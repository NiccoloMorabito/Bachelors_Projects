package it.uniroma1.lcl.studstats.dati;

import java.util.*;
import java.util.stream.Collectors;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che genera un rapporto utilizzando un AnalizzatorePadre e un voto minimo.
 * Il risultato abbina alle chiavi del rapporto originale i valori delle percentuali di studenti con voto maggiore o uguale a quello minimo rispetto al totale che rispetta quel parametro.
 * 
 * Accetta solo analizzatori di tipo AnalizzatorePadre.
 * 
 * Gli analizzatori che implementano l'interfaccia ModificatorePercentuali, producono un rapporto che segnala l'incremento rispetto all'analizzatore applicato su tutti gli studenti (in forma percentuale); le percentuali dei rapporti prodotti con gli altri analizzatori derivano dal rapporto tra il numero di studenti idonei e il numero di studenti totali su ciascun parametro del rapporto.
 * 
 * @author Niccolò Morabito
 */
@TipoAnalizzatore(Tipo.PERCENTUALE)
public class AnalizzatoreBonus extends AnalizzatoreCombinato
{	
	/**
	 * Costruttore dell'AnalizzatoreBonus che prende un solo parametro come input.
	 * L'AnalizzatorePadre viene posto automaticamente uguale ad AnalizzatoreSesso.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 */
	public AnalizzatoreBonus(int voto) { super(voto); }
	
	/**
	 * Costruttore dell'AnalizzatoreBonus che prende due parametri come input.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 * @param a analizzatore attraverso cui si vuole generare il rapporto; verrà generato solo per gli studenti idonei.
	 */
	public AnalizzatoreBonus(int voto, AnalizzatorePadre a) { super(voto, a); }
	
	/**
	 * Genera un rapporto la cui funzione toString() rappresenta le statistiche dell'analizzatore nel campo (applicato solo sugli studenti con voto maggiore al voto con cui è costruito l'oggetto) sottoforma di percentuali:
	 * • in tutti gli analizzatori di tipo AnalizzatorePadree la percentuale corrispondente a ciascuna chiave K è ottenuta confrontando il numero di studenti idonei per K con il numero di studenti totale per K;
	 * • per gli analizzatori che implementano l'interfaccia ModificatorePercentuali, le percentuali rappresentano l'incremento dei valori del rapporto sugli studenti idonei per ciascuna chiave rispetto al rapporto ottenuto su tutti gli studenti.
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		Rapporto rapportoIdonei = new AnalizzatoreStudentiVotoMaggiore(this.votoMin, this.analizzatore)
																		.generaRapporto(studs);
		Rapporto rapportoTotali = this.analizzatore.generaRapporto(studs);
		
		LinkedHashMap<String, String> mappaTemp = new LinkedHashMap<>();
		
		for (Map.Entry<?, ?> entryIdonei : rapportoIdonei.mappaRapporto.entrySet())
		{
			Double k1 = Double.parseDouble(entryIdonei.getValue().toString());
			Double k2 = Double.parseDouble(rapportoTotali.mappaRapporto.get(entryIdonei.getKey()).toString());
			
			String value = "";
			if (this.analizzatore instanceof ModificatorePercentuali)
			{
				value += Math.round((k1 - k2)/k2 *100);
			}
			else value += Math.round(k1 / k2 *100);
	
			mappaTemp.put(entryIdonei.getKey().toString(), value);
		}
		
		mappaTemp = mappaTemp.entrySet().stream()
						.sorted(Map.Entry.<String, String>comparingByValue().reversed())
						.collect(Collectors.toMap (Map.Entry::getKey,
													e -> e.getValue()+"%",
													(a, b) -> b,
													LinkedHashMap::new));
		
		return new Rapporto(mappaTemp, this.getTipo());
	}
}