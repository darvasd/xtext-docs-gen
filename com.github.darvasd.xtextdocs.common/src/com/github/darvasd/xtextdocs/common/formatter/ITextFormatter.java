/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.common.formatter;

import java.util.List;

/**
 * Interface for basic text formatting operations. A class implementing this
 * interface shall be able to represent the given raw text using the desired
 * formatting.
 */
public interface ITextFormatter {
	/**
	 * Returns the given original text escaped.
	 * 
	 * @param original
	 *            Original text.
	 * @return Original text, escaped where necessary.
	 */
	String escape(String original);

	/**
	 * Returns the given original text as bold.
	 * <p>
	 * For example, for the input {@code abc} a Markdown implementation may return
	 * {@code **abc**}, a HTML implementation may return {@code <b>abc</b>}, etc.
	 * 
	 * @param original
	 *            Original text. Can be {@code null}.
	 * @return Original text as bold. Returns empty string (without any formatting
	 *         characters) if the argument is {@code null} or empty string.
	 */
	String bold(String original);

	/**
	 * Returns the given original text as italic.
	 * 
	 * @param original
	 *            Original text. Can be {@code null}.
	 * @return Original text as italic. Returns empty string (without any formatting
	 *         characters) if the argument is {@code null} or empty string.
	 */
	String italic(String original);

	/**
	 * Returns the given original text as inline code.
	 * 
	 * @param original
	 *            Original text. Can be {@code null}.
	 * @return Original text as inline code. Returns empty string (without any
	 *         formatting characters) if the argument is {@code null} or empty
	 *         string.
	 */
	String inlineCode(String original);

	/**
	 * Returns the given original text as (multiline) code block.
	 * 
	 * @param original
	 *            Original text.
	 * @return Original text as code block.
	 */
	String codeBlock(String original);

	/**
	 * Returns a line break representation.
	 * 
	 * @return Line break.
	 */
	String newLine();

	/**
	 * Returns a link to the given target with the given text.
	 * 
	 * @param text
	 *            Text of the link.
	 * @param target
	 *            Target of the link.
	 * @return Textual representation of the link.
	 */
	String link(String text, String target);

	/**
	 * Returns the given lines as unordered list.
	 * 
	 * @param originals
	 *            Original text lines.
	 * @return Original text lines formatted as unordered list.
	 */
	String unorderedList(List<String> originals);
}
