"
I represent a match as identified by the Intimals metamodel, matching part. See my class side for how to create me.
"
Class {
	#name : #RCMatch,
	#superclass : #Object,
	#instVars : [
		'from',
		'to',
		'source',
		'collection',
		'submatches',
		'type'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCMatch class >> fromXML: anXMLMatch type: aTypeSymbol [
	| inst |
	inst := self new.
	inst from: anXMLMatch.
	inst type: aTypeSymbol.
	^inst.
]

{ #category : #'fuel support' }
RCMatch class >> fuelIgnoredInstanceVariableNames [ 
	^#('to' 'source' 'submatches')
]

{ #category : #accessing }
RCMatch >> collection: anObject [
	collection := anObject
]

{ #category : #'inspector extensions' }
RCMatch >> exampleTree [
	^to.
]

{ #category : #accessing }
RCMatch >> from [
	^ from
]

{ #category : #accessing }
RCMatch >> from: anXML [
	| errors nodes |
	from := anXML.
	nodes := from nodesNoString select: [ :node | node name = 'node' ].
	errors := from nodesNoString select: [ :errnode | errnode name = 'error' ].
	from removeNodes.
	from nodes addAll: nodes.
	errors do: [ :errnode | | id |
		id := errnode attributeAt: 'ID'.
		nodes
			detect: [ :node | (node attributeAt: 'ID') = id ]
			ifFound: [ :node | node attributeAt: 'Name' put: 'error' ] ]

]

{ #category : #accessing }
RCMatch >> fullName [
	self deprecated: 'Use originalName instead'.

	^self from attributeAt: 'FullName'.
]

{ #category : #accessing }
RCMatch >> getSource [
	^self to getFullSource.
]

{ #category : #accessing }
RCMatch >> getSourceFragment [ 
	^self to getSourceFragment.
]

{ #category : #'inspector extensions' }
RCMatch >> gtInspectorMatchPartsIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite fastTable
		title: 'Parts';
		display: [ from nodesNoString select:[:node | node name = 'node']];
		enableElementIndex;
		column: 'Index' evaluated: [ :val :i | i asString  ] width: 40;
		column: 'Label' evaluated: [ :val | val attributeAt: 'Name']  width: 100;
		column: 'To' evaluated: [ :val | 
			GTObjectPrinter asTruncatedTextFrom: (self submatches at: val ifAbsent: [to])];
		send: [:val | (self submatches at: val ifAbsent: [to])].
]

{ #category : #accessing }
RCMatch >> nodesMatched [
	| result |
	result := '  ' , (self from attributeAt: 'NodesMatched' ifAbsent: ' All').
	(self from includesAttribute: 'Errors') ifTrue: [
		result := result, ' ~ ' , (self from attributeAt: 'Errors') ].

	^ result

]

{ #category : #accessing }
RCMatch >> originalName [

	^self from attributeAt: 'FullName'.
]

{ #category : #accessing }
RCMatch >> patternID [
	^self from attributeAt: 'PatternID'. 
]

{ #category : #accessing }
RCMatch >> rootID [
	^((from nodes select: [:node | node isStringNode not]) detect: [:node |
		(node name = 'node') and: [(node attributeAt: 'Name') = '?_root']])
		attributeAt: 'ID'
]

{ #category : #accessing }
RCMatch >> sourcePath [
	"Path to the file name on this filesystem"
	^collection sourceName
]

{ #category : #accessing }
RCMatch >> submatches [
	"the matches of all my parts that are not the root of the match"
	submatches ifNil: [ | list |
		submatches := Dictionary new.
		list := self from nodesNoString select: [:node | node name = 'node'].
		list size > 1 ifTrue: [ 
			(list copyFrom: 2 to: list size) do: [:sfrom | 
				submatches
					at: sfrom
					put: (RCTreeCalculator findSubNodeOf: to withID: (sfrom attributeAt: 'ID'))]]].
	^submatches
]

{ #category : #'inspector extensions' }
RCMatch >> summaryString [
	^GTObjectPrinter asTruncatedTextFrom: self to getExactSource.
]

{ #category : #accessing }
RCMatch >> to [
	to ifNil: [ collection linkMatches ].
	^ to
]

{ #category : #accessing }
RCMatch >> to: anObject [
	to := anObject
]

{ #category : #accessing }
RCMatch >> type [
	^ type
]

{ #category : #accessing }
RCMatch >> type: anObject [
	type := anObject
]
