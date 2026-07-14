package com.ironwaterstudio.database;

import android.database.Cursor;

import com.ironwaterstudio.utils.ReflectionUtils;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DbReflection {
	private static final ReflectionUtils.FieldsStrategy FIELDS_STRATEGY = new ReflectionUtils.FieldsStrategy() {
		@Override
		public String getName(Field field) {
			Column column = field.getAnnotation(Column.class);
			String name = column != null ? column.value() : field.getName();
			return name.toLowerCase();
		}

		@Override
		public boolean isIgnore(Field field) {
			return field.getAnnotation(NotMapped.class) != null;
		}
	};

	public static String[] getAllFieldNames(Class<?> cls) {
		Set<String> names = ReflectionUtils.getFields(cls, FIELDS_STRATEGY).keySet();
		return names.toArray(new String[names.size()]);
	}

	public static Field searchField(Class<?> cls, String dbColumnName) {
		return ReflectionUtils.getFields(cls, FIELDS_STRATEGY).get(dbColumnName.toLowerCase());
	}

	@SuppressWarnings("unchecked")
	public static void readObject(Object obj, Cursor cursor) {
		Class<?> cls = obj.getClass();
		for (int i = 0; i < cursor.getColumnCount(); i++) {
			try {
				Field field = searchField(cls, cursor.getColumnName(i));
				if (field == null)
					continue;
				if (!field.isAccessible())
					field.setAccessible(true);

				Object value;
				if (field.getType() == int.class)
					value = !cursor.isNull(i) ? cursor.getInt(i) : Integer.MAX_VALUE;
				else if (field.getType() == String.class)
					value = cursor.getString(i);
				else if (field.getType() == boolean.class)
					value = cursor.getInt(i) != 0;
				else if (field.getType() == long.class)
					value = !cursor.isNull(i) ? cursor.getLong(i) : Long.MAX_VALUE;
				else if (field.getType() == float.class)
					value = !cursor.isNull(i) ? cursor.getFloat(i) : Float.MAX_VALUE;
				else if (field.getType() == double.class)
					value = !cursor.isNull(i) ? cursor.getDouble(i) : Double.MAX_VALUE;
				else if (field.getType() == short.class)
					value = !cursor.isNull(i) ? cursor.getShort(i) : Short.MAX_VALUE;
				else if (field.getType() == byte[].class)
					value = cursor.getBlob(i);
				else if (field.getType().isEnum())
					value = !cursor.isNull(i) ? ((Enum<?>[]) field.getType().getEnumConstants())[cursor.getInt(i)] : null;
				else
					continue;
				field.set(obj, value);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public static ArrayList<FieldInfo> writeObject(Object obj, FieldInfo.Type... returnTypes) {
		Class<?> cls = obj.getClass();
		ArrayList<FieldInfo> data = new ArrayList<>();
		Map<String, Field> fields = ReflectionUtils.getFields(cls, FIELDS_STRATEGY);
		List<FieldInfo.Type> types = Arrays.asList(returnTypes);
		for (String name : fields.keySet()) {
			Field field = fields.get(name);
			try {
				if (!field.isAccessible())
					field.setAccessible(true);
				Key key = field.getAnnotation(Key.class);
				FieldInfo.Type type = key == null ? FieldInfo.Type.DATA : key.value() ? FieldInfo.Type.IDENTITY : FieldInfo.Type.KEY;
				if (!types.isEmpty() && !types.contains(type))
					continue;
				Object value = null;
				if (field.getType() == boolean.class)
					value = field.getBoolean(obj) ? 1 : 0;
				else if ((field.getType() == int.class && field.getInt(obj) != Integer.MAX_VALUE)
						|| (field.getType() == String.class)
						|| (field.getType() == long.class && field.getLong(obj) != Long.MAX_VALUE)
						|| (field.getType() == float.class && field.getFloat(obj) != Float.MAX_VALUE)
						|| (field.getType() == double.class && field.getDouble(obj) != Double.MAX_VALUE)
						|| (field.getType() == short.class && field.getShort(obj) != Short.MAX_VALUE)
						|| (field.getType() == byte[].class))
					value = field.get(obj);
				else if (field.getType().isEnum())
					value = field.get(obj) != null ? ((Enum<?>) field.get(obj)).ordinal() : null;
				data.add(new FieldInfo(name, value, type));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return data;
	}
}
