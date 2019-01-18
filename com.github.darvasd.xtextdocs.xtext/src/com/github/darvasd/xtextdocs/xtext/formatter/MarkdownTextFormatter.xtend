package com.github.darvasd.xtextdocs.xtext.formatter

import java.util.List

class MarkdownTextFormatter implements ITextFormatter {
	public static final MarkdownTextFormatter INSTANCE = new MarkdownTextFormatter();

	private new() {
	}
	
	override escape(String original) {
		// FIXME do not escape inside "`"
		var ret = original;
		if (!original.contains("@code") && !original.contains("`")) { // quickfix
			ret = original.replaceAll('''([_\*])''', '''\\$1''');
		}
		return ret;
	}

	override bold(String original) {
		// The '**' does not support multiline!
		return '''**«original.replaceAll("(\\r|\\n)+(?=\\S)", "**$1**")»**''';
	}

	override codeBlock(String original) {
		return '''
		```
		«original»
		```''';
	}

	override inlineCode(String original) {
		return '''`«original»`''';
	}

	override italic(String original) {
		// The '_' does not support multiline!
		return '''_«original.replaceAll("(\\r|\\n)+", "_$1_")»_''';
	}

	override newLine() {
		return '''
			
			''';
	}

	override String link(String linkText, String target) {
		return '''[«linkText»](«target»)''';
	}
	
	override unorderedList(List<String> originals) {
		return '''
		
		«FOR line : originals»
		    «"  "»- «line»
		«ENDFOR»
		'''
	}
}
