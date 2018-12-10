<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/25/18
 * Time: 2:55 PM
 */

if(empty($_REQUEST["email"]) || empty($_REQUEST["token"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

$token = htmlentities($_REQUEST["token"]);
$emailTxt = htmlentities($_REQUEST["email"]);

$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require ("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

//include email.php
require ("secure/email.php");

$email = new email();

$result = $access->deleteToken("emailTokens", $token);
if(!$result){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Could not find token";
    echo json_encode($returnArray);
    return;
}

$token = $email->generateToken(6);
$returnArray["token"] = $token;

$user = $access->selectUserViaEmail($emailTxt);

if(!$user){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Could not find user";
}else{

    $access->saveToken("emailTokens", $user["id"], $token);

    $returnArray["status"] = "200";
    $returnArray["message"] = "New Confirmation Code send to".$emailTxt;
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];

    $details = array();
    $details["subject"]= "Email confirmation on Han";
    $details["to"] = $user["email"];
    $details["fromName"] = "hAn Support";
    $details["fromEmail"] = "han.help.contact@gmail.com";

    $template = $email->confirmationTemplate();

    $template = str_replace("{token}", $token, $template);

    $details["body"] = $template;
    $email->sendEmail($details);
}


$access->disconnect();

echo json_encode($returnArray);
?>