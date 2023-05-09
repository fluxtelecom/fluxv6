<?php
if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Http_request_logger {

    public function log_all() {
        $CI = & get_instance();
        log_message('info', 'GET --> ' . var_export($CI->input->get(null), true));
        log_message('info', 'POST --> ' . var_export($CI->input->post(null), true));                
        log_message('info', '$_SERVER -->' . var_export($_SERVER, true));
    }

}