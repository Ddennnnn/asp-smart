-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: asp_smartDb
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_reconciliations`
--

DROP TABLE IF EXISTS `account_reconciliations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_reconciliations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `financial_account_id` bigint(20) unsigned NOT NULL,
  `system_balance` decimal(18,2) NOT NULL,
  `actual_balance` decimal(18,2) NOT NULL,
  `difference` decimal(18,2) NOT NULL,
  `status` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `reconciled_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `review_notes` text DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_reconciliations_branch_id_foreign` (`branch_id`),
  KEY `account_reconciliations_financial_account_id_foreign` (`financial_account_id`),
  KEY `account_reconciliations_reconciled_by_foreign` (`reconciled_by`),
  KEY `account_reconciliations_approved_by_foreign` (`approved_by`),
  CONSTRAINT `account_reconciliations_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `account_reconciliations_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `account_reconciliations_financial_account_id_foreign` FOREIGN KEY (`financial_account_id`) REFERENCES `financial_accounts` (`id`),
  CONSTRAINT `account_reconciliations_reconciled_by_foreign` FOREIGN KEY (`reconciled_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_reconciliations`
--

LOCK TABLES `account_reconciliations` WRITE;
/*!40000 ALTER TABLE `account_reconciliations` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_reconciliations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_transactions`
--

DROP TABLE IF EXISTS `account_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `financial_account_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned DEFAULT NULL,
  `transaction_type` varchar(255) NOT NULL,
  `reference_number` varchar(255) NOT NULL,
  `direction` varchar(3) NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `balance_before` decimal(18,2) NOT NULL,
  `balance_after` decimal(18,2) NOT NULL,
  `description` text NOT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_transactions_branch_id_foreign` (`branch_id`),
  KEY `account_transactions_transaction_id_foreign` (`transaction_id`),
  KEY `account_transactions_created_by_foreign` (`created_by`),
  KEY `account_transactions_financial_account_id_created_at_index` (`financial_account_id`,`created_at`),
  CONSTRAINT `account_transactions_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `account_transactions_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `account_transactions_financial_account_id_foreign` FOREIGN KEY (`financial_account_id`) REFERENCES `financial_accounts` (`id`),
  CONSTRAINT `account_transactions_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_transactions`
--

LOCK TABLES `account_transactions` WRITE;
/*!40000 ALTER TABLE `account_transactions` DISABLE KEYS */;
INSERT INTO `account_transactions` VALUES (1,2,2,NULL,'opening','OPEN/CASH','in',5000000.00,0.00,5000000.00,'Saldo awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,2,3,NULL,'opening','OPEN/BCA','in',8000000.00,0.00,8000000.00,'Saldo awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,2,4,NULL,'opening','OPEN/BRI','in',3000000.00,0.00,3000000.00,'Saldo awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,2,5,NULL,'opening','OPEN/DIGI','in',2000000.00,0.00,2000000.00,'Saldo awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(5,2,2,7,'sale','TRX/CB01/202609/000001','in',25000.00,5000000.00,5025000.00,'TRX/CB01/202609/000001',6,'2026-09-18 04:08:02','2026-09-18 04:08:02'),(6,2,2,8,'cash_withdrawal','CASHOUT/CB01/202609/000001','out',100000.00,5025000.00,4925000.00,'CASHOUT/CB01/202609/000001',6,'2026-09-18 04:10:30','2026-09-18 04:10:30'),(7,2,4,8,'cash_withdrawal','CASHOUT/CB01/202609/000001','in',100000.00,3000000.00,3100000.00,'CASHOUT/CB01/202609/000001',6,'2026-09-18 04:10:30','2026-09-18 04:10:30'),(8,2,4,8,'cash_withdrawal','CASHOUT/CB01/202609/000001','in',10000.00,3100000.00,3110000.00,'CASHOUT/CB01/202609/000001',6,'2026-09-18 04:10:30','2026-09-18 04:10:30'),(9,2,2,9,'sale','TRX/CB01/202609/000002','in',25000.00,4925000.00,4950000.00,'TRX/CB01/202609/000002',4,'2026-09-18 08:07:21','2026-09-18 08:07:21'),(10,2,2,10,'reversal','REVERSAL/CB01/202609/000001','out',25000.00,4950000.00,4925000.00,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:07:24','2026-09-18 08:07:24'),(11,2,2,11,'sale','TRX/CB01/202609/000003','in',25000.00,4925000.00,4950000.00,'TRX/CB01/202609/000003',4,'2026-09-18 08:35:35','2026-09-18 08:35:35'),(12,2,2,12,'reversal','REVERSAL/CB01/202609/000002','out',25000.00,4950000.00,4925000.00,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:35:38','2026-09-18 08:35:38'),(13,2,2,13,'sale','TRX/CB01/202609/000004','in',25000.00,4925000.00,4950000.00,'TRX/CB01/202609/000004',4,'2026-09-18 08:44:30','2026-09-18 08:44:30'),(14,2,2,14,'reversal','REVERSAL/CB01/202609/000003','out',25000.00,4950000.00,4925000.00,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:44:34','2026-09-18 08:44:34'),(15,3,9,NULL,'opening','OPEN/171222','in',1000000.00,0.00,1000000.00,'Saldo awal',4,'2026-09-18 09:01:44','2026-09-18 09:01:44'),(16,3,10,NULL,'opening','OPEN/KasCB002','in',150000.00,0.00,150000.00,'Saldo awal',4,'2026-09-18 09:04:26','2026-09-18 09:04:26'),(17,3,10,18,'sale','TRX/CB02/202609/000001','in',110000.00,150000.00,260000.00,'TRX/CB02/202609/000001',7,'2026-09-18 09:04:58','2026-09-18 09:04:58'),(18,3,10,19,'cash_withdrawal','CASHOUT/CB02/202609/000001','out',100000.00,260000.00,160000.00,'CASHOUT/CB02/202609/000001',7,'2026-09-18 09:08:08','2026-09-18 09:08:08'),(19,3,9,19,'cash_withdrawal','CASHOUT/CB02/202609/000001','in',100000.00,1000000.00,1100000.00,'CASHOUT/CB02/202609/000001',7,'2026-09-18 09:08:08','2026-09-18 09:08:08'),(20,3,9,19,'cash_withdrawal','CASHOUT/CB02/202609/000001','in',10000.00,1100000.00,1110000.00,'CASHOUT/CB02/202609/000001',7,'2026-09-18 09:08:08','2026-09-18 09:08:08'),(21,3,9,20,'money_transfer','TRANSFER/CB02/202609/000001','out',100000.00,1110000.00,1010000.00,'TRANSFER/CB02/202609/000001',7,'2026-09-18 09:10:03','2026-09-18 09:10:03'),(22,3,10,20,'money_transfer','TRANSFER/CB02/202609/000001','in',100000.00,160000.00,260000.00,'TRANSFER/CB02/202609/000001',7,'2026-09-18 09:10:03','2026-09-18 09:10:03');
/*!40000 ALTER TABLE `account_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `approvals`
--

DROP TABLE IF EXISTS `approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `approvals` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `requested_by` bigint(20) unsigned NOT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `approvals_transaction_id_unique` (`transaction_id`),
  KEY `approvals_branch_id_foreign` (`branch_id`),
  KEY `approvals_requested_by_foreign` (`requested_by`),
  KEY `approvals_approved_by_foreign` (`approved_by`),
  CONSTRAINT `approvals_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `approvals_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `approvals_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `approvals_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `approvals`
--

LOCK TABLES `approvals` WRITE;
/*!40000 ALTER TABLE `approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `module` varchar(255) NOT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `audit_logs_user_id_foreign` (`user_id`),
  KEY `audit_logs_branch_id_foreign` (`branch_id`),
  CONSTRAINT `audit_logs_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `audit_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,NULL,2,'POST','stock_adjustment','1','[]','{\"amount\":\"0.00\",\"reference\":\"STOCK_ADJUSTMENT\\/2\\/202609\\/01M2S892JR1VY26PNAV4J1QQCM\"}','127.0.0.1','Symfony','2026-09-18 03:17:05'),(2,NULL,2,'POST','stock_adjustment','2','[]','{\"amount\":\"0.00\",\"reference\":\"STOCK_ADJUSTMENT\\/2\\/202609\\/01M2S892M6E58PWY8KXPYJ1NST\"}','127.0.0.1','Symfony','2026-09-18 03:17:05'),(3,NULL,2,'POST','stock_adjustment','3','[]','{\"amount\":\"0.00\",\"reference\":\"STOCK_ADJUSTMENT\\/2\\/202609\\/01M2S892MX0BWX2ZVTM3TX82K1\"}','127.0.0.1','Symfony','2026-09-18 03:17:05'),(4,4,2,'SHIFT_OPEN','cashier_sessions','1','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 03:50:38'),(5,4,2,'SHIFT_CLOSE','cashier_sessions','1','[]','{\"difference\":\"0.00\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 04:07:11'),(6,6,2,'SHIFT_OPEN','cashier_sessions','2','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 04:07:49'),(7,6,2,'POST','sale','7','[]','{\"amount\":\"25000.00\",\"reference\":\"TRX\\/CB01\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 04:08:02'),(8,6,2,'POST','cash_withdrawal','8','[]','{\"amount\":\"100000.00\",\"reference\":\"CASHOUT\\/CB01\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 04:10:30'),(9,6,2,'SHIFT_CLOSE','cashier_sessions','2','[]','{\"difference\":\"0.00\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 04:12:20'),(10,4,2,'SHIFT_OPEN','cashier_sessions','3','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:07:16'),(11,4,2,'POST','sale','9','[]','{\"amount\":\"25000.00\",\"reference\":\"TRX\\/CB01\\/202609\\/000002\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:07:21'),(12,4,2,'POST','reversal','10','[]','{\"amount\":\"25000.00\",\"reference\":\"REVERSAL\\/CB01\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:07:24'),(13,4,2,'CREATE','financial-accounts','6','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false}','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false,\"branch_id\":2,\"code\":\"QA1789718850985\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"updated_at\":\"2026-09-18T08:07:31.000000Z\",\"created_at\":\"2026-09-18T08:07:31.000000Z\",\"id\":6}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:07:31'),(14,4,2,'UPDATE','financial-accounts','6','{\"id\":6,\"branch_id\":2,\"code\":\"QA1789718850985\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":true,\"created_at\":\"2026-09-18T08:07:31.000000Z\",\"updated_at\":\"2026-09-18T08:07:31.000000Z\"}','{\"id\":6,\"branch_id\":2,\"code\":\"QA1789718850985\",\"name\":\"QA rekening terverifikasi\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":false,\"created_at\":\"2026-09-18T08:07:31.000000Z\",\"updated_at\":\"2026-09-18T08:07:34.000000Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:07:34'),(15,4,2,'POST','sale','11','[]','{\"amount\":\"25000.00\",\"reference\":\"TRX\\/CB01\\/202609\\/000003\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:35:35'),(16,4,2,'POST','reversal','12','[]','{\"amount\":\"25000.00\",\"reference\":\"REVERSAL\\/CB01\\/202609\\/000002\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:35:38'),(17,4,2,'CREATE','financial-accounts','7','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false}','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false,\"branch_id\":2,\"code\":\"QA1789720544579\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"updated_at\":\"2026-09-18T08:35:45.000000Z\",\"created_at\":\"2026-09-18T08:35:45.000000Z\",\"id\":7}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:35:45'),(18,4,2,'ACCOUNT_REVEAL','financial_accounts','7','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:35:48'),(19,4,2,'UPDATE','financial-accounts','7','{\"id\":7,\"branch_id\":2,\"code\":\"QA1789720544579\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":true,\"created_at\":\"2026-09-18T08:35:45.000000Z\",\"updated_at\":\"2026-09-18T08:35:45.000000Z\"}','{\"id\":7,\"branch_id\":2,\"code\":\"QA1789720544579\",\"name\":\"QA rekening terverifikasi\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":false,\"created_at\":\"2026-09-18T08:35:45.000000Z\",\"updated_at\":\"2026-09-18T08:35:49.000000Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:35:49'),(20,4,2,'POST','sale','13','[]','{\"amount\":\"25000.00\",\"reference\":\"TRX\\/CB01\\/202609\\/000004\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:44:30'),(21,4,2,'POST','reversal','14','[]','{\"amount\":\"25000.00\",\"reference\":\"REVERSAL\\/CB01\\/202609\\/000003\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:44:34'),(22,4,2,'CREATE','financial-accounts','8','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false}','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false,\"branch_id\":2,\"code\":\"QA1789721081982\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"updated_at\":\"2026-09-18T08:44:43.000000Z\",\"created_at\":\"2026-09-18T08:44:43.000000Z\",\"id\":8}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:44:43'),(23,4,2,'ACCOUNT_REVEAL','financial_accounts','8','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:44:45'),(24,4,2,'UPDATE','financial-accounts','8','{\"id\":8,\"branch_id\":2,\"code\":\"QA1789721081982\",\"name\":\"QA rekening kosong\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":true,\"created_at\":\"2026-09-18T08:44:43.000000Z\",\"updated_at\":\"2026-09-18T08:44:43.000000Z\"}','{\"id\":8,\"branch_id\":2,\"code\":\"QA1789721081982\",\"name\":\"QA rekening terverifikasi\",\"account_type\":\"bank\",\"bank_name\":null,\"account_holder\":null,\"opening_balance\":\"0.00\",\"current_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_central\":false,\"is_active\":false,\"created_at\":\"2026-09-18T08:44:43.000000Z\",\"updated_at\":\"2026-09-18T08:44:46.000000Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','2026-09-18 08:44:46'),(25,4,NULL,'CREATE','branches','3','[]','{\"code\":\"CB02\",\"name\":\"Cabang Ilham\",\"address\":\"rumah ilham\",\"phone\":\"081234567890\",\"whatsapp\":\"081234567890\",\"city\":\"Sebapo\",\"is_main\":false,\"is_active\":true,\"updated_at\":\"2026-09-18T08:56:28.000000Z\",\"created_at\":\"2026-09-18T08:56:28.000000Z\",\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 08:56:28'),(26,4,NULL,'USER_SAVE','users','7','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 08:57:02'),(27,4,3,'POST','stock_adjustment','16','[]','{\"amount\":\"0.00\",\"reference\":\"STOCK\\/CB02\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 08:59:23'),(28,4,3,'CREATE','financial-accounts','9','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false}','{\"current_balance\":\"1000000.00\",\"opening_balance\":\"1000000.00\",\"minimum_balance\":\"100000.00\",\"is_active\":true,\"is_central\":false,\"branch_id\":3,\"code\":\"171222\",\"name\":\"Ilham Rekening\",\"account_type\":\"bank\",\"bank_name\":\"Bank Ilham\",\"account_holder\":\"Fahrozi\",\"updated_at\":\"2026-09-18T09:01:44.000000Z\",\"created_at\":\"2026-09-18T09:01:44.000000Z\",\"id\":9}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:01:44'),(29,4,3,'ACCOUNT_REVEAL','financial_accounts','9','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:01:56'),(30,4,2,'ACCOUNT_REVEAL','financial_accounts','8','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:02:00'),(31,4,2,'ACCOUNT_REVEAL','financial_accounts','8','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:02:07'),(32,4,2,'ACCOUNT_REVEAL','financial_accounts','5','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:02:13'),(33,4,3,'CREATE','financial-accounts','10','{\"current_balance\":\"0.00\",\"opening_balance\":\"0.00\",\"minimum_balance\":\"0.00\",\"is_active\":true,\"is_central\":false}','{\"current_balance\":\"150000.00\",\"opening_balance\":\"150000.00\",\"minimum_balance\":\"50000.00\",\"is_active\":true,\"is_central\":false,\"branch_id\":3,\"code\":\"KasCB002\",\"name\":\"Kas\",\"account_type\":\"cash\",\"bank_name\":null,\"account_holder\":null,\"updated_at\":\"2026-09-18T09:04:26.000000Z\",\"created_at\":\"2026-09-18T09:04:26.000000Z\",\"id\":10}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:04:26'),(34,7,3,'SHIFT_OPEN','cashier_sessions','4','[]','[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 09:04:37'),(35,7,3,'POST','sale','18','[]','{\"amount\":\"110000.00\",\"reference\":\"TRX\\/CB02\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 09:04:58'),(36,4,3,'CREATE','transaction-fee-rules','1','[]','{\"name\":\"Admin Tarik tunai\",\"branch_id\":3,\"type\":\"cash_withdrawal\",\"minimum_amount\":\"10000\",\"maximum_amount\":\"1000000\",\"fee_type\":\"percentage\",\"fee_value\":\"10\",\"is_active\":true,\"updated_at\":\"2026-09-18T09:06:51.000000Z\",\"created_at\":\"2026-09-18T09:06:51.000000Z\",\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','2026-09-18 09:06:51'),(37,7,3,'POST','cash_withdrawal','19','[]','{\"amount\":\"100000.00\",\"reference\":\"CASHOUT\\/CB02\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 09:08:08'),(38,7,3,'POST','money_transfer','20','[]','{\"amount\":\"100000.00\",\"reference\":\"TRANSFER\\/CB02\\/202609\\/000001\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 09:10:03'),(39,7,3,'SHIFT_CLOSE','cashier_sessions','4','[]','{\"difference\":\"0.00\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 09:11:16');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_daily_closings`
--

DROP TABLE IF EXISTS `branch_daily_closings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_daily_closings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `date` date NOT NULL,
  `summary` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`summary`)),
  `closed_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branch_daily_closings_branch_id_date_unique` (`branch_id`,`date`),
  KEY `branch_daily_closings_closed_by_foreign` (`closed_by`),
  CONSTRAINT `branch_daily_closings_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `branch_daily_closings_closed_by_foreign` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_daily_closings`
--

LOCK TABLES `branch_daily_closings` WRITE;
/*!40000 ALTER TABLE `branch_daily_closings` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_daily_closings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_group_prices`
--

DROP TABLE IF EXISTS `branch_group_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_group_prices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `customer_group_id` bigint(20) unsigned NOT NULL,
  `digital_product_id` bigint(20) unsigned NOT NULL,
  `selling_price` decimal(18,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branch_group_product_unique` (`branch_id`,`customer_group_id`,`digital_product_id`),
  KEY `branch_group_prices_customer_group_id_foreign` (`customer_group_id`),
  KEY `branch_group_prices_digital_product_id_foreign` (`digital_product_id`),
  CONSTRAINT `branch_group_prices_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `branch_group_prices_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`),
  CONSTRAINT `branch_group_prices_digital_product_id_foreign` FOREIGN KEY (`digital_product_id`) REFERENCES `digital_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_group_prices`
--

LOCK TABLES `branch_group_prices` WRITE;
/*!40000 ALTER TABLE `branch_group_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_group_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_product_prices`
--

DROP TABLE IF EXISTS `branch_product_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_product_prices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `digital_product_id` bigint(20) unsigned NOT NULL,
  `selling_price` decimal(18,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branch_product_prices_branch_id_digital_product_id_unique` (`branch_id`,`digital_product_id`),
  KEY `branch_product_prices_digital_product_id_foreign` (`digital_product_id`),
  CONSTRAINT `branch_product_prices_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `branch_product_prices_digital_product_id_foreign` FOREIGN KEY (`digital_product_id`) REFERENCES `digital_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_product_prices`
--

LOCK TABLES `branch_product_prices` WRITE;
/*!40000 ALTER TABLE `branch_product_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_product_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_stocks`
--

DROP TABLE IF EXISTS `branch_stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_stocks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branch_stocks_branch_id_product_id_unique` (`branch_id`,`product_id`),
  KEY `branch_stocks_product_id_foreign` (`product_id`),
  CONSTRAINT `branch_stocks_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `branch_stocks_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_stocks`
--

LOCK TABLES `branch_stocks` WRITE;
/*!40000 ALTER TABLE `branch_stocks` DISABLE KEYS */;
INSERT INTO `branch_stocks` VALUES (1,2,1,19,'2026-09-18 03:17:05','2026-09-18 08:44:34'),(2,2,2,20,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,2,3,20,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(11,3,3,8,'2026-09-18 08:59:23','2026-09-18 09:04:58');
/*!40000 ALTER TABLE `branch_stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0,
  `phone` varchar(255) DEFAULT NULL,
  `whatsapp` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `province` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branches_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (2,'CB01','Cabang Utama',1,NULL,NULL,NULL,'Alamat counter belum diatur','Jambi',NULL,NULL,NULL,NULL,1,'2026-09-18 03:17:04','2026-09-18 03:17:04',NULL),(3,'CB02','Cabang Ilham',0,'081234567890','081234567890',NULL,'rumah ilham','Sebapo',NULL,NULL,NULL,NULL,1,'2026-09-18 08:56:28','2026-09-18 08:56:28',NULL);
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brands` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `brands_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
INSERT INTO `brands` VALUES (1,'Universal',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-229158b92c20cb8362e5972c3684fb6f','i:1;',1789704459),('laravel-cache-229158b92c20cb8362e5972c3684fb6f:timer','i:1789704459;',1789704459),('laravel-cache-3adb9ab0502db4563a27459f2b82e26a','i:2;',1789721903),('laravel-cache-3adb9ab0502db4563a27459f2b82e26a:timer','i:1789721903;',1789721903),('laravel-cache-89fbfa7c449e3a132352d1c1b34e8944','i:1;',1789721586),('laravel-cache-89fbfa7c449e3a132352d1c1b34e8944:timer','i:1789721586;',1789721586),('laravel-cache-a3affa0d1e1a3c72b78aa984c3367a05','i:3;',1789723969),('laravel-cache-a3affa0d1e1a3c72b78aa984c3367a05:timer','i:1789723969;',1789723969),('laravel-cache-b37e2b0b86a8368405df02e0b66d0b39','i:3;',1789723967),('laravel-cache-b37e2b0b86a8368405df02e0b66d0b39:timer','i:1789723967;',1789723967),('laravel-cache-df21bfa12c4e294c70f64916c0fbc9a5','i:8;',1789704460),('laravel-cache-df21bfa12c4e294c70f64916c0fbc9a5:timer','i:1789704460;',1789704460),('laravel-cache-e7cf66797159dc3cd3e85f72e15bb551','i:4;',1789722368),('laravel-cache-e7cf66797159dc3cd3e85f72e15bb551:timer','i:1789722368;',1789722368),('laravel-cache-fe8b05e22206757605b605e6b20af043','i:1;',1789721192),('laravel-cache-fe8b05e22206757605b605e6b20af043:timer','i:1789721192;',1789721192);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashier_sessions`
--

DROP TABLE IF EXISTS `cashier_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashier_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `financial_account_id` bigint(20) unsigned NOT NULL,
  `opening_cash` decimal(18,2) DEFAULT NULL,
  `expected_cash` decimal(18,2) DEFAULT NULL,
  `actual_cash` decimal(18,2) DEFAULT NULL,
  `difference` decimal(18,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cashier_sessions_branch_id_foreign` (`branch_id`),
  KEY `cashier_sessions_user_id_foreign` (`user_id`),
  KEY `cashier_sessions_financial_account_id_foreign` (`financial_account_id`),
  CONSTRAINT `cashier_sessions_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `cashier_sessions_financial_account_id_foreign` FOREIGN KEY (`financial_account_id`) REFERENCES `financial_accounts` (`id`),
  CONSTRAINT `cashier_sessions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashier_sessions`
--

LOCK TABLES `cashier_sessions` WRITE;
/*!40000 ALTER TABLE `cashier_sessions` DISABLE KEYS */;
INSERT INTO `cashier_sessions` VALUES (1,2,4,2,5000000.00,5000000.00,5000000.00,0.00,NULL,'2026-09-18 04:07:11','2026-09-18 03:50:38','2026-09-18 04:07:11'),(2,2,6,2,5000000.00,4925000.00,4925000.00,0.00,NULL,'2026-09-18 04:12:20','2026-09-18 04:07:49','2026-09-18 04:12:20'),(3,2,4,2,4925000.00,NULL,NULL,NULL,NULL,NULL,'2026-09-18 08:07:16','2026-09-18 08:07:16'),(4,3,7,10,150000.00,260000.00,260000.00,0.00,NULL,'2026-09-18 09:11:16','2026-09-18 09:04:37','2026-09-18 09:11:16');
/*!40000 ALTER TABLE `cashier_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_group_prices`
--

DROP TABLE IF EXISTS `customer_group_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_group_prices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_group_id` bigint(20) unsigned NOT NULL,
  `digital_product_id` bigint(20) unsigned NOT NULL,
  `selling_price` decimal(18,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_group_product_unique` (`customer_group_id`,`digital_product_id`),
  KEY `customer_group_prices_digital_product_id_foreign` (`digital_product_id`),
  CONSTRAINT `customer_group_prices_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`),
  CONSTRAINT `customer_group_prices_digital_product_id_foreign` FOREIGN KEY (`digital_product_id`) REFERENCES `digital_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_group_prices`
--

LOCK TABLES `customer_group_prices` WRITE;
/*!40000 ALTER TABLE `customer_group_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_group_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_groups`
--

DROP TABLE IF EXISTS `customer_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_groups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_groups_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_groups`
--

LOCK TABLES `customer_groups` WRITE;
/*!40000 ALTER TABLE `customer_groups` DISABLE KEYS */;
INSERT INTO `customer_groups` VALUES (1,'Retail',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,'Reseller',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,'Agent',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,'VIP',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `customer_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_wallets`
--

DROP TABLE IF EXISTS `customer_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_wallets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `financial_account_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_wallets_customer_id_branch_id_unique` (`customer_id`,`branch_id`),
  UNIQUE KEY `customer_wallets_financial_account_id_unique` (`financial_account_id`),
  KEY `customer_wallets_branch_id_foreign` (`branch_id`),
  CONSTRAINT `customer_wallets_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `customer_wallets_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `customer_wallets_financial_account_id_foreign` FOREIGN KEY (`financial_account_id`) REFERENCES `financial_accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_wallets`
--

LOCK TABLES `customer_wallets` WRITE;
/*!40000 ALTER TABLE `customer_wallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `whatsapp` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `customer_group_id` bigint(20) unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customers_code_unique` (`code`),
  KEY `customers_customer_group_id_foreign` (`customer_group_id`),
  CONSTRAINT `customers_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_products`
--

DROP TABLE IF EXISTS `digital_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digital_products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `provider_id` bigint(20) unsigned NOT NULL,
  `operator_id` bigint(20) unsigned NOT NULL,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `nominal` decimal(18,2) NOT NULL DEFAULT 0.00,
  `cost_price` decimal(18,2) NOT NULL DEFAULT 0.00,
  `selling_price` decimal(18,2) NOT NULL DEFAULT 0.00,
  `admin_fee` decimal(18,2) NOT NULL DEFAULT 0.00,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `digital_products_code_unique` (`code`),
  KEY `digital_products_provider_id_foreign` (`provider_id`),
  KEY `digital_products_operator_id_foreign` (`operator_id`),
  CONSTRAINT `digital_products_operator_id_foreign` FOREIGN KEY (`operator_id`) REFERENCES `operators` (`id`),
  CONSTRAINT `digital_products_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_products`
--

LOCK TABLES `digital_products` WRITE;
/*!40000 ALTER TABLE `digital_products` DISABLE KEYS */;
INSERT INTO `digital_products` VALUES (1,1,1,'TSEL10','Telkomsel 10K','pulsa',10000.00,10500.00,12000.00,0.00,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,1,1,'TSEL50','Telkomsel 50K','pulsa',50000.00,48500.00,52000.00,0.00,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,1,1,'DATA','Internet Package Demo','data',25000.00,22000.00,27000.00,0.00,1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `digital_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_categories`
--

DROP TABLE IF EXISTS `expense_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `expense_categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_categories`
--

LOCK TABLES `expense_categories` WRITE;
/*!40000 ALTER TABLE `expense_categories` DISABLE KEYS */;
INSERT INTO `expense_categories` VALUES (1,'Listrik',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,'Internet',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,'Sewa',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,'Gaji',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(5,'Transport',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(6,'Operasional',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(7,'ATK',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(8,'Lainnya',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `expense_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_accounts`
--

DROP TABLE IF EXISTS `financial_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `financial_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `account_type` varchar(255) NOT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `account_number` text DEFAULT NULL,
  `account_holder` varchar(255) DEFAULT NULL,
  `opening_balance` decimal(18,2) NOT NULL DEFAULT 0.00,
  `current_balance` decimal(18,2) NOT NULL DEFAULT 0.00,
  `minimum_balance` decimal(18,2) NOT NULL DEFAULT 0.00,
  `is_central` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `financial_accounts_code_unique` (`code`),
  KEY `financial_accounts_branch_id_foreign` (`branch_id`),
  CONSTRAINT `financial_accounts_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_accounts`
--

LOCK TABLES `financial_accounts` WRITE;
/*!40000 ALTER TABLE `financial_accounts` DISABLE KEYS */;
INSERT INTO `financial_accounts` VALUES (2,2,'CASH','Kas Counter','cash',NULL,NULL,NULL,5000000.00,4925000.00,100000.00,0,1,'2026-09-18 03:17:05','2026-09-18 08:44:34'),(3,2,'BCA','BCA','bank',NULL,NULL,NULL,8000000.00,8000000.00,100000.00,0,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,2,'BRI','BRI','bank',NULL,NULL,NULL,3000000.00,3110000.00,100000.00,0,1,'2026-09-18 03:17:05','2026-09-18 04:10:30'),(5,2,'DIGI','Digiflazz (Demo)','provider',NULL,NULL,NULL,2000000.00,2000000.00,100000.00,0,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(6,2,'QA1789718850985','QA rekening terverifikasi','bank',NULL,'eyJpdiI6IjhvaGZYa1J0NVdXNk56eXVxSEFablE9PSIsInZhbHVlIjoiS1JYT2lBZUZkUGJrYUgwV2oyV0VoUT09IiwibWFjIjoiZjAzZjk3YjZjZTY3MzZmYjQxZTMyM2U0YzllZTc1ZTk3MmI2ZTdkNGJiZTRmNDZkNTJjNWVhNzBkZDRhY2QzYyIsInRhZyI6IiJ9',NULL,0.00,0.00,0.00,0,0,'2026-09-18 08:07:31','2026-09-18 08:07:34'),(7,2,'QA1789720544579','QA rekening terverifikasi','bank',NULL,'eyJpdiI6InluRG9vNzhQdjBWV3JlREtRdVAwZFE9PSIsInZhbHVlIjoiTFZuV1ZCZXNnR3NhSk5qbWtPVWw2Zz09IiwibWFjIjoiYTA3ZmNlZGNkM2U3Zjk5MTdkYTUzYzFmZjdjNzYzNzhiODlmNTA0NGU3NzQxY2QxMGRhYjAyY2U5NzU1NzNlNyIsInRhZyI6IiJ9',NULL,0.00,0.00,0.00,0,0,'2026-09-18 08:35:45','2026-09-18 08:35:49'),(8,2,'QA1789721081982','QA rekening terverifikasi','bank',NULL,'eyJpdiI6Ii9wSnZhTlBIdG5hSkhBYmMwcmRxQ3c9PSIsInZhbHVlIjoianVjZFAzNGVtMlEzUE9EZFU4a0lKdz09IiwibWFjIjoiOTkyZDIzYWFlMmQ4OTRmOTQ3OWI3MzVmM2ZmMjc0MWEwMDYxYzQ1ZGRhZjM0ZjhlNTUyNDYxMmFiNGViYTZhNiIsInRhZyI6IiJ9',NULL,0.00,0.00,0.00,0,0,'2026-09-18 08:44:43','2026-09-18 08:44:46'),(9,3,'171222','Ilham Rekening','bank','Bank Ilham','eyJpdiI6IlI4MWRiN1VYOTZZa09uUEpMcDNhL3c9PSIsInZhbHVlIjoiSDdBeUNwdlJnUXRyZGt0YXV0SGtOUT09IiwibWFjIjoiMTRkY2JlY2QzOWNjOTQxNDIwOTQ3Mzg3Yjg0MGZmZDU0ZjNmOGM3YzYyYWE0YmJlOTRiOGIxMGViZTYwY2VmMiIsInRhZyI6IiJ9','Fahrozi',1000000.00,1010000.00,100000.00,0,1,'2026-09-18 09:01:44','2026-09-18 09:10:03'),(10,3,'KasCB002','Kas','cash',NULL,NULL,NULL,150000.00,260000.00,50000.00,0,1,'2026-09-18 09:04:26','2026-09-18 09:10:03');
/*!40000 ALTER TABLE `financial_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `galleries`
--

DROP TABLE IF EXISTS `galleries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `galleries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `galleries`
--

LOCK TABLES `galleries` WRITE;
/*!40000 ALTER TABLE `galleries` DISABLE KEYS */;
/*!40000 ALTER TABLE `galleries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_logs`
--

DROP TABLE IF EXISTS `login_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `success` tinyint(1) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `login_logs_user_id_foreign` (`user_id`),
  CONSTRAINT `login_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_logs`
--

LOCK TABLES `login_logs` WRITE;
/*!40000 ALTER TABLE `login_logs` DISABLE KEYS */;
INSERT INTO `login_logs` VALUES (1,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:39:30'),(2,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:42:12'),(3,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:45:16'),(4,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:45:46'),(5,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:46:21'),(6,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:46:54'),(7,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:47:28'),(8,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:47:57'),(9,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:48:28'),(10,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:50:34'),(11,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:50:52'),(12,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:54:14'),(13,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 03:54:30'),(14,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',0,'2026-09-18 03:58:53'),(15,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 03:59:02'),(16,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 04:01:45'),(17,5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 04:03:46'),(18,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 04:05:26'),(19,5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36',1,'2026-09-18 04:06:39'),(20,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 04:06:57'),(21,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36',1,'2026-09-18 04:07:39'),(22,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36',1,'2026-09-18 04:12:34'),(23,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:07:13'),(24,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:07:28'),(25,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:32:36'),(26,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:32:39'),(27,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:33:09'),(28,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:33:39'),(29,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:34:08'),(30,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:34:35'),(31,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:35:25'),(32,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:35:29'),(33,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:35:42'),(34,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:40:36'),(35,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:41:34'),(36,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:42:00'),(37,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:42:26'),(38,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:42:55'),(39,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:43:24'),(40,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:44:19'),(41,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:44:24'),(42,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:44:39'),(43,6,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 27 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27 Mobile/15E148 Safari/604.1',1,'2026-09-18 08:45:33'),(44,4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0',1,'2026-09-18 08:52:06'),(45,7,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36',0,'2026-09-18 08:57:23'),(46,7,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36',1,'2026-09-18 08:57:30');
/*!40000 ALTER TABLE `login_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_09_18_000001_create_counter_system',1),(5,'2026_09_18_000002_add_wallets_and_closing',2),(6,'2026_09_18_000003_add_settlement_reference',3),(7,'2026_09_18_000004_add_numbering_and_stock_transfers',4),(8,'2026_09_18_000005_add_digital_pricing_and_dimensions',5),(9,'2026_09_18_000006_add_reconciliation_review_and_risk',6),(10,'2026_09_18_000007_add_stock_opnames',7);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_reads`
--

DROP TABLE IF EXISTS `notification_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_reads` (
  `user_id` bigint(20) unsigned NOT NULL,
  `notification_key` varchar(255) NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`,`notification_key`),
  CONSTRAINT `notification_reads_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_reads`
--

LOCK TABLES `notification_reads` WRITE;
/*!40000 ALTER TABLE `notification_reads` DISABLE KEYS */;
INSERT INTO `notification_reads` VALUES (6,'5e89801394fb7a7e01315b775504498efc1e708e8d1e60077942251fe175d206','2026-09-18 08:46:15');
/*!40000 ALTER TABLE `notification_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `number_sequences`
--

DROP TABLE IF EXISTS `number_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `number_sequences` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `type` varchar(255) NOT NULL,
  `period` varchar(6) NOT NULL,
  `value` bigint(20) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number_sequences_branch_id_type_period_unique` (`branch_id`,`type`,`period`),
  CONSTRAINT `number_sequences_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `number_sequences`
--

LOCK TABLES `number_sequences` WRITE;
/*!40000 ALTER TABLE `number_sequences` DISABLE KEYS */;
INSERT INTO `number_sequences` VALUES (4,2,'sale','202609',4),(5,2,'cash_withdrawal','202609',1),(7,2,'reversal','202609',3),(13,3,'stock_adjustment','202609',1),(15,3,'sale','202609',1),(16,3,'cash_withdrawal','202609',1),(17,3,'money_transfer','202609',1);
/*!40000 ALTER TABLE `number_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operator_prefixes`
--

DROP TABLE IF EXISTS `operator_prefixes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operator_prefixes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `operator_id` bigint(20) unsigned NOT NULL,
  `prefix` varchar(8) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `operator_prefixes_prefix_unique` (`prefix`),
  KEY `operator_prefixes_operator_id_foreign` (`operator_id`),
  CONSTRAINT `operator_prefixes_operator_id_foreign` FOREIGN KEY (`operator_id`) REFERENCES `operators` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operator_prefixes`
--

LOCK TABLES `operator_prefixes` WRITE;
/*!40000 ALTER TABLE `operator_prefixes` DISABLE KEYS */;
/*!40000 ALTER TABLE `operator_prefixes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators`
--

DROP TABLE IF EXISTS `operators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `operators_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators`
--

LOCK TABLES `operators` WRITE;
/*!40000 ALTER TABLE `operators` DISABLE KEYS */;
INSERT INTO `operators` VALUES (1,'Telkomsel',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,'Indosat',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,'XL',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,'PLN',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(5,'DANA',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(6,'OVO',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(7,'GoPay',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `operators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_categories`
--

DROP TABLE IF EXISTS `product_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_categories`
--

LOCK TABLES `product_categories` WRITE;
/*!40000 ALTER TABLE `product_categories` DISABLE KEYS */;
INSERT INTO `product_categories` VALUES (1,'Aksesoris',1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,'Jasa',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `product_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) NOT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'physical',
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `brand_id` bigint(20) unsigned DEFAULT NULL,
  `unit_id` bigint(20) unsigned DEFAULT NULL,
  `purchase_price` decimal(18,2) NOT NULL DEFAULT 0.00,
  `selling_price` decimal(18,2) NOT NULL,
  `track_stock` tinyint(1) NOT NULL DEFAULT 1,
  `minimum_stock` int(10) unsigned NOT NULL DEFAULT 5,
  `warranty_days` int(10) unsigned NOT NULL DEFAULT 0,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_sku_unique` (`sku`),
  UNIQUE KEY `products_barcode_unique` (`barcode`),
  KEY `products_category_id_foreign` (`category_id`),
  KEY `products_brand_id_foreign` (`brand_id`),
  KEY `products_unit_id_foreign` (`unit_id`),
  CONSTRAINT `products_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`),
  CONSTRAINT `products_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'USB',NULL,'USB Cable',NULL,'physical',NULL,NULL,NULL,15000.00,25000.00,1,5,7,NULL,1,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL),(2,'GLASS',NULL,'Tempered Glass',NULL,'physical',NULL,NULL,NULL,10000.00,20000.00,1,5,7,NULL,1,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL),(3,'CHARGER',NULL,'Charger',NULL,'physical',NULL,NULL,NULL,35000.00,55000.00,1,5,7,NULL,1,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provider_accounts`
--

DROP TABLE IF EXISTS `provider_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provider_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `provider_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `financial_account_id` bigint(20) unsigned NOT NULL,
  `account_name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `provider_accounts_provider_id_branch_id_unique` (`provider_id`,`branch_id`),
  KEY `provider_accounts_branch_id_foreign` (`branch_id`),
  KEY `provider_accounts_financial_account_id_foreign` (`financial_account_id`),
  CONSTRAINT `provider_accounts_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `provider_accounts_financial_account_id_foreign` FOREIGN KEY (`financial_account_id`) REFERENCES `financial_accounts` (`id`),
  CONSTRAINT `provider_accounts_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_accounts`
--

LOCK TABLES `provider_accounts` WRITE;
/*!40000 ALTER TABLE `provider_accounts` DISABLE KEYS */;
INSERT INTO `provider_accounts` VALUES (1,1,2,5,'Saldo digital utama',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `provider_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `providers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `provider_type` varchar(255) NOT NULL DEFAULT 'mock',
  `api_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `credentials` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `providers_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `providers`
--

LOCK TABLES `providers` WRITE;
/*!40000 ALTER TABLE `providers` DISABLE KEYS */;
INSERT INTO `providers` VALUES (1,'MOCK','Provider Demo','mock',0,NULL,1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `risk_flags`
--

DROP TABLE IF EXISTS `risk_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `risk_flags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `reason` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'review',
  `reviewed_by` bigint(20) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `risk_flags_branch_id_foreign` (`branch_id`),
  KEY `risk_flags_transaction_id_foreign` (`transaction_id`),
  KEY `risk_flags_reviewed_by_foreign` (`reviewed_by`),
  CONSTRAINT `risk_flags_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `risk_flags_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `risk_flags_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `risk_flags`
--

LOCK TABLES `risk_flags` WRITE;
/*!40000 ALTER TABLE `risk_flags` DISABLE KEYS */;
/*!40000 ALTER TABLE `risk_flags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (7,'OWNER','[\"*\"]','2026-09-18 03:17:04','2026-09-18 03:17:04'),(8,'ADMIN','[\"branch.view\",\"branch.create\",\"branch.update\",\"account.view\",\"account.create\",\"account.update\",\"customer.view\",\"customer.create\",\"customer.update\",\"supplier.view\",\"supplier.create\",\"supplier.update\",\"provider.view\",\"provider.create\",\"provider.update\",\"product.view\",\"product.create\",\"product.update\",\"settings.view\",\"settings.create\",\"settings.update\",\"website.view\",\"website.create\",\"website.update\",\"expense.view\",\"expense.create\",\"expense.update\",\"dashboard.view\",\"stock.view\",\"sale.view\",\"sale.create\",\"cash_withdrawal.create\",\"transfer.create\",\"digital.create\",\"session.manage\",\"account.transfer\",\"stock.adjust\",\"stock.transfer\",\"purchase.create\",\"report.view\",\"report.export\",\"audit.view\"]','2026-09-18 03:17:04','2026-09-18 03:17:04'),(9,'MANAGER','[\"dashboard.view\",\"branch.view\",\"account.view\",\"product.view\",\"provider.view\",\"customer.view\",\"customer.create\",\"stock.view\",\"sale.view\",\"sale.create\",\"cash_withdrawal.create\",\"transfer.create\",\"digital.create\",\"session.manage\",\"account.transfer\",\"stock.adjust\",\"report.view\",\"report.export\"]','2026-09-18 03:17:04','2026-09-18 03:17:04'),(10,'CASHIER','[\"dashboard.view\",\"branch.view\",\"account.view\",\"product.view\",\"provider.view\",\"customer.view\",\"customer.create\",\"stock.view\",\"sale.view\",\"sale.create\",\"cash_withdrawal.create\",\"transfer.create\",\"digital.create\",\"session.manage\"]','2026-09-18 03:17:04','2026-09-18 03:17:04'),(11,'INVENTORY','[\"dashboard.view\",\"branch.view\",\"product.view\",\"product.create\",\"product.update\",\"supplier.view\",\"supplier.create\",\"supplier.update\",\"stock.view\",\"stock.adjust\",\"stock.transfer\",\"purchase.create\",\"sale.view\",\"account.view\"]','2026-09-18 03:17:04','2026-09-18 03:17:04'),(12,'FINANCE','[\"dashboard.view\",\"branch.view\",\"account.view\",\"account.create\",\"account.update\",\"account.adjust\",\"account.transfer\",\"account.reconcile\",\"expense.view\",\"expense.create\",\"income.create\",\"report.view\",\"report.export\",\"sale.view\",\"supplier.view\"]','2026-09-18 03:17:04','2026-09-18 03:17:04');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('3cDG0qv5QcM57iEWUrOEsCoTuJICs5gPizznbjin',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJwY3pCelA3UUhBWG11VDNWQk15cVFlcVVPTFVDVE9zcVkzMXhnYW5VIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720972),('bGeZVg9QgfGtfWBwGSGMVFiwIiXfLVMqm0W5AwWK',6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJzeEQ2QUN4Q1dkZmo4YzNXM0doQjBjR3JFOGwwbzVsSGxacFQ4YmJOIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3RyYW5zYWN0aW9ucz9icmFuY2hfaWQ9MiIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6Nn0=',1789722309),('bxWnFCEshTNblVfYyxzaRVhqXKHPHpirVgbj06pz',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJvdXpPRnBQOEc2SmRhZ1hZT1ROUlVzbEpCM0ttWUJCZmFIZzVHYWI2IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720521),('ELKql3edXZNy4ZbxwKYWmCHOAPCF7UBV245hC8HQ',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJ0UVhPZlh3TDZvanNOQUxhV3p0Mllsb2NtSDFCTjRKaW54cGZCbTBrIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3RyYW5zYWN0aW9uc1wvOSIsInJvdXRlIjpudWxsfSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6NH0=',1789718846),('EUj4hCDZ8b9O20bMvtXuClrOQRkwuChnxVIsqLfa',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJFc2ljRlkweG5PSzJEVVFCMmM4VmNuY0Uwb1N2WXdMR1gzQWNDYWJvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720917),('GYjSa9f8bYcJmFyamOykri1alfzym7v4FVlZ9mOF',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJYbGxHYmRwM2cxdjhwYk1oSVRKYmhtTW03RjNGZXZITzBQZkkyUEhPIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720416),('i9wefz7DjmVqxp5Tntk7PJoLLMYhMRCnejd9yHuP',6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI1dm5YQUxYRFRwZUNpMzNPM3lmbU9jSzZkSHJqYzIybjJHZkpGemxPIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjZ9',1789721062),('JCPGlZkyyto29g0BdcuDp58vEVqeqcygiHL1qL9r',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJsSlBSdXpTVHhqWG91bEthZEFCa01LbEhsTDNvZllUd3kzMUFrbnVxIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3Jlc291cmNlc1wvYnJhbmNoZXM/cGVyX3BhZ2U9MTAwJnNlYXJjaD0iLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789721088),('JGdU9cQ6wIkoTpYWhNAKCdHyIbofZCFyPGCiTH2n',7,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI5SDd3RXRyQmQwUlRYc2J1UXQyNThHRVRNdXNJaEx1QUdHWXdtaTBkIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL2Nhc2hpZXItc2Vzc2lvbnM/YnJhbmNoX2lkPTMmcGFnZT0xIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjo3fQ==',1789723909),('Jy8IgaWS7iBnH4oXYhi5br6kKaKQm5JOCzeUIJMh',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJXNWVBUVBteUExS3JLSno2ZnRyaGRuTVNuQTVFTGtpVEZBc0dTRkpSIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789721055),('lkY9X4nefuexgbgNgYprlnvQf8HGe5FJ7dl0b5pv',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJDTXhydnFxRWVyTFhidmY4dHQzdXNTTmRCWmZMbGJFYTNCQVkydlJ1IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789721001),('MkBsIkPt6MH1sUG6QeRtYwScBHT9WXwMxsAC9dxq',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJKNmZQRkk3V2FoVzRQekdmams2M0g4UXBpc2JVMTFCNVRoRFVQRmFRIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9zYW5jdHVtXC9jc3JmLWNvb2tpZSIsInJvdXRlIjoic2FuY3R1bS5jc3JmLWNvb2tpZSJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjo0fQ==',1789720356),('OKqwOITpOSr033FeCh2loMFjTEgOaBc6GJCP70es',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJNbGJyaEFPZHpFR3h5aHhYanVTUW9wbnhxRDV2SWp4VEtvZnFmSEVQIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3RyYW5zYWN0aW9uc1wvMTEiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720539),('osvU5b5O4hVQ5LBj971lwlG9zuIGTWqW3jebEVPS',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJLZlM4WDNUazVjSmxEZzFmeXZGU2hwa3hVc3A0dE9vMHVSd0tnT0NCIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720944),('sN5E6lu4DQs79CqZ2WmENkQBoWGqDJKWU6STJtnj',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJ6V1g3bHFtTFFIU1dsZVBEYXZselhkZEY5NmhLQVJVVXZ5MTBMcGFEIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720445),('tBW10mtNSWcd5HwNgGnEx3R2o6CS9EtMsF46tO8Z',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJCVWVuME9zWERjeDR4TmpWOHZuMDFxa0lZbUN3U0hWYjJJTmZQREh1IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3Jlc291cmNlc1wvYnJhbmNoZXM/cGVyX3BhZ2U9MTAwJnNlYXJjaD0iLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720552),('tp3IEc1oIIKqc6Xsdf2WX8VdgmrwVaHHyPid0AgE',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJWMExqZlJPcmlsS05CR3JVWGE0R0NRS1c5ajgwd2lCSEtmdXBXY2F5IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720472),('Va0yahenxF85FfDtHKBagaee4RDhXoBkVm2qeeI7',6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJud1JzQkpCVHQ5M1F0eTIyTmoyZXhWVVkxb2FTbGIxTDJma3FicmgyIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjZ9',1789720528),('VxsVh27UMB1hDaROx8jKwYHaRa0DoBlcKk1H5jJs',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0','eyJfdG9rZW4iOiIzWEtRd0NjSHZ2MnVYZEtxYkNSQWxDVUoySVFISkM4VEdLYzl4NmlEIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3JlcG9ydHM/YnJhbmNoX2lkPTMmcGFnZT0xIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjo0fQ==',1789723911),('yDOC61NfDAIRYd37s09EQx5Doxd3HLpWUra359b6',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI0a1BCUlVDWXM4bXBCV01NMUNINWxLRDROZDlhQXFuSU5kMWprTXVoIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3RyYW5zYWN0aW9uc1wvMTMiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789721076),('Yp5AYd14DyjX3rfE64AT1xtOMW2s9bljMtcCzT8K',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJhNWJuN3o4dmlPa29lMHZGTTBOcmpmNDdHRnVGZnl0WERlOHEwbUZ5IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720386),('yYkDvShOsCATFBKJzGkgcaeKJRo8EDUxQ6ki4y2X',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJWaG55U1MyUlRZcmt2NEQ5NTltT1hNRTEwckZheFBTdmhQeTB5V0lDIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL3Jlc291cmNlc1wvYnJhbmNoZXM/cGVyX3BhZ2U9MTAwJnNlYXJjaD0iLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789718856),('ZG0IqYXKJmfgR90fqJfnLWIAJv61gXArh7dEQu69',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/152.0.0.0 Safari/537.36','eyJfdG9rZW4iOiIzMVRQWlczWlhoVU93b2dycW9sZVZFd3B4RFhES01HaWdBNFladWRoIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hcGlcL25vdGlmaWNhdGlvbnM/YnJhbmNoX2lkPTIiLCJyb3V0ZSI6bnVsbH0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjR9',1789720890);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `key` varchar(255) NOT NULL,
  `value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`value`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('allow_negative_stock','false','2026-09-18 03:17:05','2026-09-18 03:17:05'),('approval_threshold','\"5000000\"','2026-09-18 03:17:05','2026-09-18 03:17:05'),('business','{\"name\":\"ASP Smart Cell\",\"legal_name\":\"ASP Smart Cell\",\"tagline\":\"Solusi digital, dekat dengan Anda.\",\"address\":\"Silakan atur alamat counter\",\"phone\":\"\",\"whatsapp\":\"\",\"email\":\"\",\"logo\":\"\",\"description\":\"Pulsa, paket data, transfer, dan aksesori dalam satu counter.\"}','2026-09-18 03:17:05','2026-09-18 03:17:05'),('receipt','{\"paper\":\"80mm\",\"footer\":\"Terima kasih atas kepercayaan Anda.\",\"terms\":\"Simpan struk sebagai bukti transaksi.\",\"show_logo\":true}','2026-09-18 03:17:05','2026-09-18 03:17:05'),('require_cashier_session','true','2026-09-18 03:17:05','2026-09-18 03:17:05'),('website','{\"hero_title\":\"Kebutuhan digital Anda. Semua ada di sini.\",\"hero_description\":\"Isi pulsa, beli paket data, transfer uang, dan temukan aksesori pilihan. Kami siap membantu setiap hari.\",\"primary_color\":\"#176b52\",\"theme\":\"modern\",\"seo_title\":\"ASP Smart Cell\",\"seo_description\":\"Counter pulsa dan layanan digital.\"}','2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_movements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `before_qty` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `after_qty` int(11) NOT NULL,
  `reason` text NOT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_movements_branch_id_foreign` (`branch_id`),
  KEY `stock_movements_product_id_foreign` (`product_id`),
  KEY `stock_movements_transaction_id_foreign` (`transaction_id`),
  KEY `stock_movements_created_by_foreign` (`created_by`),
  CONSTRAINT `stock_movements_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `stock_movements_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_movements_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `stock_movements_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
INSERT INTO `stock_movements` VALUES (1,2,1,1,'stock_adjustment',0,20,20,'Stok awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,2,2,2,'stock_adjustment',0,20,20,'Stok awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,2,3,3,'stock_adjustment',0,20,20,'Stok awal pengembangan',4,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(4,2,1,7,'sale',20,-1,19,'TRX/CB01/202609/000001',6,'2026-09-18 04:08:02','2026-09-18 04:08:02'),(5,2,1,9,'sale',19,-1,18,'TRX/CB01/202609/000002',4,'2026-09-18 08:07:21','2026-09-18 08:07:21'),(6,2,1,10,'reversal',18,1,19,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:07:24','2026-09-18 08:07:24'),(7,2,1,11,'sale',19,-1,18,'TRX/CB01/202609/000003',4,'2026-09-18 08:35:35','2026-09-18 08:35:35'),(8,2,1,12,'reversal',18,1,19,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:35:38','2026-09-18 08:35:38'),(9,2,1,13,'sale',19,-1,18,'TRX/CB01/202609/000004',4,'2026-09-18 08:44:30','2026-09-18 08:44:30'),(10,2,1,14,'reversal',18,1,19,'QA browser: pembalikan penjualan pengujian',4,'2026-09-18 08:44:34','2026-09-18 08:44:34'),(11,3,3,16,'stock_adjustment',0,10,10,'asd',4,'2026-09-18 08:59:23','2026-09-18 08:59:23'),(12,3,3,18,'sale',10,-2,8,'TRX/CB02/202609/000001',7,'2026-09-18 09:04:58','2026-09-18 09:04:58');
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_opname_items`
--

DROP TABLE IF EXISTS `stock_opname_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_opname_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stock_opname_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `system_quantity` int(11) NOT NULL,
  `actual_quantity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_opname_items_stock_opname_id_product_id_unique` (`stock_opname_id`,`product_id`),
  KEY `stock_opname_items_product_id_foreign` (`product_id`),
  CONSTRAINT `stock_opname_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `stock_opname_items_stock_opname_id_foreign` FOREIGN KEY (`stock_opname_id`) REFERENCES `stock_opnames` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_opname_items`
--

LOCK TABLES `stock_opname_items` WRITE;
/*!40000 ALTER TABLE `stock_opname_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_opname_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_opnames`
--

DROP TABLE IF EXISTS `stock_opnames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_opnames` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'draft',
  `notes` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_opnames_transaction_id_unique` (`transaction_id`),
  KEY `stock_opnames_branch_id_foreign` (`branch_id`),
  KEY `stock_opnames_created_by_foreign` (`created_by`),
  CONSTRAINT `stock_opnames_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `stock_opnames_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_opnames_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_opnames`
--

LOCK TABLES `stock_opnames` WRITE;
/*!40000 ALTER TABLE `stock_opnames` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_opnames` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_transfers`
--

DROP TABLE IF EXISTS `stock_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_transfers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned NOT NULL,
  `destination_branch_id` bigint(20) unsigned NOT NULL,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) unsigned NOT NULL,
  `approved_by` bigint(20) unsigned DEFAULT NULL,
  `received_by` bigint(20) unsigned DEFAULT NULL,
  `notes` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_transfers_transaction_id_unique` (`transaction_id`),
  KEY `stock_transfers_branch_id_foreign` (`branch_id`),
  KEY `stock_transfers_destination_branch_id_foreign` (`destination_branch_id`),
  KEY `stock_transfers_created_by_foreign` (`created_by`),
  KEY `stock_transfers_approved_by_foreign` (`approved_by`),
  KEY `stock_transfers_received_by_foreign` (`received_by`),
  CONSTRAINT `stock_transfers_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_transfers_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `stock_transfers_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_transfers_destination_branch_id_foreign` FOREIGN KEY (`destination_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `stock_transfers_received_by_foreign` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_transfers_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_transfers`
--

LOCK TABLES `stock_transfers` WRITE;
/*!40000 ALTER TABLE `stock_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppliers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `whatsapp` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `suppliers_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `testimonials`
--

DROP TABLE IF EXISTS `testimonials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `testimonials` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testimonials`
--

LOCK TABLES `testimonials` WRITE;
/*!40000 ALTER TABLE `testimonials` DISABLE KEYS */;
/*!40000 ALTER TABLE `testimonials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_fee_rules`
--

DROP TABLE IF EXISTS `transaction_fee_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_fee_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `minimum_amount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `maximum_amount` decimal(18,2) DEFAULT NULL,
  `fee_type` varchar(255) NOT NULL DEFAULT 'fixed',
  `fee_value` decimal(18,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_fee_rules_branch_id_foreign` (`branch_id`),
  CONSTRAINT `transaction_fee_rules_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_fee_rules`
--

LOCK TABLES `transaction_fee_rules` WRITE;
/*!40000 ALTER TABLE `transaction_fee_rules` DISABLE KEYS */;
INSERT INTO `transaction_fee_rules` VALUES (1,3,'Admin Tarik tunai','cash_withdrawal',10000.00,1000000.00,'percentage',10.00,1,'2026-09-18 09:06:51','2026-09-18 09:06:51');
/*!40000 ALTER TABLE `transaction_fee_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_items`
--

DROP TABLE IF EXISTS `transaction_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(18,2) NOT NULL,
  `unit_cost` decimal(18,2) NOT NULL,
  `warranty_days` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `transaction_items_transaction_id_foreign` (`transaction_id`),
  KEY `transaction_items_product_id_foreign` (`product_id`),
  CONSTRAINT `transaction_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `transaction_items_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_items`
--

LOCK TABLES `transaction_items` WRITE;
/*!40000 ALTER TABLE `transaction_items` DISABLE KEYS */;
INSERT INTO `transaction_items` VALUES (1,7,1,'USB Cable',1,25000.00,15000.00,7),(2,9,1,'USB Cable',1,25000.00,15000.00,7),(3,11,1,'USB Cable',1,25000.00,15000.00,7),(4,13,1,'USB Cable',1,25000.00,15000.00,7),(5,18,3,'Charger',2,55000.00,35000.00,7);
/*!40000 ALTER TABLE `transaction_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `reference_number` varchar(255) NOT NULL,
  `idempotency_key` varchar(80) NOT NULL,
  `request_hash` varchar(64) NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  `created_by` bigint(20) unsigned NOT NULL,
  `customer_id` bigint(20) unsigned DEFAULT NULL,
  `supplier_id` bigint(20) unsigned DEFAULT NULL,
  `cashier_session_id` bigint(20) unsigned DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `amount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `fee` decimal(18,2) NOT NULL DEFAULT 0.00,
  `revenue` decimal(18,2) NOT NULL DEFAULT 0.00,
  `cost` decimal(18,2) NOT NULL DEFAULT 0.00,
  `profit` decimal(18,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `change_amount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `outstanding_amount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `details` text NOT NULL,
  `notes` text DEFAULT NULL,
  `reversal_of` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `settlement_of` bigint(20) unsigned DEFAULT NULL,
  `provider_id` bigint(20) unsigned DEFAULT NULL,
  `digital_product_id` bigint(20) unsigned DEFAULT NULL,
  `operator_id` bigint(20) unsigned DEFAULT NULL,
  `digital_category` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transactions_reference_number_unique` (`reference_number`),
  UNIQUE KEY `transactions_idempotency_key_unique` (`idempotency_key`),
  UNIQUE KEY `transactions_reversal_of_unique` (`reversal_of`),
  KEY `transactions_created_by_foreign` (`created_by`),
  KEY `transactions_customer_id_foreign` (`customer_id`),
  KEY `transactions_supplier_id_foreign` (`supplier_id`),
  KEY `transactions_cashier_session_id_foreign` (`cashier_session_id`),
  KEY `transactions_branch_id_created_at_index` (`branch_id`,`created_at`),
  KEY `transactions_type_index` (`type`),
  KEY `transactions_status_index` (`status`),
  KEY `transactions_settlement_of_foreign` (`settlement_of`),
  KEY `transactions_provider_id_foreign` (`provider_id`),
  KEY `transactions_digital_product_id_foreign` (`digital_product_id`),
  KEY `transactions_operator_id_foreign` (`operator_id`),
  KEY `transactions_digital_category_index` (`digital_category`),
  CONSTRAINT `transactions_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `transactions_cashier_session_id_foreign` FOREIGN KEY (`cashier_session_id`) REFERENCES `cashier_sessions` (`id`),
  CONSTRAINT `transactions_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `transactions_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `transactions_digital_product_id_foreign` FOREIGN KEY (`digital_product_id`) REFERENCES `digital_products` (`id`),
  CONSTRAINT `transactions_operator_id_foreign` FOREIGN KEY (`operator_id`) REFERENCES `operators` (`id`),
  CONSTRAINT `transactions_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`),
  CONSTRAINT `transactions_reversal_of_foreign` FOREIGN KEY (`reversal_of`) REFERENCES `transactions` (`id`),
  CONSTRAINT `transactions_settlement_of_foreign` FOREIGN KEY (`settlement_of`) REFERENCES `transactions` (`id`),
  CONSTRAINT `transactions_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'STOCK_ADJUSTMENT/2/202609/01M2S892JR1VY26PNAV4J1QQCM','seed-stock-USB-initial','f844044c30a20d2fccbd2fab7f14b5883eb40a52e35ec0543d290054f96d81f1',2,4,NULL,NULL,NULL,'stock_adjustment','completed',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'eyJpdiI6IkozUm1GSDNCWE5kVzVBU2hHVnp3U1E9PSIsInZhbHVlIjoicUZkQlY4bHZSVlVaRzlhSkdzRnphc1ZuaThPL0VtUW5EVlEreXFmL0h2SFRINnVwQ3dBUTdhSUQ5QlFDeEV0azBQSmtLTGlBVjBLY0p2MUM3SEFUMnRsc1dqZk1vNUlHUzRvdE5aa2Vkc1Y0ODQ3UTlhVUlsTWZHZnVlWCtrc2pMT3JDMHFvTTBGZy81THpVSUIwODl2UXp6aVRuT3ZJTVNpZ0dYc3poN29VcXVZSUtVVlB2RXhBbE1vY0dJbmpESXRhMksyaUl1Q01rTFY5bTljTVhjQT09IiwibWFjIjoiNWE0MTM5Mzc1MGI5MWM4MmJhMGViZTdhNWM2ODhlOGI4OThhZTZiYjAzMjMwODU3YTVkY2QzOTU0NGE2ZDVhMCIsInRhZyI6IiJ9','Stok awal pengembangan',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL,NULL,NULL,NULL,NULL),(2,'STOCK_ADJUSTMENT/2/202609/01M2S892M6E58PWY8KXPYJ1NST','seed-stock-GLASS-initial','fc14f46081f0c51683fcd474c20f640f06ef2376179081f2998506d0ab75f269',2,4,NULL,NULL,NULL,'stock_adjustment','completed',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'eyJpdiI6ImphYW54aE9EYjd2VUtIMTJqWWRTYVE9PSIsInZhbHVlIjoiWFR0TUF2R2ZtamVOYmw2dWhtNEs4bnhqbllkcDBoSEtNVGQzTHg2MDFvM3RQd0tvTEk4Y1ZBQ2RJQjU2ZWlzeUhNenQ2VVQ1WXhLWi9ucmtySk1mZTdyZ0lxdVdKZ09FRlNDRXNUblVtbHFteWxJN2xWcEFkUnJxeExMZmdwQ0NkZHp6bDVxSjVYL29LZ2JLRGxOQUtjVm1iMmFxTWlXNjEwaTJQQXlkT1ZBTXN0QVQzWnpJa0FiVmhjM0RXOG1wa0R0TTY0Q1dmYTBSNWNWZXdxQ2JLQT09IiwibWFjIjoiOTgwMDNhZTkxM2NlMGQ2NDA0MjRjNmQ2YzY5YzIwMTE3MjdiMjU0YjBhYWEyMjM3ZDcyMjUzOTgzMmNiOTg3MyIsInRhZyI6IiJ9','Stok awal pengembangan',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL,NULL,NULL,NULL,NULL),(3,'STOCK_ADJUSTMENT/2/202609/01M2S892MX0BWX2ZVTM3TX82K1','seed-stock-CHARGER-initial','428830cae416c05dc6a4722ddd554feaa8b4bc1566d41d4a90f8dc0d92bbecaa',2,4,NULL,NULL,NULL,'stock_adjustment','completed',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'eyJpdiI6ImhzbytQblp5Y2dYbzljMnVUbVZBZHc9PSIsInZhbHVlIjoiM2JEZVRWeXJKSUVCU0RFVnlyY0l4eUpJRmZhWDF5WVFnRnhick5IOXdvRjZVdlRXOC9pdVpwUkQzNm84OXo4T2VCSm1xS3VHNmt4WVVQOVJoTFgxZ3hocDcrdnlNZUFsaWdUY0tzeXVaRE1iUVRieXhDVVZ5ZG9YUGl1eGhROXI3N3lSblZod0Vuajl4T2hNb2FyYjZ1R3p5OUtXQmxmL1lTamxqblNoVnBEUGtrOXB6L3ltdUdrenZ3SDhkSWV6RTNnTlJYUXl0d1BWaktHMm8rditLdz09IiwibWFjIjoiODk1NjAyZTY3ZjZhMDQ0MzEyMGM1Y2U1YjFjODgzNDM0YjYzMjIzZDA4ODUwZGJhMDQzZGRjMjNkYzU4YzM1YiIsInRhZyI6IiJ9','Stok awal pengembangan',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',NULL,NULL,NULL,NULL,NULL),(7,'TRX/CB01/202609/000001','3132c497-2e11-4675-9340-849d51ca75de','5c1016692762110cb65556eea05191771886fc2a404303e6a5396b106a471867',2,6,NULL,NULL,2,'sale','completed',25000.00,0.00,25000.00,15000.00,10000.00,30000.00,5000.00,0.00,'eyJpdiI6Ilg5NnhsOFRzeTQ3TnU4RnNMaUk0a2c9PSIsInZhbHVlIjoibElTVTd2WjR5eE5TWkxpeHBhL0ViT1J2ZE1KOUlxdXdhbXM5TXJOaG9TcFJuTlBQRFRDMlNvd2tHZkN5Mk9nL0pGR1JFY245TGpFeklwZ0c2NS8wdysvUTR5VnhNSlhRNHNESVU4NmR4K0Q5TFp2VWIwUWVRQ1FlMVB5SDFtMEc2QmRWbFpQVGlJKzE5T1FIeDl6TUhsQVorTThTcmJ5Znk2dmlPY3F2bGZPRzNmUXUyLzZvUEJjS0toRmtLeVdzYU5NUXBSdmNabjd3QUNlNTRJL3dtcGFHNTdXd3Z0K3Z0MkNab0FsRlUvc2RiSktzbTltQ0FYL09GemwrN3BsOCIsIm1hYyI6IjUwNTNhNDQ5ZWZhYTA0MzY4Y2ZhODAwZjZlODQ3N2FhNDEyMzhlY2IwZTdiOGI1YmE0NDU1MzI1ZTg4NGIzZDUiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 04:08:02','2026-09-18 04:08:02',NULL,NULL,NULL,NULL,NULL),(8,'CASHOUT/CB01/202609/000001','ffcf66cf-229a-4fe8-ac4c-b8ceee869b2e','c4fc9f92bc4a83be715710f6b314d41cc662aa18c050b262c7b3ae6a66c0feef',2,6,NULL,NULL,2,'cash_withdrawal','completed',100000.00,10000.00,10000.00,0.00,10000.00,0.00,0.00,0.00,'eyJpdiI6IkV1VVJPYkttMFJGTXNmL0lkNTl6N2c9PSIsInZhbHVlIjoiRlY5K2cvVnZtMHREZVUwSzdrTGcweVdpNTZwM0NEVGw4am1UWW9FRElNbTRIZnJFa1ZYTGNKNW5LaXhtekJlT3ZxeklvclRlUnB4NWNWdVVaVHlmaE1QSEUvWm0rVXdNbFpHUXp0RmFyODczUktEbmhsZXg3a2xWRDBlMm02V24vTVZPREtjcXFqTUNGVlNyVmdLWnQ0MzZlclQwUmd4aWUxOGV1ZUlwaU1LcXNLM1FFV0k2WW5xd1hPNVI5dGU0eEF4Z0hvZlZPaCtVVXFiaXpycmU2ODV3SUF0Q2lEenUxUkhUUWFxbkRuV05OQitKVkpYelpYd2JBMXJQSGVZQ2M5Y1BCZ2RYQXhLN2tSOEJwRVg4eUE9PSIsIm1hYyI6IjFmYTM4YjBmYmYxNzM0ZWU0YzIwOTI5NGRlYTAzMDc4ZjIyNDVlZGEyMjBmMzFhMWYxMGExNTE3ZmM3ZTIwMzUiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 04:10:30','2026-09-18 04:10:30',NULL,NULL,NULL,NULL,NULL),(9,'TRX/CB01/202609/000002','0df764bb-c46a-46d6-aef1-979e720ea311','1722e5bdba52bdd76b9c9d17c7073eb95d772fcad6dfe17a5c326be16df6521b',2,4,NULL,NULL,3,'sale','reversed',25000.00,0.00,25000.00,15000.00,10000.00,50000.00,25000.00,0.00,'eyJpdiI6InJCd0dPeXQzNzBGTEQyYzlWb1AzOWc9PSIsInZhbHVlIjoiSnpldHI1eTdyOHYzazhzRXNTN25ueWlrMlBzcmtSckhaSUFEeW1mcm5IcmxvMyt3NTJKNS9NWkJia09WN3NaVjZHemYyWTVXL3lzUkJEWHdSaHJ5cjgzWkNXanNoQW5ISkhxbGFuY1BqWkQyTGdka3RpZDZlZFRRUkpsUmNZQlBQMUpjNkRQbzdNTTdGSEw0aHgwcnk1L3RnbHNEMGQrekt3QUFLOS9VR2NjSndQeFEvbDQzaDJLK2JlcXlhSTRYMi91Rm05TkxOeHVWL3dGYWZuRSsyU2xWS1ZabW8rZ3FYcWpiZDIvZmNSeGdQVWV2cmtjdlJNZjY1cTc2cmJUVCIsIm1hYyI6Ijg2MWY5NGM4YWVmNmFmNzEyNzQ0NmI0ZDdhNDBmMGEwN2MzN2Y3NmUyZTRhMzdmYTAzMzYxMTExNzMyMTY5YzYiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 08:07:21','2026-09-18 08:07:24',NULL,NULL,NULL,NULL,NULL),(10,'REVERSAL/CB01/202609/000001','5b19df55-b787-4688-b1b3-d567f7510ac6','9152ac36bb8f340b3ae7ae8bbb00410eae86fc6a6e79038351b8a39f8ec18fa0',2,4,NULL,NULL,NULL,'reversal','completed',25000.00,0.00,-25000.00,-15000.00,-10000.00,0.00,0.00,0.00,'eyJpdiI6IjBZc2dlejNoRnMrNDJBbnFsdkdDTWc9PSIsInZhbHVlIjoiNnhsM2hyamVYS3pYVHd3N2JETUNYdUpiSEZWeVJ5ZWY0NHR6c1NwSWV3dStXclFYRk1jY0dwam84WEVPTnRzMU1SNktkT1ZITmFCczVlMmNDQzJZR2dBZU5CRy9yRU53OHJXSXMyZHRrZ21ZSlFlajdOd2o0dWFqTkI5enRDUllaa2YrS0hxRUxSUXFIT3VnVkppbmhCUk9DS1ZoSWlBcjFsS3RiaXFIYkZES0wyZTJ0Uzl4dzB1bGJnUEh0V1VQQlNwV2tlUVU3V1hCUy9qOUdLOGlwUT09IiwibWFjIjoiOWYyMjFkMGZiMmQ0MTNjZjljMDY0MDljMTZlYWZkZTk0N2ZhNjNhODQ2Y2QyOTE1MmU1YWJjOGU5ODQ0NmVmMCIsInRhZyI6IiJ9','QA browser: pembalikan penjualan pengujian',9,'2026-09-18 08:07:24','2026-09-18 08:07:24',NULL,NULL,NULL,NULL,NULL),(11,'TRX/CB01/202609/000003','6e98d853-67f0-4c7d-9a90-fc6c5c718b67','e88ae5cc06a774b234e47f521fd1083ae6cbca5b3ee0afc334d618079d616c5e',2,4,NULL,NULL,3,'sale','reversed',25000.00,0.00,25000.00,15000.00,10000.00,50000.00,25000.00,0.00,'eyJpdiI6IjBvRHg5SEFlY2s3bm9qcG92NFlSaXc9PSIsInZhbHVlIjoibDV0b2wxMUxjQXhYK3lmbFJaL2tsN3dlR1VUTVNvdW9EVEk2WGJWT3F1K1pyR1MrN0lTeTJGNjJVR3JrVy9aeDR4TE5lNkZIbE40dFJYVkdqOWlncDdaYkF2eUQrZDlaOHlJVmk3MSs5T3g2ZVpqNThFV0V1Zm1GQUVkRU9pR1BiRXdPTkRXOFdHQ0VnN09rcXhyQ09JS0Z6QVV0bkRPdm1mcUZtMm5uUFllc29lVm0rVjA5ZkxkakFqV01STThsTVA5NDFFWGlpdDdHMC9EcVhrMFFZcWRTc3YzS05lNkVLT3JiMVA1MTJSeENld3I0SjQ1S3dzQ0FVWmV0NlVTWiIsIm1hYyI6Ijc1OGYxMjIzMjhkYmIzYmJkNDRmNmIxNGMxMWQwNmM5YTU5M2YwNjk3MzdjZTgyMjE2ODQ0MTJkZWM2YjRhNzgiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 08:35:35','2026-09-18 08:35:38',NULL,NULL,NULL,NULL,NULL),(12,'REVERSAL/CB01/202609/000002','231b87d6-40be-401c-b292-5a432d0f97af','ae9cc1b05aff28d78a1ca8abba747c3d75c4f5241842a2c9dc2f68bfa6dac8b4',2,4,NULL,NULL,NULL,'reversal','completed',25000.00,0.00,-25000.00,-15000.00,-10000.00,0.00,0.00,0.00,'eyJpdiI6InYrRjVrcFJxYTJIN2J3b01VR2dtVHc9PSIsInZhbHVlIjoibUN2RGFuSVZTMTVnRzNTSVk1MlVlb3NjVGJPWW1Sci9UMVVRbUlRWFZCWkdNSUdlZyt1b20wdE13UzJxWDBXVFJ1VURTcktpdWlwZkdENm5iMEhKZE1xbFBCVFdpeGdsNi9sMlZhOVhZRlRsUmt3Y3B6TDBkSUkwdXU1am95QzRmVHM3a2tuY2ZVL2lFZlgxOEtZbWtUN3paMW10bzVOYmFhZzV3b01tdzlJK3ZYQnFqMlFQZWI5dGJkUVB2L3BXWEtsUEg3N0svRU1wK09IYlJEUDlJcFpGU3crNWx5VERLZzJVNHRBeTU5Yz0iLCJtYWMiOiIyZjZlOTE3YWYxMTk0NWY5ZmI5MTQyNDI5MDI1YzlkZDlhYWMyZmQ1N2M5ZTBjNWI3ZTdmYTYzMjEwYzQ4N2U3IiwidGFnIjoiIn0=','QA browser: pembalikan penjualan pengujian',11,'2026-09-18 08:35:38','2026-09-18 08:35:38',NULL,NULL,NULL,NULL,NULL),(13,'TRX/CB01/202609/000004','a22416d3-56ed-4eb1-a446-066375692da5','5beca0ce72beb7caea783d54a9ce4d9d4432f478b3e95637bff3f7ebf5e3528c',2,4,NULL,NULL,3,'sale','reversed',25000.00,0.00,25000.00,15000.00,10000.00,50000.00,25000.00,0.00,'eyJpdiI6IkFLUVdxa05ndFpBV3h6eWJlVEZMZnc9PSIsInZhbHVlIjoiUGsrWkhpSXpFdEt0RGx0bXQ4dk5vYWNFSk95SzZwaEwwQ3hCbGdzMU5Eb0kvYi8yQUFLTTNLRmEyd2JIeHBEdk5ncXVGaml3alhpVXozZ1BHNUQrcWtCTzhwM2lWODFheTlDUW9yNmhzMTRyUitMdFRFQjlJOWRXSEkzZnlVUWdDcGRJUC9OUFNReXhQK1N3emhsTXR0SmZ0bWJnWlRxVDI1VXFpeVJUWVMya2R2Vm45YlFiSnlOSU9IdHVnS2YzNnp6Y0FwKzUyZi9NbnZpbkFQZ1R3ZHpiNjlRc1V6MU50ZHNBa3RiNFYzaFVUVUZlTFRqUFo5VFVYRENhYnhFWCIsIm1hYyI6IjJhODdiYmZmZTU5NTMwODUyYmIzZjZmMjNmYmY3NjczODQyZWU2NDliOThiODE4NjhhZTRmMTlhZTQ4MzVhYmMiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 08:44:30','2026-09-18 08:44:34',NULL,NULL,NULL,NULL,NULL),(14,'REVERSAL/CB01/202609/000003','2d5814a3-1e12-47c3-b1c4-0874c43c80f6','9018d45069fab2ea201164ac1953ddcd04c85a07e6c9638f1f4fd8d3b981d062',2,4,NULL,NULL,NULL,'reversal','completed',25000.00,0.00,-25000.00,-15000.00,-10000.00,0.00,0.00,0.00,'eyJpdiI6IjFjRjUzWlp5Uy9ZYzZUcDZya2hhQWc9PSIsInZhbHVlIjoiNXZ4VEJ1MXBKUXhMbTJlNjBUT0hleVE4NU14TFdTZFUxUUUrZXhtRmJFWldrOGhVMlNkY1FFTlVGeHRQWDdIVGhncUdHd1pXLzhsL09DV3JISkdhT0xDUkMrZzFKU3ZET0FROUZML2N3UTF3UDdERmE5SmhWTGxpWmlPYk5lMllUbW1vNzR5dmcwS2x3b3BiYUJKL3pMTUdtUkNBblJMM0RoUlhXNDZDVE5tTTNBV0IwcEQzanRvWTJ2VllJbk84OFJOUkIxVDNOYjVEeG80WERnUzdmeit3REw4VnhKUG93dzcrdVVXdCtvTT0iLCJtYWMiOiJkMzI3NDllYmI0ZjI2MTQ3NTE3ODJmMGJmZDg5MjgzODE5YzU0NWQzMjk4ZjlhN2MzMGExYzZhYmFiOTNhNGFiIiwidGFnIjoiIn0=','QA browser: pembalikan penjualan pengujian',13,'2026-09-18 08:44:34','2026-09-18 08:44:34',NULL,NULL,NULL,NULL,NULL),(16,'STOCK/CB02/202609/000001','ae7b4bdf-f622-4257-9910-5694150a7b90','fbf16a0b87a8d675fc354f48056e49f87ddf8064d47dd76a70bd0b6491d2a214',3,4,NULL,NULL,NULL,'stock_adjustment','completed',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'eyJpdiI6IjVhY3RrZy9sang2ODZyeTU3cHA4M1E9PSIsInZhbHVlIjoibUYrMXRYWkx5RGtJRi9NOG84RjJFbTJxdWY0Z2ZCdm0wRC9mSFUzeWJxWTJEMHJXaGJKOFdPMWZGTFMyWDYrY0pCQ3NzNVB6ejFseEx1d0w3OWFHdzFlTG44aUF2NkxjdzdNUEFlaTU0Z1I5OU9NRUwvNXpEUjlwazczOXZhMXh6Syt5V1FiU3BKYlVlc0xSMWVlMTFJdTlhWFNQNnFqYVAzUjUvN2R6WFhlWkV1VTN2WW9SVVFza1BNOXZBUml6Q3lNeERtYWhZdzRHOEN2cFVmOFEzWmVkdDZLeWxwOWxRZ3J4bG9QYkRUVndkSGJSV3I5b28rdnJvdldLK3lLSiIsIm1hYyI6IjE1NzY0NDVjNGVmYTA4OTFlNmY4OGNjOTc5MWM2NWRjNzBhMDNhOTBkYjgwOGZlYWUwZWZlYjhlNjIyMDU3MzkiLCJ0YWciOiIifQ==','asd',NULL,'2026-09-18 08:59:23','2026-09-18 08:59:23',NULL,NULL,NULL,NULL,NULL),(18,'TRX/CB02/202609/000001','be38233d-eaa9-40fb-a840-701654ea4e72','9947bd545f5efa8f77deef2275c4e46d73e78bc34bc04b7b8d084356c1b3a01f',3,7,NULL,NULL,4,'sale','completed',110000.00,0.00,110000.00,70000.00,40000.00,150000.00,40000.00,0.00,'eyJpdiI6IjA0Ym1maCt5M3c2eld1bWk0dzNJRVE9PSIsInZhbHVlIjoiQ1V3TVNZV1ZDa05nNndzdWsrZFF6VzI2YThBeCt5N3NGL1EyMVBic1RaRTZNeFEwMy9Ya283c1RuRlBvbVBYMkt2R2hzNWZwcHZEd0VxMUVTN1ZqbW5Qcy9iRHBDREFCQXlwaHRGdXVGSUxkTCtUWVZsRGtBOTIvNklGV2lkSFBpSFYrdUY2ZWdNcGdQbmNGZVlVdjBaT081M1hsTmlIc0FNNko1VFd4ZjZ4RStWYlp3aDhXS0doTDRqSmZQOEtKUHQxVDlVVGZqWW9TQ2l1ZVFYRU4xbHBNV003RUtwVVpreEY2d3ZBZHF6SjNoRnFCajc2WXpwUEl3cmYwcXgrdyIsIm1hYyI6IjVlODVmYjU4NzE5N2EwNzY0MTVmZmEwNGEzMTVlNWFlOTNiNzZhNzE4NmVkYTNlYzhjZjE0NmVkN2JlMjdjMjYiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 09:04:58','2026-09-18 09:04:58',NULL,NULL,NULL,NULL,NULL),(19,'CASHOUT/CB02/202609/000001','6bf7a9ad-5750-4f21-b4ea-1a598bccb924','71120a0bb7e8efdddf8dba41304ce569cb795dd9b8c3182d71465931386bdfd1',3,7,NULL,NULL,4,'cash_withdrawal','completed',100000.00,10000.00,10000.00,0.00,10000.00,0.00,0.00,0.00,'eyJpdiI6IjEwQkt6WVU4d3BNNUxpR2Z3bng3OWc9PSIsInZhbHVlIjoiUGNmdVRyckY5TjJvTDR4eW1XKzlYdC9KTFlXbDRwS3lkeTJmSkdkT1htZElVMGNnLzZMMm4rMnJIeEQ0V3NySmxOVlVZQ0s1WXZ5bHpyWXdiTW84NjJHRzdBYzdNek5MOVUzRXZHTitpQnJRYVAwUEFPeDB0Zk5NU1JocWZONU1aMkQ5TTI3WXo3NHZka1piWWFjcldmVDFGdVpHemNXdlkrRU5qSk1IeEZwU3JDSll3dnJMTmh2OEw4WXhTVjRwSWc1bzdBc3BHZ3ptTHF6S0NBZThEbDFadm5veDdFcFB0NXhxSFBNQ2VuV1B1djZreG81MlhPZ0l6TkJTYmlZQiIsIm1hYyI6IjIwMjEzODFkMTFlYjQ1MDIyNmU0NjBmZDc3NGM2MThkNzcxNmNjZjA4MTg0NjQ5Y2M1OTJiOGVkMmFlMGExMTIiLCJ0YWciOiIifQ==',NULL,NULL,'2026-09-18 09:08:08','2026-09-18 09:08:08',NULL,NULL,NULL,NULL,NULL),(20,'TRANSFER/CB02/202609/000001','fb5bc7e7-9a69-4518-a787-5fcb77390dee','f78298ed553daa9620f540cf6d41a94b466d2bc7dac0f0e9981bc8f5669e23a8',3,7,NULL,NULL,4,'money_transfer','completed',100000.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'eyJpdiI6IkFtUlEvaklPa2o5emNnVHlVeVhlWFE9PSIsInZhbHVlIjoiNkI0cFltUEEwUldsK3BvWlBIQnR0TnFlV0tQWElhcUZ6bFppVjkwU0RHUlhzN3FFdkY1RlI5M1pLallySW93OUNJWGJjTzBYQU0rRWlvV0Y5VEcxTnU3M2N0OUh4L3VDZnZ0TUNYMk8yNkxOWjE5TTV2TGZES1EzRVVUaTdqcDk4RE5uN01rMldXeU9xZW11TmxwOThyUXJpdFloY0FTYWVXMXd2bmRXOWhyM3BrN0ZjcmtWbTJPU1QrSkJJSmpBU3IvREtpU0IzelVBSEF6b1ZJTlVoc0YzVGsveDc3RVBsS0M0ZVRjQW5MZDBJblZHUG9DVzMveStxOVlCbVdrQTN2NHZMUGovMU01ZFd6QjlRTkl6b002cGxDYU1ybmNvbGFreHJzdkE4ci82SVdiTERUWkFqK2d5aDJ6THplNEQxSlVacVNpVEI0OWJRYXN0c2piSkI1Wkg0SllBK01mdnkyTEFIVVdzOG52VW52Z1lkQnptL2Z0cllVR0c2OUZ2IiwibWFjIjoiYzQzZTc5ZTY1ZjcxZDFkMjdmY2MyNzU2YjU5Mjg3MmZjOWI2N2VkNjI4OTdiNTY4ZjY1ZjQ0ZmEzNzdjYjNlMiIsInRhZyI6IiJ9',NULL,NULL,'2026-09-18 09:10:03','2026-09-18 09:10:03',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `units_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (1,'PCS',1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_branches`
--

DROP TABLE IF EXISTS `user_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_branches` (
  `user_id` bigint(20) unsigned NOT NULL,
  `branch_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`branch_id`),
  KEY `user_branches_branch_id_foreign` (`branch_id`),
  CONSTRAINT `user_branches_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `user_branches_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_branches`
--

LOCK TABLES `user_branches` WRITE;
/*!40000 ALTER TABLE `user_branches` DISABLE KEYS */;
INSERT INTO `user_branches` VALUES (4,2),(5,2),(6,2),(7,3);
/*!40000 ALTER TABLE `user_branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role_id` bigint(20) unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (4,'Owner','owner@aspsmart.local',NULL,'$2y$12$7nmN1v0TzlPIE01zXPXO..Xa6cLlPbxzq/Mj5RJYetM1IGWwPyNt.',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',7,1,NULL),(5,'Administrator','admin@aspsmart.local',NULL,'$2y$12$I.eqph11kBQB30yCEMMuLedMiKWHko0PWSUYqH/LfaYWKG3zV3v4e',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',8,1,NULL),(6,'Kasir','cashier@aspsmart.local',NULL,'$2y$12$W8QPEsQNpC.OlULvPyLmSOmeFcSbuJXPHjbbjhvxDoSVrnhze9fQ2',NULL,'2026-09-18 03:17:05','2026-09-18 03:17:05',10,1,NULL),(7,'Ilham','scammer@gmail.com',NULL,'$2y$12$5j1s7TXfNsEx0g.3eV6Q6uFfS79pc0GISzgjKHPWCo47yMcRQrFwS',NULL,'2026-09-18 08:57:02','2026-09-18 08:57:02',10,1,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `website_sections`
--

DROP TABLE IF EXISTS `website_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `website_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `subtitle` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `website_sections`
--

LOCK TABLES `website_sections` WRITE;
/*!40000 ALTER TABLE `website_sections` DISABLE KEYS */;
INSERT INTO `website_sections` VALUES (1,'about','Tentang kami',NULL,'Layanan personal untuk kebutuhan digital Anda.',NULL,1,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(2,'services','Layanan counter',NULL,'Pulsa • Paket data • Token PLN • Transfer • Tarik tunai • Aksesoris',NULL,1,1,'2026-09-18 03:17:05','2026-09-18 03:17:05'),(3,'hours','Jam operasional',NULL,'Hubungi cabang untuk memastikan jam operasional.',NULL,1,1,'2026-09-18 03:17:05','2026-09-18 03:17:05');
/*!40000 ALTER TABLE `website_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'asp_smartDb'
--

--
-- Dumping routines for database 'asp_smartDb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-19  9:15:21
