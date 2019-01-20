/*********************************************************************
 * Copyright (c) 2018 Daniel Darvas
 * 
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 * 
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

package com.github.darvasd.xtextdocs.common.formatter

import org.junit.Test
import org.junit.Assert
import com.github.darvasd.xtextdocs.common.formatter.MarkdownTextFormatter

class DocCommentTextUtilTest {
	@Test
	def boldTest() {
		val input = '''abc <b>def</b> ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''abc «formatter.bold("def")» ghi''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}

	@Test
	def italicTest() {
		val input = '''abc <i>def</i> ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''abc «formatter.italic("def")» ghi''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}

	@Test
	def codeTest() {
		val input = '''abc {@code def} ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''abc «formatter.inlineCode("def")» ghi''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}
	
	@Test
	def ulTest1() {
		val input = '''
		First line
		<ul>
			<li>Item 1
			<li>Item 2
		</ul>''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''
			First line
			
			  - Item 1
			  - Item 2
		''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}
	
	@Test
	def ulTest2() {
		val input = '''
		First line<ul><li>Item 1</li><li>Item 2</li></ul>''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''
			First line
			  - Item 1
			  - Item 2
		''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}
	
	@Test
	def ulTest3() {
		val input = '''
		First line
		<ul>
			<li>Item {@code 1}
			<li>Item <b>2</b>
		</ul>''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''
			First line
			
			  - Item `1`
			  - Item **2**
		''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}

	@Test
	def multilineFormattingTest1() {
		val input = '''
		abc
		{@code def}
		<b>ghi</b>
		jkl''';
		val formatter = MarkdownTextFormatter.INSTANCE;
		val expected = '''
		abc
		«formatter.inlineCode("def")»
		«formatter.bold("ghi")»
		jkl''';

		Assert.assertEquals(expected, DocCommentTextUtil.format(input, formatter));
	}

	@Test
	def linkTest1() {
		val input = '''abc {@link def} ghi''';
		val expected = '''abc [def](DEF) ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;

		Assert.assertEquals(expected, DocCommentTextUtil.resolveLinks(input, formatter, [it|it.toUpperCase]));
	}

	@Test
	def linkTest2() {
		val input = '''abc {@linkplain def} ghi''';
		val expected = '''abc [def](DEF) ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;

		Assert.assertEquals(expected, DocCommentTextUtil.resolveLinks(input, formatter, [it|it.toUpperCase]));
	}
	
	@Test
	def linkTest3() {
		val input = '''abc ghi''';
		val expected = input;
		val formatter = MarkdownTextFormatter.INSTANCE;

		Assert.assertEquals(expected, DocCommentTextUtil.resolveLinks(input, formatter, [it|it.toUpperCase]));
	}
	
	@Test
	def linkTest4() {
		val input = '''abc {@linkplain http://eclipse.org Eclipse website} ghi''';
		val expected = '''abc [Eclipse website](HTTP://ECLIPSE.ORG) ghi''';
		val formatter = MarkdownTextFormatter.INSTANCE;

		Assert.assertEquals(expected, DocCommentTextUtil.resolveLinks(input, formatter, [it|it.toUpperCase]));
	}
	
	@Test
	def containsCodeTest1() {
		Assert.assertTrue(DocCommentTextUtil.containsCode("abc `def` ghi"));
		Assert.assertTrue(DocCommentTextUtil.containsCode("{@code abc} def ghi"));
		Assert.assertFalse(DocCommentTextUtil.containsCode("abc def ghi"));
		Assert.assertTrue(DocCommentTextUtil.containsCode("`abc`"));
		Assert.assertFalse(DocCommentTextUtil.containsCode("1.2345"));
	}
}
