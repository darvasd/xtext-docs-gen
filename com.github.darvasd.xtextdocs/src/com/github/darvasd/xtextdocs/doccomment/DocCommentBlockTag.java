/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.doccomment;

import com.google.common.base.Preconditions;

/**
 * Class to represent a doc comment block tag with its argument.
 * <p>
 * For example, this class can represent the {@code @example ABC DEF} section of
 * a doc comment, where the tag is {@code @example}, the argument is
 * {@code ABC DEF}.
 * <p>
 * Immutable.
 */
public class DocCommentBlockTag {
	private String tag;
	private String argument;

	/**
	 * Creates a new doc comment tag-argument pair.
	 * 
	 * @param tag
	 *            Tag. Shall not be {@code null}.
	 * @param argument
	 *            Argument. Shall not be {@code null}.
	 * @throws IllegalArgumentException
	 *             if the given tag does not start with {@code @}.
	 * @throws NullPointerException
	 *             if the tag or the argument is null.
	 */
	DocCommentBlockTag(String tag, String argument) {
		Preconditions.checkArgument(tag.startsWith("@"));
		this.tag = Preconditions.checkNotNull(tag);
		this.argument = Preconditions.checkNotNull(argument);
	}

	/**
	 * @return Tag. Never {@code null}.
	 */
	public String getTag() {
		return tag;
	}

	/**
	 * @return Argument. Never {@code null}.
	 */
	public String getArgument() {
		return argument;
	}
}
