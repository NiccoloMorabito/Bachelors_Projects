package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarit� tra parole.
 * 
 * Ciascun algoritmo per il calcolo della similarit� tra parole deve implementare questa interfaccia.
 * 
 * @author Niccol� Morabito
 *
 */
@FunctionalInterface
public interface LexicalSimilarity
{
	double computeSimilarity(Word w1, Word w2);
}
