/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.ruledoc;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.AbstractRule;
import org.eclipse.xtext.RuleCall;

import com.github.darvasd.xtextdocs.doccomment.DocComment;
import com.github.darvasd.xtextdocs.ruledoc.RuleDoc;

/**
 * Represents the documentation attached to a Xtext rule which may have
 * references to other {@link AbstractRule} Xtext rules.
 */
public abstract class ReferenceRuleDoc extends RuleDoc {
	private List<AbstractRule> refersTo = null;

	/**
	 * Creates a new rule documentation with the given head comment.
	 * 
	 * @param headComment
	 *            Head comment attached to the represented rule. Shall not be
	 *            {@code null}.
	 */
	public ReferenceRuleDoc(DocComment headComment) {
		super(headComment);
	}

	/**
	 * Returns a list of Xtext rules which are referred from this rule.
	 * 
	 * @return Unmodifiable list of rules referred from this rule.
	 */
	public List<AbstractRule> getRefersTo() {
		if (refersTo == null) {
			refersTo = Collections.unmodifiableList(new ArrayList<AbstractRule>(computeRefersTo()));
		}

		return refersTo;
	}

	private Collection<AbstractRule> computeRefersTo() {
		Set<AbstractRule> ret = new HashSet<>();
		TreeIterator<EObject> iter = getRule().getAlternatives().eAllContents();
		while (iter.hasNext()) {
			EObject current = iter.next();
			if (current instanceof RuleCall) {
				ret.add(((RuleCall) current).getRule());
			}
		}

		return ret;
	}
}
