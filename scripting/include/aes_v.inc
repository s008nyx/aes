//
//	Advanced Experience System
//	by serfreeman1337	http://gf.hldm.org/
//

enum _:
{
	AES_RT_NO,
	AES_RT_YES,
	AES_RT_LEVEL_DOWN,
	AES_RT_LEVEL_UP
}

//
// Array structure for get stats with aes_find_stats_thread native
//
enum _:aes_stats_struct
{
	AES_S_NAME[MAX_NAME_LENGTH],
	AES_S_STEAMID[30],
	AES_S_IP[16],
	
	Float:AES_S_EXP,
	AES_S_LEVEL,
	AES_S_BONUS,
	
	AES_S_ID
}

#define AES_MAX_LEVEL_LENGTH 32

//
// Returns player experience
//	@player - player id
//	
//	@return - player experience or -1.0 if player not tracked yet
//
native Float:aes_get_player_exp(player)

//
// Sets player experience
//	@player - player id
//	@exp - experience value
//	@no_forward - dont trigger forward functions on level up or level down
//	@force - force even if track paused
//
//	@return
//		AES_RT_NO - on track pause or player not tracked yet
//		AES_RT_YES - on success
//		AES_RT_LEVLE_DOWN - on level down
//		AES_RT_LEVEL_UP - on level up
//
native aes_set_player_exp(player,Float:exp,bool:no_forward = false,bool:force = false)

//
// Returns player required experience to next level
//	@player - player id
//
//	@return - required experience value
//
native Float:aes_get_player_reqexp(player)

//
// Returns player bonus points
//	@player - player id
//
//	@return - player bonus points or -1 if player
//
native aes_get_player_bonus(player)

//
// Sets player bonus points
//	@player - player id
//	@bonus - bonus value
//	@force - force even if track paused
//
//	@return
//		AES_RT_NO - on track pause or player not tracked yet
//		AES_RT_YES - on success
//
native aes_set_player_bonus(player,bonus,bool:force = false)

//
// Returns current player level
//	@player - player id
//
//	@return - current player level or -1 if player not tracked yet
//
native aes_get_player_level(player)

//
// Sets player level
//	@player - player id
//	@level - level
//	@force - force even if track paused
//
//	@return
//		AES_RT_NO - on track pause or player not tracked yet
//		AES_RT_YES - on success
//
native aes_set_player_level(player,level,bool:force = false)

//
// Returns maximum level
//
native aes_get_max_level()

//
// Returns level name for level num.
//	
//	@level - level number
//	@level[] - level name output
//	@len - len
//	@idLang - language id
//	
//	@return - len
//
native aes_get_level_name(level,level_name[],len,idLang = LANG_SERVER)

//
// Returns level for experience
//	@exp - experience value
//	
//	@return - level num or -1 of fail
//
native aes_get_exp_level(Float:exp)

//
// Returns required experience to pass level
//	@lvl - level
//
//	@return - required experience value or -1.0 on fail
//
native Float:aes_get_level_reqexp(level)

//
// Thread search for aes stats witch given array track_ids
//	@id - player id
//	@track_ids - dynamic array with track ids for search
//	@callback - your callback function
//		public my_callback(id,Array:aes_stats,stats_data[])
//	@data[] - custom data
//	@data_size - custom data size
//
//	@return - true or false
//
native aes_find_stats_thread(id = 0,Array:track_ids,callback[],data[] = "",datasize = 0)

//
// Called on player level up.
//
forward aes_player_levelup(id,new_level,old_level)

//
// Called on player level down.
//
forward aes_player_leveldown(id,new_level,old_level)

#define aes_add_player_exp_f(%0,%1) aes_set_player_exp(%0,aes_get_player_exp(%0) + %1)
#define aes_add_player_bonus_f(%0,%1) aes_set_player_bonus(%0,aes_get_player_bonus(%0) + %1)
