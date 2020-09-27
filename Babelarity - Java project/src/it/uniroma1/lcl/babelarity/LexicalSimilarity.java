package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarità tra parole.
 * 
 * Ciascun algoritmo per il calcolo della similarità tra parole deve implementare questa interfaccia.
 * 
 * @author Niccolò Morabito
 *
 */
@FunctionalInterface
public interface LexicalSimilarity
{
	double computeSimilarity(Word w1, Word w2);
}
