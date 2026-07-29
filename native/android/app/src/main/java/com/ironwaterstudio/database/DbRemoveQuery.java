package com.ironwaterstudio.database;

import java.util.ArrayList;

public class DbRemoveQuery extends DbWriteQuery {
	private DbWhere dbWhere = null;

	DbRemoveQuery(Object object, String tableName) {
		super(tableName);
		ArrayList<FieldInfo> data = DbReflection.writeObject(object, FieldInfo.Type.KEY, FieldInfo.Type.IDENTITY);
		for (int i = 0; i < data.size(); i++) {
			FieldInfo keyInfo = data.get(i);
			dbWhere = dbWhere == null ? new DbWhere(keyInfo.getName()) : dbWhere.and(keyInfo.getName());
			dbWhere.eq(String.valueOf(keyInfo.getValue()));
		}
	}

	@Override
	String getQuery() {
		return "DELETE FROM " + tableName + " WHERE " + dbWhere.toString();
	}

	@Override
	Object[] getParams() {
		return dbWhere.getParams().toArray();
	}
}