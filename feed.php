<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if( empty($_REQUEST["id"]) || empty($_REQUEST["amount"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$from = (int)htmlentities($_REQUEST["from"]);
$id = (int)htmlentities($_REQUEST["id"]);
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


$returnArray["result"] = array();
$stringID = "(";

//check newEmail already exist
$followingId = $access->selectFollowingId($id);
for ($i = 0; $i < count($followingId); $i++){
    if($i ==  count($followingId) - 1){
        $stringID = $stringID . $followingId[$i]["followedID"] . ")";
    }else{
        $stringID = $stringID . $followingId[$i]["followedID"] . ", ";
    }

}

$result = $access->findFollowingResult($from, $amount, $stringID);

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