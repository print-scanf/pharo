"
I represent a 'pattern' as returned by frequent itemset mining: an ID, a collection of paths, support
"
Class {
	#name : #RCFISPattern,
	#superclass : #Object,
	#instVars : [
		'id',
		'paths',
		'support',
		'astDir',
		'matches',
		'locations'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCFISPattern class >> fromLine: aString withID: id withMatches: aXMLMatchesDict andASTDir: astDirectory [
	| inst idx |
	inst := self new.
	inst id: id.

	idx := aString lastIndexOf: $#.
	inst paths: (aString copyFrom: 1 to: idx-2).
	inst support: (aString copyFrom: idx + 6 to: aString size).
	inst astDir: astDirectory.
	inst matches: ((aXMLMatchesDict at: id ifAbsent: [ #() ])
							collect: [:matchXML | RCMatch fromXML: matchXML type: #fis]).
	^inst.
]

{ #category : #accessing }
RCFISPattern >> astDir [
	^ astDir
]

{ #category : #accessing }
RCFISPattern >> astDir: anObject [
	astDir := anObject
]

{ #category : #'inspector extensions' }
RCFISPattern >> childrenOf: aKey [
	^aKey isString
		ifTrue: [(locations at: aKey) matches.]
		ifFalse: [{}]
]

{ #category : #'inspector extensions' }
RCFISPattern >> gtInspectorSmartPreviewIn: composite [
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

{ #category : #accessing }
RCFISPattern >> id [
	^ id
]

{ #category : #accessing }
RCFISPattern >> id: anObject [
	id := anObject
]

{ #category : #accessing }
RCFISPattern >> matches [
	^ matches
]

{ #category : #accessing }
RCFISPattern >> matches: anObject [
	matches := anObject.
	
	locations := Dictionary new.
	
	matches do: [ :match | | location |
		location := match fullName.
		(locations at: location ifAbsentPut: (RCMatchCollection forFile: location inDir: astDir)) add: match].

	locations at: ' Aggregate' put: (RCMatchAggregateCollection on: locations values).

	^matches
]

{ #category : #'inspector extensions' }
RCFISPattern >> occOf: aKey [
	^aKey isString
		ifTrue: [ (locations at: aKey) size]
		ifFalse: [ ' ' ]
]

{ #category : #accessing }
RCFISPattern >> paths [
	^ paths
]

{ #category : #accessing }
RCFISPattern >> paths: anObject [
	paths := anObject
]

{ #category : #'inspector extensions' }
RCFISPattern >> summaryOf: aKey [
	^aKey isString 
		ifTrue: [aKey size > 42
			ifTrue: ['...',(aKey copyFrom: aKey size - 42 to: aKey size)]
			ifFalse: [aKey]]
		ifFalse: [aKey summaryString].
]

{ #category : #accessing }
RCFISPattern >> support [
	^ support
]

{ #category : #accessing }
RCFISPattern >> support: anObject [
	support := anObject
]

{ #category : #'inspector extensions' }
RCFISPattern >> treeRoots [
	^locations keys sort 
]
