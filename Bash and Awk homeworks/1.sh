#!/bin/bash

# Dato come input un file il cui nome contiene una data, restituisce tale data
getDataFromPathFile() {
	# prendo il filename (senza path) e lo splitto sul '_' per ottenere la data
	data=$(echo $1 | rev | cut -d'/' -f1 | rev | cut -d'_' -f2)
	echo $data
}

# booleani
e_inserita=0
b_inserita=0

# VENGONO ANALIZZATI I VARI ARGOMENTI E SEGNALATI GLI ERRORI INIZIALI
errore_iniziale="Uso: $0 [opzioni] directory"
while getopts ":eb::" opt; do
	case $opt in
		e) e_inserita=1;;
		b) b_inserita=1
		   # Si salva l'argomento b per analizzarlo in seguito
			b=$OPTARG;;
		# Caso1: viene passata un'opzione non esistente
		\?) echo $errore_iniziale >&2
			exit 10;;
		# Caso2: viene passata un'opzione che necessita un argomento ma senza argomento
		:) echo $errore_iniziale >&2
			exit 10;;
	esac
done
#Caso3: vengono passate entrambe le opzioni -e e -b
if [ "$e_inserita" -eq 1 ] && [ "$b_inserita" -eq 1 ] ; then
	echo $errore_iniziale >&2
	exit 10
fi
#Caso4: non viene passato l'argomento obbligatorio
shift $((OPTIND-1))
if [ ${#1} -eq 0 ] ; then
	echo $errore_iniziale >&2
	exit 10
fi


# VIENE ANALIZZATO L'ARGOMENTO b E SEGNALATI GLI ERRORI CORRISPONDENTI
if [[ "$b_inserita" -eq 1 ]]; then
	errore_argomento_b="L'argomento $b non e' valido in quanto "
	#Caso1: non esiste -> occorre crearla
	if [[ ! -e $b ]] ; then
		mkdir $b
		chmod 700 $b
	else
		permessi_b=$(stat -c "%a" $b)
		#Caso2: esiste ma non è una directory
		if [[ ! -d $b ]]; then
			echo $errore_argomento_b "non e' una directory">&2
			exit 200
		#Caso3: è una directory ma non ha i permessi di lettura ed esecuzione per utente
		elif [ -d $b ] && [ ! $permessi_b -eq 700 ] ; then
			echo $errore_argomento_b "non ha i permessi richiesti">&2
			exit 200
		fi
	fi
fi


# VIENE ANALIZZATO L'ARGOMENTO d E SEGNALATI GLI ERRORI CORRISPONDENTI
errore_argomento_d="L'argomento $1 non e' valido in quanto "
#Caso1,2: non esiste o non è una cartella
if [[ ! -d $1 ]]; then
	echo $errore_argomento_d "non e' una directory" >&2
	exit 100
fi
#Caso3: non ha entrambi i permessi di lettura ed esecuzione per utente
permessi_d=$(stat -c "%a" $1)
if [ ! -x $1 ] || [ ! -r $1 ] ; then
	echo $errore_argomento_d "non ha i permessi richiesti" >&2
	exit 100
fi

# RICERCA DEI FILE

#Si esegue l'assegnazione per far sì che il sort lavori nella maniera tradizionale (ordinando con i native byte values)
LC_ALL=C

# Ricerco tutti i file nel sottoalbero radicato in $1 che hanno _YYYYMMDDHHMM_ nel nome e che sono file regolari o link simbolici
filesValidi=$(find $1 -type f,l -regextype posix-extended -regex '.*_[0-9][0-9][0-9][0-9](0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])([0-1][0-9]|2[0-3])[0-5][0-9]_.*(.[jJtT][pPxX][gGtT])')

# Si crea il file che andrà a contenere tutti i file di un qualche F',F''
path_file1=$(pwd)/ELENCO_FILE_Fs.txt
> $path_file1

# Si scorrono tutti i file validi in cerca di file del fruppo F' o F''
for file in $filesValidi; do
	# si preleva la data del file
	data=$(getDataFromPathFile $file)
	
	# se è un symbolic link
	if [[ -h $file ]]; then
		# si ricava la data del file originale
		originale=$(readlink -f $file)
		dataFileOriginale=$(getDataFromPathFile $originale)
		# se il file originale ha la stesa data ed è contenuto nella dir inserita come parametro
		if [[ $data = $dataFileOriginale && $file == *$1* ]]; then
			# F': TROVATO UN LINK SIMBOLICO
			echo $file >> $path_file1
		fi
		
	# se è un file regolare (file o hard link)
	elif [[ -f $file ]]; then
		# trovo tutti gli hard link di quel file ORDINATI (facendo una find con regex classica + data uguale a quella del file in corso + ricerca dei file uguali + escludendo tutti i link simbolici in modo tale che cerco in F-F')
		hardLinks=$(find $1 -regextype posix-extended -regex ".*_${data}_.*(.[jJtT][pPxX][gGtT])" -samefile $file -type f | LC_ALL=C sort)
		numHardLinks=$(wc -l <<< "$hardLinks")
		
		# se sono stati trovati almeno 2 hard link, si mettono in F'' solo quello con path maggiore (l'ultimo)
		if [[ $numHardLinks -gt 1 ]]; then
			# si prendono tutti quelli lessicograficamente maggiori (si lascia solo il primo, il minore a tutti)
			# F'': TROVATO UN HARD LINK
			for hardlink in $(tail -$((numHardLinks-1)) <<< $hardLinks); do
				echo $hardlink >> $path_file1
			done
		fi
	fi
done

# Si crea il file che andrà a contenere tutti i file di un qualche F'''
path_file2=$(pwd)/ELENCO_FILE_F3.txt
> $path_file2
# ULTIMO PUNTO: TROVARE FILE CON LO STESSO CONTENUTO
# si ricercano tutti i file rimanenti tra quelli che matchano la regex, sono file regolari (si esclude F') e tutti quelli che non sono presenti nell'ELENCO_FILE_Fs.txt (si esclude F'')
remainingFiles=$(find $1 -regextype posix-extended -regex '.*_[0-9][0-9][0-9][0-9](0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])([0-1][0-9]|2[0-3])[0-5][0-9]_.*(.[jJtT][pPxX][gGtT])' -type f | grep -vFf $path_file1)
#
# per ogni file rimanente si cerca se esistono file con lo stesso contenuto
for file in $remainingFiles; do
	# si calcola l'md5 e si isola dagli altri dati con le parentesi tonde
	md5=($(md5sum $file))
	
	dataFile=$(getDataFromPathFile $file)
	
	# si trovano tutti i file con lo stesso contenuto di $file (compreso $file stesso) eseguendo, in ordine, i seguenti controlli:
	# - regex su data di $file (si escludono quelli che non appartengono a F)
	# - solo i file regolari (si escludono quelli che appartengono a F')
	# - file con nomi diversi da quelli accumulati in ELENCO_FILE_Fs.txt (si ecludono quelli che appartengono a F'')
	# - si cercano solo quelli con md5sum uguale a quella di $file
	# - si formatta il risultato per lasciare solo il path
	# - si ordinano lessicograficamente i risultati IN MANIERA INVERSA
	sameContentFiles=$(find $1 -regextype posix-extended -regex ".*_${dataFile}_.*(.[jJtT][pPxX][gGtT])" -type f | grep -vFf $path_file1 | tr "\n" "\0" | xargs -0 md5sum | grep $md5 | cut -d' ' -f2- | tr -d " " | LC_ALL=C sort -r)
	numSameContentFiles=$(wc -l <<< $sameContentFiles)
	
	if [[ $numSameContentFiles -gt 1 ]] ; then
		# scorro i doppioni trovati a partire dal secondo (il primo, quello con path MAGGIORE, non fa parte di F''')
		for doppione in $(tail -$((numSameContentFiles-1)) <<< $sameContentFiles); do
			# F''': TROVATO UN FILE CON STESSO CONTENUTO
			echo $doppione >> $path_file2
		done
	fi
	
done

# FINALE
# Si uniscono i due file per ottenere un unico elenco di F', F'', F'''
cat $path_file2 >> $path_file1
# si ordina la lista dei file dei gruppi F', F'' (e F''') e si rimuovono i duplicati
LC_ALL=C sort -u -o $path_file1 $path_file1

# poi si salvano i file così ottenuti nel file di standard output separati da |
paste -s -d '|' $path_file1 >&1

# Per ogni file
for file in $(cat $path_file1); do
	# solo se non è stata inserita la -e
	if [[ e_inserita -eq 0 ]]; then
		# se è stata inserita la b, si spostano i file
		if [[ b_inserita -eq 1 ]] ; then
			# si creano le cartelle intermedie
			directories=$(echo $file | rev | cut -d'/' -f 2- | rev)
			directories=$(echo $directories | cut -d'/' -f 2- )
			mkdir -p "$b/$directories"
			
			mv $file "$b/$directories"
		# altrimenti si cancellano
		else
			rm $file
		fi
	fi
done

# si eliminano tutti i symlink rotti nella directory b 
for softlink in $(find $b -xtype l); do
	rm $softlink
done

# si eliminano i file di appoggio utilizzati
rm $path_file1
rm $path_file2
