;;; Autore: Cogo Luca 830045


(defun lmc-run (filename in)
  (let ((mem (lmc-load filename)))
    (cond
      ((eq mem 1)   ;; 1 è il valore restituito da lmc-load in caso di errore
        nil
        (format t "Errore: file non ben formato"))
      (t
        (let ((out (execution-loop (list 'state
                                         :acc 0
                                         :pc 0
                                         :mem mem
                                         :in in
                                         :out '()
                                         :flag 'noflag))))
          (cond
            ((eq out 1)
              nil
              (format t "Errore: input non valido"))
            (t
              out)))))))

;;; INTERPRETE

;;; Applica state-ctrl e poi inizia il loop con lp
(defun execution-loop (State)
  (cond
    ((state-ctrl State)
      (lp State))
    (t
      nil
      (format t "Stato iniziale non accettato"))))

;;; Applica one-instruction in loop fino a raggiungere un halted-state
(defun lp (State)
  (cond
    ((eq State 1)
      1)
    ((eq (first State) 'state)
      (lp (one-instruction State)))
    ((eq (first State) 'halted-state)
      (getf (cdr State) :out))))

;;; Legge la lista di stato e in base alla cella di memoria puntata richiama
;;; la funzione corretta
(defun one-instruction (State)
  (let (
  (acc (getf (cdr State) :acc))
	(pc (getf (cdr State) :pc))
	(mem (getf (cdr State) :mem))
	(in (getf (cdr State) :in))
	(out (getf (cdr State) :out))
	(flag (getf (cdr State) :flag)))
    (let ((op (nth pc mem)))
      (cond ((eq(car State) 'halted-state)
              1
              (format t 
                "Errore, lo stato iniziale non puo' essere un halted state"))
            ((and (>= op 100) (<= op 199))
              (sum acc pc mem in out op))
            ((and (>= op 200) (<= op 299))
              (sub acc pc mem in out op))
            ((and (>= op 300) (<= op 399))
              (sta acc pc mem in out flag op))
            ((and (>= op 500) (<= op 599))
              (lda pc mem in out flag op))
            ((and (>= op 600) (<= op 699))
              (bra acc mem in out flag op))
            ((and (>= op 700) (<= op 799))
              (brz acc pc mem in out flag op))
            ((and (>= op 800) (<= op 899))
              (brp acc pc mem in out flag op))
            ((= op 901)
              (in pc mem in out flag))
            ((= op 902)
              (out acc pc mem in out flag))
            ((and (>= op 0) (<= op 99))
              (hlt acc pc mem in out flag))))))

(defun sum (acc pc mem in out op)
  (list 'state :acc (mod (+ acc (nth (- op 100) mem)) 1000)
               :pc (pc-inc pc)
               :mem mem
               :in in
               :out out
               :flag (flag-ctrl (+ acc (nth (- op 100) mem)))))

(defun sub (acc pc mem in out op)
  (list 'state :acc (mod (- acc (nth (- op 200) mem)) 1000)
               :pc (pc-inc pc)
               :mem mem
               :in in
               :out out
               :flag (flag-ctrl (- acc (nth (- op 200) mem)))))

(defun sta (acc pc mem in out flag op)
  (list 'state :acc acc
               :pc (pc-inc pc)
               :mem (sost mem (- op 300) acc)
               :in in
               :out out
               :flag flag))

(defun lda (pc mem in out flag op)
  (list 'state :acc (nth (- op 500) mem)
               :pc (pc-inc pc)
               :mem mem
               :in in
               :out out
               :flag flag))

(defun bra (acc mem in out flag op)
  (list 'state  :acc acc
                :pc (- op 600)
                :mem mem
                :in in
                :out out
                :flag flag))

(defun brz (acc pc mem in out flag op)
  (cond
    ((and (eq flag 'noflag) (= acc 0))
      (list 'state
            :acc acc
            :pc (- op 700)
            :mem mem
            :in in
            :out out
            :flag flag))
    (t
      (list 'state
            :acc acc
            :pc (pc-inc pc)
            :mem mem
            :in in
            :out out
            :flag flag ))))

(defun brp (acc pc mem in out flag op)
  (cond
    ((eq flag 'noflag)
      (list 'state
            :acc acc
            :pc (- op 800)
            :mem mem
            :in in
            :out out
            :flag flag))
    (t
      (list 'state
            :acc acc
            :pc (pc-inc pc)
            :mem mem
            :in in
            :out out
            :flag flag ))))

(defun in (pc mem in out flag)
  (cond
    ((/= (length in) 0)
      (list 'state
            :acc (car in)
            :pc (pc-inc pc)
            :mem mem
            :in (cdr in)
            :out out
            :flag flag))
    (t                  ;; Errore: chiede input a una lista vuota.
      1)))              ;; Ritorno 1 come segnale per la funzione lp

(defun out (acc pc mem in out flag)
  (list 'state
        :acc acc
        :pc (pc-inc pc)
        :mem mem
        :in in
        :out (append out (list acc))
        :flag flag))

(defun hlt (acc pc mem in out flag)
  (list 'halted-state
        :acc acc
        :pc pc
        :mem mem
        :in in
        :out out
        :flag flag))

;;; Incrementa il pc e lo riporta a 0 se e' 99
(defun pc-inc (pc)
  (cond
    ((/= pc 99)
      (1+ pc))
    (t
      0)))

;;; Se la add o la sub danno un risultato )0,99( imposta flag
(defun flag-ctrl (n)
  (cond
    ((and (<= n 999) (>= n 0))
      'noflag)
    (t
      'flag)))

;;; Sostituisce nella lista l l'n-esimo elemento con k
(defun sost (l n k)
  (cond
    ((null l)
      nil)
    ((eq n 0)
      (cons k (cdr l)))
    ((cons (car l) (sost (cdr l) (1- n) k)))))

;;; Controlla che lo stato inserito abbia valori validi
(defun state-ctrl (state)
  (let (
    (acc (getf (cdr state) :acc))
  	(pc (getf (cdr state) :pc))
  	(mem (getf (cdr state) :mem))
  	(in (getf (cdr state) :in))
  	(out (getf (cdr state) :out))
  	(flag (getf (cdr state) :flag)))
    (cond
      ((and (>= acc 0) (<= acc 999)
            (>= pc 0) (<= pc 99)
            (= (length mem) 100) (list-ctrl mem)
            (list-ctrl in)
            (list-ctrl out)
            (is-a-flag flag))
                t)
      (t
        nil))))

;;; Controlla che l'input sia solo del tipo flag/noflag
(defun is-a-flag (flag)
  (cond
    ((and (not(eq flag 'flag)) (not (eq flag 'noflag)))
      nil)
    (t
      t)))

;;; Usa num--ctrl per controllare che
;;; tutti gli elementi di una lista siano [0,999]
(defun list-ctrl (l)
  (cond
    ((null l)
      t)
    ((and (numberp (car l)) (num-ctrl (car l)))
      (list-ctrl (cdr l)))
    (t
      nil)))

;;; Controlla che n sia [0,999]
(defun num-ctrl (n)
  (cond
    ((and (>= n 0) (<= n 999))
      t)
    (t
      nil)))




;;; COMPILATORE

;;; Utilizza tutti i predicati definiti di seguito per estrarre la lista di mem
(defun lmc-load (filename)
  (let ((cl (clean-list (file-to-rows filename))))
    (mem-ctrl
      (cod-gen
        (label-trans
          (remove-label cl) (dict-ctrl (label-dict cl)) 0)))))
; se si rimuove dict-ctrl le label doppie saranno gestite in modo da
; tenere conto solo della prima dichiarazione e ignorare le successive


;;; Genera una lista a partire da un stream
(defun read-rows (stream)
  (let ((e (read-line stream nil 'eof)))
    (unless (eq e 'eof)
    (append (list e) (read-rows stream)))))

;;; Utilizza read-rows per estrarre una lista
(defun file-to-rows (filename)
  (with-open-file (stream filename
                    :direction :input
                    :if-does-not-exist :error)
                  (read-rows stream)))


;;; Applica up, rcfl, trim-list e remove-empty per ottenere le strighe pulite
(defun clean-list (l)
  (remove-empty (trim-list (rcfl (up l)))))

;;; Porta tutte le strighe di una lista uppercase
(defun up (l)
  (mapcar 'string-upcase l))

;;; Usa rcfstr per rimuovere i commenti da ogni stringa della lista
(defun rcfl (l)
  (mapcar 'rcfstr l))

;;; Se c'e, rimuove il commento da una stringa
(defun rcfstr (str)
  (let ((p (search "//" str)))
    (cond
      ((not (eq p nil)) (subseq str 0 p))
      (t (cond
            ((not (eq (search "/" str) nil))  ;; errore: uso 1 per segnalarlo
              1)
         (t str))))))

;;; Rimuove gli spazi di troppo da tutte le stringhe di una lista
(defun trim-list (l)
  (cond
    ((not (member 1 l))
      (mapcar 'trim-string l))
    (t
      1)))

;;; Elimina gli spazi ai margini di una stringa
(defun trim-string (str)
  (string-trim " " str))

;;; Usa remove-string per togliere le stringhe vuote da l
(defun remove-empty (l)
  (cond
    ((eq l 1)
      1)
    (t
      (remove-string "" l))))

;;; Rimuove tutte le occorrenze di str da l
(defun remove-string (str l)
  (cond
    ((null l)
      nil)
    ((not(string-equal (car l) str))
      (append (list (car l)) (remove-string str (cdr l))))
    (t
      (remove-string str (cdr l)))))


;;; Usa find-label per creare un dizionario di etichette
(defun label-dict (l)
  (cond
    ((eq l 1)
      1)
    (t
      (mapcar 'find-label l))))

;;; Trova le label e le restituisce
(defun find-label (str)
  (let ((f (string-to-list str)))
    (cond
      ((and (>= (length f) 2)
      (string-equal (car f) "DAT")
      (not (is-number (second f))))
        1)
      ((and (>= (length f) 3)
      (string-equal (second f) "DAT")
      (not (is-number (third f))))
        1)
      ((is-number (car f))
        1)
      ((not (is-key (car f)))
        (car f))
      (t
        0))))
; se si rimuovono i due casi con il "DAT", sarà possibile creare istruzioni
; del tipo "DAT LABEL" senza problemi


;;; Applica rep-ctrl su dizionario per controllare label doppie
;;; Il dizionario viene prima filtrato da 0 e 1 (codici per nolabel e error)
(defun dict-ctrl (l)
  (cond
    ((eq l 1) ; In caso di errore precedente, restituisco ancora 1
      1)
    ((rep-ctrl (remove 1 (remove 0 l)))
     l)
    (t
      1)))

;;; Controlla che non ci siano doppioni nella lista
(defun rep-ctrl (l)
  (cond
    ((null l)
      t)
    ((no-rep (car l) (cdr l))
      (rep-ctrl (cdr l)))
    (t
      nil)))

;;; Controlla che non compaia mai str nella lista
(defun no-rep (str l)
  (cond
    ((null l)
      t)
    ((not (string-equal str (car l)))
      (no-rep str (cdr l)))
    (t
      nil)))


;;; Rimuove le etichette da tutta la lista
(defun remove-label (l)
  (cond
    ((eq l 1)
      1)
   (t
     (mapcar 'remove-label-from-string l))))

;;; Se c'e una label in una stringa, la rimuove
(defun remove-label-from-string (str)
  (let ((p (search " " str)))
    (cond
      ((is-key(subseq str 0 p))
        str)
      ((eq p nil)
        1)
      (t
        (subseq str (1+ p))))))

;;; Restituisce true se str e' una istruzione
(defun is-key (str)
  (cond
    ((or
     (string-equal str "ADD")
     (string-equal str "SUB")
     (string-equal str "STA")
     (string-equal str "LDA")
     (string-equal str "BRA")
     (string-equal str "BRZ")
     (string-equal str "BRP")
     (string-equal str "ADD")
     (string-equal str "INP")
     (string-equal str "OUT")
     (string-equal str "HLT")
     (string-equal str "DAT"))
       t)
    (t
       nil)))


;;; Trasforma la stringa in una lista di parole
(defun string-to-list (str)
  (remove-string "" (split-sequence " " str)))

;;; Trasforma la lista di stringhe in una sola stringa
(defun list-to-string (l)
  (cond
    ((null l)
      "")
    (t
      (string-trim
       " "
       (concatenate 'string (car l) " " (list-to-string (cdr l)))))))

;;; Sostituisce l'etichetta lab, se la trova in str
(defun swi (str lab n)
  (let ((l (string-to-list str)))
    (cond
      ((eq lab 0)
        str)
      ((string-equal (second l) lab)
        (list-to-string (sost l 1 (write-to-string n))))
      (t
        str))))

;;; Usa swi per la sostituzione di una label in tutte le righe
(defun rows-trans (l lab n)
  (cond
    ((null l)
      nil)
    (t
      (append (list (swi (car l) lab n)) (rows-trans (cdr l) lab n)))))

;;; Sostituzione di tutte le label in tutte le righe, n ( da mettere a 0)
;;; serve a contare la posizione delle label nel dizionario
(defun label-trans (l d n)
  (cond
    ((or (eq l 1) (eq d 1))
      1)
    ((not(not(member 1 d)))
      1)
    ((not(not(member 1 l)))
      1)
    ((null d)
      l)
    (t
      (label-trans (rows-trans l (car d) n) (cdr d) (1+ n)))))


;;; Generazione di una lista di opcode
(defun cod-gen (l)
  (cond
    ((eq l 1)
      1)
    ((null l)
      nil)
    (t
      (append (list (convert (car l))) (cod-gen (cdr l))))))

;;; Trasforma una stringa nel corrispondente opcode
(defun convert (str)
  (let ((l (string-to-list str)))
    (let ((f (car l)))
      (cond
        ((and (= 2 (length l)) (is-number (second l)) )
          (let ((n (+ 0 (parse-integer (second l)))))
            (cond
              ((and (string-equal f "ADD") (<= n 99) (>= n 0))
                (+ 100 (parse-integer (second l))))
              ((and (string-equal f "SUB") (<= n 99) (>= n 0))
                (+ 200 (parse-integer (second l))))
              ((and (string-equal f "STA") (<= n 99) (>= n 0))
                (+ 300 (parse-integer (second l))))
              ((and (string-equal f "LDA") (<= n 99) (>= n 0))
                (+ 500 (parse-integer (second l))))
              ((and (string-equal f "BRA") (<= n 99) (>= n 0))
                (+ 600 (parse-integer (second l))))
              ((and (string-equal f "BRZ") (<= n 99) (>= n 0))
                (+ 700 (parse-integer (second l))))
              ((and (string-equal f "BRP") (<= n 99) (>= n 0))
                (+ 800 (parse-integer (second l))))
              ((and (string-equal f "DAT") (<= n 999) (>= n 0))
                (+ 0 (parse-integer (second l))))
              (t
                nil))))
        ((= 1 (length l))
          (cond
            ((and (string-equal f "DAT"))
              0)
            ((and (string-equal f "INP"))
              901)
            ((and (string-equal f "OUT"))
              902)
            ((and (string-equal f "HLT"))
              0)
            (t
              nil)))
        (t
          nil)))))

;;; Se la stringa e' un numero restituisce true
(defun is-number (str)
  (let ((n (parse-integer str :junk-allowed t)))
    (cond
      ((and (not (not n)) (= (length str) (length (write-to-string n))))
        t)
      (t
        nil))))

;;; Controlla che la memoria abbia 100 elementi
(defun mem-ctrl (l)
  (cond
    ((eq l 1)
      1)
    ((not (not (member nil l)))
      1)
    ((> (length l) 100)
      1)
    (t
      (list-padding l (- 100 (length l))))))

;;; Effettua padding 100 alla lista
(defun list-padding (l n)
  (cond
    ((= 0 n)
      l)
    (t
      (list-padding (append l (list 0)) (1- n)))))
