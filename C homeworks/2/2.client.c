#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h> 
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

#define ERRORE "ERROR"

int testNamedPipe(char *name);
int isAnErrorRow(char *output);

/**
 * Gli argomenti del client sono, in ordine:
 * - due nomi di named pipe: nr, nw;
 * - una stringa s;
 * - un intero f.
 */
int main(int argc, char *argv[])
{
	// se non sono stati inseriti i 4 argomenti richiesti, ERRORE
	if ( argc-optind != 4 )
	{
		fprintf(stderr, "Usage: %s piperd pipewr sed_program fd\n", argv[0]);
		return 20;
	}
    
	// SI ANALIZZANO GLI ARGOMENTI PASSATI
	char *nr = argv[optind];
	char *nw = argv[++optind];
	int nrTesting = testNamedPipe(nr);
	if (nrTesting != 0)
		return nrTesting;
	int nwTesting = testNamedPipe(nw);
	if ( nwTesting != 0 )
		return nwTesting;

	char *stringa = argv[++optind];
	// si verifica che l'ultimo argomento sia numerico
	char *endptr;
	int f = strtol(argv[++optind], &endptr, 10);
	// se sono stati inseriti caratterici non numerici, ERRORE
	if (*endptr != '\0' || endptr == optarg) {
		fprintf(stderr, "Usage: %s fpiperd pipewr sed_program fd\n", argv[0]);
		return 20;
	}

	// SI APRE LA NAMED PIPE NW PER INVIARE LA STRINGA s E IL CONTENUTO DEL FILE f AL SERVER
	int nw_fd;
	nw_fd = open(nw, O_WRONLY);

	// prima di scrivere s, si scrive la sua dimensione 
	int sLen = strlen(stringa);
	write(nw_fd, &sLen, sizeof(sLen));
	// si scrive s
	write(nw_fd, stringa, sLen);
	// si scrive il contenuto di f
	char c[1];
	while ( read(f, c, 1) != 0)
		write(nw_fd, c, 1);
	
	close(nw_fd);
	

	// SI LEGGONO I RISULTATI (output o error) DEL SED ESEGUITO DAL SERVER TRAMITE nr
	int nr_fd;
	int indiceOutput = 0;
	char output[10000];
	nr_fd = open(nr, O_RDONLY);
	
	while ( read(nr_fd, c, 1) > 0 ) 
		output[indiceOutput++] = c[0];
	output[indiceOutput++] = '\0';

	// se è error, si redirecta sullo stderr
	if ( isAnErrorRow(output) > 0 )
		fprintf(stderr, "%s", output);
	// altrimenti, sullo stdout
	else
		fprintf(stdout, "%s", output);

	close(nr_fd);

	return 0;
}

/**
 * Analizza la named pipe passata come parametro:
 * se non esiste, restituisce 80;
 * se esiste ma non è una named pipe, restituisce 30;
 * altrimenti restituisce 0.
 */
int testNamedPipe(char *name)
{
	struct stat pipe_stat;
	int resultStat = stat(name, &pipe_stat);
    
	// Se la named pipe non esiste, ERRORE
	if ( resultStat != 0 )
	{
		fprintf(stderr, "Unable to open named pipe %s because of %s\n", name, strerror(errno) );
		return 80;
	}
	// Se esiste ma non è una named pipe, ERRORE
	if ( !S_ISFIFO(pipe_stat.st_mode) )
	{
		fprintf(stderr, "Named pipe %s is not a named pipe\n", name);
		return 30;
	}
	
	return 0;
}

/**
 * Restituisce 1 se la stringa passata come argomento inizia con "ERROR"
 * Restituisce 0 altrimenti.
 */
int isAnErrorRow(char *output)
{
	// si verifica se le prime 5 lettere sono uguali alla stringa "ERROR"
	char sottostringa[6];
	memcpy(sottostringa, &output[0], 5);
	sottostringa[5] = '\0';

	if (strcmp(sottostringa, ERRORE) == 0 )
		return 1;
	else
		return 0;

}