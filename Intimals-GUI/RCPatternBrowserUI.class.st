"
I am a UI for the exploration of clustered patterns. See my class side for how to use me.
"
Class {
	#name : #RCPatternBrowserUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'clusters',
		'pattern',
		'tabs',
		'graph',
		'src',
		'matchsrc',
		'clusterColl',
		'selectedPattern',
		'commonColl',
		'metadata',
		'closable'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCPatternBrowserUI class >> defaultSpec [
	^ SpecLayout composed newRow: [ :root |
		root newColumn: [ :col |
				col 	newRow: [ :row | row add: #clusters ; add: #pattern ];
						newRow: [ :row | row add: #tabs ]] width: 800;
			newColumn: [ :col | col add: #matchsrc ]];
		yourself.
]

{ #category : #'instance creation' }
RCPatternBrowserUI class >> onClusterCollection: aCollection [
	| inst |
	inst := self new.
	inst clusterColl: aCollection.
	inst resetRoots.
	^inst.

]

{ #category : #'instance creation' }
RCPatternBrowserUI class >> onClusterCollection: aClustCollection andCommonCollection: aPatCollection [
	| inst |
	inst := self new.
	inst clusterColl: aClustCollection.
	inst commonColl: aPatCollection.
	inst resetRoots.
	^inst.

]

{ #category : #accessing }
RCPatternBrowserUI >> clusterColl [
	^ clusterColl
]

{ #category : #accessing }
RCPatternBrowserUI >> clusterColl: anObject [
	clusterColl := anObject
]

{ #category : #accessing }
RCPatternBrowserUI >> clusters [
	^ clusters
]

{ #category : #accessing }
RCPatternBrowserUI >> clusters: anObject [
	clusters := anObject
]

{ #category : #accessing }
RCPatternBrowserUI >> commonColl [
	^ commonColl
]

{ #category : #accessing }
RCPatternBrowserUI >> commonColl: anObject [
	commonColl := anObject
]

{ #category : #accessing }
RCPatternBrowserUI >> extent [
	^1450@700
]

{ #category : #initialization }
RCPatternBrowserUI >> initializeWidgets [
	| tab |
	
	closable := false.
	self askOkToClose: true.
	
	clusters := self instantiate: RCClusterUI.
	pattern := self instantiate: RCPatternUI.
	clusters collection: clusterColl.
	clusters listener: self.
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
	
	metadata := self instantiate: RCPatternMetadataUI.
	metadata browser: self.
	tab := self newTab.
	tab label: 'Metadata'; closeable: false.
	tab presenter: metadata.
	tabs addTab: tab.
	
	matchsrc := self instantiate: RCMatchUI.
]

{ #category : #'api-events' }
RCPatternBrowserUI >> matchSelected: aTNP [
	aTNP isNil ifFalse: [
		aTNP content isNil ifFalse: [
			aTNP content isString ifFalse: [ | match |
				match := aTNP content.
				matchsrc fragment: match getSourceFragment.
				matchsrc source: match getSource.
				match highlight: matchsrc.
				]]]
		
]

{ #category : #accessing }
RCPatternBrowserUI >> matchsrc [
	^ matchsrc
]

{ #category : #accessing }
RCPatternBrowserUI >> matchsrc: anObject [
	matchsrc := anObject
]

{ #category : #'api-events' }
RCPatternBrowserUI >> metadataChanged: aPattern [
	clusters refresh: aPattern.
	
]

{ #category : #'api-events' }
RCPatternBrowserUI >> okToChange [

	^closable
		ifTrue: [ true ]
		ifFalse: [
			closable := UIManager default questionWithoutCancel: 'Are you sure you want to close this browser?' ]

]

{ #category : #accessing }
RCPatternBrowserUI >> pattern [
	^ pattern
]

{ #category : #accessing }
RCPatternBrowserUI >> pattern: anObject [
	pattern := anObject
]

{ #category : #'api-events' }
RCPatternBrowserUI >> patternSelected: aTNP [
	aTNP isNil ifFalse: [
		aTNP content isNil ifFalse: [| match |
			aTNP content isVariableBinding
				ifTrue: [ "It's a cluster"
					commonColl isNil "common patterns for clusters are absent?"
						ifTrue: [ ^self ] "don't do anything"
						ifFalse: [ aTNP content key = '0'
								ifTrue: [ ^self ] 
								ifFalse: [selectedPattern := commonColl patternWithID: aTNP content key]]]
				ifFalse: [ "It's a pattern"
					selectedPattern := aTNP content].
			
			pattern collapseAll.
			pattern pattern: selectedPattern.
			pattern resetRoots.
				
			match := selectedPattern exampleMatch.
			matchsrc fragment: match getSourceFragment.
			matchsrc source: match getSource.
			match highlight: matchsrc.
			
			metadata pattern: selectedPattern.
			src text: selectedPattern subtree asHighlightedSourceText.
			"hack to ensure popups of the graph work"
			[tabs dependents anyOne widget selectedTab refreshContent]
				onDNU: #form do:[:ex | ]."Ignore errors in refresh"
			]]

]

{ #category : #api }
RCPatternBrowserUI >> resetRoots [
	clusters collection: clusterColl.
	clusters resetRoots
]

{ #category : #accessing }
RCPatternBrowserUI >> tabs [
	^ tabs
]

{ #category : #accessing }
RCPatternBrowserUI >> tabs: anObject [
	tabs := anObject
]
