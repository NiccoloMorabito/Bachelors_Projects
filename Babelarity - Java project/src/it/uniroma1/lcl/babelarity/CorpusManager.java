package it.uniroma1.lcl.babelarity;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

/**
 * Classe per la gestione dei documenti, iterabile sui file del CORPUS e in grado di salvare, caricare e parsare documenti.
 * 
 * Implementa il Singleton.
 * 
 * @author Niccolò Morabito
 *
 */
public class CorpusManager implements Iterable<File>
{
	private static CorpusManager istance;
	private List<Document> documenti;
	private static final String CORPUS = 		"resources/corpus/";
	
	/**
	 * Costruttore privato di CorpusManager
	 */
	private CorpusManager()
	{
		this.documenti 	= new ArrayList<>();
	}
	
	/**
	 * Se l'istanza di CorpusManager non è stata ancora creata, la crea.
	 * Restiuisce l'istanza di CorpusManager.
	 * 
	 * @return l'unica istanza di CorpusManager
	 */
	public static CorpusManager getInstance() {
		if (istance == null)
			istance = new CorpusManager();
		return istance;
	}
	
	/**
	 * Restituisce una nuova istanza di Document parsando un file di testo di cui è fornito il percorso in input.
	 * [ Ogni documento fornito è così strutturato: nella prima linea è presente il titolo e l’ID del documento separati da TAB. Il resto del documento rappresenta il contenuto testuale. ]
	 * @param path percorso del documento
	 * @return istanza di Document
	 */
	public Document parseDocument(Path path)
	{
		Document d = new Document(path);
		this.documenti.add(d);
		return d;
	}
	
	/**
	 * Carica da disco l’oggetto Document identificato dal suo ID.
	 * @param id del documento
	 * @return istanza del documento corrisponente a id
	 */
	public Document loadDocument(String id)
	{
		for (Document d : this.documenti)
			if (d.getId().equals(id))
				return d;
		return null;
	}
	
	/**
	 * Salva su disco l’oggetto Document passato in input.
	 * @param document da salvare in memoria
	 */
	public void saveDocument(Document document)
	{
		try (PrintWriter out = new PrintWriter("resources/documents/" + document.getTitle() + ".txt"))
		{
			String text = document.getTitle() + "\t" + document.getId() + "\n" + document.getContent();
		    out.println(text);
		}
		catch (FileNotFoundException e)
		{
			System.out.println("Il salvataggio del documento '" + 
										document.getTitle() + "' non è andato a buon fine");
		}
	}

	@Override
	public Iterator<File> iterator()
	{
		return Arrays.asList(new File(CORPUS).listFiles()).iterator();
	}
	
	/**
	 * Restituisce il numero di file presenti nella cartella CORPUS
	 * @return numero di file presenti nella cartella CORPUS
	 */
	public int getNumberOfCorpusFiles()
	{
		return new File(CORPUS).listFiles().length;
	}
	
}
	
