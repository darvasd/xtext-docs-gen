/*********************************************************************
 * Copyright (c) 2018 Daniel Darvas
 * 
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 * 
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

package com.github.darvasd.xtextdocs.doccomment

import org.junit.Test
import org.junit.Assert

class DocCommentTest {
	@Test
	def cleanupMlCommentTest1() {
		val input = '''
		/**
		 * This is a description.
		 * 
		 * End of description.
		 * @tag1 This is the value of
		 *       tag 1.
		 * @tag2 This is tag 2.
		 **/'''

		val expected = '''
		This is a description.
		
		End of description.
		@tag1 This is the value of
		tag 1.
		@tag2 This is tag 2.''';

		val actual = DocComment.cleanupMlComment(input);

		Assert.assertEquals(expected, actual);
	}

	@Test
	def parseTest1() {
		val input = '''
		/**
		 * This is a description.
		 * 
		 * End of description.
		 * @tag This is the value of
		 *       tag 1.
		 * @tag This is tag 2.
		 **/'''

		val actual = DocComment.parse(input);

		Assert.assertNotNull(actual);
		Assert.assertEquals('''
		This is a description.
		
		End of description.'''.toString.trim, actual.getMainDescription);
		Assert.assertEquals(2, actual.getParts.size);
		Assert.assertEquals("@tag", actual.getParts.get(0).getTag);
		Assert.assertEquals('''
		This is the value of
		tag 1.'''.toString, actual.getParts.get(0).getArgument);
		Assert.assertEquals("@tag", actual.getParts.get(1).getTag);
		Assert.assertEquals("This is tag 2.", actual.getParts.get(1).getArgument);
	}
}
