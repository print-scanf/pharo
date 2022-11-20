Extension { #name : #XMLNodeWithChildren }

{ #category : #'*Intimals-AST' }
XMLNodeWithChildren >> childStringSummary [
	| nns |
	
	nns := self nodesNoString.
	
	^ String streamContents: [ :str|
		nns do: [:node | | child |
				str nextPutAll: node name.
				str nextPutAll: '='.
				child := node nodesNoString first.
				child isNil
					ifTrue: [ str nextPutAll: node nodes first string trim]
					ifFalse: [ str nextPutAll: child name ].
				str nextPutAll: '  ']
		]
]

{ #category : #'*Intimals-AST' }
XMLNodeWithChildren >> nodesNoString [
	"returns the nodes that are not strings.
	Useful for trimming all the space string nodes we encounter."
	
	^self nodesSelect: [:node | node isStringNode not]
]
