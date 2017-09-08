ALTER TABLE `aes_stats`
	DROP `name`,
	DROP `level`;

ALTER TABLE `aes_stats`
	CHANGE `trackId` `name` varchar(32) NOT NULL,
	CHANGE `experience` `exp` float NOT NULL DEFAULT '0',
	CHANGE `bonus` `bonus_count` int(11) NOT NULL DEFAULT '0',
	CHANGE `lastJoin` `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
	
ALTER TABLE `aes_stats`
	ADD `steamid` varchar(30) NOT NULL AFTER `name`,
	ADD `ip` varchar(16) NOT NULL AFTER `steamid`;