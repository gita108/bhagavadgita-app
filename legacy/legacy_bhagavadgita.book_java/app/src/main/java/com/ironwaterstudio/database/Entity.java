package com.ironwaterstudio.database;

public class Entity {
	private final Object object;
	private final State state;

	public Entity(Object object, State state) {
		this.object = object;
		this.state = state;
	}

	public DbWriteQuery buildWriteQuery(String tableName) {
		switch (getState()) {
			case ADDED:
				return new DbInsertQuery(getObject(), tableName);
			case UPDATED:
				return new DbUpdateQuery(getObject(), tableName);
			case DELETED:
				return new DbRemoveQuery(getObject(), tableName);
			default:
				return null;
		}
	}

	public Object getObject() {
		return object;
	}

	public State getState() {
		return state;
	}

	public enum State {UPDATED, ADDED, DELETED}
}