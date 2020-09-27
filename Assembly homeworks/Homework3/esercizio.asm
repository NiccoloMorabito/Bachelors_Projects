# HOMEWORK 3 - calcolo di espressioni artimetiche

.data
.align 2
vettore: 	.word 0:1000
N:		.word 0

.eqv $N, $s0
.eqv $maxVettore, $s1
.eqv $satana, $s2
.eqv $boolean, $s3

.eqv $indice, $t0
.eqv $inFiglioSx, $t1					# indice del figlio sinistro
.eqv $inFiglioDx, $t2					# indice del figlio destro
.eqv $numero, $t3					# il numero che prendo dal vettore di volta in volta
.eqv $inNipoteDiSx, $t4
.eqv $inNipoteDiDx, $t5
.eqv $primoOp, $t6
.eqv $secondoOp, $t7
.eqv $risultato, $t8

.text
.globl main

main:
	li $satana, -666					# carico il valore di default -666 nel registro $s2 
	# Si legge il valore N
	li $v0, 5
	syscall			
	sw $v0, N
	move $N, $v0
	
	# Si memorizza N in vettore[0]
	sw $N, vettore($zero)
	sll $maxVettore, $N, 2				# maxVettore = N*data-size 
	addi $maxVettore, $maxVettore, 4			# maxVettore = (N+1)*data-size (perche' la lunghezza del vettore e' N+1)
	
	# Si leggono gli N valori salvandone ciascuno nel vettore
	li $indice, 4				# si inizializza a 1 l'indice
	
salvaSuVettore:
	beq $indice, $maxVettore, fine_salvaSuVettore	# while indice<maxVettore:
	li $v0, 5
	syscall					# read integer
	sw $v0, vettore($indice)			# vettore[indice] = $a0
	addi $indice, $indice, 4			# si incrementa l'indice
	
	j salvaSuVettore
	
fine_salvaSuVettore:
	li $boolean, 1				# pongo il booleano = 1 (True)
	move $a2, $maxVettore			# secondo argomento = max del vettore (calcolato prima)

#WHILE BOOLEAN:
while_boolean:

# 	STAMPA ESPRESSIONE
	# lascio $a0 libero per le stampe
	li $a1, 4				# chiamo la funzione con indice iniziale = 1
	# in $a2 c'e' gia' maxVettore
	jal generaStringa

# 	STAMPA A CAPO
	li $a0, '\n'
	li $v0, 11
	syscall
	
# 	SEMPLIFICA ESPRESSIONE
	# lascio $a0 libero per le stampe
	li $a1, 4				# chiamo la funzione con indice iniziale = 1
	# in $a2 c'e' gia' maxVettore
	jal semplificaEspressione
	
	beq $boolean, $zero, fineProgramma	# condizionale del do_while
	j while_boolean
	
fineProgramma:
	li $v0, 10				# fine programma
	syscall	


# FUNZIONE RICORSIVA 1: genera la stringa con l'espressione

generaStringa:
	move $indice, $a1			# indice_nodo = secondo argomento funzione
	sll $inFiglioSx, $a1, 1			# indice_figlio_sx = indice_nodo*2
	addi $inFiglioDx, $inFiglioSx, 4		# indice_figlio_dx = indice_figlio_sx + 1
	
	# CONTROLLI PER CAPIRE LA SITUAZIONE DEL NODO CHE SI STA STUDIANDO
	blt $inFiglioSx, $a2, else_not_sxFoglia	# salta se figlioSx non e' foglia

if_sxFoglia:	
	# il figlio sx e' foglia
	# devo quindi stampare (x) dove x=numero in posizione $a0. Ovvero, in sequenza:
	
	# printo parentesi aperta
	li $a0, '('
	li $v0, 11
	syscall
	
	# printo il numero
	lw $numero, vettore($indice)
	move $a0, $numero			# a0 = vettore[indice]
	li $v0, 1
	syscall
	
	# printo parentesi chiusa
	li $a0, ')'
	li $v0, 11
	syscall
	jr $ra					# fine della chiamata
	
else_not_sxFoglia:
	lw $t9, vettore($inFiglioSx)		# t9 = figlio_sx
	beq $t9, $satana, if_sxFoglia 		# se il figlio sx e' -666, e' comunque una foglia e salto all'if precedente
	
	# e' un nodo intermedio
	
	# printo parentesi aperta
	li $a0, '('
	li $v0, 11
	syscall
	
	# CHIAMATA RICORSIVA SU FIGLIO SX
	subi $sp, $sp, 8				# alloco spazio per 2 word
	sw $ra, 0($sp)				# salvo $ra su stack
	sw $a1, 4($sp)				# salvo $a1 su stack
		# non c'e' bisogno di salvare $a2 in quanto non viene modificato
	
	sll $inFiglioSx, $a1, 1			# indice_figlio_sx = indice_nodo*2 
	
	move $a1, $inFiglioSx			# preparo gli argomenti: indice = inFiglioSx
	jal generaStringa			# richiamo la funzione
	
	lw $a1, 4($sp)				# ripristino $a1 (indice)
	lw $ra, 0($sp)				# ripristino $ra
	addi $sp, $sp, 8				# disalloco spazio per 2 word 
	
	
	# CONTROLLO OPERATORE
	lw $numero, vettore($a1)
	
	beq $numero, -1, case1
   	beq $numero, -2, case2
   	beq $numero, -3, case3
   	beq $numero, -4, case4
   	j exit
   
case1:
	# moltiplicazione
	li $a0, '*'
	j exit
case2:
	# addizione: 
	li $a0, '+'
	j exit
case3:
	#sottrazione
	li $a0, '-'
	j exit
case4:
	# potenza
	li $a0, '^'
	j exit

exit:
	li $v0, 11				# print il character caricato nei casi
	syscall
	
	# CHIAMATA RICORSIVA SU FIGLIO DX
	subi $sp, $sp, 8				# alloco spazio per 2 word
	sw $a1, 0($sp)				# salvo $a1 su stack
	sw $ra, 4($sp)				# salvo $ra su stack
	
	sll $inFiglioDx, $a1, 1			# indice_figlio_dx = indice_nodo*2 
	addi $inFiglioDx, $inFiglioDx, 4		# indice_figlio_dx = indice_figlio_dx + 1
	move $a1, $inFiglioDx			# preparo gli argomenti: indice = inFiglioDx
	jal generaStringa
	
	lw $ra, 4($sp)				# recupero $ra da stack
	lw $a1, 0($sp)				# recupero $a1 da stack
	addi $sp, $sp, 8				# disalloco spazio per 2 word
	
	# printo parentesi chiusa
	li $a0, ')'
	li $v0, 11
	syscall
	
	jr $ra					# return da funzione

#--------------------------------------------------------------------------------------------------------------------

# FUNZIONE RICORSIVA 2: effettua un passaggio di semplificazione dell'espressione

semplificaEspressione:
	move $indice, $a1			# indice_nodo = secondo argomento funzione
	move $maxVettore, $a2			# maxVettore = terzo argomento funzione
	sll $inFiglioSx, $indice, 1		# indice_figlio_sx = indice_nodo*2
	addi $inFiglioDx, $inFiglioSx, 4		# indice_figlio_dx = indice_figlio_sx + 1
	
	sll $inNipoteDiSx, $inFiglioSx, 1	# indice_nipote_del_figlioSx = 2*indice_figlioSx
	sll $inNipoteDiDx, $inFiglioDx, 1	# indice_nipote_del_figlioDx = 2*indice_figlioDx
	
	# SI CONTROLLA SE IN FIGLIOSX C'E' UNA FOGLIA
	blt $inNipoteDiSx, $maxVettore, else	# if inNipoteDiSx < maxVettore - > figlioSx non e' una foglia
	
sxIsFoglia:
	# in inFiglioSx c'e' una foglia; bisogna verificare che anche in inFiglioDx c'e' una foglia per effettuare il calcolo
	# SI CONTROLLA SE IN FIGLIODX C'E' UNA FOGLIA
	blt $inNipoteDiDx, $maxVettore, elseInterno	# if inNipoteDiDx < maxVettore - > figlioDx non e' una foglia

dxIsFoglia:
	# i due figli sono entrambi foglie
	# SI CALCOLA IL RISULTATO DEI DUE FIGLI (con operatore = nodo che si sta studiando)
	lw $primoOp, vettore($inFiglioSx)	# primo operatore e' figlioSx
	lw $secondoOp, vettore($inFiglioDx)	# secondo operatore e' figlioDx
	
	# SI VEDE QUAL E' L'OPERATORE in base al nuero presente nel nodo che si sta studiando
	lw $numero, vettore($indice)


	beq $numero, -1, prodotto
   	beq $numero, -2, somma
   	beq $numero, -3, sottrazione
   	beq $numero, -4, potenza
   	# altrimenti non e' un operatore, ovvero la funzione e il ciclo collegato devono terminare
	move $boolean, $zero			# booleano = 0 (False) poiche' il nodo non ha un operatore, la semplificazione e' terminata
	jr $ra					# termino la funzione
   
prodotto:
	mul $risultato, $primoOp, $secondoOp
	j fineControlloOperatore
somma:
	add $risultato, $primoOp, $secondoOp
	j fineControlloOperatore
sottrazione:
	sub $risultato, $primoOp, $secondoOp
	j fineControlloOperatore
potenza:
	li $risultato, 1				# pongo risultato = 1
	abs $secondoOp, $secondoOp		# rendo il secondoOp (l'esponente) positivo se e' negativo
	
	whileEsponente:
		ble $secondoOp, $zero, fineControlloOperatore	# while esponente >0
		mul $risultato, $risultato, $primoOp		# risultato *= base
		subi $secondoOp, $secondoOp, 1			# decremento l'esponente
		j whileEsponente

fineControlloOperatore:
	sw $risultato, vettore($indice)		# salvo il risultato nel nodo che stavo studiando
	sw $satana, vettore($inFiglioSx)		# metto -666 al posto di figlioSx
	sw $satana, vettore($inFiglioDx)		# metto -666 al posto di figlioDx
	
	jr $ra					# termino la funzione

elseInterno:
	lw $numero, vettore($inNipoteDiDx)	# numero = vettore[nipoteDiDx]
	bne $numero, $satana, dxIsFoglia		# anche se numero==-666 - > figlioDx e' una foglia, quindi salto a dxIsFoglia 
	
	
	# figlioSx e' una foglia, ma figlioDx no
	# CHIAMATA RICORSIVA SU FIGLIODX	
	subi $sp, $sp, 8				# alloco spazio per 2 word su stack
	sw $ra, 0($sp)				# salvo $ra su stack
	sw $a1, 4($sp)				# salvo $a1 su stack
	
	move $a1, $inFiglioDx			# secondo argomento = inFiglioDx
	jal semplificaEspressione
	
	lw $a1, 4($sp)				# recupero $a1 da stack
	lw $ra, 0($sp)				# recupero $ra da stack
	addi $sp, $sp, 8				# disalloco spazio per 2 word su stack
	
	jr $ra					# termino la funzione
	
else:
	# secondo controllo (or dell'if iniziale) per vedere se figlioSx è una foglia
	lw $numero, vettore($inNipoteDiSx)	# numero = vettore[nipoteDiSx]
	beq $numero, $satana, sxIsFoglia		# anche se numero==-666 - > figlioSx e' una foglia, quindi salto a sxIsFoglia


	# almeno figlioSx non e' una foglia; bisogna verificare se anche figlioDx non è foglia 	
	# RICHIAMO LA FUNZIONE SU FIGLIODX se e solo se figlioDx non e' una foglia
	bgt $inNipoteDiDx, $maxVettore, elseFinale	# se non rispetta la prima condizione, salta il secondo controllo
	
	lw $numero, vettore($inNipoteDiDx)
	beq $numero, $satana, elseFinale		# se rispetta anche la seconda condizione, rieseguo la chiamata ricorsiva semplificaEspressione(figlioDx)
						# altrimenti salto
	
	# CHIAMATA RICORSIVA SU FIGLIODX
	subi $sp, $sp, 8				# alloco spazio per 2 word su stack
	sw $ra, 0($sp)				# salvo $ra su stack
	sw $a1, 4($sp)				# salvo $a1 su stack
	
	move $a1, $inFiglioDx			# secondo argomento = inFiglioDx
	jal semplificaEspressione
	
	lw $a1, 4($sp)				# recupero $a1 da stack
	lw $ra, 0($sp)				# recupero $ra da stack
	addi $sp, $sp, 8				# disalloco spazio per 2 word su stack
	
	##### RIPRISTINO I VALORI #####
	move $indice, $a1			# indice_nodo = secondo argomento funzione
	sll $inFiglioSx, $a1, 1			# indice_figlio_sx = indice_nodo*2
	addi $inFiglioDx, $inFiglioSx, 4		# indice_figlio_dx = indice_figlio_sx + 1
	
	sll $inNipoteDiSx, $inFiglioSx, 1	# indice_nipote_del_figlioSx = 2*indice_figlioSx
	sll $inNipoteDiDx, $inFiglioDx, 1	# indice_nipote_del_figlioDx = 2*indice_figlioDx
	###############################

	# NON TERMINO LA FUNZIONE (deve eseguire anche elseFinale, ovvero la chiamata sul figlioSx
	
elseFinale:
	# Solo figlioSx è una foglia
	# CHIAMATA RICORSIVA SU FIGLIOSX
	subi $sp, $sp, 8				# alloco spazio per 2 word su stack
	sw $ra, 0($sp)				# salvo $ra su stack
	sw $a1, 4($sp)				# salvo $a1 su stack
	
	move $a1, $inFiglioSx			# secondo argomento della funzione = inFiglioSx
	jal semplificaEspressione
	
	lw $a1, 4($sp)				# recupero $a1 da stack
	lw $ra, 0($sp)				# recupero $ra da stack
	addi $sp, $sp, 8				# disalloco spazio per 2 word su stack
	
	jr $ra					# termino la funzione
	
	
