/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.xtext.ruledoc;

import java.util.Collections;
import java.util.List;

import org.eclipse.xtext.Grammar;

import com.github.darvasd.xtextdocs.xtext.ruledoc.RuleDoc;
import com.github.darvasd.xtextdocs.xtext.doccomment.DocComment;
import com.google.common.base.Preconditions;

/**
 * Represents the documentation attached to a {@link Grammar} Xtext grammar.
 */
public class GrammarDoc {
	/** Represented grammar. Never {@code null}. */
	private Grammar grammar;

	/** List of rule documentations. Never {@code null}. */
	private List<RuleDoc> rules;

	/** Head doc comment attached to the grammar. Never {@code null}. */
	private DocComment headComment;

	/**
	 * Creates a new grammar documentation descriptor with the given head comment
	 * and rule descriptions.
	 * 
	 * @param grammar
	 *            The represented Xtext grammar. Shall not be {@code null}.
	 * @param rules
	 *            The rule documentations of the represented grammar. Shall not be
	 *            {@code null}.
	 * @param headComment
	 *            Head comment for the grammar. Shall not be {@code null}.
	 */
	public GrammarDoc(Grammar grammar, List<RuleDoc> rules, DocComment headComment) {
		this.grammar = Preconditions.checkNotNull(grammar);
		this.rules = Preconditions.checkNotNull(rules);
		this.headComment = Preconditions.checkNotNull(headComment);
	}

	/**
	 * Returns the represented Xtext grammar.
	 * 
	 * @return Grammar. Never {@code null}.
	 */
	public Grammar getGrammar() {
		return grammar;
	}

	/**
	 * Returns the name of this grammar.
	 * 
	 * @return Name of the grammar.
	 */
	public String getGrammarName() {
		return grammar.getName();
	}

	/**
	 * Returns the documentations of the rules contained in this grammar.
	 * 
	 * @return Documentation for rules. Unmodifiable list. Never {@code null}.
	 */
	public List<RuleDoc> getRules() {
		return Collections.unmodifiableList(rules);
	}

	/**
	 * Returns the head comment of this grammar.
	 * 
	 * @return Grammar's head comment. Never {@code null}.
	 */
	public DocComment getHeadComment() {
		return headComment;
	}
}
