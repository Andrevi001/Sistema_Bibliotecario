<?php
    include_once ('lib/functions.php');
    session_start();
?>

<!DOCTYPE html>
<html>
    <head>
        <h3>Prestito</h3>
    </head>
    <body>
        <form method="post">
            <label for="sede">ha preferenze sul dove andare a prelevare il libro?</label>
            <select name="sede">
            <option>Nessuna</option>
            <option value="1">1, Milano, Via Valvassori Peroni 21</option>
            <option value="2">2, Milano, Via Festa del perdono 7</option>
            <option value="3">3, Milano, Via del conservatorio 7</option>
            <option value="4">4, Perugia, Via verdi 4</option>
            <option value="5">5, Perugia, Via rossi 5</option>
            <option value="6">6, Perugia, Via del popolo 6</option>
            <option value="7">7, Torino, Via Celoria 18</option>
            <option value="8">8, Torino, Piazza del tricolore 20</option>
            <option value="9">9, Torino, Via Golgi 3</option>
            <option value="10">10, Brescia, Via venticinque aprile 30</option>
            <option value="11">11, Brescia, Via Carl Marx 2</option>
            <option value="12">12, Brescia, Via Faggioli 1</option>
            <option value="13">13, Roma, Via Peroni 30</option>
            <option value="14">14, Roma, Via Calice 20</option>
            <option value="15">15, Roma, Via fiori 12</option>
            </select>
            <br><br>
            <input type="submit" value="Submit">
        </form>
        
        <?php
            if ($_SERVER['REQUEST_METHOD'] === 'POST'){
                $_sede = $_POST['sede'];
                $_cf = $_SESSION['CF'];
                $_isbn = $_SESSION['ISBN'];
                $db = db_login();
                $result = pg_prepare($db,'prestito', 'select * from inserisci_prestito($1, $2, $3);');
                if ($result) {
                    $result = pg_execute($db, 'prestito', array($_cf, $_isbn, $_sede));
                } else {
                    echo '<p>Stiamo avendo difficolta tecniche, riprovi più tardi</p>';
                }
            }
        ?>
    </body>
</html>