#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	const char *deoffuscatoFile = "deoffuscato.txt";
	const char *outputAwkFile = "output_awk.txt";
	const char *errorAwkFile = "error_awk.txt";
	int exitStatus = 0;
    
    // se non viene avviato con gli argomenti richiesti, ERRORE
    if ( argc-optind != 5 )
    {
		fprintf(stderr, "Usage: %s filein fileout awk_script i1 i2\n", argv[0]);
		return 10;
	}
    
	// SI ANALIZZANO GLI ARGOMENTI PASSATI
    char *fin = argv[optind];
    struct stat fin_stat;
    // se il file fin non esiste o non è accessibile in lettura, ERRORE
    if (stat(fin, &fin_stat) == -1)
    {
		fprintf(stderr, "Unable to open file %s because of %s\n", fin, strerror(errno));
		return 20;
	}
    char *fout = argv[++optind];
    char *awkScript = argv[++optind];
    // Si verifica che gli ultimi due argomenti siano numerici
	char *endptr;
	int i1 = strtol(argv[++optind], &endptr, 10);
	// se sono stati inseriti caratteri non numerici nel penultimo argomento, ERRORE
	if (*endptr != '\0' || endptr == optarg) {
		fprintf(stderr, "Usage: %s filein fileout awk_script i1 i2\n", argv[0]);
		return 10;
	}
    int i2 = strtol(argv[++optind], &endptr, 10);
	// se sono stati inseriti caratteri non numerici nell'ultimo argomento, ERRORE
	if (*endptr != '\0' || endptr == optarg) {
		fprintf(stderr, "Usage: %s filein fileout awk_script i1 i2\n", argv[0]);
		return 10;
	}

	// SI CONTANO I BYTE CONTENUTI NEL fin
	FILE *fileIn = fopen(fin, "rb");
	unsigned long numBytes;
	fseek(fileIn, 0, SEEK_END);
	numBytes = ftell(fileIn);
	fseek(fileIn, 0, SEEK_SET);
    
	// SI PRELEVANO DAL FILE I DUE NUMERI di 4 byte all'inizio di fin
	int numeri[2];
	fread(&numeri, 4, 2, fileIn);
	int n1 = numeri[0];
	int n2 = numeri[1];
	
	// se il file non contiene almeno n1+n2+8 bytes, ERRORE
	if (numBytes < n1+n2+8)
	{
		fprintf(stderr, "Wrong format for input binary file %s", fin);
		return 30;
	}

	// SI LEGGE IL FILE BINARIO fin (deoffuscando dove necessario) e si trascrive il contenuto su un file txt.
	// Per ricomporre il testo non offuscato, occorre leggere normalmente i caratteri da 8+1 a 8+n1 (i primi 8 sono stati già letti precedentemente)
	// complementare bit-a-bit quelli da 8+n1+1 a 8+n1+n2 
	// e leggere di nuovo normalmente i caratteri restanti, da 8+n1+n2 in poi.
	FILE *fdeoffuscato = fopen(deoffuscatoFile, "w");
	for (int i=0; i<numBytes-8; i++)
	{
		// lettura di un carattere da fin
		char c = fgetc(fileIn);

		// se il byte è compreso tra 8+n1 e 8+n1+n2, si complementa bit a bit
		if ( i>=n1 && i<n1+n2 )
			c = ~c;

		// scrittura del carattere su fdeoffuscato
		fputc(c, fdeoffuscato);
	}
	fclose(fileIn);
	fclose(fdeoffuscato);

	// SI ESEGUE IL COMANDO GAWK E SI PRODUCE L'OUTPUT RICHIESTO
	pid_t pid;
	int status = -1;
	pid = fork();
	if (pid == -1)
	{
		fprintf(stderr, "System call fork failed because of %s", strerror(errno));
		return 100;
	}
	// PROCESSO FIGLIO
	else if ( pid == 0)
	{
		// si redirecta l'output del gawk sul file outputAwkFile
		int fdOut = creat(outputAwkFile, 0777);
		dup2(fdOut, 1);
		// si redirecta l'error del gawk sul file errorAwkFile
		int fdErr = creat(errorAwkFile, 0777);
		dup2(fdErr, 2);
		close(fdOut);
		close(fdErr);
		// si esegue il comando gawk
		int executionResult = execl("/usr/bin/gawk", "gawk", awkScript, deoffuscatoFile, (char*)NULL);
		if (executionResult != 0)
		{
			fprintf(stderr, "System call exec failed because of %s", strerror(errno));
			return 100;
		}
		exit(0);
	}
	// PROCESSO PRINCIPALE
	else
	{
		// attende la conclusione del comando gawk e la scrittura del suo file di output e di error
		wait(&status);

		/* --PROBABILMENTE NON RICHIESTO--
		// se fout non esiste o non è accessibile in scrittura, ERRORE
		struct stat outputStat;
		if ( stat(fout, &outputStat) == -1 )
		{
			fprintf(stderr, "Unable to open file %s because of %s\n", fout, strerror(errno) );
			return 70;
		}
		*/
		
		FILE *foutputAwk = fopen(outputAwkFile, "r");
		FILE *ferrorAwk = fopen(errorAwkFile, "r");
		// si calcola la lunghezza del file dell'output del gawk
		int lunghezzaOutputAwk;
		fseek(foutputAwk, 0, SEEK_END);
		lunghezzaOutputAwk = ftell(foutputAwk);
		fseek(foutputAwk, 0, SEEK_SET);
		// si calcola la lunghezza del file di error del gawk
		int lunghezzaErrorAwk;
		fseek(ferrorAwk, 0, SEEK_END);
		lunghezzaErrorAwk = ftell(ferrorAwk);
		fseek(ferrorAwk, 0, SEEK_SET);

		// se la risposta di awk (output+error) non ha almeno i1+i2 bytes, il file andrà creato senza offuscamento (i1 = i2 = 0)
		if ( lunghezzaOutputAwk+lunghezzaErrorAwk < i1+i2 )
		{
			i1 = 0;
			i2 = 0;

			// si modifica l'exit statu a 80 per dopo
			exitStatus = 80;
		}
		
		// SCRITTURA DEL FILE BINARIO DI OUTPUT fout
		FILE *fileOut = fopen(fout, "wb");

		// si scrivono i due numeri i1, i2 sul fout
		fwrite(&i1, sizeof(int), 1, fileOut);
		fwrite(&i2, sizeof(int), 1, fileOut);

		// si legge l'output prodotto dal gawk scrivendo su fout (offuscando dove richiesto)
		for ( int i = 0; i<lunghezzaOutputAwk; i++)
		{
			// lettura di un carattere dall'output
			char c = fgetc(foutputAwk);

			// se il byte è compreso tra 8+i1 e 8+i1+i2, si complementa bit a bit prima di salvare
			if ( i>=i1 && i<i1+i2 )
				c = ~c;

			// scrittura del carattere su fout
			fputc(c, fileOut);
		}

		// si legge l'error prodotto dal gawk scrivendo su fout (offuscando dove richiesto);
		for ( int i = 0; i<lunghezzaErrorAwk; i++)
		{
			// lettura di un carattere dall'error
			char c = fgetc(ferrorAwk);

			// se il byte è compreso tra 8+i1 e 8+i1+i2, si complementa bit a bit prima di salvare
			if ( i+lunghezzaOutputAwk>=i1 && i+lunghezzaOutputAwk<i1+i2 )
				c = ~c;

			// scrittura del carattere su fout
			fputc(c, fileOut);
		}

		fclose(foutputAwk);
		fclose(ferrorAwk);
		fclose(fileOut);
		
	}

	// si cancellano i file temporanei
	remove(deoffuscatoFile);
	remove(outputAwkFile);

    return exitStatus;
}
