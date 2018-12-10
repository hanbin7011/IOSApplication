<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */



if(empty($_REQUEST["username"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

$username = htmlentities($_REQUEST["username"]);


$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

$user= $access->selectUser($username);



if(!empty($user)){

    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully";
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];

}else{
    $returnArray["status"] = "400";
    $returnArray["message"] = "Could not find user";

}

$access->disconnect();

echo json_encode($returnArray);

?>