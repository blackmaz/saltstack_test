<?php

$mysql_hostname = 'localhost';
$mysql_username = 'pandamall';
$mysql_password = '1q2w3e4r5t';
$mysql_database = 'pandamalldb';
$mysql_port = '3306';
$mysql_charset = 'utf8';

$connect = new mysqli($mysql_hostname, $mysql_username, $mysql_password, $mysql_database, $mysql_port);

if($connect->connect_errno){
	echo '[연결실패] : '.$connect->connect_error.'<br>'; 
} else {
	echo '[연결성공]<br>';
}

if(! $connect->set_charset($mysql_charset))// (php >= 5.0.5)
{
	echo '[문자열변경실패] : '.$connect->connect_error;
}

$query = ' select \'complete\' as col from dual ';

$result = $connect->query($query) or die($this->_connect->error);

while($row = $result->fetch_array())
{
	echo $row['col'].'<br>';
}

$connect->close();

?>

