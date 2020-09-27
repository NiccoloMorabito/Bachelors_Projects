package it.uniroma1.lcl.babelarity;

/**
 * Interfaccia funzionale per la similarit� tra documenti.
 * 
 * Ciascun algoritmo per il calcolo della similarit� tra documenti deve implementare questa interfaccia.
 * 
 * @author Niccol� Morabito
 *
 */
@FunctionalInterface
public interface DocumentSimilarity 
{
	double computeSimilarity(Document d1, Document d2);
}
