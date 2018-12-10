<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/14/18
 * Time: 2:02 PM
 */



if(empty($_REQUEST["email"]) || empty($_REQUEST["password"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    return;
}

$email = htmlentities($_REQUEST["email"]);
$password = htmlentities($_REQUEST["password"]);

$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require ("secure/access.php");

$access = new access($host, $user, $pass, $name);
$access->connect();

$user = $access->getUser($email);

if(empty($user)){
    $returnArray["status"] = "403";
    $returnArray["message"] = "User is not found";
}else{
    $secured_password = $user["password"];
    $salt = $user["salt"];

    if($secured_password == sha1($password . $salt)){
        $returnArray["status"] = "200";
        $returnArray["message"] = "Logged in successfully";
        $returnArray["id"] = $user["id"];
        $returnArray["username"] = $user["username"];
        $returnArray["email"] = $user["email"];
        $returnArray["fullname"] = $user["fullname"];
        $returnArray["ava"] = $user["ava"];
        $returnArray["latitude"]= $user["latitude"];
        $returnArray["longitude"]= $user["longitude"];
    }else{
        $returnArray["status"] = "403";
        $returnArray["message"] = "Password do not match";

    }
}



$access->disconnect();

echo json_encode($returnArray);


?>