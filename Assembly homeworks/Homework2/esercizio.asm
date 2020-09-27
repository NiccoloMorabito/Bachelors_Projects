#HOMEWORK 2
.data
griglia: 	.asciiz	"|        |\n|        |\n|        |\n|   BN   |\n|   NB   |\n|        |\n|        |\n|        |\n"
mossaErrata:	.asciiz "MOSSA ERRATA\n"
vinceBianco:	.asciiz "STA VINCENDO IL BIANCO"
vinceNero:	.asciiz "STA VINCENDO IL NERO"
patta: 		.asciiz "PATTA"

input:		.byte
.align 2
spazio:		.word	0
caselleIntorno:	.word	-12, -11, -10, -1, 1, 10, 11, 12

.eqv $stop, $s0
.eqv $x, $t1
.eqv $y, $t2
.eqv $indice, $s1
.eqv $turnoB, $s2
.eqv $turnoN, $s3
.eqv $turno, $t3			
.eqv $pedina, $t4
.eqv $valida, $t5
.eqv $numero, $s4
.eqv $indiceTemp, $s5
.eqv $newIndice, $s6
.eqv $contatore, $t8
.eqv $casella, $t9

.text
main:
	li $stop, 'S'			# per confrontarlo con il primo char dell'input
	li $turnoB, 'B'			# per il turno di Bianco
	li $turnoN, 'N'			# per il turno di Nero
	li $turno, 'N'			# turno inizialmente e' di Nero
	jal stampaGriglia
	
#Leggi input
whileInput:
	li $v0, 8			# read string
	la $a0, input			# carica in input
	li $a1, 5			# massimo numero di characters = 4
	syscall
	
	lb $t0, input
	
	beq $stop, $t0, fine_whileInput	# se il primo char ricevuto e' "S", l'utente ha scritto "STOP"
	# altrimenti e' una mossa e devo eseguire le varie cose (da 1 a 6):
	
	# 1) si vede di chi e' il turno: 0 -> nero, 1-> bianco e si inserisce in $pedina la lettera giusta da mettere
	beq $turno, $turnoN, turnoNero			# if il turno e' di nero -> salta a turnoNero
	move $pedina, $turnoB				# else -> $pedina = 'B'
	move $turno, $turnoN				# 	-> il turno diventa di Nero
	j continua
turnoNero:
	move $pedina, $turnoN				# $pedina = 'N'
	move $turno, $turnoB				# -> il turno diventa di Bianco
continua:
	# 2) si calcola l'indice corretto in cui inserire il valore di $pedina
	# 2a) ricavo x
	lb $x, input			# x = input[0]
	subi $x, $x, 96			# da ASCII a cifra decimale
	
	# 2b) ricavo y
	addi $t5, $zero, 1	
	lb $y, input($t5)		# y = input[1]
	subi $y, $y, 48			# da ASCII a cifra decimale
	
	# 2c) calcolo indice
	subi $y, $y, 1			# y = y-1
	li $t0, 11
	mul $indice, $y, $t0		# indice = (y-1)*11
	add $indice, $indice, $x		# indice = (y-1)*11 + x
	
	# 3) si calcola ricorsivamente se la mossa e' valida o quali pedine vengono mangiate
	li $valida, 0			# si inizializza a False una variabile temporanea per capire se la mossa e' valida
	
	# 3a) si esegue il ciclo su tutte le caselle intorno a quella richiesta
	li $t6, 0			# indiceListaNumeri = 0
	li $t7, 32			# max = 8 *4byte = 32
cicloIntorno:
	beq $t6, $t7, fine_mossa		# if indiceListaNumeri=max : esci dal ciclo e vai a fine_mossa
	lw $numero, caselleIntorno($t6)	# numero = caselleIntorno[indiceListaNumeri]
	move $a0, $indice		# argomenti funzione ricorsiva
	move $a1, $numero		# argomenti funzione ricorsiva
	
	# 3b) per ogni casella adiacente, si esegue la funzione ricorsiva per capire quali pedine puo' mangiare
	li $contatore, 0			# inizializzo contatore a 0 (quello che segnalera' quante pedine dell'avversario incontrero' di seguito)
	jal pedine_ricorsiva
	
	addi $t6, $t6, 4			# incremento indiceListaNumeri di una word
	j cicloIntorno			# ripeto il ciclo

fine_mossa:
	# 4) se la mossa e' valida:
	beq $valida, $zero, fine_mossaNonValida
		# 4a) inserisco $pedina nella pos. richiesta in input
		sb $pedina, griglia($indice)
		# 4b) $turno rimane uguale (l'ho gia' modificato prima)
		# 4a) stampa la griglia
		jal stampaGriglia
	
	j whileInput			# in entrambi i casi, ovvero alla fine di una mossa, si leggono le nuove coordinate
fine_mossaNonValida:
	# 5) se la mossa non e' valida:
		# 5a) stampo messaggio errore
		la $a0, mossaErrata
		li $v0, 4
		syscall
		# 5b) ripristino $turno, dopo la mossa non valida, al valore che aveva all'inizio di questa nuova mossa
		bne $turno, $turnoB, nomeACaso
			move $turno, $turnoN
			j whileInput
		nomeACaso:
			move $turno, $turnoB
	
	j whileInput			# in entrambi i casi, ovvero alla fine di una mossa, si leggono le nuove coordinate
	
fine_whileInput:
	# poiche' l'utente ha inserito la parola "STOP", bisogna stampare uno dei tre messaggi in base a chi sta vincendo
	
	# conto il numero di pedine bianche e il numero di pedine nere   ovvero	 numB, numN
	li $indice, 0			# inizializzo un indice a 0
	li $x, 0				# in x metto le pedine nere
	li $y, 0				# in y metto le pedine bianche
while_contaPedine:
	lb $casella, griglia($indice) 	# metto in casella il char in posizione $indice
	beq $casella, $zero, stampe	# se il char e' lo \0 terminativo, concludi il ciclo

isNera:	beq $casella, $turnoB, isBianca	# if casella=='B' salta a isBianca
	bne $casella, $turnoN, inOgniCaso	# if casella!='N' incrementa e jumpa solo
	addi $x, $x, 1			# incremento di 1 il numero di pedine nere
	j inOgniCaso
isBianca:
	addi $y, $y, 1			# incremento di 1 il numero di pedine bianche
	
inOgniCaso:
	addi $indice, $indice, 1		# incremento l'indice
	j while_contaPedine
	
stampe:
	li $v0, 4			# in qualunque caso, la syscall e' la print string
	
	beq $x, $y, stampaPatta		# se numBianche==numNere -> stampa patta
	bgt $x, $y, stampaVinceNero	# se numB > numN -> stampa vinceBianco
	la $a0, vinceBianco		# else stampo vinceBianco
	syscall
	j fine
	
stampaVinceNero:
	la $a0, vinceNero		# stampo vinceNero
	syscall
	j fine
	
stampaPatta:
	la $a0, patta			# stampo patta
	syscall
	j fine
	
	
#STAMPA GRIGLIA	
stampaGriglia:
	la $a0, griglia
	li $v0, 4
	syscall
	
	jr $ra

# FUNZIONE RICORSIVA CHE CONTROLLA LA SITUAZIONE DELLA MOSSA
pedine_ricorsiva:
	move $indiceTemp, $a0		# indiceTemp = indice ricevuto come argomento
	move $numero, $a1		# numero = numero tale che indiceTemp+numero=casellaIntorno
	add $newIndice, $indiceTemp, $numero	# newIndice = indiceTemp+numero
	
	lb $casella, griglia($newIndice)	# casella = griglia[newIndice]

if:	
	bne $casella, $turno, elif	# se casella != pedina dell'avversario -> salta a elif
	# casella == pedina dell'avversario, quindi:
	
	addi $contatore, $contatore, 1	# incremento il contatore (che segnala quante pedine dell'avversario sto incontrando)
	subi $sp, $sp, 8			# alloco 2 word su stack per salvare il contenuto di $ra e $a0
	sw $ra, 0($sp)			# salvo $ra
	sw $a0, 4($sp)			# salvo $indiceTemp
	move $a0, $newIndice		# modifico l'argomento della funzione per la chiamata ricorsiva
	
	jal pedine_ricorsiva		# CHIAMATA RICORSIVA
	
	lw $ra, 0($sp)			# recupero $ra
	lw $a0, 4($sp)			# recupero $indiceTemp
	addi $sp, $sp, 8			# disalloco 2 word su stack
	
elif:	# elif casella==pedina del giocatore
	bne $casella, $pedina, else	# if casella!= pedina -> salta a else
	beq $contatore, $zero, else	# salta a else anche se contatore e' 0 (perche' significa che non c'e' nessuna pedina da mangiare tra $casella e $Pedina)
	# casella == pedina del giocatore, quindi:
	li $valida, 1			# si pone a True la variabile booleana che verifica se la mossa e' valida
	
	sub $newIndice, $newIndice, $numero	# newIndice -= numero (si torna alla casella precedente, quella dell'avversario)
while_mangiaPedine:	
	beq $contatore, 0, else		# salta solo quando contatore e' diventato 0 (e returna per cambiare direzione)
	sb $pedina, griglia($newIndice)	# griglia(newIndice) = pedina giocatore
	sub $newIndice, $newIndice, $numero	# newIndice -= numero (si torna alla casella ancora precedente, ancora dell'avversario)
	subi $contatore, $contatore, 1	# decremento il contatore, quando arriva a 0 esco dal ciclo perche' ha mangiato tutte le pedine comprese
	j while_mangiaPedine

else:	# la casella e' vuota o fuori
	jr $ra				# si returna alla funzione principale affinche' cambi direzione
	
	

fine:
	li $v0, 10			# fine programma
	syscall
	
