package com.ironwaterstudio.database;

import java.util.ArrayList;

public interface IQuery<T> {
	IQuery<T> where(String predicate);

	IQuery<T> where(DbWhere dbWhere);

	IQuery<T> orderBy(String field);

	IQuery<T> orderBy(DbOrderBy dbOrderBy);

	IQuery<T> top(int count);

	IQuery<T> join(String table);

	IQuery<T> join(String table, String where);

	IQuery<T> join(String table, DbWhere where);

	IQuery<T> select(String... fields);

	<M> IQuery<M> select(Class<M> itemCls, String... fields);

	<M> IQuery<M> select(Class<M> itemCls);

	ArrayList<T> toList();

	T single();

	int count();

	boolean exist();
}
