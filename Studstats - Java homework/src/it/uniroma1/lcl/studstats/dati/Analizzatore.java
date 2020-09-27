package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Interfaccia che ogni analizzatore implementa.
 * 
 * @author Niccol� Morabito
 *
 */
@FunctionalInterface
@TipoAnalizzatore(Tipo.SESSO)
public interface Analizzatore
{
    Rapporto generaRapporto(Collection<Studente> studs);
    
    /**
     * Restituisce il tipo di rapporto che genera l�analizzatore
     * NOTA BENE: questo metodo pu� essere implementato di default
     * utilizzando le annotazioni OPPURE pu� essere lasciato astratto e
     * implementato in ciascuna sottoclasse (richiedendo la
     * specifica in ciascuna implementazione di Analizzatore). In
     * questo secondo caso non sara� possibile utilizzare le lambda
     * per implementare gli analizzatori base.
     */
    default TipoRapporto getTipo() 
    {
    	TipoRapporto v = this.getClass().getAnnotation(TipoAnalizzatore.class).value();
    	if (v==null) return Tipo.SESSO;
    	return v;
    }    

}
