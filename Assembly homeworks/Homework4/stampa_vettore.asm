######################################	STAMPA VETTORE	###################################################

# Stampa_vettore(albero) che:

#	dato un albero
#	stampa la stringa delle coppie di caratteri contenute nel vettore seguita da accapo

.data
spazio_stringa:	.space 2002		# si crea lo spazio necessario per contenere la stringa (max 1000 nodi)

.text

main:
	la $a0, spazio_stringa		# preparo l'argomento della stringa
	subi $a0, $a0, 1		
	
	jal stampa_albero		# chiamo la funzione
	
stampa_albero:
	move $s0, $a0			# salvo indirizzo spazio_stringa
	li $indice, 2			# inizializzo l'indice di scorrimento della stringa a 2 (0+spazio vuoto)
	
ciclo:
	lb $t0, spazio_stringa($indice)	# carico byte-etichetta
	
	beq $t0, $zero, fine_funzione	# termina la funzione se il carattere appena letto è il terminativo \0
	
	move $a0, $t0 			# printo il carattere in posizione $indice
	li $v0, 11
	syscall
	
	addi $indice, $indice, 1		# incremento l'indice di 2 byte per volta (leggo solo le etichette
	
	j ciclo
	
fine_funzione:
	li $a0, '\n'
	li $v0, 11
	syscall
	li $a0, '*'
	syscall
	
	
