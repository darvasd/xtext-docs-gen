##  Domain model grammar documentation

Example model from the Xtext documentation, see
[Xtext webpage](https://www.eclipse.org/Xtext/documentation/102_domainmodelwalkthrough.html).

Extended with documentation for demonstration purposes.

Included grammars:
- `org.eclipse.xtext.common.Terminals`


###  Rules
####  Domainmodel  
A **domain model** is a collection of elements.
			

This is the root element of the grammar.


**Refers to:**
- [AbstractElement](#abstractelement)



```
Domainmodel:
    (elements+=AbstractElement)*;
```



####  AbstractElement  
An **element** is a _package declaration_,
_import_ or _type_.
			

This is the root element of the grammar.


**Refers to:**
- [Import](#import)
- [PackageDeclaration](#packagedeclaration)
- [Type](#type)

**Referred by:**
- [Domainmodel](#domainmodel)
- [PackageDeclaration](#packagedeclaration)


```
AbstractElement:
    PackageDeclaration | Type | Import;
```



####  PackageDeclaration  
A **package** has a _qualified name_ and
[elements](#abstractelement) inside.

- **Validation:**
   * The package name shall not start with letter `P`.

**Refers to:**
- [AbstractElement](#abstractelement)
- [QualifiedName](#qualifiedname)

**Referred by:**
- [AbstractElement](#abstractelement)


```
PackageDeclaration:
    'package' name=QualifiedName '{'
        (elements+=AbstractElement)*
    '}';
```



####  Import  
An **import** makes available another namespace.
			
 
The imported namespace is defined by a qualified name,
potential with a wildcard.


**Refers to:**
- [QualifiedNameWithWildcard](#qualifiednamewithwildcard)

**Referred by:**
- [AbstractElement](#abstractelement)


```
Import:
    'import' importedNamespace=QualifiedNameWithWildcard;
```



####  QualifiedName  
A **qualified name** has one or more segments with
`.` as separators.


**Refers to:**
- ID

**Referred by:**
- [Entity](#entity)
- [Feature](#feature)
- [PackageDeclaration](#packagedeclaration)
- [QualifiedNameWithWildcard](#qualifiednamewithwildcard)

**Returns:** `ecore::EString`

```
QualifiedName:
    ID ('.' ID)*;
```



####  QualifiedNameWithWildcard  
A **qualified name**, optionally with a wildcard (`*`)
last segment.


**Refers to:**
- [QualifiedName](#qualifiedname)

**Referred by:**
- [Import](#import)

**Returns:** `ecore::EString`

```
QualifiedNameWithWildcard:
    QualifiedName '.*'?;
```



####  Type  
A **type** is either an atomic data type ([DataType](#datatype)), or 
an entity ([Entity](#entity)), containing several features.


**Refers to:**
- [DataType](#datatype)
- [Entity](#entity)

**Referred by:**
- [AbstractElement](#abstractelement)


```
Type:
    DataType | Entity;
```



####  DataType  
A **data type** is an atomic named type.


**Refers to:**
- ID

**Referred by:**
- [Type](#type)


```
DataType:
    'datatype' name=ID;
```



####  Entity  
An **entity** is a named structure of features.
It can extend another entity, in this case the features of
the extended entity will also be contained by this one.


**Refers to:**
- [Feature](#feature)
- ID
- [QualifiedName](#qualifiedname)

**Referred by:**
- [Type](#type)


```
Entity:
    'entity' name=ID ('extends' superType=[Entity|QualifiedName])? '{'
        (features+=Feature)*
    '}';
```



####  Feature  
A **feature** is a named reference to one or many
objects of the given type.


**Refers to:**
- ID
- [QualifiedName](#qualifiedname)

**Referred by:**
- [Entity](#entity)


```
Feature:
    (many?='many')? name=ID ':' type=[Type|QualifiedName];
```



####  DummyEnum (enum) 
A dummy enum to demonstrate its documentation.


Literals:
- One (`ONE`)
	 : _Representation of **number 1**._
- Three (`THREE`)
	 : _Representation of **number 3**._
- Two (`TWO`, `ZWEI`)
	 : _Representation of **number 2**._

```
enum DummyEnum:
	One = 'ONE' | 
	Two = 'TWO' | Two = 'ZWEI' |
	Three = 'THREE' 
;
```




###  Simplified grammar
**Domainmodel** ::= _AbstractElement_*;

**AbstractElement** ::= _PackageDeclaration_ | _Type_ | _Import_;

**PackageDeclaration** ::= `package`   _QualifiedName_   `{`   _AbstractElement_*   `}`;

**Type** ::= _DataType_ | _Entity_;

**Import** ::= `import`   _QualifiedNameWithWildcard_;

**QualifiedName** ::= _ID_   (`.`   _ID_)*;

**DataType** ::= `datatype`   _ID_;

**Entity** ::= `entity`   _ID_   (`extends`   _QualifiedName_)?   `{`   _Feature_*   `}`;

**QualifiedNameWithWildcard** ::= _QualifiedName_   `.*`?;

**ID** ::= `^`?   ([`a`..`z`] | [`A`..`Z`] | `_`)   ([`a`..`z`] | [`A`..`Z`] | `_` | [`0`..`9`])*;

**Feature** ::= `many`?   _ID_   `:`   _QualifiedName_;


###  Rule dependencies

![Rule dependencies](ExampleDomainmodelDocs-dependencies.png)