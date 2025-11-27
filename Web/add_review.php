<?php
header("Content-Type: application/json");
require "db.php";

$toilet_id = $_POST["toilet_id"] ?? null;
$rating = $_POST["rating"] ?? null;
$comment = $_POST["comment"] ?? null;

if (!$toilet_id || !$rating || !$comment) {
    echo json_encode(["success" => false, "error" => "Missing fields"]);
    exit;
}

// SQL apsauga nuo injection
$stmt = $conn->prepare("INSERT INTO reviews (toilet_id, rating, comment) VALUES (?, ?, ?)");
$stmt->bind_param("iis", $toilet_id, $rating, $comment);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}
?>
