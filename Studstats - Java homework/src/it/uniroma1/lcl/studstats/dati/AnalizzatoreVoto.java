package it.uniroma1.lcl.studstats.dati;

import java.util.*;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che genera un rapporto sui voti di diploma ottenuti dagli studenti.
 * 
 * In particolare, vengono generati i seguenti dati: voto medio, voto massimo, voto minimo e voto mediano.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.VOTO)
public class AnalizzatoreVoto extends AnalizzatorePadre implements ModificatorePercentuali
{
	public static final TipoRapporto tipo = Tipo.VOTO;
	
	/**
	 * Genera un rapporto la cui funzione toString restituisce il voto medio, il voto massimo, il voto minimo e il voto mediano analizzando la lista di studenti che riceve in input.
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		ArrayList<Integer> listaVoti = new ArrayList<>();
		double totale = 0;
		
		for (Studente stud : studs)
		{
			listaVoti.add(stud.getVoto());
			totale+=stud.getVoto();
		}
			
		
		Collections.sort(listaVoti, (x,y) -> {return x-y;} );
		
		LinkedHashMap<String, Number> map = new LinkedHashMap<>();
	
		map.put("VOTO_MEDIO", (double)(Math.round(totale/listaVoti.size()*100))/100);
		map.put("VOTO_MAX", Collections.max(listaVoti));
		map.put("VOTO_MIN", Collections.min(listaVoti));
		map.put("VOTO_MEDIANO", listaVoti.get(listaVoti.size()/2));
		
		return new Rapporto(map, this.getTipo());

	}

}
