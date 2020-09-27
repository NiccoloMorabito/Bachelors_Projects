package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.TreeMap;
import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che genera un rapporto sugli anni del diploma degli studenti.
 * 
 * A ciascun anno in cui almeno uno studente si è diplomato corrisponde il numero di studenti diplomati in quell'anno.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.ANNI_DIPLOMA)
public class AnalizzatoreAnnoDiploma extends AnalizzatorePadre implements Analizzatore
{		
	/**
	 * Genera un rapporto la cui funzione toString() rappresenta le statistiche sull’anno di diploma nel seguente formato, ordinate per anno in ordine decrescente:
	 * {ANNI_DIPLOMA={2017=intero, 2016=intero, ecc., 2000=intero}}
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		TreeMap<Integer, Integer> map = new TreeMap<>((x, y) -> (y-x));
		
		for (Studente stud : studs)
			map.put(stud.getAnnoDiploma(), map.getOrDefault(stud.getAnnoDiploma(), 0)+1);
		
		return new Rapporto(map, this.getTipo());
	}
	
}
