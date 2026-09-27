<?php
    include_once('lib/functions.php');
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
        <h3>
            Inserisca i dati del lettore.
        </h3>
        <form method="post">
            <p>Digiti il codice fiscale:</p>
            <input type="text" name = "cf" required><br>
            <input type="submit" value = "Submit">
        </form>

        <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                $_cf = trim($_POST["cf"]);
                if (strlen($_cf) < 16 || strlen($_cf)<16) {
                    echo '<p>Il codice civile deve contenere esattamente 16 caratteri</p>';
                } else {
                    $db = db_login();
                    $result = pg_prepare($db, 'delete', 'delete from lettore where id = $1;');
                    if ($result) {
                        $result = pg_execute($db, 'delete', array($_cf));
                        echo '<p>Rimozzione avvenuta con successo</p>';
                    } else {
                        echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                    }
                }
                pg_close($db);
            }
        ?>
    </body>
</html>