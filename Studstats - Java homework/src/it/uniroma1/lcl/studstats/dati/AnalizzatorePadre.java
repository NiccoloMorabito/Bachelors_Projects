package it.uniroma1.lcl.studstats.dati;

import java.util.*;
import java.util.stream.Collectors;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Classe astratta padre di un analizzatore generico esclusi gli analizzatori di tipo AnalizzatorePadre.
 * 
 * @author Niccolò Morabito
 */
public abstract class AnalizzatorePadre implements Analizzatore
{
	/**
	 * Ordina la mappa ricevuta in input in maniera decrescente per valori.
	 * 
	 * @param map mappa da ordinare decrescentemente
	 * @return mappa ordinata
	 */
	protected static Map<String, Integer> ordinaMappaPerValoriDecrescenti(Map<String, Integer> map)
    {
    	return map.entrySet().stream()
				.sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
				.collect(Collectors.toMap(Map.Entry::getKey,
											Map.Entry::getValue,
											(a,b) -> a,
											LinkedHashMap::new));
    }
    
	@Override
	public abstract Rapporto generaRapporto(Collection<Studente> studs);
	
	@Override
	public boolean equals(Object o)
	{
		if (this==o) return true;
		if (o==null || this.getClass()!=o.getClass()) return false;
		Analizzatore a = (AnalizzatorePadre)o;
		return this.getTipo().equals(a.getTipo());
	}
	
	@Override
	public int hashCode() { return Objects.hash(this.getTipo()); }
	
}
