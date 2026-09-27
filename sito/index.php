<?php 
  ini_set ("display_errors", "On");
  ini_set("error_reporting", E_ALL);
  include_once ('lib/functions.php');
  session_start();
?>

<!DOCTYPE html>
<html>
    <head>
        <h1 align = "center">
            Login
        </h1>
    </head>

    <body>
        <div align="center">
        <form action = "" method="post">
            <p>Codice Fiscale:</p>
            <input type="text" name="CF" required>
            <p>Password:</p>
            <input type="password" name="pswrd" required><br><br>
            <input type="submit" value="Submit">
        </form>
        </div>
    </body>

    <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST'){
            $db = db_login();
            $usr = $_POST['CF'];
            $pswrd = $_POST['pswrd'];
            $pswrd = base64_encode($pswrd);
            $result = pg_prepare($db, 'usr', "select * from lettore where cf = $1 and pswrd = $2");

            if ($result) {
                $result = pg_execute($db, 'usr', array($usr,$pswrd));
                if (pg_num_rows($result) > 0) {
                    
                    $_SERVER['CF'] = $usr;
                    pg_close($db);
                    header("Location: lettore/Usr_home.php");
                    exit();
                } else {
                    $result = pg_prepare($db, 'bib', "select * from bibliotecario where cf = $1 and pswrd = $2");
                    if ($result) {
                        $result = pg_execute($db, 'bib', array($usr,$pswrd));
                        if (pg_num_rows($result) > 0) {
                            $_SERVER['CF'] = $usr;
                            pg_close($db);
                            header("Location: bibliotecario/Bib_home.php");
                            exit();
                        }
                    }
                }
            } else {
                echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
            }
        }
        
    ?>
</html>
