/*********************************************************************
* Copyright (c) 2018 Daniel Darvas
*
* This program and the accompanying materials are made
* available under the terms of the Eclipse Public License 2.0
* which is available at https://www.eclipse.org/legal/epl-2.0/
*
* SPDX-License-Identifier: EPL-2.0
**********************************************************************/

package com.github.darvasd.xtextdocs.xtext.formatter

import com.github.darvasd.xtextdocs.xtext.doccomment.DocComment
import com.github.darvasd.xtextdocs.xtext.ruledoc.EnumRuleDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.EnumRuleDoc.EnumLiteralDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.GrammarDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.ParserRuleDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.ReferenceRuleDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.RuleDoc
import com.github.darvasd.xtextdocs.xtext.ruledoc.TerminalRuleDoc
import com.google.common.base.Preconditions
import com.google.common.base.Strings
import java.util.LinkedList
import java.util.List
import java.util.Map
import java.util.Queue
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.AbstractElement
import org.eclipse.xtext.AbstractRule
import org.eclipse.xtext.Action
import org.eclipse.xtext.Alternatives
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.CharacterRange
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.EnumLiteralDeclaration
import org.eclipse.xtext.Group
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.ParserRule
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.TerminalRule
import org.eclipse.xtext.UnorderedGroup
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.NegatedToken
import org.eclipse.xtext.Wildcard
import org.eclipse.xtext.UntilToken

class MarkdownDocsFormatter implements IGrammarDocsFormatter {
	private static final String EXAMPLE_TAG = "@example"
	private static final String VALIDATION_TAG = "@validation"
	
	@Accessors private boolean includeSimplifiedGrammar = true;
	@Accessors private boolean includeDotReferenceGraph = false;
	@Accessors private boolean gitbookLinkStyle = false;
	
	/**
	 * The main title text of the documentation to be generated.
	 * If not set ({@code null}), the title will be the full name of the grammar.
	 */
	@Accessors private String mainTitle = null;
	
	/**
	 * Title depth offset. If set to 0, the main title will be prefixed with {@code #}, 
	 * the second level titles with {@code ##}, etc.
	 * If it is greater than zero, the number of {@code #} characters will be increased
	 * with this number at each title.
	 */
	private int titleLevelOffset = 0;
	
	/**
	 * Sets the title depth offset. If set to 0, the main title will be prefixed with {@code #}, 
	 * the second level titles with {@code ##}, etc.
	 * If it is greater than zero, the number of {@code #} characters will be increased
	 * with this number at each title.
	 * <p>
	 * It is an ugly workaround to take a string as argument, but this is necessary
	 * as MWE2 does not support integer properties.
	 * See https://bugs.eclipse.org/bugs/show_bug.cgi?id=377068 .
	 */
	public def void setTitleLevelOffset(String value) {
		this.titleLevelOffset = Integer.parseInt(value);
	}

	/**
	 * Returns a Markdown-formatted document describing the given grammar,
	 * including all its rules.
	 * <p>
	 * If the value of {@code includeSimplifiedGrammar} is true, the document
	 * will contain a simplified BNF description of the grammar.
	 * If the value of {@code includeDotReferenceGraph} is true, a 
	 * GraphViz-style representation of the dependency between the grammar 
	 * rules will also be included.
	 * If the value of {@code gitbookLinkStyle} is true, the document will 
	 * use gitbook-style links and link anchors.
	 */
	public override CharSequence formatGrammar(GrammarDoc grammarDoc) {
		Preconditions.checkNotNull(grammarDoc, "grammarDoc");
		
		val Map<AbstractRule, RuleDoc> mapping = grammarDoc.rules.toMap([it|it.rule], [it|it]);

		'''
			«headerPrefix(1)» «mainTitle ?: grammarDoc.grammarName»
			
			«IF !grammarDoc.headComment.getMainDescription.nullOrEmpty»«grammarDoc.headComment.getMainDescription.docCommentFormattingToMd»«ENDIF»
			
			«IF !grammarDoc.grammar.usedGrammars.isEmpty»
				Included grammars:
				«FOR x : grammarDoc.grammar.usedGrammars»
					- `«x.name»`
				«ENDFOR»
			«ENDIF»
			
			«val metamodels = grammarDoc.grammar.metamodelDeclarations.filter[!alias.nullOrEmpty]»
			«IF !metamodels.isEmpty»
				Included metamodels:
				«FOR x : metamodels»
					- «x.alias» (`«x.EPackage.nsURI»`)
				«ENDFOR»
			«ENDIF»
			
			«headerPrefix(2)» Rules
			«FOR ruleDoc : grammarDoc.rules»
				«formatRule(ruleDoc, mapping)»
				
				
				
			«ENDFOR»
			
			«IF includeSimplifiedGrammar»
				«headerPrefix(2)» Simplified grammar
				«FOR rule : allUsedRules(grammarDoc.rules.get(0).rule)»
					**«rule.name»** ::= «formattedRuleDef(rule.alternatives)»;
					
				«ENDFOR»
			«ENDIF»
			
			«IF includeDotReferenceGraph»
				«dotRefGraph(grammarDoc.rules, grammarDoc.rules.get(0), mapping)»
			«ENDIF»
		'''
	}
	
	/**
	 * Returns a Markdown-formatted document describing the given grammar rule.
	 * <p>
	 * If the value of {@code gitbookLinkStyle} is true, the document will 
	 * use gitbook-style links and link anchors.
	 */
	public dispatch def CharSequence formatRule(RuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) {
	}

	public dispatch def CharSequence formatRule(ParserRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, "")»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToMd»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		«ruleReferences(ruleDoc, mapping)»
		
		«returns(ruleDoc.rule)»
		
		«ruleToCodeSnippet(ruleDoc.rule)»
	'''


	public dispatch def CharSequence formatRule(EnumRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, "enum")»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToMd»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		Literals:
		«FOR entry : getPerEnumLiteral(ruleDoc).entrySet.sortBy[it.key.name]»
			- «entry.key.name» («FOR textLit : entry.value.map[it | it.literalText] SEPARATOR ', '»`«textLit»`«ENDFOR»)
				«val firstCommentedLiteral = entry.value.findFirst[it | it.comment.isPresent && !it.comment.get.mainDescription.isNullOrEmpty]»«IF firstCommentedLiteral !== null» : «MarkdownTextFormatter.INSTANCE.italic(firstCommentedLiteral.comment.get.getMainDescription.docCommentFormattingToMd)»«ENDIF»
		«ENDFOR»
		
		«ruleToCodeSnippet(ruleDoc.rule)»
	'''
	
	
	private def getPerEnumLiteral(EnumRuleDoc ruleDoc) {
		val Map<EEnumLiteral, List<EnumLiteralDoc>> ret = newHashMap();
		for (enumLiteral : ruleDoc.literals.map[it | it.literalEnum].toSet) {
			ret.put(enumLiteral, ruleDoc.literals.filter[it.literalEnum == enumLiteral].toList);
		}
		return ret;
	}

	public dispatch def CharSequence formatRule(TerminalRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«ruleDocHeader(ruleDoc.ruleName, '''terminal«IF ruleDoc.isTerminalFragment» fragment«ENDIF»''')»
		«ruleDoc.headComment.getMainDescription.docCommentFormattingToMd»
		
		«validationPartIfExists(ruleDoc.headComment)»
		«examplePartIfExists(ruleDoc.headComment)»
		
		«ruleReferences(ruleDoc, mapping)»
		
		«ruleToCodeSnippet(ruleDoc.rule)»
	'''

	// Private helpers
		
	/**
	 * Returns all rules which are used from the given root rule (transitively),
	 * even if they are not in the current grammar.
	 */
	private def List<AbstractRule> allUsedRules(AbstractRule rootRule) {
		val List<AbstractRule> ret = newArrayList();
		val Queue<AbstractRule> toBeChecked = new LinkedList<AbstractRule>();
		toBeChecked.add(rootRule);
		
		while (!toBeChecked.isEmpty()) {
			val current = toBeChecked.remove();
			if (!ret.contains(current)) {
				ret.add(current);
				current.eAllContents.toIterable.filter(RuleCall).map[it | it.rule].forEach[it | toBeChecked.add(it)];
			}
		}
		
		return ret;
	}
	
	private def ruleDocHeader(String ruleName, String ruleType) {
		return '''«headerPrefix(3)» «ruleName» «IF !ruleType.nullOrEmpty»(«ruleType»)«ENDIF» «IF gitbookLinkStyle»{«toLink(ruleName)»}«ENDIF»'''
	}
	
	
	private def ruleToCodeSnippet(AbstractRule rule) '''
		```
		«tokenTextOrUnknown(rule)»
		```
	'''
	
	private def tokenTextOrUnknown(AbstractRule rule) {
		val ruleNode = NodeModelUtils.getNode(rule);
		if (ruleNode === null) {
			return "unknown";
		} else {
			val tokenText = ruleNode.leafNodes.filter[it | !isCommentNode(it)].map[it | it.text].join;
			// Not using the NodeModelUtils.getTokenText as it would collapse the whitespaces.
			return tokenText.trim().cleanupUnnecessaryNewlines();
		}
	}
	
	private def String cleanupUnnecessaryNewlines(String text) {
		// Remove consecutive new lines (even if there are whitespaces in the empty line)
		return text.replaceAll("\r?\n[ \t]*(\r?\n)", "$1");
	}
	
	private def isCommentNode(ILeafNode node) {
		val grammarElem = node.grammarElement;
		if (grammarElem instanceof TerminalRule) {
			return (grammarElem.name.equals("ML_COMMENT") || grammarElem.name.equals("SL_COMMENT"));
		}
		return false;
	}

	private def validationPartIfExists(DocComment headComment) '''
		«IF headComment.getPartsWithTag(VALIDATION_TAG).isEmpty == false»
			- **Validation:**
			   «FOR validationPart : headComment.getPartsWithTag(VALIDATION_TAG)»
			   	* «validationPart.getArgument.docCommentFormattingToMd»
			   «ENDFOR»
		«ENDIF»
	'''

	private def examplePartIfExists(DocComment headComment) '''
		«IF headComment.getPartsWithTag(EXAMPLE_TAG).isEmpty == false»
			- **Examples:**
			   «FOR validationPart : headComment.getPartsWithTag(EXAMPLE_TAG)»
			   	* «IF DocCommentTextUtil.containsCode(validationPart.getArgument)»«validationPart.getArgument.docCommentFormattingToMd»«ELSE»«'''`«validationPart.getArgument»`'''.toString.docCommentFormattingToMd»«ENDIF»
			   «ENDFOR»
		«ENDIF»
	'''
		
	private def ruleReferences(ReferenceRuleDoc ruleDoc, Map<AbstractRule, RuleDoc> mapping) '''
		«val refersTo = ruleDoc.refersTo.sortBy[it | it.name ?: ""]»
		«IF ruleDoc.refersTo.empty == false»
			**Refers to:**
			«FOR ref : refersTo»
				«IF mapping.containsKey(ref)»
					- «mapping.get(ref).ruleName.ruleNameAsLink»
				«ELSE»
					- «ref.name»
				«ENDIF»
			«ENDFOR»
			
		«ENDIF»
		«val referredBy = mapping.values.filter(ParserRuleDoc).filter[it | it.getRefersTo().contains(ruleDoc.rule)].toSet.sortBy[it.ruleName]»
		«IF referredBy.empty == false»
			**Referred by:**
			«FOR ref : referredBy»
				- «ref.ruleName.ruleNameAsLink»
			«ENDFOR»
		«ENDIF»
	'''

	private def returns(ParserRule rule) {
		if (rule.type.metamodel.alias.nullOrEmpty) {
			// it is in the generated metamodel, not so interesting
			return "";
		} else {
			return '''**Returns:** `«rule.type.metamodel.alias»::«rule.type.classifier.name»`'''
		}
	}
	
	private def ruleNameAsLink(String ruleName) {
		return MarkdownTextFormatter.INSTANCE.link(ruleName, toLink(ruleName));
	}
	
	private def dotRefGraph(List<RuleDoc> rules, RuleDoc rootRule, Map<AbstractRule, RuleDoc> mapping) '''
		«headerPrefix(2)» Rule dependencies
		
		```dot
		digraph G {
			node[ shape="rectangle", style="filled" ];
			
			// Highlight root rule
			«rootRule.ruleName» [ color="red" ];
			
			«FOR rule : rules»
				«rule.ruleName» [ color="«ruleDotNodeColor(rule, rootRule)»", fillcolor="«ruleDotNodeFillColor(rule)»" ];
				«IF rule instanceof ReferenceRuleDoc»
					«FOR ref : rule.refersTo»
«««					external dependencies are skipped (e.g. ID)
						«IF mapping.containsKey(ref)»
«««						internal dependendy
							«rule.ruleName» -> «mapping.get(ref).ruleName»;
						«ELSE»
«««						external dependency
							«ref.name» [ color="«ruleDotNodeColor(rule, rootRule)»", fillcolor="«ruleDotNodeFillColor(rule)»", style="dashed" ];
							«rule.ruleName» -> «ref.name» [ style="dashed" ];
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
		}
		```
	'''
	
	private def ruleDotNodeColor(RuleDoc ruleDoc, RuleDoc rootRule) {
		if (ruleDoc == rootRule) {
			return "red";
		} else {
			return "black";
		}
	}
	
	private def ruleDotNodeFillColor(RuleDoc ruleDoc) {
		switch (ruleDoc) {
			EnumRuleDoc: return "#ffffcc"
			ParserRuleDoc: return "#e6e6ff"
			TerminalRuleDoc: return if (ruleDoc.isTerminalFragment) "#e6ffe6" else "#ccffcc"
			default: return "white"
		}
	}
		
	/**
	 * Returns a BNF-like simplified representation of the given rule 
	 * definition, with Markdown formatting.
	 */
	private def CharSequence formattedRuleDef(AbstractElement element) {
		return formattedRuleDef(element, false);
	}

	/**
	 * Returns a BNF-like simplified representation of the given rule 
	 * definition, with Markdown formatting.
	 * @param element Element to be represented.
	 * @param parenNeeded If true and the represented element is not atomic, 
	 * it will be surrounded with parentheses.
	 * @return Simplified textual representation of the given rule definition.
	 */
	private def dispatch CharSequence formattedRuleDef(AbstractElement element, boolean parenNeeded) {
		return '''??«element.class.simpleName»??'''
	}

	private def dispatch CharSequence formattedRuleDef(Void element, boolean parenNeeded) {
		return '''(null)'''
	}

	private def dispatch CharSequence formattedRuleDef(Alternatives element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«FOR it : element.elements SEPARATOR ' | '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(UnorderedGroup element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«FOR it : element.elements SEPARATOR ' & '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Group element, boolean parenNeeded) {
		return '''«IF parenNeeded && element.elements.size > 1»(«ENDIF»«IF element.guardCondition !== null»<...>«ENDIF»«FOR it : element.elements SEPARATOR '   '»«formattedRuleDef(it, element.elements.size > 1)»«ENDFOR»«IF parenNeeded && element.elements.size > 1»)«ENDIF»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Assignment element, boolean parenNeeded) {
		return '''«formattedRuleDef(element.terminal, true)»«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(CrossReference element, boolean parenNeeded) {
		return '''«formattedRuleDef(element.terminal)»«element.cardinality»''';
	}
	
	private def dispatch CharSequence formattedRuleDef(Action element, boolean parenNeeded) {
		return ''
	}
	
	private def dispatch CharSequence formattedRuleDef(NegatedToken element, boolean parenNeeded) {
		return '''!(«formattedRuleDef(element.terminal)»)«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Wildcard element, boolean parenNeeded) {
		return '''_._«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(UntilToken element, boolean parenNeeded) {
		return ''' --> «formattedRuleDef(element.terminal)» «element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(Keyword element, boolean parenNeeded) {
		return '''`«keywordText(element.value)»`«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(RuleCall element, boolean parenNeeded) {
		return '''_«element.rule.name»_«element.cardinality»'''
	}
	
	private def dispatch CharSequence formattedRuleDef(EnumLiteralDeclaration element, boolean parenNeeded) {
		return formattedRuleDef(element.literal);
	}
	
	private def dispatch CharSequence formattedRuleDef(CharacterRange element, boolean parenNeeded) {
		return '''[«formattedRuleDef(element.left)»..«formattedRuleDef(element.right)»]«element.cardinality»''';
	}
	
	private def String keywordText(String keywordValue) {
		return keywordValue.replace("\t", "\\t").replace("\r", "\\r").replace("\n", "\\n");
	}
	
	private def String docCommentFormattingToMd(String text) {
		val escaped = MarkdownTextFormatter.INSTANCE.escape(text);
		val String resolved = DocCommentTextUtil.resolveLinks(escaped, MarkdownTextFormatter.INSTANCE, [it | toLink(it)]);
		return DocCommentTextUtil.format(resolved, MarkdownTextFormatter.INSTANCE);
	}
	
	private def String toLink(String text) {
		if (text.trim().matches("^https?://.*")) {
			return text;
		} else {
			if (gitbookLinkStyle) {
				return '''#«text.replaceAll("\\s", "-")»''';
			} else {
				return '''#«text.replaceAll("\\s", "-").toLowerCase»''';
			}
		}
	}
	
	private def String headerPrefix(int level) {
		return '''«Strings.repeat("#", level + titleLevelOffset)» ''';
	}
}
