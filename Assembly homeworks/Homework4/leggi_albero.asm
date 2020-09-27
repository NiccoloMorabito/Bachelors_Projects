######################################	LEGGI ALBERO	###################################################

# Leggi_albero(buffer, dim_max) che:

# 	dato l'indirizzo di una zona di memoria (buffer) di dimensione dim_max
#	legge la stringa che rappresenta un intero albero
#	torna il numero di nodi presenti nella stringa (compresi i nodi vuoti)

.globl main

.data
spazio_stringa:	.space 2002		# si crea lo spazio necessario per contenere la stringa (max 1000 nodi)
numero_nodi:	.word 0			# VEDI SE SERVE QUESTO DATO SALVATO

.eqv $indice, $t1
.eqv $contatore, $t2

.text
main:
	la $a0, spazio_stringa
	addi $a0, $a0, 2			# incremento di 2 byte l'indirizzo per la stringa (PRIMO ELEMENTO VUOTO)
	li $a1, 2002			# dim_max (spazio del buffer in byte)
	
	jal leggi_albero			# si esegue la funzione
	
	j fine_programma
	
leggi_albero:
	move $s0, $a0			# salvo indirizzo spazio_stringa
	li $contatore, 0			# azzero il contatore

	li $v0, 8			# si legge la stringa che rappresenta l'albero
	syscall

	li $indice, 2			# inizializzo l'indice di scorrimento della stringa a 2 (0+spazio vuoto)
	
ciclo:
	lb $t0, spazio_stringa($indice)	# carico byte-etichetta
	
	beq $t0, $zero, fine_funzione	# termina la funzione se il carattere appena letto è il terminativo \0
	
	addi $contatore, $contatore, 1
	
	addi $indice, $indice, 2		# incremento l'indice di 2 byte per volta (leggo solo le etichette
	
	j ciclo
	
fine_funzione:
	sw $contatore, numero_nodi	# salvo il risultato in memoria
	move $a0, $contatore		# stampo contatore
	li $v0, 1
	syscall
	
fine_programma:
	li $v0, 	10			# termino il programma
	syscall
