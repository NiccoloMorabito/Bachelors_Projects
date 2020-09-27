BEGIN {
    # Si inizializzano i 3 booleani del file di configurazione
    stripComments=0
    onlyFigs=0
    alsoFigs=0

    # Si inizializzano le due variabili di buffer per il file di log
    buffer_tex = ""
    buffer_img = ""

    numFileDaModificare=2
    # booleano che segnala se è stato eseguito un exit nel body
    exit_status=0

    # Si scrivere sia su standard output che su standard error la sequenza dei file-argomento, tutti su una riga separati da spazi e preceduti dalla stringa Eseguito con argomenti.
    stringaIniziale = "Eseguito con argomenti "
    for (i = 1; i < ARGC; i++)
    {
	stringaIniziale=stringaIniziale ARGV[i] " "
	# metto in un vettore-mappa il file e il booleano false
	fileToIsPresent[ARGV[i]] = 0
	# pongo tutti i file come inclusi (nel file di log) ma controllerò successivamente
	notincluded[i] = 0

	# creo i file che userò come file di appoggio (solo per quelli dal terzo in poi)
	if ( i > 2 )
	    system ("touch " ARGV[i] ".txt")
    }
    print substr(stringaIniziale, 0, length(stringaIniziale)-1) >> "/dev/stdout"
    print substr(stringaIniziale, 0, length(stringaIniziale)-1) >> "/dev/stderr"

    # Se non sono stati inseriti almeno 2 file di input, si genera errore
    if (ARGC-1 < 2)
    {
	print "Errore: dare almeno 2 file di input" > "/dev/stderr"
	exit_status=1
	exit 0
    }

    # Si pone il separatore a = per il parsing corretto del primo file di config
    FS="="
}
{
    # PRIMO FILE: FILE DI CONFIGURAZIONE
    if ( ARGIND == 1 )
    {
	if ( $1 == "strip_comments" )
	    stripComments=$2
	else if ( $1 == "only_figs" )
	    onlyFigs=$2
	else if ( $1 == "also_figs" )
	    alsoFigs=$2
    }
    
    # SECONDO FILE: FILE DI LOG
    else if ( ARGIND == 2 )
    {
	# Se dopo aver analizzato il primo file, onlyFigs=1 e alsoFigs=0, si genera errore
	if ( onlyFigs==1 && alsoFigs==0 )
	{
	    print "Errore di configurazione: only_figs=1 e also_figs=0" > "/dev/stderr"
	    exit_status=1
	    exit 0
	}
        
	# RICERCA FILE .tex IN FILE DI LOG
	# si aggiunge la riga corrente al buffer
	buffer_tex = buffer_tex $0

	# si calcolano gli indici di prima occorrenza
	i_aperta = index(buffer_tex, "(")

	# finché esiste una parentesi aperta nel buffer
	while ( i_aperta > 0 )
	{
	    # se la parentesi è l'ultimo carattere del buffer
	    if ( i_aperta == length(buffer_tex) )
	    {
		# si rimanda la valutazione all'iterazione successiva
		break
	    }
	    # se il carattere dopo la parentesi è un punto
	    else if ( substr(buffer_tex, i_aperta+1, 1) == "." )
	    {
		# si elimina tutto ciò che precede l'aperta
		buffer_tex = substr (buffer_tex, i_aperta)
	    }
	    else
	    {
		# altrimenti si elimina ciò che precede l'aperta + l'aperta stessa
		buffer_tex = substr (buffer_tex, i_aperta+1)
		i_aperta = index(buffer_tex, "(")
		continue
	    }

	    i_tex = index (buffer_tex, ".tex")
	    i_chiusa = index(buffer_tex, ")")
		
	    # se c'è solo ".tex" e non la chiusa
	    if ( i_tex > 0 && i_chiusa == 0)
	    {
		# si controlla prima che non ci sia un'aperta prima di .tex
		i_secondaAperta = index(substr(buffer_tex, 2), "(")
		if (i_secondaAperta > 0 && i_secondaAperta < i_tex)
		{
		    buffer_tex=substr(buffer_tex, i_secondaAperta)
		    i_aperta=index(buffer_tex, "(")
		    continue
		}
		# FILE TROVATO
		length_filename = i_tex + 4 # indice di ".tex" + le sue 4 lettere
		filename=substr(buffer_tex, 2, length_filename-2) # elimino la parentesi iniziale
		# si stampa in output il filename solo se il config aveva onlyFigs a 0
		if (onlyFigs==0)
		    print filename
		fileToIsPresent[filename] = 1
		    
		# si aggiorna il buffer cancellando il filename appena ricavato
		buffer_tex = substr(buffer_tex, length_filename+1)
	    }
	    # se c'è solo la chiusa ma non ".tex"
	    else if ( i_chiusa > 0 && i_tex == 0)
	    {
		# si elimina dal buffer tutto ciò che precede la chiusa + la chiusa stessa
		buffer_tex = substr(buffer_tex, i_chiusa+1)
	    }
	    # se ci sono entrambi
	    else if ( i_tex > 0 && i_chiusa > 0 )
	    {
		# e viene prima ".tex"
		if ( i_tex < i_chiusa )
		{
		    # si controlla prima che non ci sia un'aperta prima di .tex
		    i_secondaAperta = index(substr(buffer_tex, 2), "(")
		    if (i_secondaAperta > 0 && i_secondaAperta < i_tex)
		    {
			buffer_tex=substr(buffer_tex, i_secondaAperta)
			i_aperta=index(buffer_tex, "(")
			continue
		    }
		    # FILE TROVATO
		    length_filename = i_tex + 4 # indice di ".tex" + le sue 4 lettere
		    filename=substr(buffer_tex, 2, length_filename-2) # elimino la parentesi iniziale
		    # si stampa in output il filename solo se il config aveva onlyFigs a 0
		    if (onlyFigs==0)
			print filename
		    fileToIsPresent[filename] = 1

		    # si aggiorna il buffer cancellando il filename appena ricavato
		    buffer_tex = substr(buffer_tex, length_filename+1)
		}
		else
		{
		    # altrimenti si elimina dal buffer tutto ciò che precede la chiusa
		    # + la chiusa stessa (eventualmente il nomefile è dopo)
		    buffer_tex = substr(buffer_tex, i_chiusa+1)
		}
		    
	    }
	    # se non c'è nessuno dei due
	    else
	    {
		# ma c'è un'altra aperta
		i_secondaAperta = index ( substr(buffer_tex, 2), "(" )
		if ( i_secondaAperta > 0 )
		{
		    # si elimina dal buffer tutto ciò che precede la seconda aperta
		    buffer_tex = substr(buffer_tex, i_secondaAperta)
		}
		    
		else
		    break
	    }
	        
	    i_aperta = index(buffer_tex, "(")
	}
	    
	# se non c'è un'aperta nel buffer, si procede allo svuotamento dello stesso
	i_aperta = index ( buffer_tex, "(" )
	if ( i_aperta == 0 )
		buffer_tex = ""

	# RICERCA IMMAGINI .png, .jpg o .odf IN FILE DI LOG 
	if ( alsoFigs == 1 || onlyFigs == 1 )
	{
	    # si aggiunge la riga corrente al buffer
	    buffer_img = buffer_img $0

	    # si calcola l'indice di prima occorrenza di "File: "
	    i_file = index(buffer_img, "File: ")

	    # finché esiste "File: "  nel buffer
	    while ( i_file > 0 )
	    {
		# se il buffer finisce con "File: "
		if ( substr(buffer_img, length(buffer_img)-6) == "File: ")
		{
		    # si rimanda la valutazione all'iterazione successiva
		    next
		}
		# se i due caratteri dopo sono "./"
		if ( substr(buffer_img, i_file+6, 2) == "./" )
		{
		    # si elimina tutto ciò che precede "File: "
		    buffer_img = substr (buffer_img, i_file)
		}
		else
		{
		    # altrimenti si elimina ciò che precede "File: " + "File: " stesso
		    buffer_img = substr (buffer_img, i_file+6)
		    i_file = index(buffer_img, "File: ")
		    continue;
		}

		match(buffer_img, /\.(png|jpg|pdf)/ )
		i_estensione = RSTART
		i_chiusa = index(buffer_img, ")")
		
		# se c'è solo l'estensione e non la chiusa
		if ( i_estensione > 0 && i_chiusa == 0)
		{
		    # si controlla prima che non ci sia un "File: " prima dell'estensione
		    i_secondoFile = index(substr(buffer_img, 7), "File: ")
		    if (i_secondoFile > 0 && i_secondoFile < i_estensione)
		    {
			buffer_img=substr(buffer_img, i_secondoFile)
			i_file=index(buffer_img, "File: ")
			continue
		    }
		    # FILE TROVATO
		    length_filename = i_estensione + 4 # indice + le 4 lettere dell'estensione
		    print substr(buffer_img, 7, length_filename-7) # elimino "File: " iniziale

		    # si aggiorna il buffer cancellando il filename appena ricavato
		    buffer_img = substr(buffer_img, length_filename+1)
		}
		# se c'è solo la chiusa ma non l'estensione
		else if ( i_chiusa > 0 && i_estensione == 0)
		{
		    # si elimina dal buffer tutto ciò che precede la chiusa + la chiusa stessa
		    buffer_img = substr(buffer_img, i_chiusa+1)
		}
		# se ci sono entrambi
		else if ( i_estensione > 0 && i_chiusa > 0 )
		{
		    # e viene prima l'estensione
		    if ( i_estensione < i_chiusa )
		    {
			# si controlla prima che non ci sia un "File: " prima dell'estensione
			i_secondoFile = index(substr(buffer_img, 7), "File: ")
			if (i_secondoFile > 0 && i_secondoFile < i_estensione)
			{
			    buffer_img=substr(buffer_img, i_secondoFile)
			    i_file=index(buffer_img, "File: ")
			    continue
			}
			# FILE TROVATO
			length_filename = i_estensione + 4 # indice + le 4 lettere dell'estensione
			print substr(buffer_img, 7, length_filename-7) # elimino "File: " iniziale
			
			# si aggiorna il buffer cancellando il filename appena ricavato
			buffer_img = substr(buffer_img, length_filename+1)
		    }
		    else
		    {
			# altrimenti si elimina dal buffer tutto ciò che precede la chiusa
			# + la chiusa stessa (eventualmente il nomefile è dopo)
			buffer_img = substr(buffer_img, i_chiusa+1)
		    }
		    
		}
		# se non c'è nessuno dei due
		else
		{
		    # ma c'è un'altro "File: "
		    i_secondoFile = index ( substr(buffer_img, 7), "File: " )
		    if ( i_secondoFile > 0 )
		    {
			# si elimina dal buffer tutto ciò che precede il secondo "File: "
			buffer_img = substr(buffer_img, i_secondoFile)
		    }
		    # altrimenti si passa all'iterazione successiva (senza svuotare il buffer)
		    else
			next
		}
	        
		i_file = index(buffer_img, "File: ")
	    }
	    
	    # se si esegue questa riga, significa che non c'è un'aperta nel buffer
	    # si procede allo svuotamento dello stesso
	    buffer_img = ""
	}
    }

    # DAL TERZO FILE IN POI: si eliminano i commenti se strip_comments=1
    else if ( ARGIND > 2 )
    {
	# la prima volta che il il file numero ARGIND viene aperto, si deve trasportare il contenuto del file temporaneo precedentemente riempito nell file di ARGIND-1
	if (numFileDaModificare == 2)
	{
	    filetemp = ARGV[ARGIND] ".txt"
	    numFileDaModificare = 3
	}
	else if (numFileDaModificare != ARGIND)
	{
	    filetemp = ARGV[ARGIND] ".txt"
	    numFileDaModificare = ARGIND
	}

	# CANCELLAZIONE DEI COMMENTI nei file successivi
	if ( stripComments == 1 )
 	{
	    # la prima volta per ogni file, si controlla se è incluso o meno nel file di log
	    if ( fileToIsPresent[ARGV[ARGIND]] == 0 && notincluded[ARGIND] == 0 )
	    {
		print "Errore: il file " ARGV[ARGIND]" non risulta incluso" >> "/dev/stderr"
		notincluded[ARGIND] = 1
		next
	    }
	    
	    # se il primo carattere è "%" non si scrive nulla
	    if ( substr($0, 1, 1) == "%")
	    {
		next
	    }
	    # se il "%" è in mezzo alla riga, si scrive solo la parte che lo precede
	    else if ( match($0, /[^\\]%/, m) )
	    {
		# se almeno un carattere prima di % non è uno spazio o un tab, scrivo
		if ( substr($0, 1, RSTART) ~ /[^ \t]/)
		    print substr($0, 1, RSTART) >> filetemp
		# altrimenti non si scriva (caso equivalente al primo if)
	    }
	    # se non c'è, si scrive la riga come è
	    else
	    {
		print $0 >> filetemp
	    }
        
	}
    }

}
END {
	numNotIncludedFiles = 0
    
	# si rimuovono tutti i file con ".txt" creati nel begin
	for (i=3; i<ARGC; i++)
	{
	    # nel caso siano stati utilizzati (ovvero, stripcomments è true e il file .tex corrispondente era incluso nel file di log), prima di rimuoverli si copiano nei file .tex che dovevano essere strippati
	    # se è stato eseguito l'exit da qualche parte, il codice di END non si esegue
	    if ( exit_status == 0)
	    {
		if ( stripComments == 1 && notincluded[i] == 0)
		    system ("cat " ARGV[i] ".txt > " ARGV[i] )
		else if ( stripComments == 1)
		    numNotIncludedFiles++
	    }
	    # la rimozione dei file di appoggio si esegue sempre
	    system ("rm " ARGV[i] ".txt" )
	}
	exit numNotIncludedFiles
}
