package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che genera un rapporto sui titoli di studio conseguiti dagli studenti.
 * 
 * A ciascun titolo di studio che almeno uno studente ha conseguito corrisponde il numero di studenti con quell'istituto.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.TITOLO)
public class AnalizzatoreTitoloDiStudio extends AnalizzatorePadre
{	
	/**
	 * Genera un rapporto la cui funzione toString() rappresenta le statistiche sui titoli di studio degli studenti ordinati in ordine decrescente di valore.
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		Map<String, Integer> temp = new HashMap<>();
		
		for (Studente stud : studs)
			temp.put(stud.getTitoloDiStudio(), temp.getOrDefault(stud.getTitoloDiStudio(), 0) + 1);
		
		return new Rapporto(ordinaMappaPerValoriDecrescenti(temp), this.getTipo());
	}
	
}
