<?php
$host = "localhost";
$user = "root";
$pass = ""; // jei XAMPP – palik tuščią
$dbname = "toitoi";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "DB connection failed: " . $conn->connect_error]));
}
?>
