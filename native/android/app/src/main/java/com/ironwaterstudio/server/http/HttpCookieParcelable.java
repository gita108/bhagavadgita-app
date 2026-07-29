package com.ironwaterstudio.server.http;

import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.Keep;

import java.net.HttpCookie;
import java.util.Locale;

@Keep
public class HttpCookieParcelable implements Parcelable {
	private HttpCookie cookie;

	public HttpCookieParcelable(HttpCookie cookie) {
		this.cookie = cookie;
	}

	public HttpCookieParcelable(Parcel source) {
		String name = source.readString();
		String value = source.readString();
		cookie = new HttpCookie(name, value);
		cookie.setComment(source.readString());
		cookie.setCommentURL(source.readString());
		cookie.setDiscard(source.readByte() != 0);
		cookie.setDomain(source.readString());
		cookie.setMaxAge(source.readLong());
		cookie.setPath(source.readString());
		cookie.setPortlist(source.readString());
		cookie.setSecure(source.readByte() != 0);
		cookie.setVersion(source.readInt());
	}

	public HttpCookie getCookie() {
		return cookie;
	}

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(cookie.getName());
		dest.writeString(cookie.getValue());
		dest.writeString(cookie.getComment());
		dest.writeString(cookie.getCommentURL());
		dest.writeByte((byte) (cookie.getDiscard() ? 1 : 0));
		dest.writeString(cookie.getDomain());
		dest.writeLong(cookie.getMaxAge());
		dest.writeString(cookie.getPath());
		dest.writeString(cookie.getPortlist());
		dest.writeByte((byte) (cookie.getSecure() ? 1 : 0));
		dest.writeInt(cookie.getVersion());
	}

	/**
	 * Serializes HttpCookie object into String
	 *
	 * @param cookie cookie to be encoded, can be null
	 * @return cookie encoded as String
	 */
	public static String encodeCookie(HttpCookie cookie) {
		if (cookie == null)
			return null;

		final Parcel p = Parcel.obtain();
		try {
			p.writeValue(new HttpCookieParcelable(cookie));
			return byteArrayToHexString(p.marshall());
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			p.recycle();
		}
	}

	/**
	 * Returns HttpCookie decoded from cookie string
	 *
	 * @param cookieString string of cookie as returned from http request
	 * @return decoded cookie or null if exception occurred
	 */
	public static HttpCookie decodeCookie(String cookieString) {
		final Parcel p = Parcel.obtain();
		try {
			byte[] bytes = hexStringToByteArray(cookieString);
			p.unmarshall(bytes, 0, bytes.length);
			p.setDataPosition(0);
			HttpCookieParcelable result = (HttpCookieParcelable) p.readValue(HttpCookieParcelable.class.getClassLoader());
			return result.getCookie();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			p.recycle();
		}
	}

	/**
	 * Using some super basic byte array &lt;-&gt; hex conversions so we don't
	 * have to rely on any large Base64 libraries. Can be overridden if you
	 * like!
	 *
	 * @param bytes byte array to be converted
	 * @return string containing hex values
	 */
	private static String byteArrayToHexString(byte[] bytes) {
		StringBuilder sb = new StringBuilder(bytes.length * 2);
		for (byte element : bytes) {
			int v = element & 0xff;
			if (v < 16) {
				sb.append('0');
			}
			sb.append(Integer.toHexString(v));
		}
		return sb.toString().toUpperCase(Locale.getDefault());
	}

	/**
	 * Converts hex values from strings to byte array
	 *
	 * @param hexString string of hex-encoded values
	 * @return decoded byte array
	 */
	private static byte[] hexStringToByteArray(String hexString) {
		int len = hexString.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(hexString.charAt(i), 16) << 4) + Character
					.digit(hexString.charAt(i + 1), 16));
		}
		return data;
	}

	public static final Parcelable.Creator<HttpCookieParcelable> CREATOR =
			new Creator<HttpCookieParcelable>() {
				@Override
				public HttpCookieParcelable[] newArray(int size) {
					return new HttpCookieParcelable[size];
				}

				@Override
				public HttpCookieParcelable createFromParcel(Parcel source) {
					return new HttpCookieParcelable(source);
				}
			};
}