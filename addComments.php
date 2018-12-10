<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["username"]) || empty($_REQUEST["uuid"]) || empty($_REQUEST["comment"])  || empty($_REQUEST["commentNum"])  || empty($_REQUEST["type"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$username = htmlentities($_REQUEST["username"]);
$uuid = htmlentities($_REQUEST["uuid"]);
$comment = htmlentities($_REQUEST["comment"]);
$commentNum = htmlentities($_REQUEST["commentNum"]);
$type = htmlentities($_REQUEST["type"]);

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


$result = $access->insertComment($uuid,$username,$comment);
$resultOfCommentNum = $access->updateCommentNum($type, $uuid, $commentNum);

if($result && $resultOfCommentNum){
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully commented";
}else if(!$result && !$resultOfCommentNum){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Not updated comment Num";
}else if(!$result){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Not updated comment Num";
}else{
    $returnArray["status"] = "400";
    $returnArray["message"] = "Not inserted";
}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>