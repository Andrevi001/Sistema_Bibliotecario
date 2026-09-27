<?php
    session_start();
    $_isbn = $_SESSION['ISBN'];
    include_once ('lib/functions.php');
    $db = db_login();
    $query = 'select autore.nome_cognome, autore.data_nascita, autore.data_morte, autore.biografia from merito inner join autore on merito.autore = autore.id where merito.libro = $1';
    $result = pg_prepare($db, 'autori', $query);
    
    if ($result) {
        $result = pg_execute($db, 'autori', array($_isbn));
        echo '<html>';
        echo '<head>';
        echo '<style>
            table {
                width: 100%;
                border-collapse: collapse;
            }

            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                vertical-align: top;
            }

            th {
                background-color: #f2f2f2;
                text-align: left;
                width: 20%;
            }

            td {
                width: 80%;
            }

           .text {
               height: 75px;
            }';
        echo '</style>';
        echo '<h3>Autore/i<h3>';
        echo '</head>';
        echo '<body>';
        echo '<table>';
        while ($row = pg_fetch_assoc($result)) {
            echo '<tr><th>Nome e cognome</th><td>' .$row['nome_cognome'].'</td></tr>';
            echo '<tr><th>Data di nascita</th><td>' .$row['data_nascita'].'</td></tr>';
            echo '<tr><th>Data di morte</th><td>'.$row['data_morte'].'</td></tr>';
            echo '<tr><th>Biografie</th><td>' .$row['biografia'].'</td></tr>';
        }
        echo '</table>';
        echo '<form action = "Usr_home.php" method = "post">';
        echo '<input type = "submit" value = "Ritorna">';
        echo '</from><br>';
        echo '</body>';
        echo '</html>';
    } else {
        echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
    }