"
I am a UI for the exploration of patterns and history (old versus new versions). See my class side for how to use me.
"
Class {
	#name : #RCHistoryPatternBrowserUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'patterns',
		'pattern',
		'tabs',
		'graph',
		'src',
		'matchsrc',
		'selectedPattern',
		'oldPatterns',
		'newPatterns'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCHistoryPatternBrowserUI class >> defaultSpec [
	^ SpecLayout composed newRow: [ :root |
		root newColumn: [ :col |
				col 	newRow: [ :row | row add: #patterns ; add: #pattern ];
						newRow: [ :row | row add: #tabs ]] width: 800;
			newColumn: [ :col | col add: #matchsrc ]];
		yourself.
]

{ #category : #'instance creation' }
RCHistoryPatternBrowserUI class >> onOldPatternCollection: oldpats newPatternCollection: newpats [
	| inst |
	inst := self basicNew.
	inst oldPatterns: oldpats; newPatterns: newpats.
	inst initialize.
	^inst
]

{ #category : #api }
RCHistoryPatternBrowserUI >> extent [
	^1450@700
]

{ #category : #initialization }
RCHistoryPatternBrowserUI >> initializeWidgets [
	| tab |
	
	self title: 'Pattern history browser: Old versus New'.
	
	patterns := self instantiate: RCHistoryPatternCollectionUI.
	pattern := self instantiate: RCHistoryPatternUI.
	patterns collection: oldPatterns.
	patterns resetRoots.
	patterns listener: self.
	pattern listener: self.
	
	graph := RoassalModel new.
	graph script: [ :view :canvas | 
			selectedPattern ifNotNil: [
					RCIntPatternGraphBuilder build: selectedPattern on: view.
					canvas camera focusOnCenterScaled: 950@290 ] ].
			
	tabs := self newTabManager.
	tab := self newTab.
	tab label: 'Graph'; closeable: false.
	tab presenter: graph.
	tabs addTab: tab.
	
	src := self newText.
	src beForText.
	
	tab := self newTab.
	tab label: 'Source'; closeable: false.
	tab presenter: src.
	tabs addTab: tab.
	
	matchsrc := self instantiate: RCHistoryMatchUI.
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> matchsrc [
	^ matchsrc
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> matchsrc: anObject [
	matchsrc := anObject
]

{ #category : #'api-events' }
RCHistoryPatternBrowserUI >> newMatchSelected: aMatch withEquivalentFile: aFileNameString [
	| otherSrc |

	otherSrc :=  aFileNameString
		ifNil: [ 'No equivalent old file present.' ] 
		ifNotNil: [ aFileNameString asFileReference contents ].

	matchsrc fragment: aMatch getSourceFragment.
	matchsrc oldSource: otherSrc.
	matchsrc newSource: aMatch getSource.
	aMatch highlight: matchsrc.
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> newPatterns [
	^ newPatterns
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> newPatterns: anObject [
	newPatterns := anObject
]

{ #category : #'api-events' }
RCHistoryPatternBrowserUI >> oldMatchSelected: aMatch withEquivalentFile: aFileNameString [
	| otherSrc |

	otherSrc :=  aFileNameString
		ifNil: [ 'No equivalent new file present.' ] 
		ifNotNil: [ aFileNameString asFileReference contents ].

	matchsrc fragment: aMatch getSourceFragment.
	matchsrc oldSource: aMatch getSource.
	matchsrc newSource: otherSrc.
	aMatch highlight: matchsrc.
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> oldPatterns [
	^ oldPatterns
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> oldPatterns: anObject [
	oldPatterns := anObject
]

{ #category : #initialization }
RCHistoryPatternBrowserUI >> openWithSpec [
	patterns collection: oldPatterns.
	^ super openWithSpec 
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> pattern [
	^ pattern
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> pattern: anObject [
	pattern := anObject
]

{ #category : #'api-events' }
RCHistoryPatternBrowserUI >> patternSelected: aTNP [ 

	aTNP isNil ifTrue: [ ^self].
	
	selectedPattern := aTNP content.
			
	pattern collapseAll.
	pattern oldPattern: selectedPattern newPattern: (newPatterns patternWithID: selectedPattern id).
	pattern resetRoots.
	
	self setMatchSrc: selectedPattern exampleMatch.
	
	src text: selectedPattern subtree asHighlightedSourceText.
	"hack to ensure popups of the graph work"
	[tabs dependents anyOne widget selectedTab refreshContent]
		onDNU: #form do:[:ex | ]."Ignore errors in refresh"

]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> patterns [
	^ patterns
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> patterns: anObject [
	patterns := anObject
]

{ #category : #'api-events' }
RCHistoryPatternBrowserUI >> setMatchSrc: aMatch [
	
	aMatch isNil ifTrue: [ ^self ].

	matchsrc fragment: aMatch getSourceFragment.
	matchsrc oldSource: aMatch getSource. 
	matchsrc newSource: '(this is an example match, only old source file contents are shown)'.
	aMatch highlight: matchsrc.
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> tabs [
	^ tabs
]

{ #category : #accessing }
RCHistoryPatternBrowserUI >> tabs: anObject [
	tabs := anObject
]
