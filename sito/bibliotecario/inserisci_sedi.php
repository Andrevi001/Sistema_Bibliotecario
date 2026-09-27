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

    <body>
        <form method="post">
            <p>Digiti nome e cognome:</p>
            <input type="text" name = "città" required><br>
            <p>Digiti l'indirizzo</p>
            <input type="text" name = "indirizzo" required><br>
            <input type="submit" value = "Submit">
        </form>

        <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                $_citta = trim($_POST["città"]);
                $_ind = $_POST["indirizzo"];
                $db = db_login();
                $result = pg_prepare($db, 'insert', 'insert into sedi(città, indirizzo) values ($1, $2);');
                if ($result) {
                    $result = pg_execute($db, 'insert', array($_citta,$_ind));
                    echo '<p>Inserimento avvenuto con successo</p>';
                } else {
                    echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                }
                pg_close($db);
            }
        ?>
    </body>
</html>