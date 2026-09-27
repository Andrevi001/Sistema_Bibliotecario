<?php
    include_once('lib/functions.php');
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

    <body>
        <?php
            $db = db_login();
            $_cf = $_SESSION['CF'];
            $result = pg_prepare($db, 'report', 'selet * from report_ritardi($1)');
            if ($result) {
                $result = pg_execute($db, 'report', array($_cf));
            }
            $rows = pg_fetch_all($result);

            if ($rows) {
                echo '<table>';
                echo '<tr><th>Responsabile</th><td>Id_copia</td></tr>';
                foreach ($rows as $row) {
                    echo '<tr><th>'.$row['lettore'].'</th><td>' .$row['libro'].'</td></tr>';
                }
                echo '</table>';
            }
        ?>
    </body>
</html>