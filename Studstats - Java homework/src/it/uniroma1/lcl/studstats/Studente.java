package it.uniroma1.lcl.studstats;

import java.util.LinkedHashMap;

/**
 * Classe le cui istanze sono gli studenti generati da Studstats.
 * 
 * @author Niccolò Morabito
 *
 */
public class Studente
{
	/**
	 * Enum per identificare il sesso dello studente.
	 */
	public enum Sesso {M, F}
	
	/**
	 * Mappa in cui il costruttore definisce le 8 chiavi costanti e associa loro i valori specifici di ogni studente.
	 */
	private LinkedHashMap<String, String> campi;
	/**
	 * Chiave a cui corrisponde il sesso dello studente.
	 */
	private static final String SESSO = "Sesso";
	/**
	 * Chiave a cui corrisponde la nazione di nascita dello studente.
	 */
	private static final String NAZIONE = "Nazione di nascita";
	/**
	 * Chiave a cui corrisponde la regione di nascita dello studente.
	 */
	private static final String REGIONE = "Regione di nascita";
	/**
	 * Chiave a cui corrisponde la provincia di nascita dello studente.
	 */
	private static final String PROVINCIA = "Provincia di nascita";
	/**
	 * Chiave a cui corrisponde il titolo di studio ottenuto dallo studente.
	 */
	private static final String TITOLO = "Titolo di studio";
	/**
	 * Chiave a cui corrisponde l'istituto frequentato dallo studente.
	 */
	private static final String ISTITUTO = "Nome istituto";
	/**
	 * Chiave a cui corrisponde il comune nel quale è sito l'istituto frequentato dallo studente.
	 */
	private static final String COMUNE = "Comune istituto";
	/**
	 * Chiave a cui corrisponde il voto con cui lo studente si è diplomato.
	 */
	private static final String VOTO = "Voto diploma";
	/**
	 * Chiave a cui corrisponde l'anno in cui lo studente si è diplomato.
	 */
	private static final String ANNO = "Anno diploma";
	
	
	/**
	 * Costruttore di uno studente che, presa in input una riga splittata del file da analizzare, crea una mappa che, per ciascuna stringa costante definita nella classe, asocia il valore specifico dello studente che si sta costruendo.
	 * 
	 * @param rigaSplittata array di stringhe contenente tutte le informazioni da inserire nei campi: sesso, nazione di nascita, regione di nascita, provincia di nascita, titolo, istituo, comune, voto, anno.
	 */
	public Studente (String[] rigaSplittata)
	{
		this.campi = new LinkedHashMap<>();
		
		campi.put(SESSO, rigaSplittata[0]);
		campi.put(NAZIONE, rigaSplittata[1]);
		campi.put(REGIONE, rigaSplittata[2]);
		campi.put(PROVINCIA, rigaSplittata[3]);
		campi.put(TITOLO, rigaSplittata[4]);
		campi.put(ISTITUTO, rigaSplittata[5]);
		campi.put(COMUNE, rigaSplittata[6]);
		campi.put(VOTO, rigaSplittata[7]);
		campi.put(ANNO, rigaSplittata[8]);
	}

	
	/**
	 * Getter dell'anno di diploma dello studente.
	 * 
	 * @return l'anno in cui lo studente si è diplomato.
	 */
	public int getAnnoDiploma() { return Integer.parseInt(campi.get(ANNO)); }

	
	/**
	 * Getter dell'istituo superiore in cui lo studente si è diplomato.
	 * 
	 * @return il nome dell'istituto in cui lo studente si è diplomato.
	 */
	public String getIstitutoSuperiore() { return campi.get(ISTITUTO); }
	
	
	/**
	 * Getter del sesso dello studente.
	 * 
	 * @return il sesso dello studente.
	 */
	public Studente.Sesso getSesso() { return Studente.Sesso.valueOf(campi.get(SESSO)); }
	
	
	/**
	 * Getter del titoo di studio ottenuto dallo studente.
	 * 
	 * @return il titolo di studio di cui dispone lo studente.
	 */
	public String getTitoloDiStudio() { return campi.get(TITOLO); }

	
	/**
	 * Getter del voto in centesimi con cui si è diplomato lo studente.
	 * 
	 * @return il voto in centesimi con cui si è diplomato lo studente.
	 */
	public int getVoto() { return Integer.parseInt(campi.get(VOTO)); }
	
}
