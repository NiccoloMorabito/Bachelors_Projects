#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <limits.h>
#include <stdlib.h>

// stringhe con cui confrontare l'output
#define ERRORE "ERROR"
#define EXIT "EXIT"


int testNamedPipe(char *name);
int executeRequest(char *sedScript, char *inputFilename, char *nr, char *nw);
long int getFileLength(FILE *file);
int isExit(char *output);
void writeERRORn(int fd, int numRiga);
char *getFilenameOf(char filename[], char *type, char *nr, char *nw);

/**
 * Gli argomenti del server sono due nomi di named pipe: nr, nw.
 */
int main(int argc, char *argv[])
{
	int nr_fd;

	// se non sono stati inseriti i 2 argomenti richiesti, ERRORE
	if ( argc-optind != 2 )
  	{
		fprintf(stderr, "Usage: %s piperd pipewr\n", argv[0]);
		return 10;
	}
    
	// SI ANALIZZANO GLI ARGOMENTI PASSATI
	char *nr = argv[optind];
	char *nw = argv[++optind];
	int nrTesting = testNamedPipe(nr);
	if ( nrTesting != 0 )
		return nrTesting;
	int nwTesting = testNamedPipe(nw);
	if ( nwTesting != 0 )
		return nwTesting;

	// SI AVVIA IL SERVER (che si interromperà solo se durante l'esecuzione di una richiesta legge "EXIT" come output)
	while (1)
	{
		// SI APRE LA NAMED PIPE nr 
		int sLen;
		nr_fd = open(nr, O_RDONLY);
		if (nr_fd ==-1)
		{
			fprintf(stderr, "System call open failed because of %s\n", strerror(errno));
			return 100;
		}
		// si legge la dimensione di s
		read(nr_fd, &sLen, sizeof(int));
		// si legge la stringa s passata dal client
		char stringa[sLen];
		read(nr_fd, stringa, sLen);
		stringa[sLen] = '\0';
		// si legge il contenuto del file f
		// e si trascrive in un file da utilizzare come input per il sed
		char c[1];
		char INPUT_SED_FILENAME[strlen("input") + strlen(nr) + strlen(nw) + 4];
		getFilenameOf(INPUT_SED_FILENAME, "input", nr, nw);
		
		int fdinp = creat(INPUT_SED_FILENAME, 0777);
		if (fdinp == -1)
		{
			fprintf(stderr, "System call creat failed because of %s", strerror(errno));
			return 100;
		}
		while ( read(nr_fd, c, 1) > 0 )
			write(fdinp, c, 1);
		close(fdinp);

		// SI ESEGUE LA RICHIESTA SED usando lo script stringa e il contenuto del file appena compilato
		int requestResult = executeRequest(stringa, INPUT_SED_FILENAME, nr, nw);
		if ( requestResult != 0 )
		{
			close(nr_fd);
			remove(nr);
			remove(nw);
			return requestResult;
		}

		close(nr_fd);
		remove(INPUT_SED_FILENAME);
	}
    
  return 0;
}

/**
 * Analizza la named pipe passata come parametro:
 * se non esiste, si crea;
 * 	se la creazione non va a buon fine, restituisce 40;
 * 	altrimenti 0;
 * se esiste ma non è una named pipe, restituisce 30;
 * altrimenti restituisce 0.
 */
int testNamedPipe(char *name)
{
	struct stat pipe_stat;
	int creation = 0;
	int resultStat = stat(name, &pipe_stat);

	// Se la named pipe non esiste, si crea
	if ( resultStat != 0 )
		creation = mkfifo(name, 0666);
	// Se esiste ma non è una named pipe, ERRORE
	else if ( !S_ISFIFO(pipe_stat.st_mode) )
	{
		fprintf(stderr, "Named pipe %s is not a named pipe\n", name);
		return 30;
	}
	
	// Se c'è stato un problema nella creazione, ERRORE
	if ( creation != 0 )
	{
		fprintf(stderr, "Unable to create name pipe %s because of %s\n", name, strerror(errno) );
		return 40;
	}
	else
		return 0;
}

/**
 * Esegue lo script passato come parametro prendendo come input inputFilename e gestisce
 * output ed error del sed.
 * 
 * Restituisce 0 in caso di successo, -1 se l'output del sed è "EXIT"
 */
int executeRequest(char *sedScript, char *inputFilename, char *nr, char *nw) {

	// SI CREANO I FILE CHE VERRANNO USATI COME OUTPUT ED ERROR PER IL SED
	char OUTPUT_SED_FILENAME[strlen("output") + strlen(nr) + strlen(nw) + 4];
	char ERROR_SED_FILENAME[strlen("error") + strlen(nr) + strlen(nw) + 4];
	getFilenameOf(OUTPUT_SED_FILENAME, "output", nr, nw);
	getFilenameOf(ERROR_SED_FILENAME, "error", nr, nw);
	int fdout = creat(OUTPUT_SED_FILENAME, 0777);
	if (fdout == -1)
	{
		fprintf(stderr, "System call creat failed because of %s", strerror(errno));
		return 100;
	}
	int fderr = creat(ERROR_SED_FILENAME, 0777);
	if (fderr == -1)
	{
		fprintf(stderr, "System call creat failed because of %s", strerror(errno));
		return 100;
	}

	// FORK
	pid_t pid;
	int status = -1;
	pid = fork();
	int nw_fd;
	if ( pid == -1 )
	{
		fprintf(stderr, "System call fork failed because of %s", strerror(errno));
		return 100;
	}
	// PROCESSO FIGLIO: ESECUZIONE DEL SED
	else if ( pid == 0 )
	{
		// redirect di output e di error
		dup2(fdout, 1);
		dup2(fderr, 2);
		close(fdout);
		close(fderr);

		// esecuzione
		int executionResult = execl("/bin/sed", "/bin/sed", sedScript, inputFilename, (char*)NULL);
		if (executionResult != 0)
		{
			fprintf(stderr, "System call execl failed because of %s", strerror(errno));
			return 100;
		}
		exit(0);

	}
	// PROCESSO PRINCIPALE: SCRITTURA SU NAMED PIPE nw DELL'OUTPUT O DELL'ERROR DI SED
	else 
	{
		wait(&status);
		nw_fd = open(nw, O_WRONLY);
		// SE LA RICHIESTA È ANDATA A BUON FINE (fdout non è vuoto)
		FILE *foutput = fopen(OUTPUT_SED_FILENAME, "r");
		if ( foutput == NULL)
		{
			fprintf(stderr, "System call fopen failed because of %s", strerror(errno));
			return 100;
		}
		long int lenOutput = getFileLength(foutput);
		if ( lenOutput > 0 )
		{
			// SI MANDA L'OUTPUT AL CLIENT TRAMITE NAMED PIPE nw E SU FILE DESCRIPTOR 3
			char outputContent[lenOutput];
			fread(outputContent, 1, lenOutput, foutput);
			write(nw_fd, outputContent, lenOutput);
			write(3, outputContent, lenOutput);

			// se l'output è "EXIT", si interrompe il server
			if ( isExit(outputContent) == 1 )
			{
				fclose(foutput);
				return 155;
			}
		}
		// ALTRIMENTI SI MANDANO GLI ERRORI (formattati)
		else
		{
			FILE *ferror = fopen(ERROR_SED_FILENAME, "r");
			if ( ferror == NULL )
			{
				fprintf(stderr, "System call s failed because of %s", strerror(errno));
				fclose(foutput);
				return 100;
			}
			
			long int lenError = getFileLength(ferror);

			// SI MANDA L'ERROR AL CLIENT TRAMITE NAMED PIPE nw E SU FILE DESCRIPTOR 3 premettendo "ERRORn:", con n=numRiga, per ogni riga
			int numRiga = 1;
			writeERRORn(nw_fd, numRiga);
			writeERRORn(3, numRiga);
			char c[1];
			c[0] = '.';
			
			for (int i=0; i<lenError; i++)
			{
				// se il carattere precedente termina una riga, si aggiunge il nuovo "ERRORn+1" 
				if ( c[0] == '\n')
				{
					numRiga++;
					writeERRORn(nw_fd, numRiga);
					writeERRORn(3, numRiga);
				}

				// in generale, ogni carattere letto dall'error_file viene scritto sia su nw che su fd3
				fread(c, 1, 1, ferror);
				write(nw_fd, c, 1);
				write(3, c, 1);
			}
			fclose(ferror);
		}
		fclose(foutput);
		close(nw_fd);
	}

	remove(OUTPUT_SED_FILENAME);
	remove(ERROR_SED_FILENAME);

	return 0;
}

/**
 * Restituisce la lunghezza del file passato in input.
 */
long int getFileLength(FILE *file)
{
	fseek(file, 0, SEEK_END);
	long int lenOutput = ftell(file);
	rewind(file);

	return lenOutput;
}

/**
 * Restituisce 1 se la stringa passata come argomento è "EXIT"
 * Restituisce 0 altrimenti.
 */
int isExit(char *output)
{
	char sottostringa[5];
	memcpy(sottostringa, &output[0], 4);
	sottostringa[4] = '\0';

	if (strcmp(sottostringa, EXIT) == 0 )
		return 1;
	else
		return 0;

}

/**
 * Scrive sul file descriptor fd la riga: "ERRORn", con n=numRiga
 */
void writeERRORn(int fd, int numRiga)
{
	char n[3];
	sprintf(n, "%d", numRiga);
	write(fd, ERRORE, 5);
	write(fd, n, strlen(n));
	n[0] = ':';
	write(fd, n, 1);
}

/**
 * Preso come parametro type (input, output o error), restituisce il nome del file corrispondente costruito come di seguito:
 * type_nr_nw.txt, dove nr e nw sono le named pipe passate per parametro
 */
char * getFilenameOf(char filename[], char *type, char *nr, char *nw)
{
	strcpy(filename, type);
	strcat(filename, nr);
	strcat(filename, nw);
	strcat(filename, ".txt");

	// si sostituiscono gli slash nel percorso con degli | per evitare errori di path
	for (int i=0; i<strlen(filename); i++)
	{
		if ( filename[i] == '/')
			filename[i] = '|';
	}

	return filename;
}