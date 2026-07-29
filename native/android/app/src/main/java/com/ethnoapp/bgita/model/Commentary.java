package com.ethnoapp.bgita.model;

public class Commentary {
	private String initials;
	private String name;
	private String commentary;

	public Commentary(String initials, String name, String commentary) {
		this.initials = initials;
		this.name = name;
		this.commentary = commentary;
	}

	public String getInitials() {
		return initials;
	}

	public void setInitials(String initials) {
		this.initials = initials;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCommentary() {
		return commentary;
	}

	public void setCommentary(String commentary) {
		this.commentary = commentary;
	}
}
