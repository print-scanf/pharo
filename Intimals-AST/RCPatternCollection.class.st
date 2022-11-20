"
I am the result of a pattern match run, I contain the XML document in the Intimals metamodel output format.
"
Class {
	#name : #RCPatternCollection,
	#superclass : #Object,
	#instVars : [
		'patterns',
		'astDir'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCPatternCollection class >> fromPatterns: aPatternsXMLName withMatches: aMatchesXMLName andASTDir: aDirName [
	| patxml matxml astDirectory patterns matches |
	
	astDirectory := RCDirectoryMagic onFileReference: (aDirName asFileReference).
	
	'Reading patterns and matches files.'
		displayProgressFrom: 0 to: 2 during: [:bar | 
			bar current: 1.
			patxml := self parse: aPatternsXMLName.
			patxml := (patxml nodes first nodes reject: [ :node | node isStringNode ]).

			bar current: 2.
			matxml := self parse: aMatchesXMLName.
			
			matches := Dictionary new: patxml size.
			matxml nodes first nodes do: [ :node |
					node isStringNode ifFalse: [ 
						(matches at: (node attributeAt: 'PatternID')
									ifAbsentPut: [OrderedCollection new]) add: node ]
				 ]
			].
	
	RCASTCollection resetGlobal.
	RCSourcesCollection resetGlobal.

	patterns := OrderedCollection new: patxml size.	
	patxml
		do: [:pat | patterns add: (RCPattern on: pat withMatches: matches andASTDir: astDirectory)]
		displayingProgress: 'Reading patterns ...'.
	
	^self new patterns: patterns

		
]

{ #category : #'instance creation' }
RCPatternCollection class >> parse: aFileName [
	| domparser |
	domparser := XMLDOMParser onFileNamed: aFileName.
	domparser optimizeForLargeDocuments.
	^domparser parseDocument.
]

{ #category : #accessing }
RCPatternCollection >> astDir [
	^ astDir
]

{ #category : #accessing }
RCPatternCollection >> astDir: anObject [
	astDir := anObject
]

{ #category : #exporting }
RCPatternCollection >> exportTo: aWriteStream [

	self patterns do: [:pat | pat exportTo: aWriteStream] separatedBy: [ aWriteStream nextPut: Character cr  ]
]

{ #category : #'inspector extensions' }
RCPatternCollection >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: -10>
	^ composite fastTable
		title: 'Patterns';
		display: [ self patterns ];
		enableElementIndex;
		column: 'Id' evaluated: [ :val | val id padLeftTo: 4 with: $0 ] width: 40;
		column: 'Sup' evaluated: [ :val | val support padLeftTo: 3 with: $0 ] width: 40;
		column: 'WSup'evaluated: [ :val | val wsupport padLeftTo: 3 with: $0  ] width: 40;
		column: 'Size' evaluated: [ :val | val size padLeftTo: 3 with: $0 ] width: 40;
		column: 'Root' evaluated: [ :val | val astRoot name ];
		column: 'Children' evaluated: [ :val |
			GTObjectPrinter asTruncatedTextFrom:
				val astRoot childStringSummary].
]

{ #category : #accessing }
RCPatternCollection >> patternWithID: anID [
	^self patterns detect: [ :pat | pat id = anID ]
]

{ #category : #accessing }
RCPatternCollection >> patterns [
	^ patterns
]

{ #category : #accessing }
RCPatternCollection >> patterns: anObject [
	patterns := anObject
]
