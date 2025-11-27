<?php
header("Content-Type: application/json");
require "db.php";

// Toilets
$toilets = [];
$q = $conn->query("SELECT * FROM toilets");
while ($row = $q->fetch_assoc()) {
    $toilets[] = $row;
}

// Reviews
$reviews = [];
$q2 = $conn->query("SELECT * FROM reviews");
while ($row = $q2->fetch_assoc()) {
    $reviews[] = $row;
}

echo json_encode([
    "toilets" => $toilets,
    "reviews" => $reviews
]);
?>
