<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */



if(empty($_REQUEST["username"]) || empty($_REQUEST["password"]) || empty($_REQUEST["email"]) || empty($_REQUEST["fullname"]) || empty($_REQUEST["id"])|| empty($_REQUEST["checkSameUsernameEmail"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

$username = htmlentities($_REQUEST["username"]);
$password = htmlentities($_REQUEST["password"]);
$email = htmlentities($_REQUEST["email"]);
$fullname = htmlentities($_REQUEST["fullname"]);
$id = (int)htmlentities($_REQUEST["id"]);
$checkSameUsernameEmail = htmlentities($_REQUEST["checkSameUsernameEmail"]);

$checkPassChanged = true;
if($password != "****"){
    $salt = openssl_random_pseudo_bytes(20);
    $secured_password = sha1($password . $salt);
}else{
    $checkPassChanged = false;
}


$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

if (strpos($checkSameUsernameEmail, 'email') == false) {
    $checkEmailExist = $access->selectUserViaEmail($email);
}else{
    $checkEmailExist = "";
}

if (strpos($checkSameUsernameEmail, 'username') == false){
    $checkUserExist = $access->selectUser($username);
}else{
    $checkUserExist = "";
}

$checkExist = true;

$result = null;

//Check email already exist or not
if(!empty($checkEmailExist) && !empty($checkUserExist)){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Email and Username already exist";
}else if(!empty($checkEmailExist)){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Email already exist";
}else if(!empty($checkUserExist)){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Username already exist";
}else{
    if($checkPassChanged){
        $result = $access->changeUserInfo($username, $secured_password, $salt, $email, $fullname, $id);
        $checkExist = false;
    }else{
        $result = $access->changeUserInfoWithout($username, $email, $fullname, $id);
        $checkExist = false;
    }

}





if(!empty($result)){

    $user = $access->selectUser($username);


    $returnArray["status"] = "200";
    $returnArray["message"] = "Successfully register";
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];
    $returnArray["latitude"]= $user["latitude"];
    $returnArray["longitude"]= $user["longitude"];


}else{
    if(!$checkExist){
        $returnArray["status"] = "400";
        $returnArray["message"] = "Could not register with provided information";
    }
}

$access->disconnect();

echo json_encode($returnArray);

?>