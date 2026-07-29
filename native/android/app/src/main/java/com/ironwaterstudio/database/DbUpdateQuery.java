package com.ironwaterstudio.database;

import java.util.ArrayList;

public class DbUpdateQuery extends DbWriteQuery {
	private ArrayList<FieldInfo> data;
	private DbWhere dbWhere = null;

	DbUpdateQuery(Object object, String tableName) {
		super(tableName);
		data = DbReflection.writeObject(object);
		for (FieldInfo fieldInfo : data) {
			if (fieldInfo.getType() == FieldInfo.Type.DATA)
				continue;
			dbWhere = dbWhere == null ? new DbWhere(fieldInfo.getName()) : dbWhere.and(fieldInfo.getName());
			dbWhere.eq(String.valueOf(fieldInfo.getValue()));
		}
	}

	@Override
	String getQuery() {
		StringBuilder query = new StringBuilder();
		query.append("UPDATE ");
		query.append(tableName);
		query.append(" SET ");
		for (int i = 0; i < data.size(); i++) {
			if (data.get(i).getType() != FieldInfo.Type.DATA)
				continue;
			if (i > 0)
				query.append(", ");
			query.append(data.get(i).getName()).append(" = ?");
		}
		query.append(" WHERE ");
		query.append(dbWhere.toString());
		return query.toString();
	}

	@Override
	Object[] getParams() {
		ArrayList<Object> params = new ArrayList<>();
		for (int i = 0; i < data.size(); i++) {
			if (data.get(i).getType() == FieldInfo.Type.DATA)
				params.add(data.get(i).getValue());
		}
		params.addAll(dbWhere.getParams());
		return params.toArray();
	}
}
