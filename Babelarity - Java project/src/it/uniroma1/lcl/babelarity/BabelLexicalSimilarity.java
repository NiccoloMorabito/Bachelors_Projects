package it.uniroma1.lcl.babelarity;

/**
 * Classe per il calcolo della similarità lessicale (ovvero tra word) attraverso l'algoritmo avanzato vettorizzazione+cosine similarity.
 * 
 * @author Niccolò Morabito
 *
 */
public class BabelLexicalSimilarity implements LexicalSimilarity
{
	private static MiniBabelNet mbn;
	private static String[] allwords;
	private static final double numberOfCorpusFiles = 
								CorpusManager.getInstance().getNumberOfCorpusFiles();
	
	/**
	 * Calcola il valore di similarità tra due parole.
	 * @param w1 prima word
	 * @param w2 seconda word
	 * @return valore di similarità tra le due word
	 */
	public double computeSimilarity(Word w1, Word w2)
	{
		if (mbn==null) 
			mbn = MiniBabelNet.getInstance();
		if (allwords==null)
			allwords = mbn.getAllWords();

		return CosineSimilarity.computeCosineSimilarity(computeVector(w1), computeVector(w2));
	}
	
	/**
	 * Data una parola w, calcola il vettore di co-occorrenza all'interno dei file del corpus di MiniBabelNet.
	 * @param w parola di cui si vuole calcolare il vettore di co-occorrenza
	 * @return vettore di co-occorrenza di w
	 */
	private static double[] computeVector(Word w)
	{
		String string = w.toString();
		double[] vettore = new double[allwords.length];

		for (int i=0; i<allwords.length; i++)
			vettore[i] = computePMI(string, allwords[i]);
		return vettore;
	}
	
	/**
	 * Calcola il valore di PMI tra le due parole date in input. 
	 * Attraverso i vettori di booleani calcola i valori di frequenza delle due parole nei documenti del corpus in MiniBabelNet e produce il valore corrispondente di PMI.
	 * @param s1 prima parola
	 * @param s2 seconda parola
	 * @return PMI(s1,s2)
	 */
	private static double computePMI(String s1, String s2)
	{
		boolean[] occorrenzeS1 = mbn.getOccorrenze(s1);
		boolean[] occorrenzeS2 = mbn.getOccorrenze(s2);
		
		int freqX = 0;
		int freqY = 0;
		int freqXeY = 0;
		
		for (int i=0; i<occorrenzeS1.length; i++)
		{
			boolean n1 = occorrenzeS1[i];
			boolean n2 = occorrenzeS2[i];
			
			freqX += n1 ? 1 : 0;
			freqY += n2 ? 1 : 0;
			
			freqXeY += n1&&n2 ? 1 : 0;
		}
		
		double dfreqX = (freqX + 1) / numberOfCorpusFiles; 	
		double dfreqY = (freqY + 1) / numberOfCorpusFiles;
		double dfreqXeY = (freqXeY + 1) / numberOfCorpusFiles; 

		return Math.log(dfreqXeY / (double)(dfreqX * dfreqY));

	}
}
