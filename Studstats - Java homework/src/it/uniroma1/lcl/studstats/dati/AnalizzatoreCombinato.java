package it.uniroma1.lcl.studstats.dati;

import java.util.Collection;
import java.util.Objects;

import it.uniroma1.lcl.studstats.Studente;

/**
 * Classe astratta per analizzatori che combinano un voto minimo ed un analizzatore di tipo AnalizzatorePadre.
 * 
 * @author Niccolò Morabito
 */
public abstract class AnalizzatoreCombinato implements Analizzatore
{
	/**
	 * Voto minimo sotto il quale gli studenti non sono considerati idonei e non partecipato alla generazione del rapporto.
	 */
	protected int votoMin;
	/**
	 * Analizzatore di cui viene chiamato il metodo generaRapporto con la lista degli studenti idonei.
	 */
	protected AnalizzatorePadre analizzatore;
	
	/**
	 * Costruttore dell'AnalizzatoreCombinato che prende un solo parametro come input.
	 * L'AnalizzatorePadre viene posto automaticamente uguale ad AnalizzatoreSesso.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 */
	public AnalizzatoreCombinato(int voto)
	{
		this.votoMin = voto;
		this.analizzatore = new AnalizzatoreSesso();
	}
	
	/**
	 * Costruttore dell'AnalizzatoreCombinato che prende due parametri come input.
	 * 
	 * @param voto il voto minimo per considerare valido uno studente per l'analisi.
	 * @param a analizzatore attraverso cui si vuole generare il rapporto; verrà generato solo per gli studenti idonei.
	 */
	public AnalizzatoreCombinato(int voto, AnalizzatorePadre a)
	{
		this(voto);
		this.analizzatore = a;
	}

	@Override
	public abstract Rapporto generaRapporto(Collection<Studente> studs);
	
	@Override
	public boolean equals(Object o)
	{
		if (this==o) return true;
		if (o==null || this.getClass()!=o.getClass()) return false;
		AnalizzatoreCombinato an = (AnalizzatoreCombinato)o;
		return this.votoMin==an.getVotoMin() 
				&& this.getAnalizzatore().equals(an.getAnalizzatore()) 
				&& this.getTipo().equals(an.getTipo());
	}
	
	@Override
	public int hashCode() { return Objects.hash(this.votoMin, this.analizzatore, this.getTipo()); }

	/**
	 * Getter del campo votoMin della classe.
	 * @return votoMin, il voto minimo per cosiderare uno studente idoneo al rapporto.
	 */
	public int getVotoMin() { return this.votoMin; }

	/**
	 * Getter del campo anallizatore della classe.
	 * @return analizzatore, l'analizzatore di cui si vuole ottenere il rapporto per gli studenti idonei.
	 */
	public Analizzatore getAnalizzatore() { return this.analizzatore; }

}
