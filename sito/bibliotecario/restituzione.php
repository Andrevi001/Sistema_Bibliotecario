<?php
    include_once ('lib/functions.php');
    session_start();
?>

<!DOCTYPE html>
<html>
    <head>
        <nav>
            <ul>
                <li><a href="Bib_home.php">Home</a></li>
                <li><a href="restituzione.php">Restituzione</a></li>
                <li><a href="azzera_ritardi.php">Azzera ritardi</a></li>
                <li><a href="gestione_user.php">Gestione uttenti</a></li>
                <li><a href="gestione_sedi.php">Gestione Sedi</a></li>
                <li><a href="inserisci_libri.php">Inserisci libri</a></li>
                <li><a href="report_ritardi.php">Report_ritardi</a></li>
            </ul>
        </nav>
    </head>

    <body align = "center">
        <form method="post">
            <p>Inserisci il codice fiscale del lettore:</p>
            <input type="text" name ="cf"><br>
            <p>Inserisci id del libro:</p>
            <input type="text" name ="libro"><br>
            <input type="submit" value="Submit">
         </form>
         <?php
            if ($_SERVER['REQUEST_METHOD'] === 'POST'){
                $_bib = $_SESSION['cf'];
                $_cf = $_POST["cf"];
                $_lib = $_POST["libro"];
                $db = db_login();
                $result = pg_prepare($db,'restituzione', 'select * from restituzione($1, $2, $3);');
                if ($result) {
                    pg_execute($db, 'restituzione', array($_bib,$_cf,$_lib));
                } else {
                    echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                }
            }
         ?>
    </body>
</html>