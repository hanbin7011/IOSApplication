<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/4/18
 * Time: 11:28 AM
 */

class access{

    //connection global variables
    var $host = null;
    var $user = null;
    var $pass = null;
    var $name = null;
    var $conn = null;
    var $result = null;


    function  __construct($dbhost, $dbuser, $dbpass, $dbname){

        $this->host = $dbhost;
        $this->user = $dbuser;
        $this->pass = $dbpass;
        $this->name = $dbname;

    }

    //connection function
    public function connect(){

        //establish connection and store it in $conn
        $this->conn = new mysqli($this->host, $this->user, $this->pass, $this->name);

        if(mysqli_connect_errno()){
            echo "Could not connect to database";
        }else{
            //echo "Conneted";
        }

        $this->conn->set_charset("utf8");
    }

    public function disconnect(){

        if($this->conn != null){
            $this->conn->close();
        }
    }

    public function registerUser($username, $password, $salt, $email, $fullname){

        //sql command
        $sql = "INSERT INTO users SET username=?, password=?, salt=?, email=?, fullname=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("sssss", $username, $password, $salt, $email, $fullname);

        $returnValue = $statement->execute();

        return $returnValue;

    }
    function deleteUser($id){
        $sql = "DELETE FROM users WHERE id=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("i",$id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function selectUser($username){

        $returnArray = null;

        $sql = "SELECT * FROM users WHERE username='".$username."'";

        $result = $this->conn->query($sql);


        if($result != null && (mysqli_num_rows($result) >= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    public function selectUserViaEmail($email){

        $returnArray = null;

        $sql = "SELECT * FROM users WHERE email='".$email."'";

        $result = $this->conn->query($sql);


        if($result != null && (mysqli_num_rows($result) >= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    public function selectUserViaId($id){

        $returnArray = array();

        $sql = "SELECT * FROM users WHERE id='".$id."'";

        $result = $this->conn->query($sql);


        if($result != null && (mysqli_num_rows($result) >= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    public function selectUserIdViaEmailToken($token){

        $returnArray = null;

        $sql = "SELECT * FROM emailTokens WHERE token='".$token."'";

        $result = $this->conn->query($sql);


        if($result != null && (mysqli_num_rows($result) >= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }


    //Save email confirmation message's token
    public  function  saveToken($table, $id, $token){

        //sql statement
        $sql = "INSERT INTO $table SET id=?, token=?";

        //prepare statement to be executed
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        //bind paramaters to sql statement
        $statement->bind_param("is", $id, $token);

        //launch / execute and store feedback in $returnValue
        $returnValue = $statement->execute();

        return $returnValue;

    }

    function getUserID($table, $token){

        $returnArray = null;
        //sql statement
        $sql = "SELECT id FROM $table WHERE token ='".$token."'";

        $result = $this->conn->query($sql);

        if($result != null && (mysqli_num_rows($result)>= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    function  emailConfirmationStatus($status, $id){
        $sql = "UPDATE users SET emailConfirmed=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("ii", $status,$id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function  updatePassword($id, $password, $salt){
        $sql = "UPDATE users SET password=?, salt=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("ssi", $password,$salt ,$id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function  changeEmail($id, $email){
        $sql = "UPDATE users SET email=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("si", $email ,$id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    function deleteToken($table, $token){
        $sql = "DELETE FROM $table WHERE token=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("s",$token);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function getUser($email){
        $returnArray = array();

        $sql = "SELECT * FROM users WHERE email='".$email."'";

        $result = $this->conn->query($sql);

        if($result != null && (mysqli_num_rows($result)>=1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);
        }

        if(!empty($row)){
            $returnArray = $row;
        }

        return $returnArray;
    }

    function updateAvaPath($path, $id){

        $sql = "UPDATE users SET ava=? WHERE id=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("si", $path, $id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    //Insert post in database
    public function insertPost($id, $uuid, $title, $text, $type){
        //sql statement
        $sql = "INSERT INTO posts".$type." SET id=?, uuid=?, title=?, text=?, type=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("issss", $id, $uuid, $title,$text,$type);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    //insert pic in postsPic database
    public function insertPostPic( $type,$uuid, $path){
        //sql statement
        $sql = "INSERT INTO postsPic".$type." SET uuid=?, path=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("ss", $uuid, $path);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    //Select all posts + user information made by user with relevant $id
    public function selectPosts($id, $type){
        $returnArray = array();

        $sql = "SELECT posts$type.*, users.username FROM Han.posts$type JOIN Han.users ON posts$type.id =$id AND users.id =$id ORDER by posts$type.date Desc";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }

        return $returnArray;
    }

    public function selectPicViaUuid($uuid, $type){

        $returnArray = null;

        $sql = "SELECT path FROM postsPic$type WHERE uuid='".$uuid."'";

        $result = $this->conn->query($sql);

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }

        return $returnArray;
    }


    public function findMatchResult($search){
        $returnArray = array();

        $search1 = "'#".$search."%'";
        $search2 = "'@".$search."%'";

        //sql statement
        $sql = "SELECT * FROM words WHERE (word LIKE ".$search1." OR word LIKE ".$search2.") ORDER BY postNum DESC";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }


        return $returnArray;
    }

    public function findBookByDistance($from, $amount, $latitudeFrom, $latitudeTo, $longitudeFrom, $longitudeTo){
        $returnArray = array();

        //sql statement
        $sql = "SELECT postsBook.* FROM Han.users JOIN Han.postsBook ON Han.postsBook.id = Han.users.id WHERE users.latitude>=$latitudeFrom AND users.latitude<=$latitudeTo AND users.longitude>=$longitudeFrom AND users.longitude<=$longitudeTo LIMIT $amount OFFSET $from";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();


        while($row = $result->fetch_assoc()){
            $paths = $this->selectPicViaUuid($row["uuid"], $row["type"]);
            $shares = $this->selectSharesViaUuid($row["uuid"]);

            $row["path"] = array();
            for($i = 0; $i < count($paths); $i++){
                if($paths[$i] != null){
                    $row["path"][] = $paths[$i]["path"];
                }
            }

            $row["shares"] = array();
            for($i = 0; $i < count($shares); $i++) {
                if ($shares[$i] != null) {
                    $row["shares"][] = $shares[$i]["sharesBy"];
                }
            }
            $returnArray[] = $row;
        }


        return $returnArray;
    }

    public function findOthersByDistance($from, $amount, $latitudeFrom, $latitudeTo, $longitudeFrom, $longitudeTo){
        $returnArray = array();

        //sql statement
        $sql = "SELECT postsOthers.* FROM Han.users JOIN Han.postsOthers ON Han.postsOthers.id = Han.users.id WHERE users.latitude>=$latitudeFrom AND users.latitude<=$latitudeTo AND users.longitude>=$longitudeFrom AND users.longitude<=$longitudeTo LIMIT $amount OFFSET $from";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $paths = $this->selectPicViaUuid($row["uuid"], $row["type"]);
            $shares = $this->selectSharesViaUuid($row["uuid"]);

            $row["path"] = array();
            for($i = 0; $i < count($paths); $i++){
                if($paths[$i] != null){
                    $row["path"][] = $paths[$i]["path"];
                }
            }

            $row["shares"] = array();
            for($i = 0; $i < count($shares); $i++) {
                if ($shares[$i] != null) {
                    $row["shares"][] = $shares[$i]["sharesBy"];
                }
            }

            $returnArray[] = $row;
        }


        return $returnArray;
    }

    public function findMatchUsername($search, $id){
        $returnArray = array();

        $search1 = "'%".$search."%'";

        //sql statement
        $sql = "SELECT username, id, date, email, ava FROM users WHERE (username LIKE ".$search1." OR fullname LIKE ".$search1.") AND id!=$id" ;

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }


        return $returnArray;
    }


    public  function checkWordExist($word){
        $returnArray = null;

        $sql = "SELECT * FROM words WHERE word='".$word."'";

        $result = $this->conn->query($sql);


        if($result != null && (mysqli_num_rows($result) >= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    public function  updateWord($word, $num){
        $sql = "UPDATE words SET postNum=? WHERE word=?";
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("is", $num, $word);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function insertWord($word){
        //sql statement
        $sql = "INSERT INTO words SET word=?, postNum=1";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("s", $word);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function findMatchText($search, $id){
        $returnArray = array();

        $search = "'%".$search."%'";

        //sql statement
        $sql = "SELECT * FROM postsBook WHERE text LIKE ".$search." AND id != $id ORDER BY date DESC";
        $sql2 = "SELECT * FROM postsOthers WHERE text LIKE ".$search." AND id != $id ORDER BY date DESC";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $paths = $this->selectPicViaUuid($row["uuid"], $row["type"]);
            $shares = $this->selectSharesViaUuid($row["uuid"]);
            
            $row["path"] = array();
            for($i = 0; $i < count($paths); $i++){
                if($paths[$i] != null){
                    $row["path"][] = $paths[$i]["path"];
                }
            }

            $row["shares"] = array();
            for($i = 0; $i < count($shares); $i++) {
                if ($shares[$i] != null) {
                    $row["shares"][] = $shares[$i]["sharesBy"];
                }
            }
            $returnArray[] = $row;
        }

        $statement = $this->conn->prepare($sql2);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $paths = $this->selectPicViaUuid($row["uuid"], $row["type"]);
            $row["path"] = array();
            for($i = 0; $i < count($paths); $i++){
                if($paths[$i] != null){
                    $row["path"][] = $paths[$i]["path"];
                }
            }

            $returnArray[] = $row;
        }


        return $returnArray;
    }

    function  setCoordinate($latitude, $longitude, $id){
        $sql = "UPDATE users SET latitude=?, longitude=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("ddi", $latitude,$longitude, $id);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function insertFollowing($newsByID,$newsToID){
        //sql statement
        $sql = "INSERT INTO family SET followerID=?, followedID=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("ii", $newsByID,$newsToID);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function selectSharesViaUuid($uuid){

        $returnArray = null;

        $sql = "SELECT sharesBy FROM shares WHERE sharesTo='".$uuid."'";

        $result = $this->conn->query($sql);

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }

        return $returnArray;
    }

    public function findFollowingResult($from, $amount, $ids){
        $returnArray = array();

        //sql statement
        $sql = "(SELECT postsBook.*, users.longitude, users.latitude, users.username FROM Han.users JOIN Han.postsBook ON Han.postsBook.id = Han.users.id WHERE users.id IN ".$ids.") UNION (SELECT postsOthers.*, users.longitude, users.latitude, users.username FROM Han.users JOIN Han.postsOthers ON Han.postsOthers.id = Han.users.id WHERE users.id IN ".$ids.") ORDER by date Desc LIMIT $amount OFFSET $from";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $paths = $this->selectPicViaUuid($row["uuid"], $row["type"]);
            $shares = $this->selectSharesViaUuid($row["uuid"]);
            $row["path"] = array();
            for($i = 0; $i < count($paths); $i++){
                if($paths[$i] != null){
                    $row["path"][] = $paths[$i]["path"];
                }
            }
            $row["shares"] = array();
            for($i = 0; $i < count($shares); $i++){
                if($shares[$i] != null){
                    $row["shares"][] = $shares[$i]["sharesBy"];
                }
            }

            $returnArray[] = $row;
        }


        return $returnArray;
    }

    public function getShares($uuid){
        $shares = $this->selectSharesViaUuid($uuid);

        $row["shares"] = array();
        for($i = 0; $i < count($shares); $i++){
            if($shares[$i] != null){
                $row["shares"][] = $shares[$i]["sharesBy"];
            }
        }

        return $row;
    }

    public  function selectFollowingId($id){
        $returnArray = array();

        $sql = "SELECT family.followedID FROM family WHERE followerID='".$id."' AND allowed=1";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }

        return $returnArray;
    }

    public function insertNews($newsByUsername,$newsToUsername, $type){
        //sql statement
        $sql = "INSERT INTO news SET newsBy=?, newsTo=?, type=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("sss", $newsByUsername,$newsToUsername, $type);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function selectNewsByUsername($username, $from, $amount){
        $returnArray = array();

        //sql statement
        $sql = "SELECT * FROM news WHERE newsTo='".$username. "' ORDER by date Desc LIMIT $amount OFFSET $from" ;


        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }


        return $returnArray;
    }

    function getAvaByUsername($username){

        $returnArray = null;
        //sql statement
        $sql = "SELECT ava FROM users WHERE username ='".$username."'";

        $result = $this->conn->query($sql);

        if($result != null && (mysqli_num_rows($result)>= 1)){
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if(!empty($row)){
                $returnArray = $row;
            }
        }

        return $returnArray;
    }

    public function changeUserInfo($username, $password, $salt, $email, $fullname, $id){

        //sql command
        $sql = "UPDATE users SET username=?, password=?, salt=?, email=?, fullname=?  WHERE id=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("sssssi", $username, $password, $salt, $email, $fullname, $id);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    public function changeUserInfoWithout($username, $email, $fullname, $id){

        //sql command
        $sql = "UPDATE users SET username=?, email=?, fullname=? WHERE id=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("sssi", $username, $email, $fullname, $id);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    public function selectCommentsViaUuid($uuid, $from, $amount){

        $returnArray = null;

        $sql = "SELECT comments.*, users.ava FROM Han.comments JOIN Han.users ON comments.username =users.username WHERE comments.uuid ='".$uuid. "' ORDER by comments.date ASC LIMIT $amount OFFSET $from";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row;
        }

        return $returnArray;
    }

    public function insertComment($uuid,$username,$comment){
        //sql statement
        $sql = "INSERT INTO comments SET uuid=?, username=?, comment=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("sss", $uuid,$username,$comment);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function updateCommentNum($type, $uuid,$commentNum){

        //sql command
        $sql = "UPDATE posts".$type." SET commentNum=? WHERE uuid=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("is", $commentNum, $uuid);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    public function updateSold($type, $uuid, $sold){

        //sql command
        $sql = "UPDATE posts".$type." SET sold=? WHERE uuid=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("is", $sold, $uuid);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    function deleteNews($newsByUsername, $newsToUsername, $type){
        $sql = "DELETE FROM news WHERE newsBy=? AND newsTo=? AND type=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("sss",$newsByUsername, $newsToUsername, $type);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function updateAddShareNum($type, $uuid){

        //sql command
        $sql = "UPDATE posts".$type." SET sharedNum = sharedNum + 1 WHERE uuid=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("s", $uuid);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    public function updateSubShareNum($type, $uuid){

        //sql command
        $sql = "UPDATE posts".$type." SET sharedNum = sharedNum - 1 WHERE uuid=?";

        //store query result in $statement
        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("s", $uuid);

        $returnValue = $statement->execute();

        return $returnValue;

    }

    public function insertShares($shresBy,$shresTo){
        //sql statement
        $sql = "INSERT INTO shares SET sharesBy=?, sharesTo=?";

        $statement = $this->conn->prepare($sql);

        //error occured
        if(!$statement){
            throw new Exception($statement->error);
        }

        //binding param in place of "?"
        $statement->bind_param("ss", $shresBy,$shresTo);

        //execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;
    }

    function deleteShares($sharesBy,$sharesTo){
        $sql = "DELETE FROM shares WHERE sharesBy=? AND sharesTo=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("ss",$sharesBy,$sharesTo);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    function deleteFollow($newsByID,$newsToID){
        $sql = "DELETE FROM family WHERE followerID=? AND followedID=?";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->bind_param("ss",$newsByID,$newsToID);

        $returnValue = $statement->execute();

        return $returnValue;
    }

    public function followingUsername($id){

        $returnArray = null;

        $sql = "SELECT users.username FROM Han.family JOIN Han.users ON family.followedID =users.id WHERE family.followerID ='".$id. "'";

        $statement = $this->conn->prepare($sql);

        if(!$statement){
            throw new Exception($statement->error);
        }

        $statement->execute();

        $result = $statement->get_result();

        while($row = $result->fetch_assoc()){
            $returnArray[] = $row["username"];
        }

        return $returnArray;
    }
}

?>