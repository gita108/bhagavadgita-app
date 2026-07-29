package com.ironwaterstudio.database;

import java.util.ArrayList;
import java.util.LinkedHashMap;

public class DbSet<T> implements IQuery<T> {
	private final DbContext dbContext;
	private final Class<T> itemCls;
	private String tableName;
	private final LinkedHashMap<Integer, Entity> entities = new LinkedHashMap<>();

	public DbSet(DbContext dbContext, Class<T> itemCls) {
		this.dbContext = dbContext;
		this.itemCls = itemCls;
		Table table = itemCls.getAnnotation(Table.class);
		tableName = table != null ? table.value() : itemCls.getSimpleName();
		dbContext.addDbSet(this);
	}

	Class<T> getItemCls() {
		return itemCls;
	}

	public String getTableName() {
		return tableName;
	}

	public LinkedHashMap<Integer, Entity> getEntities() {
		return entities;
	}

	@Override
	public IQuery<T> orderBy(String field) {
		return createQuery().orderBy(field);
	}

	@Override
	public IQuery<T> orderBy(DbOrderBy dbOrderBy) {
		return createQuery().orderBy(dbOrderBy);
	}

	@Override
	public IQuery<T> top(int count) {
		return createQuery().top(count);
	}

	@Override
	public IQuery<T> join(String table) {
		return createQuery().join(table);
	}

	@Override
	public IQuery<T> join(String table, String where) {
		return createQuery().join(table, where);
	}

	@Override
	public IQuery<T> join(String table, DbWhere where) {
		return createQuery().join(table, where);
	}

	@Override
	public IQuery<T> select(String... fields) {
		return createQuery().select(fields);
	}

	@Override
	public <M> IQuery<M> select(Class<M> itemCls, String... fields) {
		return createQuery(itemCls).select(fields);
	}

	@Override
	public <M> IQuery<M> select(Class<M> itemCls) {
		return createQuery(itemCls).select(DbReflection.getAllFieldNames(itemCls));
	}

	@Override
	public IQuery<T> where(String predicate) {
		return createQuery().where(predicate);
	}

	@Override
	public IQuery<T> where(DbWhere dbWhere) {
		return createQuery().where(dbWhere);
	}

	@Override
	public T single() {
		return createQuery().single();
	}

	@Override
	public int count() {
		return createQuery().count();
	}

	@Override
	public boolean exist() {
		return createQuery().exist();
	}

	@Override
	public ArrayList<T> toList() {
		return createQuery().toList();
	}

	private DbQuery<T> createQuery() {
		return new DbQuery<>(dbContext, itemCls, tableName);
	}

	private <M> DbQuery<M> createQuery(Class<M> itemCls) {
		return new DbQuery<>(dbContext, itemCls, tableName);
	}

	@SafeVarargs
	public final void add(T... items) {
		for (T item : items)
			createEntity(item, Entity.State.ADDED);
	}

	public void add(ArrayList<T> items) {
		for (T item : items)
			createEntity(item, Entity.State.ADDED);
	}

	@SafeVarargs
	public final void update(T... items) {
		for (T item : items)
			createEntity(item, Entity.State.UPDATED);
	}

	public void update(ArrayList<T> items) {
		for (T item : items)
			createEntity(item, Entity.State.UPDATED);
	}

	@SafeVarargs
	public final void remove(T... items) {
		for (T item : items)
			createEntity(item, Entity.State.DELETED);
	}

	public void remove(ArrayList<T> items) {
		for (T item : items)
			createEntity(item, Entity.State.DELETED);
	}

	public void remove(DbWhere dbWhere) {
		remove(where(dbWhere).toList());
	}

	private void createEntity(T item, Entity.State state) {
		entities.put(item.hashCode(), new Entity(item, state));
	}
}
