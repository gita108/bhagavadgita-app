package com.ironwaterstudio.database;

public class DbOrderBy {
	private StringBuilder builder = new StringBuilder();

	public DbOrderBy(String field) {
		addField(field, true);
	}

	public DbOrderBy(String field, boolean asc) {
		addField(field, asc);
	}

	public DbOrderBy and(String field) {
		builder.append(", ");
		addField(field, true);
		return this;
	}

	public DbOrderBy and(String field, boolean asc) {
		builder.append(" ");
		addField(field, asc);
		return this;
	}

	private void addField(String field, boolean asc) {
		builder.append(field);
		if (!asc)
			builder.append(" DESC");
	}

	@Override
	public String toString() {
		return builder.toString();
	}
}
