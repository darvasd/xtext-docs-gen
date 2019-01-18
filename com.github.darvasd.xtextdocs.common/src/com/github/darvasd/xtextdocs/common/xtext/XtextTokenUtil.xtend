package com.github.darvasd.xtextdocs.common.xtext

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.TerminalRule
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

/**
 * Utility class for specific Xtext token manipulation.
 */
class XtextTokenUtil {
	/**
	 * Like {@link NodeModelUtils.getTokenText} but keeps original whitespace.
	 */
	static def tokenTextOrUnknown(EObject e) {
		val ruleNode = NodeModelUtils.getNode(e);
		if (ruleNode === null) {
			return "unknown";
		} else {
			val tokenText = ruleNode.leafNodes.filter[it | !isCommentNode(it)].map[it | it.text].join;
			// Not using the NodeModelUtils.getTokenText as it would collapse the whitespaces.
			return tokenText.trim().cleanupUnnecessaryNewlines();
		}
	}
	
	/**
	 * Removes consecutive new lines (even if there are whitespaces in the empty line)
	 * and returns the result.
	 */
	static def String cleanupUnnecessaryNewlines(String text) {
		return text.replaceAll("\r?\n[ \t]*(\r?\n)", "$1");
	}
	
	/**
	 * Returns true iff the given node is a comment node (single- or multi-line).
	 */
	static def isCommentNode(ILeafNode node) {
		val grammarElem = node.grammarElement;
		if (grammarElem instanceof TerminalRule) {
			return (grammarElem.name.equals("ML_COMMENT") || grammarElem.name.equals("SL_COMMENT"));
		}
		return false;
	}
}
