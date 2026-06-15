package kr.co.mcmp.util;

public class NamingUtils {

	/* Comment translated to English. */
    public static String getCredentialName(Long id, String name) {
    	return String.format("m-cmp_%s-%s-Credential", id, name);
    }
}
