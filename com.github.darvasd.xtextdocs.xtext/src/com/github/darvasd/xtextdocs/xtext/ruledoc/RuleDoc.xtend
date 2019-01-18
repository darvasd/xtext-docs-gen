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

import org.eclipse.xtext.AbstractRule;

import org.eclipse.xtext.TerminalRule
import com.google.common.base.Preconditions
import com.github.darvasd.xtextdocs.xtext.doccomment.DocComment
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.EnumRule

/**
 * Generic representation of documentation attached to an {@link AbstractRule} Xtext rule.
 */
public abstract class RuleDoc {
	private DocComment headComment;

	/**
	 * Creates a new Xtext rule representation with the given head comment.
	 * @param headComment Parsed head comment. Shall not be {@null}.
	 */
	public new(DocComment headComment) {
		this.headComment = Preconditions.checkNotNull(headComment);
	}

	/**
	 * Returns the Xtext rule that is represented by this.
	 */
	public abstract def AbstractRule getRule();

	/**
	 * Returns the name of the represented grammar rule.
	 */
	public def String getRuleName() {
		return getRule().getName();
	}

	/**
	 * Returns the head comment attached to the represented grammar rule.
	 * @return Head comment. Never {@code null}.
	 */
	public def DocComment getHeadComment() {
		return headComment;
	}

	/**
	 * Creates an appropriate {@link RuleDoc} representation for the given 
	 * rule, with the given head comment.
	 */
	public def static RuleDoc create(AbstractRule rule, DocComment headComment) {
		switch (rule) {
			ParserRule: return new ParserRuleDoc(rule, headComment)
			EnumRule: return new EnumRuleDoc(rule, headComment)
			TerminalRule: return new TerminalRuleDoc(rule, headComment)
		}
	}
}
