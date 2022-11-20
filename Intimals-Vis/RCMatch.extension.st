Extension { #name : #RCMatch }

{ #category : #'*Intimals-Vis' }
RCMatch >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: -2>
	
	^composite spec
		title: 'Source';
		display: [ :elt | | cm |
			cm := RCIntSourceView on: self getSourceFragment.
			cm buildWithSpec.
			self highlight: cm.
			cm
			]
]

{ #category : #'*Intimals-Vis' }
RCMatch >> highlight: aRCIntSourceView [
	| highlighter |

	(self type = #fis)
		ifTrue: [ highlighter := RCPathMatchHighlightVisitor ]
		ifFalse: [ highlighter := RCFreqTMatchHighlightVisitor ].

	^(highlighter forMatch: self withView: aRCIntSourceView) doHighlight
]
