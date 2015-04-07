-- MySQL dump 10.13  Distrib 5.5.41, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: sp
-- ------------------------------------------------------
-- Server version	5.5.41-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `sp_access_privilege`
--

DROP TABLE IF EXISTS `sp_access_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_access_privilege` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pri_group` varchar(500) NOT NULL DEFAULT '' COMMENT '1;2;3;4;5',
  `pri_rule` int(11) NOT NULL DEFAULT '0' COMMENT '1:all, 2:allow, 4:ban',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_access_privilege`
--

LOCK TABLES `sp_access_privilege` WRITE;
/*!40000 ALTER TABLE `sp_access_privilege` DISABLE KEYS */;
INSERT INTO `sp_access_privilege` VALUES (1,'',1,'2015-04-02 05:49:15'),(2,'1',2,'2015-04-03 13:00:29'),(3,'1',4,'2015-04-03 13:03:14');
/*!40000 ALTER TABLE `sp_access_privilege` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_consign`
--

DROP TABLE IF EXISTS `sp_consign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_consign` (
  `consignid` int(11) NOT NULL AUTO_INCREMENT,
  `consignname` varchar(180) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`consignid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_consign`
--

LOCK TABLES `sp_consign` WRITE;
/*!40000 ALTER TABLE `sp_consign` DISABLE KEYS */;
INSERT INTO `sp_consign` VALUES (1,'三星国际','2015-03-09 10:36:56'),(2,'LG company','2015-03-09 10:41:58');
/*!40000 ALTER TABLE `sp_consign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_cp`
--

DROP TABLE IF EXISTS `sp_cp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_cp` (
  `cpid` int(11) NOT NULL AUTO_INCREMENT,
  `consignid` int(11) DEFAULT NULL,
  `serviceid` int(11) DEFAULT NULL,
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cpid`),
  KEY `fk_consignid` (`consignid`),
  KEY `fk_serviceid` (`serviceid`),
  CONSTRAINT `fk_consignid` FOREIGN KEY (`consignid`) REFERENCES `sp_consign` (`consignid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_serviceid` FOREIGN KEY (`serviceid`) REFERENCES `sp_service` (`serviceid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_cp`
--

LOCK TABLES `sp_cp` WRITE;
/*!40000 ALTER TABLE `sp_cp` DISABLE KEYS */;
INSERT INTO `sp_cp` VALUES (1,1,1,'2015-03-10 08:11:43');
/*!40000 ALTER TABLE `sp_cp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_final_stat`
--

DROP TABLE IF EXISTS `sp_final_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_final_stat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `spname` varchar(100) NOT NULL DEFAULT '',
  `consignid` int(11) DEFAULT NULL,
  `consignname` varchar(180) NOT NULL DEFAULT '',
  `serviceid` int(11) DEFAULT NULL,
  `servicename` varchar(180) NOT NULL DEFAULT '',
  `provinceid` varchar(30) NOT NULL DEFAULT '',
  `provincename` varchar(30) NOT NULL DEFAULT '',
  `monums` int(11) NOT NULL DEFAULT '0',
  `mousers` int(11) NOT NULL DEFAULT '0',
  `mtnums` int(11) NOT NULL DEFAULT '0',
  `mtusers` int(11) NOT NULL DEFAULT '0',
  `fee` int(11) NOT NULL DEFAULT '0',
  `day` varchar(30) NOT NULL DEFAULT '' COMMENT 'format/20150303',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_day_spnum_consignid_serviceid_provinceid` (`day`,`spnum`,`consignid`,`serviceid`,`provinceid`),
  KEY `day_spname_consign` (`day`,`spnum`,`consignid`),
  KEY `day_spname_servicename` (`day`,`spnum`,`serviceid`),
  KEY `day_spname_provincename` (`day`,`spnum`,`provinceid`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_final_stat`
--

LOCK TABLES `sp_final_stat` WRITE;
/*!40000 ALTER TABLE `sp_final_stat` DISABLE KEYS */;
INSERT INTO `sp_final_stat` VALUES (1,'10669501','九五在线',1,'三星国际',1,'rich','0311','河北',3,8,0,0,0,'2015-04-01','2015-04-03 03:34:45'),(4,'10669501','九五在线',1,'三星国际',1,'rich','0311','hebeisheng',12,2,37,1,3700,'2015-04-02','2015-04-03 03:35:12'),(48,'10669501','九五在线',2,'LG company',1,'rich','0311','hebeisheng',0,0,1,0,100,'2015-04-03','2015-04-03 03:35:00');
/*!40000 ALTER TABLE `sp_final_stat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_info`
--

DROP TABLE IF EXISTS `sp_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_info` (
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `spname` varchar(100) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`spnum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_info`
--

LOCK TABLES `sp_info` WRITE;
/*!40000 ALTER TABLE `sp_info` DISABLE KEYS */;
INSERT INTO `sp_info` VALUES ('10669501','九五在线','2015-03-09 10:26:55');
/*!40000 ALTER TABLE `sp_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_menu_template`
--

DROP TABLE IF EXISTS `sp_menu_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_menu_template` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '1 2 4 8',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '统计查询 明细查询 扣量查询 客服查询 ',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT 'admin common sink service',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_menu_template`
--

LOCK TABLES `sp_menu_template` WRITE;
/*!40000 ALTER TABLE `sp_menu_template` DISABLE KEYS */;
INSERT INTO `sp_menu_template` VALUES (1,'统计查询','admin','2015-04-01 11:21:41'),(2,'明细查询','common','2015-04-01 11:21:41'),(4,'扣量查询','sink','2015-04-01 11:21:41'),(8,'客服查询','service','2015-04-01 11:21:41');
/*!40000 ALTER TABLE `sp_menu_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_mo_log`
--

DROP TABLE IF EXISTS `sp_mo_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_mo_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `linkid` varchar(100) NOT NULL DEFAULT '',
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `spname` varchar(100) NOT NULL DEFAULT '',
  `msg` varchar(500) NOT NULL DEFAULT '',
  `serviceword` varchar(180) NOT NULL DEFAULT '',
  `servicename` varchar(180) NOT NULL DEFAULT '',
  `servicefee` int(11) NOT NULL DEFAULT '0',
  `servicetype` varchar(24) NOT NULL DEFAULT '',
  `terminal` varchar(200) NOT NULL DEFAULT '',
  `consignid` int(11) DEFAULT NULL,
  `consignname` varchar(180) NOT NULL DEFAULT '',
  `provinceid` varchar(30) NOT NULL DEFAULT '',
  `provincename` varchar(30) NOT NULL DEFAULT '',
  `cityid` varchar(30) NOT NULL DEFAULT '',
  `cityname` varchar(30) NOT NULL DEFAULT '',
  `statusid` varchar(30) NOT NULL DEFAULT '',
  `statuscode` varchar(30) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_mo_log`
--

LOCK TABLES `sp_mo_log` WRITE;
/*!40000 ALTER TABLE `sp_mo_log` DISABLE KEYS */;
INSERT INTO `sp_mo_log` VALUES (1,'f123','10669501','九五在线','t','t','rich',100,'0','13900000001',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 04:26:44'),(2,'f123','10669501','九五在线','t','t','rich',100,'0','13900000001',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:16:35'),(3,'f123','10669501','九五在线','t','t','rich',100,'0','13900000001',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:17:57'),(4,'f123','10669501','九五在线','t','t','rich',100,'0','13900000001',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:20:28'),(5,'f123','10669501','九五在线','t','t','rich',100,'0','13900000001',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:22:23'),(6,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:23:07'),(7,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 05:36:24'),(8,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 06:17:45'),(9,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 06:17:48'),(10,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 06:17:50'),(11,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 06:17:51'),(12,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','','','2015-03-23 06:18:07'),(13,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','1002','','2015-03-23 06:38:52'),(14,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','1002','','2015-03-23 06:41:02'),(15,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','1002','','2015-03-23 09:31:46');
/*!40000 ALTER TABLE `sp_mo_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_msisdn`
--

DROP TABLE IF EXISTS `sp_msisdn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_msisdn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(30) NOT NULL DEFAULT '',
  `provinceid` varchar(30) NOT NULL DEFAULT '',
  `provincename` varchar(30) NOT NULL DEFAULT '',
  `cityid` varchar(30) NOT NULL DEFAULT '',
  `cityname` varchar(30) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_msisdn`
--

LOCK TABLES `sp_msisdn` WRITE;
/*!40000 ALTER TABLE `sp_msisdn` DISABLE KEYS */;
INSERT INTO `sp_msisdn` VALUES (1,'1390000','0311','hebeisheng','0313','zhangjiakou','2015-03-10 08:51:18');
/*!40000 ALTER TABLE `sp_msisdn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_mt_log`
--

DROP TABLE IF EXISTS `sp_mt_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_mt_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `linkid` varchar(100) NOT NULL DEFAULT '',
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `spname` varchar(100) NOT NULL DEFAULT '',
  `msg` varchar(500) NOT NULL DEFAULT '',
  `serviceword` varchar(180) NOT NULL DEFAULT '',
  `servicename` varchar(180) NOT NULL DEFAULT '',
  `servicefee` int(11) NOT NULL DEFAULT '0',
  `servicetype` varchar(24) NOT NULL DEFAULT '',
  `terminal` varchar(200) NOT NULL DEFAULT '',
  `expendtime` int(11) NOT NULL DEFAULT '0',
  `timeline` varchar(180) NOT NULL DEFAULT '',
  `consignid` int(11) DEFAULT NULL,
  `consignname` varchar(180) NOT NULL DEFAULT '',
  `provinceid` varchar(30) NOT NULL DEFAULT '',
  `provincename` varchar(30) NOT NULL DEFAULT '',
  `cityid` varchar(30) NOT NULL DEFAULT '',
  `cityname` varchar(30) NOT NULL DEFAULT '',
  `statusid` varchar(30) NOT NULL DEFAULT '',
  `statuscode` varchar(30) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_mt_log`
--

LOCK TABLES `sp_mt_log` WRITE;
/*!40000 ALTER TABLE `sp_mt_log` DISABLE KEYS */;
INSERT INTO `sp_mt_log` VALUES (1,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:03:24'),(2,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:04:57'),(3,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:14:49'),(4,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:15:44'),(5,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:15:58'),(6,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:08'),(7,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:12'),(8,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:15'),(9,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:17'),(10,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:24'),(11,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:18:54'),(12,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:41:40'),(13,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:43:10'),(14,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:46:51'),(15,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:48:52'),(16,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 07:53:20'),(17,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:00:23'),(18,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:12:10'),(19,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:12:53'),(20,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:12:56'),(21,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:12:58'),(22,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:19:45'),(23,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:19:59'),(24,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:20:02'),(25,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:20:20'),(26,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:25:49'),(27,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:25:56'),(28,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:26:04'),(29,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:26:05'),(30,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:40:14'),(31,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:40:17'),(32,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:40:45'),(33,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:41:05'),(34,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','103','','2015-03-23 08:41:14'),(35,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',2,'LG company','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 08:41:14'),(36,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 09:19:50'),(37,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 09:20:40'),(38,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 09:20:45'),(39,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 09:20:46'),(40,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',1,'三星国际','0311','hebeisheng','0313','zhangjiakou','103','','2015-03-23 09:20:54'),(41,'f123','10669501','九五在线','t','t','rich',100,'0','13900000002',0,'',2,'LG company','0311','hebeisheng','0313','zhangjiakou','200','','2015-03-23 09:20:54');
/*!40000 ALTER TABLE `sp_mt_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_node_privilege`
--

DROP TABLE IF EXISTS `sp_node_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_node_privilege` (
  `id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL DEFAULT '',
  `node` varchar(500) NOT NULL DEFAULT '' COMMENT '1:/login, 2:/, 4:/admin, 8:/common, 16:/sink, 32:/service, 64:/rLogin, 128:/user, 256:/fs/admin/, 512:/fs/adu, 1024:/fs/admin/sink, 2048:/fs/adu/sink, 4096:/ur, 8192:/logout',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_node_privilege`
--

LOCK TABLES `sp_node_privilege` WRITE;
/*!40000 ALTER TABLE `sp_node_privilege` DISABLE KEYS */;
INSERT INTO `sp_node_privilege` VALUES (1,'登录页','/login','2015-04-03 12:39:00'),(2,'首页','/','2015-04-03 12:39:00'),(4,'统计查询页','/admin','2015-04-03 12:39:00'),(8,'明细查询页','/common','2015-04-03 12:39:00'),(16,'扣量查询页','/sink','2015-04-03 12:39:00'),(32,'客服查询页','/service','2015-04-03 12:39:00'),(64,'登录验证请求','/rLogin','2015-04-03 12:39:00'),(128,'明细查询请求','/user','2015-04-03 12:39:00'),(256,'统计查询请求','/fs/admin','2015-04-03 12:39:00'),(512,'统计查询-明细查询请求','/fs/adu','2015-04-03 12:39:00'),(1024,'扣量查询请求','/fs/admin/sink','2015-04-03 12:39:00'),(2048,'扣量查询-明细查询请求','/fs/adu/sink','2015-04-03 12:39:00'),(4096,'客服查询请求','/ur','2015-04-03 12:39:00'),(8192,'退出登录','/logout','2015-04-03 12:39:00');
/*!40000 ALTER TABLE `sp_node_privilege` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_receive_log`
--

DROP TABLE IF EXISTS `sp_receive_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_receive_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `msg` varchar(1000) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_receive_log`
--

LOCK TABLES `sp_receive_log` WRITE;
/*!40000 ALTER TABLE `sp_receive_log` DISABLE KEYS */;
INSERT INTO `sp_receive_log` VALUES (1,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(2,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(3,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(4,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(5,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(6,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(7,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(8,'{\"mobile\":[\"1390111111\"],\"provinceid\":[\"0310\"],\"rip\":[\"127.0.0.1\"],\"servicecode\":[\"t\"],\"spnum\":[\"901077\"]}'),(9,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"1390111111\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(10,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"1390111111\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(11,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"1390111111\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(12,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"1391111111\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(13,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(14,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(15,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(16,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(17,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"901077\"]}'),(18,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(19,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(20,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(21,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(22,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(23,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(24,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(25,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(26,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(27,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(28,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(29,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000001\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(30,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(31,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(32,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(33,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(34,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(35,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(36,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"]}'),(37,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"1002\"]}'),(38,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"1002\"]}'),(39,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(40,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(41,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(42,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(43,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(44,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(45,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(46,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(47,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(48,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(49,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(50,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(51,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(52,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(53,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(54,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(55,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(56,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(57,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(58,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(59,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(60,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(61,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(62,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(63,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(64,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(65,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(66,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(67,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(68,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(69,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(70,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(71,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(72,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(73,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(74,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(75,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(76,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(77,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(78,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(79,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(80,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(81,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(82,'{\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"ok\"]}'),(83,'{\"areacode\":[\"0310\"],\"content\":[\"t\"],\"linkid\":[\"f123\"],\"phone\":[\"13900000002\"],\"rip\":[\"127.0.0.1\"],\"spnumber\":[\"10669501\"],\"status\":[\"1002\"]}');
/*!40000 ALTER TABLE `sp_receive_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_role`
--

DROP TABLE IF EXISTS `sp_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_role` (
  `id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT 'user, services, admin, guess',
  `privilege` int(11) NOT NULL DEFAULT '0',
  `menu` int(11) NOT NULL DEFAULT '0',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_role`
--

LOCK TABLES `sp_role` WRITE;
/*!40000 ALTER TABLE `sp_role` DISABLE KEYS */;
INSERT INTO `sp_role` VALUES (1,'匿名用户',65,0,'2015-04-03 12:57:12'),(2,'管理员',16383,15,'2015-04-03 12:57:12'),(4,'普通用户',8395,2,'2015-04-03 12:57:12'),(8,'渠道管理员',13295,11,'2015-04-03 12:57:12'),(16,'客户服务',12387,8,'2015-04-03 12:57:12');
/*!40000 ALTER TABLE `sp_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_service`
--

DROP TABLE IF EXISTS `sp_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_service` (
  `serviceid` int(11) NOT NULL AUTO_INCREMENT,
  `serviceword` varchar(180) NOT NULL DEFAULT '' COMMENT 'user input words',
  `servicename` varchar(180) NOT NULL DEFAULT '',
  `servicetype` int(11) NOT NULL DEFAULT '0' COMMENT '0(both mo mt) 1(only mt)',
  `servicefee` int(11) NOT NULL DEFAULT '0',
  `serviceip` varchar(30) NOT NULL DEFAULT '',
  `servicerule` varchar(500) NOT NULL DEFAULT '' COMMENT '{"spnum":"spnumber", "terminal":"phone", "statusid":"status", "serviceword":"content", "linkid":"linkid", "cityid":"citycode", "cityname":"cityname", "provinceid":"areacode", "provincename":"areaname"}',
  `referrule` varchar(180) NOT NULL DEFAULT '' COMMENT '{"key":["linkid", "terminal"]}',
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`serviceid`),
  UNIQUE KEY `uk_spnum_serviceword` (`spnum`,`serviceword`),
  CONSTRAINT `fk_spnum` FOREIGN KEY (`spnum`) REFERENCES `sp_info` (`spnum`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_service`
--

LOCK TABLES `sp_service` WRITE;
/*!40000 ALTER TABLE `sp_service` DISABLE KEYS */;
INSERT INTO `sp_service` VALUES (1,'t','rich',0,100,'127.0.0.1','{\"spnum\":\"spnumber\", \"terminal\":\"phone\", \"statusid\":\"status\", \"statuscode\":\"code\", \"serviceword\":\"content\", \"linkid\":\"linkid\", \"cityid\":\"citycode\", \"cityname\":\"cityname\", \"provinceid\":\"areacode\", \"provincename\":\"areaname\"}','{\"key\":[\"linkid\", \"terminal\"], \"statusid\":\"ok\"}','10669501','2015-03-20 08:01:56');
/*!40000 ALTER TABLE `sp_service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_sink`
--

DROP TABLE IF EXISTS `sp_sink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_sink` (
  `sinkid` int(11) NOT NULL AUTO_INCREMENT,
  `bnum` int(11) NOT NULL DEFAULT '100',
  `slice` int(11) NOT NULL DEFAULT '0',
  `consignid` int(11) DEFAULT NULL,
  `serviceid` int(11) DEFAULT NULL,
  `provincename` varchar(180) NOT NULL DEFAULT '',
  `response` varchar(500) NOT NULL DEFAULT '' COMMENT '{"response":["101", "102", "103"]}',
  `tconsignid` int(11) DEFAULT NULL,
  PRIMARY KEY (`sinkid`),
  KEY `fk_sink_consignid` (`consignid`),
  KEY `fk_sink_serviceid` (`serviceid`),
  CONSTRAINT `fk_sink_consignid` FOREIGN KEY (`consignid`) REFERENCES `sp_consign` (`consignid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sink_serviceid` FOREIGN KEY (`serviceid`) REFERENCES `sp_service` (`serviceid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_sink`
--

LOCK TABLES `sp_sink` WRITE;
/*!40000 ALTER TABLE `sp_sink` DISABLE KEYS */;
INSERT INTO `sp_sink` VALUES (1,5,1,1,1,'hebeisheng','{\"response\":[\"101\", \"102\", \"103\"]}',2),(2,5,1,1,1,'','{\"response\":[\"101\", \"102\", \"103\"]}',2);
/*!40000 ALTER TABLE `sp_sink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_sink_stat`
--

DROP TABLE IF EXISTS `sp_sink_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_sink_stat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `spnum` varchar(100) NOT NULL DEFAULT '',
  `spname` varchar(100) NOT NULL DEFAULT '',
  `consignid` int(11) DEFAULT NULL,
  `consignname` varchar(180) NOT NULL DEFAULT '',
  `serviceid` int(11) DEFAULT NULL,
  `servicename` varchar(180) NOT NULL DEFAULT '',
  `provinceid` varchar(30) NOT NULL DEFAULT '',
  `provincename` varchar(30) NOT NULL DEFAULT '',
  `monums` int(11) NOT NULL DEFAULT '0',
  `mousers` int(11) NOT NULL DEFAULT '0',
  `mtnums` int(11) NOT NULL DEFAULT '0',
  `mtusers` int(11) NOT NULL DEFAULT '0',
  `fee` int(11) NOT NULL DEFAULT '0',
  `day` varchar(30) NOT NULL DEFAULT '' COMMENT 'format/20150303',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_day_spnum_consignid_serviceid_provinceid` (`day`,`spnum`,`consignid`,`serviceid`,`provinceid`),
  KEY `day_spname_consign` (`day`,`spnum`,`consignid`),
  KEY `day_spname_servicename` (`day`,`spnum`,`serviceid`),
  KEY `day_spname_provincename` (`day`,`spnum`,`provinceid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_sink_stat`
--

LOCK TABLES `sp_sink_stat` WRITE;
/*!40000 ALTER TABLE `sp_sink_stat` DISABLE KEYS */;
INSERT INTO `sp_sink_stat` VALUES (1,'10669501','九五在线',1,'三星国际',1,'rich','0311','hebeisheng',0,0,2,0,200,'2015-03-23','2015-04-03 08:58:54');
/*!40000 ALTER TABLE `sp_sink_stat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_user`
--

DROP TABLE IF EXISTS `sp_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sp_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `roleid` int(11) NOT NULL DEFAULT '0',
  `accessid` int(11) NOT NULL DEFAULT '0',
  `logtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_user`
--

LOCK TABLES `sp_user` WRITE;
/*!40000 ALTER TABLE `sp_user` DISABLE KEYS */;
INSERT INTO `sp_user` VALUES (1,'root','admin',2,1,'2015-04-02 05:49:46'),(2,'kefu','kefu',16,1,'2015-04-03 12:43:07'),(3,'qudao','qudao',8,1,'2015-04-03 12:47:34'),(4,'coco','coco',4,2,'2015-04-03 13:00:58'),(5,'qudao1','qudao1',8,3,'2015-04-03 13:03:51');
/*!40000 ALTER TABLE `sp_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-04-07 17:30:00
