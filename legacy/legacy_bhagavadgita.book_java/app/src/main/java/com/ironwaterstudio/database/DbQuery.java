package com.ironwaterstudio.database;

import android.database.Cursor;

import java.util.ArrayList;
import java.util.Collections;

public class DbQuery<T> implements IQuery<T> {
	public static final int ALL = -1;

	private ArrayList<String> tables = new ArrayList<>();
	private ArrayList<String> fields = new ArrayList<>();
	private ArrayList<String> where = new ArrayList<>();
	private ArrayList<String> orderBy = new ArrayList<>();
	private int top = ALL;
	private ArrayList<String> params = new ArrayList<>();

	private final DbContext dbContext;
	private final Class<T> itemCls;

	DbQuery(DbContext dbContext, Class<T> itemCls, String tableName) {
		this.dbContext = dbContext;
		this.itemCls = itemCls;

		tables.add(tableName);
		fields.add(tableName + ".*");
	}

	@SuppressWarnings("unchecked")
	private DbQuery(DbQuery dbQuery, Class<T> itemCls) {
		dbContext = dbQuery.dbContext;
		this.itemCls = itemCls;
		tables.addAll(dbQuery.tables);
		fields.addAll(dbQuery.fields);
		where.addAll(dbQuery.where);
		orderBy.addAll(dbQuery.orderBy);
		top = dbQuery.top;
		params.addAll(dbQuery.params);
	}

	@Override
	public IQuery<T> where(String predicate) {
		where.add(predicate);
		return this;
	}

	@Override
	public IQuery<T> where(DbWhere dbWhere) {
		where.add(dbWhere.toString());
		params.addAll(dbWhere.getParams());
		return this;
	}

	@Override
	public IQuery<T> orderBy(String field) {
		orderBy.add(field);
		return this;
	}

	@Override
	public IQuery<T> orderBy(DbOrderBy dbOrderBy) {
		orderBy.add(dbOrderBy.toString());
		return this;
	}

	@Override
	public IQuery<T> top(int count) {
		top = count;
		return this;
	}

	@Override
	public IQuery<T> join(String table) {
		tables.add(table);
		return this;
	}

	@Override
	public IQuery<T> join(String table, String where) {
		tables.add(table);
		where(where);
		return this;
	}

	@Override
	public IQuery<T> join(String table, DbWhere where) {
		tables.add(table);
		where(where);
		return this;
	}

	@Override
	public IQuery<T> select(String... fields) {
		this.fields.clear();
		Collections.addAll(this.fields, fields);
		return this;
	}

	@Override
	public <M> IQuery<M> select(Class<M> itemCls, String... fields) {
		return new DbQuery<>(this, itemCls).select(fields);
	}

	@Override
	public <M> IQuery<M> select(Class<M> itemCls) {
		return new DbQuery<>(this, itemCls).select(DbReflection.getAllFieldNames(itemCls));
	}

	@Override
	public ArrayList<T> toList() {
		ArrayList<T> items = new ArrayList<>();
		processQuery(items, ALL);
		return items;
	}

	@Override
	public T single() {
		ArrayList<T> items = new ArrayList<>();
		processQuery(items, 1);
		if (!items.isEmpty())
			return items.get(0);
		return null;
	}

	@Override
	public int count() {
		final int[] count = new int[1];
		dbContext.query(buildQuery(true), params.toArray(new String[params.size()]), new DbContext.OnQueryListener() {
			@Override
			public void onQuery(Cursor c) {
				try {
					count[0] = c.getInt(0);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
		return count[0];
	}

	@Override
	public boolean exist() {
		return count() > 0;
	}

	private void processQuery(final ArrayList<T> items, final int count) {
		dbContext.query(buildQuery(false), params.toArray(new String[params.size()]), new DbContext.OnQueryListener() {
			@Override
			public void onQuery(Cursor c) {
				try {
					do {
						T object = itemCls.newInstance();
						DbReflection.readObject(object, c);
						items.add(object);
					} while ((count == ALL || count > items.size()) && c.moveToNext());
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	private String buildQuery(boolean onlyCount) {
		StringBuilder query = new StringBuilder();
		query.append("SELECT ");
		if (onlyCount)
			query.append("COUNT(*)");
		else
			joinStrings(query, fields, ", ");
		query.append(" FROM ");
		joinStrings(query, tables, ", ");
		if (!where.isEmpty()) {
			query.append(" WHERE ");
			joinStrings(query, where, " AND ");
		}
		if (!orderBy.isEmpty() && !onlyCount) {
			query.append(" ORDER BY ");
			joinStrings(query, orderBy, ", ");
		}
		if (top != ALL && !onlyCount) {
			query.append(" LIMIT ");
			query.append(top);
		}
		return query.toString();
	}

	@Override
	public String toString() {
		return buildQuery(false);
	}

	private static void joinStrings(StringBuilder builder, ArrayList<String> data, String separator) {
		if (!data.isEmpty())
			builder.append(data.get(0));
		for (int i = 1; i < data.size(); i++) {
			builder.append(separator);
			builder.append(data.get(i));
		}
	}
}
