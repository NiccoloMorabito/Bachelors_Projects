package it.uniroma1.lcl.babelarity;

import java.util.List;
import java.util.Set;

/**
 * Un synset è composto da un ID, da una Part Of Speech (POS), dai lemmi che corrispondono all'insieme dei syn associati a quell'id e da un certo numero di definizioni.
 * 
 * @author Niccolò Morabito
 *
 */
public interface Synset extends LinguisticObject
{
	/**
	 * Restituisce l'ID del synset
	 * @return id
	 */
	String getID();
	
	/**
	 * Restituisce la part of speech del synset
	 * @return POS
	 */
	PartOfSpeech getPOS();
	
	/**
	 * Restituisce l'insieme dei lemmi
	 * @return lemmas
	 */
	Set<String> getLemmas();
	
	/**
	 * Restituisce la lista delle definizioni
	 * @return glosses
	 */
	List<String> getGlosses();
}
