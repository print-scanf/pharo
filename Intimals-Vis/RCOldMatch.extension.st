Extension { #name : #RCOldMatch }

{ #category : #'*Intimals-Vis' }
RCOldMatch >> emphasizeRecursively: element [
	emphasizedElements add: element.
	element outgoingEdges do: [ :edge |
		edge trachelShape width: 10.
		self emphasizeRecursively: edge to ].
	element trachelShape color: Color blue.
	
		
]

{ #category : #'*Intimals-Vis' }
RCOldMatch >> graphView [
	graphView isNil
		ifTrue: [ graphView := RTView new]
		ifFalse: [ emphasizedElements do: [:elt |
				elt trachelShape color: Color black.
				elt outgoingEdges do: [:edge | edge trachelShape width: 1 ] ] ].
	^graphView
]

{ #category : #'*Intimals-Vis' }
RCOldMatch >> gtInspectorGraphIn: composite [
	<gtInspectorPresentationOrder: 0>
	
	^composite roassal2
		title: 'Graph';
		initializeView: [self graphView ];
		painting: [:view | | elements |
			view elements isEmpty ifTrue: [ 
				Cursor wait showWhile: [
					graphHighlight := RCIntVis new visOf: (self matches first document) onView: view.
					view canvas focusOnCenterScaled. ]
				].
				emphasizedElements := OrderedCollection new.
				elements := self matches collect: [:match | view elementFromModel: match ].
				elements do: [:element | self emphasizeRecursively: element].
			]

		
]
