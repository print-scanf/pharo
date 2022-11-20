Extension { #name : #XMLString }

{ #category : #'*Intimals-AST' }
XMLString >> isIgnorable [
	^self string trim isEmpty
]

{ #category : #'*Intimals-AST' }
XMLString >> isImage [
	^false
]

{ #category : #'*Intimals-AST' }
XMLString >> nodesNoString [
	^#()
]
