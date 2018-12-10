<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/26/18
 * Time: 9:55 AM
 */

//check token data is sent
if(empty($_REQUEST["token"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get token data and confirmationStatus data from url
$token = htmlentities($_REQUEST["token"]);
$confirmationStatus = htmlentities($_REQUEST["confirmationStatus"]);

$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require ("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

//get userId from emailTokens table using token
$userId = $access->getUserID("emailTokens",$token);

//delete old token from emailTokens table
$result = $access->deleteToken("emailTokens", $token);

//get User by using userId
$user = $access->selectUserViaId($userId["id"]);

//check deleteToken success
if($result){
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully confirmed";
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];
    $returnArray["latitude"]= $user["latitude"];
    $returnArray["longitude"]= $user["longitude"];

    //change email confirmationStatus
    $access->emailConfirmationStatus($confirmationStatus, $user["id"]);
}else{
    $returnArray["status"] = "400";
    $returnArray["message"] = "Could not find token";
}

//disconnec to database
$access->disconnect();

// show process result
echo json_encode($returnArray);
?>