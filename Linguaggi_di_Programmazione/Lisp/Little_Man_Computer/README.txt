Cogo Luca 

LITTLE MAN COMPUTER

Questo progetto è un'implementazione in LISP di un simulatore del Little Man Computer
Little Man Computer è un modello di computer a istruzioni realizzato da Stuart Madnik nel 1965.
Il simulatore riceve in input un file *.lmc e una lista di input, si occupa dunque di simulare il comportamento del LMC. 

L'architettura del LMC ha i seguenti elementi:
-Accumulatore: 		Unico registro in cui vengono salvati temporaneamente i risultati numerici delle operazioni
-Program Counter: 	Registro che indica la cella di memoria attualmente puntata
-Memoria:		Corrisponde al file sorgente, tradotto in codice macchina. 
	 		Contiene sia istruzioni che variabili e può essere modificata dalle istruzioni stesse
-Input: 		Lista numerica corrispondente agli input del programma lanciato
-Output: 		Lista numerica tramite cui il programma può restituire i risultati delle operazioni
-Flag: 			Registro booleano utile per il controllo di alcune operazioni


STRUTTURA DI UN FILE LMC:

Un file *.lmc ben formato può contenere istruzioni, etichette e commenti.

	#ISTRUZIONI
		Le istruzioni devono essere scritte su righe distinte del file (le righe vuote saranno automaticamente ignorate). 
		Il LMC gestisce un massimo di 100 istruzioni (senza contare le righe vuote), un file più lungo non sarà accettato. 
		Questa è la lista di istruzioni disponibili:
		
		Istruzione 	Valori possibili per xx 	Significato
		----------------------------------------------------------------------------------------------------------
		ADD xx 		Indirizzo o etichetta 		Esegui l’istruzione di addizione tra l’accumulatore e il
								valore contenuto nella cella indicata da xx
		----------------------------------------------------------------------------------------------------------
		SUB xx 		Indirizzo o etichetta 		Esegui l’istruzione di sottrazione tra l’accumulatore e il
								valore contenuto nella cella indicata da xx
		----------------------------------------------------------------------------------------------------------
		STA xx 		Indirizzo o etichetta 		Esegue una istruzione di store del valore
								dell’accumulatore nella cella indicata da xx
		----------------------------------------------------------------------------------------------------------
		LDA xx 		Indirizzo o etichetta 		Esegue una istruzione di load dal valore contenuto nella
								cella indicata da xx nell’accumulatore
		----------------------------------------------------------------------------------------------------------
		BRA xx 		Indirizzo o etichetta 		Esegue una istruzione di branch non condizionale al
								valore indicato da xx		
		----------------------------------------------------------------------------------------------------------
		BRZ xx 		Indirizzo o etichetta 		Esegue una istruzione di branch condizionale (se
								l’accumulatore è zero e non vi è il flag acceso) al valore
								indicato da xx.
		----------------------------------------------------------------------------------------------------------		
		BRP xx 		Indirizzo o etichetta 		Esegue una istruzione di branch condizionale (se non vi è
								il flag acceso) al valore indicato da xx.
		----------------------------------------------------------------------------------------------------------
		INP 		Nessuno 			Esegue una istruzione di input
		----------------------------------------------------------------------------------------------------------
		OUT 		Nessuno 			Esegue una istruzione di output
		----------------------------------------------------------------------------------------------------------
		HLT 		Nessuno 			Esegue una istruzione di halt
		----------------------------------------------------------------------------------------------------------
		DAT xx 		Numero 				Memorizza nella cella di memoria corrispondente a
								questa istruzione assembly il valore xx
		----------------------------------------------------------------------------------------------------------
		DAT 		Nessuno 			Memorizza nella cella di memoria corrispondente a
								questa istruzione assembly
		----------------------------------------------------------------------------------------------------------


	#COMMENTI	
		È possibile inserire commenti su singola riga:
		
		Es:
			add 12 //tutto quello che c'è qui viene ignorato
			//anche questo

	#ETICHETTE 
		È inoltre possibile utilizzare etichette per contrassegnare una cella di memoria (che equivale anche al numero di riga) 
	
		Es:
			label add 12
			sub label 

		In questo caso label assume il valore 0 e quindi alla riga successiva si avrà sub 0.

		ATTENZIONE:		 
		Non sono accettate etichette interamente numeriche o equivalenti a codici istruzione:
			
			lab		v
			Lab123		v
			123lab		v
			123		x
			add		x
		
		Un'etichetta non può fare riferimento a più spazi di memoria contemporaneamente:

			lab add 12
			lab sub 15

		Non è un file ben formato.
		

UTILIZZO:

Aprire LispWorks, dunque caricare e compilare il file lmc.lisp.
Per lanciare un file inserire nella shell il seguente comando:

	(lmc-run "nomefile.lmc" '(...))

dove in '(...) si trova la lita degli input
e premere invio. 

É anche possibile dare al simulatore direttamente una lista di opcode al posto di un file assembly da tradurre.
Bisogna però ricordare che tale lista deve avere una lunghezza pari a 100.
Per fare ciò è sufficiente inserire il seguente comando:

	(execution-loop '(state :acc <Acc> :pc <Pc> :mem <Mem> :in <In> :out <Out> :flag <Flag>))

Dove Mem è la lista di 100 istruzioni e In è la lista di input
L'inserimento di Mem e In non necessita del quote.
Per gli altri parametri è consigliabile inserire i seguenti valori:
Acc = 0
Pc = 0
Out = nil
Flag = noflag
e premere invio.

Ecco i gli opcode corrispondenti alle istruzioni assembly:
	
	ADD xx = 1xx
	SUB xx = 2xx
	STA xx = 3xx
	LDA xx = 5xx
	BRA xx = 6xx
	BRZ xx = 7xx	
	BRP xx = 8xx
	INP    = 901	
	OUT    = 902
	HLT    = xx	


IMPLEMENTAZIONE:
L'intero progetto si suddivide in due parti:
- L'assembler che trasforma un file *.lmc in linguaggio macchina
- Il simulatore che, data la memoria iniziale e l'input produce l'output

	#ASSEMBLER
		La traduzione viene effettuata dalla funzione lmc-load che riceve in input il nome del file e restituisce la lista di memoria.
		La traduzione si suddivide nei seguenti passi:
		-Rimozione di commenti e righe vuote dal file
		-Gestione delle etichette (crea un dizionario delle etichette e lo usa per tradurle quando vengono richiamate da un'istruzione)
		-Trasformazione delle istruzioni in opcode.
		lmc-load andrà a buon fine solo se il file è ben formato secondo le regole definite sopra.

	#SIMULAZIONE 
		Se ne occupa la già citata execution-loop
		Essa riceve in input uno stato iniziale e prosegue la simulazione fino al raggiungimento di un halted-state 
		Per fare ciò viene generato uno stato iniziale costruito in questo modo: 
			
			(state :acc 0 :pc 0 :mem Mem :in In :out Out :flag noflag) 
		
		Al raggiungimento di uno stato del tipo:

			(halted-state ...)
		il loop viene interrotto e la lista di output restituita così com'è.


	
