<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 7/10/18
 * Time: 3:40 PM
 */


$file = parse_ini_file("../../Han.ini");

$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

require("secure/access.php");

$access = new access($host, $user, $pass, $name);
$access->connect();

if( !empty($_REQUEST["uuid"]) || !empty($_REQUEST["text"]) ) {

    $id = htmlentities($_REQUEST["id"]);
    $uuid = htmlentities($_REQUEST["uuid"]);
    $title = htmlentities($_REQUEST["title"]);
    $text = htmlentities($_REQUEST["text"]);
    $count = (int)htmlentities($_REQUEST["count"]);
    $type = htmlentities($_REQUEST["type"]);

    $folder = "/Applications/XAMPP/xamppfiles/htdocs/Han/Han/posts/" . $id . "/" . $type;

    if (!file_exists($folder)) {
        mkdir($folder, 0777, true);
    }

    $tmpText = str_replace("@", " @", $text);
    $tmpText = str_replace("#", " #", $tmpText);
    $split_strings = preg_split("/[\s]+/", $tmpText);

    foreach($split_strings as $result){
        if (strpos($result, '@') !== false or strpos($result, '#')!== false){
            $word = $access->checkWordExist($result);
            if($word){
                $access->updateWord($word["word"], (int)$word["postNum"] + 1);
            }else{
                $access->insertWord($result);
            }
        }
    }

    for ($i = 0; $i < $count; $i++) {
        $tempfolder = $folder . "/" . basename($_FILES["file" . $i]["name"]);

        if (move_uploaded_file($_FILES["file" . $i]["tmp_name"], $tempfolder)) {
            $returnArray["message"] = "Post has been made with picture";
            $path = "http://localhost/Han/Han/posts/" . $id . "/" . $type . "/" . $uuid . "post-" . $i . ".jpg";

            $picPostsResult = $access->insertPostPic($type, $uuid, $path);
        } else {
            $returnArray["message"] = "Post has been made without picture";
        }


    }
    $postsResult = $access->insertPost($id, $uuid, $title, $text, $type);


    if ($postsResult) {
        $returnArray["status"] = "200";
        $returnArray["id"] = $id;
        $returnArray["message"] = "Successfully post";

    } else {
        $returnArray["status"] = "400";
        $returnArray["message"] = "Some problem";
    }
}else{

    $email = htmlentities($_REQUEST["email"]);
    $type = htmlentities($_REQUEST["type"]);

    $user = $access->selectUserViaEmail($email);

    $posts = $access->selectPosts($user["id"], $type);

    if(!empty($posts)){
        for($i = 0; $i < count($posts); $i++){
            $pics = $access->selectPicViaUuid($posts[$i]["uuid"], $type);

            $posts[$i]["path"] = array();

            if($pics != null){
                foreach($pics as $tmpPic){
                    $posts[$i]["path"][] = $tmpPic["path"];
                }
            }


        }

        $returnArray["posts"] = $posts;
    }else{
        $returnArray["posts"] = [];
    }

}



$access->disconnect();

echo json_encode($returnArray);


?>