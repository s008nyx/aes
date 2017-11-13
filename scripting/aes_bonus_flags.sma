#include <amxmodx>
#include <sqlx>
#if AMXX_VERSION_NUM < 183
	#include <colorchat>
#endif

forward amxbans_sql_initialized(Handle:sqlTuple, const dbPrefix[]);
forward fbans_sql_connected(Handle:sqlTuple);

enum (+=1) {
	NONE = 0,
	AMX,
	FB
}

enum _:qState     { AddOne, AddTwo }

new g_System = NONE;
new Handle:g_DBTuple;
new g_TableAdmins[32], g_TableSAdmins[32], g_TableSInfo[32], g_ServerIp[25];
new g_szQuery[512], g_Data[2];

public plugin_init()
{
#define PNAME "AES Bonus: Flags"
#define PVERSION "0.1"
#define PAUTHOR "Sonyx"
	register_plugin(PNAME, PVERSION, PAUTHOR);
}

public amxbans_sql_initialized(Handle:sqlTuple, const dbPrefix[])
{
	if (g_System != NONE) {
		return PLUGIN_CONTINUE;
	}

	g_DBTuple = sqlTuple;
	g_System = AMX;	

	formatex(g_TableAdmins, charsmax(g_TableAdmins), "%s_amxadmins", dbPrefix);
	formatex(g_TableSInfo, charsmax(g_TableSInfo), "%s_serverinfo", dbPrefix);
	formatex(g_TableSAdmins, charsmax(g_TableSAdmins), "%s_admins_servers", dbPrefix);
	
	get_cvar_string("amxbans_server_address", g_ServerIp, charsmax(g_ServerIp));
	if (!g_ServerIp[0]) {
		get_user_ip(0, g_ServerIp, charsmax(g_ServerIp), 0);
	}

	return PLUGIN_CONTINUE;
}

public fbans_sql_connected(Handle:sqlTuple)
{
	new i_Ip[16], i_Port[8];
	if (g_System != NONE) {
		return PLUGIN_CONTINUE;
	}

	g_DBTuple = sqlTuple;
	g_System = FB;
	if (!get_cvar_string("amx_amxadmins_table", g_TableAdmins, charsmax(g_TableAdmins)))
		g_TableAdmins = "amx_amxadmins";
	if (!get_cvar_string("amx_admins_table", g_TableSAdmins, charsmax(g_TableSAdmins)))
		g_TableSAdmins = "amx_admins_servers";
	get_cvar_string("fb_servers_table", g_TableSInfo, charsmax(g_TableSInfo));
	get_cvar_string("fb_server_ip", i_Ip, charsmax(i_Ip));
	get_cvar_string("fb_server_port", i_Port, charsmax(i_Port));

	formatex(g_ServerIp, charsmax(g_ServerIp), "%s:%s", i_Ip, i_Port);

	return PLUGIN_CONTINUE;
}

public SQL_Handler(failstate, Handle:query, err[], errcode, dt[], datasize)
{
	switch(failstate)
	{
		case TQUERY_CONNECT_FAILED, TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL ERROR #%d][Query State %d] %s", errcode, dt[0], err);
			SQL_FreeHandle(query);
			return;
		}
	}

	switch(dt[0])
	{
		case AddOne:
		{
			g_Data[0] = AddTwo;
			new szAuth[25], iID = SQL_GetInsertId(query);
			get_user_authid(dt[1], szAuth, charsmax(szAuth));
			formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO %s (admin_id, server_id, custom_flags, use_static_bantime) VALUES ('%d', (SELECT id FROM %s WHERE address = '%s'), '', 'no')", g_TableSAdmins, iID, g_TableSInfo, g_ServerIp);
			SQL_ThreadQuery(g_DBTuple, "SQL_Handler", g_szQuery, g_Data, sizeof(g_Data));
		}
		case AddTwo:
		{
			SQL_FreeHandle(query);
			server_cmd("amx_reloadadmins");
		}
	}
}

public pointBonus_GiveFlags(id, flags[], days)
{
	if(!flags[0] || !days)
		return 0;
	if (g_System == NONE)
	{
		client_print_color(id, id, "^4[AES] ^3Отсутствует подключение к Базе!");
		return 0;
	}
	if (get_user_flags(id) & read_flags(flags))
	{
		client_print_color(id, id, "^4[AES] ^3У вас уже есть данная привилегия!");
		return 0;
	}
	new szAuth[25], szName[32], szPlayerEnd;
	get_user_authid(id, szAuth, charsmax(szAuth));
	get_user_name(id, szName, charsmax(szName));
	szPlayerEnd = get_systime() + days * 86400;
	g_Data[0] = AddOne;
	g_Data[1] = id;
	formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO %s (username, access, flags, steamid, nickname, ashow, created, expired, days) VALUES ('%s', '%s', 'ce', '%s', '%s', '0', UNIX_TIMESTAMP(NOW()), '%d', '%d')", g_TableAdmins, szAuth, flags, szAuth, szName, szPlayerEnd, days);
	SQL_ThreadQuery(g_DBTuple, "SQL_Handler", g_szQuery, g_Data, sizeof(g_Data));
	
	return 1;
}