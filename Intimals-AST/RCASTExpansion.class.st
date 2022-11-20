"
I specify under which conditions an expansion should take place as well as the name of the node to create for the expansion.
"
Class {
	#name : #RCASTExpansion,
	#superclass : #Object,
	#instVars : [
		'conditions',
		'ahName'
	],
	#category : #'Intimals-AST'
}

{ #category : #accessing }
RCASTExpansion class >> map: conditions to: aName [
	| inst |
	inst := self new.
	inst conditions: conditions.
	inst ahName: aName.
	^inst.
]

{ #category : #accessing }
RCASTExpansion >> ahName [
	^ ahName
]

{ #category : #accessing }
RCASTExpansion >> ahName: anObject [
	ahName := anObject
]

{ #category : #accessing }
RCASTExpansion >> conditions: anObject [
	conditions := anObject
]

{ #category : #accessing }
RCASTExpansion >> mandatories [
	^ conditions select: [:kvp | kvp value ] thenCollect: [:kvp | kvp key ]
]

{ #category : #matching }
RCASTExpansion >> matchedNTsIn: aRCASTNode [
	| cand |
	cand := self ntNames.
	^ aRCASTNode nodesNoString select: [ :node | cand includes: node name  ].

]

{ #category : #matching }
RCASTExpansion >> matches: aNode [
	| list names |
	list := aNode nodesNoString.
	names := (list collect: [:node | node name]) asOrderedCollection.
	^names includesAll: self mandatories.
]

{ #category : #accessing }
RCASTExpansion >> ntNames [
	^conditions collect: [:kvp | kvp key].
]

{ #category : #accessing }
RCASTExpansion >> optionals [
	^ conditions select: [:kvp | kvp value not ] thenCollect: [:kvp | kvp key ]
]

{ #category : #transforming }
RCASTExpansion >> pushDown: aCollection withID: id [
	| newNode parent bl el bc ec |
	bl := aCollection
		inject: 1000000
		into: [:lo :node | lo min: (node attributeAt: 'LineNr') asInteger ].
	bc := aCollection
		inject: 1000000
		into: [:lo :node | lo min: (node attributeAt: 'ColNr') asInteger ].
	el := aCollection
		inject: 0
		into: [:hi :node | hi max: (node attributeAt: 'EndLineNr') asInteger ].
	ec := aCollection
		inject: 0
		into: [:hi :node | hi max: (node attributeAt: 'ColNr') asInteger ].
	parent := aCollection anyOne parent.
	newNode := XMLElement named: 'AdHoc_',ahName.
	newNode attributeAt: 'LineNr' put: bl asString.
	newNode attributeAt: 'EndLineNr' put: el asString.
	newNode attributeAt: 'ColNr' put: bc asString.
	newNode attributeAt: 'EndColNr' put: ec asString.
	newNode attributeAt: 'ID' put: id asString.
	aCollection do: [:node | newNode addNode: node].
	parent addNode: newNode.
	^newNode 
]
