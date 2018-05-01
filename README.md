# xtext-docs-gen
A simple overview documentation generation for Xtext grammars.

## Example
To get the gist of it, have a look at the example below, illustrating the documentation generation.

[[docs/small_example.png]]

To check a more comprehensive example, see the [documentation](docs/ExampleDomainmodelDocs.md) generated for the [Domainmodel example grammar](examples/org.example.domainmodel/src/org/example/domainmodel/Domainmodel.xtext), using [this workflow file](examples/org.example.domainmodel/src/org/example/domainmodel/GenerateDomainmodel.mwe2).

## Usage
1. Add `com.github.darvasd.xtextdocs` as depencency to the `MANIFEST.MF` of your plug-in project containing the Xtext grammar.
   * You can use the http://darvasd.github.io/xtext-docs-gen/release/ update site to fetch it.
1. Add the documentation generation to your workflow description (`.mwe2` file next to your grammar), as a fragment for your language configuration (`XtextGeneratorLanguage` instance). For example:
   ```
	language = StandardLanguage {
	[...]
		// xtext-docs-gen
		fragment = DocsGeneratorFragment auto-inject {
			outputFileName = "docs.md"
			formatter = MarkdownDocsFormatter {
				includeSimplifiedGrammar = true
				mainTitle = "Title text" // optional
			}
		}
	[...]
	}
   ```
   
   You will need some imports:
   ```
   import com.github.darvasd.xtextdocs.fragment.DocsGeneratorFragment
   import com.github.darvasd.xtextdocs.formatter.MarkdownDocsFormatter
   ```
1. If you execute your workflow, the grammar documentation should be generated. You can see it in the log as well:
   ```
   ...
   5214 [main] INFO  docs.fragment.DocsGeneratorFragment  - Generating grammar documentation
   5242 [main] INFO  docs.fragment.DocsGeneratorFragment  - Grammar documentation using 'MarkdownDocsFormatter' written to 'docs.md' 
   ...
   ```
   
## Download

Use `https://darvasd.github.io/xtext-docs-gen/release/` as update site and install the _Xtext grammar documentation generator_ plug-in.

## License

Copyright (c) 2018 Daniel Darvas

This program and the accompanying materials are made available under the terms of the **Eclipse Public License 2.0** which is available at https://www.eclipse.org/legal/epl-2.0/ .

The Domainmodel grammar is a commented version of the one available in the Xtext documentation, located at  https://www.eclipse.org/Xtext/documentation/102_domainmodelwalkthrough.html. See its [GitHub page](https://github.com/eclipse/xtext/edit/website-published/xtext-website/documentation/102_domainmodelwalkthrough.md) for the list of contributors. Used for demonstration purposes only. 