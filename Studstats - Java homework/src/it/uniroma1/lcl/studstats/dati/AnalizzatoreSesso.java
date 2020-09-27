package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.LinkedHashMap;

import it.uniroma1.lcl.studstats.Studente;
import it.uniroma1.lcl.studstats.Studente.Sesso;

/**
 * Analizzatore che genera un rapporto sul sesso degli studenti, a ciascuno dei quali appartiene il numero di studenti di quel sesso.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.SESSO)
public class AnalizzatoreSesso extends AnalizzatorePadre
{
	/**
	 * Genera un rapporto la cui funzione toString() rappresenta le statistiche sul sesso degli studenti.
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		LinkedHashMap<Sesso, Integer> map = new LinkedHashMap<>();
		map.put(Sesso.F, 0);
		map.put(Sesso.M, 0);
		
		for (Studente stud : studs)
			map.put(stud.getSesso(), (Integer)map.get(stud.getSesso()) + 1);
		
		return new Rapporto(map, this.getTipo());
	}

	
}
