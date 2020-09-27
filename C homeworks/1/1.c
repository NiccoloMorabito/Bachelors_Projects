#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <locale.h>
#include <errno.h>

int isFile(struct stat path_stat);
int isDirectory(struct stat path_stat);
void printFileDetails(char *filename, struct stat path_stat, int l_inserita, int mod);
void printHardLinkCount(struct stat path_stat);
void printDimension(struct stat path_stat);
int exploreDirectory(char *dir, int l_inserita, int mod, int R_inserita, int length);
void printPermessions(struct stat path_stat);
int getFirstLetterOfPermission(int mode);
int orderLex(const void *p1, const void *p2);
int orderLexDirAllaFine(const void *p1, const void *p2);

int main(int argc, char *argv[])
{	
	// Si inizializzano i booleani per le opzioni inserite
	int d_inserita = 0;
	int R_inserita = 0;
	int l_inserita = 0;
	int mod;
	
	// si calcola la lunghezza del path della cwd (serve nella stampa ricorsiva)
	int length;
	char cwd[PATH_MAX];
	if (getcwd(cwd, sizeof(cwd)) != NULL)
		length = strlen(cwd);
	
	// SI ANALIZZANO LE OPZIONI
	int opt;
    while((opt = getopt(argc, argv, ":dRl:")) != -1)  
    {  
        switch(opt)  
        {  
			// è stata inserita l'opzione -d
            case 'd':
				d_inserita = 1;
				break;
			// è stata inserita l'opzione -R
            case 'R':
				R_inserita = 1;
				break;
			// è stata inserita l'opzione -l
            case 'l':
                l_inserita = 1;
                
                // si verifica che sia stato inserito un argomento mod numerico
				char *endptr;
                mod = strtol(optarg, &endptr, 10);
                // se sono stati inseriti caratterici non numerici
				if (*endptr != '\0' || endptr == optarg) {
					// si restituisce l'errore
					fprintf(stderr, "Usage: %s [-dR] [-l mod] [files]\n", argv[0]);
					return 20;
				}

                break; 
            // è stata inserita l'opzione -l ma senza mod -> ERRORE
            case ':':
				fprintf(stderr, "Usage: %s [-dR] [-l mod] [files]\n", argv[0]);
                return 20;  
            // è stata inserita un'opzione sconosciuta -> ERRORE
            case '?':
				fprintf(stderr, "Usage: %s [-dR] [-l mod] [files]\n", argv[0]);
                return 20;  
        }  
    } 
    
    int passedFiles = argc-optind;
    
    // SE NON SONO STATI INSERITI FILE ARGOMENTO
	if (argc-optind == 0) {
		// Si calcola lo stat per studiare il file/directory
		struct stat path_stat;
		if ( lstat(".", &path_stat) == -1)
		{
			fprintf(stderr, "System call scandir failed because of %s\n", strerror(errno));
			return 100;
		}
		// si esplora la dir se -d non è stata inserita
		if (d_inserita == 0)
		{
			if ( exploreDirectory(".", l_inserita, mod, R_inserita, length) == 100)
				return 100;
		}
		else
			printFileDetails(".", path_stat, l_inserita, mod);
	}
	
	// PRIMA DELL'ORDINAMENTO, SI SCORRONO I FILE PER VERIFICARE QUALI NON ESISTONO
	int numFileErrors = 0;
	for(int i=optind; i < argc; i++){
		struct stat path_stat;
		int statResult = lstat(argv[i], &path_stat);
		// se non esiste
		if (statResult != 0) {
			// si stampa su standard errore di ls
			fprintf(stderr, "%s: cannot access '%s': No such file or directory\n", argv[0], argv[i]);
			
			numFileErrors++;
		}
	}
	
	// ORDINAMENTO VETTORE DI ARGOMENTI
	setlocale(LC_ALL, "C");
	// se d non è inserita, si ordinano lessicograficamente gli argomenti
	if ( d_inserita==1 )
		qsort(&argv[optind], argc -optind, sizeof(char *), orderLex);
	// altrimenti, si ordina lessicograficamente ma mettendo le directory alla fine
	else
		qsort(&argv[optind], argc -optind, sizeof(char *), orderLexDirAllaFine);
		
	// SI ANALIZZANO I FILE INSERITI
	int firstArgumentIndex = optind;
	for(; optind < argc; optind++){
		
		// Si calcola lo stat per studiare il file/directory
		struct stat path_stat;
		int statResult = lstat(argv[optind], &path_stat);

		// se non esiste
		if (statResult != 0)
			continue;
		// se è una directory
		else if (isDirectory(path_stat)){
			// se -d non inserita, si stampa sempre un accapo in più prima dei dettagli su una directory (tranne la prima volta)
			if (firstArgumentIndex != optind  && d_inserita==0)
				printf("\n");
			// si stampa il nome della directory se sono stati passati almeno due file
			// con opzioni -R e -D non si stampa in quanto si stampa un'unica volta rispettivamente da explore_directory() o da printFileDetails()
			if ( passedFiles > 1 && R_inserita == 0 && d_inserita == 0)
			{
				printf("%s", argv[optind]);
				// se -d non è inserita -> si deve esplorare, si aggiungono anche i due punti
				if (d_inserita == 0)
					printf(":");
				printf("\n");
			}
			// si esplora la dir se -d non è stata inserita
			if (d_inserita == 0)
			{
				if ( exploreDirectory(argv[optind], l_inserita, mod, R_inserita, length) == 100)
					return 100;
			}
			else
				printFileDetails(argv[optind], path_stat, l_inserita, mod);
		}
		// se è un file
		else if (isFile(path_stat)){
			printFileDetails(argv[optind], path_stat, l_inserita, mod);
		}
	}
	// se è stato inserito almeno un file inesistente, si esce con codice = numFileErrors
	if (numFileErrors > 0)
		return numFileErrors;
	
	return 0;
}

/*
 * Funzione per l'ordinamento lessicografico.
 */
int orderLex(const void *p1, const void *p2)
{ 
   return strcmp(* (char * const *) p1, * (char * const *) p2);
}

/*
 * Funzione per l'ordinamento lessicografico che mette però le directory alla fine
 */
int orderLexDirAllaFine(const void *p1, const void *p2)
{
       
    char *s1 = *(char * const *) p1;
    char *s2 = *(char * const *) p2;

	int firstIsDir = 0;
	DIR *dir;
	if ( (dir = opendir(s1)) ) {
		firstIsDir = 1;
		closedir(dir);
	}

	int secondIsFile = 0;
	FILE *file;
	if ( (file = fopen(s2, "r")) ){
		secondIsFile = 1;
		fclose(file);
	}
	
	int comparison = strcmp(s1,s2);

	if ( firstIsDir && secondIsFile==1 )
		return 1;
	else if ( comparison > 0 )
		return 1;
	else if ( comparison == 0)
		return 0;

	return -1;
}

/*
 * Verifica se il path passato come parametro è di un file regolare o di un link simbolico.
 */
int isFile(struct stat path_stat)
{
	return S_ISREG(path_stat.st_mode) || S_ISLNK(path_stat.st_mode);
}

/*
 * Verifica se il path passato come parametro è di una directory.
 */
int isDirectory(struct stat path_stat) {
   return S_ISDIR(path_stat.st_mode);
}

/*
 * Effettua l'esplorazione della directory passata come primo parametro in base alle opzioni inserite.
 */
int exploreDirectory(char *dir, int l_inserita, int mod, int R_inserita, int length) {
	
	// si printa il relative path della directory corrente se -R inserita
	if ( R_inserita == 1) {
		char cwd[PATH_MAX];
		if (getcwd(cwd, sizeof(cwd)) != NULL && dir[0] != '.') {		
			// si stampa il risultato di getcwd senza i primi l caratteri (per stampare solo il percorso relativo alla dir di partenza)
			printf(".%s/", cwd + length);
		}
		// si stampa il nome della directory corrente
		printf("%s:\n", dir);
	}
	
	// Si effettua lo scandir della directory
	struct dirent **namelist;
	int n;
	n = scandir(dir, &namelist, NULL, alphasort);
	
	// si entra nella cartella che si sta esplorando
	chdir(dir);
	
	// se c'è stato un errore
	if (n < 0)
	{
		fprintf(stderr, "System call scandir failed because of %s\n", strerror(errno));
		return 100;
	}
	// altrimenti si scorrono i file
	else {
		
		// se è stata inserita -l, si deve calcolare il totale
		if ( l_inserita == 1 ) {
			int total = 0;
			// in total si accumula somma dei blocchi allocati per ogni file
			for (int i=0; i<n; i++) {
				char firstChar = (*namelist[i]).d_name[0];
				if (firstChar != '.')
				{
					struct stat path_stat;
					if ( lstat((*namelist[i]).d_name, &path_stat) == -1)
					{
						fprintf(stderr, "System call lstat failed because of %s\n", strerror(errno));
						return 100;
					}
					total += path_stat.st_blocks;
				}
			}
			total = total / 2;
			printf("total %d\n", total);
		}
		for (int i=0; i<n; i++) {
			// si stampa il nome e gli eventuali dettagli del file (se non inizia con il punto)
			char firstChar = (*namelist[i]).d_name[0];
			if (firstChar != '.')
			{
				struct stat path_stat;
				if ( lstat((*namelist[i]).d_name, &path_stat) == -1)
				{
					fprintf(stderr, "System call lstat failed because of %s\n", strerror(errno));
					return 100;
				}
				printFileDetails((*namelist[i]).d_name, path_stat, l_inserita, mod);
			}
			// se namelist non serve dopo per -R, si dealloca la memoria corrispondente
			if ( R_inserita == 0) {
				free(namelist[i]);
			}
		}
		// se è stata inserita -R, si deve ricorsivamente chiamare l'exploreDirectory su ogni directory
		if ( R_inserita == 1 ) {
			for (int i=0; i<n; i++) {
				char firstChar = (*namelist[i]).d_name[0];
				if (firstChar != '.' )
				{
					struct stat path_stat;
					if ( lstat((*namelist[i]).d_name, &path_stat) == -1)
					{
						fprintf(stderr, "System call lstat failed because of %s\n", strerror(errno));
						return 100;
					}
					if ( isDirectory(path_stat) ) 
					{
						printf("\n");
						exploreDirectory((*namelist[i]).d_name, l_inserita, mod, R_inserita, length);
					}
				}
				free(namelist[i]);
			}
		}
		free(namelist);
	}
	
	// si torna alla directory precedente
	chdir("..");
	return 0;
}

/*
 * Stampa tutti i dettagli sui permessi del file il cui stat è passato per parametro
 */
void printPermessions(struct stat path_stat)
{
    static char bits[11];
    int mode = path_stat.st_mode;

	// prima lettera
	if (S_ISREG(mode))
        bits[0] = '-';
    else if (S_ISDIR(mode))
        bits[0] = 'd';
    else if (S_ISBLK(mode))
        bits[0] = 'b';
    else if (S_ISCHR(mode))
        bits[0] = 'c';
    else if (S_ISFIFO(mode))
        bits[0] = 'p';
    else if (S_ISLNK(mode))
        bits[0] = 'l';
    else if (S_ISSOCK(mode))
        bits[0] = 's';
	else 
		bits[0] = '?';

	// terna dell'utente
	bits[1] = (mode & S_IRUSR) ? 'r' : '-';
	bits[2] = (mode & S_IWUSR) ? 'w' : '-';
	bits[3] = (mode & S_IXUSR) ? 'x' : '-';

	// terna del gruppo
	bits[4] = (mode & S_IRGRP) ? 'r' : '-';
	bits[5] = (mode & S_IWGRP) ? 'w' : '-';
	bits[6] = (mode & S_IXGRP) ? 'x' : '-';

	// terza degli altri
	bits[7] = (mode & S_IROTH) ? 'r' : '-';
	bits[8] = (mode & S_IWOTH) ? 'w' : '-';
	bits[9] = (mode & S_IXOTH) ? 'x' : '-';

	// sticky bit, setuid bit, setgroup bit
	if (mode & S_ISUID)
        bits[3] = (mode & S_IXUSR) ? 's' : 'S';
    if (mode & S_ISGID)
        bits[6] = (mode & S_IXGRP) ? 's' : 'S';	
    if (mode & S_ISVTX)
        bits[9] = (mode & S_IXOTH) ? 't' : 'T';

    bits[10] = '\0';

    printf("%s\t", bits);
}

/*
 * Stampa il numero di hard link del file il cui stat è passato per parametro
 */
void printHardLinkCount(struct stat path_stat) {
	printf("%d", (int)path_stat.st_nlink);
	printf("\t");
}

/*
 * Stampa la dimensione del file il cui stat è passato per parametro
 */
void printDimension(struct stat path_stat) {
	printf("%d", (int)path_stat.st_size);
	printf("\t");
}

/*
 * Stampa i dettagli del file il cui stat è passato per parametro in base al valore di mod se -l inserita
 */
void printFileDetails(char *filename, struct stat path_stat, int l_inserita, int mod) {
	// se -l inserita, si stampano i dettagli aggiuntivi in base al valore di mod
	if ( l_inserita == 1 ) {
		// si stampano sempre i permessi
		printPermessions(path_stat);
		// se mod 0
		if ( mod == 0 ) {
			// si stampano anche hard link count e dimensione
			printHardLinkCount(path_stat);
			printDimension(path_stat);
		}
	}
	// in generale, si stampa sempre il nome
	printf("%s", filename);
	// se è un symbolic link e se -l inserita si stampa anche la destinazione del link
	if ( S_ISLNK(path_stat.st_mode) && l_inserita == 1 )
	{
		char *linkname = malloc(path_stat.st_size + 1);
		readlink(filename, linkname, path_stat.st_size + 1);
		linkname[path_stat.st_size] = '\0';
		printf(" -> %s", linkname);
		free(linkname);
	}
	printf("\n");
}

