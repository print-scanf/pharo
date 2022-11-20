"
I represent a collection of RCMatches for a given file. See my class side for how to create me.
"
Class {
	#name : #RCMatchCollection,
	#superclass : #Object,
	#instVars : [
		'fileName',
		'xmlName',
		'ast',
		'matches',
		'graphView',
		'graphHighlight',
		'emphasizedElements',
		'sourceName'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCMatchCollection class >> forFile: aFileName inDir: aDir [
	| inst |
	
	inst := self new.
	inst fileName: aFileName.
	inst sourceName: (aDir resolveFileName: aFileName).
	inst linkXML.
	
	^inst
]

{ #category : #'fuel support' }
RCMatchCollection class >> fuelIgnoredInstanceVariableNames [
	^#('ast')
]

{ #category : #'match processing' }
RCMatchCollection >> add: aMatchXML [
	matches add: aMatchXML.
	aMatchXML collection: self.
]

{ #category : #accessing }
RCMatchCollection >> ast [
	ast ifNil: [ self linkXML ].
	^ ast
]

{ #category : #accessing }
RCMatchCollection >> ast: anObject [
	ast := anObject
]

{ #category : #accessing }
RCMatchCollection >> fileName [
	^ fileName
]

{ #category : #accessing }
RCMatchCollection >> fileName: anObject [
	fileName := anObject
]

{ #category : #initialization }
RCMatchCollection >> initialize [
	matches := OrderedCollection new.
]

{ #category : #'match processing' }
RCMatchCollection >> linkMatches [
	| matchdict calc |
	"fill in all the links from maches to the source file"
	
	GrowlMorph openWithLabel: 'Match Collection' contents: 'Linking matches to source XML.'.
	
	matchdict := Dictionary new.
	matches do: [:match | matchdict at: match rootID put: match].
	
	calc := RCTreeCalculator new.
	calc calcBlock: [:node | 
		matchdict at: (node attributeAt: 'ID') ifPresent: [:match | match to: node ]].
	self ast acceptNodeVisitor: calc.
	
]

{ #category : #initialization }
RCMatchCollection >> linkXML [

	ast := (RCASTCollection global fetchASTAt: xmlName).
	ast root attributeAt: 'SourceFileName' put: sourceName.
]

{ #category : #accessing }
RCMatchCollection >> matches [
	^ matches
]

{ #category : #accessing }
RCMatchCollection >> size [
	^matches size
]

{ #category : #accessing }
RCMatchCollection >> sourceName [
	^ sourceName
]

{ #category : #accessing }
RCMatchCollection >> sourceName: aName [
	| idx |
	sourceName := aName.
	idx := sourceName lastIndexOf: $..
	xmlName := (idx = 0
		ifTrue: [ sourceName ]
		ifFalse: [ sourceName copyFrom: 1 to: idx ]), 'xml'.

]

{ #category : #accessing }
RCMatchCollection >> xmlName: anObject [
	xmlName := anObject
]
