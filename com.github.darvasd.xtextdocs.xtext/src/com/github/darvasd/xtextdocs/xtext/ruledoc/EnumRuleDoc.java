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

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.EnumLiteralDeclaration;
import org.eclipse.xtext.EnumRule;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;

import com.github.darvasd.xtextdocs.xtext.ruledoc.RuleDoc;
import com.github.darvasd.xtextdocs.xtext.DocsGenerator;
import com.github.darvasd.xtextdocs.xtext.doccomment.DocComment;
import com.google.common.base.Preconditions;

/**
 * Represents the documentation attached to a {@link EnumRule} Xtext rule.
 */
public class EnumRuleDoc extends RuleDoc {

	/**
	 * Represents the documentation attached to a {@link EnumLiteralDeclaration}
	 * Xtext enum literal declaration.
	 */
	public static class EnumLiteralDoc {
		private EnumLiteralDeclaration declaration;
		private String literalText = null;
		private EEnumLiteral literalEnum = null;
		private Optional<DocComment> comment = Optional.empty();

		protected EnumLiteralDoc(EnumLiteralDeclaration declaration) {
			this.declaration = Preconditions.checkNotNull(declaration);

			if (declaration.getLiteral() != null) {
				this.literalText = declaration.getLiteral().getValue();
			}
			this.literalEnum = declaration.getEnumLiteral();

			// TODO This solution is not very nice, we should not have head comment parsing
			// here.
			String commentText = DocsGenerator.getHeadComment(NodeModelUtils.getNode(declaration));
			if (commentText != null) {
				this.comment = Optional.of(DocComment.parse(commentText));
			}
		}

		/**
		 * Returns the represented Xtext enum literal declaration.
		 * 
		 * @return Enum literal declaration. Never {@code null}.
		 */
		public EnumLiteralDeclaration getDeclaration() {
			return declaration;
		}

		/**
		 * Returns the text representing this literal in the grammar.
		 * 
		 * @return Literal text. May be {@code null} if not possible to determine.
		 */
		public String getLiteralText() {
			return literalText;
		}

		/**
		 * Returns the represented EMF enum literal. Note: Multiple {@link EnumRuleDoc}
		 * can represent the same EMF enum literal.
		 * 
		 * @return EMF enum literal. May be {@code null} if not possible to determine.
		 */
		public EEnumLiteral getLiteralEnum() {
			return literalEnum;
		}

		/**
		 * Returns the parsed doc comment attached to the literal.
		 * 
		 * @return Documentation comment if exists, otherwise {@link Optional#empty()}. Never
		 *         {@code null}.
		 */
		public Optional<DocComment> getComment() {
			return comment;
		}
	}

	private EnumRule rule;
	private List<EnumLiteralDoc> literals = new ArrayList<>();

	/**
	 * Creates a new enum rule representation for the given Xtext parser rule,
	 * having the given head comment.
	 * 
	 * @param rule
	 *            The Xtext enum rule to be represented.
	 * @param headComment
	 *            The head comment attached to the represented rule. Shall not be
	 *            {@null}.
	 */
	public EnumRuleDoc(EnumRule rule, DocComment headComment) {
		super(headComment);
		this.rule = rule;

		TreeIterator<EObject> iter = rule.getAlternatives().eAllContents();
		while (iter.hasNext()) {
			EObject current = iter.next();
			if (current instanceof EnumLiteralDeclaration) {
				literals.add(new EnumLiteralDoc((EnumLiteralDeclaration) current));
			}
		}
	}

	@Override
	public EnumRule getRule() {
		return rule;
	}

	/**
	 * Returns the literals defining this enum rule.
	 * 
	 * @return List of literals. Unmodifiable, never {@code null}.
	 */
	public List<EnumLiteralDoc> getLiterals() {
		return Collections.unmodifiableList(literals);
	}
}
