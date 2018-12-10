<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if( empty($_REQUEST["uuid"]) || empty($_REQUEST["amount"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$from = (int)htmlentities($_REQUEST["from"]);
$uuid = htmlentities($_REQUEST["uuid"]);
$amount = (int)htmlentities($_REQUEST["amount"]);

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

$result = $access->selectCommentsViaUuid($uuid, $from, $amount);

if($result == null){
    $returnArray["status"] = "400";
    $returnArray["message"] = "No match result";
}else {
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully reload";

    $returnArray["result"] = $result;

}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>