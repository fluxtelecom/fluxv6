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

 Date: 11/05/2023 13:29:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- View structure for view_devices
-- ----------------------------
DROP VIEW IF EXISTS `view_devices`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_devices` AS SELECT `dids`.`id` AS `id`, `dids`.`number` AS `number`, `sip_devices`.`id` AS `sip_device_id`, `dids`.`accountid` AS `account_id`, `dids`.`id` AS `did_id`, `sip_devices`.`reseller_id` AS `sip_devices_resseler` FROM `sip_devices` JOIN `dids` ON `dids`.`number` = `sip_devices`.`username` WHERE `dids`.`status` = 0 AND `sip_devices`.`status` = 0 ORDER BY `dids`.`id`;
-- ----------------------------
-- View structure for basic_calls
-- ----------------------------
DROP VIEW IF EXISTS `basic_calls`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `basic_calls` AS select `a`.`uuid` AS `uuid`,`a`.`direction` AS `direction`,`a`.`created` AS `created`,`a`.`created_epoch` AS `created_epoch`,`a`.`name` AS `name`,`a`.`state` AS `state`,`a`.`cid_name` AS `cid_name`,`a`.`cid_num` AS `cid_num`,`a`.`ip_addr` AS `ip_addr`,`a`.`dest` AS `dest`,`a`.`presence_id` AS `presence_id`,`a`.`presence_data` AS `presence_data`,`a`.`accountcode` AS `accountcode`,`a`.`callstate` AS `callstate`,`a`.`callee_name` AS `callee_name`,`a`.`callee_num` AS `callee_num`,`a`.`callee_direction` AS `callee_direction`,`a`.`call_uuid` AS `call_uuid`,`a`.`hostname` AS `hostname`,`a`.`sent_callee_name` AS `sent_callee_name`,`a`.`sent_callee_num` AS `sent_callee_num`,`b`.`uuid` AS `b_uuid`,`b`.`direction` AS `b_direction`,`b`.`created` AS `b_created`,`b`.`created_epoch` AS `b_created_epoch`,`b`.`name` AS `b_name`,`b`.`state` AS `b_state`,`b`.`cid_name` AS `b_cid_name`,`b`.`cid_num` AS `b_cid_num`,`b`.`ip_addr` AS `b_ip_addr`,`b`.`dest` AS `b_dest`,`b`.`presence_id` AS `b_presence_id`,`b`.`presence_data` AS `b_presence_data`,`b`.`accountcode` AS `b_accountcode`,`b`.`callstate` AS `b_callstate`,`b`.`callee_name` AS `b_callee_name`,`b`.`callee_num` AS `b_callee_num`,`b`.`callee_direction` AS `b_callee_direction`,`b`.`sent_callee_name` AS `b_sent_callee_name`,`b`.`sent_callee_num` AS `b_sent_callee_num`,`c`.`call_created_epoch` AS `call_created_epoch` from ((`channels` `a` left join `calls` `c` on(((`a`.`uuid` = `c`.`caller_uuid`) and (`a`.`hostname` = `c`.`hostname`)))) left join `channels` `b` on(((`b`.`uuid` = `c`.`callee_uuid`) and (`b`.`hostname` = `c`.`hostname`)))) where ((`a`.`uuid` = `c`.`caller_uuid`) or `a`.`uuid` in (select `calls`.`callee_uuid` from `calls`) is false);

-- ----------------------------
-- View structure for detailed_calls
-- ----------------------------
DROP VIEW IF EXISTS `detailed_calls`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `detailed_calls` AS select `a`.`uuid` AS `uuid`,`a`.`direction` AS `direction`,`a`.`created` AS `created`,`a`.`created_epoch` AS `created_epoch`,`a`.`name` AS `name`,`a`.`state` AS `state`,`a`.`cid_name` AS `cid_name`,`a`.`cid_num` AS `cid_num`,`a`.`ip_addr` AS `ip_addr`,`a`.`dest` AS `dest`,`a`.`application` AS `application`,`a`.`application_data` AS `application_data`,`a`.`dialplan` AS `dialplan`,`a`.`context` AS `context`,`a`.`read_codec` AS `read_codec`,`a`.`read_rate` AS `read_rate`,`a`.`read_bit_rate` AS `read_bit_rate`,`a`.`write_codec` AS `write_codec`,`a`.`write_rate` AS `write_rate`,`a`.`write_bit_rate` AS `write_bit_rate`,`a`.`secure` AS `secure`,`a`.`hostname` AS `hostname`,`a`.`presence_id` AS `presence_id`,`a`.`presence_data` AS `presence_data`,`a`.`accountcode` AS `accountcode`,`a`.`callstate` AS `callstate`,`a`.`callee_name` AS `callee_name`,`a`.`callee_num` AS `callee_num`,`a`.`callee_direction` AS `callee_direction`,`a`.`call_uuid` AS `call_uuid`,`a`.`sent_callee_name` AS `sent_callee_name`,`a`.`sent_callee_num` AS `sent_callee_num`,`b`.`uuid` AS `b_uuid`,`b`.`direction` AS `b_direction`,`b`.`created` AS `b_created`,`b`.`created_epoch` AS `b_created_epoch`,`b`.`name` AS `b_name`,`b`.`state` AS `b_state`,`b`.`cid_name` AS `b_cid_name`,`b`.`cid_num` AS `b_cid_num`,`b`.`ip_addr` AS `b_ip_addr`,`b`.`dest` AS `b_dest`,`b`.`application` AS `b_application`,`b`.`application_data` AS `b_application_data`,`b`.`dialplan` AS `b_dialplan`,`b`.`context` AS `b_context`,`b`.`read_codec` AS `b_read_codec`,`b`.`read_rate` AS `b_read_rate`,`b`.`read_bit_rate` AS `b_read_bit_rate`,`b`.`write_codec` AS `b_write_codec`,`b`.`write_rate` AS `b_write_rate`,`b`.`write_bit_rate` AS `b_write_bit_rate`,`b`.`secure` AS `b_secure`,`b`.`hostname` AS `b_hostname`,`b`.`presence_id` AS `b_presence_id`,`b`.`presence_data` AS `b_presence_data`,`b`.`accountcode` AS `b_accountcode`,`b`.`callstate` AS `b_callstate`,`b`.`callee_name` AS `b_callee_name`,`b`.`callee_num` AS `b_callee_num`,`b`.`callee_direction` AS `b_callee_direction`,`b`.`call_uuid` AS `b_call_uuid`,`b`.`sent_callee_name` AS `b_sent_callee_name`,`b`.`sent_callee_num` AS `b_sent_callee_num`,`c`.`call_created_epoch` AS `call_created_epoch` from ((`channels` `a` left join `calls` `c` on(((`a`.`uuid` = `c`.`caller_uuid`) and (`a`.`hostname` = `c`.`hostname`)))) left join `channels` `b` on(((`b`.`uuid` = `c`.`callee_uuid`) and (`b`.`hostname` = `c`.`hostname`)))) where ((`a`.`uuid` = `c`.`caller_uuid`) or `a`.`uuid` in (select `calls`.`callee_uuid` from `calls`) is false);

-- ----------------------------
-- View structure for packages_view
-- ----------------------------
DROP VIEW IF EXISTS `packages_view`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `packages_view` AS select `O`.`order_id` AS `id`,`P`.`id` AS `product_id`,`P`.`name` AS `package_name`,`O`.`free_minutes` AS `free_minutes`,(`O`.`free_minutes` * 60) AS `free_secs`,`P`.`applicable_for` AS `applicable_for`,`P`.`status` AS `status`,`P`.`price` AS `price`,`C`.`used_seconds` AS `counters_used_seconds`,`C`.`package_id` AS `counters_package_id`,`C`.`id` AS `counter_id`,`C`.`status` AS `counter_status`,round((`C`.`used_seconds` / 60),0) AS `counters_used_minutes`,`O`.`accountid` AS `accountid`,`O`.`is_terminated` AS `is_terminated` from ((`products` `P` join `order_items` `O`) join `counters` `C`) where ((`P`.`id` = `O`.`product_id`) and (`C`.`package_id` = `O`.`order_id`) and (`P`.`product_category` = 1) and (`P`.`status` = 0) and ((`O`.`termination_date` >= (utc_timestamp() - interval 1 month)) or (`O`.`termination_date` = '0000-00-00 00:00:00')));

-- ----------------------------
-- View structure for packages_view_copy1
-- ----------------------------
DROP VIEW IF EXISTS `packages_view_copy1`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `packages_view_copy1` AS select `O`.`order_id` AS `id`,`P`.`id` AS `product_id`,`P`.`name` AS `package_name`,`O`.`free_minutes` AS `free_minutes`,`P`.`applicable_for` AS `applicable_for`,`P`.`status` AS `status`,`P`.`price` AS `price`,`O`.`accountid` AS `accountid`,`O`.`is_terminated` AS `is_terminated` from (`products` `P` join `order_items` `O`) where ((`P`.`id` = `O`.`product_id`) and (`P`.`product_category` = 1) and (`P`.`status` = 0) and ((`O`.`termination_date` >= (utc_timestamp() - interval 1 month)) or (`O`.`termination_date` = '0000-00-00 00:00:00')));

-- ----------------------------
-- View structure for view_accounts_permissions
-- ----------------------------
DROP VIEW IF EXISTS `view_accounts_permissions`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_accounts_permissions` AS select `a`.`id` AS `account_id`,`a`.`number` AS `number`,`a`.`status` AS `status`,`a`.`first_name` AS `first_name`,`a`.`last_name` AS `last_name`,`a`.`company_name` AS `company_name`,`a`.`permission_id` AS `account_permission_id`,`a`.`country_id` AS `country_id`,`a`.`email` AS `email`,`a`.`telephone_1` AS `telephone_1`,`p`.`id` AS `permission_id`,`a`.`deleted` AS `deleted`,`a`.`type` AS `type`,`p`.`name` AS `name`,`p`.`id` AS `id`,`p`.`creation_date` AS `creation_date`,`p`.`description` AS `description`,`p`.`modification_date` AS `modification_date`,`p`.`reseller_id` AS `reseller_id`,`p`.`name` AS `permission_name`,`p`.`login_type` AS `login_type` from (`accounts` `a` join `permissions` `p`) where (`a`.`permission_id` = `p`.`id`);

-- ----------------------------
-- View structure for view_chamadas_destino
-- ----------------------------
DROP VIEW IF EXISTS `view_chamadas_destino`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_chamadas_destino` AS select `accounts`.`company_name` AS `empresa`,`cdrs`.`sip_user` AS `ramal`,`cdrs`.`callednum` AS `destino`,count(0) AS `qtd_chamadas`,`accounts`.`reseller_id` AS `revenda` from (`cdrs` join `accounts` on((`cdrs`.`accountid` = `accounts`.`id`))) where ((`cdrs`.`callstart` between (now() - interval 30 day) and now()) and (`cdrs`.`disposition` in ('ORIGINATOR_CANCEL [487]','NORMAL_CLEARING [16]'))) group by `destino`;

-- ----------------------------
-- View structure for view_chamadas_rota
-- ----------------------------
DROP VIEW IF EXISTS `view_chamadas_rota`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_chamadas_rota` AS select `accounts`.`company_name` AS `empresa`,`cdrs`.`notes` AS `tipo_chamada`,count(0) AS `qtd_chamadas`,`accounts`.`reseller_id` AS `revenda` from (`cdrs` join `accounts` on((`cdrs`.`accountid` = `accounts`.`id`))) where ((`cdrs`.`callstart` between (now() - interval 30 day) and now()) and (`cdrs`.`disposition` in ('ORIGINATOR_CANCEL [487]','NORMAL_CLEARING [16]'))) group by `empresa`;

-- ----------------------------
-- View structure for view_chamadas_sipuser
-- ----------------------------
DROP VIEW IF EXISTS `view_chamadas_sipuser`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_chamadas_sipuser` AS select `accounts`.`company_name` AS `empresa`,`cdrs`.`sip_user` AS `sip_device`,`cdrs`.`call_direction` AS `call_direction`,count(0) AS `qtd_chamadas`,round(sum(`cdrs`.`debit`),2) AS `valor_total`,sum(`cdrs`.`billseconds`) AS `total_secs`,`accounts`.`reseller_id` AS `revenda`,`accounts`.`id` AS `accountid` from (`accounts` join `cdrs` on((`accounts`.`id` = `cdrs`.`accountid`))) where (`cdrs`.`callstart` between (now() - interval 30 day) and now()) group by `accounts`.`company_name`,`cdrs`.`sip_user`;

-- ----------------------------
-- View structure for view_count_chamadas
-- ----------------------------
DROP VIEW IF EXISTS `view_count_chamadas`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_count_chamadas` AS select `accounts`.`company_name` AS `empresa`,count(0) AS `qtd_chamadas`,`accounts`.`reseller_id` AS `revenda`,`accounts`.`id` AS `cliente_id` from (`accounts` join `cdrs` on((`accounts`.`id` = `cdrs`.`accountid`))) where (`cdrs`.`callstart` between (now() - interval 30 day) and now()) group by `accounts`.`company_name`;

-- ----------------------------
-- View structure for view_dids
-- ----------------------------
DROP VIEW IF EXISTS `view_dids`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_dids` AS select `dids`.`id` AS `id`,`dids`.`number` AS `number`,`products`.`id` AS `reseller_product_id`,`dids`.`accountid` AS `account_id`,`products`.`reseller_id` AS `reseller_id`,if((`dids`.`parent_id` <> `products`.`created_by`),(select `dids`.`accountid` from `products` `dids` where (`dids`.`id` > `products`.`id`) order by `dids`.`id` limit 1),`dids`.`accountid`) AS `buyer_accountid`,`dids`.`country_id` AS `country_id`,`dids`.`cost` AS `cost`,`dids`.`call_type` AS `call_type`,`dids`.`city` AS `city`,`dids`.`province` AS `province`,`dids`.`leg_timeout` AS `leg_timeout`,`dids`.`maxchannels` AS `maxchannels`,`dids`.`extensions` AS `extensions`,`dids`.`hg_type` AS `hg_type`,`dids`.`reverse_rate` AS `reverse_rate`,`dids`.`rate_group` AS `rate_group`,`dids`.`area_code` AS `area_code`,`products`.`buy_cost` AS `buy_cost`,`products`.`setup_fee` AS `setup_fee`,`products`.`price` AS `price`,`products`.`billing_type` AS `billing_type`,`products`.`billing_days` AS `billing_days`,`products`.`id` AS `product_id`,`products`.`last_modified_date` AS `modified_date` from (`products` join `dids` on((`dids`.`product_id` = `products`.`id`))) where (`products`.`status` = 0) order by `products`.`id`;

-- ----------------------------
-- View structure for view_fs_reg
-- ----------------------------
DROP VIEW IF EXISTS `view_fs_reg`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_fs_reg` AS select `accounts`.`id` AS `accounts_id`,`accounts`.`number` AS `accounts_number`,`accounts`.`reseller_id` AS `accounts_reseller`,`accounts`.`company_name` AS `company_name`,`sip_devices`.`id` AS `devices_id`,`sip_devices`.`username` AS `username`,`registrations`.`reg_user` AS `reg_user`,`registrations`.`realm` AS `realm`,`registrations`.`url` AS `url`,`registrations`.`expires` AS `expires`,`registrations`.`network_ip` AS `network_ip`,`registrations`.`network_port` AS `network_port`,`registrations`.`network_proto` AS `network_proto`,`registrations`.`hostname` AS `hostname` from ((`accounts` join `sip_devices` on(((`accounts`.`reseller_id` = `sip_devices`.`reseller_id`) and (`accounts`.`id` = `sip_devices`.`accountid`)))) join `registrations` on((convert(`sip_devices`.`username` using utf8mb4) = `registrations`.`reg_user`)));

-- ----------------------------
-- View structure for view_invoices
-- ----------------------------
DROP VIEW IF EXISTS `view_invoices`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_invoices` AS select `invoices`.`id` AS `id`,concat(`invoices`.`prefix`,`invoices`.`number`) AS `number`,`invoices`.`accountid` AS `accountid`,`invoices`.`reseller_id` AS `reseller_id`,`invoices`.`from_date` AS `from_date`,`invoices`.`to_date` AS `to_date`,`invoices`.`due_date` AS `due_date`,`invoices`.`status` AS `status`,if(((select `accounts`.`posttoexternal` from `accounts` where (`accounts`.`id` = `invoices`.`accountid`)) = 0),0,if(((sum(`invoice_details`.`debit`) - sum(`invoice_details`.`credit`)) = 0),0,1)) AS `is_paid`,`invoices`.`generate_date` AS `generate_date`,`invoices`.`type` AS `type`,`invoices`.`payment_id` AS `payment_id`,`invoices`.`generate_type` AS `generate_type`,`invoices`.`confirm` AS `confirm`,`invoices`.`notes` AS `notes`,`invoices`.`is_deleted` AS `is_deleted`,sum(`invoice_details`.`debit`) AS `debit`,sum((`invoice_details`.`debit` * `invoice_details`.`exchange_rate`)) AS `debit_exchange_rate`,sum(`invoice_details`.`credit`) AS `credit`,sum((`invoice_details`.`credit` * `invoice_details`.`exchange_rate`)) AS `credit_exchange_rate` from (`invoices` join `invoice_details` on((`invoices`.`id` = `invoice_details`.`invoiceid`))) group by `invoice_details`.`invoiceid`;

-- ----------------------------
-- View structure for view_invoices_2
-- ----------------------------
DROP VIEW IF EXISTS `view_invoices_2`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_invoices_2` AS select `invoices`.`id` AS `id`,concat(`invoices`.`prefix`,`invoices`.`number`) AS `number`,`invoices`.`accountid` AS `accountid`,`invoices`.`reseller_id` AS `reseller_id`,`invoices`.`from_date` AS `from_date`,`invoices`.`to_date` AS `to_date`,`invoices`.`due_date` AS `due_date`,`invoices`.`status` AS `status`,if(((select `accounts`.`posttoexternal` from `accounts` where (`accounts`.`id` = `invoices`.`accountid`)) = 0),0,if(((sum(`invoice_details`.`debit`) - sum(`invoice_details`.`credit`)) = 0),0,1)) AS `is_paid`,`invoices`.`generate_date` AS `generate_date`,`invoices`.`type` AS `type`,`invoices`.`payment_id` AS `payment_id`,`invoices`.`generate_type` AS `generate_type`,`invoices`.`confirm` AS `confirm`,`invoices`.`notes` AS `notes`,`invoices`.`is_deleted` AS `is_deleted`,round(sum(`invoice_details`.`debit`),2) AS `debit`,round(sum((`invoice_details`.`debit` * `invoice_details`.`exchange_rate`)),4) AS `debit_exchange_rate`,round(sum(`invoice_details`.`credit`),2) AS `credit`,round(sum((`invoice_details`.`credit` * `invoice_details`.`exchange_rate`)),4) AS `credit_exchange_rate` from (`invoices` join `invoice_details` on((`invoices`.`id` = `invoice_details`.`invoiceid`))) group by `invoice_details`.`invoiceid`;

-- ----------------------------
-- View structure for view_new_invoices
-- ----------------------------
DROP VIEW IF EXISTS `view_new_invoices`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_new_invoices` AS select `invoices`.`id` AS `id`,concat(`invoices`.`prefix`,`invoices`.`number`) AS `number`,`invoices`.`accountid` AS `accountid`,`pricelists`.`name` AS `plano`,`invoices`.`reseller_id` AS `reseller_id`,`invoices`.`from_date` AS `from_date`,`invoices`.`to_date` AS `to_date`,`invoices`.`due_date` AS `due_date`,`invoices`.`status` AS `status`,if(((select `accounts`.`posttoexternal` from `accounts` where (`accounts`.`id` = `invoices`.`accountid`)) = 0),0,if(((sum(`invoice_details`.`debit`) - sum(`invoice_details`.`credit`)) = 0),0,1)) AS `is_paid`,`invoices`.`generate_date` AS `generate_date`,`invoices`.`type` AS `type`,`invoices`.`payment_id` AS `payment_id`,`invoices`.`generate_type` AS `generate_type`,`invoices`.`confirm` AS `confirm`,`invoices`.`notes` AS `notes`,`invoices`.`is_deleted` AS `is_deleted`,round(sum(`invoice_details`.`debit`),2) AS `debit`,round(sum((`invoice_details`.`debit` * `invoice_details`.`exchange_rate`)),2) AS `debit_exchange_rate`,round(sum(`invoice_details`.`credit`),2) AS `credit`,round(sum((`invoice_details`.`credit` * `invoice_details`.`exchange_rate`)),2) AS `credit_exchange_rate`,round((sum(`invoice_details`.`debit`) - sum(`invoice_details`.`credit`)),2) AS `invoice_total` from (((`invoices` join `invoice_details` on((`invoices`.`id` = `invoice_details`.`invoiceid`))) join `accounts` on((`invoices`.`accountid` = `accounts`.`id`))) join `pricelists` on((`accounts`.`pricelist_id` = `pricelists`.`id`))) group by `invoice_details`.`invoiceid`,`invoice_details`.`accountid` order by `invoices`.`id` desc;

-- ----------------------------
-- View structure for view_orders
-- ----------------------------
DROP VIEW IF EXISTS `view_orders`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_orders` AS select `orders`.`id` AS `id`,`orders`.`order_id` AS `order_id`,`orders`.`order_date` AS `order_date`,`orders`.`payment_gateway` AS `payment_gateway`,(case when (`order_items`.`is_terminated` = 0) then concat('Ativo') else concat('Inativo') end) AS `order_status`,`orders`.`payment_status` AS `payment_status`,`orders`.`reseller_id` AS `reseller_id`,`orders`.`accountid` AS `accountid`,(case when (`products`.`product_category` = 4) then concat('DID') else concat('Package') end) AS `product_type`,`products`.`name` AS `product_name`,`products`.`status` AS `product_status`,(case when (`products`.`is_deleted` = 1) then concat('Produto Excluido') else concat('Produto Ativo') end) AS `product_deleted`,`order_items`.`product_id` AS `product_id`,`order_items`.`setup_fee` AS `setup_fee`,`order_items`.`billing_date` AS `billing_date`,`order_items`.`next_billing_date` AS `next_billing_date`,`order_items`.`termination_date` AS `termination_date`,`order_items`.`price` AS `price` from ((`orders` join `order_items` on((`orders`.`id` = `order_items`.`order_id`))) join `products` on((`order_items`.`product_id` = `products`.`id`))) order by `orders`.`id` desc;

-- ----------------------------
-- View structure for view_pacotes
-- ----------------------------
DROP VIEW IF EXISTS `view_pacotes`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_pacotes` AS select `O`.`order_id` AS `id`,`P`.`id` AS `product_id`,`P`.`name` AS `package_name`,`O`.`free_minutes` AS `free_minutes`,(`O`.`free_minutes` * 60) AS `free_secs`,`P`.`applicable_for` AS `applicable_for`,`P`.`status` AS `status`,`P`.`price` AS `price`,`C`.`used_seconds` AS `counters_used_seconds`,`C`.`package_id` AS `counters_package_id`,round((`C`.`used_seconds` / 60),0) AS `counters_used_minutes`,`O`.`accountid` AS `accountid`,`O`.`is_terminated` AS `is_terminated` from ((`products` `P` join `order_items` `O`) join `counters` `C`) where ((`P`.`id` = `O`.`product_id`) and (`C`.`package_id` = `O`.`order_id`) and (`P`.`product_category` = 1) and (`P`.`status` = 0) and ((`O`.`termination_date` >= (utc_timestamp() - interval 1 month)) or (`O`.`termination_date` = '0000-00-00 00:00:00')));

-- ----------------------------
-- View structure for view_permissions
-- ----------------------------
DROP VIEW IF EXISTS `view_permissions`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY INVOKER VIEW `view_permissions` AS select `permissions`.`id` AS `id`,`permissions`.`name` AS `name`,`permissions`.`reseller_id` AS `reseller_id`,`permissions`.`description` AS `description`,`permissions`.`login_type` AS `login_type`,`permissions_types`.`permission_name` AS `permission_name`,`permissions_types`.`permission_type_code` AS `permission_type_code`,`permissions`.`permissions` AS `permissions`,`permissions`.`creation_date` AS `creation_date`,`permissions`.`modification_date` AS `modification_date` from (`permissions` join `permissions_types`) where (`permissions`.`login_type` = `permissions_types`.`permission_type_code`) order by `permissions`.`id`;

-- ----------------------------
-- View structure for view_status_pedidos
-- ----------------------------
DROP VIEW IF EXISTS `view_status_pedidos`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_status_pedidos` AS select `orders`.`id` AS `id`,`orders`.`order_id` AS `order_id`,`orders`.`order_date` AS `order_date`,`orders`.`payment_gateway` AS `payment_gateway`,(case when (`order_items`.`is_terminated` = 0) then concat('Pedido Ativo') else concat('Pedido Inativo') end) AS `order_status`,`orders`.`payment_status` AS `payment_status`,`orders`.`reseller_id` AS `reseller_id`,`orders`.`accountid` AS `accountid`,concat(`accounts`.`number`,' ',`accounts`.`first_name`,' ',`accounts`.`last_name`,' ',`accounts`.`company_name`) AS `company`,`accounts`.`pricelist_id` AS `pricelist_id`,`accounts`.`invoice_day` AS `invoice_day`,(case when (`products`.`product_category` = 4) then concat('DID') else concat('Package') end) AS `product_type`,`products`.`name` AS `product_name`,(case when (`products`.`status` = 1) then concat('Produto Desativado') else concat('Produto Ativado') end) AS `product_status`,(case when (`products`.`is_deleted` = 1) then concat('Produto Excluido') else concat('Produto Ativo') end) AS `product_deleted`,`order_items`.`product_id` AS `product_id`,`order_items`.`setup_fee` AS `setup_fee`,(`order_items`.`free_minutes` * 60) AS `includedseconds`,`order_items`.`is_terminated` AS `is_terminated`,`order_items`.`billing_date` AS `billing_date`,`order_items`.`next_billing_date` AS `next_billing_date`,`order_items`.`termination_date` AS `termination_date`,round(`order_items`.`price`,2) AS `price`,round(`products`.`price`,2) AS `product_price` from (((`orders` join `order_items` on((`orders`.`id` = `order_items`.`order_id`))) join `products` on((`order_items`.`product_id` = `products`.`id`))) join `accounts` on((`order_items`.`accountid` = `accounts`.`id`))) order by `orders`.`order_date` desc;

-- ----------------------------
-- View structure for view_status_pedidos_new
-- ----------------------------
DROP VIEW IF EXISTS `view_status_pedidos_new`;
CREATE ALGORITHM = UNDEFINED DEFINER = `fluxuser`@`127.0.0.1` SQL SECURITY DEFINER VIEW `view_status_pedidos_new` AS select `orders`.`id` AS `id`,`orders`.`order_id` AS `order_id`,`orders`.`order_date` AS `order_date`,`counters`.`used_seconds` AS `counter_used_seconds`,`counters`.`id` AS `counter_id`,`orders`.`payment_gateway` AS `payment_gateway`,(case when (`order_items`.`is_terminated` = 0) then concat('Pedido Ativo') else concat('Pedido Inativo') end) AS `order_status`,`orders`.`payment_status` AS `payment_status`,`orders`.`reseller_id` AS `reseller_id`,`orders`.`accountid` AS `accountid`,concat(`accounts`.`number`,' ',`accounts`.`first_name`,' ',`accounts`.`last_name`,' ',`accounts`.`company_name`) AS `company`,`accounts`.`invoice_day` AS `invoice_day`,(case when (`products`.`product_category` = 4) then concat('DID') else concat('Package') end) AS `product_type`,`products`.`name` AS `product_name`,(case when (`products`.`status` = 1) then concat('Produto Desativado') else concat('Produto Ativado') end) AS `product_status`,(case when (`products`.`is_deleted` = 1) then concat('Produto Excluido') else concat('Produto Ativo') end) AS `product_deleted`,`order_items`.`product_id` AS `product_id`,`order_items`.`setup_fee` AS `setup_fee`,`order_items`.`billing_date` AS `billing_date`,`order_items`.`next_billing_date` AS `next_billing_date`,`order_items`.`termination_date` AS `termination_date`,`products`.`price` AS `price` from ((((`orders` join `order_items` on((`orders`.`id` = `order_items`.`order_id`))) join `products` on((`order_items`.`product_id` = `products`.`id`))) join `counters` on((`order_items`.`order_id` = `counters`.`package_id`))) join `accounts` on((`order_items`.`accountid` = `accounts`.`id`))) order by `orders`.`order_date` desc;

SET FOREIGN_KEY_CHECKS = 1;
