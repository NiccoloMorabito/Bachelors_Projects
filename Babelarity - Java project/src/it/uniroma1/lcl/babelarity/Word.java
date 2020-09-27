package it.uniroma1.lcl.babelarity;

/**
 * Classe che rappresenta una parola in MiniBabelNet.
 * 
 * @author Niccolò Morabito
 *
 */
public class Word implements LinguisticObject
{
	private String value;
	
	/**
	 * Costruttore di Word
	 * @param s stringa rappresentante una parola
	 */
	private Word(String s)
	{
		this.value = s;
	}
	
	/**
	 * Restituisce la word corrispondente alla stringa passata in input.
	 * @param s stringa di cui si vuole ottenere la Word corrispondente
	 * @return istanza di Word corrispondente
	 */
	static Word fromString(String s) 
	{
		return new Word(s);
	}
	
	@Override
	public String toString()
	{
		return this.value;
	}
}
