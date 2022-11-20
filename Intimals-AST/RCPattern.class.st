"
I represent a pattern as produced by a mining algorithm and contain my matches as well. See my class side on how to create me.
"
Class {
	#name : #RCPattern,
	#superclass : #Object,
	#instVars : [
		'id',
		'subtree',
		'matches',
		'locations',
		'astDir',
		'metadata'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCPattern class >> on: aXMLPatternNode withMatches: aXMLMatchesDict andASTDir: anASTDirectory [
	| inst id  |

	id := aXMLPatternNode attributeAt: 'id'. 
	inst := self new.
	inst id: id.
	inst subtree: (aXMLPatternNode allElementsNamed: 'subtree') first.
	inst astDir: anASTDirectory.								
	inst matches: ((aXMLMatchesDict at: id ifAbsent: [ #() ])
							collect: [:matchXML | RCMatch fromXML: matchXML type: #freqt]).
	inst metadata: RCPatternMetadata new.
	^inst
]

{ #category : #accessing }
RCPattern >> astDir [
	^ astDir
]

{ #category : #accessing }
RCPattern >> astDir: anObject [
	astDir := anObject
]

{ #category : #accessing }
RCPattern >> astRoot [
	^subtree nodesNoString first
]

{ #category : #'inspector extensions' }
RCPattern >> childrenOf: aKey [
	^aKey isString
		ifTrue: [(locations at: aKey) matches.]
		ifFalse: [{}]
]

{ #category : #accessing }
RCPattern >> chisquare [
	^subtree attributeAt: 'score' ifAbsent: '?'
]

{ #category : #accessing }
RCPattern >> exampleMatch [
	matches isEmpty ifTrue: [ ^nil ].
	^ matches anyOne
]

{ #category : #exporting }
RCPattern >> exportTo: aWriteStream [
	
	aWriteStream nextPutAll: '### Pattern '.
	aWriteStream nextPutAll: id.
	
	aWriteStream nextPut: Character cr.
	
	aWriteStream nextPutAll: '- Supp: '.
	aWriteStream nextPutAll: self support.

	aWriteStream nextPut: Character cr.

	aWriteStream nextPutAll: '- Count: '.
	aWriteStream nextPutAll: matches size asString.

	aWriteStream nextPut: Character cr.
	
	aWriteStream nextPutAll: '- Size: '.
	aWriteStream nextPutAll: self size.

	aWriteStream nextPut: Character cr.

	aWriteStream nextPutAll: '- Root: '.
	aWriteStream nextPutAll: self astRoot name.

	aWriteStream nextPut: Character cr.
	
	metadata exportTo: aWriteStream.
	
	aWriteStream nextPutAll: '- Filenames: '.
 	locations keys sort allButFirst do: [:nam | aWriteStream nextPutAll: nam] separatedBy: [ aWriteStream nextPutAll: ', ' ].
	
	aWriteStream nextPut: Character cr.
]

{ #category : #'inspector extensions' }
RCPattern >> gtInspectorPatternTreeIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite tree
			title: 'Pattern';
			display: [ self subtree ];
			children: [:each | each treeViewChildren];
			format: [:each | each treeViewLabelText];
			allExpanded.
]

{ #category : #'inspector extensions' }
RCPattern >> gtInspectorSmartPreviewIn: composite [
	<gtInspectorPresentationOrder: -5>
	
	^composite fastTreeTable
			title: 'Matches';
			display: [ self treeRoots ];
			children: [ :key | self childrenOf: key ];
			column: 'Summary' evaluated: [ :key | self summaryOf: key] width: 340;
			column: '# Occurances' evaluated: [ :key | self occOf: key];
			send: [ :key | 
				key isString
					ifTrue: [ locations at: key ]
					ifFalse: [ key ]
				].
]

{ #category : #'inspector extensions' }
RCPattern >> gtInspectorSourceTreeIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite tree
			title: 'EG Tree';
			display: [ matches anyOne to ];
			children: [:each | each treeViewChildren];
			format: [:each | each treeViewLabelText];
			allExpanded.
]

{ #category : #accessing }
RCPattern >> id [
	^ id
]

{ #category : #accessing }
RCPattern >> id: anObject [
	id := anObject
]

{ #category : #accessing }
RCPattern >> matchFileNames [
	"All file names of matches"
	^(matches collect: [:match | match to fileReference fullName]) asSet
]

{ #category : #accessing }
RCPattern >> matches [
	^ matches
]

{ #category : #accessing }
RCPattern >> matches: anObject [
	matches := anObject.
	
	locations := Dictionary new.
	
	matches do: [ :match | | location |
		location := match originalName.
		(locations at: location ifAbsentPut: (RCMatchCollection forFile: location inDir: astDir)) add: match].

	locations at: ' Aggregate' put: (RCMatchAggregateCollection on: locations values).

	^matches
]

{ #category : #accessing }
RCPattern >> metadata [
	^ metadata
]

{ #category : #accessing }
RCPattern >> metadata: anObject [
	metadata := anObject
]

{ #category : #'inspector extensions' }
RCPattern >> occOf: aKey [
	^aKey isString
		ifTrue: [ (locations at: aKey) size]
		ifFalse: [ aKey nodesMatched ]
]

{ #category : #accessing }
RCPattern >> size [
	^subtree attributeAt: 'size' ifAbsent: '?'
]

{ #category : #accessing }
RCPattern >> subtree [
	^ subtree
]

{ #category : #accessing }
RCPattern >> subtree: anObject [
	subtree := anObject
]

{ #category : #'inspector extensions' }
RCPattern >> summaryOf: aKey [
	^aKey isString 
		ifTrue: [aKey size > 42
			ifTrue: ['...',(aKey copyFrom: aKey size - 42 to: aKey size)]
			ifFalse: [aKey]]
		ifFalse: [aKey summaryString].
]

{ #category : #accessing }
RCPattern >> support [
	^subtree attributeAt: 'support' ifAbsent: '?'
]

{ #category : #'inspector extensions' }
RCPattern >> treeRoots [
	^locations keys sort 
]

{ #category : #accessing }
RCPattern >> wsupport [
	^subtree attributeAt: 'wsupport' ifAbsent: '?'
]
