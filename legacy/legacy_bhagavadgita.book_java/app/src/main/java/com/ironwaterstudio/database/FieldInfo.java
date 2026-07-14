package com.ironwaterstudio.database;

public class FieldInfo {
	private String name;
	private Object value;
	private Type type;

	public FieldInfo(String name, Object value, Type type) {
		this.name = name;
		this.value = value;
		this.type = type;
	}

	public String getName() {
		return name;
	}

	public Object getValue() {
		return value;
	}

	public Type getType() {
		return type;
	}

	public enum Type {DATA, KEY, IDENTITY}
}
