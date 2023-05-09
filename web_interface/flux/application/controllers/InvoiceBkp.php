<?php
// ##############################################################################
// Flux Telecom - Unindo pessoas e negócios
//
// Copyright (C) 2021 Flux Telecom
// Daniel Paixao <daniel@flux.net.br>
// FluxSBC Version 4.2 and above
// License https://www.gnu.org/licenses/agpl-3.0.html
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
// ##############################################################################
class ProcessInvoice extends MX_Controller {

	public static $global_config;
	public $Error_flag = "true";

	public $CurrentDate = "";
	public $StartDate = "";
	public $EndDate = "";
	public $fp = "";

	function __construct() {
		parent::__construct();
		$this->load->model("db_model");
		$this->load->library("flux/common");
		$this->load->library("flux/order");
		$this->load->library("Invoice_log");
		$this->load->model("common_model");

//		error_reporting("E_ALL");
		ini_set("memory_limit", "3048M");
		ini_set("max_execution_time", "2592000");

		$this->get_system_config();

		$this->fp = fopen("/var/log/flux/monitor.log", "a+");

    $this->CurrentDate = gmdate("Y-m-d 00:00:01");
//		$this->custom_current_date = "2023-03-31 23:59:59";
    $this->custom_current_date = "2023-02-28 23:59:59";
//		$this->CurrentDate = "2023-03-31 23:59:59";
	}

	function ManageServices() {

         $this->product_renewal_reminder();
		       $this->renew_product_service();

	}

	function GenerateInvoice() {

		$this->db->where_in("type", array(
			0,
			1,
			3,
		));
		$accountsdata = $this->db_model->getSelect("*", "accounts", array(
			"status" => "0",
			"deleted" => 0,
			"posttoexternal" => 1,
		));
		if ($accountsdata->num_rows > 0) {
			$accountsdata = $accountsdata->result_array();
			foreach ($accountsdata as $accountkey => $accountvalue) {
				if ($accountvalue['generate_invoice'] == '0') {
					$this->generate_invoices($accountvalue);
				}

			}
		}
		exit();
	}

	function generate_invoices($accountinfo) {
		$this->StartDate = ($accountinfo['last_bill_date'] == '0000-00-00 00:00:00') ? $accountinfo['creation'] : $accountinfo['last_bill_date'];
		$this->StartDate = date("Y-m-d 00:00:01", strtotime($this->StartDate));
		switch ($accountinfo['sweep_id']) {

		case 0:
			if (Strtotime($this->StartDate) > strtotime($this->CurrentDate)) {
				$this->StartDate = date("Y-m-d 00:00:01", strtotime($this->CurrentDate . " - 1 days"));
			}
			$this->EndDate = date("Y-m-d 23:59:59", strtotime($this->CurrentDate . " - 1 days"));
			if ($this->EndDate != '') {
				$invoiceid = $this->create_invoice($accountinfo);
				if ($invoiceid > 0) {
					$this->bill_calls($accountinfo, $invoiceid);
					$this->apply_taxes($accountinfo, $invoiceid);
//					$this->product_renewal_reminder($accountinfo, $invoiceid);
//     $this->renew_product($accountinfo, $invoiceid);

					
					$this->db->where("id", $accountinfo['id']);
					$this->db->update("accounts", array(
						"last_bill_date" => $this->CurrentDate,
					));

				}
			}
			

			break;
		case 2:
			// Ashish FLUXUPDATE-820
			if (date("d", strtotime($this->CurrentDate)) == $accountinfo['invoice_day']) {
				// Ashish 820 End
				$this->EndDate = date("Y-m-" . $accountinfo['invoice_day'] . " 23:59:59", strtotime($this->StartDate . " + 1 month"));
				$accountinfo['last_bill_date'] = ($accountinfo['last_bill_date'] > $accountinfo['creation']) ? $accountinfo['last_bill_date'] : $accountinfo['creation'];
				if (Strtotime($this->EndDate) > strtotime($this->CurrentDate)) {
					$this->EndDate = $this->CurrentDate;
				}
				$this->EndDate = date("Y-m-d H:i:s", strtotime($this->EndDate . " -2 second"));
				$invoiceid = $this->create_invoice($accountinfo);
				if ($invoiceid > 0) {
					$this->bill_calls($accountinfo, $invoiceid);
					$this->apply_taxes($accountinfo, $invoiceid);
//					$this->product_renewal_reminder($accountinfo, $invoiceid);
//					$this->renew_product($accountinfo, $invoiceid);
//					$this->product_renewal_reminder($accountinfo, $invoiceid);
					$this->db->where("id", $accountinfo['id']);
					$this->db->update("accounts", array(
						"last_bill_date" => $this->CurrentDate,
					));
				}
			}
			break;
		}

	}

	function create_invoice($accountinfo) {
		$invoiceconf = $this->common->Get_Invoice_configuration($accountinfo);
		if ($invoiceconf != '') {
			if ($invoiceconf['interval'] > 0) {
				$DueDate = date("Y-m-d 23:59:59", strtotime($this->CurrentDate . " +" . $invoiceconf['interval'] . " days"));
			} else {
				$DueDate = date("Y-m-d 23:59:59", strtotime($this->CurrentDate . " +7 days"));
			}

			$last_invoice_ID = $this->common->get_invoice_date("number", "", $accountinfo['reseller_id']);

			if ($last_invoice_ID && $last_invoice_ID > 0) {
				$last_invoice_ID = ($last_invoice_ID + 1);

				if ($last_invoice_ID < $invoiceconf['invoice_start_from']) {
					$last_invoice_ID = $invoiceconf['invoice_start_from'];
				}

			} else {
				$last_invoice_ID = $invoiceconf['invoice_start_from'];
			}
			$last_invoice_ID = str_pad($last_invoice_ID, 6, '0', STR_PAD_LEFT);
			$automatic_flag = self::$global_config['system_config']['automatic_invoice'] == 1 ? '0' : '1';
			if ($invoiceconf['no_usage_invoice'] == 1) {

				$InvoiceData = array(
					"accountid" => $accountinfo['id'],
					"prefix" => $invoiceconf['invoice_prefix'],
					"number" => $last_invoice_ID,
					"reseller_id" => $accountinfo['reseller_id'],
					"generate_date" => $this->CurrentDate,
					"from_date" => $this->StartDate,
					"to_date" => $this->EndDate,
					"due_date" => $DueDate,
					"status" => 0,
					"confirm" => $automatic_flag,
					"notes" => $accountinfo['invoice_note'],
					"is_deleted" => 0,
				);
				$this->db->insert("invoices", $InvoiceData);
				$invoiceid = $this->db->insert_id();

				$InvoiceDataLog = array(
					"accountid" => $accountinfo['id'],
					"prefix" => $invoiceconf['invoice_prefix'],
					"number" => $last_invoice_ID,
					"reseller_id" => $accountinfo['reseller_id'],
					"generate_date" => $this->CurrentDate,
					"from_date" => $this->StartDate,
					"to_date" => $this->EndDate,
					"due_date" => $DueDate,
					"status" => 0,
					"confirm" => $automatic_flag,
					"notes" => $accountinfo['invoice_note'],
					"is_deleted" => 0,
				);
				$this->invoice_log->write_log('create_invoice', json_encode($InvoiceDataLog));

				$InvoiceDetailData = array(
					"invoiceid" => $invoiceid,
					"accountid" => $accountinfo['id'],
					"reseller_id" => $accountinfo['reseller_id'],
					"created_date" => $this->CurrentDate,
					"generate_type" => 0,
					"debit" => 0.00,
					"credit" => 0.00,
					"charge_type" => "INV",
					"before_balance" => 0.00,
					"after_balance" => 0.00,
					"quantity" => 1,
					"description" => "Invoice Criado",
					"exchange_rate" => "1.00",
					"account_currency" => "BRL",
					"base_currency" => "BRL",
				);

				$InvoiceLogDetailData = array(
					"invoiceid" => $invoiceid,
					"accountid" => $accountinfo['id'],
					"debit" => "0.00",
					"credit" => "0.00",
					"reseller_id" => $accountinfo['reseller_id'],
					"created_date" => $this->CurrentDate,
					"generate_type" => 0,
					"account_currency" => "BRL",
				);
				$this->db->insert("invoice_details", $InvoiceDetailData);
				$this->invoice_log->write_log('create_detail_invoice', json_encode($InvoiceLogDetailData));

				$update_billable_item = "update invoice_details set invoiceid = " . $invoiceid . " where accountid=" . $accountinfo['id'] . " AND created_date >='" . $this->StartDate . "' AND created_date <= '" . $this->EndDate . "'";
//				$update_billable_item = "update invoice_details set invoiceid = " . $invoiceid . " where accountid=" . $accountinfo['id'] . " AND created_date >='" . $this->StartDate . "' AND created_date <= '" . $this->EndDate . "' AND invoiceid = 0";
				$this->db->query($update_billable_item);
				$amount = $this->db_model->getSelect("debit,credit", "invoice_details", array(
					"invoiceid" => $invoiceid,
				));
				if ($amount->num_rows > 0) {
					$amount = $amount->result_array()[0];
					$InvoiceData['amount'] = ($amount['credit'] - $amount['debit']);
					$InvoiceData['amount'] = ($InvoiceData['amount'] < 0) ? ($InvoiceData['amount'] * -1) : $InvoiceData['amount'];
					$InvoiceData['invoice_number'] = $invoiceconf['invoice_prefix'] . $last_invoice_ID;
					$InvoiceData['currency_id'] = $accountinfo['currency_id'];
					$final_array = array_merge($accountinfo, $InvoiceData);
					$log_final_array = array_merge($accountinfo, $InvoiceData);
					$this->invoice_log->write_log('update_invoice_amount', json_encode($log_final_array));
     $this->InvoiceLogger('create_invoice',$log_final_array);
     $this->common->mail_to_users("new_invoice", $final_array);

				}

				//LOG
				//   $this->invoice_log->write_log ( 'account_insert_invoice', json_encode($InvoiceDataLog) );
				//   $this->invoice_log->write_log ( 'update_billable_item_log', json_encode($update_billable_item_log) );
				//   $this->invoice_log->write_log ( 'log_final_array', json_encode($log_final_array) );
				//END LOG
				return $invoiceid;
			}
		}
	}

	function bill_calls($accountinfo, $invoiceid) {
		//	   $start_date = $this->common->convert_GMT_to($this->StartDate,$this->StartDate,$this->StartDate,$accountinfo['timezone_id']);
		//		$end_Date = $this->common->convert_GMT_to($this->EndDate,$this->EndDate,$this->EndDate,$accountinfo['timezone_id']);
		//		$table_name = $accountinfo['type'] == 1 ? 'reseller_cdrs' : 'cdrs';
		//		$where_condition = $accountinfo['type'] == 1 ? "AND callstart >= '" .$start_date."'" : ' AND invoiceid =0 ';
		//		$billable_calls_qr = "select calltype,sum(debit) as debit,sum(billseconds) as duration from ".$table_name." where accountid =" . $accountinfo['id'] . "  AND callstart <= '" .$end_Date. "' ".$where_condition." group by calltype";
		//	$this->PrintLogger($this->Error_flag,$billable_calls_qr);
		//    $billable_calls_qr = "select calltype,sum(debit) as debit,sum(billseconds) as duration from cdrs where accountid =" . $accountinfo['id'] . " AND callstart >='" . $this->StartDate . "' AND callstart <= '" . $this->EndDate . "' AND invoiceid=0 group by calltype";

		$billable_calls_qr = "select calltype,sum(debit) as debit,sum(billseconds) as duration from cdrs where accountid =" . $accountinfo['id'] . " AND callstart >='" . $this->StartDate . "' AND callstart <= '" . $this->EndDate . "' AND invoiceid=0 group by calltype";
		$billable_calls = $this->db->query($billable_calls_qr);

		if ($billable_calls->num_rows() > 0) {
//    $update_billable_calls_qr = "select calltype,sum(debit) as debit,sum(billseconds) as duration from ".$table_name." where accountid =" . $accountinfo['id'] . "  AND callstart <= '" .$end_Date. "' ".$where_condition." group by calltype";

			$billable_calls = $billable_calls->result_array();
			$base_currency = Common_model::$global_config['system_config']['base_currency'];
			$decimal_point = Common_model::$global_config['system_config']['decimalpoints'];
			$account_currency_info = $this->db_model->getSelect("*", "currency", array(
				"id" => $accountinfo['currency_id'],
			));
			if ($account_currency_info->num_rows > 0) {
				$account_currency_info = $account_currency_info->result_array();
				$account_currency_info = $account_currency_info[0];
			}
			else {
			$account_currency_info = $this->db_model->getSelect("*", "currency", array(
				"id" => "16",
			));
			$account_currency_info = $account_currency_info->result_array();
			$account_currency_info = $account_currency_info[0];
			
			}
			foreach ($billable_calls as $calls) {
				$seconds = $calls['duration'];
				$minutes = floor($seconds / 60);
				$secondsleft = $seconds % 60;
				if ($minutes < 10) {
					$minutes = "0" . $minutes;
				}

				if ($secondsleft < 10) {
					$secondsleft = "0" . $secondsleft;
				}

				if ($calls['calltype'] == "Gratuita") {
					$calls['debit'] = "0.00";
				}
				if ($calls['calltype'] == "") {
					$calls['calltype'] = "Padrao";
				}

				$tempArr = array(
					"accountid" => $accountinfo['id'],
					"reseller_id" => $accountinfo['reseller_id'],
					"order_item_id" => "0",
					"description" => $calls['calltype'] . "-" . "$minutes:$secondsleft.",
					"debit" => $calls['debit'],
					"charge_type" => $calls['calltype'],
					"created_date" => $this->EndDate,
					"base_currency" => $base_currency,
					"exchange_rate" => $account_currency_info['currencyrate'],
					"account_currency" => $account_currency_info['currency'],
					"invoiceid" => $invoiceid,
				);
				$logArr = array(
					"accountid" => $accountinfo['id'],
					"reseller_id" => $accountinfo['reseller_id'],
					"order_item_id" => "0",
					"description" => $calls['calltype'] . "-" . "$minutes:$secondsleft.",
					"debit" => $calls['debit'],
					"charge_type" => $calls['calltype'],
					"created_date" => $this->EndDate,
					"base_currency" => $base_currency,
					"exchange_rate" => $account_currency_info['currencyrate'],
					"account_currency" => $account_currency_info['currency'],
					"invoiceid" => $invoiceid,
				);
				$this->db->insert("invoice_details", $tempArr);
				$this->invoice_log->write_log('invoice_details', json_encode($logArr));

				$update_cdrs_arr = "update cdrs set invoiceid = " . $invoiceid . " where accountid=" . $accountinfo['id'] . " AND callstart >='" . $this->StartDate . "' AND callstart <= '" . $this->EndDate . "'";
				$this->db->query($update_cdrs_arr);
				$update_log_cdrs_arr = "update cdrs set invoiceid = " . $invoiceid . " where accountid=" . $accountinfo['id'] . " AND callstart >='" . $this->StartDate . "' AND callstart <= '" . $this->EndDate . "'";
				$this->invoice_log->write_log('update_cdrs', json_encode($update_log_cdrs_arr));

			}
		}
	}

	function apply_taxes($accountinfo, $invoiceid) {

		$get_total_billable_item = "select count(id) as count,ifnull(sum(debit),'0.00') as debit,ifnull(sum(credit),'0.00') as credit from invoice_details where accountid=" . $accountinfo['id'] . " AND charge_type != 'REFILL' AND product_category != 3 AND created_date >='" . $this->StartDate . "' AND created_date <= '" . $this->EndDate . "' AND invoiceid = " . $invoiceid;
		
		$get_total_billable_item = $this->db->query($get_total_billable_item);
		if ($get_total_billable_item->num_rows() > 0) {
			$total_billable_item = $get_total_billable_item->result_array()[0];
			$tax_calculation = $this->common_model->calculate_taxes($accountinfo, $total_billable_item["debit"]);
			if (isset($tax_calculation['tax']) && !empty($tax_calculation['tax'] && $total_billable_item["debit"] > 0)) {
				$base_currency = Common_model::$global_config['system_config']['base_currency'];
				$account_balance = $accountinfo['posttoexternal'] == 1 ? $accountinfo['credit_limit'] - ($accountinfo['balance']) : $accountinfo['balance'];
				$debit = isset($tax_calculation['total_tax']) ? $tax_calculation['total_tax'] : "0.00";
				$credit = "0.00";
				$after_balance = $account_balance - $debit;
				$account_currency_info = $this->db_model->getSelect("*", "currency", array(
					"id" => $accountinfo['currency_id'],
				));
				if ($account_currency_info->num_rows > 0) {
					$account_currency_info = $account_currency_info->result_array();
					$account_currency_info = $account_currency_info[0];
				}
				foreach ($tax_calculation['tax'] as $tax_key => $tax) {
					$tax_insert_arr = array(
						"accountid" => $accountinfo['id'],
						"description" => $tax_key,
						"created_date" => $this->EndDate,
						"invoiceid" => $invoiceid,
						"reseller_id" => $accountinfo['reseller_id'],
						"is_tax" => 1,
						"order_item_id" => 0,
						"payment_id" => 0,
						'before_balance' => $account_balance,
						'product_category' => '0',
						'charge_type' => "TAX",
						'after_balance' => $after_balance,
						'base_currency' => $base_currency,
						'exchange_rate' => $account_currency_info['currencyrate'],
						'account_currency' => $account_currency_info['currency'],
						'debit' => $tax,
						'credit' => 0,

					);
					$log_tax_insert_arr = array(
						"accountid" => $accountinfo['id'],
						"description" => $tax_key,
						"created_date" => $this->EndDate,
						"invoiceid" => $invoiceid,
						"reseller_id" => $accountinfo['reseller_id'],
						"is_tax" => 1,
						"order_item_id" => 0,
						"payment_id" => 0,
						'before_balance' => $account_balance,
						'product_category' => '0',
						'charge_type' => "TAX",
						'after_balance' => $after_balance,
						'base_currency' => $base_currency,
						'exchange_rate' => $account_currency_info['currencyrate'],
						'account_currency' => $account_currency_info['currency'],
						'debit' => $tax,
						'credit' => 0,

					);
					$this->db->insert("invoice_details", $tax_insert_arr);
					$this->invoice_log->write_log('tax_calculate', json_encode($log_tax_insert_arr));

				}
			}
		}
	}

	function renew_product($accountinfo, $invoiceid) {
		$is_apply_commission = "false";
		$renewable_order = $this->db_model->getJionQuery('orders', 'orders.payment_status,orders.order_id as order_number,order_items.id,order_items.order_id,order_items.product_category,order_items.product_id,
order_items.quantity,order_items.billing_type,order_items.billing_days,order_items.free_minutes,
order_items.billing_date,order_items.next_billing_date,order_items.is_terminated ,order_items.termination_date,
order_items.termination_note,order_items.from_currency,order_items.exchange_rate,order_items.to_currency,
order_items.reseller_id,order_items.accountid,order_items.setup_fee,order_items.price', array(
			"order_items.next_billing_date <=" => $this->CurrentDate,
			"order_items.product_category <>" => "3",
			"order_items.is_terminated" => "0",
			"orders.payment_status <>" => "FAIL",
		), 'order_items', 'orders.id=order_items.order_id', 'inner', '', '', '', '');
		if ($renewable_order->num_rows > 0) {
			$renewable_order = $renewable_order->result_array();
			foreach ($renewable_order as $orderkey => $ordervalue) {
				$orderobjArr = array();
				$parentdata = array();
				$parent_array = array();
				$parent_key_arr = array();
				$productdata = array(
					"product_id" => $ordervalue['product_id'],
				);
				$productdatalog = array(
					"product_id" => $ordervalue['product_id'],
				);

				$product_data = $this->db_model->getSelect("*", "products", array(
					"id" => $ordervalue['product_id'],
					'is_deleted' => "0",
					'status' => "0",
				));
				if ($product_data->num_rows() > 0) {
					$accountdata = $this->db_model->getSelect("*", "accounts", array(
						"id" => $ordervalue["accountid"],
						'deleted' => "0",
						"status" => "0",
					));
					if ($accountdata->num_rows() > 0) {
						$accountdata = $accountdata->result_array()[0];
						$account_currency_info = $this->db_model->getSelect("*", "currency", array(
							"id" => $accountdata['currency_id'],
						));
						if ($account_currency_info->num_rows > 0) {
							$account_currency_info = (array) $account_currency_info->result_array();
							$account_currency_info = $account_currency_info[0];
						} else {
							{
								$base_currency = Common_model::$global_config['system_config']['base_currency'];
								$account_currency_info = $this->db_model->getSelect("*", "currency", array(
									"currency" => $base_currency,
								));
								$account_currency_info = (array) $account_currency_info->result_array();
								$account_currency_info = $account_currency_info[0];
							}

						}
						$user_product_info = $this->order->get_account_product_info($orderobjArr, (object) $accountdata, $productdata);
						if (!empty($user_product_info) && $product_data->num_rows() > 0) {
							$is_process = true;
							$user_product_info->price = $ordervalue['price'];
							$user_product_info->quantity = $ordervalue['quantity'];
							$user_product_info->setup_fee = $ordervalue['setup_fee'];
							$user_product_info->billing_days = $ordervalue['billing_days'];
							$product_info = (array) $user_product_info;
							$total_amt = ($ordervalue['price'] * $ordervalue['quantity']);
							if ($accountdata['posttoexternal'] == 1) {
								$account_balance = $accountdata['credit_limit'];
							} else {

								$account_balance = $accountdata['balance'];

							}

							//		$account_balance = $accountdata ['posttoexternal'] == 1 ? $accountdata ['credit_limit'] - ($accountdata ['balance']) :        $accountdata ['balance'];
							$product_info['product_name'] = $product_info['name'];
							$final_array = array_merge($accountdata, $product_info);
							$acc_id = '';
							$order_id = '';

							$acc_id = $this->common->get_field_name("id", "accounts", array(
								"number" => $final_array['number'],
							));
							$order_id = $this->common->get_field_name("order_id", "orders", array(
								"id" => $ordervalue['order_id'],
							));
							$final_array['order_id'] = $order_id;
							$final_array['next_billing_date'] = $this->common->get_field_name("next_billing_date", "order_items", array(
								"order_id" => $ordervalue['order_id'],
							));
							$update_order_arr = array(
								"is_terminated" => '1',
								"termination_date" => $this->CurrentDate,
								"termination_note" => "Product has been terminated",
							);
							$did_update_array = array(
								"accountid" => 0,
								"call_type" => 0,
								"extensions" => "",
								"always" => 0,
								"always_destination" => "",
								"user_busy" => 0,
								"user_busy_destination" => "",
								"user_not_registered" => 0,
								"user_not_registered_destination" => "",
								"no_answer" => 0,
								"no_answer_destination" => "",
								"call_type_vm_flag" => 1,
								"failover_call_type" => 1,
								"always_vm_flag" => 1,
								"user_busy_vm_flag" => 1,
								"user_not_registered_vm_flag" => 1,
								"no_answer_vm_flag" => 1,
								"failover_extensions" => "",
							);

							if ($product_info['release_no_balance'] == 0 && $product_info['product_category'] == 1) {
								if ($account_balance < $total_amt) {
									$is_process = false;
									$this->db->update("order_items", $update_order_arr, array(
										"id" => $ordervalue['id'],
									));
									$final_array['next_billing_date'] = $update_order_arr['termination_date'];
									$this->common->mail_to_users("product_release", $final_array);
									$no_account_balance_insert_arr = array(
										"cron_date" => $this->CurrentDate,
										"account_number" => $final_array['number'],
										"product_category" => $product_info['product_category'],
										"order_id" => $ordervalue['id'],
										"account_balance" => $account_balance,
										"product_total" => $total_amt,
										'message' => "Produto removido por falta de saldo",
									);
									$this->invoice_log->write_log('no_get_account_product_info', json_encode($no_account_balance_insert_arr));
									//LOG

								}
							}
							if ($is_process == true) {
								$parentdata = $this->db_model->getSelect("*", "accounts", array(
									"id" => $ordervalue["reseller_id"],
								));
								$parentdata = $parentdata->first_row();

								$product_info['payment_status'] = "PAID";
								$product_info['payment_by'] = "Account Balance";
								$product_info['order_item_id'] = $ordervalue['order_id'];
								$product_info['invoice_type'] = "debit";
								$product_info['is_apply_tax'] = "false";
//                $product_info['add_invoice_credit']= "true";
								$product_info['charge_type'] = $this->common->get_field_name("code", "category", array(
									"id" => $product_info['product_category'],
								));
								$product_info['description'] = $product_info['charge_type'] . " (" . $product_info['name'] . ") has been renewed.";

								$update_order_arr = array(
									"billing_date" => $this->CurrentDate,
									"next_billing_date" => ($ordervalue['billing_days'] == 0) ? gmdate("Y-m-" . $accountdata['invoice_day'] . " 23:59:59", strtotime($ordervalue['next_billing_date'] . "+10 years")) : gmdate("Y-m-" . $accountdata['invoice_day'] . " 23:59:59", strtotime($ordervalue['next_billing_date'] . " + " . ($ordervalue['billing_days']) . " days")),
								);

								$final_array = array_merge($accountdata, $product_info);
								$final_array['next_billing_date'] = $update_order_arr['next_billing_date'];
								$last_payment_id = $this->payment->add_payments_transcation($product_info, $accountdata, $account_currency_info);
								if ($last_payment_id != '') {
									$update_invoice_item = "update invoices set payment_id = " . $last_payment_id . " where accountid=" . $accountinfo['id'] . " AND id = " . $invoiceid . "";
									$this->db->query($update_invoice_item);
									$update_invoice_detail_item = "update invoice_details set order_item_id = " . $ordervalue['order_id'] . " where accountid=" . $accountinfo['id'] . " AND invoiceid = " . $invoiceid . " AND charge_type = 'PACKAGE' AND created_date >='" . $this->StartDate . "' AND created_date <= '" . $this->EndDate . "'";
									$this->db->query($update_invoice_detail_item);
									$this->common->mail_to_users("product_renewed", $final_array);

								}

								$this->db->update("counters", array(
									"status" => 0,
								), array(
									"product_id" => $ordervalue['product_id'],
									"accountid" => $ordervalue['accountid'],
								));
								$counter_update_arr = array(
									"product_id" => $ordervalue['product_id'],
									"accountid" => $ordervalue['accountid'],
									"status" => 0,
								);
								$this->invoice_log->write_log('update_counter', json_encode($counter_update_arr));
								$counters_insert_arr = array(
									"used_seconds" => 0,
									"product_id" => $ordervalue['product_id'],
									"accountid" => $ordervalue['accountid'],
									"package_id" => $ordervalue['id'],
									"type" => 1,
									"status" => 1,
								);
								$this->db->insert("counters", $counters_insert_arr);
								$counter_id = $this->db->insert_id();
								$counters_log_insert_arr = array(
									"used_seconds" => 0,
									"product_id" => $ordervalue['product_id'],
									"accountid" => $ordervalue['accountid'],
									"package_id" => $ordervalue['id'],
									"counter_id" => $counter_id,
									"type" => 1,
									"status" => 1,
								);
								$this->invoice_log->write_log('insert_counter', json_encode($counters_log_insert_arr));
								$this->db->update("order_items", $update_order_arr, array(
									"id" => $ordervalue['id'],
								));
							}
						} else {
							$no_acc_product_insert_arr = array(
								"cron_date" => $this->CurrentDate,
								"account" => $accountdata,
								"order_id" => $ordervalue['id'],
								'message' => "Produto nao encontrado para a conta.",
							);
							$this->invoice_log->write_log('no_get_account_product_info', json_encode($no_acc_product_insert_arr));
							/*$update_order_arr = array(
								                "is_terminated" => '1',
								                "termination_note" => "Product has been terminated",
								                "termination_date" => $this->CurrentDate
								              );
								              $this->db->update("order_items", $update_order_arr, array(
								                "id" => $ordervalue['id']
								              ));
								              if ($product_info['product_category'] == 4)
								              {
								                $this->db->update("dids", $did_update_array, array(
								                  "product_id" => $ordervalue['product_id']
								                ));
							*/

						}

					}
				} else {
					$no_product_insert_arr = array(
						"cron_date" => $this->CurrentDate,
						"product_id" => $productdatalog,
						'message' => "Produto nao encontrado.",

					);
					$this->invoice_log->write_log('not_found_product', json_encode($no_product_insert_arr));
					$this->InvoiceLogger('renew_product', $product_data);

				}
			}
		} else {
			$no_renew_insert_arr = array(
				"cron_date" => $this->CurrentDate,
				'message' => "Nenhum pedido para renovação.",

			);
			$this->invoice_log->write_log('no_renew', json_encode($no_renew_insert_arr));

		}

	}

	function product_renewal_reminder() {
		$renewable_order = "SELECT  order_items.*,notify_before_day from order_items inner join invoice_conf ON invoice_conf.accountid = IF(order_items.reseller_id=0,1,order_items.reseller_id) where order_items.is_terminated =0 and   order_items.next_billing_date <= DATE(DATE_ADD('" . $this->CurrentDate . "', INTERVAL invoice_conf.notify_before_day  DAY))";

		$renewable_order = $this->db->query($renewable_order);

		if ($renewable_order->num_rows > 0) {
			$renewable_order = $renewable_order->result_array();
			foreach ($renewable_order as $orderkey => $ordervalue) {

				$product_info = $this->db_model->getSelect("name,status,price,can_purchase,billing_days,billing_type,can_resell,reseller_id", "products", array(
					"id" => $ordervalue['product_id'],
					"status" => "0",
				));
				if ($product_info->num_rows > 0) {
					$product_info = $product_info->result_array()[0];
					$log_product_info = $product_info->result_array()[0];
					$reseller_id = ($ordervalue['reseller_id'] > 0) ? $ordervalue['reseller_id'] : 0;
					$account_info = $this->db_model->getSelect("*", "accounts", array(
						"id" => $ordervalue['accountid'],
						"reseller_id" => $reseller_id,
						"status" => 0,
						"deleted" => 0,
					));
					if ($product_info['status'] == 0) {
						$reseller_id = ($ordervalue['reseller_id'] > 0) ? $ordervalue['reseller_id'] : 0;
						$account_data = $this->db_model->getSelect("*", "accounts", array(
							"id" => $ordervalue['accountid'],
							"reseller_id" => $reseller_id,
							"status" => 0,
							"deleted" => 0,
						));

						if ($account_data->num_rows > 0) {
							$account_info = $account_data->result_array()[0];
							$final_array = array_merge($account_info, $product_info);

							$final_array['billing_date'] = $ordervalue['next_billing_date'];
							$final_array['next_billing_date'] = ($product_info['billing_days'] == 0) ? gmdate('Y-m-' . $account_info['invoice_day'] . ' 23:59:59', strtotime('+10 years')) : gmdate("Y-m-" . $account_info['invoice_day'] . " 23:59:59", strtotime("+" . ($product_info['billing_days'] - 1) . " days"));
							$final_array['product_name'] = $product_info['name'];
							if ($product_info['status'] == '1' || $product_info['billing_type'] == '0') {
								$final_array['next_billing_date'] = $ordervalue['termination_date'];
								$this->common->mail_to_users("product_release", $final_array);
								$this->invoice_log->write_log('billing_type', json_encode($final_array));
							} else if (($product_info['can_purchase'] == 1 || $product_info['can_resell'] == 1) && $product_info['reseller_id'] == $ordervalue['reseller_id'] && $ordervalue['reseller_id'] > 0) {

								$this->common->mail_to_users("product_renewal_notice", $final_array);

							} else {

								$this->common->mail_to_users("product_renewal_notice", $final_array);

							}
						}
					} else {

						$no_product_insert_arr = array(
							"cron_date" => $this->CurrentDate,
							'query' => $log_product_info,
							'message' => "Produto desativado.",

						);
						$this->invoice_log->write_log('product_no_status', json_encode($no_product_insert_arr));

					}
				} else {

				}
			}
		}
	}
	
	
	function renew_product_service() {
			$is_apply_commission = "false";
			$renewable_order = $this->db_model->getJionQuery('orders', 'orders.payment_status,orders.order_id as order_number,order_items.id,order_items.order_id,order_items.product_category,order_items.product_id,
	order_items.quantity,order_items.billing_type,order_items.billing_days,order_items.free_minutes,
	order_items.billing_date,order_items.next_billing_date,order_items.is_terminated ,order_items.termination_date,
	order_items.termination_note,order_items.from_currency,order_items.exchange_rate,order_items.to_currency,
	order_items.reseller_id,order_items.accountid,order_items.setup_fee,order_items.price', array(
				"order_items.next_billing_date <=" => $this->CurrentDate,
				"order_items.product_category <>" => "3",
				"order_items.is_terminated" => "0",
				"orders.payment_status <>" => "FAIL",
			), 'order_items', 'orders.id=order_items.order_id', 'inner', '', '', '', '');
			if ($renewable_order->num_rows > 0) {
				$renewable_order = $renewable_order->result_array();
				foreach ($renewable_order as $orderkey => $ordervalue) {
					$orderobjArr = array();
					$parentdata = array();
					$parent_array = array();
					$parent_key_arr = array();
					$productdata = array(
						"product_id" => $ordervalue['product_id'],
					);
					$productdatalog = array(
						"product_id" => $ordervalue['product_id'],
					);
	
					$product_data = $this->db_model->getSelect("*", "products", array(
						"id" => $ordervalue['product_id'],
						'is_deleted' => "0",
						'status' => "0",
					));
					if ($product_data->num_rows() > 0) {
						$accountdata = $this->db_model->getSelect("*", "accounts", array(
							"id" => $ordervalue["accountid"],
							'deleted' => "0",
							"status" => "0",
						));
						if ($accountdata->num_rows() > 0) {
							$accountdata = $accountdata->result_array()[0];
							$account_currency_info = $this->db_model->getSelect("*", "currency", array(
								"id" => $accountdata['currency_id'],
							));
							if ($account_currency_info->num_rows > 0) {
								$account_currency_info = (array) $account_currency_info->result_array();
								$account_currency_info = $account_currency_info[0];
							} else {
								{
									$base_currency = Common_model::$global_config['system_config']['base_currency'];
									$account_currency_info = $this->db_model->getSelect("*", "currency", array(
										"currency" => $base_currency,
									));
									$account_currency_info = (array) $account_currency_info->result_array();
									$account_currency_info = $account_currency_info[0];
								}
	
							}
							$user_product_info = $this->order->get_account_product_info($orderobjArr, (object) $accountdata, $productdata);
							if (!empty($user_product_info) && $product_data->num_rows() > 0) {
								$is_process = true;
								$user_product_info->price = $ordervalue['price'];
								$user_product_info->quantity = $ordervalue['quantity'];
								$user_product_info->setup_fee = $ordervalue['setup_fee'];
								$user_product_info->billing_days = $ordervalue['billing_days'];
								$product_info = (array) $user_product_info;
								$total_amt = ($ordervalue['price'] * $ordervalue['quantity']);
								if ($accountdata['posttoexternal'] == 1) {
									$account_balance = $accountdata['credit_limit'];
								} else {
	
									$account_balance = $accountdata['balance'];
	
								}
	
								//		$account_balance = $accountdata ['posttoexternal'] == 1 ? $accountdata ['credit_limit'] - ($accountdata ['balance']) :        $accountdata ['balance'];
								$product_info['product_name'] = $product_info['name'];
								$final_array = array_merge($accountdata, $product_info);
								$acc_id = '';
								$order_id = '';
	
								$acc_id = $this->common->get_field_name("id", "accounts", array(
									"number" => $final_array['number'],
								));
								$order_id = $this->common->get_field_name("order_id", "orders", array(
									"id" => $ordervalue['order_id'],
								));
								$final_array['order_id'] = $order_id;
								$final_array['next_billing_date'] = $this->common->get_field_name("next_billing_date", "order_items", array(
									"order_id" => $ordervalue['order_id'],
								));
								$update_order_arr = array(
									"is_terminated" => '1',
									"termination_date" => $this->CurrentDate,
									"termination_note" => "Product has been terminated",
								);
								$did_update_array = array(
									"accountid" => 0,
									"call_type" => 0,
									"extensions" => "",
									"always" => 0,
									"always_destination" => "",
									"user_busy" => 0,
									"user_busy_destination" => "",
									"user_not_registered" => 0,
									"user_not_registered_destination" => "",
									"no_answer" => 0,
									"no_answer_destination" => "",
									"call_type_vm_flag" => 1,
									"failover_call_type" => 1,
									"always_vm_flag" => 1,
									"user_busy_vm_flag" => 1,
									"user_not_registered_vm_flag" => 1,
									"no_answer_vm_flag" => 1,
									"failover_extensions" => "",
								);
	
								if ($product_info['release_no_balance'] == 0 && $product_info['product_category'] == 1) {
									if ($account_balance < $total_amt) {
										$is_process = false;
										$this->db->update("order_items", $update_order_arr, array(
											"id" => $ordervalue['id'],
										));
										$final_array['next_billing_date'] = $update_order_arr['termination_date'];
										$this->common->mail_to_users("product_release", $final_array);
										$no_account_balance_insert_arr = array(
											"cron_date" => $this->CurrentDate,
											"account_number" => $final_array['number'],
											"product_category" => $product_info['product_category'],
											"order_id" => $ordervalue['id'],
											"account_balance" => $account_balance,
											"product_total" => $total_amt,
											'message' => "Produto removido por falta de saldo",
										);
										$this->invoice_log->write_log('no_get_account_product_info', json_encode($no_account_balance_insert_arr));
										//LOG
	
									}
								}
								if ($is_process == true) {
									$parentdata = $this->db_model->getSelect("*", "accounts", array(
										"id" => $ordervalue["reseller_id"],
									));
									$parentdata = $parentdata->first_row();
	
									$product_info['payment_status'] = "PAID";
									$product_info['payment_by'] = "Account Balance";
									$product_info['order_item_id'] = $ordervalue['order_id'];
									$product_info['invoice_type'] = "debit";
									$product_info['is_apply_tax'] = "false";
	//                $product_info['add_invoice_credit']= "true";
									$product_info['charge_type'] = $this->common->get_field_name("code", "category", array(
										"id" => $product_info['product_category'],
									));
									$product_info['description'] = $product_info['charge_type'] . " (" . $product_info['name'] . ") has been renewed.";
	
									$update_order_arr = array(
										"billing_date" => $this->CurrentDate,
										"next_billing_date" => ($ordervalue['billing_days'] == 0) ? gmdate("Y-m-" . $accountdata['invoice_day'] . " 23:59:59", strtotime($ordervalue['next_billing_date'] . "+10 years")) : gmdate("Y-m-" . $accountdata['invoice_day'] . " 23:59:59", strtotime($ordervalue['next_billing_date'] . " + " . ($ordervalue['billing_days']) . " days")),
									);
	
									$final_array = array_merge($accountdata, $product_info);
									$final_array['next_billing_date'] = $update_order_arr['next_billing_date'];
									$last_payment_id = $this->payment->add_payments_transcation($product_info, $accountdata, $account_currency_info);
									if ($last_payment_id != '') {
										$this->common->mail_to_users ( "product_renewed", $final_array );
									
									}
	
									$this->db->update("counters", array(
										"status" => 0,
									), array(
										"product_id" => $ordervalue['product_id'],
										"accountid" => $ordervalue['accountid'],
									));
									$counter_update_arr = array(
										"product_id" => $ordervalue['product_id'],
										"accountid" => $ordervalue['accountid'],
										"status" => 0,
									);
									$this->invoice_log->write_log('update_counter', json_encode($counter_update_arr));
									$counters_insert_arr = array(
										"used_seconds" => 0,
										"product_id" => $ordervalue['product_id'],
										"accountid" => $ordervalue['accountid'],
										"package_id" => $ordervalue['id'],
										"type" => 1,
										"status" => 1,
									);
									$this->db->insert("counters", $counters_insert_arr);
									$counter_id = $this->db->insert_id();
									$counters_log_insert_arr = array(
										"used_seconds" => 0,
										"product_id" => $ordervalue['product_id'],
										"accountid" => $ordervalue['accountid'],
										"package_id" => $ordervalue['id'],
										"counter_id" => $counter_id,
										"type" => 1,
										"status" => 1,
									);
									$this->invoice_log->write_log('insert_counter', json_encode($counters_log_insert_arr));
									$this->db->update("order_items", $update_order_arr, array(
										"id" => $ordervalue['id'],
									));
								}
							} else {
								$no_acc_product_insert_arr = array(
									"cron_date" => $this->CurrentDate,
									"account" => $accountdata,
									"order_id" => $ordervalue['id'],
									'message' => "Produto nao encontrado para a conta.",
								);
								$this->invoice_log->write_log('no_get_account_product_info', json_encode($no_acc_product_insert_arr));
								/*$update_order_arr = array(
									                "is_terminated" => '1',
									                "termination_note" => "Product has been terminated",
									                "termination_date" => $this->CurrentDate
									              );
									              $this->db->update("order_items", $update_order_arr, array(
									                "id" => $ordervalue['id']
									              ));
									              if ($product_info['product_category'] == 4)
									              {
									                $this->db->update("dids", $did_update_array, array(
									                  "product_id" => $ordervalue['product_id']
									                ));
								*/
	
							}
	
						}
					} else {
						$no_product_insert_arr = array(
							"cron_date" => $this->CurrentDate,
							"product_id" => $productdatalog,
							'message' => "Produto nao encontrado.",
	
						);
						$this->invoice_log->write_log('not_found_product', json_encode($no_product_insert_arr));
						$this->InvoiceLogger('renew_product', $product_data);
	
					}
				}
			} else {
				$no_renew_insert_arr = array(
					"cron_date" => $this->CurrentDate,
					'message' => "Nenhum pedido para renovação.",
	
				);
				$this->invoice_log->write_log('no_renew', json_encode($no_renew_insert_arr));
	
			}
	
		}

	function PrintLogger($Error_flag, $Message) {
		if ($Error_flag) {
			if (is_array($Message)) {
				foreach ($Message as $MessageKey => $MessageValue) {
					if (is_array($MessageValue)) {
						foreach ($MessageValue as $LogKey => $LogValue) {
						        $this->invoice_log->write_log(''.$LogKey.'', json_encode($LogValue));
//							fwrite($this->fp, "::::: " . $LogKey . " ::::: " . $LogValue . " :::::\n");
						}
					} else {
					       $this->invoice_log->write_log(''.$MessageKey.'', json_encode($MessageValue));
	//					fwrite($this->fp, "::::: " . $MessageKey . " ::::: " . $MessageValue . " :::::\n");
					}
				}
			} else {
				if ($this->Error_flag) {
				         $this->invoice_log->write_log('error_invoice', json_encode($Message));
	//				fwrite($this->fp, "::::: " . $Message . " :::::\n");
				}
			}
		}
	}

	function get_system_config() {
		$query = $this->db->get("system");
		$config = array();
		$result = $query->result_array();
		foreach ($result as $row) {
			$config[$row['name']] = $row['value'];
		}
		self::$global_config['system_config'] = $config;
	}
}

?>
