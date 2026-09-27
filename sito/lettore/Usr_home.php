<?php
    include_once('lib/functions.php');
    session_start();
?>
<!DOCTYPE html>
<html>
    <head>
        <nav>
            <ul>
                <li><a href="User_home.php">Home</a></li>
                <li><a href="modifica_pswrd.php">Restituzione</a></li>
            </ul>
        </nav>

    <style>
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
            }
        </style>
    </head>
    <body>
        <div align="center">
        <p><h3>Bentornata/o!</h3>
        che libro ti interessa oggi?</p>
        <form method="post">
            <p>digita il titolo o il codice ISBN:</p>
            <input type="text" name="T/I" value=<?php session_start(); echo $_SESSION['ISBN'] ?>><br><br>
            <input type="submit" value="Submit"><br><br>
        </form>
        </div>
        <?php
            if ($_SERVER['REQUEST_METHOD'] === 'POST'){
                
               

                if ($row) {
                    echo '<form action="prestito.php" method="post">';
                    echo '<input type="submit" value="Richiedi prestito">';
                    echo '</form>';
                    
                    echo '<table>';
                    echo '<tr><th>Titolo</th><td>' .$row['titolo'].'</td></tr>';
                    echo '<tr><th>ISBN</th><td>' .$row['isbn'].'</td></tr>';
                    echo '<tr><th>Trama</th><td class="text">'.$row['trama'].'</td></tr>';
                    echo '<tr><th>Casa Editrice</th><td>' .$row['casa_editrice'].'</td></tr>';
                    echo '</table>';
                    
                    echo '<form action ="autori.php" method = "post">';
                    echo '<input type = "submit" name = "action" value = "Autori">';
                    echo '</form><br><br>';
                } else {
                    echo '<p align = "center">ci dispice, ma al momento il libro non è presente nelle nostre librerie</p>';
                }
                pg_close($db);
            }
        ?>
    </body>
</html>