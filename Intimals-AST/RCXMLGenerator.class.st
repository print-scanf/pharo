"
I contain the logic for creating xml parse trees for legacy languages.

I require the XMLDOMParser from the XMLParser project in the Pharo Catalog to be loaded. 

See my class side for how to use.

E.G.: RCXMLGenerator transformDir: 'C:\Users\johan\Documents\Intimals\tmp'
"
Class {
	#name : #RCXMLGenerator,
	#superclass : #Object,
	#instVars : [
		'filterVisitor',
		'transformVisitor',
		'expandVisitor'
	],
	#category : #'Intimals-AST'
}

{ #category : #operations }
RCXMLGenerator class >> cobol2AST: aFileName [
	"transform a cobol xml dump to an XML in the Intimals AST format"
	| inst result |

	inst := self new.
	result := inst filteredXMLOf: aFileName.
	inst transformXML: result.
	^result root
	
	
	
]

{ #category : #operations }
RCXMLGenerator class >> cobolDir2ASTDir: aDirectoryName [
	"interleave the processing to language-agnostic and to intimals format"
	| names inst size |
	
	inst := self new.
	names := self cobolFilesIn: aDirectoryName.
	size := names size.	
	
		' '	
		displayProgressFrom: 1 to: size
		during: [ :bar |
			1 to: size do: [:i | | fname |
				bar current: i.
				bar label: 'Processing program ', i asString, ' of ' , size asString. 
				fname := names at: i.
				inst makeFiltered: fname.
				inst transformFiltered:
					(fname copyFrom: 1 to: fname size - 8),'.pml']].
	^ size asString , ' programs processed'
]

{ #category : #operations }
RCXMLGenerator class >> cobolFilesIn: aDirectoryName [
	| names |
	names := aDirectoryName asFileReference entries
		collect: [:entry | entry fullName].

	names := names select: [ :nam | | lcnam |
		lcnam := nam asLowercase.
		(lcnam endsWith: '.cob.xml') or: [lcnam endsWith: '.cbl.xml']].
	
	^names
]

{ #category : #operations }
RCXMLGenerator class >> import: aSymbol from: aRootDirName [
	| root dirs |

	
	root := aRootDirName asFileReference.
	root isDirectory ifFalse: [ Error signal: 'Root directory is not a directory.' ].
	
	dirs := root allDirectories.

	aSymbol = #COBOL ifFalse: [ Error signal: 'Only COBOL is supported.'].
	
	'Processing directories'
		displayProgressFrom: 1 to: dirs size
		during: [ :bar |
			1 to: dirs size do: [ :i | | str |
				str := (dirs at: i) pathString.
				bar current: i.
				bar label: 'Processing ', str.
				self cobolDir2ASTDir: str. 
				]
			 ].
	
	^'Processed ' , dirs size asString , ' directories.'
	
]

{ #category : #operations }
RCXMLGenerator class >> processCobolDir: aDirectoryName [
	"cobol-specific processing to produce language-agnostic intermediate format"
	| names inst size |

	inst := self new.
	names := self cobolFilesIn: aDirectoryName.
	size := names size.
	
	' '	
		displayProgressFrom: 1 to: size
		during: [ :bar |
			1 to: size do: [:i | 
				bar current: i.
				bar label: 'Filtering program ', i asString, ' of ' , size asString. 
				inst makeFiltered: (names at: i) ]].
]

{ #category : #operations }
RCXMLGenerator class >> quickCobolDir2ASTDir: aDirectoryName [
	"skip the processing to language-agnostic format "
	| names inst size |
	
	inst := self new.
	names := self cobolFilesIn: aDirectoryName.
	size := names size.	
	
		' '	
		displayProgressFrom: 1 to: size
		during: [ :bar |
			1 to: size do: [:i | | fname |
				bar current: i.
				bar label: 'Processing program ', i asString, ' of ' , size asString. 
				fname := names at: i.
				inst transformFiltered:
					(fname copyFrom: 1 to: fname size - 8),'.pml']].
	^ size asString , ' programs processed'
]

{ #category : #operations }
RCXMLGenerator class >> quickImport: aSymbol from: aRootDirName [
	| root dirs |

	
	root := aRootDirName asFileReference.
	root isDirectory ifFalse: [ Error signal: 'Root directory is not a directory.' ].
	
	dirs := root allDirectories.

	aSymbol = #COBOL ifFalse: [ Error signal: 'Only COBOL is supported.'].
	
	'Processing directories'
		displayProgressFrom: 1 to: dirs size
		during: [ :bar |
			1 to: dirs size do: [ :i | | str |
				str := (dirs at: i) pathString.
				bar current: i.
				bar label: 'Processing ', str.
				self quickCobolDir2ASTDir: str. 
				]
			 ].
	
	^'Processed ' , dirs size asString , ' directories.'
	
]

{ #category : #constants }
RCXMLGenerator class >> relationsRenameList [
	"a list of renamings for relations in rules"
	^{ 'TheArgs' -> 'TheArg' } asDictionary 
]

{ #category : #operations }
RCXMLGenerator class >> transformDir: aDirectoryName [
	| names inst size |
	names := aDirectoryName asFileReference entries
		collect: [:entry | entry fullName].

	names := names select: [ :nam | (nam endsWith: '.pml') ].
	inst := self new.
	size := names size.
	' '
		displayProgressFrom: 1 to: size
		during: [ :bar |
			1 to: size do: [:i | 
				bar current: i.
				bar label: 'Transforming program ', i asString, ' of ' , size asString. 
			 	inst transformFiltered: (names at: i) ]].
]

{ #category : #processing }
RCXMLGenerator >> filteredXMLOf: aFileName [
	| xml |
	xml := self parse: aFileName.
	xml root attributeAt: 'FullName' put: (aFileName copyFrom: 1 to: (aFileName size) - 4).
	xml acceptNodeVisitor: filterVisitor.
	^xml
]

{ #category : #initialization }
RCXMLGenerator >> initialize [
	filterVisitor := RCASTFilter new.
	transformVisitor := RCASTTransformer new.
	expandVisitor := RCASTExpander new.

]

{ #category : #processing }
RCXMLGenerator >> makeFiltered: aFileName [
	| name |
	"filter a cobol parser output to a smaller form"
	(((aFileName copyFrom: (aFileName size) - 7 to: aFileName size) asLowercase = '.cob.xml')
	  or: [(aFileName copyFrom: (aFileName size) - 7 to: aFileName size) asLowercase = '.cbl.xml' ])
		ifFalse:[Error signal: 'No support for this filetype'].
	name := aFileName copyFrom: 1 to: (aFileName size ) - 8. 

	(self filteredXMLOf: aFileName) printToFileNamed: name , '.pml'.
]

{ #category : #processing }
RCXMLGenerator >> parse: aFileName [
	| domparser |
	domparser := XMLDOMParser onFileNamed: aFileName.
	domparser optimizeForLargeDocuments.
	^domparser parseDocument.
]

{ #category : #processing }
RCXMLGenerator >> transformFiltered: aFileName [
	| xml name |
	" the file has already been filtered, transform it to a better tree"
	(aFileName copyFrom: (aFileName size) - 3 to: aFileName size)= '.pml'
		ifFalse:[Error signal: 'No support for this filetype'].

	xml := self parse: aFileName.
	self transformXML: xml.

	name := aFileName copyFrom: 1 to: (aFileName size ) - 3. 
	xml printToFileNamed: name , 'xml'.
]

{ #category : #processing }
RCXMLGenerator >> transformXML: anXML [
	anXML acceptNodeVisitor: transformVisitor.
	expandVisitor counter: transformVisitor counter + 1.
	"anXML acceptNodeVisitor: expandVisitor."
]
