package it.uniroma1.lcl.studstats.dati;

import java.util.ArrayList;
import java.util.Collection;

/**
 * Gli oggetti sono costruiti con un voto minimo e, opzionalmente, con un Analizzatore. Genera un rapporto la cui toString è il rapporto dell’analizzatore fornito in fase di costruzione (o, se non specificato, l’AnalizzatoreSesso) dei soli studenti con voto >= di quello minimo specificato in fase di costruzione.
 */
import it.uniroma1.lcl.studstats.Studente;

/**
 * Analizzatore che si costruisce con un voto minimo e un analizzatore.
 * Genera il rapporto corrispondente solo per gli studenti con un voto maggiore o uguale al valore con cui viene costruita l'istanza.
 * 
 * @author Niccolò Morabito
 *
 */
@TipoAnalizzatore(Tipo.VOTO_MAGGIORE)
public class AnalizzatoreStudentiVotoMaggiore extends AnalizzatoreCombinato
{
	/**
	 * Costruttore dell'AnalizzatoreStudentiVotoMaggiore che prende un solo parametro come input.
	 * L'AnalizzatorePadre viene posto automaticamente uguale ad AnalizzatoreSesso.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 */
	public AnalizzatoreStudentiVotoMaggiore(int voto) { super(voto); }
	
	/**
	 * Costruttore dell'AnalizzatoreStudentiVotoMaggiore che prende due parametri come input.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 * @param a analizzatore attraverso cui si vuole generare il rapporto; verrà generato solo per gli studenti idonei.
	 */
	public AnalizzatoreStudentiVotoMaggiore(int voto, AnalizzatorePadre a) { super(voto, a); }
	
	/**
	 * Genera il rapporto dell'analizzatore con cui è costruito passando come argomento la lista degli studenti idonei.
	 */
	@Override
	public Rapporto generaRapporto(Collection<Studente> studs)
	{
		ArrayList<Studente> studentiIdonei = new ArrayList<>();
		
		for (Studente stud : studs)
			if (stud.getVoto() >= this.votoMin) studentiIdonei.add(stud);
		
		return this.analizzatore.generaRapporto(studentiIdonei);
	}
}
