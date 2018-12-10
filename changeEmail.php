<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["email"]) || empty($_REQUEST["token"]) || empty($_REQUEST["newEmail"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$email = htmlentities($_REQUEST["email"]);
$newEmail = htmlentities($_REQUEST["newEmail"]);
$token = htmlentities($_REQUEST["token"]);

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
$checkEmailExist = $access->selectUserViaEmail($newEmail);

if($checkEmailExist){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Email exists";
}else {

    //delete olde token from emailTokens table
    $result = $access->deleteToken("emailTokens", $token);
    //get user data by email
    $user = $access->selectUserViaEmail($email);

    //Change user email
    $result = $access->changeEmail($user["id"], $newEmail);

    //if change is success send email
    if ($result) {

        $returnArray["status"] = "200";
        $returnArray["message"] = "Successfully changed";
        $returnArray["id"] = $user["id"];
        $returnArray["username"] = $user["username"];
        $returnArray["email"] = $newEmail;
        $returnArray["fullname"] = $user["fullname"];
        $returnArray["ava"] = $user["ava"];

        //include email.php
        require("secure/email.php");

        $email = new email();

        //generate new token
        $token = $email->generateToken(6);
        $returnArray["token"] = $token;

        //save new token to emailTokens table
        $access->saveToken("emailTokens", $user["id"], $token);

        //set up email content
        $details = array();
        $details["subject"] = "Email confirmation on Han";
        $details["to"] = $newEmail;
        $details["fromName"] = "hAn Support";
        $details["fromEmail"] = "han.help.contact@gmail.com";

        $template = $email->confirmationTemplate();

        $template = str_replace("{token}", $token, $template);

        $details["body"] = $template;

        //send email
        $email->sendEmail($details);


    } else {
        // if email change wrong
        if (!$checkExist) {
            $returnArray["status"] = "400";
            $returnArray["message"] = "Could not change email with provided information";
        }
    }
}

//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>