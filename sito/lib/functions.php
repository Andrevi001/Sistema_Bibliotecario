<?php
function db_login() {
    $connection = "host=localhost user='connessione' password='PSWRD' dbname='biblioteca'";
    $db = pg_connect($connection);
    $prepared = pg_prepare($db, 'SET', 'set search_path = biblioteca');

    if($prepared) {
        $prepared = pg_execute($db, 'SET', array());
    }
    
    return $db;
}
?>
