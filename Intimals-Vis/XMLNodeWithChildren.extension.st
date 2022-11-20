Extension { #name : #XMLNodeWithChildren }

{ #category : #'*Intimals-Vis' }
XMLNodeWithChildren >> isUnaryTree [
	| children |
	"I am an unary tree if I have one child and that child is an unary tree"
	"We need to ignore StringNodes to avoid considering spaces :-/"
	children := self nodes reject: [ :node | node isStringNode ].
	
	^children isEmpty or: [(children size <= 1) and: [children first isUnaryTree]]. 
]
