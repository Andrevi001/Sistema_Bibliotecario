--creo il db
Create schema Biblioteca;
Set search_path = biblioteca;

--creo le tabelle 
create table Lettore (
	CF 			char(16) primary key,
	Nome_cognome 		varchar(30) not null,
	Premium			bool not null,
	Prestiti_attivi		integer default 0,
	Ritardi			integer default 0,
	Pswrd			varchar(18) not null
);

create table Sede (
	Id			serial primary key,
	Città 			varchar(15) not null,
	Indirizzo		varchar(40) not null,
	N_copie			integer default 0,
	N_ISBN			integer default 0,
	N_prestiti_attivi	integer default 0
);
	
create table Libro (
	ISBN			char(13) primary key,
	Titolo			Varchar(100) not null,
	Trama			varchar(200),
	Casa_editrice		varchar(40)
);

create table Autore (
	Id			serial primary key,
	Nome_cognome 		varchar(30) not null,
	Biografia		varchar(200),
	Data_nascita		date,
	Data_morte		date
);

create table Bibliotecario (
	CF			char(16) primary key,
	Nome_cognome		varchar(30) not null,
	Pswrd			varchar(12) not null,
	sede			integer
);

create table Copia (
	Id			serial primary key,
	Disponibile		bool not null,
	ISBN			char(13),
	Sede			integer not null
);

create table Prestito (
	Id			serial primary key,
	Lettore			char(16) not null,
	Libro			integer not null,
	Data_inizio		date not null,
	Data_max		date not null,
	Data_fine		date
);

create table Merito (
	Autore			integer,
	Libro			char(13),
	primary key(Autore,Libro)
);

create type ritardo as (
	Lettore		char(16),
	libro		integer
);

create user connessione with PASSWORD 'PSWRD';
grant usage on schema biblioteca to connessione;
grant select on all tables in schema biblioteca to connessione;
grant insert on all tables in schema biblioteca to connessione;
grant delete on all tables in schema biblioteca to connessione;
grant update on table biblioteca.lettore to connessione;
grant update on table biblioteca.prestito to connessione;


--definisco le chievi esterne
alter table bibliotecario add constraint fk_Bibliotecario foreign key(sede) references sede(id);
alter table copia add constraint fk01_Copia foreign key(ISBN) references libro(ISBN);
alter table copia add constraint fk02_Copia foreign key(Sede) references sede(Id);
alter table prestito add constraint fk01_Prestito foreign key(Lettore) references Lettore(CF);
alter table prestito add constraint fk02_Prestito foreign key(Libro) references Copia(Id);
alter table merito add constraint fk01_Merito foreign key(Autore) references autore(Id);
alter table merito add constraint fk02_Merito foreign key(Libro) references libro(ISBN);

--parte attiva del db

--funzione per richiedere un prestito
create or replace function inserisci_prestito(_lettore char(16), _isbn char(13), _sede integer)
	returns void as $$
		declare
		lib	char(13);
		_id	integer;
		begin
			--seleziono un id di un libro con le specifiche richieste
			select id into _id
			from copia
			where sede = _sede and isbn = _isbn and disponibile = true limit 1;
			
			if _id is null then 
				
				select id into _id
				from copia
				where isbn = _isbn and disponibile = true;
				
				if _id is null then
					raise info 'il libro non è al momento disponibile';
					return;
				end if;
				
				select sede into _sede
				from copia
				where id = _id;
				
				if _sede is not null then 
					raise info 'il libro non è disponibile nella sede %', _sede;
				end if;
				
				insert into prestito(lettore, libro, data_inizio, data_max) values
						    (_lettore, _id, current_date, current_date + interval '30 days');
				
				raise info 'il prestito è stato completato su una copia della sede %', _sede;
			else 
				
				insert into prestito(lettore, libro, data_inizio, data_max) values
						    (_lettore, _id, current_date, current_date + interval '30 days');
				raise info 'il prestito è stato completato.';
			end if;
		end;
	$$ language plpgsql;
 

-- funzione per il controllo dell'ideneità del prestito
create or replace function check_idoneità_prestito()
	returns trigger as $$
		declare 
			prestiti 	integer;
			n_ritardi 	integer;
			prm		bool;
			possibile	bool;
		begin
			select Ritardi into n_ritardi --seleziono i riatrdi del lettore che richiede il prestito
			from lettore
			where lettore.CF = new.Lettore;
		
			select Prestiti_attivi into prestiti --selezioni i prestiti attivi del lettore
			from lettore 
			where lettore.CF = new.Lettore;
		
			select premium into prm -- vedo se il lettore é utente premium
			from lettore
			where cf = new.lettore;
		 
			select Disponibile into possibile -- vedo se la copia è disponibile
			from copia
			where Id = new.Libro;
		
		-- faccio i controlli di idoneità del lettore (ritardi, prestiti attivi) e controllo se la specifica copia è disponibile
			if n_ritardi >= 5 then
        			raise info 'Non puoi richiedere un prestito perché hai registrato 5 ritardi.';
       				return NULL;
    			elsif not prm and prestiti >= 3 then
        			raise INFO 'Non puoi richiedere un prestito perché hai già 3 prestiti attivi.';
       				return NULL;
       			elsif prm and prestiti >= 5 then
        			raise INFO 'Non puoi richiedere un prestito perché hai già 5 prestiti attivi.';
       				return NULL;
       			elsif not possibile then
        			raise INFO 'il libro non è disponibile';
       				return NULL;
    			else
    		-- se possibile effetuo il prestito e aggiorno il numero di prestiti attivi dell'utente e la disponibilità della copia
    				update lettore
    				set Prestiti_attivi = Prestiti_attivi + 1
    				where lettore.CF = new.Lettore;
    				update copia
    				set Disponibile = false
    				where copia.Id = new.Libro;
        			return new;
    			end if;
		end;
	$$ language plpgsql;

--trigger per l'idoneità del prestito
create trigger idoneità_prestito
before insert on prestito
for each row
execute function check_idoneità_prestito();

-- funzione per la restituzione dei libri
create or replace function restituzione(bib char(16), lib integer, let char(16))
	returns void as $$
		declare
			sede_rest	integer;
			sede_prest	integer;
			isbn_n		integer;
			data_rest_prev	date;
		begin
			--metto in sede_rest l'id della sede di restituzoine del libro
			select sede.id into sede_rest
			from bibliotecario
			inner join sede on bibliotecario.sede = sede.id
			where bibliotecario.cf = bib;
			
			--metto dentro sede_prest 'd della sede che ha concesso il prestito
			select sede.id into sede_prest
			from prestito
			inner join copia on prestito.libro = copia.id
			inner join sede on copia.sede = sede.id
			where prestito.lettore = let and prestito.libro = lib and data_fine is null;
			
			--metto dentro data_rest_prev la data di restituzione prevista del libro
			select data_max into data_rest_prev
			from prestito
			where data_fine is null and libro = lib and lettore = let;
			
			--controllo se la restituzione è avvenuta in ritardo se si aggiorno il numero di ritardi del lettore
			if current_date > data_rest_prev then 
				update lettore 
				set ritardi = ritardi + 1
				where lettore.cf = let;
			end if;
			
			--aggiorno il numero di prestiti attivi del lettore
			update lettore
			set prestiti_attivi = prestiti_attivi - 1
			where cf = let;
			
			--aggiorno da data di fine del prestito
			update prestito
			set data_fine = current_date
			where lettore = let and libro = lib and data_fine is null;
			
			--aggiorno la sede di riferimento del libro (che puo cambiare a seconda di dove il lettore va a restituire il libro) e la disponibilità del libro
			update copia
			set sede = sede_rest,
			    disponibile = true
			where id = lib;
			
			--aggiorno le statistiche della sede
			--vedo se il lettore ha restituito il libro alla sede originale o a una sede alternativa
			if sede_rest = sede_prest then
				--caso sede originale 
				update sede
				set n_prestiti_attivi = n_prestiti_attivi - 1
				where id = sede_rest;
			else
				--caso sede altenativa
				--conto il nuovo numero di isbn nella sede alternativa
				select count(distinct  isbn) into isbn_n
				from copia 
				where sede = sede_rest;
				
				--aggiorno le statistiche della sede alternativa
				update sede
				set n_copie = n_copie + 1,
				    n_isbn = isbn_n
				where id = sede_rest;
				
				--conto il nuovo numero di isbn nella sede originale
				select count(distinct  isbn) into isbn_n
				from copia 
				where sede = sede_prest;
				
				--aggiorno le statistiche della sede originale
				update sede
				set n_copie = n_copie - 1,
				    n_isbn = isbn_n,
				    n_prestiti_attivi = n_prestiti_attivi - 1
				where id = sede_prest;
			end if;
		end;
	$$ language plpgsql;
	
--funzione per la proroga della durata di un prestito
create or replace function proroga(lib integer, let char(16), data date)
	returns void as $$
		declare
			data_prev	date;
			data_ini	date;
		
		begin
			--metto dentro data_ini la data del inizio del prestito
			select data_inizio into data_ini
			from prestito
			where lettore = let and libro = lib and data_fine is null;
			
			--controllo se la data di consegna nuova e dopo la data di inizio del prestito
			if data_ini > data then
				raise info 'data inserita non valida';
				return;
			end if;
			
			--recupero la date di restituzione prevista
			select data_max into data_prev
			from prestito
			where libro = lib and lettore = let and data_fine is null;
			--vedo se il libro è già in ritardo, se no cambio la data di restituzione
			if data_prev < current_date then
				raise info 'non è possibile effettuare la proroga perchè il libro in prestito è gia in ritardo';
				return;
			else
				update prestito
				set data_max = data
				where lettore = let and libro = lib and data_fine is null;
			end if;
		end;
	$$ language plpgsql;

--funzione per l'aggiornamento delle statistiche di una sede
create or replace function aggiorna_statistiche_sede_on_insert_copia()
	returns trigger as $$
		declare
			isbn_n		integer;
		
		begin
			--conto il nuovo numero di ISBN distinti della sede interessata 
			select count(distinct isbn) into isbn_n
			from copia
			where copia.sede = new.sede;
				
			--aggiorno il n_copie, n_ISBN, n_prestiti_attivi della sede interessata
			update sede
			set n_isbn = isbn_n,
			    n_copie = n_copie + 1
			where id = new.sede;
			
			return new;
		end;
	$$ language plpgsql;

--trigger per l'aggiornamento del numero di copie e isbn di una sede
create trigger statistiche_sede_1
after insert on copia
for each row
execute function aggiorna_statistiche_sede_on_insert_copia();

--funzione per l'aggiornamento delle statistiche di una sede
create or replace function aggiorna_statistiche_sede_on_insert_prestito()
	returns trigger as $$
		declare
			sede_prest	integer;
		begin
			--recupero l'id della sede interessata
			select copia.sede into sede_prest
			from copia
			where id = new.libro;
		
			--aggiorno il numero di prestiti_attivi 
			update sede
			set n_prestiti_attivi = n_prestiti_attivi + 1
			where id = sede_prest;
			
			return new;
		end;
	$$ language plpgsql;

--trigger per l'aggiornamento del numero di prestiti attivi di una sede
create trigger statistiche_sede_2
after insert on prestito
for each row
execute function aggiorna_statistiche_sede_on_insert_prestito();

--funzione per generale report ritardi
create or replace function report_ritardi(bib char(16))
	returns setof ritardo as $$
		declare
			sede_bib	integer;
			_ritardo	ritardo;
		begin
			--inserisco dentro sede_bib la sede di riferimento del report
			select bibliotecario.sede into sede_bib
			from bibliotecario
			inner join sede on bibliotecario.sede = sede.id
			where bibliotecario.cf = bib;

			--seleziono tutti i libri con prestito attivo in ritardo
			for _ritardo in
				select prestito.lettore, prestito.libro
				from prestito
				inner join copia on copia.id = prestito.libro
				where data_max < current_date and data_fine is null and copia.sede = sede_bib
			loop
				return next _ritardo;
			end loop;
			return;
		end;
	$$ language plpgsql;

--popolo il db
--password utenti: PSWRDUSR
insert into lettore values
	('AAAAAAAAAAAAAAAA', 'Andrea Viganò', true, 0, 0, 'UFNXUkRVU1I='),
	('HHHHHHHHHHHHHHHH', 'Hayat Abdu', false, 0, 3, 'UFNXUkRVU1I='),
	('KKKKKKKKKKKKKKKK', 'Kiya Viganò', true, 0, 4, 'UFNXUkRVU1I='),
	('SSSSSSSSSSSSSSSS', 'Seble Girma', false, 0, 2, 'UFNXUkRVU1I='),
	('MMMMMMMMMMMMMMMM', 'Marco Viganò', false, 0, 4, 'UFNXUkRVU1I='),
	('MHMHMHMHMHMHMHMH', 'Mahader Girma', false, 0, 5, 'UFNXUkRVU1I='),
	('HEHEHEHEHEHEHEHE', 'Hermela Ghezahegn', false, 0, 1, 'UFNXUkRVU1I=');
	
insert into sede(Città, Indirizzo) values
	('Milano', 'Via Valvassori Peroni 21'),
	('Milano', 'Via Festa del perdono 7'),
	('Milano', 'Via del conservatorio 7'),
	('Perugia', 'Via verdi 4'),
	('Perugia', 'Via rossi 5'),
	('Perugia', 'Via del popolo 6'),
	('Torino', 'Via Celoria 18'),
	('Torino', 'Piazza del tricolore 20'),
	('Torino', 'Via Golgi 3'),
	('Brescia', 'Via venticinque aprile 30'),
	('Brescia', 'Via Carl Marx 2'),
	('Brescia', 'Via Faggioli 1'),
	('Roma', 'Via Peroni 30'),
	('Roma', 'Via Calice 20'),
	('Roma', 'Via fiori 12');
	
insert into libro values
	('9780451524935', '1984', 'In a dystopian future, the totalitarian regime of Big Brother controls all aspects of life.', 'Secker & Warburg'),
	('9780439023528', 'The Hunger Games', 'Katniss Everdeen volunteers for a deadly competition in a dystopian future.', 'Scholastic Press'),
	('9780141439518', 'Pride and Prejudice', 'Elizabeth Bennet navigates issues of manners, upbringing, and marriage in early 19th century England.', 'T. Egerton'),
	('9780316769488', 'The Catcher in the Rye', 'Holden Caulfield recounts events in his life after being expelled from his prep school.', 'Little, Brown and Company'),
	('9780061120084', 'To Kill a Mockingbird', 'Scout Finch grows up in the racially charged Depression-era South.', 'J.B. Lippincott & Co.'),
	('9780743273565', 'The Great Gatsby', 'Jay Gatsby s love for Daisy Buchanan in the roaring twenties is doomed by their differing social status.', 'Charles Scribner s Sons'),
	('9780140449136', 'The Odyssey', 'Homer s epic poem about Odysseus s ten-year journey home after the Trojan War.', 'Penguin Classics'),
	('9780316037923', 'The Twilight Saga: New Moon', 'Bella Swan falls into deep depression when Edward leaves her.', 'Little, Brown and Company'),
	('9780385472579', 'The Secret History', 'A group of eccentric misfits at an elite college commit a murder.', 'Knopf'),
	('9780679783268', 'Beloved', 'Sethe, an escaped slave, is haunted by the ghost of her dead daughter.', 'Alfred A. Knopf');
	
insert into Autore (Nome_cognome, Biografia, Data_nascita, Data_morte) values
('George Orwell', 'English novelist, essayist, journalist and critic.', '1903-06-25', '1950-01-21'),
('Suzanne Collins', 'American television writer and author, best known for The Hunger Games series.', '1962-08-10', NULL),
('Jane Austen', 'English novelist known primarily for her six major novels.', '1775-12-16', '1817-07-18'),
('J.D. Salinger', 'American writer best known for his novel The Catcher in the Rye.', '1919-01-01', '2010-01-27'),
('Harper Lee', 'American novelist widely known for To Kill a Mockingbird.', '1926-04-28', '2016-02-19'),
('F. Scott Fitzgerald', 'American novelist and short story writer, widely regarded as one of the greatest American writers of the 20th century.', '1896-09-24', '1940-12-21'),
('Homer', 'Ancient Greek epic poet, traditionally said to be the author of the epic poems the Iliad and the Odyssey.', NULL, NULL),
('Stephenie Meyer', 'American novelist, best known for her vampire romance series Twilight.', '1973-12-24', NULL),
('Donna Tartt', 'American author and essayist, known for her novels The Secret History, The Little Friend, and The Goldfinch.', '1963-12-23', NULL),
('Toni Morrison', 'American novelist, essayist, editor, teacher, and professor emeritus at Princeton University.', '1931-02-18', '2019-08-05');

insert into Merito (Libro, Autore) values
	('9780451524935', 1),
	('9780439023528', 2), 
	('9780141439518', 3), 
	('9780316769488', 4), 
	('9780061120084', 5), 
	('9780743273565', 6), 
	('9780140449136', 7), 
	('9780316037923', 8), 
	('9780385472579', 9),
	('9780679783268', 10);

--password bibliotecario: 
insert into Bibliotecario (CF, Nome_cognome, Sede, Pswrd) values
	('MAMAMAMAMAMAMAMA','Marco Fumagalli', '1', 'UFNXUkRCSUI='),
	('CACACACACACACACA','Carlo Giuduce', '2', 'UFNXUkRCSUI='),
	('LLLLLLLLLLLLLLLL', 'Leonardo da vinci', '3', 'UFNXUkRCSUI='),
	('EZEZEZEZEZEZEZEZ','Ezio Auditore', '4', 'UFNXUkRCSUI='),
	('TETETETETETETETE', 'Teodoro beluomo', '5', 'UFNXUkRCSUI='),
	('FRFRFRFRFRFRFRFR', 'Francesca Verdi', '6', 'UFNXUkRCSUI='),
	('GGGGGGGGGGGGGGGG', 'Giulia Stirpe', '7', 'UFNXUkRCSUI='),
	('GIGIGIGIGIGIGIGI', 'Giacomo di siena', '8', 'UFNXUkRCSUI='),
	('MMMMMMMMMMMMMMMM','Mario Cancelli', '9', 'UFNXUkRCSUI='),
	('LULULULULULULULU', 'Luca Puliti', '10', 'UFNXUkRCSUI='),
	('MRMRMRMRMRMRMRMR', 'Maria Delle Donne', '11', 'UFNXUkRCSUI='),
	('GOGOGOGOGOGOGOGO', 'Gioia Merli', '12', 'UFNXUkRCSUI='),
	('LCLCLCLCLCLCLCLC', 'Luce Rossi', '13', 'UFNXUkRCSUI='),
	('AAAAAAAAAAAAAAAA', 'Antonio Berto', '14', 'UFNXUkRCSUI='),
	('ARARARARARARARAR', 'Armando Forte', '15', 'UFNXUkRCSUI=');

insert into copia(ISBN, Sede, Disponibile) values 
	('9780451524935',1,true),
	('9780451524935',12,true),
	('9780451524935',4,true),
	('9780439023528',13,true),
	('9780439023528',11,true),
	('9780439023528',10,true),
	('9780141439518',3,true),
	('9780141439518',7,true),
	('9780141439518',1,true),
	('9780316769488',2,true),
	('9780316769488',2,true),
	('9780316769488',6,true),
	('9780061120084',15,true),
	('9780061120084',4,true),
	('9780061120084',1,true),
	('9780743273565',6,true),
	('9780743273565',5,true),
	('9780743273565',9,true),
	('9780140449136',8,true),
	('9780140449136',14,true),
	('9780140449136',13,true),
	('9780316037923',5,true),
	('9780316037923',7,true),
	('9780316037923',12,true),
	('9780385472579',10,true),
	('9780385472579',15,true),
	('9780385472579',8,true),
	('9780679783268',5,true),
	('9780679783268',11,true),
	('9780679783268',9,true);
