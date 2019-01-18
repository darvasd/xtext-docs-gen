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

import org.junit.Assert
import org.junit.Test

class MarkdownTextFormatterTest {
	@Test
	def escapeTest1() {
		val expected = '''a\_b\_c def''';
		val actual = MarkdownTextFormatter.INSTANCE.escape("a_b_c def");

		Assert.assertEquals(expected, actual);
	}
	
	@Test
	def escapeTest2() {
		val expected = '''a\*a+b\*b= c\*c''';
		val actual = MarkdownTextFormatter.INSTANCE.escape('''a*a+b*b= c*c''');

		Assert.assertEquals(expected, actual);
	}
	
	@Test
	def boldTest1() {
		val expected = '''**content**''';
		val actual = MarkdownTextFormatter.INSTANCE.bold("content");

		Assert.assertEquals(expected, actual);
	}

	@Test
	def boldTest2() {
		val expected = '''
		**first line**
		**second line**''';
		val actual = MarkdownTextFormatter.INSTANCE.bold('''
		first line
		second line''');

		Assert.assertEquals(expected, actual);
	}

	@Test
	def italicTest1() {
		val expected = '''_content_''';
		val actual = MarkdownTextFormatter.INSTANCE.italic("content");

		Assert.assertEquals(expected, actual);
	}

	@Test
	def italicTest2() {
		val expected = '''
		_first line_
		_second line_''';
		val actual = MarkdownTextFormatter.INSTANCE.italic('''
		first line
		second line''');

		Assert.assertEquals(expected, actual);
	}
}
