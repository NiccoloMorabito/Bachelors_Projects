package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.*;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che genera un rapporto sugli istituti frequentati dagli studenti.
 * 
 * A ciascun istituto in cui almeno uno studente si è diplomato corrisponde il numero di studenti diplomati in quell'istituto.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.ISTITUTI)
public class AnalizzatoreIstituti extends AnalizzatorePadre
{	
	/**
	 * Genera un rapporto la cui funzione toString() rappresenta le statistiche sugli istituti ordinate in maniera decrescente per numero di studenti diplomati in quell'istituto; ad esempio:
	 * {ISTITUTI={ALTRO=16, LABRIOLA=14, ecc. ecc.}}
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		Map<String, Integer> temp = new HashMap<>();
		
		for (Studente stud : studs)
			temp.put(stud.getIstitutoSuperiore(), temp.getOrDefault(stud.getIstitutoSuperiore(), 0) + 1);
		
		return new Rapporto(ordinaMappaPerValoriDecrescenti(temp), this.getTipo());
	}
	
}
