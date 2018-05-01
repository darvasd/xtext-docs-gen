/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.xtext.AbstractRule;
import org.eclipse.xtext.Grammar;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;

import com.github.darvasd.xtextdocs.ruledoc.RuleDoc;
import com.github.darvasd.xtextdocs.doccomment.DocComment;
import com.github.darvasd.xtextdocs.formatter.IGrammarDocsFormatter;
import com.github.darvasd.xtextdocs.ruledoc.GrammarDoc;

/**
 * Utility class containing the entry points for the documentation generation
 * based on a parsed Xtext grammar ({@link Grammar}).
 */
public final class DocsGenerator {
	private DocsGenerator() {
		// Utility class.
	}

	/**
	 * Generates a formatted textual documentation for the given grammar, using the
	 * given formatter.
	 * 
	 * @param grammar
	 *            The grammar to be represented.
	 * @param formatter
	 *            The formatter to be used.
	 * @return Formatted textual documentation.
	 */
	public static CharSequence generateFormattedDoc(Grammar grammar, IGrammarDocsFormatter formatter) {
		GrammarDoc grammarDoc = createGrammarDocumentation(grammar);
		return formatter.formatGrammar(grammarDoc);
	}

	/**
	 * Creates and returns a documentation object for the grammar, including its
	 * rules.
	 * 
	 * @param grammarRootNode
	 *            The grammar to be represented.
	 * @return The grammar documentation.
	 * @see #extractRuleDocumentation(Grammar)
	 */
	public static GrammarDoc createGrammarDocumentation(Grammar grammarRootNode) {
		String headComment = getHeadComment(NodeModelUtils.findActualNodeFor(grammarRootNode));
		DocComment parsedComment = (headComment == null) ? DocComment.empty()
				: DocComment.parse(headComment);

		List<RuleDoc> rules = extractRuleDocumentation(grammarRootNode);

		return new GrammarDoc(grammarRootNode, rules, parsedComment);
	}

	/**
	 * Creates and returns the list of {@link RuleDoc} documentation objects for
	 * each rule contained in the given grammar.
	 * 
	 * @param grammar
	 *            The grammar containing the rules to be represented.
	 * @return The list of grammar rule documentations. Their order respects their
	 *         original order in the grammar.
	 */
	public static List<RuleDoc> extractRuleDocumentation(Grammar grammar) {
		List<RuleDoc> ret = new ArrayList<RuleDoc>();

		for (AbstractRule rule : grammar.getRules()) {
			String headComment = getHeadComment(NodeModelUtils.findActualNodeFor(rule));
			DocComment parsedComment = headComment == null ? DocComment.empty()
					: DocComment.parse(headComment);

			ret.add(RuleDoc.create(rule, parsedComment));
		}

		return ret;
	}

	/**
	 * Finds and returns the head comment attached to the given composite Xtext
	 * node.
	 * <p>
	 * The head comment is the first multi-line comment that precedes the given node
	 * in the grammar, or a single-line comment if it is not separated from the node
	 * by empty lines.
	 * 
	 * @param node
	 *            The node for which the head comment is looked up. May be
	 *            {@code null}, then the returned value is also {@code null}.
	 * @return Head comment for the given Xtext node. Returns {@code null} if the
	 *         given node is {@code null} or no head comment was found.
	 */
	public static String getHeadComment(ICompositeNode node) {
		if (node == null) {
			return null;
		}

		String comment = null;
		boolean previousCommentMl = false;

		for (INode childNode : node.getAsTreeIterable()) {
			if (childNode.getGrammarElement() instanceof TerminalRule) {
				TerminalRule terminalRule = (TerminalRule) childNode.getGrammarElement();
				if (terminalRule.getName().equals("SL_COMMENT") || terminalRule.getName().equals("ML_COMMENT")) {
					comment = NodeModelUtils.getTokenText(childNode);
					previousCommentMl = terminalRule.getName().equals("ML_COMMENT");
				} else if (terminalRule.getName().equals("WS")) {
					String whiteSpace = NodeModelUtils.getTokenText(childNode);
					long newLines = whiteSpace.chars().filter(ch -> ch == '\n').count();
					if (newLines >= 1 && !previousCommentMl) {
						comment = null;
					}
					previousCommentMl = false;
				}
			}

			if (childNode.getGrammarElement() instanceof RuleCall) {
				RuleCall ruleCall = (RuleCall) childNode.getGrammarElement();
				if (ruleCall.getRule().getName().equals("ID")) {
					// This is the name of the rule to be defined by the node
					break;
				}
			}

		}

		return comment;
	}
}
