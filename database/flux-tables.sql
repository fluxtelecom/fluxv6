/*
 Navicat Premium Data Transfer

 Source Server         : Flux - Dev - root
 Source Server Type    : MySQL
 Source Server Version : 80033
 Source Host           : localhost:3306
 Source Schema         : flux-new

 Target Server Type    : MySQL
 Target Server Version : 80033
 File Encoding         : 65001

 Date: 11/05/2023 16:56:20
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


DROP TABLE IF EXISTS `aliases`;
CREATE TABLE `aliases`  (
  `sticky` int(0) NULL DEFAULT NULL,
  `alias` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `command` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `alias1`(`alias`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for automated_reports
-- ----------------------------
DROP TABLE IF EXISTS `automated_reports`;
CREATE TABLE `automated_reports`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `report_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `account_email` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `report_interval_days` tinyint(1) NOT NULL,
  `report_interval_recurring` tinyint(1) NOT NULL,
  `interval_frequency_on` tinyint(1) NOT NULL,
  `filters_where` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `select_names` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `module` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `select_values` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `creation_date` datetime(0) NOT NULL,
  `last_modified_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint(1) NOT NULL,
  `week_day` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `automated_report_value` tinyint(1) NOT NULL,
  `next_execution_date` date NOT NULL DEFAULT '0000-00-00',
  `update_flag` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for calls
-- ----------------------------
DROP TABLE IF EXISTS `calls`;
CREATE TABLE `calls`  (
  `call_uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_created` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_created_epoch` int(0) NULL DEFAULT NULL,
  `caller_uuid` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `callee_uuid` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `callsidx1`(`hostname`) USING BTREE,
  INDEX `eruuindex`(`caller_uuid`, `hostname`) USING BTREE,
  INDEX `eeuuindex`(`callee_uuid`) USING BTREE,
  INDEX `eeuuindex2`(`call_uuid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for channels
-- ----------------------------
DROP TABLE IF EXISTS `channels`;
CREATE TABLE `channels`  (
  `uuid` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `direction` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_epoch` int(0) NULL DEFAULT NULL,
  `name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `state` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `cid_name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `cid_num` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ip_addr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `dest` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `application` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `application_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `dialplan` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `context` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `read_codec` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `read_rate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `read_bit_rate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `write_codec` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `write_rate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `write_bit_rate` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `secure` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_id` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accountcode` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `callstate` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `callee_name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `callee_num` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `callee_direction` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_uuid` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sent_callee_name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sent_callee_num` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_cid_name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_cid_num` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_ip_addr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_dest` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_dialplan` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `initial_context` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `chidx1`(`hostname`) USING BTREE,
  INDEX `uuindex`(`uuid`, `hostname`) USING BTREE,
  INDEX `uuindex2`(`call_uuid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for complete
-- ----------------------------
DROP TABLE IF EXISTS `complete`;
CREATE TABLE `complete`  (
  `sticky` int(0) NULL DEFAULT NULL,
  `a1` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a2` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a3` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a4` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a5` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a6` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a7` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a8` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a9` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `a10` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `complete1`(`a1`, `hostname`) USING BTREE,
  INDEX `complete2`(`a2`, `hostname`) USING BTREE,
  INDEX `complete3`(`a3`, `hostname`) USING BTREE,
  INDEX `complete4`(`a4`, `hostname`) USING BTREE,
  INDEX `complete5`(`a5`, `hostname`) USING BTREE,
  INDEX `complete6`(`a6`, `hostname`) USING BTREE,
  INDEX `complete7`(`a7`, `hostname`) USING BTREE,
  INDEX `complete8`(`a8`, `hostname`) USING BTREE,
  INDEX `complete9`(`a9`, `hostname`) USING BTREE,
  INDEX `complete10`(`a10`, `hostname`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for counters_trigger
-- ----------------------------
DROP TABLE IF EXISTS `counters_trigger`;
CREATE TABLE `counters_trigger`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `product_id` int(0) NOT NULL DEFAULT 0,
  `package_id` int(0) NOT NULL DEFAULT 0,
  `accountid` int(0) NOT NULL DEFAULT 0,
  `used_seconds` int(0) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `type` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `package_id`(`product_id`) USING BTREE,
  INDEX `accountid`(`accountid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for db_data
-- ----------------------------
DROP TABLE IF EXISTS `db_data`;
CREATE TABLE `db_data`  (
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `realm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `data_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  UNIQUE INDEX `dd_data_key_realm`(`data_key`, `realm`) USING BTREE,
  INDEX `dd_realm`(`realm`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `email_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `password` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `admin_id_list` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sub_admin_id_list` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `additional_email_address` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `smtp_host` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `smtp_port` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `smtp_user` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `smtp_password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `reseller_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for dialer_device_info
-- ----------------------------
DROP TABLE IF EXISTS `dialer_device_info`;
CREATE TABLE `dialer_device_info`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `accountid` int(0) NOT NULL,
  `username` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `last_login_date` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for did_hg_types
-- ----------------------------
DROP TABLE IF EXISTS `did_hg_types`;
CREATE TABLE `did_hg_types`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `hg_type_code` tinyint(1) NOT NULL DEFAULT 0,
  `hg_type` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

INSERT INTO `did_hg_types`(`id`, `hg_type_code`, `hg_type`) VALUES (1, 0, 'Sequencial');
INSERT INTO `did_hg_types`(`id`, `hg_type_code`, `hg_type`) VALUES (2, 1, 'Simultaneo');

-- ----------------------------
-- Table structure for did_reverse_rate
-- ----------------------------
DROP TABLE IF EXISTS `did_reverse_rate`;
CREATE TABLE `did_reverse_rate`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `reverse_rate_code` tinyint(1) NOT NULL DEFAULT 0,
  `reverse_rate` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for domain
-- ----------------------------
DROP TABLE IF EXISTS `domain`;
CREATE TABLE `domain`  (
  `id` int(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `domain` char(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `last_modified` datetime(0) NOT NULL DEFAULT '1900-01-01 00:00:01',
  `music_on_hold` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `tech_prefix` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `external_extension` tinyint(1) NOT NULL DEFAULT 0,
  `external_server` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `use_alternative_softswitch` tinyint(1) NOT NULL DEFAULT 0,
  `alternative_softswitch` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `logo_url` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `max_extensions` int(0) NULL DEFAULT NULL,
  `allowed_origin` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT 'BR',
  `allowed_destination` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT 'BR',
  `domain_description` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `creation_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `domain_idx`(`domain`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci;

-- ----------------------------
-- Table structure for domains
-- ----------------------------
DROP TABLE IF EXISTS `domains`;
CREATE TABLE `domains`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `domain` varchar(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `tech_prefix` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `api_token` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `allowed_origin` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT 'BR',
  `allowed_destination` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT 'BR',
  `accountid` int(0) NULL DEFAULT NULL,
  `status` varchar(1) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `reseller_id` int(0) NOT NULL DEFAULT 0,
  `domain_description` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `last_modified` datetime(0) NOT NULL DEFAULT '1900-01-01 00:00:01',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `domain_id`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci;

-- ----------------------------
-- Table structure for domains_to_accounts
-- ----------------------------
DROP TABLE IF EXISTS `domains_to_accounts`;
CREATE TABLE `domains_to_accounts`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `accountid` int(0) NOT NULL DEFAULT 0,
  `domain_id` int(0) NOT NULL DEFAULT 0,
  `assign_date` datetime(0) NOT NULL DEFAULT '1000-01-01 00:00:00',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `accountid`(`accountid`) USING BTREE,
  INDEX `domain_id`(`domain_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for group_data
-- ----------------------------
DROP TABLE IF EXISTS `group_data`;
CREATE TABLE `group_data`  (
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `groupname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `gd_groupname`(`groupname`) USING BTREE,
  INDEX `gd_url`(`url`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for interfaces
-- ----------------------------
DROP TABLE IF EXISTS `interfaces`;
CREATE TABLE `interfaces`  (
  `type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `name` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `description` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ikey` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `filename` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `syntax` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for limit_data
-- ----------------------------
DROP TABLE IF EXISTS `limit_data`;
CREATE TABLE `limit_data`  (
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `realm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `ld_hostname`(`hostname`) USING BTREE,
  INDEX `ld_uuid`(`uuid`) USING BTREE,
  INDEX `ld_realm`(`realm`) USING BTREE,
  INDEX `ld_id`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for local_number
-- ----------------------------
DROP TABLE IF EXISTS `local_number`;
CREATE TABLE `local_number`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `reseller_id` int(0) NOT NULL DEFAULT 0,
  `number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `country_id` int(0) NOT NULL,
  `province` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL COMMENT '0:active,1:inactive',
  `created_date` datetime(0) NOT NULL,
  `last_modified_date` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for local_number_destination
-- ----------------------------
DROP TABLE IF EXISTS `local_number_destination`;
CREATE TABLE `local_number_destination`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `local_number_id` int(0) NOT NULL DEFAULT 0,
  `account_id` int(0) NOT NULL DEFAULT 0,
  `destination_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `destination_number` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `creation_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_modified_date` datetime(0) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for log_cron
-- ----------------------------
DROP TABLE IF EXISTS `log_cron`;
CREATE TABLE `log_cron`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `accountid` int(0) NULL DEFAULT NULL,
  `invoiceid` int(0) NULL DEFAULT NULL,
  `date` datetime(0) NULL DEFAULT NULL,
  `log` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `query` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for order_items_trigger
-- ----------------------------
DROP TABLE IF EXISTS `order_items_trigger`;
CREATE TABLE `order_items_trigger`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_id` int(0) NOT NULL,
  `product_category` int(0) NOT NULL,
  `product_id` int(0) NOT NULL,
  `quantity` int(0) NOT NULL DEFAULT 1,
  `price` decimal(10, 5) NOT NULL DEFAULT 0.00000,
  `setup_fee` decimal(10, 5) NOT NULL DEFAULT 0.00000,
  `billing_type` int(0) NOT NULL,
  `billing_days` int(0) NOT NULL DEFAULT 0,
  `free_minutes` int(0) NOT NULL DEFAULT 0,
  `accountid` int(0) NOT NULL,
  `reseller_id` int(0) NOT NULL,
  `billing_date` datetime(0) NOT NULL,
  `next_billing_date` datetime(0) NOT NULL,
  `is_terminated` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 FOR NO AND 1 FOR YES',
  `termination_date` datetime(0) NOT NULL,
  `termination_note` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `from_currency` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `exchange_rate` decimal(10, 5) NOT NULL DEFAULT 1.00000,
  `to_currency` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for pbx_conference_specification
-- ----------------------------
DROP TABLE IF EXISTS `pbx_conference_specification`;
CREATE TABLE `pbx_conference_specification`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accountid` int(0) NULL DEFAULT NULL,
  `reseller_id` int(0) NULL DEFAULT NULL,
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NULL DEFAULT NULL,
  `last_modified_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for pbx_ivr_specification
-- ----------------------------
DROP TABLE IF EXISTS `pbx_ivr_specification`;
CREATE TABLE `pbx_ivr_specification`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accountid` int(0) NULL DEFAULT NULL,
  `reseller_id` int(0) NULL DEFAULT NULL,
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NULL DEFAULT NULL,
  `last_modified_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for pbx_queue
-- ----------------------------
DROP TABLE IF EXISTS `pbx_queue`;
CREATE TABLE `pbx_queue`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accountid` int(0) NULL DEFAULT NULL,
  `reseller_id` int(0) NULL DEFAULT NULL,
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NULL DEFAULT NULL,
  `last_modified_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for pbx_recording
-- ----------------------------
DROP TABLE IF EXISTS `pbx_recording`;
CREATE TABLE `pbx_recording`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accountid` int(0) NULL DEFAULT NULL,
  `reseller_id` int(0) NULL DEFAULT NULL,
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NULL DEFAULT NULL,
  `last_modified_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for permissions_types
-- ----------------------------
DROP TABLE IF EXISTS `permissions_types`;
CREATE TABLE `permissions_types`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `permission_type_code` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `permission_name` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `reseller_id` int(0) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '\'0 for active,1 for inactive\'',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for permissionsv6
-- ----------------------------
DROP TABLE IF EXISTS `permissionsv6`;
CREATE TABLE `permissionsv6`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `reseller_id` int(0) NOT NULL DEFAULT 0,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `login_type` tinyint(1) NOT NULL DEFAULT 0,
  `permissions` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `edit_permissions` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `creation_date` datetime(0) NOT NULL,
  `modification_date` datetime(0) NOT NULL DEFAULT '1000-01-01 00:00:00',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for query_planos
-- ----------------------------
DROP TABLE IF EXISTS `query_planos`;
CREATE TABLE `query_planos`  (
  `id_pedido` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id_cliente` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `empresa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `dia_fatura` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ultima_cobranca` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id_produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `pedido_dias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `produto_dias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `minutos_gratuitos_pedido` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `minutos_gratuitos_produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status_pedido` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `data_encerramento` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `valor_pedido` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `valor_produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `tipo_produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status_produto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `produto_removido` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for recovery
-- ----------------------------
DROP TABLE IF EXISTS `recovery`;
CREATE TABLE `recovery`  (
  `runtime_uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `technology` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `metadata` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  INDEX `recovery1`(`technology`) USING BTREE,
  INDEX `recovery2`(`profile_name`) USING BTREE,
  INDEX `recovery3`(`uuid`) USING BTREE,
  INDEX `recovery4`(`runtime_uuid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for registrations
-- ----------------------------
DROP TABLE IF EXISTS `registrations`;
CREATE TABLE `registrations`  (
  `reg_user` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `realm` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `token` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `expires` int(0) NULL DEFAULT NULL,
  `network_ip` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_port` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_proto` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `metadata` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `regindex1`(`reg_user`, `realm`, `hostname`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for roles_and_permission_v1
-- ----------------------------
DROP TABLE IF EXISTS `roles_and_permission_v1`;
CREATE TABLE `roles_and_permission_v1`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `login_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Admin,1:Reseller',
  `permission_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Main,1:Edit',
  `menu_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `module_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sub_module_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `module_url` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `permissions` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NOT NULL DEFAULT '1000-01-01 00:00:00',
  `priority` decimal(10, 5) NOT NULL DEFAULT 0.00000,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for roles_and_permission_v6
-- ----------------------------
DROP TABLE IF EXISTS `roles_and_permission_v6`;
CREATE TABLE `roles_and_permission_v6`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `login_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Admin,1:Reseller',
  `permission_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Main,1:Edit',
  `menu_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `module_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sub_module_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `module_url` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `permissions` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NOT NULL DEFAULT '1000-01-01 00:00:00',
  `priority` decimal(10, 5) NOT NULL DEFAULT 0.00000,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for sip_authentication
-- ----------------------------
DROP TABLE IF EXISTS `sip_authentication`;
CREATE TABLE `sip_authentication`  (
  `nonce` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `expires` bigint(0) NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `last_nc` int(0) NULL DEFAULT NULL,
  `algorithm` int(0) NOT NULL DEFAULT 1,
  INDEX `sa_nonce`(`nonce`) USING BTREE,
  INDEX `sa_hostname`(`hostname`) USING BTREE,
  INDEX `sa_expires`(`expires`) USING BTREE,
  INDEX `sa_last_nc`(`last_nc`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_device_routing
-- ----------------------------
DROP TABLE IF EXISTS `sip_device_routing`;
CREATE TABLE `sip_device_routing`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `sip_device_id` int(0) NOT NULL DEFAULT 0,
  `call_forwarding_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0:Enable,1:Disable',
  `call_forwarding_destination` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `on_busy_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0:Enable,1:Disable',
  `on_busy_destination` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `no_answer_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0:Enable,1:Disable',
  `no_answer_destination` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `not_register_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0:Enable,1:Disable',
  `not_register_destination` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `is_recording` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for sip_dialogs
-- ----------------------------
DROP TABLE IF EXISTS `sip_dialogs`;
CREATE TABLE `sip_dialogs`  (
  `call_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_to_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_to_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_from_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_from_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `direction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_info_state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `expires` bigint(0) NULL DEFAULT 0,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `rpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_to_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_from_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `rcd` int(0) NOT NULL DEFAULT 0,
  INDEX `sd_uuid`(`uuid`) USING BTREE,
  INDEX `sd_hostname`(`hostname`) USING BTREE,
  INDEX `sd_presence_data`(`presence_data`) USING BTREE,
  INDEX `sd_call_info`(`call_info`) USING BTREE,
  INDEX `sd_call_info_state`(`call_info_state`) USING BTREE,
  INDEX `sd_expires`(`expires`) USING BTREE,
  INDEX `sd_rcd`(`rcd`) USING BTREE,
  INDEX `sd_sip_to_tag`(`sip_to_tag`) USING BTREE,
  INDEX `sd_sip_from_user`(`sip_from_user`) USING BTREE,
  INDEX `sd_sip_from_host`(`sip_from_host`) USING BTREE,
  INDEX `sd_sip_to_host`(`sip_to_host`) USING BTREE,
  INDEX `sd_presence_id`(`presence_id`) USING BTREE,
  INDEX `sd_call_id`(`call_id`) USING BTREE,
  INDEX `sd_sip_from_tag`(`sip_from_tag`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_presence
-- ----------------------------
DROP TABLE IF EXISTS `sip_presence`;
CREATE TABLE `sip_presence`  (
  `sip_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `rpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `expires` bigint(0) NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_port` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `open_closed` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `sp_hostname`(`hostname`) USING BTREE,
  INDEX `sp_open_closed`(`open_closed`) USING BTREE,
  INDEX `sp_sip_user`(`sip_user`) USING BTREE,
  INDEX `sp_sip_host`(`sip_host`) USING BTREE,
  INDEX `sp_profile_name`(`profile_name`) USING BTREE,
  INDEX `sp_expires`(`expires`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_registrations
-- ----------------------------
DROP TABLE IF EXISTS `sip_registrations`;
CREATE TABLE `sip_registrations`  (
  `call_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_hosts` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ping_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `ping_count` int(0) NULL DEFAULT NULL,
  `ping_time` bigint(0) NULL DEFAULT NULL,
  `force_ping` int(0) NULL DEFAULT NULL,
  `rpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `expires` bigint(0) NULL DEFAULT NULL,
  `ping_expires` int(0) NOT NULL DEFAULT 0,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `server_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_port` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_realm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `mwi_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `mwi_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `orig_server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `orig_hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sub_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `sr_call_id`(`call_id`) USING BTREE,
  INDEX `sr_sip_user`(`sip_user`) USING BTREE,
  INDEX `sr_sip_host`(`sip_host`) USING BTREE,
  INDEX `sr_sub_host`(`sub_host`) USING BTREE,
  INDEX `sr_mwi_user`(`mwi_user`) USING BTREE,
  INDEX `sr_mwi_host`(`mwi_host`) USING BTREE,
  INDEX `sr_profile_name`(`profile_name`) USING BTREE,
  INDEX `sr_presence_hosts`(`presence_hosts`) USING BTREE,
  INDEX `sr_contact`(`contact`(768)) USING BTREE,
  INDEX `sr_expires`(`expires`) USING BTREE,
  INDEX `sr_ping_expires`(`ping_expires`) USING BTREE,
  INDEX `sr_hostname`(`hostname`) USING BTREE,
  INDEX `sr_status`(`status`) USING BTREE,
  INDEX `sr_ping_status`(`ping_status`) USING BTREE,
  INDEX `sr_network_ip`(`network_ip`) USING BTREE,
  INDEX `sr_network_port`(`network_port`) USING BTREE,
  INDEX `sr_sip_username`(`sip_username`) USING BTREE,
  INDEX `sr_sip_realm`(`sip_realm`) USING BTREE,
  INDEX `sr_orig_server_host`(`orig_server_host`) USING BTREE,
  INDEX `sr_orig_hostname`(`orig_hostname`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_shared_appearance_dialogs
-- ----------------------------
DROP TABLE IF EXISTS `sip_shared_appearance_dialogs`;
CREATE TABLE `sip_shared_appearance_dialogs`  (
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_str` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `expires` bigint(0) NULL DEFAULT NULL,
  INDEX `ssd_profile_name`(`profile_name`) USING BTREE,
  INDEX `ssd_hostname`(`hostname`) USING BTREE,
  INDEX `ssd_contact_str`(`contact_str`) USING BTREE,
  INDEX `ssd_call_id`(`call_id`) USING BTREE,
  INDEX `ssd_expires`(`expires`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_shared_appearance_subscriptions
-- ----------------------------
DROP TABLE IF EXISTS `sip_shared_appearance_subscriptions`;
CREATE TABLE `sip_shared_appearance_subscriptions`  (
  `subscriber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `aor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_str` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `ssa_hostname`(`hostname`) USING BTREE,
  INDEX `ssa_network_ip`(`network_ip`) USING BTREE,
  INDEX `ssa_subscriber`(`subscriber`) USING BTREE,
  INDEX `ssa_profile_name`(`profile_name`) USING BTREE,
  INDEX `ssa_aor`(`aor`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sip_subscriptions
-- ----------------------------
DROP TABLE IF EXISTS `sip_subscriptions`;
CREATE TABLE `sip_subscriptions`  (
  `proto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sip_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sub_to_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sub_to_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `presence_hosts` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `event` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `call_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `full_from` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `full_via` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `expires` bigint(0) NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `accept` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_port` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `network_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `version` int(0) NOT NULL DEFAULT 0,
  `orig_proto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `full_to` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `ss_call_id`(`call_id`) USING BTREE,
  INDEX `ss_multi`(`call_id`, `profile_name`, `hostname`) USING BTREE,
  INDEX `ss_hostname`(`hostname`) USING BTREE,
  INDEX `ss_network_ip`(`network_ip`) USING BTREE,
  INDEX `ss_sip_user`(`sip_user`) USING BTREE,
  INDEX `ss_sip_host`(`sip_host`) USING BTREE,
  INDEX `ss_presence_hosts`(`presence_hosts`) USING BTREE,
  INDEX `ss_event`(`event`) USING BTREE,
  INDEX `ss_proto`(`proto`) USING BTREE,
  INDEX `ss_sub_to_user`(`sub_to_user`) USING BTREE,
  INDEX `ss_sub_to_host`(`sub_to_host`) USING BTREE,
  INDEX `ss_expires`(`expires`) USING BTREE,
  INDEX `ss_orig_proto`(`orig_proto`) USING BTREE,
  INDEX `ss_network_port`(`network_port`) USING BTREE,
  INDEX `ss_profile_name`(`profile_name`) USING BTREE,
  INDEX `ss_version`(`version`) USING BTREE,
  INDEX `ss_full_from`(`full_from`) USING BTREE,
  INDEX `ss_contact`(`contact`(768)) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for sms_pricelists
-- ----------------------------
DROP TABLE IF EXISTS `sms_pricelists`;
CREATE TABLE `sms_pricelists`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '',
  `markup` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '0',
  `routing_type` tinyint(1) NOT NULL DEFAULT 0,
  `initially_increment` int(0) NOT NULL,
  `inc` int(0) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 for active,1 for inactive,2 for delete',
  `reseller_id` int(0) NOT NULL DEFAULT 0 COMMENT 'Accounts table id',
  `pricelist_id_admin` int(0) NOT NULL DEFAULT 0,
  `routing_prefix` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `call_count` int(0) NOT NULL DEFAULT 0,
  `creation_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_modified_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `name`(`name`) USING BTREE,
  INDEX `reseller_id`(`reseller_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for support_ticket
-- ----------------------------
DROP TABLE IF EXISTS `support_ticket`;
CREATE TABLE `support_ticket`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `support_ticket_number` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '0',
  `ticket_type` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '0',
  `priority` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '0',
  `accountid` int(0) NOT NULL,
  `reseller_id` int(0) NOT NULL,
  `subject` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `creation_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_modified_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `department_id` int(0) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `close_ticket_display_flag` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for support_ticket_details
-- ----------------------------
DROP TABLE IF EXISTS `support_ticket_details`;
CREATE TABLE `support_ticket_details`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `support_ticket_id` int(0) NOT NULL,
  `generate_account_id` int(0) NOT NULL,
  `message` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `attachment` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `creation_date` datetime(0) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `last_modified_date` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for tasks
-- ----------------------------
DROP TABLE IF EXISTS `tasks`;
CREATE TABLE `tasks`  (
  `task_id` int(0) NULL DEFAULT NULL,
  `task_desc` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `task_group` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `task_runtime` bigint(0) NULL DEFAULT NULL,
  `task_sql_manager` int(0) NULL DEFAULT NULL,
  `hostname` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  INDEX `tasks1`(`hostname`, `task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for time_condition
-- ----------------------------
DROP TABLE IF EXISTS `time_condition`;
CREATE TABLE `time_condition`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `strategy` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `destinations` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `reseller_id` int(0) NOT NULL,
  `accountid` int(0) NOT NULL,
  `no_answer_call_type` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `no_answer_call_type_value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:Active,1:Inactive',
  `creation_date` datetime(0) NOT NULL,
  `last_modified_date` datetime(0) NOT NULL DEFAULT '2022-01-01 00:00:00',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Table structure for userlevels_permissions
-- ----------------------------
DROP TABLE IF EXISTS `userlevels_permissions`;
CREATE TABLE `userlevels_permissions`  (
  `userlevelid` int(0) NOT NULL,
  `userlevelname` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `module_permissions` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`userlevelid`) USING BTREE,
  INDEX `userlevelname`(`userlevelname`) USING BTREE,
  INDEX `module_permissions`(`module_permissions`(1024)) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- ----------------------------
-- Triggers structure for table order_items_trigger
-- ----------------------------
DROP TRIGGER IF EXISTS `Order1Trigger`;
delimiter ;;
CREATE DEFINER = `fluxuser`@`127.0.0.1` TRIGGER `Order1Trigger` AFTER INSERT ON `order_items_trigger` FOR EACH ROW begin
   insert into counters_trigger(product_id,package_id,accountid,used_seconds,status,type) values (new.product_id,new.order_id, new.accountid,0,1,1);
    end
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
