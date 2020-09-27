package it.uniroma1.lcl.babelarity;

/**
 * Classe per il calcolo della Cosine Similarity.
 * 
 * @author Niccolò Morabito
 *
 */
public class CosineSimilarity
{
	/**
	 * Metodo che, presi due vettori, ne restituisce la cosine similarity.
	 * 
	 * @param vector1
	 * @param vector2
	 * @return il valore di cosine similarity tra i due vettori
	 */
	public static double computeCosineSimilarity(double[] vector1, double[] vector2)
	{
		double sommaProdotti = 0;
		double sommaQuadrati1 = 0;
		double sommaQuadrati2 = 0;
		
		for (int i=0; i<vector1.length; i++)
		{
			double i1 = vector1[i];
			double i2 = vector2[i];
			sommaProdotti += i1*i2;
			sommaQuadrati1 += i1*i1;
			sommaQuadrati2 += i2*i2;
		}
		
		return sommaProdotti / (Math.sqrt(sommaQuadrati1 ) * Math.sqrt(sommaQuadrati2));
	}
}
