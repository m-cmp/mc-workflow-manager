package kr.co.mcmp.util;

public class JenkinsPipelineUtil {

	/* Comment translated to English. */
	public static StringBuffer appendLine(StringBuffer sb, String line) {
		return appendLine(sb, line, 0);
	}
	
	public static StringBuffer appendLine(StringBuffer sb, String line, int indent) {
		for(int i=0; i<indent * 2; i++) { // Comment translated to English.
			sb.append(" ");
		}
		sb.append(line);
		sb.append("\n");
		return sb;
	}
}
