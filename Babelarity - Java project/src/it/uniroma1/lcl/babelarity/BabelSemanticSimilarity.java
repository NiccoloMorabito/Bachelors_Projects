package it.uniroma1.lcl.babelarity;

import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * Classe per il calcolo della similarità semantica (ovvero tra synset) attraverso l'algoritmo avanzato LHC.
 * 
 * Nel caso in cui l'algoritmo LHC non produca risultati per mancanze tra le relazioni di iperonimia e iponimia, si utilizza l'algoritmo base PATH.
 * 
 * @author Niccolò Morabito
 *
 */
public class BabelSemanticSimilarity implements SemanticSimilarity
{
	private Set<String> roots;
	private MiniBabelNet mbn;
	
	/**
	 * Calcola il valore di similarità semantica tra due synset.
	 * @param d1 primo synset
	 * @param d2 secondo synset
	 * @return valore di similarità tra i due synset
	 */
	public double computeSimilarity(Synset s1, Synset s2)
	{	
		this.roots = new HashSet<>();
		if (mbn==null) mbn = MiniBabelNet.getInstance();
		String id1 = s1.getID();
		String id2 = s2.getID();
		
		// partendo dalle mappe antenato->distanza corrispondenti ai due synset, ricavo LCS come il nodo in comune (ovvero LCS) tra i due synset e con distanza minore (ovvero lengthLCS)
		Map<String, Integer> ancestorToDistance1 = getUpperDistances(id1, 0, new HashMap<>());
		Map<String, Integer> ancestorToDistance2 = getUpperDistances(id2, 0, new HashMap<>());
		String lcs ="";
		int lengthLCS = Integer.MAX_VALUE;
		for (String antenato1 : ancestorToDistance1.keySet())
			if (ancestorToDistance2.containsKey(antenato1))
			{
				int percorso = ancestorToDistance1.get(antenato1) + ancestorToDistance2.get(antenato1);
				if (percorso<lengthLCS)
				{
					lcs = antenato1;
					lengthLCS = percorso;
				}
			}
		
		// se l'algoritmo LHC non ha trovato nessun percorso, restituisco il risultato ottenuto utilizzando l'algoritmo PATH
		if (lcs.length()==0 || lengthLCS==0)
			return 1.0 / (findPath(id1, id2) + 1.0); 
		
		// per ogni radice trovata durante la ricerca del LCS, mi calcolo la maxDepth e la aggiungo a maxDepths
		Set<Integer> maxDepths = new HashSet<>();
		for (String root : roots)
			maxDepths.add(findDepths(root, 0, new HashMap<>()).values()
																.stream()
																.mapToInt(i -> i)
																.max()
																.getAsInt()
																);
		// faccio la media tra le maxDepths trovate per ricavare il valore di maxDepth necessario per LHC
		double maxDepth = maxDepths.stream()
						            .mapToDouble(a -> a)
						            .average()
						            .getAsDouble();

		return -Math.log((double)lengthLCS / (double)( 2 * maxDepth ));
	}
	
	/**
	 * SIMILARITA' AVANZATA (LCH)
	 * 
	 * Metodo ricorsivo che, partendo dal synset dato in input, esplora l'albero superiore (relazioni is-a) inserendo nella mappa ancestorToDistance tutti gli antenati e la corrispondente distanza dal nodo di partenza
	 * @param id synset da cui si vuole salire
	 * @param passi numero rappresentante la distanza dal nodo iniziale
	 * @param ancestorToDistance mappa idAntenato -> distanzaDalNodoIniziale
	 * @return ancestorToDistance mappa idAntenato -> distanzaDalNodoIniziale
	 */
	private Map<String, Integer> getUpperDistances(String id, int passi, Map<String, Integer> ancestorToDistance)
	{
		Set<String> parents = mbn.getRelatedSynsets(id, RelationType.ISA);
		if (parents.isEmpty())
			roots.add(id);

		ancestorToDistance.put(id, passi);
		
		for (String parent : parents)
			if (!ancestorToDistance.containsKey(parent))
				getUpperDistances(parent, passi+1, ancestorToDistance);
		
		return ancestorToDistance;
	}
	
	/**
	 * Metodo ricorsivo che, partendo dal synset dato in input, esplora l'albero inferiore (relazioni has-kind) inserendo nella mappa synsetsToDepths tutti i discententi e la corrispondente distanza dal nodo di partenza
	 * @param id synset da cui si vuole scendere
	 * @param passi numero rappresentante la profondità dal nodo iniziale
	 * @param synsetToDepth mappa idDiscendente -> profonditàDalNodoIniziale
	 * @return synsetsToDepths mappa idDiscendente -> profonditàDalNodoIniziale
	 */
	private Map<String, Integer> findDepths(String id, int passi, Map<String, Integer> synsetToDepth)
	{
		synsetToDepth.put(id, passi);
		
		for (String child : mbn.getRelatedSynsets(id, RelationType.HASKIND))
			if (!synsetToDepth.containsKey(child))
				findDepths(child, passi+1, synsetToDepth);
		
		return synsetToDepth;
	}
	
	/**
	 * SIMILARITA' BASE (PATH)
	 * 
	 * Metodo che esegue l'algoritmo BFS per esplorare il grafo di MiniBabelNet (attraverso ogni tipo di relazione) dalla sorgente e si interrompe quando trova la destinazione, restituendo la distanza tra i due nodi.
	 * 
	 * @param source synset da cui l'algoritmo parte
	 * @param destination synset di arrivo
	 * @return distanza tra source e destination
	 */
	private int findPath (String source, String destination)
	{
		LinkedList<String> next = new LinkedList<>();
		next.add(source);
		Map<String, Integer> synToDistance = new HashMap<>();
		synToDistance.put(source, 0);
		
		while (!next.isEmpty())
		{
			String synset = next.remove(0);
	
			if (synset.equals(destination))
				return synToDistance.get(synset);
			
			for (String child : mbn.getRelatedSynsets(synset))
				if (!synToDistance.containsKey(child))
				{
					next.add(child);
					synToDistance.put(child, synToDistance.get(synset)+1);
				}
		}
		return 0;
	}	
}	