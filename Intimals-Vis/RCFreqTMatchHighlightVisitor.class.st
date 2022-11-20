"
I am a customisation of the highlight visitor for matches from freqt matching
"
Class {
	#name : #RCFreqTMatchHighlightVisitor,
	#superclass : #RCHighlightVisitor,
	#category : #'Intimals-Vis'
}

{ #category : #visiting }
RCFreqTMatchHighlightVisitor >> visitNodeWithElements: aNode [
	"this node is an AST edge, actually"

	"consider the destinations of the AST Edge"
	aNode nodesNoString do: [:node |
		(self is: node taggedAs: '?_visited')
			ifTrue: [
					self highlight: node color: (RCIntPalettes astColorFor: '?_visited'). 
					super visitNodeWithElements: node ]
			ifFalse: [
				(self is: node taggedAs: 'error')
					ifTrue: [	self highlight: node color: (RCIntPalettes astColorFor: 'error')]
					ifFalse: [self highlight: node color: Color gray.]]
		 ].
]
