package com.ironwaterstudio.database;

import java.util.ArrayList;

public class DbInsertQuery extends DbWriteQuery {
	private ArrayList<FieldInfo> data;

	DbInsertQuery(Object object, String tableName) {
		super(tableName);
		data = DbReflection.writeObject(object, FieldInfo.Type.DATA, FieldInfo.Type.KEY);
	}

	@Override
	public String getQuery() {
		StringBuilder query = new StringBuilder();
		query.append("INSERT INTO ");
		query.append(tableName);
		query.append(" (");
		StringBuilder paramsTemplate = new StringBuilder();
		for (int i = 0; i < data.size(); i++) {
			if (i > 0) {
				query.append(", ");
				paramsTemplate.append(", ");
			}
			query.append(data.get(i).getName());
			paramsTemplate.append("?");
		}
		query.append(") VALUES (");
		query.append(paramsTemplate.toString());
		query.append(")");
		return query.toString();
	}

	@Override
	public Object[] getParams() {
		Object[] params = new Object[data.size()];
		for (int i = 0; i < data.size(); i++)
			params[i] = data.get(i).getValue();
		return params;
	}
}
