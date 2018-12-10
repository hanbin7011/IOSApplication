<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["username"]) || empty($_REQUEST["amount"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$from = (int)htmlentities($_REQUEST["from"]);
$amount = (int)htmlentities($_REQUEST["amount"]);
$username = htmlentities($_REQUEST["username"]);

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
$news = $access->selectNewsByUsername($username, $from, $amount);
//check newEmail already exist
for ($i = 0; $i<count($news); $i++){
    $result = $access->getAvaByUsername($news[$i]["newsBy"]);
    $news[$i]["ava"] = $result["ava"];
}




if($result == null){
    $returnArray["status"] = "400";
    $returnArray["message"] = "No match result";
}else {
    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully changed";

    $returnArray["result"] = array();

    $returnArray["result"] = $news;


}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>