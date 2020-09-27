package it.uniroma1.lcl.babelarity;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

// TODO javadoc dei campi? (sia qui che dalle altre parti)
public class MiniBabelNet implements Iterable<Synset>
{
	// ISTANZA
	private static MiniBabelNet istance;
	
	// CAMPI CHE SEGUONO L'IDEA SCRITTA NEL COSTRUTTORE
	private Map<String, List<String>> lemmi = new HashMap<>();							// mappa parolaFlessa:[lista lemma di quella parola]
	private Set<Synset> synsets = new HashSet<>();										// insieme dei synset
	private Map<String, List<String>> definizioni = new HashMap<>();					// mappa idSynset:[lista definizioni synset]
	private Map<String, List<String>> relationsMap = new HashMap<>();					// mappa id_synset:[lista synset in relazione con synset], con elementolista = idSynset_nomeRelazioneSemplice_nomeRelazioneCompleto
	/**
	 * Contiene tutti i syn di ogni synset presente nel documento DICTIONARY
	 */
	private Set<String> dictionaryWords = new HashSet<>();
	// mappa con {parola -> array di flags} (ogni flag in posizione i indica se parola compare nell'i-esimo documento)
	private Map<String, boolean[]> wordToFlags = new HashMap<>();
	private Set<String> allwords = new HashSet<>();
	
	// CAMPI PER INDIRIZZI FILE UTILI
	private final static String LEMMATIZATION =	"resources/lemmatization-en.txt";
	private final static String GLOSSES = 		"resources/glosses.txt";
	private final static String DICTIONARY = 	"resources/dictionary.txt";
	private final static String RELATIONS = 	"resources/relations.txt";
	
	// CAMPI STRATEGY PATTERN
	LexicalSimilarity lexicalSimilarity;
	SemanticSimilarity semanticSimilarity;
	DocumentSimilarity documentSimilarity;
	
	private static final Set<String> stopwords = new HashSet<>(Arrays.asList("i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now"));
	
	/**
	 * Costruttore privato di MiniBabelNet.
	 * 
	 * Oltre a inizializzare i campi, il costruttore analizza i quattro file con le informazioni per la rete semantica: LEMMATIZATION, GLOSSES, DICTIONARY, RELATIONS.
	 * Inoltre, setta gli algoritmi di similarità (lessicale, semantica e di documenti) di default.
	 */
	private MiniBabelNet()
	{
		this.lemmi = new HashMap<>();
		this.synsets = new HashSet<>();
		this.definizioni = new HashMap<>();
		this.relationsMap = new HashMap<>();
		this.dictionaryWords = new HashSet<>();
		this.wordToFlags = new HashMap<>();
		this.allwords = new HashSet<>();
		
		// per ogni forma flessa aggiungo una voce a lemmi del tipo formaFlessa->[lemmiCorrispondenti]
		this.lemmi = getLines(LEMMATIZATION).stream()
											.map(riga -> new ArrayList<String>(Arrays.asList(riga.toLowerCase().split("\t"))))
											.collect(Collectors.toMap(	riga -> riga.remove(0),
																		riga -> riga,
																		(riga1, riga2) -> Arrays.asList(riga1.get(0), riga2.get(0))
																		));
		
		// per ogni synset aggiungo una voce a definizioni del tipo idSynset -> [definizioni]
		this.definizioni = getLines(GLOSSES).stream()
											.map(riga -> new ArrayList<>(Arrays.asList(riga.toLowerCase().split("\t"))))
											.collect(Collectors.toMap(
																		riga -> riga.remove(0),
																		riga -> riga
																	 ));		
		
		// per ogni riga del file, creo un synset con l'id e i lemmi che lo seguono + le definizioni trovate nel punto precedente
		// inoltre, aggiungo tutti i lemmi a dictionaryWords
		for (String riga : getLines(DICTIONARY))
		{
			List<String> splitted = new ArrayList<String>(Arrays.asList(riga.toLowerCase().split("\t")));
			String id = splitted.remove(0);
			Set<String> lemmi = new HashSet<>(splitted);
			this.synsets.add(new BabelSynset(id, lemmi, definizioni.get(id)));
			this.dictionaryWords.addAll(lemmi);
		}
	
		// ad ogni riga del file corrisponde una relazione nel seguente formato: synset_sorgente TAB(\t) synset_destinazione TAB(\t) nome_relazione_semplice TAB(\t) nome_relazione_completo NEWLINE(\n)
		// nella mappa relationsMap, ad ogni id corrisponde una lista delle relazioni che ha, ciascuna delle quali è una stringa formattata nel seguente formato:
		for (String riga : getLines(RELATIONS))
		{
			String[] splitted = riga.toLowerCase().split("\t");
			String key = splitted[0];
			
			String value = String.join("_", Arrays.copyOfRange(splitted, 1, splitted.length));

		    relationsMap.computeIfAbsent(key, v -> new ArrayList<>()).add(value);
		}
		
		this.lexicalSimilarity = new BabelLexicalSimilarity()::computeSimilarity;
		this.semanticSimilarity = new BabelSemanticSimilarity()::computeSimilarity;
		this.documentSimilarity = new BabelDocumentSimilarity()::computeSimilarity;
	}

	/**
	 * Dato il percorso di un file, restituisce la lista delle righe contenute in file.
	 * 
	 * @param file che si vuole aprire
	 * @return lista delle righe di file
	 */
	private List<String> getLines(String file)
	{
		Path glosses = Paths.get(file);
		List<String> lines = new ArrayList<>();
		
		try
		{
			BufferedReader br = Files.newBufferedReader(glosses);
			while (br.ready())
				lines.add(br.readLine());
			br.close();
		}
		catch (IOException e)
		{
			System.out.println("Il fine " + file.split("/")[file.split("/").length-1] + " non è disponibile.");
		}
		
		return lines;
	}

	/**
	 * Restituisce l'unica istanza della rete semantica MiniBabelNet.
	 * @return istanza MiniBabelNet
	 */
	public static MiniBabelNet getInstance()
	{
		if (istance==null)
			istance = new MiniBabelNet();
		return istance;
	}

	/**
	 * Scorrendo tutti i file del corpus attraverso l'istanza di CorpusManager, computa le strutture dati necessarie per la BabelLexicalSimilarity: l'insieme delle allWords presenti in tutti i documenti e il vettore-occorrenze di ogni documento nel corpus.
	 * Per ogni file nella cartella CORPUS, leva tutti i segni di punteggiatura dal testo e splitta con lo spazio per ottenere una lista di stringhe (allWordsInFile) e costruisce un vettore di boolean in cui per ogni flag in posizione i il booleano rappresenta se è presente o meno la parola nell'i-esimo file del corpus.
	 */
	private void prepareLexicalSimilarity()
	{
		int numFile = 0;
		
		CorpusManager corpusManager = CorpusManager.getInstance();
		int numberOfCorpusFiles = corpusManager.getNumberOfCorpusFiles();

		for (File f : corpusManager)
		{
			List<String> allWordsInFile = new ArrayList<>();
			try
			{
				BufferedReader br = Files.newBufferedReader(f.toPath());
				while (br.ready())
					allWordsInFile.addAll(Arrays.asList(br.readLine().replaceAll("[^a-zA-Z- ]", " ").toLowerCase().split("\\s+")));
			}
			catch (IOException e)
			{
				System.out.println("Il file '" + f + "' del corpus di documenti non è disponibile.");
			}
			
			for (String word : allWordsInFile)
			{
				word = getLemmas(word).get(0); 
				if (!stopwords.contains(word) && word.length()>2)
				{
					allwords.add(word);
					wordToFlags.computeIfAbsent(word, w -> new boolean[numberOfCorpusFiles]);
					wordToFlags.get(word)[numFile] = true;
				}
			}
			numFile++;
		}
	}
	
	/**
	 * Restituisce il vettore che rappresenta le occorrenze della parola data in input all'interno dei file del corpus analizzati in prepareLexicalSimilarity().
	 * @param word 
	 * @return vettore di flags in cui, per ogni i, se vettore[i] allora word compare nell'i-esimo documento; se !vettore[i] allora word non compare nell'i-esimo documento.
	 */
	public boolean[] getOccorrenze(String word)
	{
		if (wordToFlags.isEmpty()) prepareLexicalSimilarity();
		return wordToFlags.get(word);
	}
	
	/**
	 * Restituisce l'array di tutte le parole trovate in tutti i file del corpus analizzati in prepareLexicalSimilarity().
	 * @return
	 */
	public String[] getAllWords()
	{
		if (allwords.isEmpty()) prepareLexicalSimilarity();
		return allwords.toArray(new String[allwords.size()]);
	}
	
	/**
	 * Restituisce l'insieme di synset che contengono tra i loro sensi la parola in input
	 * @param word di cui si vuole ottenere la lista di synset corrispondenti
	 * @return la lista dei synset che contengono tra i loro sensi la parola in input
	 */
	public List<Synset> getSynsets(String word)
	{	
		List<Synset> synsetsConWord = new ArrayList<>();
		for (Synset s : synsets)
		{
			for (String lemma : s.getLemmas())
				if (lemmi.getOrDefault(lemma, List.of()).contains(word))
					synsetsConWord.add(s);
		}
		return synsetsConWord;
	}
	
	/**
	 * Restituisce il synset relativo all'id specificato
	 * @param id del synset che si vuole ottenere
	 * @return istanza del Synset con id uguale a quello dato in input
	 */
	public Synset getSynset(String id)
	{
		for (Synset synset : this.synsets)
			if (synset.getID().equals(id))
				return synset;
		return null;
	}
	
	/**
	 * Restituisce uno o più lemmi associati alla parola flessa fornita in input
	 * @param word di cui si vuole ottenere i lemmi
	 * @return la lista dei lemmi corrispondenti se esiste, la parola se è già in forma base o stringa vuota altrimenti
	*/
	public List<String> getLemmas(String word)
	{
		if (lemmi.containsKey(word)) return lemmi.get(word);
		else if (dictionaryWords.contains(word)) return List.of(word);
		else return List.of("");
	}
	
	/**
	 * Restituisce le informazioni inerenti al Synset fornito in input sotto forma di stringa.
	 * Il formato della stringa è il seguente:
	 * ID\tPOS\tLEMMI\tGLOSSE\tRELAZIONI
	 * 
	 * Le componenti LEMMI, GLOSSE e RELAZIONI possono contenere più elementi, questi sono separati dal carattere ";"
	 * Le relazioni devono essere condificate nel seguente formato:
	 * 		TARGETSYNSET_RELATIONNAME		es. bn:00081546n_has-kind
	 * 	
	 * es: bn:00047028n	NOUN	word;intelligence;news;tidings	Information about recent and important events	bn:0000001n_has-kind;bn:0000001n_is-a
	 * 
	 * @param s synset di cui si vuole ottenere il sommario
	 */
	String getSynsetSummary(Synset s)
	{
		String id = s.getID();
		return 	id + "\t" +																		// ID
				s.getPOS() + "\t" +																// POS
				s.getLemmas().stream().collect(Collectors.joining(";")) + "\t" +				// lemmi
				s.getGlosses().stream().collect(Collectors.joining(";")) + "\t" +				// definizioni
				this.relationsMap.get(id).stream()												// relazioni
										.map(relazione -> relazione.split("_")[0] + "_" + relazione.split("_")[1])
										.collect(Collectors.joining(";"));
	}

	/**
	 * Imposta l'algoritmo di calcolo della similarità tra parole.
	 */
	public void setLexicalSimilarityStrategy(LexicalSimilarity lexicalSimilarity)
	{
		this.lexicalSimilarity = lexicalSimilarity;
	}
	
	/**
	 * Imposta l'algoritmo di calcolo della similarità tra synset.
	 */
	public void setSemanticSimilarityStrategy(SemanticSimilarity semanticSimilarity)
	{
		this.semanticSimilarity = semanticSimilarity;
	}
	
	/**
	 * Imposta l'algoritmo di calcolo della similarità tra documenti.
	 */
	public void setDocumentSimilarityStrategy(DocumentSimilarity documentSimilarity)
	{
		this.documentSimilarity = documentSimilarity;
	}
	
	/**
	 * Calcola e restituisce un double che rappresenta la similarità tra due oggetti linguistici (Synset, Documenti o Word).
	 * @param o1 primo oggetto linguistico
	 * @param o2 secondo oggetto linguistico
	 * @return valore di similarità tra i due oggetti dati in input
	 */
	public double computeSimilarity(LinguisticObject o1, LinguisticObject o2)
	{
		if 		(o1 instanceof Word && o2 instanceof Word) 			
			return lexicalSimilarity.computeSimilarity((Word)o1, (Word)o2);
		else if (o1 instanceof Synset && o2 instanceof Synset) 		
			return semanticSimilarity.computeSimilarity((Synset)o1, (Synset)o2);
		else if (o1 instanceof Document && o2 instanceof Document) 	
			return documentSimilarity.computeSimilarity((Document)o1, (Document)o2);
		else 
			return 0.0;
	}

	@Override
	public Iterator<Synset> iterator() {
		return this.synsets.iterator();
	}
	
	/**
	 * Restituisce la mappa in cui ad ogni lemma corrisponde l'id del synset corrispondente.
	 * @return mappa lemmaToId
	 */
	public Map<String, String> getMapLemmaToId()
	{
		Map<String, String> lemmaToId = new HashMap<>();
		
		for (Synset s : synsets)
			for (String lemma : s.getLemmas())
				lemmaToId.put(lemma, s.getID());
		
		return lemmaToId;
	}
	
	/**
	 * Restituisce l'insieme dei synset in relazione con quello dato in input.
	 * @param id synset di cui si cercano gli adiacenti
	 * @return insieme degli adiacenti a id
	 */
	public Set<String> getRelatedSynsets (String id)
	{
		return relationsMap.getOrDefault(id, List.of()).stream()
														.map(relation -> relation.split("_")[0])
														.collect(Collectors.toSet());
	}

	/**
	 * Restituisce l'insieme dei synset in relazione con quello dato in input e del tipo uguale a quello in input
	 * @param id synset di cui si cercano gli adiacenti
	 * @param type tipo di relazione attraverso cui si vogliono filtrare gli adiacenti
	 * @return insieme degli adiacenti a id di tipo type
	 */
	public Set<String> getRelatedSynsets (String id, RelationType type)
	{
		return relationsMap.getOrDefault(id, List.of()).stream()
														.filter(relation -> relation.split("_")[1].equals(type.toString()))
														.map(relation -> relation.split("_")[0])
														.collect(Collectors.toSet());
	}
}
