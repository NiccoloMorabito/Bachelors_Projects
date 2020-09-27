##		HOMEWORK 1 - sequenza a finestra scorrevole 		##

.globl main

.data
.align 2
	#k
	k: 		.word 0
	#vettore di k elementi
	vettore: 	.word 0:21
	#variabili da stampare alla fine
	minS: 		.word 0 		# $s0
	maxS: 		.word 0			# $s1
	minY: 		.word 0			# $s2
	maxY: 		.word 0			# $s3

.text 

main:
# 1) LEGGO IL NUMERO K E LO METTO NEL REGISTRO $S0
li 	$v0, 5
syscall
	
sw 	$v0, k 					# salvo la variabile k
move 	$s4, $v0				# e copio il contenuto nel registro $s4
add	$s6, $s4, 1				# salvo la variabile k+1 (servira' dopo)
	
li 	$t0, 0					# inizializzo l'indice del vettore
	
leggo_k_elementi: #in un vettore di dimensione 21 (poiche' 0<k<21)
beq 	$t0, $s4, calcola_somma			# while indice < k
	
	li 	$v0, 5 				# leggo un nuovo numero
	syscall
	
	beq $v0, $zero, stampe_finali		# se il numero appena letto e' 0, eseguo le stampi finali e chiudo
	
	# CONTROLLI PER minS e maxS:
	# 1) la prima volta vengono posti uguali all'input appena ricevuto
	bne $s0, $zero, controllo_minS 		# if minS==0:
		move 	$s0, $v0		# 	minS = valoreInserito
		move 	$s1, $v0		# 	maxS = valoreInserito
	
	# 2) si vede se l'input appena ricevuto e' minore di minS
	controllo_minS:
	bgt 	$v0, $s0, controllo_maxS	# if valoreInserito < minS:
		move 	$s0, $v0		#	minS = valoreInserito
	
	# 3) si vede se l'input appena ricevuto e' maggiore di maxS
	controllo_maxS:
	blt 	$v0, $s1, salva_elemento	# if valoreInserito > maxS
		move 	$s1, $v0		# 	maxS = valoreInserito
	
	salva_elemento:
	sll 	$t1, $t0, 2			# offset: $t1 = indice *4
	sw 	$v0, vettore($t1)		# vettore[$t1] = valoreInserito
	
	addi 	$t0, $t0, 1			# indice += 1
	
	j 	leggo_k_elementi
		
	
calcola_somma:
li 	$s5, 0					# pongo la variabile somma uguale a 0 prima di iniziare
li 	$t2, 0					# pongo l'indice uguale a 0

ciclo_somma:
beq 	$t2, $s4, controllo_Y			# while indice < k
	sll 	$t3, $t2, 2			# offset: $t3 = indice*4
	lw 	$t4, vettore($t3)		# $t4 = vettore[$t3]
	
	add 	$s5, $s5, $t4			# somma += el -> $s5 += $t4
	
	addi 	$t2, $t2, 1			# indice += 1
	j 	ciclo_somma

# CONTROLLI PER minY e maxY:
controllo_Y:
# 1) la prima volta vengono posti uguali alla somma appena calcolata tramite un booleano realizzato con il registro $t8
bnez 	$t8, controllo_minY			# if $t8==0:
	move	$s2, $s5			#	minY = somma
	move 	$s3, $s5			#	maxY = somma
	li 	$t8, 1				#	$t8 = 1 (per far saltare queste tre righe dalla seconda esecuzione in poi)
	
# 2) si vede se la somma appena calcolata e' minore di minY
controllo_minY:
bgt 	$s5, $s2, controllo_maxY		# if somma < minY:
	move 	$s2, $s5			#	minY = somma

# 3) si vede se la somma appena calcolata e' maggiore di maxY
controllo_maxY:
blt 	$s5, $s3, stampa_somma			# if somma > maxY:
	move	$s3, $s5			# 	maxY = somma

stampa_somma:
move 	$a0, $s5				# $a0 (integer to print) = somma
li 	$v0, 1					# print integer
syscall

jal 	stampa_a_capo				# esegue funzione che stampa a-capo

li 	$t5, 1					# inizializzo l'indice per lo shifting a 1
shift_vettore:
beq 	$t5, $s6, ripeti_tutto			# while indice < k+1 #deve fare anche lo shift di uno 0 nella posizione finale (?)
	sll 	$t6, $t5, 2			# $t6 = indice*4
	lw 	$t7, vettore($t6)		# $t7 = vettore[indice]
	
	subi 	$t6, $t6, 4			# $t6 = indice*4 - 4
	sw 	$t7, vettore($t6)		# vettore[indice-1] = $t7
	
	addi 	$t5, $t5, 1			# indice += 1
	
	j	shift_vettore


ripeti_tutto:
subi 	$t5, $t5, 2				# indice = k-2
move 	$t0, $t5				# prima di ripetere tutto, pongo l'indice del ciclo leggo_k_elementi uguale a k-1
j leggo_k_elementi


stampe_finali:
move 	$a0, $s0				# stampo minS
li 	$v0, 1
syscall

jal stampa_a_capo				# stampo un a-capo

move 	$a0, $s1				# stampo maxS
li 	$v0, 1
syscall

jal stampa_a_capo				# stampo un a-capo

move 	$a0, $s2				# stampo minY
li 	$v0, 1
syscall

jal stampa_a_capo				# stampo un a-capo

move 	$a0, $s3				# stampo maxY
li 	$v0, 1
syscall

jal stampa_a_capo				# stampo un a-capo

fine:
li 	$v0, 10					# fine programma
syscall
	
stampa_a_capo:
li 	$a0, '\n'				# carico il carattere di a-capo
li 	$v0, 11					# print character
syscall
jr $ra		
