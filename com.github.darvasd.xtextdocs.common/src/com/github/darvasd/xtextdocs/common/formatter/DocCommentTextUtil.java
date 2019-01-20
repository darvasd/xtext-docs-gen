/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.xtext.formatter;

import java.util.List;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.github.darvasd.xtextdocs.common.formatter.ITextFormatter;

/**
 * Utility class with methods to represent the doc comment formatting using the
 * given text formatter.
 * <p>
 * For example, the &#123;&#64;code content&#125; tags will be replaced with the
 * text that is needed to format {@code content} as an inline code snippet in
 * the target textual representation.
 */
public class DocCommentTextUtil {
	private DocCommentTextUtil() {
		// Utility class.
	}
	
	private static final String CODE_PATTERN1 = "\\{@code\\s+([^\\}]+)\\}";
	private static final String CODE_PATTERN2 = "`(.*?)`";

	/**
	 * Replaces the following tags in the given text with the format defined by the
	 * given formatter.
	 * <ul>
	 * <li>Code snippets: &#123;&#64;code ...&#125;
	 * <li>Bold text: &lt;b&gt;...&lt;/b&gt; (also `...`)
	 * <li>Italic text: &lt;i&gt;...&lt;/i&gt;
	 * <li>New paragraph: &lt;p&gt;
	 * <li>Unordered list: &lt;ul&gt; &lt;li&gt; ... &lt;li&gt; ... &lt;/ul&gt.
	 * </ul>
	 * 
	 * @param text
	 *            Original text containing doc comment tags.
	 * @param formatter
	 *            Formatter to be used for the replacement.
	 * @return Formatted text
	 */
	public static String format(String text, ITextFormatter formatter) {
		String ret = text;

		// {@code ...} or `...`
		ret = ret.replaceAll(CODE_PATTERN1, formatter.inlineCode("$1"));
		ret = ret.replaceAll(CODE_PATTERN2, formatter.inlineCode("$1"));

		// <b>...</b>
		ret = ret.replaceAll("\\Q<b>\\E(.*?)\\Q</b>\\E", formatter.bold("$1"));

		// <i>...</i>
		ret = ret.replaceAll("\\Q<i>\\E(.*?)\\Q</i>\\E", formatter.italic("$1"));

		// <p>
		ret = ret.replaceAll("\\Q<p>\\E", formatter.newLine());
		
		// <ul>..</ul>
		Matcher ulMatcher = Pattern.compile("\\Q<ul>\\E(.*?)\\Q</ul>\\E", Pattern.DOTALL).matcher(ret);
		while (ulMatcher.find()) {
			String ul = ulMatcher.group(1).trim();
			ret = ulMatcher.replaceFirst(formatAsList(ul, formatter));
			ulMatcher.reset(ret);
		}
		//ret = ret.replaceAll("^\\s*\\Q<li>\\E(.*?)(\\Q</li>\\E|\\Q</ul>\\E|)", replacement)

		return ret;
	}
	
	private static String formatAsList(String ul, ITextFormatter formatter) {
		String ret = ul.replaceAll("\\Q</li>\\E", "");
		List<String> lines = Stream.of(ret.split("\\Q<li>\\E")).filter(it -> !it.trim().equals("")).collect(Collectors.toList());
		return formatter.unorderedList(lines);
	}

	/**
	 * Replaces the link tags (&#123;&#64;link ...&#125; and &#123;&#64;linkplain
	 * ...&#125;) in the given text with the format defined by the given formatter.
	 * The target of the link will be determined by the given function.
	 * 
	 * @param text
	 *            Original text containing doc comment tags.
	 * @param formatter
	 *            Formatter to be used for the replacement.
	 * @param linkToTarget
	 *            Function that returns the target for a given link text.
	 * @return Formatted text
	 */
	public static String resolveLinks(String text, ITextFormatter formatter, Function<String, String> linkToTarget) {
		String ret = text;
		// TODO The code duplication could be reduced

		// {@link ...} and {@linkplain ...} (with no label, e.g. {@link ID})
		{
			Pattern linkPattern = Pattern.compile("\\{@link(?:plain)?\\s+([^ \\}]+)\\s*\\}");
			Matcher matcher = linkPattern.matcher(ret);
	
			while (matcher.find()) {
				String linkText = matcher.group(1);
				ret = matcher.replaceFirst(formatter.link(linkText, linkToTarget.apply(linkText)));
				matcher.reset(ret);
			}
		}
		
		// {@link <target> <label optionally with whitespace>} and {@linkplain <target> <label>}
		{
			Pattern linkPattern = Pattern.compile("\\{@link(?:plain)?\\s+([^ ]+)\\s+([^\\}]+)\\}");
			Matcher matcher = linkPattern.matcher(ret);
	
			while (matcher.find()) {
				String target = matcher.group(1);
				String linkText = matcher.group(2);
				ret = matcher.replaceFirst(formatter.link(linkText, linkToTarget.apply(target)));
				matcher.reset(ret);
			}
		}

		return ret;
	}
	
	/**
	 * Returns true iff the given original doc comment text contains any code part.
	 * @param originalText Doc comment text
	 * @return True if contains code.
	 */
	public static boolean containsCode(String originalText) {
		return Pattern.matches(String.format(".*%s.*", CODE_PATTERN1), originalText) || 
				Pattern.matches(String.format(".*%s.*", CODE_PATTERN2), originalText);
	}
}
