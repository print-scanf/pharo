"
This visitor destructively filters a Raincode AST XML dump, removing unneeded attributes.
"
Class {
	#name : #RCASTFilter,
	#superclass : #XMLNodeVisitor,
	#instVars : [
		'programName'
	],
	#category : #'Intimals-AST'
}

{ #category : #private }
RCASTFilter >> handleEnclosing: aRCASTNode [ 
	| refContents idx slash colon|
	
	refContents := aRCASTNode attributeAt: 'GetEnclosing'.
	aRCASTNode removeAttribute: 'GetEnclosing'.
	
	slash := refContents findLastOccurrenceOfString:'\' startingAt: 1.
   colon := (refContents indexOf: $: startingAt: slash).
"	(refContents copyFrom: slash + 1 to: colon - 1) = self programName
		ifFalse: [Exception signal: 'External enclosing references not supported.']."

	idx := refContents copyFrom: colon +1 to: refContents size.
	aRCASTNode attributeAt: 'ParentLevel' put: idx.
	
]

{ #category : #private }
RCASTFilter >> handleRef: aRCASTNode [ 
	| refContents idx slash colon|
	
	refContents := aRCASTNode attributeAt: 'Ref'.
	aRCASTNode removeAttribute: 'Ref'.
	
	slash := refContents findLastOccurrenceOfString:'\' startingAt: 1.
   colon := (refContents indexOf: $: startingAt: slash).
"	(refContents copyFrom: slash + 1 to: colon - 1) = self programName
		ifFalse: [Exception signal: 'External module references not supported.']."

	
	idx := refContents copyFrom: colon +1 to: refContents size.
	aRCASTNode attributeAt: 'XRef' put: idx.
	
]

{ #category : #accessing }
RCASTFilter >> programName [
	^ programName
]

{ #category : #accessing }
RCASTFilter >> programName: anObject [
	programName := anObject
]

{ #category : #visiting }
RCASTFilter >> visitDocument: aDocument [
	self programName: (aDocument root nodes second attributeAt: 'OriginalModuleName').
	aDocument root acceptNodeVisitor: self.
	aDocument root attributeAt: 'Language' put: 'Cobol'.
	self programName: nil.
	^aDocument 
]

{ #category : #visiting }
RCASTFilter >> visitNode: aRCASTNode [
	self halt.
	^super visitNode: aRCASTNode 
]

{ #category : #visiting }
RCASTFilter >> visitNodeWithElements: aRCASTNode [

   aRCASTNode removeAttribute: 'ShiftIndex' ifAbsent: [].
   aRCASTNode removeAttribute: 'EndShiftIndex' ifAbsent: [].
   aRCASTNode removeAttribute: 'OriginalLineNr' ifAbsent: [].
   aRCASTNode removeAttribute: 'OriginalEndLineNr' ifAbsent: [].
   aRCASTNode removeAttribute: 'OriginalModuleName' ifAbsent: [].
	aRCASTNode removeAttribute: 'IsRead' ifAbsent: [].
	aRCASTNode removeAttribute: 'IsWritten' ifAbsent: [].
	(aRCASTNode includesAttribute: 'Ref') ifTrue: [ self handleRef: aRCASTNode. ].
	(aRCASTNode includesAttribute: 'GetEnclosing') ifTrue: [ self handleEnclosing: aRCASTNode. ].
	^super visitNodeWithElements: aRCASTNode
]
