<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */



if(empty($_REQUEST["email"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

$email = htmlentities($_REQUEST["email"]);


$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

$user= $access->selectUserViaEmail($email);

$result = $access->deleteUser($user["id"]);


if(!empty($result)){

    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully deleteUser";
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];

}else{
    if(!$checkExist){
        $returnArray["status"] = "400";
        $returnArray["message"] = "Could not delete with provided information";
    }
}

$access->disconnect();

echo json_encode($returnArray);

?>