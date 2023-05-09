<?php
defined('BASEPATH') or exit('No direct script access allowed');
require APPPATH . '/controllers/common/account.php';
class Invoices extends Account
{
	protected $postdata = "";
	function __construct()
	{
		parent::__construct();
		$this->load->model('common_model');
		$this->load->library('common');
		$this->load->model('db_model');
		$this->load->model('common_model');
		$this->load->model('Flux_common');
		$this->load->library('Form_validation');
		$this->load->library('flux/payment');
		$rawinfo = $this->post();
		$this->accountinfo = $this->get_account_info(); 
		if($this->accountinfo['type'] != '-1'  && $this->accountinfo ['type'] != '2' && $this->accountinfo ['type'] != '6' && $this->accountinfo ['type'] != '1' ){
			$this->response ( array (
				'status'  => false,
				'error'   => $this->lang->line ( 'error_invalid_key' )
			), 400 );
		}
		foreach ($rawinfo as $key => $value) {
			$this->postdata[$key] = $this->_xss_clean($value, TRUE);
		}
	}
	public function index()
	{
		$accountid = $this->accountinfo ['id'];
		if($this->accountinfo['type'] == '1'){
			$where = array('id' => $this->accountinfo['id'] , 'type' => 1);
		}else{
			$type = array(-1,2);
			$where = array('id'=>$accountid,'deleted'=>0,'status'=>0);
		}
		$accountinfo = (array)$this->db->get('accounts')->first_row();
		if(empty($accountinfo) || !isset($accountinfo)){
			$this->response ( array (
				'status'  => false,
				'error'   => $this->lang->line ( 'account_not_found' )
			), 400 );
		}
		$accountinfo = $this->_authorize_account ( $accountinfo,true,true);
		$function = isset ( $this->postdata ['action'] ) ? $this->postdata ['action'] : '';
		if ($function != '') {
			$function = '_' . $function;
			if (( int ) method_exists ( $this, $function ) > 0) {
				$this->$function ();
			} else {
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line ( 'unknown_method' )
				), 400 );
			}
		} else {
			$this->response ( array (
				'status'=> false,
				'error' => $this->lang->line ( 'unknown_method' )
			), 400 );
		}
	}
	
	private function _customer_invoices()
	{
		if (empty($this->postdata['end_limit']) || empty($this->postdata['start_limit']) ){
			if(!( $this->postdata['start_limit'] == '	0' || $this->postdata['end_limit'] == '0' )){
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line ( 'error_param_missing' ) . " integer:end_limit,integer:start_limit"
				), 400 );
			}else{
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('number_greater_zero')
				), 400 );
			}
		}
		if(!($this->postdata['start_limit'] < $this->postdata['end_limit'])){
			$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('valid_start_limit')
			), 400 );
		}
		$from_currency = Common_model::$global_config['system_config']['base_currency'];
		$to_currency = $this->common->get_field_name('currency', 'currency', $this->accountinfo['currency_id']);
		$start = $this->postdata['start_limit']-1;
		$limit = $this->postdata['end_limit'];
		$no_of_records = (int)$limit - (int)$start;
		$object_where_params = $this->postdata['object_where_params'];
		if(!empty($object_where_params['from_date']) || !empty($object_where_params['to_date'])  ){
			$from_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['from_date']);
	       	$to_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['to_date']);
	       	if(empty($from_dates) || empty($to_dates)){
	       		$this->response ( array (
						'status' => false,
						'error' => $this->lang->line('invalid_date_format')
				), 400 );
	       	}else{
	       		$object_where_params_date['generate_date >='] = $this->timezone->convert_to_GMT_new ( $object_where_params['from_date'], '1' , $this->accountinfo['timezone_id']);
				 $object_where_params_date['generate_date <='] = $this->timezone->convert_to_GMT_new ( $object_where_params['to_date'], '1',$this->accountinfo['timezone_id']);
				$this->db->where($object_where_params_date);
	       	}
		}
		unset($object_where_params['to_date'],$object_where_params['from_date'],$object_where_params['display_records']);
		foreach($object_where_params as $object_where_key => $object_where_value) {
			if($object_where_value != '') {	
				if(isset($object_where_key) && $object_where_key == 'destination'){
					$this->db->where('notes', $object_where_params['destination'] );
				}
				if(isset($object_where_key) && $object_where_key == 'duration'){
					$duration = explode(':', $object_where_params['duration']);
                    if (isset($duration[0]) && isset($duration[1])) {
                        if (is_numeric($duration[0]) && is_numeric($duration[1])) {
                            $object_where_params['duration'] = (60 * $duration[0]) + $duration[1];
                        }
                    }
					$this->db->where('billseconds' , $object_where_params['duration']);
				}
				if(isset($object_where_key) && $object_where_key == 'code'){
					$this->db->like('pattern', '^'.$object_where_params['code'] );
				}
				$where[$object_where_key] = $object_where_value;
			}
		}
		if(!empty($where)){
			unset($where['destination'],$where['code'],$where['duration']);
			$this->db->like($where, $object_where_params );
		}
	 	if ($this->accountinfo['type'] == '1') {
			$this->db->where('reseller_id', $this->postdata['id']);
	 	} 
		$this->db->where_in('generate_type',array(0,1));
		$this->db->order_by("generate_date", "desc");
		$this->db->limit($no_of_records, $start);
        $this->db->select('*');
        $result = $this->db->get('view_new_invoices');
        $count = $result -> num_rows();
        $invoices_info = $result->result_array();
		foreach ($invoices_info as $key => $invoices_value) {  
            
            $invoices_value['generate_date'] = $this->common->convert_GMT_to('','',$invoices_value['generate_date'],$this->accountinfo['timezone_id']);
            $invoices_value['from_date'] = $this->common->convert_GMT_to('','',$invoices_value['from_date'],$this->accountinfo['timezone_id']);
            $invoices_value['to_date'] = $this->common->convert_GMT_to('','',$invoices_value['to_date'],$this->accountinfo['timezone_id']);
            $invoices_value['due_date'] = $this->common->convert_GMT_to('','',$invoices_value['due_date'],$this->accountinfo['timezone_id']);
            $invoices_value['debit'] = $this->common_model->calculate_currency_customer($invoices_value['debit'],$from_currency,$to_currency,true,true)." ".$to_currency; 
            $invoices_value['credit'] = $this->common_model->calculate_currency_customer($invoices_value['credit'],$from_currency,$to_currency,true,true)." ".$to_currency;
            $invoices_value['invoice_total'] = $this->common_model->calculate_currency_customer($invoices_value['invoice_total'],$from_currency,$to_currency,true,true)." ".$to_currency; 
            $invoices_value['accountid'] = $this->common->reseller_select_value('first_name,last_name,number,company_name','accounts',$invoices_value['accountid']);
			$invoicesinfo[] =$invoices_value;
		}
    	if (!empty($invoicesinfo)) {
			$this->response ( array (
				'status' => true,
				'total_count' => $count,
				'data' => $invoicesinfo,
				'success' => $this->lang->line( "invoices_list" )
			), 200 );
        }else{
			$this->response ( array (
				'status' => true,
				'data' => array(),
				'success' => $this->lang->line( "no_records_found" )
			), 200 );
		}
	}

	private function _provider_invoices()
	{
		if (empty($this->postdata['end_limit']) || empty($this->postdata['start_limit']) ){
			if(!( $this->postdata['start_limit'] == '	0' || $this->postdata['end_limit'] == '0' )){
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line ( 'error_param_missing' ) . " integer:end_limit,integer:start_limit"
				), 400 );
			}else{
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('number_greater_zero')
				), 400 );
			}
		}
		if(!($this->postdata['start_limit'] < $this->postdata['end_limit'])){
			$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('valid_start_limit')
			), 400 );
		}
		$from_currency = Common_model::$global_config['system_config']['base_currency'];
		$to_currency = $this->common->get_field_name('currency', 'currency', $this->accountinfo['currency_id']);
		$start = $this->postdata['start_limit']-1;
		$limit = $this->postdata['end_limit'];
		$no_of_records = (int)$limit - (int)$start;
		$object_where_params = $this->postdata['object_where_params'];

		if(!empty($object_where_params['from_date']) || !empty($object_where_params['to_date'])  ){
			$from_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['from_date']);
	       	$to_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['to_date']);
	       	if(empty($from_dates) || empty($to_dates)){
	       		$this->response ( array (
						'status' => false,
						'error' => $this->lang->line('invalid_date_format')
				), 400 );
	       	}else{
	       		$object_where_params_date['generate_date >='] = $this->timezone->convert_to_GMT_new ( $object_where_params['from_date'], '1' , $this->accountinfo['timezone_id']);
				 $object_where_params_date['generate_date <='] = $this->timezone->convert_to_GMT_new ( $object_where_params['to_date'], '1',$this->accountinfo['timezone_id']);
				$this->db->where($object_where_params_date);
	       	}
		}
		unset($object_where_params['to_date'],$object_where_params['from_date'],$object_where_params['display_records']);
		foreach($object_where_params as $object_where_key => $object_where_value) {
			if($object_where_value != '') {	
				if(isset($object_where_key) && $object_where_key == 'destination'){
					$this->db->where('notes', $object_where_params['destination'] );
				}
				if(isset($object_where_key) && $object_where_key == 'duration'){
					$duration = explode(':', $object_where_params['duration']);
                    if (isset($duration[0]) && isset($duration[1])) {
                        if (is_numeric($duration[0]) && is_numeric($duration[1])) {
                            $object_where_params['duration'] = (60 * $duration[0]) + $duration[1];
                        }
                    }
					$this->db->where('billseconds' , $object_where_params['duration']);
				}
				if(isset($object_where_key) && $object_where_key == 'code'){
					$this->db->like('pattern', '^'.$object_where_params['code'] );
				}
				if(isset($object_where_key) && $object_where_key == 'accountid'){
					$this->db->where('provider_id', $object_where_params['accountid'] );
				}
				$where[$object_where_key] = $object_where_value;
			}
		}
		if(!empty($where)){
			unset($where['destination'],$where['code'],$where['duration'],$where['accountid']);
			$this->db->where($where, $object_where_params );
		}
		$this->db->where('trunk_id !=', '');
		$this->db->order_by("generate_date", "desc");
		$this->db->limit($no_of_records, $start);
        $this->db->select('calltype,generate_date,sip_user,call_direction,country_id,callerid,callednum,pattern,notes,billseconds,provider_call_cost,disposition,provider_id,cost');
        $result = $this->db->get('cdrs');
        $count = $result -> num_rows();
        $invoices_info = $result->result_array();
		foreach ($invoices_info as $key => $invoices_value) { 
            $show_seconds = $this->postdata['object_where_params']['display_records'] == 'minutes' || $this->postdata['object_where_params']['display_records'] == 'seconds' ? $this->postdata['object_where_params']['display_records'] : 'minutes';
            $invoices_value['duration'] = ($show_seconds == 'minutes') ? ($invoices_value['billseconds'] > 0) ? sprintf('%02d', $invoices_value['billseconds'] / 60) . ":" . sprintf('%02d', $invoices_value['billseconds'] % 60) : "00:00" : $invoices_value['billseconds'];
            $invoices_value['generate_date'] = $this->common->convert_GMT_to('','',$invoices_value['generate_date'],$this->accountinfo['timezone_id']);
            $invoices_value['cost'] = $this->common_model->calculate_currency_customer($invoices_value['cost'],$from_currency,$to_currency,true,true)." ".$to_currency; 
            $invoices_value['accountid'] = $this->common->reseller_select_value('first_name,last_name,number,company_name','accounts',$invoices_value['provider_id']); 
            $invoices_value['country_id'] = $this->common->get_field_name('country','countrycode',array('id' => $invoices_value['country_id'])) ;
            $invoices_value['destination'] = $invoices_value['notes'] ;
            $invoices_value['code'] =  preg_replace('/[^\d+0-9]/', '',  $invoices_value['pattern']);
            unset($invoices_value['notes'],$invoices_value['billseconds'],$invoices_value['pattern'],$invoices_value['provider_id'],$invoices_value['is_recording'],$invoices_value['provider_call_cost']);
			$invoicesinfo[] =$invoices_value;
		}
    	if (!empty($invoicesinfo)) {
			$this->response ( array (
				'status' => true,
				'total_count' => $count,
				'data' => $invoicesinfo,
				'success' => $this->lang->line( "provider_invoices_list" )
			), 200 );
        }else{
			$this->response ( array (
				'status' => true,
				'data' => array(),
				'success' => $this->lang->line( "no_records_found" )
			), 200 );
		}
	}
	private function _reseller_invoices_list()
	{
		$this->_reseller_invoices();
	}
	private function _reseller_invoices()
	{
		if (empty($this->postdata['end_limit']) || empty($this->postdata['start_limit']) ){
			if(!( $this->postdata['start_limit'] == '	0' || $this->postdata['end_limit'] == '0' )){
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line ( 'error_param_missing' ) . " integer:end_limit,integer:start_limit"
				), 400 );
			}else{
				$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('number_greater_zero')
				), 400 );
			}
		}
		if(!($this->postdata['start_limit'] < $this->postdata['end_limit'])){
			$this->response ( array (
					'status' => false,
					'error' => $this->lang->line('valid_start_limit')
			), 400 );
		}
		$from_currency = Common_model::$global_config['system_config']['base_currency'];
		$to_currency = $this->common->get_field_name('currency', 'currency', $this->accountinfo['currency_id']);
		$start = $this->postdata['start_limit']-1;
		$limit = $this->postdata['end_limit'];
		$no_of_records = (int)$limit - (int)$start;
		$object_where_params = $this->postdata['object_where_params'];

		if(!empty($object_where_params['from_date']) || !empty($object_where_params['to_date'])  ){
			$from_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['from_date']);
	       	$to_dates = DateTime::createFromFormat("Y-m-d H:i:s", $object_where_params['to_date']);
	       	if(empty($from_dates) || empty($to_dates)){
	       		$this->response ( array (
						'status' => false,
						'error' => $this->lang->line('invalid_date_format')
				), 400 );
	       	}else{
	       		$object_where_params_date['generate_date >='] = $this->timezone->convert_to_GMT_new ( $object_where_params['from_date'], '1' , $this->accountinfo['timezone_id']);
				 $object_where_params_date['generate_date <='] = $this->timezone->convert_to_GMT_new ( $object_where_params['to_date'], '1',$this->accountinfo['timezone_id']);
				$this->db->where($object_where_params_date);
	       	}
		}
		unset($object_where_params['to_date'],$object_where_params['from_date'],$object_where_params['display_records']);
		foreach($object_where_params as $object_where_key => $object_where_value) {
			if($object_where_value != '') {	
				if(isset($object_where_key) && $object_where_key == 'destination'){
					$this->db->where('notes', $object_where_params['destination'] );
				}
				if(isset($object_where_key) && $object_where_key == 'duration'){
					$this->db->where('billseconds' , $object_where_params['duration']);
				}
				if(isset($object_where_key) && $object_where_key == 'code'){
					$this->db->where('pattern', '^'.$object_where_params['code'] );
				}
				$where[$object_where_key] = $object_where_value;
			}
		}
		if(!empty($where)){
			unset($where['destination'],$where['code'],$where['duration']);
			$this->db->where($where, $object_where_params );
		}
		if($this->accountinfo['type'] == '1' && $this->postdata['action'] != 'reseller_invoices_list'){
			$where = array(
                "reseller_id" => $this->postdata['id'],
                "accountid <>" => $this->postdata['id']
            );
			$this->db->where($where);
		}
		$this->db->order_by("generate_date", "desc");
		$this->db->limit($no_of_records, $start);
		if($this->postdata['action'] != 'reseller_invoices_list'){
			 $this->db->select('generate_date,callerid,call_direction,callednum,notes,billseconds,disposition,debit,country_id,pattern,cost,accountid,pricelist_id,calltype,trunk_id');
		}else{
			$this->db->where('accountid', $this->postdata['id']);
			$this->db->select('generate_date,callerid,callednum,notes,billseconds,debit,cost,disposition,calltype');
		}
 		$result = $this->db->get('reseller_invoices');       
        $count = $result -> num_rows();
        $reseller_invoices_info = $result->result_array();
		foreach ($reseller_invoices_info as $key => $invoices_value) {  
            $show_seconds = $this->postdata['object_where_params']['display_records'] == 'minutes' || $this->postdata['object_where_params']['display_records'] == 'seconds' ? $this->postdata['object_where_params']['display_records'] : 'minutes';
            $invoices_value['duration'] = ($show_seconds == 'minutes') ? ($invoices_value['billseconds'] > 0) ? sprintf('%02d', $invoices_value['billseconds'] / 60) . ":" . sprintf('%02d', $invoices_value['billseconds'] % 60) : "00:00" : $invoices_value['billseconds'];
            $invoices_value['generate_date'] = $this->common->convert_GMT_to('','',$invoices_value['generate_date'],$this->accountinfo['timezone_id']);
            $invoices_value['debit'] = $this->common_model->calculate_currency_customer($invoices_value['debit'],$from_currency,$to_currency,true,true)." ".$to_currency; 
            $invoices_value['cost'] = $this->common_model->calculate_currency_customer($invoices_value['cost'],$from_currency,$to_currency,true,true)." ".$to_currency; 
            $invoices_value['accountid'] = $this->common->reseller_select_value('first_name,last_name,number,company_name','accounts',$invoices_value['accountid']); 
            $invoices_value['country_id'] = $this->common->get_field_name('country','countrycode',array('id' => $invoices_value['country_id'])) ;
            $invoices_value['pricelist_id'] = $this->common->get_field_name('name','pricelists',array('id' => $invoices_value['pricelist_id'])) ;
            $invoices_value['trunk_id'] = $this->common->get_field_name('name','trunks',array('id' => $invoices_value['trunk_id'])) ;
            $invoices_value['destination'] = $invoices_value['notes'] ;
            $invoices_value['code'] =  preg_replace('/[^\d+0-9]/', '',  $invoices_value['pattern']);
            if( $this->postdata['action'] == 'reseller_invoices_list'){
            	unset($invoices_value['cost'],$invoices_value['accountid'],$invoices_value['country_id'],$invoices_value['trunk_id'],$invoices_value['pricelist_id'],$invoices_value['code']);
            }
            unset($invoices_value['notes'],$invoices_value['billseconds'],$invoices_value['pattern'],$invoices_value['notes'],$invoices_value['is_recording']);
			$invoicesinfo[] =$invoices_value;
		}
    	if (!empty($invoicesinfo)) {
			$this->response ( array (
				'status' => true,
				'total_count' => $count,
				'data' => $invoicesinfo,
				'success' => $this->lang->line( "invoices_list" )
			), 200 );
        }else{
			$this->response ( array (
				'status' => true,
				'data' => array(),
				'success' => $this->lang->line( "no_records_found" )
			), 200 );
		}
	}
	
}