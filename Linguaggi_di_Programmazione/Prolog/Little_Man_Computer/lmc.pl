%Autore: Cogo Luca 830045


lmc_run(Filename, In, Out) :-
    lmc_load(Filename, Mem),
    execution_loop(state(0, 0, Mem, In, [], noflag),Out).


% INTERPRETE:

%%% Chiama il controllo sul primo input e chiama il loop che itera
execution_loop(State, Out) :-
    state_ctrl(State),
    loop(State, Out).

%%% Loop di esecuzione: itera sulla lista della memoria fino
%%% a raggiungere un haltedstate
loop(State, Out) :-
    one_instruction(State, NewState),
    loop(NewState, Out).

%%% Caso base di uscita:
%%% ho raggiunto un halted_state -> restituisco Out
loop(halted_state(_, _, _, _, Out, _), Out).

%%% Incrementatore PC: restituisce Pc+1 tranne quando Pc=99
pc_inc(Pc, NPc) :-
    Pc < 99,
    NPc is Pc + 1.

pc_inc(99, 0).



%%% Controlli sullo stato iniziale

%%% Controlla che la lista sia formata solo da interi
n_ctrl([]).

n_ctrl([H|T]) :-
    integer(H),
    n_ctrl(T).


%%% Controlla che Flag non assuma altri valori
is_a_flag(flag).

is_a_flag(noflag).

%%% Controlla che In contenga valori [0,999], [] -> caso base
r_ctrl([]).

r_ctrl([H|T]) :-
    H >= 0,
    H =< 999,
    r_ctrl(T).

%%% Controlla che Mem contenga esattamente 100 elementi
state_ctrl(state(_, _, Mem, In, _, Flag)) :-
    length(Mem, 100),
    n_ctrl(In),
    r_ctrl(In),
    r_ctrl(Mem), %Devo fare lo stesso controllo anche con la Mem
    is_a_flag(Flag).




%%% Istruzione ADD:
one_instruction(state(Acc, Pc, Mem, In, Out, _),
                state(NAcc, NPc, Mem, In, Out, NFlag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 100,
    Ta =< 199,
    Tb is Ta - 100,
    nth0(Tb, Mem, Tc),
    Td is Acc + Tc,
    NAcc is mod(Td, 1000),
    pc_inc(Pc, NPc),
    add_ctrl(Td, NFlag).

%%% Istruzione SUB:
one_instruction(state(Acc, Pc, Mem, In, Out, _),
                state(NAcc, NPc, Mem, In, Out, NFlag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 200,
    Ta =< 299,
    Tb is Ta - 200,
    nth0(Tb, Mem, Tc),
    Td is Acc - Tc,
    NAcc is mod(Td, 1000),
    pc_inc(Pc, NPc),
    sub_ctrl(Td, NFlag).

%%% Istruzione STORE:
 one_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NPc, NMem, In, Out, Flag)) :-
   nth0(Pc, Mem, Ta),
   Ta >= 300,
   Ta =< 399,
   Tb is Ta - 300,
   replace(Tb, Mem, Acc, NMem),
   pc_inc(Pc, NPc).

%%% Istruzione LOAD
one_instruction(state(_, Pc, Mem, In, Out, Flag),
                state(NAcc, NPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 500,
    Ta =< 599,
    !,
    Tb is Ta - 500,
    nth0(Tb, Mem, Tc),
    NAcc is Tc,
    pc_inc(Pc, NPc).

%%% Istruzione BRANCH
one_instruction(state(Acc, Pc, Mem, In , Out, Flag),
                state(Acc, NPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 600,
    Ta =< 699,
    !,
    Tb is Ta - 600,
    NPc is Tb.

%%% Istruzione BRZ quando Acc=0 e noflag
one_instruction(state(Acc, Pc, Mem, In , Out, Flag),
                state(Acc, NPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 700,
    Ta =< 799,
    Acc is 0,
    no_flag(Flag),
    !,
    Tb is Ta - 700,
    NPc is Tb.

%%% Variante BRZ per quando le condizioni non si verificano
one_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                state(Acc, NPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 700,
    Ta =< 799,
    pc_inc(Pc, NPc).

%%% Istruzione BRP quando le condizioni sono verificate -> noflag
one_instruction(state(Acc, Pc, Mem, In, Out, noflag),
                state(Acc, NPc, Mem, In, Out, noflag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 800,
    Ta =< 899,
    !,
    Tb is Ta - 800,
    NPc is Tb.

%%% Istruzione BRP quando le condizioni non si verificano -> noflag
one_instruction(state(Acc, Pc, Mem, In, Out, flag),
               state(Acc, NPc, Mem, In, Out, noflag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 800,
    Ta =< 899,
    !,
    pc_inc(Pc, NPc).

%%% Istruzione Input
one_instruction(state(_, Pc, Mem, In, Out, Flag),
               state(NAcc, NPc, Mem, NIn, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta is 901,
    !,
    length(In,Tb),
    Tb > 0,
    nth0(0, In, NAcc, NIn),
    pc_inc(Pc, NPc).

%%% Istruzione Output
one_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                state(Acc, NPc, Mem, In, NOut, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta is 902,
    !,
    append(Out, [Acc], NOut),
    pc_inc(Pc, NPc).

%%% Istruzione Halt
one_instruction(state(Acc, Pc, Mem, In, Out, Flag),
               halted_state(Acc, Pc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Ta),
    Ta >= 0,
    Ta =< 99.


%%% Predicati definiti per one_instruciton:

%%% Controlla che Acc+Reg<1000 (istruzione ADD)
add_ctrl(Td, flag) :-
    Td >= 1000,
    !.

add_ctrl(Td, noflag) :-
    Td < 1000,
    !.

%%% Controlla se il contenuto del registro è positivo o negativo
sub_ctrl(Td, flag) :-
    Td < 0,
    !.

sub_ctrl(Td, noflag) :-
    Td >= 0,
    !.

%%% Istruzione replace, che sostituisce con N l'elemento di indice I
%%% della lista L
replace(I, L, N, K) :-
    nth0(I, L, _, R),
    nth0(I, K, N, R).

%%% Controlla che il flag sia attivo, se non lo è restituisce false,
%%% serve per BRZ e BRP
no_flag(noflag).




% COMPILATORE

lmc_load(Filename, Mem) :-
    read_file(Filename, Str),
    string_upper(Str, Up),
    split_string(Up, "\n", "\r", Rows),
    remove_comments(Rows, RowNoCm),
    remove_empty(RowNoCm, RowNoEmpty),
    label_trans(RowNoEmpty, InstList),
    mem_generator(InstList, Ta),
    mem_padding(Ta, Mem).

%%% Apre il file e lo trasforma in una stringa
read_file(Filename,Str) :-
    open(Filename, read, In),
    read_string(In,_,Str),
    close(In).

%%% Prende in input una stringa e restituisce una lista di char, usando
%%% list_to_char
string_to_charlist(String, L) :-
    string_to_list(String, Ta),
    list_to_char(Ta, L).

%%% Trasforma una lista di codici ASCII in una lista di char
list_to_char([], []).

list_to_char([H1|T1], [H2|T2]) :-
    char_code(H2, H1),
    list_to_char(T1, T2).

%%% Chiama rcfs per rimuovere i commenti da tutte le righe
remove_comments([], []).

remove_comments([H1|T1], [H2|T2]) :-
    rcfs(H1, H2),
    remove_comments(T1, T2).

%%% Rimuove i commenti da una stringa
rcfs(H1, H2) :-
    string_to_charlist(H1, Ta),
    first_ctrl(Ta, Tb),
    !,
    next_ctrl(Tb),
    once(nth0(I1, Ta, /)),
    length(Ta, L),
    I2 is L - I1,
    sub_string(H1, 0, _, I2, H2).

rcfs(H1, H2) :-
    sub_string(H1, 0, _, 0, H2).



%%% Rimuove tutte le righe vuote
remove_empty([], []).

remove_empty([H1|T1], L) :-
    H1 = "",
    !,
    remove_empty(T1, L).

remove_empty([H1|T1], [H1|T2]) :-
    remove_empty(T1, T2).



%%% Controlla se c'è uno / e restituisce quello che c'è dopo
first_ctrl(['/'|T], T) :-
    !.

first_ctrl([_|T], L) :-
    first_ctrl(T, L).

%%% Guarda se la testa è uno / (usata in combinazione con first_ctrl)
next_ctrl(['/'|_]).


%%% Keywords:
key("ADD").
key("SUB").
key("STA").
key("LDA").
key("BRA").
key("BRZ").
key("BRP").
key("INP").
key("OUT").
key("HLT").
key("DAT").

not_a_key(T):-
    T \= "ADD",
    T \= "SUB",
    T \= "STA",
    T \= "LDA",
    T \= "BRA",
    T \= "BRZ",
    T \= "BRP",
    T \= "INP",
    T \= "OUT",
    T \= "HLT",
    T \= "DAT".


%%% Trasforma le labels nei rispettivi indirizzi e rimuove
%%% Si aspetta stringhe uppercase (le ho gia rese tali)
%%% per applicare not_a_key
label_trans(RowNoEmpty, InstList) :-
    label_dict(RowNoEmpty, D, L),
    dict_ctrl(D),
    transform(L, D, 0, InstList).


%%% Non sono consentite etichette che si ripetono
dict_ctrl(D) :-
    delete(D, 0, Ta),
    rep_ctrl(Ta).


rep_ctrl([]).

rep_ctrl([H|T]) :-
    no_rep(H, T),
    rep_ctrl(T).

no_rep(_, []).

no_rep(Str, [H|T]) :-
    Str \= H,
    no_rep(Str, T).


%%% Crea un dizionario di label
label_dict([], [], []).

label_dict([H1|T1], [H2|T2], [H3|T3]) :-
    extract_label(H1, H2, H3),%Trova l'etichetta e la mette nella lista 2
    label_dict(T1, T2, T3).


%%% Trova e toglie l'etichetta nella singola riga
%%% Label numeriche non sono accettate
extract_label(Str, _, _) :-
    split_string(Str, " ", " ", [H1|_]),
    atom_number(H1, _),
    !,
    fail.

%%% Una riga del tipo "DAT label" non è accettata
extract_label(Str, _, _) :-
    split_string(Str, " ", " ", [Ta, Tb|_]),
    Ta = "DAT",
    is_not_a_number(Tb),
    !,
    fail.

%%% Una riga del tipo "label DAT label" non è accettata
extract_label(Str, _, _) :-
    split_string(Str, " ", " ", [_, Tb, Tc|_]),
    Tb = "DAT",
    is_not_a_number(Tc),
    !,
    fail.

%%% Gestione righe con label
extract_label(Str, Lab, NewStr) :-
    split_string(Str, " ", " ", [H1|T1]),
    Ta = H1,
    not_a_key(Ta),
    !,
    Lab = Ta,
    losts(T1, "", NewStr).

%%% Gestione righe senza label
extract_label(Str, 0, Str).

%%% Concat a List of strings to a string
losts([], S, S).

losts([H1|T1], S, String) :-
    atom_concat(S, H1, Ta),
    atom_concat(Ta, " ", Tb),
    losts(T1, Tb, String).

%%% Restituisce true se Str è un numero
is_not_a_number(Str) :-
    atom_number(Str, _),
    !,
    fail.

is_not_a_number(_).


%%% Usa la switch per trasformare tutte
%%% le label negli indirizzi corrispondenti
transform(L, [], _, L).

transform([H1|T1], [H2|T2], I, [H3|T3]) :-
    switch([H1|T1], H2, I, L),
    Ta is I + 1,
    transform(L, T2, Ta, [H3|T3]).

%%% Se trova Label la sostituisce con I
switch([], _, _, []).

switch([H1|T1], Label, I, [H2|T2]) :-
    split_string(H1, " ", " ", L1),
    nth0(1, L1, Label),
    !,
    replace(1, L1, I, L2),
    losts(L2, "", H2),
    switch(T1, Label, I, T2).

switch([H1|T1], Label, I, [H2|T2]) :-
    H2 = H1,
    switch(T1, Label, I, T2).



%%% Legge la lista e converte le istruzioni in numeri
mem_generator([], []).

mem_generator([H1|T1], [H2|T2]) :-
    split_string(H1, " ", " ", [X, Y|T3]),
    length([X, Y|T3], 2),
    key(X),
    atom_number(Y, Z),
    integer(Z),
    !,
    convert(X, Z, H2),
    mem_generator(T1, T2).

mem_generator([H1|T1], [H2|T2]) :-
    split_string(H1, " ", " ", [H3|T3]),
    length([H3|T3], 1),
    key(H3),
    !,
    convert(H3, H2),
    mem_generator(T1, T2).


%%% Predicati che convertono:
convert("ADD", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 100,
    !.

convert("SUB", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 200,
    !.

convert("STA", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 300,
    !.

convert("LDA", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 500,
    !.

convert("BRA", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 600,
    !.

convert("BRZ", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 700,
    !.

convert("BRP", X, Q) :-
    X >= 0,
    X =< 99,
    Q is X + 800,
    !.

convert("DAT", X, X) :-
    X >= 0,
    X =< 999,
    !.

convert("INP", 901).

convert("OUT", 902).

convert("HLT", 0).

convert("DAT", 0).

%%% Se la memoria è >100 errore,
%%% se <100 faccio padding
mem_padding(X, Mem) :-
    length(X, Ta),
    Tb is 100 - Ta,
    pad(Tb, X, Mem).

pad(N1, L1, L) :-
    N1 > 0,
    append(L1, [0], L2),
    N2 is N1 - 1,
    pad(N2, L2, L).

pad(0, L, L).















