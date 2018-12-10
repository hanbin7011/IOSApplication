<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/7/18
 * Time: 10:21 AM
 */


//check token is send by url
if(empty($_GET["token"])){
    echo 'Missing required information';
    return;
}

//get token from url
$token = htmlentities($_GET["token"]);

//get database login information
$file = parse_ini_file("../../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

//login to data base
require ("../secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

//get User id from emailTokens table
$id = $access->getUserID("emailTokens", $token);

//check this token User is exist or not
if(empty($id["id"])){
    echo 'User with this token is not found';
}else{

    //change emailConfirmationStatus
    $result = $access->emailConfirmationStatus(1, $id["id"]);

    //Check email confirmed
    if ($result) {
        $access->deleteToken("emailTokens", $token);
        echo 'Thank you! Your email is now confirmed';
    }
}

//disconnect database
$access->disconnect();


?>