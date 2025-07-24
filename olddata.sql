-- MySQL dump 10.13  Distrib 8.0.42, for macos15 (x86_64)
--
-- Host: localhost    Database: user_management
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `username` varchar(50) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `account_id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(255) NOT NULL,
  `balance` decimal(15,2) DEFAULT '0.00',
  `account_type` enum('Checking','Savings') NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `phone` varchar(20) NOT NULL,
  `account_number` varchar(255) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES ('Rawaz.muhsin','Rawaz@example.com',10,'Rawaz2004',4900.00,'Checking','2025-04-18 11:10:15','07504527553',NULL,'user_images/10_profile.png','0AL5M8yJ04qHiwPTNaVYrQ=='),('azhy.a','azhy@example.com',11,'azhy123',0.00,'Checking','2025-04-18 13:15:56','047544496',NULL,NULL,NULL),('baxan.hamid','baxan@example.com',13,'sL/nEBkFmngWm1CEctjUEy02mFTG/eoREh95mFNybIg=',1470.00,'Checking','2025-04-21 10:47:31','0750664666',NULL,NULL,'gDYWc/x0gICV6iywl9eJQQ=='),('diarnzar','diar@example.com',15,'diar123',500.00,'Checking','2025-05-07 10:16:32','07868484363',NULL,NULL,NULL),('makwan_baban','makwan@example.com',18,'DuRdzpZ1HTU2AavGokybZQ==:F88vi77t9RGs0eLFZEkmwZ5Xvb+KhwQhZXAlkk6n75E=',250.00,'Checking','2025-06-02 00:32:37','2e829829832',NULL,NULL,NULL),('lisa','lisa@gmail.com',19,'srpunkC/9HEFZuRTYLB9DQ==:9XTw/HGSXd7+KfV08IwUGj+RqYeVmMAxG6tgh+pns/0=',650.00,'Checking','2025-06-13 01:42:48','28782782743',NULL,NULL,NULL);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'manager',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'Rawaz.muhsin','rawaz@muhsin.com','rawaz123','Rawaz','Muhsinn','manager','2025-04-22 15:32:06','2025-06-27 13:29:21',1,'STHlzbfLFIVrR5js6nR9pw==');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cards` (
  `card_id` int NOT NULL AUTO_INCREMENT,
  `account_id` int DEFAULT NULL,
  `card_number` varchar(16) NOT NULL,
  `card_type` enum('DEBIT','CREDIT','PREPAID') NOT NULL,
  `card_usage_type` enum('PHYSICAL','ONLINE','PHONE','INTERNET') NOT NULL,
  `card_holder_name` varchar(100) NOT NULL,
  `expiry_date` date NOT NULL,
  `cvv` varchar(3) NOT NULL,
  `pin_code` varchar(255) NOT NULL,
  `pin_attempts` int DEFAULT '0',
  `card_status` enum('ACTIVE','BLOCKED','EXPIRED') DEFAULT 'ACTIVE',
  `daily_limit` decimal(12,2) DEFAULT '1000.00',
  `card_balance` decimal(12,2) DEFAULT '0.00',
  `card_name` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`card_id`),
  UNIQUE KEY `card_number` (`card_number`),
  KEY `cards_account_fk` (`account_id`),
  CONSTRAINT `cards_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cards`
--

LOCK TABLES `cards` WRITE;
/*!40000 ALTER TABLE `cards` DISABLE KEYS */;
INSERT INTO `cards` VALUES (5,10,'2812883119042940','PREPAID','ONLINE','Rawaz.muhsin','2026-05-08','962','3538229660',0,'ACTIVE',10.00,10.00,'iTunes','2025-05-08 11:51:54','2025-05-08 11:51:54'),(6,10,'9105698486568088','PREPAID','INTERNET','Rawaz.muhsin','2026-05-08','712','4165792987',0,'ACTIVE',20.00,20.00,'Fastlink','2025-05-08 11:52:17','2025-05-08 11:52:17'),(7,10,'8956181270137642','PREPAID','ONLINE','Rawaz.muhsin','2026-05-08','300','2632757964',0,'ACTIVE',10.00,10.00,'iTunes','2025-05-08 12:00:18','2025-05-08 12:00:18'),(8,10,'2919395180286870','PREPAID','PHONE','Rawaz.muhsin','2026-05-08','158','4564004704',0,'ACTIVE',5.00,5.00,'Korek','2025-05-08 12:03:56','2025-05-08 12:03:56'),(9,13,'9421948382493752','PREPAID','PHONE','baxan.hamid','2026-05-08','031','1834929795',0,'ACTIVE',15.00,15.00,'Zain','2025-05-08 15:01:34','2025-05-08 15:01:34'),(10,19,'1892256053581655','PREPAID','ONLINE','lisa','2026-06-13','628','1189151905',0,'ACTIVE',50.00,50.00,'PlayStation','2025-06-12 22:44:00','2025-06-12 22:44:00'),(11,10,'3798688761063939','PREPAID','INTERNET','Rawaz.muhsin','2026-06-27','975','4943487997',0,'ACTIVE',30.00,30.00,'Newroz','2025-06-27 13:25:43','2025-06-27 13:25:43');
/*!40000 ALTER TABLE `cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `transaction_type` enum('deposit','withdrawal','transfer','purchase') DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `description` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `approval_date` datetime DEFAULT NULL,
  `account_number` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (3,10,'transfer',100.00,'2025-04-19 20:02:28','Transfer to account ID 11','APPROVED','2025-04-19 20:10:30',NULL,NULL),(4,10,'transfer',100.00,'2025-04-19 20:06:23','Transfer to account ID 11','APPROVED','2025-04-19 20:09:12',NULL,NULL),(5,10,'transfer',500.00,'2025-04-19 20:10:06','Transfer to account ID 11','APPROVED','2025-04-19 20:10:27',NULL,NULL),(6,10,'transfer',250.00,'2025-04-19 20:25:52','Transfer to account ID 11','APPROVED','2025-04-19 20:26:07',NULL,NULL),(7,10,'transfer',250.00,'2025-04-19 20:39:21','Transfer to account ID 12','APPROVED','2025-04-19 20:39:33',NULL,NULL),(8,10,'transfer',250.00,'2025-04-20 17:07:02','Transfer to account ID 11','APPROVED',NULL,NULL,NULL),(9,10,'deposit',500.00,'2025-04-20 17:20:26','yes','APPROVED','2025-04-20 17:20:39',NULL,NULL),(10,10,'deposit',100.00,'2025-04-20 17:34:55','yess','APPROVED','2025-04-20 17:35:15',NULL,NULL),(11,10,'withdrawal',100.00,'2025-04-20 17:42:47','yes','APPROVED','2025-04-20 17:43:00',NULL,NULL),(12,10,'transfer',250.00,'2025-04-20 22:02:58','Transfer to account ID 11','APPROVED','2025-04-20 22:03:35',NULL,NULL),(13,10,'deposit',100.00,'2025-04-21 10:49:21','yes','APPROVED','2025-04-21 10:49:58',NULL,NULL),(14,11,'transfer',-100.00,'2025-04-21 19:03:33','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(15,13,'transfer',100.00,'2025-04-21 19:03:33','Transfer from account ID 11','APPROVED',NULL,NULL,NULL),(16,10,'withdrawal',250.00,'2025-04-21 19:10:13','','APPROVED','2025-04-21 19:10:28',NULL,NULL),(19,10,'transfer',-250.00,'2025-04-23 15:30:03','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(20,13,'transfer',250.00,'2025-04-23 15:30:03','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(21,10,'deposit',500.00,'2025-04-23 15:30:18','w','APPROVED','2025-04-23 15:30:29',NULL,NULL),(22,10,'transfer',-250.00,'2025-04-23 20:38:28','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(23,13,'transfer',250.00,'2025-04-23 20:38:28','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(24,10,'transfer',-500.00,'2025-04-23 21:16:01','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(25,13,'transfer',500.00,'2025-04-23 21:16:01','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(26,10,'transfer',-500.00,'2025-04-23 22:12:52','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(27,13,'transfer',500.00,'2025-04-23 22:12:52','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(28,10,'deposit',500.00,'2025-04-23 22:14:45','fyf','APPROVED','2025-04-24 08:59:14',NULL,NULL),(29,10,'transfer',-250.00,'2025-04-24 09:46:56','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(30,13,'transfer',250.00,'2025-04-24 09:46:56','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(31,10,'transfer',-250.00,'2025-04-24 20:18:45','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(32,13,'transfer',250.00,'2025-04-24 20:18:45','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(33,10,'transfer',-250.00,'2025-04-24 20:19:05','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(34,13,'transfer',250.00,'2025-04-24 20:19:05','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(35,13,'transfer',-250.00,'2025-04-25 09:48:27','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(36,10,'transfer',250.00,'2025-04-25 09:48:27','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(37,13,'transfer',-1000.00,'2025-04-25 10:07:18','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(38,10,'transfer',1000.00,'2025-04-25 10:07:18','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(39,13,'transfer',-100.00,'2025-04-25 13:53:28','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(40,10,'transfer',100.00,'2025-04-25 13:53:28','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(41,13,'deposit',100.00,'2025-04-25 13:53:34','','APPROVED','2025-04-25 14:02:40',NULL,NULL),(42,13,'transfer',-100.00,'2025-04-25 14:45:24','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(43,10,'transfer',100.00,'2025-04-25 14:45:24','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(44,13,'deposit',500.00,'2025-04-25 14:45:53','','REJECTED','2025-04-25 14:47:07',NULL,NULL),(45,13,'deposit',100.00,'2025-04-25 19:06:14','yes','APPROVED','2025-04-25 19:10:50',NULL,NULL),(46,13,'transfer',-250.00,'2025-04-25 19:07:27','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(47,10,'transfer',250.00,'2025-04-25 19:07:27','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(48,10,'withdrawal',100.00,'2025-04-27 17:05:21','','APPROVED','2025-05-08 01:32:27',NULL,NULL),(49,10,'transfer',-500.00,'2025-04-27 17:58:07','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(50,13,'transfer',500.00,'2025-04-27 17:58:07','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(51,13,'transfer',-100.00,'2025-04-27 22:01:06','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(52,10,'transfer',100.00,'2025-04-27 22:01:06','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(53,15,'deposit',500.00,'2025-05-07 10:19:14','','APPROVED','2025-05-07 10:22:26',NULL,NULL),(54,10,'purchase',5.00,'2025-05-07 22:40:11','Purchase of Korek Card','APPROVED','2025-05-08 01:32:31',NULL,10),(55,10,'purchase',5.00,'2025-05-07 22:45:46','Purchase of Korek Card','APPROVED','2025-05-08 01:32:26',NULL,NULL),(56,10,'purchase',10.00,'2025-05-08 14:33:40','Purchase of iTunes Card','APPROVED','2025-05-08 18:08:13',NULL,NULL),(57,10,'purchase',10.00,'2025-05-08 14:40:25','Purchase of iTunes Card','APPROVED','2025-05-08 18:08:07',NULL,NULL),(58,10,'purchase',5.00,'2025-05-08 14:44:18','Purchase of Korek Card','APPROVED','2025-05-08 18:08:11',NULL,NULL),(59,10,'purchase',5.00,'2025-05-08 14:49:06','Purchase of Asiacell Card','APPROVED','2025-05-08 18:08:06',NULL,NULL),(60,10,'purchase',10.00,'2025-05-08 14:51:54','Purchase of iTunes Card','APPROVED','2025-05-08 18:08:15',NULL,NULL),(61,10,'purchase',20.00,'2025-05-08 14:52:17','Purchase of Fastlink Card','APPROVED','2025-05-08 18:08:05',NULL,NULL),(62,10,'purchase',10.00,'2025-05-08 15:00:18','Purchase of iTunes Card','APPROVED','2025-05-08 18:08:10',NULL,NULL),(63,10,'purchase',5.00,'2025-05-08 15:03:56','Purchase of Korek Card','APPROVED','2025-05-08 18:08:04',NULL,NULL),(64,13,'transfer',-250.00,'2025-05-08 18:01:05','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(65,10,'transfer',250.00,'2025-05-08 18:01:05','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(66,13,'purchase',15.00,'2025-05-08 18:01:34','Purchase of Zain Card','APPROVED','2025-05-08 18:08:01',NULL,NULL),(67,13,'withdrawal',100.00,'2025-05-14 12:19:34','','APPROVED','2025-05-14 12:19:59',NULL,NULL),(68,13,'deposit',500.00,'2025-05-14 12:21:12','','APPROVED','2025-05-14 12:21:37',NULL,NULL),(69,13,'transfer',-250.00,'2025-05-14 14:12:17','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(70,10,'transfer',250.00,'2025-05-14 14:12:17','Transfer from account ID 13','APPROVED',NULL,NULL,NULL),(71,10,'deposit',100.00,'2025-05-14 15:42:11','','APPROVED','2025-06-27 16:31:01',NULL,NULL),(72,10,'transfer',-250.00,'2025-05-14 15:42:41','Transfer to account ID 13','APPROVED',NULL,NULL,NULL),(73,13,'transfer',250.00,'2025-05-14 15:42:41','Transfer from account ID 10','APPROVED',NULL,NULL,NULL),(74,19,'deposit',500.00,'2025-06-13 01:43:09','','APPROVED','2025-06-13 01:43:30',NULL,NULL),(75,19,'purchase',50.00,'2025-06-13 01:44:00','Purchase of PlayStation Card','APPROVED','2025-06-27 16:30:55',NULL,NULL),(76,19,'deposit',500.00,'2025-06-13 01:44:47','','APPROVED','2025-06-27 16:30:58',NULL,NULL),(77,19,'transfer',-250.00,'2025-06-13 01:45:21','Transfer to account ID 10','APPROVED',NULL,NULL,NULL),(78,10,'transfer',250.00,'2025-06-13 01:45:21','Transfer from account ID 19','APPROVED',NULL,NULL,NULL),(79,10,'purchase',30.00,'2025-06-27 16:25:43','Purchase of Newroz Card','APPROVED','2025-06-27 16:30:54',NULL,NULL),(80,10,'transfer',-250.00,'2025-06-27 16:26:18','Transfer to account ID 18','APPROVED',NULL,NULL,NULL),(81,18,'transfer',250.00,'2025-06-27 16:26:18','Transfer from account ID 10','APPROVED',NULL,NULL,NULL);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transfers`
--

DROP TABLE IF EXISTS `transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transfers` (
  `transfer_id` int NOT NULL AUTO_INCREMENT,
  `from_account_id` int NOT NULL,
  `to_account_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transfer_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transfer_id`),
  KEY `from_account_id` (`from_account_id`),
  KEY `to_account_id` (`to_account_id`),
  CONSTRAINT `transfers_ibfk_1` FOREIGN KEY (`from_account_id`) REFERENCES `accounts` (`account_id`),
  CONSTRAINT `transfers_ibfk_2` FOREIGN KEY (`to_account_id`) REFERENCES `accounts` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transfers`
--

LOCK TABLES `transfers` WRITE;
/*!40000 ALTER TABLE `transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-24 16:26:25
