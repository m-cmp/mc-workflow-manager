package kr.co.strato.util;

import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

public class JsonUtil {
	public static JsonElement fromString(String json, String path) throws JsonSyntaxException {
	    JsonObject obj = new GsonBuilder().create().fromJson(json, JsonObject.class);
	    return fromString(obj, path);
	}
	
	public static JsonElement fromString(JsonObject obj, String path) throws JsonSyntaxException {
	    String[] seg = path.split("\\.");
	    for (String element : seg) {
	        if (obj != null) {
	            JsonElement ele = obj.get(element);
	            if (!ele.isJsonObject()) 
	                return ele;
	            else
	                obj = ele.getAsJsonObject();
	        } else {
	            return null;
	        }
	    }
	    return obj;
	}
}
