"
I am a visitor specially made for highlighting source code according to a RCMatch.
"
Class {
	#name : #RCHighlightVisitor,
	#superclass : #XMLNodeVisitor,
	#instVars : [
		'match',
		'view',
		'subtrees'
	],
	#category : #'Intimals-Vis'
}

{ #category : #'instance creation' }
RCHighlightVisitor class >> forMatch: aMatch withView: aView [
	| inst |
	inst := self new.
	inst match: aMatch.
	inst view: aView.
	inst addMatchSubtrees.
	^inst
]

{ #category : #initialization }
RCHighlightVisitor >> addMatchSubtrees [
	| list |
	list := match from nodesNoString reject: [:node| (node attributeAt: 'Name') = '?_root'].
	list do: [ :node | | name dest |
		dest := match submatches at: node.
		name := (node attributeAt: 'Name').
		(subtrees at: name ifAbsentPut: OrderedCollection new) add: dest ]
]

{ #category : #highlighting }
RCHighlightVisitor >> doHighlight [

	view
		addHighlightFrom: match to characterOffsetToStart
		to: match to characterOffsetToEnd
		color: (RCIntPalettes astColorFor: '?_root').
	
	match to nodes do: [:node | self visitNodeWithElements: node].
]

{ #category : #highlighting }
RCHighlightVisitor >> highlight: aNode color: aColor [
	| highstart highstop lns cns lne cne |
	
	(match to hasSameCharacterRangeAs: aNode) ifTrue: [Error signal: 'Unexpected range overlap'.].
	
	lns := (aNode attributeAt: 'LineNr') asInteger.
	cns := (aNode attributeAt: 'ColNr') asInteger.
	lne := (aNode attributeAt: 'EndLineNr') asInteger.
	cne := (aNode attributeAt: 'EndColNr') asInteger.
	
	highstart := match to	characterOffsetToLine: lns andColumn: cns.
	highstop := match to characterOffsetToLine: lne andColumn: cne.
	view addHighlightFrom: highstart to: highstop color: aColor.

]

{ #category : #initialization }
RCHighlightVisitor >> initialize [
	subtrees := Dictionary new.
]

{ #category : #testing }
RCHighlightVisitor >> is: aNode taggedAs: aString [
	^(subtrees at: aString ifAbsent: [^false]) includes: aNode.
]

{ #category : #accessing }
RCHighlightVisitor >> match: anObject [
	match := anObject
]

{ #category : #accessing }
RCHighlightVisitor >> view: anObject [
	view := anObject
]
