package it.uniroma1.lcl.studstats;

import java.util.List;
import it.uniroma1.lcl.studstats.dati.Analizzatore;
import it.uniroma1.lcl.studstats.dati.Rapporto;
import it.uniroma1.lcl.studstats.dati.TipoRapporto;

/**
 * Interfaccia che viene implementata da Studstats.
 * 
 * @author navigli
 */
public interface AggregatoreStatistico
{
	/**
     * Aggiunge uno studente per l'analisi
     * @param s studente da aggiungere
     */
    void add(Studente s);
    
    /**
     * Aggiunge un analizzatore all'aggregatore
     * @param an analizzatore da aggiungere
     */
    void add(Analizzatore an);
    
    /**
     * Genera i rapporti dei tipi specificati 
     * (tutti i tipi se non viene specificato nessun tipo)
     * * NOTA BENE: non importa se un tipo di rapporto specificato
     * non viene generato da nessuno degli analizzatori. Nel caso
     * peggiore verra’ restituita una lista di rapporti vuota.
     * @param tipiRapporto i tipi di cui si vogliono i rapporti
     * @return la lista dei rapporti generati
     */
    List<Rapporto> generaRapporti(TipoRapporto... tipiRapporto);
    
    /**
     * Restituisce il numero di analizzatori memorizzati
     */
    int numeroAnalizzatori();
    
    /**
     * Aggiunge tutti gli analizzatori specificati.
     * 
     * @param analizzatori da aggiungere
     */
    default void addAll(Analizzatore... analizzatori)
    {
    	for (Analizzatore a : analizzatori) add(a);
    }


}
