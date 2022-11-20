"
I am a user interface that shows a RC cluster collection as a tree. If I have a listener, I will inform it when a pattern in a cluster is selected.
"
Class {
	#name : #RCClusterUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'collection',
		'tree',
		'listener'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCClusterUI class >> defaultSpec [

	^ SpecLayout composed add: #tree ; yourself
]

{ #category : #'instance creation' }
RCClusterUI class >> onClusterCollection: aCollection [
	| inst |
	inst := self basicNew.
	inst collection: aCollection.
	inst initialize.
	^inst.

]

{ #category : #accessing }
RCClusterUI >> collection [
	^ collection
]

{ #category : #accessing }
RCClusterUI >> collection: anObject [
	collection := anObject
]

{ #category : #icons }
RCClusterUI >> iconFor: aNode [

	aNode isVariableBinding ifTrue: [ ^self iconNamed: #blank ].
	aNode metadata quality = 0 ifTrue: [ ^self iconNamed: #blank ].
	
	^aNode metadata quality > 0
		ifTrue:  [self iconNamed: #thumbsUp ]
		ifFalse: [self iconNamed: #thumbsDown]
]

{ #category : #initialization }
RCClusterUI >> initializePresenter [
		tree whenSelectedItemsChanged: [
			listener ifNotNil: [ listener patternSelected: tree highlightedItem ] ].
]

{ #category : #initialization }
RCClusterUI >> initializeWidgets [
	| col1 col2 col3 col4 col5|
	tree := self newTree.

	tree iconBlock: [ :node | self iconFor: node ].
	
	col1 := TreeColumnPresenter new
			headerLabel: 'ID';
			displayBlock: [:tnp | collection inspectorIDOf: tnp content ];
			initialWidth: 100;
			headerAction: [tree expandAll].
	col2 := TreeColumnPresenter new
			headerLabel: 'Count';
			initialWidth: 65;
			displayBlock: [:tnp | collection inspectorCountOf: tnp content ].
	col3 := TreeColumnPresenter new
			headerLabel: 'Sup';
			initialWidth: 65;
			displayBlock: [:tnp | collection inspectorSupOf: tnp content ].
	col4 := TreeColumnPresenter new
			headerLabel: 'WSup';
			initialWidth: 65;
			displayBlock: [:tnp | collection inspectorWSupOf: tnp content ].
	col5 := TreeColumnPresenter new
			headerLabel: 'Size';
			initialWidth: 60;
			displayBlock: [:tnp | collection inspectorSizeOf: tnp content ].	
	
	tree columns: {col1 . col2 . col3 . col4 . col5}.	
	
	tree childrenBlock: [ :item |(collection inspectorChildrenOf: item)].
	
	self resetRoots
]

{ #category : #accessing }
RCClusterUI >> listener [
	^ listener
]

{ #category : #accessing }
RCClusterUI >> listener: anObject [
	listener := anObject
]

{ #category : #api }
RCClusterUI >> refresh: aPattern [
	"tree updateTree"

]

{ #category : #api }
RCClusterUI >> resetRoots [
	collection ifNotNil: [ 
		tree roots: collection clusters.
		tree expandAll
	 ]
]

{ #category : #accessing }
RCClusterUI >> tree [
	^ tree
]

{ #category : #accessing }
RCClusterUI >> tree: anObject [
	tree := anObject
]
