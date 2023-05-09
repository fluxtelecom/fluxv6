<?php
// ##############################################################################
// Flux SBC - Unindo pessoas e negócios
//
// Copyright (C) 2022 Flux Telecom
// Daniel Paixao <daniel@flux.net.br>
// Flux SBC Version 4.0 and above
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
class logger {
	var $fp;
	var $config;
	function __construct($lib) {
		$this->config = $lib->config;
//HP: Remove static set value		$this->config ['debug'] = 0;
		 //~ $this->config['log_path'] = "/backup/html/flux/";
		if ($this->config ['debug'] == '1') {
			// $this->fp = fopen($this->config['log_path'] . 'flux_' . date('Y-m-d') . '.txt', 'a+');
			$this->fp = fopen ( $this->config ['log_path'] . 'flux.log', 'a+' );
			//$this->fp = fopen ( $this->config ['log_path'], 'a+' );
		}
	}
	function log($log) {
		if ($this->config ['debug'] == '1') {
			if (is_array ( $log ))
				fwrite ( $this->fp, "[" . date ( 'Y-m-d H:i:s' ) . "] " . print_r ( $log, TRUE ) );
			else
				fwrite ( $this->fp, "[" . date ( 'Y-m-d H:i:s' ) . "] " . $log . "\n" );
		}
	}
	function close() {
		if ($this->config ['debug'] == '1')
			fclose ( $this->fp );
	}
}

?>
