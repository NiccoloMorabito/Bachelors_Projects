package it.uniroma1.lcl.studstats;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

import it.uniroma1.lcl.studstats.dati.Analizzatore;
import it.uniroma1.lcl.studstats.dati.Rapporto;
import it.uniroma1.lcl.studstats.dati.Tipo;
import it.uniroma1.lcl.studstats.dati.TipoRapporto;

/**
 * Classe i cui oggetti vengono costruiti attraverso il metodo statico fromFile.
 * Raccoglie le informazioni sullo studio che si sta facendo, in particolar modo gli studenti che si stanno analizzando e gli analizzatori che possono essere utilizzati.
 * 
 * @author Niccolò Morabito
 *
 */
public class Studstats implements AggregatoreStatistico
{
	/**
	 * Carattere di separazione nelle righe del file con cui viene costruita l'istanza.
	 */
	private static final String SEPARATORE = ";";
	/**
	 * Lista contenente tutti gli studenti del file e quelli aggiunti attraverso il metodo add(Studente s).
	 */
	private ArrayList<Studente> listaStudenti;
	/**
	 * Insieme contente tutti gli analizzatori disponibili per l'istanza.
	 */
	private LinkedHashSet<Analizzatore> insiemeAnalizzatori;
	
	/**
	 * Costrutture della classe che, preso il nome del file in input, genera gli studenti contenuti al suo interno e li aggiunge al campo della classe listaStudenti dividendo ciascuna riga tramite il carattere ";".
	 * 
	 * @param nomeFile il percorso del file da analizzare
	 */
	private Studstats (Path pathFile)
	{
		this.insiemeAnalizzatori = new LinkedHashSet<>();
		this.listaStudenti = new ArrayList<Studente>();
		
		try(BufferedReader br = Files.newBufferedReader(pathFile))
		{
			br.readLine(); 				// si salta la prima riga in quanto non contiene dati di alcun studente
			
			while(br.ready())
				this.add(new Studente (br.readLine().split(SEPARATORE)));
		}
		catch(IOException e)
		{
			System.out.println("Il fine non è valido.");
		}
	}
	
	@Override
    public void add(Analizzatore an) { this.insiemeAnalizzatori.add(an); }

	@Override
    public void add(Studente s) { this.listaStudenti.add(s); }
	
	/**
	 * Overloading del metodo generaRapporti (TipoRapporto... tipiRapporto) con 0 tipi aggiunti.
	 * Il metodo restituisce la lista dei rapporti generati dagli analizzatori aggiunti al momento della chiamata.
	 * @return listaRapporti lista dei rapporti generati
	 */
	public List<Rapporto> generaRapporti ()
	{
		ArrayList<Rapporto> listaRapporti = new ArrayList<>();
		for (Analizzatore a : this.insiemeAnalizzatori)
			listaRapporti.add(a.generaRapporto(this.listaStudenti));
		return listaRapporti;
	}
	
	/**
	 * Per ciascun TipoRapporto preso in input, richiama l'analizzatore corrispondente, esegue il rapporto attraverso il metodo implementato generaRapporto e restituisce la lista dei rapporti generati in questa maniera.
	 * 
	 * @param tipiRapporto, array di tipi che implementano la classe TipoRapporto.
	 * 
	 * @return lsta dei rapporti generati dagli analizzatori corrispondenti ai tipiRapporto in input.
	 */
	@Override
	public List<Rapporto> generaRapporti (TipoRapporto... tipiRapporto)
	{
		ArrayList<Rapporto> listaRapporti = new ArrayList<>();
		
		if (tipiRapporto.length==0) this.generaRapporti();
		
		for (Analizzatore an : this.insiemeAnalizzatori)
			for (TipoRapporto tipo : tipiRapporto)
				if (((Tipo)an.getTipo()).equals(tipo)) listaRapporti.add(an.generaRapporto(this.listaStudenti));
		
		return listaRapporti;
	}
    
	/**
	 * Preso in input il percorso di un file F sottoforma di stringa, genera l'istanza costruita con i dati di F.
	 * Il formato del file è: una riga per studente con i campi separati dal carattere ";".
	 * 
	 * @param nomeFile percorso del file da analizzare
	 * @return istanza di Studstats costruita con i dati del file richiesto
	 */
	public static Studstats fromFile(String nomeFile) { return new Studstats (Paths.get(nomeFile)); }
	
	/**
	 * Preso in input il percorso di un file F sottoforma di oggetto Path, genera l'istanza costruita con i dati di F.
	 * Il formato del file è: una riga per studente con i campi separati dal carattere ";".
	 * 
	 * @param path percorso del file
	 * @return istanza di Studstats costruita con i dati del file richiesto
	 */
	public static Studstats fromFile(Path path) { return new Studstats (path); }

	@Override
	public int numeroAnalizzatori() { return this.insiemeAnalizzatori.size(); }
	
}
