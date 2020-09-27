package it.uniroma1.lcl.babelarity;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.util.Objects;

/**
 * Classe che rappresenta un documento di tipo LinguisticObject.
 * È caratterizzato da ID, titolo e contenuto.
 * 
 * @author Niccolò Morabito
 *
 */
public class Document implements LinguisticObject
{
	private String ID;
	private String title;
	private String content;
	
	/**
	 * Costruttore della classe Document che, preso il path del documento, ne ricava il titolo e l'id dalla prima riga e ne costuisce l'oggetto con i tre parametri: ID, title, content.
	 * 
	 * @param path percorso del file
	 */
	public Document(Path path)
	{	
		File file = new File(path.toString());

		try(BufferedReader br = new BufferedReader(new FileReader(file)))
		{
			// si ricava titolo e ID dalla prima linea
			String[] firstLine = br.readLine().split("\t");
			this.title = firstLine[0];
			this.ID = firstLine[1];
			
			// il resto del testo è il content
			StringBuffer sb = new StringBuffer();
			while(br.ready())
				sb.append(br.readLine());
			this.content = sb.toString();
			
		}
		catch(IOException e)
		{
			System.out.println("Il Documento inserito non esiste.");
		}

	}
	
	/**
	 * Restituisce l'ID del documento.
	 * @return ID del documento
	 */
	public String getId() { return this.ID; }
	
	/**
	 * Restituisce il titolo del documento.
	 * @return titolo del documento
	 */
	public String getTitle() { return this.title; }
	
	/**
	 * Restituisce il contenuto del documento sotto forma di stringa.
	 * @return contenuto del documento
	 */
	public String getContent() { return this.content; }

	@Override
	public int hashCode() { return Objects.hash(this.title + this.ID + this.content); }

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null || this.getClass() != obj.getClass())
			return false;
		Document other = (Document) obj;
		if (ID.equals(other.getId()) && content.equals(other.getContent()) && title.equals(other.getTitle()))
			return true;
		return false;
	}
}

