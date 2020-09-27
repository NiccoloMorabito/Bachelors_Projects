package it.uniroma1.lcl.studstats.dati;

/**
 * Definizione delle costanti che individuano i tipi di rapporto.
 * 
 * @author Niccolò Morabito
 */
public enum Tipo implements TipoRapporto
{
	/**
	 * Costante per AnalizzatoreAnnoDiploma
	 */
	ANNI_DIPLOMA,
	/**
	 * Costante per AnalizzatoreIstituti
	 */
	ISTITUTI,
	/**
	 * Costante per AnalizzatoreSesso
	 */
	SESSO,
	/**
	 * Costante per AnalizzatoreTitoloDiStudio
	 */
	TITOLO,
	/**
	 * Costante per AnalizzatoreVoto
	 */
	VOTO,
	/**
	 * Costante per AnalizzatoreStudentiVotoMaggiore
	 */
	VOTO_MAGGIORE,
	/**
	 * Costante per AnalizzatoreBonus
	 */
	PERCENTUALE;
}
