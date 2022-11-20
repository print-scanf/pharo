Extension { #name : #RCPattern }

{ #category : #'*Intimals-Vis' }
RCPattern >> gtInspectorGraphIn: composite [
	<gtInspectorPresentationOrder: 0>
	
	^composite roassal2
		title: 'Graph';
		painting: [:view | RCIntPatternGraphBuilder build: self on: view]
]

{ #category : #'*Intimals-Vis' }
RCPattern >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite spec
		title: 'EG Source';
		display: [ :elt | | cm match |
			match := matches anyOne.
			cm := RCIntSourceView on: match getSourceFragment.
			cm buildWithSpec.
			match highlight: cm.
			cm
			]
]
