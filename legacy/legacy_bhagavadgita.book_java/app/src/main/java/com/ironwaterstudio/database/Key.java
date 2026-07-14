package com.ironwaterstudio.database;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD})
public @interface Key {
	/**
	 * @return {@code true} if this {@code Field} is {@code Identity}, {@code false} otherwise.
	 */
	boolean value() default true;
}