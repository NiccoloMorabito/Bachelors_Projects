#codifica utf-8
##########################################	MAIN	######################################################

# Il programma main legge una successione di comandi e li esegue nell'ordine.

#	Un comando inizia con una lettera, seguita sulla stessa riga dal testo che contiene i parametri (separati da
#	' ' spazio) della chiamata da eseguire

#	Lo spazio di memoria necessario a contenere l'albero ed eventuali buffer va definito staticamente ed il suo
#	indirizzo viene passato come argomento alle funzioni che ne hanno bisogno.

.data
spazio_stringa:		.space 2004		# si crea lo spazio necessario per contenere la stringa in input (max 1000 nodi)		
albero:			.space 2004		# spazio per copiare la stringa che rappresenta l'albero
nodo_da_aggiungere: 	.half 0
numero_nodi:		.word 0
lunghezza_albero:	.word 0			

.eqv $contatore, $t9
.eqv $indiceNodo, $t8
.eqv $coeff, $t7
.eqv $indirizzo1, $s7
.eqv $indirizzo2, $s6
.eqv $profMax, $s5
.eqv $etichettaMax, $s4

.text
.globl main

main:
	# leggo una stringa, di grandezza massima uguale a space (2002 byte)
	la $a0, spazio_stringa		# imposto lo spazio in memoria come indirizzo di destinazione della stringa
	addi $a0, $a0, 1			# lascio un byte di buco prima di caricare la stringa
	li $a1, 2004			# imposto la grandezza massima di caratteri ricevibili = 2001 (1000 nodi + primo carattere che indica la funzione)
	
	li $v0, 8			# read string
	syscall
	
	# vedo cosa c'e' nel primo carattere della stringa appena letta (ovvero il comando)
	lb $t0, spazio_stringa+1		# t0 = stringa[1]
	
	# se la stringa contine come prima lettera 'Q', esce dal programma
	beq $t0, 'Q', fine_programma
	
	# altrimenti, esegui la funzione corrispondente alla lettera e continua il ciclo
	beq $t0, 'L', prep_leggi
   	beq $t0, 'I', prep_inserisci
   	beq $t0, 'E', prep_elimina
   	beq $t0, 'S', prep_sposta
   	beq $t0, 'V', prep_stampa
   	beq $t0, 'C', prep_trova
   	beq $t0, 'M', prep_cerca
   	beq $t0, 'A', prep_somma
 
	# una delle funzioni sopra viene preparata, poi verra' chiamata nel codice del caso selezionato
	# completata la preparazione, si saltera' di nuovo al main per effettuare una nuova richiesta
	
	j main

prep_leggi:
	la $t0, spazio_stringa		# carico l'indirizzo della stringa ricevuta
	addi $a0, $t0, 2			# aggiungo 2 byte all'indirizzo (per saltare il char 'L' e il primo byte lasciato vuoto, e lo metto come argomento della funzione)

	jal leggi_albero			# si esegue la funzione leggi_albero

	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
prep_inserisci:
	# preparazione argomenti: albero, percorso, etichetta_e_valore, sx_o_dx
	la $a0, albero			# primo argomento: indirizzo albero
	
		# la stringa su cui devo lavorare e' di questo tipo: " Iahdma l1 0" ovvero: spaziovuoto + 'I' + percorso + spaziovuoto + nododaaggiungere + spaziovuoto + bitbooleano
		# 1) ricavo l'indice del nodo x percorrendo il percorso
	li $t1, 3			# inizializzo indice1 a 3 (per il byte vuoto + la 'I' + il primo nodo banalmente uguale)
	li $t2, 2			# inizializzo indice2 a 2 (per saltare i primi due byte vuoti)

	inizio_trovanodo3:
	lb $t3, spazio_stringa($t1)	# nodo da cercare = spazio_stringa[indice1]
	addi $t1, $t1, 1			# incremento indice1 per l'iterazione successiva
	beq $t3, ' ', fine_trovanodo3	# termino il ciclo quando il percorso e' finito (incontro il primo spazio)

	sll $t2, $t2, 1			# indiceFiglioSx = indice2 * 2
	lb $t4, albero($t2)		# t4 = figlioSx
	beq $t4, $t3, inizio_trovanodo3	# ricomincio il ciclo con $t2 (indice2) = indiceFiglioSx

	addi $t2, $t2, 2			# indiceFiglioDx = indice*2 + 2	
	j inizio_trovanodo3		# ricomincio il ciclo con $t2 (indice2) = indiceFiglioDx

	fine_trovanodo3:

	move $a1, $t2			# secondo argomento per la chiamata: $t2, ovvero indice2, L'INDICE DEL NODO A CUI ATTACCARE IL FIGLIO
	
	lb $t5, spazio_stringa($t1)	# carico il byte-etichetta del nodo da aggiungere
	sb $t5, nodo_da_aggiungere	# e lo salvo in memoria
	lb $t5, spazio_stringa +1($t1)	# carico il byte-valore del nodo da aggiungere
	sb $t5, nodo_da_aggiungere +1	# e lo salvo in memoria
	
	la $a2, nodo_da_aggiungere	# terzo argomento per la chiamata: indirizzo che contiene i 2 byte del nodo da aggiungere
	
	addi $t1, $t1, 3			# incremento di 4 byte indice 1 per saltare l'hw appena caricata e lo spazio e saltare all'indice del bit booleano
	lb $a3, spazio_stringa($t1)	# quarto argomento per la chiamata: carico il bit booleano che segnala se il nodo deve essere aggiunto alla sinistra o alla destra
	
	jal inserisci_nodo
	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
prep_elimina:
	# preparazione argomenti: albero, percorso del nodo x
	la $a0, albero			# preparo l'indirizzo dell'albero
	
	# calcolo l'indice del nodo x, che individua il sottoalbero da cancellare
	li $t1, 3			# inizializzo indice1 a 3 (per saltare la 'E' e il primo nodo banalmente uguale + il byte vuoto)
	li $t2, 2			# inizializzo indice2 a 2 (per saltare i primi due byte vuoti)

	inizio_trovanodo:
	lb $t3, spazio_stringa($t1)	# nodo da cercare = spazio_stringa[indice1]
	addi $t1, $t1, 1			# incremento indice1 per l'iterazione successiva
	beq $t3, '\n', fine_trovanodo	# termino il ciclo quando ho scorso tutta la stringa inserita

	sll $t2, $t2, 1			# indiceFiglioSx = indice2 * 2
	lb $t4, albero($t2)		# t4 = figlioSx
	beq $t4, $t3, inizio_trovanodo	# ricomincio il ciclo con $t2 (indice2) = indiceFiglioSx

	addi $t2, $t2, 2			# indiceFiglioDx = indice*2 + 2	
	j inizio_trovanodo		# ricomincio il ciclo con $t2 (indice2) = indiceFiglioDx

	fine_trovanodo:

	move $a1, $t2			# secondo argomento per la chiamata: $t2, ovvero indice2, L'INDICE DEL PRIMO NODO DA CANCELLARE
	
	jal elimina_sottoalbero		# eseguo la chiamata alla funzione ricorsiva elimina_sottoalbero
	
	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
prep_sposta:
	# preparazione argomenti
	# jal funzione del caso
	j main				# si salta nuovamente al main per richiedere una nuova funzione	
   	
prep_stampa:
	# preparazione argomenti: indirizzo albero
	la $a0, albero			# preparo l'indirizzo dell'albero

	jal stampa_albero		# chiamo la funzione stampa_albero

	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
prep_trova:
	# preparazione argomenti
	# jal funzione del caso
	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
	
prep_cerca:
	# preparazione argomenti: albero, valore
	la $a0, albero			# primo argomento della funzione: indirizzo albero
	lb $a1, spazio_stringa + 2	# secondo argomento della funzione: valore messo in input (quello che segue 'M')
	li $a2, -1			# terzo argomento: profondita' (andra' a 0 alla prima chiamata)
	li $a3, 2			# quarto argomento: indice della stringa (saltando lo spazio vuoto)
	
	li $profMax, -1			# si inizializza la profondita massima trovata a -1
	
	jal cerca_max_prof_nodo		# si esegue la funzione cerca_max_prof_nodo
	
	move $a0, $profMax		# printo profondita' massima
	li $v0, 1			# print integer
	syscall
	li $a0, ' '			# printo uno spazio
	li $v0, 11			# print character
	syscall
	move $a0, $etichettaMax		# printo etichetta corrispondente
	syscall
	li $a0, '\n'			# printo accapo
	syscall
	
	j main				# si salta nuovamente al main per richiedere una nuova funzione	
	
prep_somma:
	# preparazione argomenti: albero, percorso del nodo x
	la $a0, albero			# preparo l'indirizzo dell'albero
	
	# calcolo l'indice del nodo x, che individua il sottoalbero da sommare
	li $t1, 3			# inizializzo indice1 a 2 (per saltare la 'A' e il primo nodo banalmente uguale + il byte lasciato vuoto)
	li $t2, 2			# inizializzo indice2 a 2 (per saltare i primi due byte vuoti)

	inizio_trovanodo2:
	lb $t3, spazio_stringa($t1)	# nodo da cercare = spazio_stringa[indice1]
	addi $t1, $t1, 1			# incremento indice1 per l'iterazione successiva
	beq $t3, '\n', fine_trovanodo2	# termino il ciclo quando ho scorso tutta la stringa inserita

	sll $t2, $t2, 1			# indiceFiglioSx = indice2 * 2
	lb $t4, albero($t2)		# t4 = figlioSx
	beq $t4, $t3, inizio_trovanodo2	# ricomincio il ciclo con $t2 (indice2) = indiceFiglioSx

	addi $t2, $t2, 2			# indiceFiglioDx = indice*2 + 2	
	j inizio_trovanodo2		# ricomincio il ciclo con $t2 (indice2) = indiceFiglioDx

	fine_trovanodo2:

	move $a1, $t2			# secondo argomento per la chiamata: $t2, ovvero indice2, L'INDICE DEL PRIMO NODO DA SOMMARE
	li $a2, 1			# terzo argomento per la chiamata: il coefficiente per cui bisognera' moltiplicare i valori del nodo in base alla profondita'
	
	li $s0, 0			# inizializzo la variabile somma a 0
	
	jal somma_alterna		# eseguo la chiamata alla funzione ricorsiva somma_alterna
	
	move $a0, $s0			# carico nel registro a0 la somma ottenuta con la funzione chiamata
	li $v0, 1			# print integer
	syscall
	
	li $a0, '\n'			# print accapo
	li $v0, 11
	syscall
	
	j main				# si salta nuovamente al main per richiedere una nuova funzione	



##########################################       FINE MAIN	###############################################################

########################################################################################################################

##########################################     LEGGI_ALBERO 	######################################################

leggi_albero:
	move $indirizzo1, $a0		# carico indirizzo1 dall'argomento della funzione (spazio_stringa)
	la $t2, albero			# carico indirizzo2 da albero
	addi $indirizzo2, $t2, 2		# incremento indirizzo2 di 2, cosi' da lasciare lo spazio vuoto all'inizio del buffer
	
	li $t2, 2			# inizializzo un contatore per la lunghezza della stringa

	inizio_copiaStringa:	# ciclo per la copia della stringa
	
	lb $t3, 	($indirizzo1)		# t3 = byte in indirizzo1
	beq $t3, '\n', fine_copiaStringa	# se il carattere appena letto e' l'accapo, la stringa e' terminata
	beq $t3, '\0', fine_copiaStringa	# anche se il carattere appena letto e' quello terminativo, la stringa e' terminata

	lh $t3, ($indirizzo1)		# t3 = 2 byte di spazio_stringa
	sh $t3, ($indirizzo2)		# in indirizzo2 <- t3
	
	addi $indirizzo1, $indirizzo1, 2	# incremento indirizzo1 di 2 byte
	addi $indirizzo2, $indirizzo2, 2	# incremento indirizzo2 di 2 byte
	addi $t2, $t2, 2			# aumento di 2 la lunghezza dell'albero che sto calcolando
	
	j inizio_copiaStringa	

	fine_copiaStringa:
	
	sw $t2, lunghezza_albero		# salvo la lunghezza dell'albero in memoria

	subi $t2, $t2, 2			# lunghezza -= 2 
	sra $contatore, $t2, 1		# numero nodi = lunghezza/2
	
	sw $contatore, numero_nodi	# salvo il risultato in memoria
	move $a0, $contatore		# stampo contatore
	li $v0, 1
	syscall
	
	li $a0, '\n'			# stampo accapo
	li $v0, 11
	syscall

	jr $ra				# termino la funzione

########################################################################################################################

##########################################    STAMPA_VETTORE 	######################################################

stampa_albero:
	move $indirizzo1, $a0		# salvo indirizzo spazio_stringa	
	addi $indirizzo1, $indirizzo1, 2	# ignoro i primi due byte (elemento vuoto)
	
	move $a0, $indirizzo1		# utilizzo l'indirizzo calcolato come argomento del print
	li $v0, 4			# print string
	syscall
	
	li $a0, '\n'			# print accapo
	li $v0, 11
	syscall
	
	jr $ra				# termino la funzione


########################################################################################################################

##########################################       ELIMINA_SOTTOALBERO  	######################################################

elimina_sottoalbero:
	move $indirizzo1, $a0		# indirizzo = argomento ricevuto
	move $indiceNodo, $a1		# indiceNodo = secondo argomento ricevuto
	add $indirizzo1, $indirizzo1, $indiceNodo	# indirizzo = indirizzo + indiceNodo ricevuto
	
	li $s0, '.'			# metto in un registro il carattere che devo sostituire ai nodi che devo cancellare
	lw $s1, lunghezza_albero		# metto in un registro la dimensione massima dell'albero
	
	sb $s0, ($indirizzo1)		# albero[indiceNodo] = '.'
	sb $s0, 1($indirizzo1)		# albero[indiceNodo+1] = '.'
	
elimina_sasx:
	sll $t5, $a1, 1			# t5 = indiceNodo*2
	bge $t5, $s1, elimina_sadx	# se t5 > len(stringa) ovvero salta eliminazione sottoalberoSX
	# chiamata ricorsiva sul figlio sinistro
	subi $sp, $sp, 8			# alloco lo spazio su stack per due word
	sw $ra, 0($sp)			# salvo il registro su stack
	sw $t5, 4($sp)			# salvo l'indiceNodo su stack
	move $a1, $t5			# a1 = indiceNodo*2
	jal elimina_sottoalbero		# chiamata ricorsiva sul figlio sinistro
	lw $ra, 0($sp)			# carico il registro da stack
	lw $t5, 4($sp)			# carico l'indiceNodo da stack
	addi $sp, $sp, 8			# disalloco lo spazio su stack
	
elimina_sadx:
	addi $t5, $t5, 2			# t5 = indiceNodo*2 + 2
	bge $t5, $s1, fine_eliminazioni	# se t5 > len(stringa) -> salta eliminazione sottoalberoDX e concludi funzione
	# chiamata ricorsiva sul figlio destro
	subi $sp, $sp, 8			# alloco lo spazio su stack per due word
	sw $ra, 0($sp)			# salvo il registro su stack
	sw $t5, 4($sp)			# salvo indiceNodo su stack
	move $a1, $t5			# a1 = indiceNodo*2 + 2
	jal elimina_sottoalbero		# chiamata ricorsiva sul figlio destro
	lw $ra, 0($sp)			# carico il registro da stack
	lw $t5, 4($sp)			# carico indiceNodo da stack
	addi $sp, $sp, 8			# disalloco lo spazio su stack
	
fine_eliminazioni:
	jr $ra				# termino la funzione
	

###############################################################################################################################

##########################################        SOMMA_ALTERNA   	######################################################

somma_alterna:
	move $indirizzo1, $a0		# indirizzo = argomento ricevuto
	move $indiceNodo, $a1		# indiceNodo = secondo argomento ricevuto
	add $indirizzo1, $indirizzo1, $indiceNodo	# indirizzo = indirizzo + indiceNodo ricevuto
	move $coeff, $a2			# coeff = 1 o -1 (a seconda della profondita'); andra' moltiplicato per il valore di un nodo prima di sommarlo
	
	# s0 contiene la variabile somma (variabile globale)
	lw $s1, lunghezza_albero
	
	lb $t0, 1($indirizzo1)		# t0 = indirizzo+indiceNodo+1, ovvero il valore del nodo di indice indiceNodo
	beq $t0, '.', non_sommare	# se il byte caricato e' un punto, significa che quel nodo e' vuoto -> non ha un valore da sommare
	
	subi $t0, $t0, 48		# trasformo in intero il byte ricevuto in ASCII
	mul $t1, $t0, $coeff		# t1 = t0*coefficiente
	add $s0, $s0, $t1		# somma += t1
	
non_sommare:
somma_sasx:	# somma sottoalbero sinistro
	sll $t5, $a1, 1			# t5 = indiceNodo*2
	bge $t5, $s1, somma_sadx		# se t5 >= len(stringa) -> salta somma del sottoalberoSX
	# chiamata ricorsiva sul figlio sinistro
	subi $sp, $sp, 12		# alloco lo spazio su stack per tre word
	sw $ra, 0($sp)			# salvo il registro su stack
	sw $t5, 4($sp)			# salvo l'indiceNodo su stack
	sw $coeff, 8($sp)		# salvo il coefficiente su stack
	move $a1, $t5			# a1 = indiceNodo*2
	mul $a2, $coeff, -1		# argomentoFunz = coeff * (-1) -> si fa l'opposto ad ogni chiamata
	jal somma_alterna		# chiamata ricorsiva sul figlio sinistro
	lw $ra, 0($sp)			# carico il registro da stack
	lw $t5, 4($sp)			# carico l'indiceNodo da stack
	lw $coeff, 8($sp)		# carico il coefficiente da stack
	addi $sp, $sp, 12		# disalloco lo spazio su stack
	
somma_sadx:
	addi $t5, $t5, 2			# t5 = indiceNodo*2 + 2
	bge $t5, $s1, fine_somme		# se t5 >= len(stringa) -> salta somma del sottoalberoDX e concludi funzione
	# chiamata ricorsiva sul figlio destro
	subi $sp, $sp, 12		# alloco lo spazio su stack per tre word
	sw $ra, 0($sp)			# salvo il registro su stack
	sw $t5, 4($sp)			# salvo indiceNodo su stack
	sw $coeff, 8($sp)		# salvo il coefficiente su stack
	move $a1, $t5			# a1 = indiceNodo*2 + 2
	mul $a2, $coeff, -1		# argomentoFunz = coeff * (-1) -> si fa l'oposto ad ogni chiamata 
	jal somma_alterna		# chiamata ricorsiva sul figlio destro
	lw $ra, 0($sp)			# carico il registro da stack
	lw $t5, 4($sp)			# carico indiceNodo da stack
	lw $coeff, 8($sp)		# carico il coefficiente da stack
	addi $sp, $sp, 12		# disalloco lo spazio su stack
	
fine_somme:
	jr $ra				# termino la funzione
	

########################################################################################################################

##########################################     INSERISCI_NODO 	######################################################

inserisci_nodo:
	# a0 = indirizzo albero					a1 = indiceNodo a cui aggiungere
	# a2 = indirizzo vettore con nodo da aggiunere		a3 = 0/1 (uno dei due sottoforma di byte di char)
	
	beq $a3, '0', ins_a_destra	# se il bit booleano e' 0, calcolo l'indice del figlio destro
					# altrimenti, calcolo quello del figlio sinistro
	sll $t5, $a1, 1			# t5 = indiceNodo*2 (indiceFiglioSinistro)
	j inserimento			# salto il calcolo dell'indice destro
ins_a_destra:
	sll $t5, $a1, 1			# t5 = indiceNodo*2
	addi $t5, $t5, 2			# t5 = indiceNodo*2 + 2 (indiceFiglioDestro)

inserimento:
	add $indirizzo1, $a0, $t5	# indirizzo = indirizzoalbero + indice del figlio appena calcolato
	
	lh $t6, nodo_da_aggiungere	# t6 = etichetta&valore nodo da aggiungere
	sh $t6, ($indirizzo1)		# sovrascrivo t6 nella posizione data da indirizzo1
	
	jr $ra				# termino la funzione


########################################################################################################################

##########################################      CERCA_MAX_PROF_NODO 	######################################################

cerca_max_prof_nodo:
	# in $a0 c'e' l'indirizzo (non viene modificato)
	# in $a1 c'e' il valore da confrontare (non viene modificato)
	move $indirizzo2, $a0
	add $t5, $a2, 1			# t5 = profondita' + 1
	move $indiceNodo, $a3		# ricavo l'indiceNodo
	lw $t6, lunghezza_albero 	# t6 = lunghezza albero
	
	sll $indiceNodo, $indiceNodo, 1	# indiceFiglioSx = indiceNodo *2
	bge $indiceNodo, $t6, noFigliSx	# se indice >= lunghezza -> il nodo non ha figlio sinistro
	
	# altrimenti, richiamo la funzione sui figli sx
	subi $sp, $sp, 12		# alloco spazio per 3 word su stack
	sw $a2, 0($sp)			# salvo profondita' su stack
	sw $a3, 4($sp)			# salvo indiceNodo su stack
	sw $ra, 8($sp)			# salvo ra su stack
	
	move $a2, $t5			# nuova profondita' come terzo argomento
	move $a3, $indiceNodo		# nuovo indiceNodo (indiceFiglioSx) come quarto argomento)
	jal cerca_max_prof_nodo		# si esegue la chiamata ricorsiva su figlioSX
	
	lw $ra, 8($sp)			# recupero ra da stack
	lw $a3, 4($sp)			# recupero indiceNodo da stack
	lw $a2, 0($sp)			# recupero profondita' da stack
	addi $sp, $sp, 12		# disalloco spazio su stack

noFigliSx:
	# controllo se il nodo ha valore = a quello richiesto in input
	add $indirizzo1, $a0, $a3	# indirizzo = indirizzoalbero + indiceNodo
	lb $t2, ($indirizzo1)		# t2 = etichetta del nodo
	lb $t3, 1($indirizzo1)		# t3 = valore del nodo
	
	bne $t3, $a1, nonTrovato		# se t3 e' uguale al valore ricavato dall'input, salto i controlli
	# se il nodo contiene il valore uguale a $valore, guardo la profondita' (in $a2) e la confronto con $profMax-1.
	addi $t7, $profMax, -1		# t7 = profondita'Max - 1
	blt $a2, $t7, nonTrovato	# if a2<profondita'Max -> non ho trovato un nuovo nodo
	# altrimenti, sostituisco profondita' con $profMax e etichetta con $etichettaMax
	move $profMax, $a2
	addi $profMax, $profMax, 1
	move $etichettaMax, $t2
	
nonTrovato:
	# a questo punto, in ogni caso, devo richiamare la funzione sul figlio destro (se ha un figlio destro)
	sll $a3, $a3, 1			
	addi $a3, $a3, 2			# quarto argomento: indiceFiglioDx
	addi $a2, $a2, 1			# di nuovo incremento la profondita' e la metto come terzo argomento
	
	bge $a3, $t6, noFigliDx		# se indiceFiglioDx > lunghezza_albero -> il nodo non ha figli destri
	subi $sp, $sp, 4			# alloco spazio per una word su stack
	sw $ra, ($sp)			# salvo ra su stack
	
	jal cerca_max_prof_nodo		# si esegue la chiamata ricorsiva su figlioDX
	
	lw $ra, ($sp)			# ripristino ra da stack
	addi $sp, $sp, 4			# disalloco lo spazio su stack
	
noFigliDx:
	jr $ra

fine_programma:
	# termino il programma
	li $v0, 10
	syscall
