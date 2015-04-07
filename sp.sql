-- mySQL 

CREATE TABLE sp_receive_log (
	id int NOT NULL auto_increment,
	msg varchar(1000) NOT NULL DEFAULT "",
	PRIMARY KEY (id)
)

CREATE TABLE sp_mo_log (
	id int NOT NULL auto_increment,
	linkid varchar(100) NOT NULL DEFAULT '',
	spnum varchar(100) NOT NULL DEFAULT '',
	spname varchar(100) NOT NULL DEFAULT '',
	msg varchar(500) NOT NULL DEFAULT '',
	serviceword varchar(180) NOT NULL DEFAULT '',
	servicename varchar(180) NOT NULL DEFAULT '',
	servicefee int NOT NULL DEFAULT 0,
	servicetype varchar(24) NOT NULL DEFAULT '',	
	terminal varchar(200) NOT NULL DEFAULT '',
 	consignid int DEFAULT NULL,
	consignname varchar(180) NOT NULL DEFAULT '',
	provinceid varchar(30) NOT NULL DEFAULT '',
	provincename varchar(30) NOT NULL DEFAULT '',
	cityid varchar(30) NOT NULL DEFAULT '',
	cityname varchar(30) NOT NULL DEFAULT '',
	statusid varchar(30) NOT NULL DEFAULT '',
	statuscode varchar(30)	NOT NULL DEFAULT '',
	logtime timestamp NOT NULL DEFAULT current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8
INSERT INTO sp_mo_log (linkid, spnum, spname ,msg, serviceword, servicename, servicefee, servicetype, terminal, consignid, consignname, provinceid, provincename, cityid, cityname, statusid, statuscode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

CREATE TABLE sp_mt_log(
	id int NOT NULL auto_increment,
	linkid varchar(100) NOT NULL DEFAULT '',
	spnum varchar(100) NOT NULL DEFAULT '',
	spname varchar(100) NOT NULL DEFAULT '',	
	msg varchar(500) NOT NULL DEFAULT '',
	serviceword varchar(180) NOT NULL DEFAULT '',
	servicename varchar(180) NOT NULL DEFAULT '',
	servicefee int NOT NULL DEFAULT 0,
	servicetype varchar(24) NOT NULL DEFAULT '',
	terminal varchar(200) NOT NULL DEFAULT '',
	expendtime  int NOT NULL DEFAULT 0,
	timeline varchar(180) NOT NULL DEFAULT '',
	consignid  int DEFAULT NULL,
	consignname varchar(180) NOT NULL DEFAULT '',
	provinceid varchar(30) NOT NULL DEFAULT '',
	provincename varchar(30) NOT NULL DEFAULT '',
	cityid varchar(30) NOT NULL DEFAULT '',
	cityname varchar(30) NOT NULL DEFAULT '',
	statusid varchar(30) NOT NULL DEFAULT '',
	statuscode varchar(30)	NOT NULL DEFAULT '',
	logtime timestamp NOT NULL DEFAULT current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO	sp_mt_log(linkid, spnum, spname ,msg, serviceword, servicename, servicefee,servicetype, terminal, expendtime, timeline, consignid, consignname, provinceid, provincename, cityid, cityname, statusid, statuscode) VALUES()

CREATE TABLE sp_info (
	spnum varchar(100) NOT NULL DEFAULT '',
	spname varchar(100) NOT NULL DEFAULT '',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY (spnum)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE sp_consign (
	consignid int NOT NULL AUTO_INCREMENT,
	consignname varchar(180) NOT NULL DEFAULT '',	
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(`consignid`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE sp_service(
	serviceid int NOT NULL auto_increment,
	serviceword varchar(180) NOT NULL DEFAULT '' comment 'user input words',
	servicename varchar(180) NOT NULL DEFAULT '',
	servicetype int NOT NULL DEFAULT 0 comment '0(both mo mt) 1(only mt)',
	servicefee int NOT NULL DEFAULT 0,
	serviceip varchar(30) NOT NULL DEFAULT '',	 
	servicerule varchar(500) NOT NULL DEFAULT '' comment '{"spnum":"spnumber", "terminal":"phone", "statusid":"status", "statuscode":"code", serviceword":"content", "linkid":"linkid", "cityid":"citycode", "cityname":"cityname", "provinceid":"areacode", "provincename":"areaname", "timeline":"timeline", "expendtime":"expendtime"}', 
	referrule varchar(180) NOT NULL DEFAULT '' comment '{"key":["linkid", "terminal"], "statusid":"ok"}',
	spnum varchar(100) NOT NULL DEFAULT '',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(serviceid), 
	UNIQUE KEY  `uk_spnum_serviceword`(spnum, serviceword),
	CONSTRAINT `fk_spnum` FOREIGN KEY  (`spnum`)  REFERENCES  `sp_info` (`spnum`) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_service (serviceword, servicename, servicetype, servicefee, serviceip, servicerule, referrule, spnum) values ('t', 'rich', 0, 100, '192.168.1.222', '{"spnum":"spnumber", "terminal":"phone", "statusid":"status", "statuscode":"code","serviceword":"content", "linkid":"linkid", "cityid":"citycode", "cityname":"cityname", "provinceid":"areacode", "provincename":"areaname"}', '{"key":["linkid", "terminal"], "statusid":"ok"}','10669501')

UPDATE sp_service SET servicerule = '{"spnum":"spnumber", "terminal":"phone", "statusid":"status", "statuscode":"code", "serviceword":"content", "linkid":"linkid", "cityid":"citycode", "cityname":"cityname", "provinceid":"areacode", "provincename":"areaname"}', referrule = '{"key":["linkid", "terminal"], "statusid":"ok"}' WHERE serviceid = 1

http://localhost:10086/moReceiver?spnumber=10669501&phone=13900000002&content=t&areacode=0310&linkid=f123&status=1002
http://localhost:10086/mtReceiver?spnumber=10669501&phone=13900000002&linkid=f123&status=ok


CREATE TABLE sp_cp(
	cpid int NOT NULL auto_increment,
	consignid int DEFAULT NULL,
	serviceid int DEFAULT NULL,
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(cpid),
	CONSTRAINT `fk_consignid` FOREIGN KEY (`consignid`) REFERENCES `sp_consign` (`consignid`) on UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT `fk_serviceid` FOREIGN KEY  (`serviceid`)  REFERENCES  `sp_service` (`serviceid`) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8



--sp_service:spnum:--serviceword:-- hash {  json}
--sp_service:serviceip:---
SELECT serviceid, serviceword, servicename, servicetype, servicefee, spnum FROM sp_service

--serviceid:  hash{ json}
SELECT consignid, serviceid, servicerule, referrule FROM sp_cp
-- consignid: hash{ json}
SELECT consignid, consignname FROM 	sp_consign
-- spnum has{ json}
SELECT spnum, spname FROM sp_info




CREATE TABLE sp_msisdn(
	id int NOT NULL auto_increment,
	prefix varchar(30) NOT NULL DEFAULT '',
	provinceid varchar(30) NOT NULL DEFAULT '',
	provincename varchar(30) NOT NULL DEFAULT '',
	cityid varchar(30) NOT NULL DEFAULT '',
	cityname varchar(30) NOT NULL DEFAULT '',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_msisdn (prefix, provinceid, provincename, cityid, cityname) values("1390000", "0311", "hebeisheng", "0313", "zhangjiakou")
-- prefix: hash{ json}
SELECT id, prefix, provinceid, provincename, cityid, cityname FROM sp_msisdn

-- cityid:--cityname:--  hash{ json}

SELECT cityid, cityname, provinceid, provincename FROM sp_msisdn GROUP BY cityid, cityname

-- provinceid:--provincename:-- hash{ json}
SELECT provinceid, provincename FROM sp_msisdn GROUP BY provinceid, provincename


CREATE TABLE sp_sink(
	sinkid int NOT NULL auto_increment,
	bnum int NOT NULL DEFAULT 100,
	slice int NOT NULL DEFAULT 0,
	consignid int DEFAULT NULL,
	serviceid int DEFAULT NULL,
	provincename varchar(180) NOT NULL DEFAULT '',
	response varchar(500) NOT NULL DEFAULT '' comment '{"response":["101", "102", "103"]}',
	tconsignid int DEFAULT NULL,
	PRIMARY KEY(sinkid),
	CONSTRAINT `fk_sink_consignid` FOREIGN KEY  (`consignid`)  REFERENCES  `sp_consign` (`consignid`) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT `fk_sink_serviceid` FOREIGN KEY  (`serviceid`)  REFERENCES  `sp_service` (`serviceid`) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_sink (bnum, slice, consignid, serviceid, provincename, response, tconsignid) values(100, 20, 1, 1, "hebeisheng", '{"response":["101", "102", "103"]}', 2)
INSERT INTO sp_sink (bnum, slice, consignid, serviceid, provincename, response, tconsignid) values(100, 20, 1, 1, "", '{"response":["101", "102", "103"]}', 2)
-- consignid:--:serviceid:--provincename:-- hash{ json}
-- consignid:--:serviceid:-- hash{ json}
-- consignid:--:provincename:-- hash{ json}
-- consignid:-- {hash json}
SELECT sinkid, bnum, slice, consignid, serviceid, provincename, response,tconsignid, CONCAT('consignid:', consignid, IF(serviceid, '', CONCAT(':serviceid:', serviceid)), IF(provincename, '', CONCAT(':provincename:', provincename))) AS key1 FROM sp_sink

SELECT sinkid, bnum, slice, consignid, serviceid, provincename, response,tconsignid, CONCAT('consignid:', consignid, IF(serviceid, CONCAT(':serviceid:', serviceid), ''), IF(provincename <> '', CONCAT(':provincename:', provincename), '')) AS key1 FROM sp_sink
-- 20150306:mo:users:consignid:--:serviceid:--:provinceid:-- set {} -- scard get set count




CREATE TABLE sp_final_stat (
	id int NOT NULL auto_increment,

	spnum varchar(100) NOT NULL DEFAULT '',
	spname varchar(100) NOT NULL DEFAULT '',

	consignid int DEFAULT NULL,
	consignname varchar(180) NOT NULL DEFAULT '',

	serviceid int DEFAULT NULL,
	servicename varchar(180) NOT NULL DEFAULT '',

	provinceid varchar(30) NOT NULL DEFAULT '',
	provincename varchar(30) NOT NULL DEFAULT '',

	monums int NOT NULL DEFAULT 0,
	mousers int NOT NULL DEFAULT 0, 
	mtnums int NOT NULL DEFAULT 0,
	mtusers int NOT NULL DEFAULT 0,
	fee int NOT NULL DEFAULT 0,

	day varchar(30) NOT NULL DEFAULT '' comment 'format/20150303',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,

	PRIMARY KEY(id),
	UNIQUE KEY `uk_day_spnum_consignid_serviceid_provinceid` (day, spnum, consignid, serviceid, provinceid),
	KEY day_spname_consign(day, consignid, spnum),
	KEY day_spname_servicename(day, serviceid, spnum),
	KEY day_spname_provincename(day, provinceid, spnum)
 )ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_final_stat (spnum, spname, consignid, consignname, serviceid, servicename, provinceid, provincename, monums, mousers, day) VALUES ("10669501","九五在线", 1, "三星国际", 1, "rich", "0311", "河北", 1, 8, 20150319) ON DUPLICATE KEY UPDATE monums = monums + 1, mousers = VALUES(mousers);

SELECT spnum, spname, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" GROUP BY spname

SELECT spnum, spname, consignid, consignname, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND spnum = "10669501" GROUP BY consignid

SELECT spnum, spname, serviceid, servicename, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND spnum = "10669501" GROUP BY serviceid


-- common user
-- by serviceid
SELECT serviceid, servicename, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) GROUP BY serviceid 
--  by consignid
SELECT consignid, consignname, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) GROUP BY serviceid 
--  by provincename
SELECT provinceid, provincename, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) GROUP BY serviceid 


-- admin 

SELECT spnum, spname, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) GROUP BY  spnum, spname
-- admin user

-- by serviceid
SELECT serviceid, servicename, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?)  AND spnum = ?GROUP BY serviceid 
--  by consignid
SELECT consignid, consignname, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) AND spnum = ?GROUP BY consignid 
--  by provincename
SELECT provinceid, provincename, SUM(monums), SUM(mtnums), SUM(mousers), SUM(mtusers), SUM(fee) FROM sp_final_stat WHERE day >= "20150319" AND day <= "20150319" AND consign IN (?) AND spnum = ? GROUP BY provinceid 



CREATE TABLE sp_sink_stat (
	id int NOT NULL auto_increment,

	spnum varchar(100) NOT NULL DEFAULT '',
	spname varchar(100) NOT NULL DEFAULT '',

	consignid int DEFAULT NULL,
	consignname varchar(180) NOT NULL DEFAULT '',

	serviceid int DEFAULT NULL,
	servicename varchar(180) NOT NULL DEFAULT '',

	provinceid varchar(30) NOT NULL DEFAULT '',
	provincename varchar(30) NOT NULL DEFAULT '',

	monums int NOT NULL DEFAULT 0,
	mousers int NOT NULL DEFAULT 0, 
	mtnums int NOT NULL DEFAULT 0,
	mtusers int NOT NULL DEFAULT 0,
	fee int NOT NULL DEFAULT 0,

	day varchar(30) NOT NULL DEFAULT '' comment 'format/20150303',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,

	PRIMARY KEY(id),
	UNIQUE KEY `uk_day_spnum_consignid_serviceid_provinceid` (day, spnum, consignid, serviceid, provinceid),
	KEY day_spname_consign(day, spnum, consignid),
	KEY day_spname_servicename(day, spnum, serviceid),
	KEY day_spname_provincename(day, spnum, provinceid)

)ENGINE=InnoDB DEFAULT CHARSET=utf8

-- rbac

CREATE TABLE sp_user (
	id int NOT NULL AUTO_INCREMENT,
	username varchar(100) NOT NULL DEFAULT '',
	password varchar(100) NOT NULL DEFAULT '',
	roleid int NOT NULL DEFAULT 0,
	accessid int NOT NULL DEFAULT 0,
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_user(username, password, roleid, accessid)  VALUES("root", "admin", 2, 1) 

INSERT INTO sp_user(username, password, roleid, accessid)  VALUES("kefu", "kefu", 16, 1) 
INSERT INTO sp_user(username, password, roleid, accessid)  VALUES("qudao", "qudao", 8, 1) 

INSERT INTO sp_user(username, password, roleid, accessid)  VALUES("qudao1", "qudao1", 8, 3) 

INSERT INTO sp_user(username, password, roleid, accessid)  VALUES("coco", "coco", 4, 2) 



CREATE TABLE sp_role (
	id int NOT NULL DEFAULT 0,	
	name varchar(100) NOT NULL DEFAULT '' comment 'user, services, admin, guess',
	privilege int NOT NULL DEFAULT 0,
	menu int NOT NULL DEFAULT 0,
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_role (id, name, privilege, menu) VALUES (1, "匿名用户", 65, 0), (2, "管理员", 16383, 15), (4, "普通用户", 8395, 2), (8,"渠道管理员", 13295, 11), (16, "客户服务",12387,8)

CREATE TABLE sp_node_privilege (
	id int NOT NULL DEFAULT 0,
	name varchar(100) NOT NULL DEFAULT '',
	node varchar(500) NOT NULL DEFAULT '' comment '1:/login, 2:/, 4:/admin, 8:/common, 16:/sink, 32:/service, 64:/rLogin, 128:/user, 256:/fs/admin/, 512:/fs/adu, 1024:/fs/admin/sink, 2048:/fs/adu/sink, 4096:/ur, 8192:/logout',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_node_privilege (id, name, node)  VALUES (1, "登录页", "/login"), (2, "首页", "/"), (4, "统计查询页", "/admin"), (8, "明细查询页", "/common"), (16, "扣量查询页", "/sink"), (32, "客服查询页", "/service"), (64, "登录验证请求", "/rLogin"), (128, "明细查询请求", "/user"), (256, "统计查询请求", "/fs/admin"), (512, "统计查询-明细查询请求", "/fs/adu"), (1024, "扣量查询请求", "/fs/admin/sink"), (2048, "扣量查询-明细查询请求", "/fs/adu/sink"), (4096, "客服查询请求", "/ur"), (8192, "退出登录", "/logout")

CREATE TABLE sp_access_privilege (
	id int NOT NULL AUTO_INCREMENT,
	pri_group varchar(500) NOT NULL DEFAULT '' comment '1;2;3;4;5',	
	pri_rule int NOT NULL DEFAULT 0 comment '1:all, 2:allow, 4:ban',
	logtime timestamp NOT NULL DEFAULT current_timestamp ON update current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8

INSERT INTO sp_access_privilege (pri_group, pri_rule) VALUES ('', 1)

INSERT INTO sp_access_privilege (pri_group, pri_rule) VALUES ('1', 2)

INSERT INTO sp_access_privilege (pri_group, pri_rule) VALUES ('1', 4)

CREATE TABLE sp_menu_template (
	id int NOT NULL DEFAULT 0 comment '1 2 4 8',
	title varchar(100) NOT NULL DEFAULT '' comment '统计查询 明细查询 扣量查询 客服查询 ', 
	name varchar(100) NOT NULL DEFAULT '' comment 'admin common sink service', 
	logtime timestamp NOT NULL DEFAULT current_timestamp ON UPDATE current_timestamp,
	PRIMARY KEY(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8


INSERT INTO sp_menu_template (id, title, name)  VALUES(1, "统计查询", "admin"), (2, "明细查询", "common"), (4, "扣量查询", "sink"), (8, "客服查询", "service")


SELECT a.id, a.username, a.password, a.roleid, b.name, b.privilege, a.accessid, c.group, c.rule FROM sp_user a 
	INNER JOIN sp_role b ON a.roleid = b.id
	INNER JOIN sp_access_privilege c ON a.accessid = c.id
	WHERE username = ? AND password = ? 












 