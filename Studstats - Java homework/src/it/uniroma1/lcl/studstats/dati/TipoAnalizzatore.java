package it.uniroma1.lcl.studstats.dati;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Annotazione il cui metodo value() restituisce il tipo di rapporto (enum Tipo), specifico per ogni analizzatore.
 * 
 * @author Niccolò Morabito
 *
 */
@Retention(RetentionPolicy.RUNTIME)
public @interface TipoAnalizzatore
{
	/**
	 * Metodo per avere a runtime il tipo della classe su cui viene applicata l'annotazione.
	 * 
	 * @return il Tipo del rapporto che la classe Analizzatore a cui è legata pò generare.
	 */
	public Tipo value() default Tipo.SESSO;
}