<?php

class ProcessInvoice extends MX_Controller
{

    public static $global_config;
    public $Error_flag = true;

    public $CurrentDate = "";
    public $StartDate = "";
    public $EndDate = "";
    public $fp = "";

    function __construct()
    {
        parent::__construct();
        $this->load->model("db_model");
        $this->load->library("flux/common");
        $this->load->library("flux/order");
	$this->load->model("common_model");


	error_reporting("E_ALL");
	ini_set("memory_limit", "2048M");
	ini_set("max_execution_time", "259200");

        $this->get_system_config();

//        $this->fp = fopen("/var/www/html/flux/application/logs/flux-invoice.log", "a+");
         $this->fp = fopen("/var/log/flux/flux-invoice.log", "a+");

//        $this->CurrentDate = gmdate("Y-m-d 00:00:01");
//	$this->custom_current_date = gmdate("Y-m-d 23:59:59");
	$this->CurrentDate = "2023-05-02 00:00:01";
	$this->custom_current_date = "2023-05-02 23:59:59";
    }

    function ManageServices(){

        $this->PrintLogger($this->Error_flag,"::::: SERVICES & PRODUCT MANAGEMENT PROCESS START ::::: \n");
        $this->PrintLogger($this->Error_flag,":::::" . gmdate("Y-m-d H:i:s") . ":::::\n");

        $this->product_renewal_reminder();
        $this->renew_product();
    }


    function GenerateInvoice()
    {
        $this->PrintLogger($this->Error_flag,"::::: INVOICE PROCESS START ::::: \n");
        $this->PrintLogger($this->Error_flag,":::::" . gmdate("Y-m-d H:i:s") . ":::::\n");

	$this->db->where_in("type",array(0,1,3));
	$accountsdata = $this->db_model->getSelect("*", "accounts", array("status" => "0","deleted"=>0,"posttoexternal"=>1));
	if($accountsdata->num_rows > 0){
		$accountsdata = $accountsdata->result_array();
		foreach($accountsdata as $accountkey => $accountvalue){
			if($accountvalue['generate_invoice'] == '0'){
			        $this->generate_invoices($accountvalue);
			}

		}
	}

        exit();
    }

    function generate_invoices($accountinfo){
	$this->StartDate = ($accountinfo['last_bill_date'] == '0000-00-00 00:00:00')?$accountinfo['creation']:$accountinfo['last_bill_date'];
	$this->StartDate = date ( "Y-m-d 00:00:01", strtotime ( $this->StartDate ) );
	switch ($accountinfo ['sweep_id']) {

		case 0 :
			if (Strtotime ( $this->StartDate ) > strtotime ( $this->CurrentDate )) {
				$this->StartDate = date ( "Y-m-d 00:00:01", strtotime ( $this->CurrentDate . " - 1 days" ) );
			}
			$this->EndDate = date ( "Y-m-d 23:59:59", strtotime ( $this->CurrentDate . " - 1 days" ) );

			$invoiceid = $this->create_invoice($accountinfo);
			$this->bill_calls($accountinfo,$invoiceid);
			$this->apply_taxes($accountinfo,$invoiceid);

			break;
		case 2 :
			if (gmdate ( "d", strtotime ( "-1 days" ) ) == $accountinfo ['invoice_day']) {
				$this->EndDate = date ( "Y-m-" . $accountinfo ['invoice_day'] . " 23:59:59", strtotime ( $this->StartDate . " + 1 month" ) );
				if (Strtotime ( $this->EndDate ) > strtotime ( $this->CurrentDate )) {
					$this->EndDate = $this->CurrentDate;
				}

				$invoiceid = $this->create_invoice($accountinfo);
				$this->bill_calls($accountinfo,$invoiceid);
				$this->apply_taxes($accountinfo,$invoiceid);
			}
			break;
	}
 		//$this->db->where("id",$accountinfo['id']);
		//$this->db->update("accounts",array("last_bill_date" => $this->EndDate));



    }

    function create_invoice($accountinfo)
    {
        $invoiceconf = $this->common->Get_Invoice_configuration($accountinfo);
       	if($invoiceconf != ''){
			if ($invoiceconf['interval'] > 0) {
			    $DueDate = date("Y-m-d 23:59:59", strtotime($this->CurrentDate . " +" . $invoiceconf['interval'] . " days"));
			} else {
			    $DueDate = date("Y-m-d 23:59:59", strtotime($this->CurrentDate . " +7 days"));
			}

			$last_invoice_ID = $this->common->get_invoice_date("number", "", $accountinfo['reseller_id']);

			if ($last_invoice_ID && $last_invoice_ID > 0) {
			    $last_invoice_ID = ($last_invoice_ID + 1);

			    if ($last_invoice_ID < $invoiceconf['invoice_start_from'])
				$last_invoice_ID = $invoiceconf['invoice_start_from'];
			} else {
			    $last_invoice_ID = $invoiceconf['invoice_start_from'];
			}
			$last_invoice_ID = str_pad($last_invoice_ID, 6, '0', STR_PAD_LEFT);
			$automatic_flag = self::$global_config['system_config']['automatic_invoice'];


		if($invoiceconf['no_usage_invoice'] == 0){

					if ($automatic_flag == 0) {
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
						"confirm" => 1,
						"notes"=>$accountinfo['invoice_note'],
						"is_deleted" =>0
					    );
					}
					else {
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
						"confirm" => 0,
						"notes"=>$accountinfo['invoice_note'],
						"is_deleted"=>0
					    );
					}

			$this->db->insert("invoices", $InvoiceData);
			$invoiceid = $this->db->insert_id();

			 $update_billable_item = "update invoice_details set invoiceid = ".$invoiceid." where accountid=" . $accountinfo['id'] . " AND created_date >='" .$this->StartDate. "' AND created_date <= '" .$this->EndDate. "' AND invoiceid = 0";

            $this->db->where("id",$accountinfo['id']);
            $this->db->update("accounts",array("balance" => $accountinfo['credit_limit']));

// $this->db->where("id",$accountinfo['id']);
//            $this->db->update("accounts",array("balance" => "0"));

			$this->db->query($update_billable_item);
			$amount = $this->db_model->getSelect("debit,credit","invoice_details",array("invoiceid"=>$invoiceid));
			if($amount->num_rows > 0){
				$amount = $amount->result_array()[0];
				$InvoiceData ['amount'] = ( $amount['credit'] - $amount['debit']);
				$InvoiceData ['amount'] = ($InvoiceData ['amount'] < 0)?($InvoiceData ['amount']*-1):$InvoiceData ['amount'];
				$InvoiceData['invoice_number']=$invoiceconf['invoice_prefix'].$last_invoice_ID;
				$final_array = array_merge($accountinfo,$InvoiceData);
				$this->common->mail_to_users("new_invoice",$final_array);
			}
			return $invoiceid;
		}
		else {

		if ($automatic_flag == 0) {
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
						"confirm" => 1,
						"notes"=>$accountinfo['invoice_note'],
						"is_deleted" =>0
					    );
					}
					else {
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
						"confirm" => 0,
						"notes"=>$accountinfo['invoice_note'],
						"is_deleted"=>0
					    );
					}

			$this->db->insert("invoices", $InvoiceData);
			$invoiceid = $this->db->insert_id();

			 $update_billable_item = "update invoice_details set invoiceid = ".$invoiceid." where accountid=" . $accountinfo['id'] . " AND created_date >='" .$this->StartDate. "' AND created_date <= '" .$this->EndDate. "' AND invoiceid = 0";

   //         $this->db->where("id",$accountinfo['id']);
    //        $this->db->update("accounts",array("balance" => $accountinfo['credit_limit']));

     $this->db->where("id",$accountinfo['id']);
            $this->db->update("accounts",array("balance" => "0"));

			$this->db->query($update_billable_item);
			$amount = $this->db_model->getSelect("debit,credit","invoice_details",array("invoiceid"=>$invoiceid));
			if($amount->num_rows > 0){
				$amount = $amount->result_array()[0];
				$InvoiceData ['amount'] = ( $amount['credit'] - $amount['debit']);
				$InvoiceData ['amount'] = ($InvoiceData ['amount'] < 0)?($InvoiceData ['amount']*-1):$InvoiceData ['amount'];
				$InvoiceData['invoice_number']=$invoiceconf['invoice_prefix'].$last_invoice_ID;
				$final_array = array_merge($accountinfo,$InvoiceData);
				$this->common->mail_to_users("new_invoice",$final_array);
			}
			return $invoiceid;


		}
	}
    }

    function apply_taxes($accountinfo,$invoiceid){

 	$get_total_billable_item = "select count(id) as count,sum(debit) as debit,sum(credit) as credit from invoice_details where accountid=" . $accountinfo['id'] . " AND charge_type != 'REFILL' AND product_category != 3 AND created_date >='" .$this->StartDate. "' AND created_date <= '" .$this->EndDate. "' AND invoiceid = ".$invoiceid;


        $get_total_billable_item = $this->db->query($get_total_billable_item);
        if ($get_total_billable_item->num_rows() > 0) {
            $total_billable_item = $get_total_billable_item->result_array()[0];


	    $tax_calculation=$this->common_model->calculate_taxes($accountinfo,$total_billable_item["debit"]);

	    if(isset($tax_calculation['tax']) && !empty($tax_calculation['tax'] && $total_billable_item["debit"] > 0)){

		$base_currency = Common_model::$global_config ['system_config'] ['base_currency'];
		$account_balance = $accountinfo ['posttoexternal'] == 1 ? $accountinfo ['credit_limit'] - ($accountinfo ['balance']) : $accountinfo ['balance'];
		$debit = isset($tax_calculation['total_tax'])?$tax_calculation['total_tax']:"0.00";
		$credit = "0.00";
		$after_balance = $account_balance - $debit;

		$account_currency_info = $this->db_model->getSelect("*","currency",array("id"=>$accountinfo['currency_id']));
		if($account_currency_info->num_rows > 0){
			$account_currency_info = $account_currency_info->result_array();
			$account_currency_info = $account_currency_info[0];
		}

		foreach($tax_calculation['tax'] as $tax_key => $tax){
			$tax_insert_arr = array (
					"accountid" => $accountinfo['id'],
					"description" => $tax_key,
					"created_date" => $this->EndDate,
					"invoiceid" => $invoiceid,
					"reseller_id" => $accountinfo['reseller_id'],
					"is_tax"=>1,
					"order_item_id" => 0,
					"payment_id"=> 0,
					'before_balance' =>$account_balance,
					'product_category'=>'0',
					'charge_type'=> "TAX",
					'after_balance'=>$after_balance,
					'base_currency'=>$base_currency,
					'exchange_rate'=>$account_currency_info['currencyrate'],
					'account_currency'=>$account_currency_info['currency'],
					'debit'=>$tax,
					'credit'=>0

			      );
			$this->db->insert("invoice_details",$tax_insert_arr);

		}
	    }
        }
    }

	function bill_calls($accountinfo,$invoiceid){
	   $billable_calls_qr = "select calltype,sum(debit) as debit,sum(billseconds) as duration from cdrs where accountid =" . $accountinfo['id'] . " AND callstart >='" .$this->StartDate. "' AND callstart <= '" .$this->EndDate. "' AND invoiceid=0 group by calltype";


        $billable_calls = $this->db->query($billable_calls_qr);

        if ($billable_calls->num_rows() > 0) {
            $billable_calls = $billable_calls->result_array();
            $account_limit_info = $this->db_model->getSelect("credit_limit", "accounts", array("id"=>$accountinfo["id"]));
 	    $base_currency = Common_model::$global_config ['system_config'] ['base_currency'];
	    $deciamal_point = Common_model::$global_config ['system_config'] ['decimalpoints'];
	    $account_currency_info = $this->db_model->getSelect("*","currency",array("id"=>$accountinfo['currency_id']));
		if($account_currency_info->num_rows > 0){
			$account_currency_info = $account_currency_info->result_array();
			$account_currency_info = $account_currency_info[0];
	    }
            foreach ($billable_calls as $calls) {

        if ($calls['calltype'] == "") {
                    $calls['calltype'] = "Padrao";
        }
		$seconds = $calls['duration'];
		$minutes = floor($seconds/60);
		$secondsleft = $seconds%60;
		if($minutes<10) {
			$minutes = "0" . $minutes;
		}
		if($secondsleft<10) {
			$secondsleft = "0" . $secondsleft;
        }
        if ($calls['calltype'] == "Gratuita" || $calls['calltype'] == "FREE" || $calls['calltype'] == "Chamada Gratuita") {
                    $calls['debit'] = 0;
                }
        $tempArr = array(
                    "accountid" => $accountinfo['id'],
                    "reseller_id" => $accountinfo['reseller_id'],
                    "order_item_id" => "0",
                    "description" => $calls['calltype'],
                    "debit" => $calls['debit'],
                    "charge_type" => $calls['calltype'],
                    "created_date" => $this->EndDate,
		    'base_currency'=>$base_currency,
		    'exchange_rate'=>$account_currency_info['currencyrate'],
		    'account_currency'=>$account_currency_info['currency'],
                    "invoiceid" => $invoiceid,
                );
                if ($this->Error_flag) {
                $this->PrintLogger($this->Error_flag,"::::: INVOICE PROCESS ERROR ::::: \n");
                $this->PrintLogger($this->Error_flag,":::::" . $tempArr . ":::::\n");
                }
                $this->db->insert("invoice_details", $tempArr);
            }
        $this->update_bill_date($accountinfo);
        }
        else {
        $account_limit_info = $this->db_model->getSelect("credit_limit", "accounts", array("id"=>$accountinfo["id"]));
 	    $base_currency = Common_model::$global_config ['system_config'] ['base_currency'];
	    $deciamal_point = Common_model::$global_config ['system_config'] ['decimalpoints'];
	    $account_currency_info = $this->db_model->getSelect("*","currency",array("id"=>$accountinfo['currency_id']));
		if($account_currency_info->num_rows > 0){
			$account_currency_info = $account_currency_info->result_array();
			$account_currency_info = $account_currency_info[0];
	    }

        $tempArr = array(
                    "accountid" => $accountinfo['id'],
                    "reseller_id" => $accountinfo['reseller_id'],
                    "order_item_id" => "0",
                    "description" => "Invoice sem Cobrança",
                    "debit" => 0,
                    "charge_type" => "Invoice sem Cobrança",
                    "created_date" => $this->EndDate,
		    'base_currency'=>$base_currency,
		    'exchange_rate'=>$account_currency_info['currencyrate'],
		    'account_currency'=>$account_currency_info['currency'],
                    "invoiceid" => $invoiceid,
                );
        $this->db->insert("invoice_details", $tempArr);
        $this->update_bill_date($accountinfo);


        }
    }
     function renew_product(){
	$is_apply_commission = "false";
/*	$renewable_order = $this->db_model->getJionQuery('orders', 'orders.payment_status,order_items.id,order_items.order_id,order_items.product_category,order_items.product_id,
order_items.quantity,order_items.billing_type,order_items.billing_days,order_items.free_minutes,
order_items.billing_date,order_items.next_billing_date,order_items.is_terminated ,order_items.termination_date,
order_items.termination_note,order_items.from_currency,order_items.exchange_rate,order_items.to_currency,
order_items.reseller_id,order_items.accountid,order_items.setup_fee,order_items.price',array("DATE_SUB(order_items.next_billing_date, INTERVAL 2 HOUR) >="=>gmdate("Y-m-d 21:58:00"),"order_items.next_billing_date <=" => $this->custom_current_date,"order_items.product_category <>"=>"3", "order_items.is_terminated" => "0","orders.payment_status <>"=>"FAIL"),'order_items','orders.id=order_items.order_id', 'inner', '' ,'','','');*/

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

	if($renewable_order->num_rows > 0){

		$renewable_order = $renewable_order->result_array();

		foreach($renewable_order as $orderkey => $ordervalue){
			$orderobjArr = array();
			$parentdata = array();
			$parent_array = array();
			$parent_key_arr = array();
			$productdata = array("product_id"=>$ordervalue['product_id']);
		        $accountdata = $this->db_model->getSelect("*", "accounts", array("id"=>$ordervalue["accountid"],"status"=>0));
			$accountdata = $accountdata->result_array()[0];

		    	$account_currency_info = $this->db_model->getSelect("*","currency",array("id"=>$accountdata['currency_id']));
		      if($account_currency_info->num_rows > 0){
				$account_currency_info = (array)$account_currency_info->result_array();
				$account_currency_info = $account_currency_info[0];
		      }
			$user_product_info = $this->order->get_account_product_info($orderobjArr,(object)$accountdata,$productdata);

		        if (!empty($user_product_info)) {
			    $is_process = true;

				    $user_product_info->price= $ordervalue['price'];
				    $user_product_info->quantity= $ordervalue['quantity'];
				    $user_product_info->setup_fee= $ordervalue['setup_fee'];
				    $user_product_info->billing_days= $ordervalue['billing_days'];
				    $product_info = (array)$user_product_info;
					$total_amt = ($ordervalue['price']*$ordervalue['quantity']);
					$account_balance = $accountdata ['posttoexternal'] == 1 ? $accountdata ['credit_limit'] - ($accountdata ['balance']) : $accountdata ['balance'];
			     		$final_array = array_merge($accountdata,$product_info);
			     		$acc_id='';
			     		$order_id='';

			     		$acc_id=$this->common->get_field_name("id","accounts",array("number"=>$final_array['number']));
			     		$order_id=$this->common->get_field_name("order_id","orders",array("id"=>$ordervalue['order_id']));
			     		$final_array['order_id']=$order_id;
			     		$final_array['next_billing_date']=$this->common->get_field_name("next_billing_date","order_items",array("order_id"=>$ordervalue['order_id']));
						$update_order_arr = array("is_terminated"=>'1',
							      "termination_date"=> $this->CurrentDate,
							      "termination_note" => "Product has been terminated"
							    );
						$did_update_array  = array("accountid"=>0,"call_type"=>0,"extensions"=>"","always"=>0,"always_destination"=>"","user_busy"=>0,"user_busy_destination"
=>"","user_not_registered"=>0,"user_not_registered_destination"=>"","no_answer"=>0,"no_answer_destination"=>"","call_type_vm_flag"=>1,
"failover_call_type"=>1,"always_vm_flag"=>1,"user_busy_vm_flag"=>1,"user_not_registered_vm_flag"=>1,"no_answer_vm_flag"=>1,"failover_extensions"=>"");
					if($product_info['status'] == 1 ||  $ordervalue['billing_type'] == 0){
							$is_process = false;
							$this->db->update("order_items",$update_order_arr,array("id"=>$ordervalue['id']));
						if($product_info['product_category'] == 4){
							$this->db->update("dids",$did_update_array,array("product_id"=>$ordervalue['product_id']));
						}
						$final_array['next_billing_date'] = $update_order_arr['termination_date'];
						$this->common->mail_to_users ( "product_release", $final_array );

					} if(($product_info['can_purchase'] == 1 ||$product_info['can_resell'] == 1) && ($product_info['reseller_id'] == $ordervalue['reseller_id'] && $ordervalue['reseller_id'] > 0)){
							$is_process = false;
							$this->db->update("order_items",$update_order_arr,array("id"=>$ordervalue['id']));
						if($product_info['product_category'] == 4){
							$this->db->update("dids",$did_update_array,array("product_id"=>$ordervalue['product_id']));
						}
						$final_array['next_billing_date'] = $update_order_arr['termination_date'];
						$this->common->mail_to_users ( "product_release", $final_array );
				     }

					if($product_info['release_no_balance'] == 0){
					 	if($account_balance < $total_amt){
							$is_process = false;
							$this->db->update("order_items",$update_order_arr,array("id"=>$ordervalue['id']));
						if($product_info['product_category'] == 4){
							$this->db->update("dids",$did_update_array,array("product_id"=>$ordervalue['product_id']));
						}
							$final_array['next_billing_date'] = $update_order_arr['termination_date'];
							$this->common->mail_to_users ( "product_release", $final_array );
						}
					}
				if($is_process == true){
					$parentdata = $this->db_model->getSelect("*", "accounts", array("id"=>$ordervalue["reseller_id"]));
					$parentdata = $parentdata->first_row();
			    		if((isset($parentdata->is_distributor) && $parentdata->is_distributor == 1 && $parentdata->type == 1 && $ordervalue["reseller_id"]>0)){
						$parent_array[$parentdata->id] = $parentdata;
						$parent_key_arr[] = $parentdata->id;
						$parent_array[$parentdata->id]->currecny_info = $account_currency_info;
						$parent_array[$parentdata->id]->product_info = $user_product_info;
						$parent_array[$parentdata->id]->order_item_id= $ordervalue['id'];
						$parent_array[$parentdata->id]->product_id= $user_product_info->product_id;
						$parent_array[$parentdata->id]->description= "Product (".$user_product_info->name.") commission has been credited";
						if($parentdata->reseller_id > 0){

							$tempcomm = 0.00;
							$parent_reseller = $this->common->get_parent_info($parentdata->id, 0);
							$max_count = (count((explode(",",rtrim($parent_reseller,",")))));

							$comm_rate = $product_info['commission'];
							$product_amount = ($product_info['price']*$ordervalue['quantity']);

							for($i=1; $i<=$max_count; $i++){
								$tempcomm = (($product_amount*$comm_rate)/100);
								$product_amount =  $tempcomm;
							}
							$parent_array[$parentdata->id]->commission = $tempcomm;
							$parent_array[$parentdata->id]->reseller_id = 0;
						}else{
							$parent_commission = (($product_info['price']*$ordervalue['quantity']*$product_info['commission'])/100);

							$parent_array[$parentdata->id]->commission = $parent_commission;
						}

						$is_apply_commission = "true";
					}
				    $product_info['payment_status'] = "PAID";
				    $product_info['payment_by'] = "Account Balance";
			  	    $product_info['order_item_id']= $ordervalue['order_id'];
				    $product_info['invoice_type'] = "debit";

				    $product_info['is_apply_tax']= "false";
				    $product_info['charge_type'] = $this->common->get_field_name("code","category",array("id"=>$product_info['product_category']));
			   	 $product_info['description']= $product_info['charge_type']." (".$product_info['name'].") has been added.";

		    		$update_order_arr = array("billing_date"=>$this->CurrentDate,
						      "next_billing_date"=>($ordervalue['billing_days'] == 0)?gmdate("Y-m-d 23:59:59",strtotime($ordervalue['next_billing_date']."+10 years")):gmdate("Y-m-d 23:59:59",strtotime($ordervalue['next_billing_date']." + ".($ordervalue['billing_days'])." days")));

				$last_payment_id=$this->payment->add_payments_transcation($product_info,$accountdata,$account_currency_info);
				$final_array = array_merge($accountdata,$product_info);
				$final_array['next_billing_date'] = $update_order_arr['next_billing_date'];
				if($last_payment_id != '') {

							$this->common->mail_to_users ( "product_renewed", $final_array );
				}


					if($accountdata["reseller_id"] > 0 && $accountdata["is_distributor"] == 1  && $product_info['product_category'] != '4' && $is_apply_commission == "true"){

					$parent_array[$accountdata['id']] = (object)$accountdata;
					$parent_array[$accountdata['id']]->product_info->price = $product_info['price'];
					$parent_key_arr[] = $accountdata['id'];
					$this->order->product_commission($parent_array,$parent_key_arr);
						$product_info['amount'] = $parent_array[$parentdata->id]->commission;
						$final_array = array_merge($accountdata,$product_info);
						$this->common->mail_to_users ( "product_commission", $final_array );


				}
				$this->db->update("counters",array("used_seconds"=>0),array("product_id"=>$ordervalue['product_id'],"accountid"=>$ordervalue['accountid']));
				$this->db->update("order_items",$update_order_arr,array("id"=>$ordervalue['id']));

			   }
			}else{
				$update_order_arr = array("is_terminated"=>'1',
						      "termination_date"=> $this->CurrentDate,
						      "termination_note" => "Product has been terminated");
				$this->db->update("order_items",$update_order_arr,array("id"=>$ordervalue['id']));
				if($product_info['product_category'] == 4){
					$this->db->update("dids",$did_update_array,array("product_id"=>$ordervalue['product_id']));
				}

			}

		}
	}
    }
    function product_renewal_reminder(){
	$renewable_order = "SELECT  order_items.*,notify_before_day from order_items inner join invoice_conf ON invoice_conf.accountid = IF(order_items.reseller_id=0,1,order_items.reseller_id) where order_items.is_terminated =0 and   order_items.next_billing_date <= DATE(DATE_ADD('".$this->CurrentDate."', INTERVAL invoice_conf.notify_before_day  DAY))";

	$renewable_order =$this->db->query($renewable_order);


	if($renewable_order->num_rows > 0){
		$renewable_order = $renewable_order->result_array();
		foreach($renewable_order as $orderkey => $ordervalue){

			$product_info = $this->db_model->getSelect("name,status,price,can_purchase,billing_days,billing_type,reseller_id,can_resell","products",array("id"=>$ordervalue['product_id']));
			if($product_info->num_rows > 0){
				$product_info = $product_info->result_array()[0];
				$reseller_id  = ($ordervalue['reseller_id'] > 0)?$ordervalue['reseller_id']:0;
				$account_data = $this->db_model->getSelect("*","accounts",array("id"=>$ordervalue['accountid'],"reseller_id"=> $reseller_id,"status"=>0,"deleted"=>0));

				if($account_data->num_rows > 0){
					$account_info = $account_data->result_array()[0];
					$final_array = array_merge($account_info,$product_info);

					$final_array['billing_date'] = $ordervalue['next_billing_date'];
					$final_array['next_billing_date'] =($product_info['billing_days'] == 0)?gmdate('Y-m-d 23:59:59', strtotime('+10 years')):gmdate("Y-m-d 23:59:59",strtotime("+".($product_info['billing_days']-1)." days"));
					$final_array['product_name'] = $product_info['name'];
					if($product_info['status'] == 1 ||   $product_info['billing_type'] == 0 ){
						$final_array['next_billing_date'] = $ordervalue['termination_date'];
						$this->common->mail_to_users ( "product_release", $final_array );
					}

					else if(($product_info['can_purchase'] == 1 ||$product_info['can_resell'] == 1) && $product_info['reseller_id'] == $ordervalue['reseller_id'] && $ordervalue['reseller_id'] > 0){
							$this->common->mail_to_users ( "product_renewal_notice", $final_array );
					}
					else{
						$this->common->mail_to_users ( "product_renewal_notice", $final_array );

					}
			     }
		  }
	   }
	}
    }
    function update_bill_date($accountinfo) {

    $this->db->where("id",$accountinfo['id']);
	$this->db->update("accounts",array("last_bill_date" => $this->CurrentDate));
    }
    function PrintLogger($Error_flag,$Message)
    {
	if ($Error_flag) {
		if (is_array($Message)) {
		    foreach ($Message as $MessageKey => $MessageValue) {
		        if (is_array($MessageValue)) {
		            foreach ($MessageValue as $LogKey => $LogValue) {
		                fwrite($this->fp, "::::: " . $LogKey . " ::::: " . $LogValue . " :::::\n");
		            }
		        } else {
		            fwrite($this->fp, "::::: " . $MessageKey . " ::::: " . $MessageValue . " :::::\n");
		        }
		    }
		} else {
		    if ($this->Error_flag) {
		        fwrite($this->fp, "::::: " . $Message . " :::::\n");
		    }
		}
	}
    }
    function get_system_config()
    {
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