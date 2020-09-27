package it.uniroma1.lcl.babelarity;

/**
 * Enum che contiene tutti i tipi di relazione presenti all'interno della rete semantica MiniBabelNet.
 * 
 * @author Niccolò Morabito
 *
 */
public enum RelationType
{
	ISA("is-a"), HASKIND("has-kind"), PARTOF("part-of"), HASPART("has-part"),
	GLOSSRELATED("gloss-related"), RELATED("related");
	
	/**
	 * Parola chiave che indica il tipo di relazione in MiniBabelNet
	 */
    private String keyword;
    
    /**
     * Costruttore di RelationType.
     * 
     * @param keyword parola chiave che indica il tipo di relazione in MiniBabelNet
     */
    private RelationType(String keyword)
    { 
        this.keyword = keyword; 
    } 
    
    @Override 
    public String toString()
    { 
        return keyword; 
    }   
}
