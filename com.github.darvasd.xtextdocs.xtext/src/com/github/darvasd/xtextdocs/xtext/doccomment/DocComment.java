/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.xtext.doccomment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import com.google.common.base.Preconditions;

/**
 * Class to represent a documentation comment (doc comment). A documentation
 * comment consists of a <b>main description</b> (that may be empty) and a
 * <b>tag section</b> that contains zero or more tag-argument pairs, each of
 * them starting in a new line with a {@code @} character.
 * 
 * @see <a href=
 *      "https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javadoc.html">Reference
 *      of javadoc utility</a>
 *
 */
public class DocComment {
	private String mainDescription;
	private List<DocCommentBlockTag> parts;

	private DocComment(String description, List<DocCommentBlockTag> parts) {
		this.mainDescription = Preconditions.checkNotNull(description);
		this.parts = Collections.unmodifiableList(Preconditions.checkNotNull(parts));
	}

	/**
	 * Returns the main description of the represented doc comment.
	 * 
	 * @return Main description. Never {@code null}.
	 */
	public String getMainDescription() {
		return mainDescription;
	}

	/**
	 * Returns the tag-argument pairs of the this doc comment, contained in its tag
	 * section.
	 * 
	 * @return Unmodifiable list of tag-argument pairs. Never {@code null}.
	 */
	public List<DocCommentBlockTag> getParts() {
		// already made unmodifiable in the constructor
		return parts;
	}

	/**
	 * Returns the tag-argument pairs of the this doc comment having the given tag,
	 * contained in its tag section.
	 * 
	 * @param tag
	 *            The tag whose instances will be returned. Must start with
	 *            {@code @}
	 * @return Unmodifiable list of tag-argument pairs having the given tag. Never
	 *         {@code null}
	 */
	public List<DocCommentBlockTag> getPartsWithTag(String tag) {
		Preconditions.checkArgument(tag.startsWith("@"), "Block tags in doc comments must start with '@'.");
		return parts.stream().filter(it -> it.getTag().equals(tag)).collect(Collectors.toList());
	}

	/**
	 * Returns true iff this doc comment contains at least one occurrence of the
	 * given tag in its tag section.
	 * 
	 * @param tag
	 *            The tag which is being checked. Must start with {@code @}
	 * @return True if the given tag is present in this comment
	 */
	public boolean hasPartWithTag(String tag) {
		Preconditions.checkArgument(tag.startsWith("@"), "Block tags in doc comments must start with '@'.");
		return parts.stream().filter(it -> it.getTag().equals(tag)).findAny().isPresent();
	}

	/**
	 * Returns a new empty doc comment. It does not have any main description or tag
	 * in the tag section.
	 * 
	 * @return Empty doc comment
	 */
	public static DocComment empty() {
		return new DocComment("", Collections.emptyList());
	}

	/**
	 * Parses the given raw comment text and tries to parse as doc comment.
	 * <p>
	 * If it is not a valid doc comment (i.e., it does not start with {@code /*} and
	 * end with {@code /*} ), an empty doc comment will be returned. Otherwise it
	 * will be split into main description and tag section, each block tag will be
	 * parsed and the leading * characters will be removed.
	 * 
	 * @param commentText
	 *            Comment text to be parsed
	 * @return Parsed doc comment
	 */
	public static DocComment parse(String commentText) {
		Preconditions.checkNotNull(commentText);

		if (!commentText.startsWith("/*") || !commentText.endsWith("*/")) {
			// skip if not correctly formatted
			return DocComment.empty();
		}

		// Remove '/**', '*/' and '*' from line start
		String cleanText = cleanupMlComment(commentText);

		List<String> partTexts = Arrays.asList(cleanText.split("(?m)(?=^@[^\\s])"));
		// System.out.println(partTexts);
		// System.err.println("Split into " + partTexts.size());
		Preconditions.checkState(partTexts.size() >= 1);

		String description = partTexts.get(0).trim();
		List<DocCommentBlockTag> parts = new ArrayList<>();
		Pattern tagParserPattern = Pattern.compile("(?s)^\\s*(@[^\\s]+)\\s+(.*)$");

		for (String partText : partTexts.subList(1, partTexts.size())) {
			Matcher matcher = tagParserPattern.matcher(partText);
			Preconditions.checkState(matcher.find(),
					"Illegal doc comment, cannot be parsed as tag-value pair: " + partText);
			DocCommentBlockTag part = new DocCommentBlockTag(matcher.group(1), matcher.group(2).trim());
			parts.add(part);
		}

		return new DocComment(description, parts);
	}

	static String cleanupMlComment(String commentText) {
		// Package private for testing
		Preconditions.checkArgument(commentText.startsWith("/*"), "The given comment does not start with '/*'.");
		Preconditions.checkArgument(commentText.endsWith("*/"), "The given comment does not end with '*/'.");

		// Remove '/**', '*/'
		String cleanText = commentText.replaceAll("^/(\\*)+", "").replaceAll("(\\*)+/$", "");
		// Remove '*' from beginning of lines
		cleanText = cleanText.replaceAll("(?m)^[ \t]*\\*[ \\t]+", "");

		return cleanText.trim();
	}
}
