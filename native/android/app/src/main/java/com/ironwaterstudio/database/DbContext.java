package com.ironwaterstudio.database;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import com.ironwaterstudio.utils.FileUtils;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;

public class DbContext extends SQLiteOpenHelper {
	public static final String LOG_TAG = DbContext.class.getSimpleName();
	private final ArrayList<DbSet> sets = new ArrayList<>();
	private final String dbName;
	private final int dbVersion;
	private int oldVersion = -1;
	private SQLiteDatabase db = null;

	private final Context context;
	private String dbPath = null;

	/**
	 * Constructor Takes and keeps a reference of the passed context in order to
	 * access to the application assets and resources.
	 *
	 * @param context
	 */
	protected DbContext(Context context, String dbName, int dbVersion, boolean create) {
		super(context, dbName, null, dbVersion);
		this.context = context;
		this.dbName = dbName;
		this.dbVersion = dbVersion;
		oldVersion = dbVersion;
		dbPath = context.getDatabasePath(dbName).getPath();
		if (create)
			createDataBase();
	}

	void addDbSet(DbSet dbSet) {
		sets.add(dbSet);
	}

	@SuppressWarnings("unchecked")
	public boolean saveChanges() {
		beginTransaction();
		try {
			for (DbSet dbSet : sets) {
				LinkedHashMap<Integer, Entity> entities = dbSet.getEntities();
				for (Entity entity : entities.values()) {
					DbWriteQuery writeQuery = entity.buildWriteQuery(dbSet.getTableName());
					execute(writeQuery.getQuery(), writeQuery.getParams());
				}
			}
			setTransactionSuccessful();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			endTransaction();
			revertChanges();
		}
	}

	public void revertChanges() {
		for (DbSet dbSet : sets)
			dbSet.getEntities().clear();
	}

	private void createDataBase() {
		boolean dbExist = checkDataBase();
		SQLiteDatabase dbRead = getReadableDatabase();
		dbRead.close();
		if (FileUtils.assetFileExist(context, dbName) && (!dbExist || oldVersion < dbVersion)) {
			try {
				if (dbExist)
					beforeCopy();
				FileUtils.copyStream(context.getAssets().open(dbName), new FileOutputStream(dbPath));
				if (dbExist)
					afterCopy();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	private boolean checkDataBase() {
		SQLiteDatabase checkDB = null;

		try {
			checkDB = SQLiteDatabase.openDatabase(dbPath, null,
					SQLiteDatabase.NO_LOCALIZED_COLLATORS
							| SQLiteDatabase.OPEN_READONLY);
		} catch (SQLiteException e) {
			// database does't exist yet
		}

		if (checkDB != null) {
			checkDB.close();
		}

		return checkDB != null;
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		if (FileUtils.assetFileExist(context, dbName))
			return;
		onUpgrade(0);
	}

	@Override
	public final void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		if (FileUtils.assetFileExist(context, dbName)) {
			this.oldVersion = oldVersion;
			return;
		}
		onUpgrade(oldVersion);
	}

	protected void onUpgrade(int oldVersion) {
	}

	protected void beforeCopy() {
	}

	protected void afterCopy() {
	}

	public void query(String sql, String[] params, OnQueryListener listener) {
		Cursor c = null;
		try {
			SQLiteDatabase db = getReadableDatabase();
			logQuery(sql, params);
			c = db.rawQuery(sql, params);
			if (c.moveToFirst())
				listener.onQuery(c);
		} finally {
			if (c != null)
				c.close();
		}
	}

	public boolean exists(String sql, String... params) {
		Cursor c = null;
		try {
			SQLiteDatabase db = getReadableDatabase();
			logQuery(sql, params);
			c = db.rawQuery(sql, params);
			return c.moveToFirst();
		} finally {
			if (c != null)
				c.close();
		}
	}

	public void beginTransaction() {
		if (db != null)
			return;
		db = getWritableDatabase();
		db.beginTransaction();
	}

	public void setTransactionSuccessful() {
		if (db == null)
			return;
		db.setTransactionSuccessful();
	}

	public void endTransaction() {
		if (db == null)
			return;
		db.endTransaction();
		db = null;
	}

	public void execute(String sql, Object... params) {
		SQLiteDatabase db = this.db == null ? getWritableDatabase() : this.db;
		logQuery(sql, params);
		db.execSQL(sql, params);
	}

	private void logQuery(String sql, Object[] params) {
		StringBuilder paramsBuilder = new StringBuilder();
		if (params != null && params.length > 0) {
			paramsBuilder.append("[");
			for (int i = 0; i < params.length; i++) {
				if (i > 0)
					paramsBuilder.append("; ");
				paramsBuilder.append(String.valueOf(params[i]));
			}
			paramsBuilder.append("]");
		} else {
			paramsBuilder.append("nothing");
		}
		Log.d(LOG_TAG, "Query: " + sql + "\nParams: " + paramsBuilder.toString());
	}

	public interface OnQueryListener {
		void onQuery(Cursor c);
	}
}
