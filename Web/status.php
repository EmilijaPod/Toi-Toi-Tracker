<?php
$conn = @pg_connect("host=".getenv('DB_HOST')." dbname=toitoi_db user=".getenv('DB_USER')." password=".getenv('DB_PASS'));
if($conn) { 
    echo "<h2 style='color:lightgreen; font-family:sans-serif; margin:0;'>DB Connection: OK</h2>"; 
} else { 
    http_response_code(500);
    echo "<h2 style='color:red; font-family:sans-serif; margin:0;'>DB Connection: FAILED</h2>"; 
}
?>
