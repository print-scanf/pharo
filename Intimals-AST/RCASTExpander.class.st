"
I am a visitor that transforms parse trees (for COBOL) and adds adhoc/synthetic nodes where needed.
"
Class {
	#name : #RCASTExpander,
	#superclass : #XMLNodeVisitor,
	#instVars : [
		'counter'
	],
	#category : #'Intimals-AST'
}

{ #category : #constants }
RCASTExpander class >> xformDict [
	self deprecated: 'This is an example that should not be used'.
	^ {'WriteStatement' -> {
			RCASTExpansion
				map: { 	'TheSource'->true . 'TheLength'->false . 'TheDestination'->false }
				to:  'WriteStatement_OPT150' }
			} asDictionary.
]

{ #category : #accessing }
RCASTExpander >> counter [
	^ counter
]

{ #category : #accessing }
RCASTExpander >> counter: anObject [
	counter := anObject
]

{ #category : #visiting }
RCASTExpander >> expandElement: aRCASTNode [
	| xforms replace newnodes |
	
	xforms := self class xformDict at: aRCASTNode name ifAbsent: [^self].
	
	newnodes := OrderedCollection new.
	xforms do: [ :xform |
		(xform matches: aRCASTNode) ifTrue: [
			replace := xform matchedNTsIn: aRCASTNode.
			counter := counter + 1.
			newnodes add: (xform pushDown: replace withID: 0 - counter).]
		].

	newnodes do: [:node | self expandElement: node	].

	^self 
]

{ #category : #visiting }
RCASTExpander >> visitDocument: aXMLDocument [ 
	^aXMLDocument root acceptNodeVisitor: self.
]

{ #category : #visiting }
RCASTExpander >> visitElement: aRCASTNode [
	
	super visitNodeWithElements: aRCASTNode.
	
	self expandElement: aRCASTNode.
	^self 
]
