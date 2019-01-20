package com.github.darvasd.xtextdocs.xcore.formatter

import org.eclipse.emf.codegen.ecore.genmodel.GenBase
import org.eclipse.emf.codegen.ecore.genmodel.GenClass
import org.eclipse.emf.codegen.ecore.genmodel.GenDataType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EModelElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.xcore.XAttribute
import org.eclipse.emf.ecore.xcore.XClass
import org.eclipse.emf.ecore.xcore.XClassifier
import org.eclipse.emf.ecore.xcore.XDataType
import org.eclipse.emf.ecore.xcore.XEnum
import org.eclipse.emf.ecore.xcore.XEnumLiteral
import org.eclipse.emf.ecore.xcore.XGenericType
import org.eclipse.emf.ecore.xcore.XModelElement
import org.eclipse.emf.ecore.xcore.XNamedElement
import org.eclipse.emf.ecore.xcore.XOperation
import org.eclipse.emf.ecore.xcore.XPackage
import org.eclipse.emf.ecore.xcore.XReference
import org.eclipse.emf.ecore.xcore.resource.XcoreResource
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.google.common.base.Strings
import java.util.TreeMap
import java.util.SortedMap
import com.github.darvasd.xtextdocs.common.xtext.XtextTokenUtil
import com.github.darvasd.xtextdocs.common.formatter.MarkdownTextFormatter
import com.github.darvasd.xtextdocs.common.formatter.DocCommentTextUtil

/**
 * Class to be used for generating a Markdown documentation for an Xcore metamodel description.
 */
class MarkdownXcoreDocsFormatter implements IXcoreDocsFormatter {

	private static val DOCUMENTATION_ANNOTATION_KEY = "documentation";

	private static val extension MarkdownTextFormatter mdFormatter = MarkdownTextFormatter.INSTANCE;

	/**
	 * The main title text of the documentation to be generated.
	 * If not set ({@code null}), the title will be the URI of the metamodel.
	 */
	@Accessors private String mainTitle = null;

	@Accessors boolean gitbookLinkStyle = true;

	@Accessors boolean showOriginalXcoreCode = true;

	@Accessors boolean includeToc = true;

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
	 * Map that stores (name, id) pairs. The stored 'id' is the anchor that is used for the definition of the class 'name'.
	 */
	private SortedMap<String, String> anchors = new TreeMap<String, String>();
	private int anchorCounter = 1;

	override generateDocs(XcoreResource resource) {
		fillAnchors(resource);

		return '''
			«headerPrefix(1)» «IF mainTitle === null»«resource.URI»«ELSE»«mainTitle»«ENDIF»
			
			«IF includeToc»
				«toc()»
			«ENDIF»
			
			«FOR p : resource.contents.filter(XPackage)»
				«representPackage(p)»
			«ENDFOR»
		'''
	}

	/**
	 * Generates a table of contents representation based on the stored anchors.
	 */
	private def toc() {
		return '''
			«headerPrefix(2)» Table of contents
			«FOR entry : anchors.entrySet»
				- «link(entry.key, entry.value)»
			«ENDFOR»
		''';
	}

	/**
	 * Generates unique anchors for the classifiers in the given resource.
	 */
	private def fillAnchors(XcoreResource resource) {
		for (EObject e : resource.allContents.toIterable) {
			if (e instanceof XClassifier) {
				anchors.put(e.name, "#anchor" + anchorCounter);
				anchorCounter++;
			}
		}
	}

	/**
	 * Represents the definition of an anchor.
	 * If no anchor exists for the given classifier, empty string is returned
	 */
	private def anchorDefinitionIfExists(XClassifier xClassifier) {
		if (anchors !== null && anchors.containsKey(xClassifier.name)) {
			if (gitbookLinkStyle) {
				return '''{«anchors.get(xClassifier.name)»}'''
			} else {
				return '''<a name="«anchors.get(xClassifier.name).replaceFirst("#", "")»"></a>'''
			}
		} else {
			return "";
		}
	}

	/**
	 * Represents the given package.
	 */
	private def representPackage(XPackage p) {
		'''
			«headerPrefix(2)» Package `«p.name»`
			
			«FOR xClass : p.eContents.filter(XClass)»
				«representClass(xClass)»
			«ENDFOR»
			
			«FOR xEnum : p.eContents.filter(XEnum)»
				«representEnum(xEnum)»
			«ENDFOR»
			
			«FOR xDataType : p.eContents.filter(XDataType)»
				«representDataType(xDataType)»
			«ENDFOR»
		'''
	}

	/**
	 * Represents the given class.
	 */
	private def representClass(XClass xClass) {
		val attributes = xClass.members.filter(XAttribute);
		val references = xClass.members.filter(XReference);
		val operations = xClass.members.filter(XOperation);

		return '''
			«headerPrefix(3)» «classHeader(xClass)» `«xClass.name»` «anchorDefinitionIfExists(xClass)»
			
			«getDocAnnotation(xClass).italic»
			
			«bold("Extends")»: «IF xClass.superTypes.isNullOrEmpty»`EObject`«ELSE»«FOR superType : xClass.superTypes SEPARATOR ', '»«representXType(superType)»«ENDFOR»«ENDIF»
			«IF xClass.instanceType !== null»
				Wraps: «xClass.instanceType.qualifiedName»
			«ENDIF»
			
			«IF !attributes.isEmpty»			
				«bold("Attributes")»:
				«FOR xAttribute : attributes» 
					«representAttribute(xAttribute)»
				«ENDFOR»
			«ENDIF»
			
			«IF !references.isEmpty»
				«bold("References")»:
				«FOR xReference : references» 
					«representReference(xReference)»
				«ENDFOR»
			«ENDIF»
			
			«IF !operations.isEmpty»
				«bold("Operations")»:
				«FOR xOperation : operations»
					«representOperation(xOperation)»
				«ENDFOR»
			«ENDIF»
			
			«printOriginalCode(xClass)»
		'''
	}

	/**
	 * Returns the type name to be used for the given class in the header. 
	 */
	private def classHeader(XClass xClass) {
		if (xClass.isInterface) {
			return "Interface"
		} else if (xClass.abstract) {
			return "Abstract class"
		} else {
			return "Class"
		}
	}

	/**
	 * Represents the given reference.
	 */
	private def representReference(XReference xReference) {
		return '''
			- «xReference.name.bold» «representMultiplicity(xReference.multiplicity)»: «representXType(xReference.type)»
			    «getDocAnnotation(xReference).italic.prefixIfNotEmpty("*").indentFromSecondLine(2)»
			    * Containment: «representReferenceContainment(xReference)»
			    «representModifiers(xReference).prefixIfNotEmpty("* Modifiers:")»
			    «representReferenceOpposite(xReference).prefixIfNotEmpty("* Opposite:")»
		  '''
	}

	/**
	 * Represents the given multiplicity as string.
	 * If the given multiplicity is null, an empty string is returned.
	 * Otherwise the returned representation is prefixed with a space.
	 */
	private def String representMultiplicity(int[] multiplicity) {
		if (multiplicity === null) {
			return "";
		} else if (multiplicity.length == 0) {
			// [] is shorthand for [0..*]
			return " [0..*]"
		} else if (multiplicity.length == 1) {
			val val1 = multiplicity.get(0);
			if (val1 == -1) {
				// [*] is shorthand for [0..*]
				return " [0..*]";
			} else {
				// [n] is shorthand for [n..n] (exactly n)
				return ''' [«multiplicity.get(0)»..«multiplicity.get(0)»]'''
			}
		} else if (multiplicity.length == 2) {
			if (multiplicity.get(1) == -1) {
				return ''' [«multiplicity.get(0)»..*]'''
			} else {
				return ''' [«multiplicity.get(0)»..«multiplicity.get(1)»]'''
			}
		} else {
			return " [?]";
		}
	}

	/**
	 * If the given reference has an opposite, this returns a textual reference to it.
	 * If the given reference does not have an opposite, empty string is returned.
	 */
	private def representReferenceOpposite(XReference reference) {
		if (reference.opposite === null) {
			return "";
		} else {
			return '''«representXType(reference.type)».«reference.opposite.name.inlineCode»'''
		}
	}

	/**
	 * Returns a string representing the containment type of the given reference. 
	 */
	private def representReferenceContainment(XReference xReference) {
		if (xReference.containment) {
			return "contains"
		} else if (xReference.container) {
			return "container"
		} else if (xReference.local) {
			return "local"
		} else {
			return "refers"
		}
	}

	/**
	 * Represents the modifiers of the given reference in a comma separated list.
	 */
	private def dispatch representModifiers(XReference x) {
		val list = newArrayList();

		if (x.unordered) {
			list.add("Unordered");
		}
		if (x.unique) {
			list.add("Unique");
		}
		if (x.readonly) {
			list.add("Readonly");
		}
		if (x.transient) {
			list.add("Transient");
		}
		if (x.volatile) {
			list.add("Volatile");
		}
		if (x.unsettable) {
			list.add("Unsettable");
		}
		if (x.derived) {
			list.add("Derived");
		}

		if (x.resolveProxies) {
			list.add("Resolving");
		}

		return list.join(", ");
	}

	/**
	 * Represents the given attribute.
	 */
	private def representAttribute(XAttribute xAttribute) {
		return '''
			- «xAttribute.name.bold» «representMultiplicity(xAttribute.multiplicity)»: «representXType(xAttribute.type)»
			    «getDocAnnotation(xAttribute).italic.prefixIfNotEmpty("*").indentFromSecondLine(2)»
			    «representModifiers(xAttribute).prefixIfNotEmpty("* Modifiers:")»
			    «xAttribute.defaultValueLiteral.prefixIfNotEmpty("* Default value:")»
		  '''
	}

	/**
	 * Represents the modifiers of the given attribute in a comma separated list.
	 */
	private def dispatch representModifiers(XAttribute x) {
		val list = newArrayList();

		if (x.unordered) {
			list.add("Unordered");
		}
		if (x.unique) {
			list.add("Unique");
		}
		if (x.readonly) {
			list.add("Readonly");
		}
		if (x.transient) {
			list.add("Transient");
		}
		if (x.volatile) {
			list.add("Volatile");
		}
		if (x.unsettable) {
			list.add("Unsettable");
		}
		if (x.derived) {
			list.add("Derived");
		}
		if (x.ID) {
			list.add("ID");
		}

		return list.join(", ");
	}

	/**
	 * Represents the given operator.
	 */
	private def representOperation(XOperation op) {
		return '''
			- «op.name.bold»(«representOperationParameters(op)») : «representXType(op.type)»
			    «getDocAnnotation(op).italic.prefixIfNotEmpty("*")»
			    «representOperationThrows(op).inlineCode.prefixIfNotEmpty("* Throws:")»
		'''
	}

	/**
	 * Represents the parameters of the given operator.
	 */
	private def representOperationParameters(XOperation op) {
		var modifiers = '''«IF op.unordered»unordered«ENDIF»«IF op.unique»«IF op.unordered», «ENDIF»unique«ENDIF»''';
		return '''«FOR param : op.parameters SEPARATOR ', '»«param.name» : «modifiers» «representXType(param.type)»«representMultiplicity(param.multiplicity)»«ENDFOR»''';
	}

	/**
	 * Represents the exceptions that can be thrown by the given operator.
	 */
	private def representOperationThrows(XOperation operation) {
		if (operation.exceptions === null) {
			return "";
		} else {
			return '''«FOR ex : operation.exceptions SEPARATOR ', '»«representXType(ex)»«ENDFOR»''';
		}
	}

	/**
	 * Represents the modifiers of the given operation in a comma separated list.
	 */
	private def dispatch representModifiers(XOperation x) {
		val list = newArrayList();

		if (x.unordered) {
			list.add("Unordered");
		}
		if (x.unique) {
			list.add("Unique");
		}

		return list.join(", ");
	}

	/**
	 * Represents the given enum.
	 */
	private def representEnum(XEnum xEnum) {
		return '''
			«headerPrefix(3)» Enum `«xEnum.name»` «anchorDefinitionIfExists(xEnum)»
			
			«getDocAnnotation(xEnum).italic»
			
			**Literals**:
			«FOR xLiteral : xEnum.literals» 
				- «representEnumLiteral(xLiteral)»
			«ENDFOR»
			
			«printOriginalCode(xEnum)»
		'''
	}

	/**
	 * Represents the given enum literal.
	 */
	private def representEnumLiteral(XEnumLiteral xLiteral) {
		return '''`«xLiteral.name»` «IF xLiteral.literal !== null»(«xLiteral.literal»)«ENDIF»«IF xLiteral.value != 0» = «xLiteral.value»«ENDIF»«xLiteral.docAnnotation.italic.prefixIfNotEmpty(":")»''';
	}

	/**
	 * Represents the given data type.
	 */
	private def representDataType(XDataType xDataType) {
		if (xDataType.instanceType === null) {
			return "";
		}

		return '''
			«headerPrefix(3)» Data Type `«xDataType.name»` «anchorDefinitionIfExists(xDataType)»
			
			«getDocAnnotation(xDataType).italic»
			
			- Wraps: `«xDataType.instanceType?.qualifiedName»` 
		''';

	// TODO typeParameters not supported
	}

	// Type representation dispatch
	/**
	 * Returns a representation for the given type. If possible, it will be represented as a link.
	 */
	private def dispatch CharSequence representEType(EModelElement type) {
		return '''Unknown type: «type»''';
	}

	private def dispatch CharSequence representEType(EDataType type) {
		return type.name;
	}

	private def dispatch CharSequence representEType(EClass type) {
		return type.name;
	}

	private def CharSequence representXType(XGenericType type) {

		try {
			val String typeStr = representType(type.type).toString.trim;
			if (anchors.containsKey(typeStr)) {
				return link(typeStr, anchors.get(typeStr));
			} else {
				return '''`«typeStr»`''';
			}
		} catch (Exception e) {
			// Fallback solution
			val tokenText = NodeModelUtils.getTokenText(NodeModelUtils.getNode(type));
			return '''`«tokenText»` (unresolved)''';
		}
	}

	private def dispatch CharSequence representType(GenBase type) {
		throw new IllegalArgumentException("Unknown type: " + type);
	}

	private def dispatch CharSequence representType(GenDataType type) {
		return representEType(type.ecoreModelElement);
	}

	private def dispatch CharSequence representType(GenClass type) {
		return representEType(type.ecoreModelElement);
	}

	/**
	 * Returns the original Xcore metamodel code snippet for the given element, if the {@link #showOriginalXcoreCode}=true.
	 * Otherwise empty string is returned.
	 */
	private def printOriginalCode(XNamedElement x) {
		if (showOriginalXcoreCode) {
			return '''
				```
				«XtextTokenUtil.tokenTextOrUnknown(x)»
				```
			''';
		} else {
			return "";
		}
	}

	// Helper methods
	/**
	 * Returns the documentation annotation value for the given model element in markdown format.
	 * The formatting and links are already resolved in the returned text.
	 */
	private def String getDocAnnotation(XModelElement x) {
		return '''«FOR annotation : x.annotations»«annotation.details.get(DOCUMENTATION_ANNOTATION_KEY).toMd»«ENDFOR»'''
	}

	/**
	 * If the given text is not empty, it returns the given string prefixed with the given prefix, followed by a space character.
	 * If the given text is empty or contains whitespace only, the original text is returned. 
	 */
	private static def CharSequence prefixIfNotEmpty(CharSequence text, String prefix) {
		if (text === null) {
			return null;
		}

		val str = text.toString.trim;
		if (str.empty) {
			return text;
		} else {
			return '''«prefix» «text»''';
		}
	}

	/**
	 * If the given text is a multi-line text (i.e., it contains {@code \n} character),
	 * then from the second line every line will be indented by the given amount of characters.
	 * If the given text does not contain new line character, the original text is returned.
	 */
	private def String indentFromSecondLine(CharSequence text, int indentChars) {
		val textAsString = text?.toString;
		if (textAsString !== null && textAsString.contains("\n")) {
			return textAsString.replace("\n", "\n" + Strings.repeat(" ", indentChars));
		} else {
			return textAsString;
		}
	}

	/**
	 * Translates the given text into Markdown format. It resolves the formatting in it (e.g., `@code` or {@code <b>}) and the links.
	 */
	private def toMd(CharSequence text) {
		if (text === null) {
			return text;
		}

		val textFormattingResolved = DocCommentTextUtil.format(text.toString, mdFormatter);
		val textLinksResolved = DocCommentTextUtil.resolveLinks(textFormattingResolved, mdFormatter, [key |
			anchors.get(key)
		]);

		return textLinksResolved;
	}

	/**
	 * Returns the header prefix that is to be used on the given level, taking the {@link #titleLevelOffset} into account.
	 */
	private def String headerPrefix(int level) {
		return '''«Strings.repeat("#", level + titleLevelOffset)» ''';
	}
}
