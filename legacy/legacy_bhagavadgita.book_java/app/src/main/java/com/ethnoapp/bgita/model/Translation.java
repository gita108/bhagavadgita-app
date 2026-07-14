package com.ethnoapp.bgita.model;

public class Translation {
	private String languageCode;
	private String text;

	public Translation(String languageCode, String text) {
		this.languageCode = languageCode;
		this.text = text;
	}

	public String getLanguageCode() {
		return languageCode;
	}

	public void setLanguageCode(String languageCode) {
		this.languageCode = languageCode;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}
}
