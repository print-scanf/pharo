"
I am a builder of a graph of an Intimals source code pattern. See my class side for how to instantiate me.
"
Class {
	#name : #RCIntPatternGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'view',
		'pattern'
	],
	#category : #'Intimals-Vis'
}

{ #category : #building }
RCIntPatternGraphBuilder class >> build: aPattern on: aView [
	| inst |
	inst := self new.
	inst pattern: aPattern.
	inst view: aView.
	^inst build
]

{ #category : #building }
RCIntPatternGraphBuilder >> build [
	| b els gn | 
	b := RTMondrian new.
	b view: view.
	view @ RTDraggableView @ RTZoomableView.
	b interaction noInteractions.
	b interaction popup
			text: [:elt | self popupTextFor: elt ];
			backgroundColor: Color white darker;
			alphaPopupBackground: 1.

	(pattern subtree attributeAt: 'size') asInteger > 400
		ifTrue: [ 
			b shape rectangle
				size: 10;
				color: [:elt | self graphColorFor: elt ];
				borderColor: (Color darkGray)]
		ifFalse: [
			b shape rectangle
				size: 10;
				color: [:elt | self graphColorFor: elt ];
				borderColor: (Color darkGray);
				withTextAbove: [:elt | self nodeTextFor: elt ]].

	gn := self graphNodes.
	els := b nodes: gn.
	self buildEdges: b edges.
   b layout tree.
   b build.
"	els do: [ :e | | l |
		l := RTLabeled new
			view: b view;
			text: [:elt | self popupTextFor: elt ];
			setAsShouldBeInTheFront;
			setAsHighlightable.
		l color: Color red.
		l lowColor: Color black.
		e @ l ]."
	self buildLegend.

	^b view.
]

{ #category : #building }
RCIntPatternGraphBuilder >> buildEdges: ebuilder [
	| edges shape |
	shape := RTStyledMultiLine new.
	shape withVerticallAttachPoint.
	shape orthoVerticalBalanceTo: 0.2.
	shape color: (Color white darker).
	ebuilder shape: shape.

	edges := ebuilder connectFromAll: [ :v | Array with: v parent parent with: v parent].
"	edges @ (RTPopup new
		text: [:assoc | assoc value parent name];
		backgroundColor: Color lightGray lighter;
		borderColor: Color lightGray lighter;
		alphaPopupBackground: 1)."
	^edges.
]

{ #category : #building }
RCIntPatternGraphBuilder >> buildLegend [
	| lb |
	lb := RTLegendBuilder new.
	lb view: view; left.
	lb addColor: (RCIntPalettes pattern at: 2) text: 'Unordered'.
	lb addColor: (RCIntPalettes pattern at: 3) text: 'Sequence'.
"	lb addColor: (RCIntPalettes pattern at: 1) text: '> 1 directives' ."
	lb build.
]

{ #category : #building }
RCIntPatternGraphBuilder >> graphColorFor: aNode [
	| dirNode |
	aNode isStringNode ifTrue: [ ^Color gray ].

	aNode name = '__directives' ifTrue: [ ^self graphColorForDirectives: aNode ].
		
	aNode name = 'meta-variable' ifTrue: [^RCIntPalettes pattern at: 5 ].
	aNode name = 'parameter' ifTrue: [^RCIntPalettes pattern at: 6 ].
	aNode name = 'wildcard' ifTrue: [^RCIntPalettes pattern at: 7 ].
	aNode name = 'optional' ifTrue: [^RCIntPalettes pattern at: 8 ].
	
	"we need to look for directive nodes up to 3 levels up"
	dirNode := aNode parent nodesNoString
		detect: [ :dir | dir name = '__directives' ]
		ifNone: [ aNode parent parent nodesNoString
			detect: [ :dir | dir name = '__directives' ]
			ifNone: [ aNode parent parent parent nodesNoString
				detect: [ :dir | dir name = '__directives' ]
				ifNone: [ ^Color black ] ]].
	
	^self graphColorForDirectives: dirNode.
]

{ #category : #building }
RCIntPatternGraphBuilder >> graphColorForDirectives: aDirectivesNode [
	|sub|
	
	sub := aDirectivesNode nodesNoString.
	sub size > 1 ifTrue: [^RCIntPalettes pattern at: 1].
	(sub anySatisfy: [:node | node name ='match-set' ])
			ifTrue: [^RCIntPalettes pattern at: 2 ].
	(sub anySatisfy: [:node | node name ='match-sequence' ])
			ifTrue: [^RCIntPalettes pattern at: 3 ].
	^RCIntPalettes pattern at: 1
]

{ #category : #building }
RCIntPatternGraphBuilder >> graphNodes [
	| coll |

	coll := OrderedCollection with: pattern subtree nodesNoString first.
   coll addAll: (coll first nodesNoString flatCollect: [ :edge | self graphNodesOfASTEdge: edge]).
	^coll
]

{ #category : #building }
RCIntPatternGraphBuilder >> graphNodesOfASTEdge: anASTEdge [
	| coll |

	anASTEdge name = '__directives' ifTrue:[^#()].
		
	coll := anASTEdge nodes asOrderedCollection reject: [:node |
			node isIgnorable or:
			[node isStringNode not and: [node name = '__directives']]].
	coll addAll:
		(coll flatCollect: [:node |
			node nodesNoString asOrderedCollection flatCollect: [:edge |
				self graphNodesOfASTEdge: edge]]).
	^coll
	
]

{ #category : #building }
RCIntPatternGraphBuilder >> nodeTextFor: aNode [
	| nodename names ucidx runidx |

	nodename := (aNode isStringNode)
		ifTrue: [ aNode string trimmed ] 
		ifFalse: [ aNode name ].
	nodename = '__directives' ifTrue: [^'@'].
	nodename size <= 5 ifTrue: [^nodename].
	
	ucidx := nodename indexOfFirstUppercaseCharacter.	
	ucidx = 0 ifTrue: [ |minidx|
		minidx := nodename indexOf: $- ifAbsent: 0.
		minidx = 0
			ifTrue: [^nodename truncateTo: 4]
			ifFalse: [ucidx := 1 ]].

	names := OrderedCollection new.
	
	ucidx = 1 ifFalse: [ names add: (nodename copyFrom: 1 to: ucidx - 1 )].
	
	runidx := ucidx+1.
	[runidx <= nodename size ] whileTrue: [
		(nodename at: runidx) isUppercase
			ifTrue: [
				names add: (nodename copyFrom: ucidx to: runidx - 1).
				ucidx := runidx.]
			ifFalse: [ (nodename at: runidx) = $- ifTrue: [ 
					names add: (nodename copyFrom: ucidx to: runidx - 1).
					names add: '-'.
					runidx := runidx + 1. "skip the $-" 
					ucidx := runidx.]].
		 runidx := runidx + 1.
		].
		
	names add: (nodename copyFrom: ucidx to: nodename size). 

	^String streamContents: [ :aStream |
		names do: [ :nam | aStream nextPutAll: (nam truncateTo: 4) ]]

]

{ #category : #accessing }
RCIntPatternGraphBuilder >> pattern: anObject [
	pattern := anObject
]

{ #category : #building }
RCIntPatternGraphBuilder >> popupTextFor: aNode [
	^aNode isStringNode
		ifTrue: [ aNode string trimmed ]
		ifFalse: [aNode parent name , ': ' , aNode name ] 
]

{ #category : #accessing }
RCIntPatternGraphBuilder >> view: anObject [
	view := anObject
]
