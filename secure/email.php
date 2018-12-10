<?php
/**
 * Created by PhpStorm.
 * User: hanbinpark
 * Date: 6/7/18
 * Time: 10:32 AM
 */

class email{
    //Generate unique token for user when he got confirmation email
    function generateToken($length){

        $characters = "1234567890";

        $charactersLength= strlen($characters);

        $token = '';

        for($i = 0; $i < $length; $i++){
            $token .= $characters[rand(0, $charactersLength-1)];
        }

        return $token;
    }

    function resetPasswordTemplate(){
        $file = fopen("templates/resetPasswordTemplate.html", "r") or die("Unable to open file");

        $template = fread($file, filesize("templates/resetPasswordTemplate.html"));

        fclose($file);

        return $template;
    }

    function confirmationTemplate(){
        //open file
        $file = fopen("templates/confirmationTemplate.html", "r") or die ("Unable to open file");

        $template = fread($file, filesize("templates/confirmationTemplate.html"));

        fclose($file);

        return $template;
    }

    function sendEmail($details){

        $subject = $details["subject"];
        $to = $details["to"];
        $fromName = $details["fromName"];
        $fromEmail = $details["fromEmail"];
        $body = $details["body"];

        $headers = "MIME-Version: 1.0". "\r\n";
        $headers .= "Content-type:text/html;charset=UTF-8"."\r\n";
        $headers .= "From: " . $fromName . " <". $fromEmail .">"."\r\n";

        mail($to, $subject, $body, $headers);

    }


}

?>