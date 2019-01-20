#  Library.xcore metamodel description

##  Table of contents
- [Book](#anchor2)
- [BookCategory](#anchor4)
- [Date](#anchor5)
- [Library](#anchor1)
- [Writer](#anchor3)

##  Package `org.example.xcore.library`

###  Class `Library` {#anchor1}

_Representation of a library._

_Root element of the library metamodel._

**Extends**: `EObject`

**Attributes**:
- **name** : `EString`
    * _Name of the library. The documentation supports both **HTML** _formatting_ tags and doc comment style `formatting`._
- **address** : `EString`
    * _Address of the library. Linking to other elements is possible: [Library](#anchor1) or [like this](#anchor1)._

**References**:
- **books**  [0..*]: [Book](#anchor2)
    * _Books stored in the library._
    * Containment: contains
    * Opposite: [Book](#anchor2).`library`
- **authors**  [0..*]: [Writer](#anchor3)
    * _Authors known in the library._
    * Containment: contains
    * Opposite: [Writer](#anchor3).`library`

**Operations**:
- **getBook**(title :  `EString`) : [Book](#anchor2)
    * _Returns a book known by the given title. Returns `null` if no book is known with the given title._

```
@GenModel(documentation="Representation of a library.\n\nRoot element of the library metamodel.")
class Library {
	@GenModel(documentation="Name of the library. The documentation supports both <b>HTML</b> <i>formatting</i> tags and doc comment style {@code formatting}.")
	String name
	@GenModel(documentation="Address of the library. Linking to other elements is possible: {@link Library} or {@link Library like this}.")
	String address
	@GenModel(documentation="Books stored in the library.")
	contains Book[0..*] books opposite library
	@GenModel(documentation="Authors known in the library.")
	contains Writer[0..*] authors opposite library
	@GenModel(documentation="Returns a book known by the given title. Returns {@code null} if no book is known with the given title.")
	op Book getBook(String title) {
		for (Book book : books) {
			if (title == book.title) return book
		}
		return null
	}
}
```
###  Class `Book` {#anchor2}

_Representation of a physical instance of a **book**,_
_	located in a _library_._

**Extends**: `EObject`

**Attributes**:
- **title** : `EString`
    * _Title of the book._
- **bookCategory** : [BookCategory](#anchor4)
    * _Category of the book. Exactly one of the defined_
      _		[book categories](#anchor4)._
- **pages** : `EInt`
    * _Number of pages. Expected to be positive._
- **copyright** : [Date](#anchor5)
    * _Date of release._

**References**:
- **library** : [Library](#anchor1)
    * _The library containing this book instance._
    * Containment: container
    * Opposite: [Library](#anchor1).`books`
- **authors**  [1..*]: [Writer](#anchor3)
    * _Writers of the book._
      
      _The referred writers are expected to be contained by `this.library`._
    * Containment: refers
    * Opposite: [Writer](#anchor3).`books`


```
@GenModel(documentation="Representation of a physical instance of a <b>book</b>,
	located in a <i>library</i>.")
class Book {
	@GenModel(documentation="Title of the book.")
	String title
	@GenModel(documentation="Category of the book. Exactly one of the defined
		{@link BookCategory book categories}.")
	BookCategory bookCategory
	@GenModel(documentation="Number of pages. Expected to be positive.")
	int pages
	@GenModel(documentation="Date of release.")
	Date copyright
	@GenModel(documentation="The library containing this book instance.")
	container Library library opposite books
	@GenModel(documentation="Writers of the book.\n\nThe referred writers are expected to be contained by `this.library`.")
	refers Writer[1..*] authors opposite books
}
```
###  Class `Writer` {#anchor3}


**Extends**: `EObject`

**Attributes**:
- **name** : `EString`
- **lastName** : `EString`
    * Modifiers: Derived

**References**:
- **library** : [Library](#anchor1)
    * Containment: container
    * Opposite: [Library](#anchor1).`authors`
- **books**  [0..*]: [Book](#anchor2)
    * Containment: refers
    * Opposite: [Book](#anchor2).`authors`


```
class Writer {
	String name
	container Library library opposite authors
	refers Book[] books opposite authors
	derived String lastName get {
		if (name !== null) {
			val int index = name.lastIndexOf(' ')
			if (index != -1) name.substring(index+1) else name
		}
	}
}
```

###  Enum `BookCategory` {#anchor4}

_Known book categories._

**Literals**:
- `Mistery` (M): _Mistery books. It includes fairy tales too._
- `ScienceFiction` (S): _Science-fiction books._
- `Biography` (B): _Biography books._

```
@GenModel(documentation="Known book categories.")
enum BookCategory {
	@GenModel(documentation="Mistery books. It includes fairy tales too.")
	Mistery as "M"
	@GenModel(documentation="Science-fiction books.")
	ScienceFiction as "S"
	@GenModel(documentation="Biography books.")
	Biography as "B"
}
```

###  Data Type `Date` {#anchor5}

_Date (year, month, day) representation._

- Wraps: `java.util.Date` 
