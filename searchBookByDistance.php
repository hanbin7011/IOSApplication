<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["latitudeFrom"]) || empty($_REQUEST["latitudeTo"]) || empty($_REQUEST["longitudeFrom"]) || empty($_REQUEST["longitudeTo"]) ||empty($_REQUEST["amount"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$from = (int)htmlentities($_REQUEST["from"]);
$amount = (int)htmlentities($_REQUEST["amount"]);
$latitudeFrom = (double)htmlentities($_REQUEST["latitudeFrom"]);
$latitudeTo = (double)htmlentities($_REQUEST["latitudeTo"]);
$longitudeFrom = (double)htmlentities($_REQUEST["longitudeFrom"]);
$longitudeTo = (double)htmlentities($_REQUEST["longitudeTo"]);

//get database connection information
$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

//connect database
require("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

//check newEmail already exist
$result = $access->findBookByDistance($from, $amount, $latitudeFrom, $latitudeTo, $longitudeFrom, $longitudeTo);



if($result == null){
    $returnArray["status"] = "400";
    $returnArray["message"] = "No match result";
}else {
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully changed";

    $returnArray["result"] = array();

    $returnArray["result"] = $result;


}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>