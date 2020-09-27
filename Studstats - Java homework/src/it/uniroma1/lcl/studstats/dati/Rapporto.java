package it.uniroma1.lcl.studstats.dati;

import java.util.*;

/**
 * Classe che memorizza il tipo di rapporto e le informazioni calcolate dagli analizzatori che la utilizzano.
 * 
 * @author Niccolò Morabito
 *
 */
public class Rapporto
{
	/**
	 * Mappa che contiene i dati dell'analisi effettuata dall'analizzatore.
	 */
	public Map<?,?> mappaRapporto;
	/**
	 * Campo che rappresenta il tipo di rapporto che è stato generato.
	 */
	private TipoRapporto tipo;
	
	/**
	 * Costruttore della classe Rapporto.
	 * 
	 * @param mappa 
	 * @param tipo
	 */
	public Rapporto(Map<?,?> mappa, TipoRapporto tipo ) { this.tipo = tipo; this.mappaRapporto = mappa; }
	
	@Override
	public String toString() { return "{" + this.tipo + "=" + this.mappaRapporto + "}"; }

}
