<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["type"]) || empty($_REQUEST["uuid"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$type = htmlentities($_REQUEST["type"]);
$uuid = htmlentities($_REQUEST["uuid"]);
$sold = (int)htmlentities($_REQUEST["sold"]);

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

$result = null;

if($sold == 1){
    $result = $access->updateSold($type, $uuid, 0);
    $returnArray["sold"] = 0;
}else{
    $result = $access->updateSold($type, $uuid, 1);
    $returnArray["sold"] = 1;
}


if($result == null){
    $returnArray["status"] = "400";
    $returnArray["message"] = "No match result";
}else {
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully changed";

    $returnArray["result"] = $result;

}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>