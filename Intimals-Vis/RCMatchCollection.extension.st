Extension { #name : #RCMatchCollection }

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> colorSubSubtreesOf: aView withPalette: aPalette [
	| subsub idx |
	"color sub-subtrees for emphasizing in a different color "
	
	subsub := Dictionary new.
	matches do: [:match | match addMatchSubtreesTo: subsub].
	
	"check if nothing to do"
	subsub size = 0 ifTrue: [^self].
	
	idx := 1.	
	(subsub keys sort: [:first :second | first < second]) do: [:key| | col |
			idx := idx + 1. 
			col := aPalette at: idx.
			(subsub at: key) do: [ :assoc | |subroot|
				subroot := RCTreeCalculator findSubNodeOf: assoc key withID: assoc value.
				self emphasizeRecursively: (aView elementFromModel: subroot) in: col ]
		]

]

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> emphasizeRecursively: element in: aColor [
	emphasizedElements add: element.
	element outgoingEdges do: [ :edge |
		edge trachelShape width: 10.
		self emphasizeRecursively: edge to in: aColor ].
	element trachelShape color: aColor.
]

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> emphasizeSubtreeOf: aView [
	| elements palette |
	
	palette := RCIntPalettes ast collect: [:col | col trans].
	emphasizedElements := OrderedCollection new.
	
	"Color the subtrees from the root,
	remember all subtrees so they can be uncolored later"
	elements := matches collect: [:match | aView elementFromModel: match to ].
	elements do: [:element | self emphasizeRecursively: element in: (palette at: 1)].
	
	self colorSubSubtreesOf: aView withPalette: palette.
]

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> graphView [
	graphView isNil
		ifTrue: [ graphView := RTView new]
		ifFalse: [ emphasizedElements do: [:elt |
				elt trachelShape color: Color black.
				elt outgoingEdges do: [:edge | edge trachelShape width: 1 ] ] ].
	^graphView
]

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> gtInspectorGraphIn: composite [
	"<gtInspectorPresentationOrder: -10>"
	
	^composite roassal2
		title: 'Graph';
		initializeView: [self graphView ];
		painting: [:view |
			view elements isEmpty ifTrue: [ 
				Cursor wait showWhile: [
					graphHighlight := RCIntVis new visOf: self ast onView: view.
					view canvas focusOnCenterScaled. ]
				].
				self emphasizeSubtreeOf: view.
			]

		
]

{ #category : #'*Intimals-Vis' }
RCMatchCollection >> gtInspectorSourceFileIn: composite [
	<gtInspectorPresentationOrder: -15>
	
	^composite spec 
		title: 'File src';
		display: [ :elt | | cm  |
			cm := RCIntSourceView onFileName: (self ast root attributeAt: 'SourceFileName').
			cm buildWithSpec.
			cm ]
]
