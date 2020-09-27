package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;

import it.uniroma1.lcl.studstats.Studente;

@TipoAnalizzatore(Tipo.ISTITUTI)
public class AnalizzatoreSegretoSegretissimo extends AnalizzatorePadre
{	
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		LinkedHashMap<String, Integer> temp = new LinkedHashMap<>();
		
		for (Studente stud : studs)
			temp.put(stud.getIstitutoSuperiore(), temp.getOrDefault(stud.getIstitutoSuperiore(), 0) + 1);
		
		SortedSet<Map.Entry<String, Integer>> ordinaValore = new TreeSet<>(
				 new Comparator<Map.Entry<String, Integer>>()
				 {
		            @Override public int compare(Map.Entry<String,Integer> e1, Map.Entry<String,Integer> e2)
		            {
		                int res = e2.getValue().compareTo(e1.getValue());
		                return res != 0 ? res : 1;
		            }
				 }															);
		
		ordinaValore.addAll(temp.entrySet());
		
		temp.clear();
		
		for (Map.Entry<String, Integer> entry : ordinaValore)
			temp.put(entry.getKey(), entry.getValue());
		
		return new Rapporto(temp, this.getTipo());
		
	}

}
