"
I am a customisation of the highlight visitor for matches from item set matching (paths)
"
Class {
	#name : #RCPathMatchHighlightVisitor,
	#superclass : #RCHighlightVisitor,
	#category : #'Intimals-Vis'
}

{ #category : #visiting }
RCPathMatchHighlightVisitor >> visitNodeWithElements: aNode [
	"this node is an AST edge, actually"
	
	(self is: aNode taggedAs: '?_visited')
		ifTrue: [self highlight: aNode color: (RCIntPalettes astColorFor: '?_visited')].
				
	"consider the destinations of the AST Edge"
	aNode nodesNoString do: [:node |
		(self is: node taggedAs: '?_visited')
			ifTrue: [	self highlight: node color: (RCIntPalettes astColorFor: '?_visited')]
			ifFalse: [self highlight: node color: Color gray].
		super visitNodeWithElements: node].
]
