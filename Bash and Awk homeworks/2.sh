#!/bin/bash
# Se ci sono meno di 6 argomenti (il minimo: i primi 3 + 1comando + 2file) errore 15
if [ "$#" -lt 6 ] ; then
	echo "Usage: $0 bytes walltime sampling commands files" >&2
	exit 15
fi

# VENGONO ANALIZZATI I VARI ARGOMENTI E SEGNALATI GLI ERRORI INIZIALI
bytesNum=$1
walltime=$2
intervallo=$3

# Ricavo gli argomenti rimanenti (oltre i primi 3) che contengono sia la lista di comandi che la lista di file
args=("$@")
rimanenti=$(echo ${args[@]:3:${#}})

# Splitto su ';;;'
comandi=$(echo $rimanenti | sed "s/;;;/@/g" | cut -d '@' -f1)
files=$(echo $rimanenti | sed "s/;;;/@/g" | cut -d '@' -f2)
# scorro i comandi splittando su ';;' e li metto in un vettore
numComandi=0
IFS="';;'"
for comando in $comandi; do
	trim=$(echo -e "${comando}" | sed -e 's/^[[:space:]]*//')
	if [[ ! -z $trim ]]; then
		vettoreComandi[numComandi]=$trim
		((numComandi++))
	fi
done
IFS='\n'

# se i file non sono esattamente il doppio dei comandi appena contati, errore 30
numFiles=$(wc -w <<< $files)
if [[ numFiles -ne $((numComandi*2)) ]]; then
	echo "Usage: $0 bytes walltime sampling commands files" >&2
	exit 30
fi

i=0
# si apre il file descriptor 3
exec 3>&3
# per ogni comando passato in input
for comando in ${vettoreComandi[@]}; do
	# si verifica l'esistenza del comando prima di procedere all'esecuzione
	primaParola=$(echo $comando | cut -d ' ' -f1)
	if [[ -x $primaParola || -x $(type -P $primaParola) ]]; then
		# si ricava il file per l'output e per l'error corrispondente al comando
		file_stdout=$(echo $files | cut -d ' ' -f $(($i+2)))
		file_stderr=$(echo $files | cut -d ' ' -f $(($i+$numComandi+2)))
		
		# si lancia ciascun comando in foreground redirectando output e error
		eval $comando" > $file_stdout 2> $file_stderr &"
		
		# si scrive il PID corrispondente su file descriptor 3 con uno spazio
		echo -n $!' ' >&3
		
		# si salva il PID corrispondente nel vettore dei PID
		vettorePID[i]=$!
		
		((i++))
	fi
done
exec 3>&- # si chiude il file descriptor 3

#ogni c secondi si effettuano i controlli su dimensione immagine, elapsed time e su file
while true; do
	
	# si pone ad ogni controllo un booleano a 0 (che diventerà 1 solo se esiste almeno un processo ancora attivo)
	aRunningFileExists=0
	# PRIMI CONTROLLI: si verificano dimensione ed etime
	for pid in ${vettorePID[@]}; do
		# Se il processo esiste, si pone il booleano a true. Altrimenti, si continua all'iterazione successiva
		if [ $(ps -p $pid | wc -l | awk '{print $1}') -ne 1 ]; then
			aRunningFileExists=1
		else
			continue
		fi
		
		# se b>0, si controlla se la dimensione dell'immagine del processo supera b
		if [[ $bytesNum -gt 0 ]]; then
			# si recupera la dimensione dell'immagine del processo e del suo processo figlio
			dimensione=$(ps -o drs $pid | tail -1)
			dimFiglio=$(ps -o drs --ppid $pid | tail -1)
			dimensione=$((dimensione+dimFiglio))
			
			# si killa il processo se ha superato la memoria di b
			if [[ $dimensione -gt $bytesNum ]]; then
				kill -INT $pid
			fi
		fi
		
		# se w>0, si controlla se l'elapsed time del processo supera w
		if [[ $walltime -gt 0 ]]; then
			# si recupera l'elapsed time del processo
			time=$(ps -p $pid -o etimes= | tr -d ' ')
			
			# si killa il processo se ha superato il walltime di w
			if [[ $time -gt $(($walltime)) ]]; then
				kill -INT $pid
			fi
		fi
	done
	
	sleep $intervallo
	
	# SECONDO CONTROLLO: si verifica che esiste almeno un processo non completato
	if [[ $aRunningFileExists -eq 0 ]]; then
		echo "Tutti i processi sono terminati" >&1
		exit 1
	fi
	
	# TERZO CONTROLLO: si verifica se è stato generato il file regolare done.txt
	if [[ -f done.txt ]]; then
		echo "File done.txt trovato" >&1
		# si chiudono i processi avviati che sono ancora in esecuzione
		for pid in ${vettorePID[@]}; do
			if [ $(ps -p $pid | wc -l | awk '{print $1}') -ne 1 ]; then
				kill -INT $pid
			fi
		done
		
		exit 0
	fi
done
