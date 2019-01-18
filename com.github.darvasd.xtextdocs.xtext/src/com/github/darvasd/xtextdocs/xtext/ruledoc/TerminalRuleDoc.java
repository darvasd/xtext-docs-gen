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

import org.eclipse.xtext.TerminalRule;

import com.github.darvasd.xtextdocs.xtext.doccomment.DocComment;
import com.google.common.base.Preconditions;

/**
 * Represents the documentation attached to a {@link TerminalRule} Xtext rule.
 */
public class TerminalRuleDoc extends ReferenceRuleDoc {
	private TerminalRule rule;

	/**
	 * Creates a new documentation for the given terminal rule with the given head
	 * comment.
	 * 
	 * @param rule
	 *            Represented terminal rule. Shall not be {@code null}.
	 * @param headComment
	 *            Head comment attached to the represented rule. Shall not be
	 *            {@code null}.
	 */
	public TerminalRuleDoc(TerminalRule rule, DocComment headComment) {
		super(headComment);

		this.rule = Preconditions.checkNotNull(rule);
	}

	@Override
	public TerminalRule getRule() {
		return rule;
	}

	/**
	 * Returns true iff this rule is a terminal fragment.
	 * 
	 * @return True if this rule is a fragment
	 */
	public boolean isTerminalFragment() {
		return rule.isFragment();
	}
}
