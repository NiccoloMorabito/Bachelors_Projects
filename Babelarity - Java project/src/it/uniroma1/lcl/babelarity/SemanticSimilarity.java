package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarit� tra synset.
 * 
 * Ciascun algoritmo per il calcolo della similarit� tra synset deve implementare questa interfaccia.
 * 
 * @author Niccol� Morabito
 *
 */
@FunctionalInterface
public interface SemanticSimilarity
{
	double computeSimilarity(Synset s1, Synset s2);
}
