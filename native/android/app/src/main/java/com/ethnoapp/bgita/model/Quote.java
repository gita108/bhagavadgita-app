package com.ethnoapp.bgita.model;

import java.io.Serializable;

public class Quote implements Serializable {
	private String author;
	private String text;


	public Quote() {
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}
}
