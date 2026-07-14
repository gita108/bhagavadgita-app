package com.ironwaterstudio.database;

public abstract class DbWriteQuery {
	protected String tableName;

	DbWriteQuery(String tableName) {
		this.tableName = tableName;
	}

	abstract String getQuery();

	abstract Object[] getParams();
}