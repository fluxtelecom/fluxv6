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

$current_date = gmdate("Y-m-d H:i:s");
$start_date = "0000-00-00 00:00:00";


if ($start_date = "0000-00-00 00:00:00" ){
$start_date = gmdate ( "Y-m-d 23:59:59", strtotime ( $current_date . " - 1 month" ) );
$end_date = gmdate ( "Y-m-d 23:59:59", strtotime ( $start_date . " + 1 month" ) );
echo "Start Date Zero";

echo "start:".$start_date;
echo "end:".$end_date;

}

$end_date = gmdate ( "Y-m-d 23:59:59", strtotime ( $start_date . " + 1 month" ) );






?>