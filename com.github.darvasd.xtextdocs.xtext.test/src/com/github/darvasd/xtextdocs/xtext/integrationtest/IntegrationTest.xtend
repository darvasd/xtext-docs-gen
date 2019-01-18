/*********************************************************************
 * Copyright (c) 2018 Daniel Darvas
 * 
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 * 
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

package com.github.darvasd.xtextdocs.xtext.integrationtest

import com.github.darvasd.xtextdocs.xtext.DocsGenerator
import com.google.common.base.Preconditions
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMIResource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.xtext.Grammar
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import com.github.darvasd.xtextdocs.xtext.formatter.MarkdownDocsFormatter

class IntegrationTest {
	private Grammar grammar;

	/**
	 * Loads the grammar metamodel for the integration tests.
	 * Note that the node model is not saved, i.e. the head comments will not be found.
	 */
	@Before
	def void loadExampleGrammar() {
		val fileName = "DomainmodelGrammar.xmi";

		val grammarFileResource = this.class.classLoader.getResource(fileName);
		Preconditions.checkNotNull(grammarFileResource, '''File «fileName» not found.''');

		val sourceUri = URI.createURI(grammarFileResource.toURI.toString);
		val XMIResource resource = new XMIResourceImpl(sourceUri);
		resource.load(null);
		val content = resource.getContents().get(0);

		Preconditions.checkNotNull(content);
		Preconditions.checkState(content instanceof Grammar);

		this.grammar = content as Grammar;
		EcoreUtil.resolveAll(this.grammar);
	}

	@Test
	def void test1() {
		val grammarDoc = DocsGenerator.createGrammarDocumentation(grammar);
		Assert.assertNotNull(grammarDoc);
		Assert.assertEquals(10, grammarDoc.rules.size);
	}

	@Test
	def void test2() {
		val grammarDocText = DocsGenerator.generateFormattedDoc(
			grammar,
			new MarkdownDocsFormatter() => [includeSimplifiedGrammar = true]
		).toString;
		Assert.assertNotNull(grammarDocText);

		val expectedWords = #{"Domainmodel", "PackageDeclaration", "entity", "::="};

		for (expectedWord : expectedWords) {
			Assert.assertTrue(grammarDocText.contains(expectedWord));
		}
	}
}
