/* 
	Advanced Experience System
	by serfreeman1337		http://gf.hldm.org/
*/

/*
	Random CSTRIKE Bonuses
*/

#include <amxmodx>

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
	
	#define print_team_default DontChange
	#define print_team_grey Grey
	#define print_team_red Red
	#define print_team_blue Blue
	
	#define MAX_NAME_LENGTH	32
	#define MAX_PLAYERS 32
	
	#define client_disconnected client_disconnect
#endif

#include <aes_v>
#include <engine>
#include <reapi>

#define PLUGIN "AES: Bonus CSTRIKE"
#define VERSION "0.5.1 Vega[REAPI]"
#define AUTHOR "serfreeman1337"

// биты? да это же круто!
enum _:
{
	SUPER_NICHEGO,
	SUPER_NADE,
	SUPER_DEAGLE
}

new g_PlayerPos[33], g_iSyncMsg, g_iSyncMsg2, g_ModeDam[33]
new const Float:g_flCoords[][] = { {0.55, 0.55}, {0.5, 0.55}, {0.55, 0.5}, {0.45, 0.5}, {0.45, 0.45}, {0.5, 0.45}, {0.55, 0.45}, {0.45, 0.55} }
new g_players[MAX_PLAYERS + 1],g_maxplayers
new bool: g_PointDam[33] = false

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "CBasePlayer_TakeDamage_Post", false)
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)
	register_event ("Damage", "EventDamage", "b", "2!0")
	g_maxplayers = get_maxplayers()
	
	g_iSyncMsg = CreateHudSyncObj()
	g_iSyncMsg2 = CreateHudSyncObj()
}

public client_disconnected(id)
{
	g_players[id] = SUPER_NICHEGO // сбрасываем возможности на дисконнекте
}

public CBasePlayer_Killed_Post(const victim, const killer)
	g_players[victim] = SUPER_NICHEGO // сбрасываем возможности при смерти

public CBasePlayer_TakeDamage_Post(const id, idinflictor, idattacker, Float:damage){
	new Float:dmg = damage
	
	if(!idattacker || idattacker > g_maxplayers)
		return HC_CONTINUE
	
	if(g_players[idattacker])
	{	
	if(idattacker == idinflictor && get_member(get_member(idattacker, m_pActiveItem), m_iId) == WEAPON_DEAGLE && (g_players[idattacker] & (1 << SUPER_DEAGLE))){
		dmg = damage * 2.0
	}
	else if(FClassnameIs(idinflictor, "grenade") && (g_players[idattacker] & (1 << SUPER_NADE))){
		set_task(0.5,"deSetNade",idattacker)
		dmg = damage * 3.0
	}
	SetHookChainArg(4, ATYPE_FLOAT, dmg)
	}
	return HC_CONTINUE
}

public EventDamage(iVictim)
{
	static iKiller;
	iKiller = get_user_attacker(iVictim);
	if(!iVictim || iVictim > g_maxplayers) return;
	if(!iKiller || iKiller > g_maxplayers) return;
	new iPos = ++g_PlayerPos[iKiller]
	if(iPos == sizeof(g_flCoords))
	{
		iPos = g_PlayerPos[iKiller] = 0
	}
	if (g_PointDam[iKiller] && iVictim != iKiller) 
	{
		if (g_ModeDam[iKiller] == 1)
		{
			set_hudmessage(0, 100, 200, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.0, 1.0, 0.0, 0.0)
			ShowSyncHudMsg(iKiller, g_iSyncMsg, "%i^n", read_data(2))
		}
		else if (g_ModeDam[iKiller] == 2 && ent_sees_ent(iVictim, iKiller))
		{
			set_hudmessage(0, 100, 200, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.0, 1.0, 0.0, 0.0)
			ShowSyncHudMsg(iKiller, g_iSyncMsg, "%i^n", read_data(2))
		}
	}
	if (g_PointDam[iVictim]) 
	{
		set_hudmessage(200, 100, 0, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.0, 1.0, 0.0, 0.0)
		ShowSyncHudMsg(iVictim, g_iSyncMsg2, "%i^n", read_data(2))
	}
}
// сбарсываем множитель урона гранаты
public deSetNade(id)
	g_players[id] &= ~(1<<SUPER_NADE)

public roundBonus_GiveDefuser(id,cnt){
	if(!cnt)
		return false
	
	if(get_member(id, m_iTeam) != TEAM_CT)
		return false

	rg_give_item(id, "item_thighpack")
	
	return true
}

public roundBonus_GiveNV(id,cnt){
	if(!cnt)
		return false
	
	set_member(id, m_bHasNightVision, 1)
	
	return true
}

public roundBonus_Dmgr(id,cnt){
	if(!cnt || cnt <= 0)
		return false
	
	g_PointDam[id] = true
	g_ModeDam[id] = (1 < cnt <= 2) ? cnt : 1
	
	return true
}

public roundBonus_GiveArmor(id,cnt){
	if(!cnt)
	{
		return false
	}
	
	switch(cnt)
	{
		case 1:
		{
			rg_give_item(id, "item_kevlar", GT_REPLACE)
		}
		case 2: 
		{
			rg_give_item(id, "item_assaultsuit", GT_REPLACE)
		}
		default:
		{
			new Float:i_Armo = get_entvar(id, var_armorvalue)
			rg_give_item(id, "item_assaultsuit", GT_REPLACE)
			set_entvar(id, var_armorvalue, (float(cnt) < i_Armo) ? i_Armo : float(cnt))
		}
	}
	
	return true
}

public roundBonus_GiveHP(id,cnt){
	if(!cnt)
		return false
	
	set_entvar(id, var_health, (get_entvar(id, var_health) + float(cnt)))
	return true
}

#define CHECK_ALIVE(%1) \
if(!is_user_alive(%1)){\
	client_print_color(id,0,"%L %L",id,"AES_TAG",id,"AES_ANEW_ALIVE"); \
	return 0; \
}

public pointBonus_GiveM4a1(id)
{
	CHECK_ALIVE(id)
	
	rg_give_item(id, "weapon_m4a1", GT_REPLACE)
	rg_set_user_bpammo(id, WEAPON_M4A1, 90)
	
	return true
}

public pointBonus_GiveAk47(id)
{
	CHECK_ALIVE(id)
	
	rg_give_item(id, "weapon_ak47", GT_REPLACE)
	rg_set_user_bpammo(id, WEAPON_AK47, 90)
	
	return true
}

public pointBonus_GiveAWP(id)
{
	CHECK_ALIVE(id)
	
	rg_give_item(id, "weapon_awp", GT_REPLACE)
	rg_set_user_bpammo(id, WEAPON_AWP, 30)
	
	return true
}

public pointBonus_Dmgr(id)
{
	g_PointDam[id] = true;
	
	return true
}

public pointBonus_Give10000M(id)
{
	CHECK_ALIVE(id)
	
	rg_add_account(id, 10000)
	
	return true
}

public pointBonus_Set200HP(id)
{
	CHECK_ALIVE(id)
	
	set_entvar(id, var_health, 200.0)
	
	return true
}

public pointBonus_Set200CP(id)
{
	CHECK_ALIVE(id)
	
	rg_give_item(id, "item_assaultsuit", GT_REPLACE)
	set_entvar(id, var_armorvalue, 200.0)
	
	return true
}

public pointBonus_GiveMegaGrenade(id)
{
	CHECK_ALIVE(id)
	
	if(!user_has_weapon(id,CSW_HEGRENADE))
	{
		rg_give_item(id, "weapon_hegrenade")
	}
	
	g_players[id] |= (1<<SUPER_NADE)
	
	client_print_color(id,0,"%L %L",id,"AES_TAG",id,"AES_BONUS_GET_MEGAGRENADE")
	
	return true
}

public pointBonus_GiveMegaDeagle(id){
	CHECK_ALIVE(id)
	
	rg_give_item(id, "weapon_deagle", GT_REPLACE)
	rg_set_user_bpammo(id, WEAPON_DEAGLE, 35)
	
	g_players[id] |= (1<<SUPER_DEAGLE)
	
	client_print_color(id,0,"%L %L",id,"AES_TAG",id,"AES_BONUS_GET_MEGADEAGLE")
	
	return true
}

stock bool:ent_sees_ent(iEnt, iEnt2)
{
	static Float:fEntOrigin[3], Float:fEnt2Origin[3], Float:fResult[3];
	entity_get_vector(iEnt, EV_VEC_origin, fEntOrigin);
	entity_get_vector(iEnt2, EV_VEC_origin, fEnt2Origin);
	return trace_line(iEnt, fEntOrigin, fEnt2Origin, fResult) == iEnt2;
}