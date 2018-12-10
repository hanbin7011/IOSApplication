<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["id"]) || empty($_REQUEST["latitude"]) || empty($_REQUEST["longitude"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$id = (int)htmlentities($_REQUEST["id"]);
$latitude = (double)htmlentities($_REQUEST["latitude"]);
$longitude = (double)htmlentities($_REQUEST["longitude"]);

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
$updateAddress = $access->setCoordinate($latitude, $longitude, $id);

$user = $access->selectUserViaId($id);

if(!$updateAddress){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Some problems";
}else{
    $returnArray["status"] = "200";
    $returnArray["message"] = "Success";

    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];
    $returnArray["latitude"]= $user["latitude"];
    $returnArray["longitude"]= $user["longitude"];


}

//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>