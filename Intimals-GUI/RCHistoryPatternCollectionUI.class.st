"
I am a user interface that shows a pattern collection for history browsing. If I have a listener, I will inform it when a pattern is selected.
"
Class {
	#name : #RCHistoryPatternCollectionUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'collection',
		'listener',
		'tree'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCHistoryPatternCollectionUI class >> defaultSpec [

	^ SpecLayout composed add: #tree ; yourself
]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> collection [
	^ collection
]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> collection: anObject [
	collection := anObject
]

{ #category : #defaults }
RCHistoryPatternCollectionUI >> iconFor: aNode [

	aNode isVariableBinding ifTrue: [ ^self iconNamed: #blank ].
	aNode metadata quality = 0 ifTrue: [ ^self iconNamed: #blank ].
	
	^aNode metadata quality > 0
		ifTrue:  [self iconNamed: #thumbsUp ]
		ifFalse: [self iconNamed: #thumbsDown]
]

{ #category : #initialization }
RCHistoryPatternCollectionUI >> initializePresenter [
		tree whenSelectedItemsChanged: [
			listener ifNotNil: [ listener patternSelected: tree highlightedItem ] ].
]

{ #category : #initialization }
RCHistoryPatternCollectionUI >> initializeWidgets [
	| col1 col2 col3 col4 col5 |
	tree := self newTree.

	col1 := TreeColumnPresenter new
			headerLabel: 'ID';
			displayBlock: [:tnp | tnp content id padLeftTo: 3 ];
			initialWidth: 100.
	col2 := TreeColumnPresenter new
			headerLabel: 'Count';
			initialWidth: 65;
			displayBlock: [:tnp | tnp content size padLeftTo: 3].
	col3 := TreeColumnPresenter new
			headerLabel: 'OSup-NSup';
			initialWidth: 65;
			displayBlock: [:tnp | tnp content support ].
   col4 := TreeColumnPresenter new
			headerLabel: 'ChiSq';
			initialWidth: 65;
			displayBlock: [:tnp | tnp content chisquare truncateWithElipsisTo: 10 ].
	col5 := TreeColumnPresenter new
			headerLabel: 'Size';
			initialWidth: 60;
			displayBlock: [:tnp | tnp content size ].	

	tree columns: {col1 . col2 . col3 . col4 . col5 }.	

]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> listener [
	^ listener
]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> listener: anObject [
	listener := anObject
]

{ #category : #api }
RCHistoryPatternCollectionUI >> refresh: aPattern [
	"tree updateTree"
]

{ #category : #api }
RCHistoryPatternCollectionUI >> resetRoots [
	collection ifNotNil: [ 
		tree roots: collection patterns.
		tree expandAll
	 ]
]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> tree [
	^ tree
]

{ #category : #accessing }
RCHistoryPatternCollectionUI >> tree: anObject [
	tree := anObject
]
