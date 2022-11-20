"
This visitor walks over the tree and performs the calculation as specified in the calcBlock.

Example:
| calc |
calc := RCTreeCalculator new.
calc result: 0.
calc calcBlock: [:node |
	calc result max:
		(Integer readFrom: (node attributeAt: 'ID' ifAbsent: ['0']))
	].
<tree> acceptNodeVisitor: calc
"
Class {
	#name : #RCTreeCalculator,
	#superclass : #XMLNodeVisitor,
	#instVars : [
		'result',
		'calcBlock'
	],
	#category : #'Intimals-AST'
}

{ #category : #utility }
RCTreeCalculator class >> findSubNodeOf: aNode withID: anID [
	| visit |
	
	visit := self new.
	visit calcBlock: [ :node |	(node attributeAt: 'ID') = anID ifTrue: [ ^node ]  ].
	aNode acceptNodeVisitor: visit.
	
	^Error signal: 'Unable to find requested subnode.'
]

{ #category : #accessing }
RCTreeCalculator >> calcBlock [
	^ calcBlock
]

{ #category : #accessing }
RCTreeCalculator >> calcBlock: anObject [
	calcBlock := anObject
]

{ #category : #accessing }
RCTreeCalculator >> result [
	^ result
]

{ #category : #accessing }
RCTreeCalculator >> result: anObject [
	result := anObject
]

{ #category : #visiting }
RCTreeCalculator >> visitDocument: aDocument [
	aDocument root acceptNodeVisitor: self.
	^result
]

{ #category : #visiting }
RCTreeCalculator >> visitNodeWithElements: aRCASTNode [
	result := calcBlock value: aRCASTNode.
	^super visitNodeWithElements: aRCASTNode
]
