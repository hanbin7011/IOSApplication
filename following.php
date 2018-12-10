<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 12:01 PM
 */


//check email, token, newEmail data are send by url
if(empty($_REQUEST["newsByID"]) || empty($_REQUEST["newsToID"]) || empty($_REQUEST["newsByUsername"]) || empty($_REQUEST["type"])|| empty($_REQUEST["newsToUsername"])){
    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

//get email, token, newEmail from url
$newsByID = (int)htmlentities($_REQUEST["newsByID"]);
$newsToID = (int)htmlentities($_REQUEST["newsToID"]);
$newsByUsername = htmlentities($_REQUEST["newsByUsername"]);
$type = htmlentities($_REQUEST["type"]);
$newsToUsername = htmlentities($_REQUEST["newsToUsername"]);
if(!empty($_REQUEST["style"])){
    $style = htmlentities($_REQUEST["style"]);
}


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

$newsToUsername = $access->selectUserViaId($newsToID)["username"];

//check newEmail already exist
if($type == "follow"){
    $result = $access->insertFollowing($newsByID,$newsToID);
}

if(strpos($type, 'un') !== false){
    $type = substr($type, 2);
    $result = $access->deleteNews($newsByUsername, $newsToUsername, $type);

    if($type == "share"){
        $access->updateSubShareNum($style, $newsToUsername);
        $access->deleteShares($newsByUsername, $newsToUsername);
    }

    if($type == "follow"){
        $access->deleteFollow($newsByID,$newsToID);
    }
    if ($result) {
        $returnArray["status"] = "200";
        $returnArray["message"] = "Successfully remove news";
        $returnArray["news"] = "unnews";

    } else {
        $returnArray["status"] = "400";
        $returnArray["message"] = "Could not remove news";
        $returnArray["news"] = "news";
    }

}else {
    $noti = $access->insertNews($newsByUsername, $newsToUsername, $type);

    if($type == "share"){
        $access->updateAddShareNum($style, $newsToUsername);
        $access->insertShares($newsByUsername, $newsToUsername);
    }
    if ($noti == null) {
        $returnArray["status"] = "400";
        $returnArray["message"] = "Could not send news";
        $returnArray["news"] = "unnews";
    } else {
        $returnArray["status"] = "200";
        $returnArray["message"] = "Successfully send news";
        $returnArray["news"] = "news";
    }
}


//disconnect with database
$access->disconnect();

//show process result
echo json_encode($returnArray);

?>