package com.ironwaterstudio.database;

import java.util.ArrayList;
import java.util.Collections;

public class DbWhere {
	private StringBuilder builder = new StringBuilder();
	private ArrayList<String> params = new ArrayList<>();
	private boolean isParam;

	ArrayList<String> getParams() {
		return params;
	}

	public DbWhere(String operand) {
		this(operand, true);
	}

	public DbWhere(String operand, boolean isParam) {
		builder.append(operand);
		this.isParam = isParam;
	}

	private void param(String param) {
		builder.append(" ");
		if (isParam) {
			builder.append("?");
			params.add(param);
		} else {
			builder.append(param);
		}
	}

	private void params(String... params) {
		builder.append(" ");
		if (isParam) {
			builder.append("(");
			for (int i = 0; i < params.length; i++) {
				builder.append("?");
				if (i < params.length - 1)
					builder.append(",");
			}
			builder.append(")");
			Collections.addAll(this.params, params);
		} else {
			for (int i = 0; i < params.length; i++) {
				builder.append(params[i]);
				if (i < params.length - 1)
					builder.append(", ");
			}
		}
	}

	public DbWhere or(String operand) {
		return or(operand, true);
	}

	public DbWhere or(String operand, boolean isParam) {
		builder.append(" OR ");
		builder.append(operand);
		this.isParam = isParam;
		return this;
	}

	public DbWhere and(String operand) {
		return and(operand, true);
	}

	public DbWhere and(String operand, boolean isParam) {
		builder.append(" AND ");
		builder.append(operand);
		this.isParam = isParam;
		return this;
	}

	/**
	 * Equals (=)
	 */
	public DbWhere eq(String param) {
		builder.append(" =");
		param(param);
		return this;
	}

	public DbWhere eq(Number param) {
		return eq(String.valueOf(param));
	}

	/**
	 * Not equals (!=)
	 */
	public DbWhere neq(String param) {
		builder.append(" !=");
		param(param);
		return this;
	}

	public DbWhere neq(Number param) {
		return neq(String.valueOf(param));
	}

	public DbWhere isNull() {
		builder.append(" IS NULL");
		return this;
	}

	public DbWhere notNull() {
		builder.append(" NOT NULL");
		return this;
	}

	/**
	 * Greater (>)
	 */
	public DbWhere gt(String param) {
		builder.append(" >");
		param(param);
		return this;
	}

	public DbWhere gt(Number param) {
		return gt(String.valueOf(param));
	}

	/**
	 * Greater or equals (>=)
	 */
	public DbWhere gte(String param) {
		builder.append(" >=");
		param(param);
		return this;
	}

	public DbWhere gte(Number param) {
		return gte(String.valueOf(param));
	}

	/**
	 * Less (<)
	 */
	public DbWhere lt(String param) {
		builder.append(" <");
		param(param);
		return this;
	}

	public DbWhere lt(Number param) {
		return lt(String.valueOf(param));
	}

	/**
	 * Less or equals (<=)
	 */
	public DbWhere lte(String param) {
		builder.append(" <=");
		param(param);
		return this;
	}

	public DbWhere lte(Number param) {
		return lte(String.valueOf(param));
	}

	public DbWhere in(String... params) {
		builder.append(" IN");
		params(params);
		return this;
	}

	public DbWhere in(Number... params) {
		String[] strParams = new String[params.length];
		for (int i = 0; i < params.length; i++)
			strParams[i] = String.valueOf(params[i]);
		return in(strParams);
	}

	@Override
	public String toString() {
		return builder.toString();
	}
}
