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
        <p>Inserisci Il codice fiscale del lettore</p>
        <form method="post">
            <input type="text" name="CF" required>
            <input type="submit" value="submit">
        </form>
        
        <?php
            if ($_SERVER['REQUEST_METHOD'] === 'POST'){
                include('lib/functions.php');
                $db = db_login();
                $_cf = $_POST['CF'];
                $query = 'update lettore set ritardi = 0 where cf = $1';
                $result = pg_prepare($db, 'update', $query);
                if ($result) {
                    $result = pg_execute($db, 'update', array($_cf));
                    echo '<p>Operazione eseguita con successo</p>';
                } else {
                    echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                }
                pg_close($db);
            }
        ?>
    </body>
</html>