package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarità tra synset.
 * 
 * Ciascun algoritmo per il calcolo della similarità tra synset deve implementare questa interfaccia.
 * 
 * @author Niccolò Morabito
 *
 */
@FunctionalInterface
public interface SemanticSimilarity
{
	double computeSimilarity(Synset s1, Synset s2);
}
