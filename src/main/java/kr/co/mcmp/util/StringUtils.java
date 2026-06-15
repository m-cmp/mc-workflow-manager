package kr.co.mcmp.util;

public class StringUtils {
	
	
	/* Comment translated to English. */
	public static String toLowerCamelCase(String str, String sep) {
		String camel = "";
		
		if(sep == null) {
			sep = "_";
		}
		
		if(str != null && !"".equals(str)) {
			String[] strs = str.split(sep);
			if(strs.length > 1) {
				camel = strs[0];
				for(int i=1; i<strs.length; i++) {
					camel += strs[i].substring(0, 1).toUpperCase() + strs[i].substring(1);
				}
			}
		}
		
		if("".equals(camel)) {
			camel = str;
		}
		
		return camel;
	}
	
}
