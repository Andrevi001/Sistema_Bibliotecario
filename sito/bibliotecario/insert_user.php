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
        <h3>
            Inserisca i dati del lettore.
        </h3>
        <form method="post">
            <p>Digiti il codice fiscale:</p>
            <input type="text" name = "cf" required><br>
            <p>Digiti nome e cognome:</p>
            <input type="text" name = "nome" required><br>
            <p>Digiti la password</p>
            <input type="password" name = "pswrd" required><br>
            <input type="submit" value = "Submit">
        </form>

        <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                $_cf = trim($_POST["cf"]);
                $_nome = trim($_POST["nome"]);
                $_pswrd = $_POST["pswrd"];
                if (strlen($_cf) < 16 || strlen($_cf)<16) {
                    echo '<p>Il codice civile deve contenere esattamente 16 caratteri</p>';
                } else {
                    $db = db_login();
                    $result = pg_prepare($db, 'insert', 'insert into lettore(cf, nome_cognome, pswrd) values ($1, $2, $3);');
                    if ($result) {
                        $result = pg_execute($db, 'insert', array($_cf,$_nome,$_pswrd));
                        echo '<p>Inserimento avvenuto con successo</p>';
                    } else {
                        echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                    }
                }
            }
        ?>
    </body>
</html>