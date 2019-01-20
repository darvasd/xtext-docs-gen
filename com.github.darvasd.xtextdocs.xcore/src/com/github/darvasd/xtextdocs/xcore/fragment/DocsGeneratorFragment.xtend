package com.github.darvasd.xtextdocs.xcore.fragment

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xcore.resource.XcoreResource
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtend.lib.annotations.Accessors
import java.nio.file.Paths
import java.io.FileWriter
import com.github.darvasd.xtextdocs.xcore.formatter.IXcoreDocsFormatter
import org.apache.log4j.Logger

/**
 * Xcore documentation generation fragment to be used in MWE2 workflows.
 */
class DocsGeneratorFragment implements IWorkflowComponent {
	private final static Logger LOG = Logger.getLogger(DocsGeneratorFragment);
	
	/**
	 * The URI of the Xcore metamodel to be documented.
	 * <p>
	 * Mandatory.
	 */
	@Accessors String uri;
	
	/**
	 * The file name of the generated Xcore metamodel documentation.
	 * <p>
	 * Mandatory.
	 */
	@Accessors String outputFileName;
	
	/**
	 * Formatted documentation generator to be used.
	 * <p>
	 * Mandatory.
	 */
	 @Accessors IXcoreDocsFormatter formatter;
	
	override invoke(IWorkflowContext ctx) {
		val ResourceSet resourceSet = new ResourceSetImpl();
		val res = resourceSet.getResource(URI.createURI(getUri()), true);

		if (res instanceof XcoreResource) {
			if (outputFileName !== null) {				
				val outFile = Paths.get(outputFileName).toAbsolutePath.toString;
				val writer = new FileWriter(outFile);
    			writer.write(formatter.generateDocs(res).toString);
    			writer.close();
				LOG.info('''Xcore documentation using '«formatter.class.simpleName»' written to '«outputFileName».' ''');
			} else {
				// Error handling (without breaking the workflow)
				LOG.error("Unknown output file name ('outputFileName'), impossible to generate the documentation.");
				return;
			}
		} else {
			// Error handling (without breaking the workflow)
			LOG.error("The resource loaded for the given URI is not an Xcore resource.");
			return;
		}
	}
	
	override postInvoke() {
	}

	override preInvoke() {
	}
}
