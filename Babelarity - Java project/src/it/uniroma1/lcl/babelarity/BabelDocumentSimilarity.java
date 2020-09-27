package it.uniroma1.lcl.babelarity;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Classe per il calcolo della similarità tra documenti attraverso l'algoritmo avanzato costruzione del grafo semantico + RandomWalk.
 * 
 * @author Niccolò Morabito
 *
 */
public class BabelDocumentSimilarity implements DocumentSimilarity
{
	private Map<String, String> lemmaToId;
	private final static double restartProbability = 0.20;
	private final static int maxIteration = 500000;
	
	/**
	 * Calcola il valore di similarità tra due documenti.
	 * @param d1 primo documento
	 * @param d2 secondo documento
	 * @return valore di similarità tra i due documenti
	 */
	public double computeSimilarity(Document d1, Document d2)
	{
		if (lemmaToId==null) lemmaToId = MiniBabelNet.getInstance().getMapLemmaToId();
		
		// Mappe risultati dall'esecuzione del RandomWalk sul grafo corrispondente
		Map<String, Integer> m1 = getMapOfRandomWalk(d1.getContent());
		Map<String, Integer> m2 = getMapOfRandomWalk(d2.getContent());
		
		// intersezione dei synset dei due documenti
		Set<String> intersection = new HashSet<>(m1.keySet());
		intersection.retainAll(m2.keySet());
		
		// unione dei synset dei due documenti
		Set<String> union = new HashSet<>();
		union.addAll(m1.keySet());
		union.addAll(m2.keySet());

		// indici
		int u = 0;
		int d = intersection.size();
		int t = m1.keySet().size();
		
		// costruzione dei due vettori rappresentanti i corrispondenti documenti
		int length = union.size();
		double[] vector1 = new double[length];
		double[] vector2 = new double[length];
		for (String id : union)
		{
			if (m1.keySet().contains(id) && m2.keySet().contains(id))
			{
				vector1[u] = m1.get(id);
				vector2[u] = m2.get(id);
				u++;
			}
			else if (m1.keySet().contains(id))
			{
				vector1[d] = m1.get(id);
				vector2[d] = 0;
				d++;
			}
			else if (m2.keySet().contains(id))
			{
				vector1[t] = 0;
				vector2[t] = m2.get(id);
				t++;
			}
		}
		
		return CosineSimilarity.computeCosineSimilarity(vector1, vector2);
	}

	/**
	 * Dopo aver costruito il grafo semantico corrispondente al testo passato in input, il metodo restituisce la mappa rappresentante il risultato dell'algoritmo RandomWalk eseguito sul grafo suddetto.
	 * @param txt testo del documento
	 * @return mappa idSynset -> valoreDiOccorrenza (valoreDiOccorrenza ottenuto dal RandomWalk)
	 */
	private Map<String, Integer > getMapOfRandomWalk(String txt)
	{
		Set<String> words = new HashSet<>(Arrays.asList(txt.replaceAll("[^a-zA-Z- ]", " ").toLowerCase().split("\\s+")));
		Map<String, Set<String>> synsetToRelateds = new HashMap<>();
		MiniBabelNet mbn = MiniBabelNet.getInstance();
		
		// COSTRUZIONE DEL GRAFO SEMANTICO DEL DOCUMENTO txt
		for (String word : words)
		{
			String synset = lemmaToId.get(mbn.getLemmas(word).get(0));
			if (synset != null)
				synsetToRelateds.put(synset, new HashSet<>());
		}
		Set<String> allSynsetsInDocument = new HashSet<>(synsetToRelateds.keySet());
		for (String synset : synsetToRelateds.keySet())
		{
			// aggiungo gli adiacenti a synset in synsetToRelateds solo se sono anch'essi contenuti nel documento
			for (String related : mbn.getRelatedSynsets(synset))
			{
				if (synsetToRelateds.containsKey(related))
				{
					synsetToRelateds.get(synset).add(related);
					if (allSynsetsInDocument.contains(synset))
						allSynsetsInDocument.remove(synset);
				}
			}
		}
		// per i restanti nodi non connessi effettuo una visita BFS a distanza massima 2 
		// se durante la ricerca visito un nodo presente nel documento aggiungo un arco diretto tra quest'ultimo e il nodo sorgente
		for (String synset : allSynsetsInDocument)
			for (String related : mbn.getRelatedSynsets(synset))
				for (String deeperRelated : mbn.getRelatedSynsets(related))
					if (synsetToRelateds.containsKey(deeperRelated))
						synsetToRelateds.get(synset).add(deeperRelated);

		// RANDOM WALK
		// le informazioni del grafo appena costruito sono contenute in synsetsToRelateds
		// il risultato del RandomWalk sarà contenuto nella mappa idToOccurrences
		List<String> nodes = synsetToRelateds.keySet().stream().collect(Collectors.toList());
		Random random = new Random();
		int index = random.nextInt(nodes.size());
		int max = maxIteration;		
		Map<String, Integer> idToOccurrences = new HashMap<>();			
		for (String s : nodes)										
			idToOccurrences.put(s, 0);							

		while (max > 0)
		{
			float restart = random.nextFloat();
			if (restart > restartProbability)
				index = random.nextInt(nodes.size());
			
			String idNode = nodes.get(index);
			idToOccurrences.put(idNode, idToOccurrences.get(idNode)+1);
			
			Object[] neighbors = synsetToRelateds.get(idNode).toArray();
			if (neighbors.length>0)
			{
				String neighbor = (String)neighbors[random.nextInt(neighbors.length)];
				index = nodes.indexOf(neighbor);
			}
			else
				index = random.nextInt(nodes.size());
			max--;
		}
		
		return idToOccurrences;	
	}

}
