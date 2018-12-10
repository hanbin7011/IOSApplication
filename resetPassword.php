<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/15/18
 * Time: 2:01 PM
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

require ("secure/access.php");

$access = new access($host, $user, $pass, $name);
$access->connect();

$user = $access->selectUserViaEmail($email);

if(empty($user)){
    $returnArray["status"] = "403";
    $returnArray["message"] = "Email not found";
}else{
    require ("secure/email.php");

    $email = new email();

    $token = $email->generateToken(20);

    $access->saveToken("passwordTokens", $user["id"], $token);

    $details = array();
    $details["subject"] = "Password reset request on hAn";
    $details["email"] = $email;
    $details["to"] = $user["email"];
    $details["fromName"] = "hAn Support";
    $details["fromEmail"] = "han.help.contact@gmail.com";

    $template = $email->resetPasswordTemplate();
    $template = str_replace("{token}", $token, $template);
    $details["body"] = $template;

    $email->sendEmail($details);

    $returnArray["status"] = "200";
    $returnArray["email"] = $user["email"];
    $returnArray["message"] = "We have sent you email to reset password";
}


echo json_encode($returnArray);

$access->disconnect();
?>

