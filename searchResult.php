<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["search"]) || empty($_REQUEST["id"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$search = htmlentities($_REQUEST["search"]);
$id = (int)htmlentities($_REQUEST["id"]);

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
$result = $access->findMatchText($search, $id);



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