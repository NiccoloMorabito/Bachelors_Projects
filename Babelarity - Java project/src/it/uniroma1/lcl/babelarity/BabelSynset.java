package it.uniroma1.lcl.babelarity;

import java.util.List;
import java.util.Set;

/**
 * Un BabelSynset è composto da un ID, da una Part Of Speech (POS), dai lemmi che corrispondono all'insieme dei syn associati a quell'id e da un certo numero di definizioni.
 * 
 * @author Niccolò Morabito
 *
 */
public class BabelSynset implements Synset
{
	private String ID;
	private Set<String> lemmas;	
	private List<String> glosses;
	
	/**
	 * Costruttore che prende in input l'id, i lemmi e le definizioni.
	 * 
	 * @param ID
	 * @param lemmas
	 * @param glosses
	 */
	public BabelSynset(String ID, Set<String> lemmas, List<String> glosses)
	{ 
		this.ID = ID;
		this.lemmas = lemmas;
		this.glosses = glosses;
	}
	
	/**
	 * Restituisce l'id univoco del synset sotto forma di stringa.
	 * Gli identificativi dei synset seguono il formato 
	 * bn:00000000n, dove l’ultimo carattere rappresenta la parte del discorso del concetto n(oun), v(erb), a(djective), (adve)r(b).
	 * @return ID del synset
	 */
	public String getID() { return this.ID; }
	
	/**
	 * Restituisce la parte del discorso (Part-of-Speech) del synset NOUN, ADV, ADJ, VERB.
	 * @return POS del synset
	 */
	public PartOfSpeech getPOS()
	{
		char letter = this.ID.charAt(this.ID.length()-1);
		return PartOfSpeech.getPartOfSpeechFor(letter);
	}
	
	/**
	 * Restituisce l’insieme delle lessicalizzazioni di cui è composto il synset.
	 * @return lemmi del synset
	 */
	public Set<String> getLemmas() { return this.lemmas; }
	
	/**
	 * Restituisce le definizioni del synset.
	 * @return definizioni del synset
	 */
	public List<String> getGlosses() { return this.glosses; }
	
	
}
