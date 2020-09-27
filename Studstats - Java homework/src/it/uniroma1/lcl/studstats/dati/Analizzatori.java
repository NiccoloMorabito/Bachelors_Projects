package it.uniroma1.lcl.studstats.dati;

import java.util.Optional;

/**
 * Interfaccia che istanzia gli analizzatori di base.
 *
 * @author navigli
 *
 */
public interface Analizzatori
{
    static Analizzatore annoDiploma() { return new AnalizzatoreAnnoDiploma(); }
    static Analizzatore istituti() { return new AnalizzatoreIstituti(); }
    static Analizzatore sesso() { return new AnalizzatoreSesso(); }
    static Analizzatore titoloDiStudio() { return new AnalizzatoreTitoloDiStudio(); }
    static Analizzatore voto() { return new AnalizzatoreVoto(); }
    static Analizzatore studentiVotoMaggiore(int voto) { return new AnalizzatoreStudentiVotoMaggiore(voto); }
    static Analizzatore studentiVotoMaggiore(int voto, AnalizzatorePadre a) { return new AnalizzatoreStudentiVotoMaggiore(voto, a); }

	static Optional<Analizzatore> analizzatoreBonus(int voto) { return Optional.of(new AnalizzatoreBonus(voto)); }
	static Optional<Analizzatore> analizzatoreBonus(int voto, AnalizzatorePadre a) { return Optional.of(new AnalizzatoreBonus(voto, a)); }
	static Analizzatore[] allBasic() { return new Analizzatore[] {
									 annoDiploma(), istituti(),
									 sesso(), titoloDiStudio(),
									 voto() }; }
}
