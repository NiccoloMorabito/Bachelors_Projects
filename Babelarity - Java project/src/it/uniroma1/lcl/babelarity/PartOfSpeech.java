package it.uniroma1.lcl.babelarity;

/**
 * Part of Speech a cui possono far parte i BabelSynset
 * 
 * @author Niccolò Morabito
 *
 */
public enum PartOfSpeech 
{
	NOUN('n'),
	VERB('v'),
	ADJ('a'),
	ADV('r');
	
	private char c;
	
	/**
	 * Costruttore di PartOfSpeech
	 * @param c carattere finale dell'id del BabelSynset
	 */
	private PartOfSpeech(char c) { this.c = c; }
	
	/**
	 * Restituisce la POS corrispondente al char c dato in input
	 * @param c carattere finale dell'id del BabelSynset
	 * @return POS corrispondente a c
	 */
	public static PartOfSpeech getPartOfSpeechFor(char c)
	{
		for (PartOfSpeech pos : PartOfSpeech.values())
			if (pos.c == c)
				return pos;
		return null;
	}
}
