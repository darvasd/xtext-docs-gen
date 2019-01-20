package com.github.darvasd.xtextdocs.xcore.formatter;

import org.eclipse.emf.ecore.xcore.resource.XcoreResource;

/**
 * Interface to be used for generating a documentation for an Xcore metamodel description.
 */
public interface IXcoreDocsFormatter {
	/**
	 * Returns an appropriately formatted documentation of the given Xcore resource.
	 * @param resource Xcore resource to be documented
	 * @return Generated documentation
	 */
	public CharSequence generateDocs(XcoreResource resource);
}
