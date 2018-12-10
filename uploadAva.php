<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 7/2/18
 * Time: 4:23 PM
 */

if(empty($_REQUEST["id"])){
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

$id = htmlentities($_REQUEST["id"]);

$folder = "/Applications/XAMPP/xamppfiles/htdocs/Han/Han/ava/".$id;

if(!file_exists($folder)){
    mkdir($folder, 0777, true);
}

$folder = $folder. "/". basename($_FILES["file"]["name"]);

if(move_uploaded_file($_FILES["file"]["tmp_name"], $folder)){
    $returnArray["status"] = "200";
    $returnArray["message"] = "The file has been uploaded";
}else{
    $returnArray["status"] = "300";
    $returnArray["message"] = "Error while uploading";
}

$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();

$path = "http://localhost/Han/Han/ava/". $id. "/ava.jpg";
$access->updateAvaPath($path, $id);

$user = $access->selectUserViaId($id);

$returnArray["id"] = $user["id"];
$returnArray["username"] = $user["username"];
$returnArray["fullname"] = $user["fullname"];
$returnArray["email"] = $user["email"];
$returnArray["ava"] = $user["ava"];

$access->disconnect();

echo json_encode($returnArray);


?>