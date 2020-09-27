package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarità tra documenti.
 * 
 * Ciascun algoritmo per il calcolo della similarità tra documenti deve implementare questa interfaccia.
 * 
 * @author Niccolò Morabito
 *
 */
@FunctionalInterface
public interface DocumentSimilarity 
{
	double computeSimilarity(Document d1, Document d2);
}
