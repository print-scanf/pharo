"
I am a user interface that shows a RC pattern and its matches as a tree. If I have a listener, I will inform it when a match is selected.
"
Class {
	#name : #RCPatternUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'pattern',
		'tree',
		'listener'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCPatternUI class >> defaultSpec [

	^ SpecLayout composed add: #tree ; yourself
]

{ #category : #'instance creation' }
RCPatternUI class >> onPattern: aPattern [
	| inst |
	inst := self basicNew.
	inst pattern: aPattern.
	inst initialize.
	^inst
]

{ #category : #api }
RCPatternUI >> collapseAll [
		tree collapseAll
]

{ #category : #initialization }
RCPatternUI >> initializePresenter [
		tree whenSelectedItemsChanged: [
			listener ifNotNil: [ |item|
				item := tree selectedItem.
				item ifNotNil: [ 
					item content isString ifFalse:[listener matchSelected: item ]]]].
]

{ #category : #initialization }
RCPatternUI >> initializeWidgets [
	| col1 col2 |
	tree := self newTree.

	col1 := TreeColumnPresenter new
		headerLabel: 'Summary';
		displayBlock: [ :tnp | pattern summaryOf: tnp content];
		initialWidth: 320.
	col2 := TreeColumnPresenter new
		headerLabel: '# Match';
		initialWidth: 60;
		displayBlock: [ :tnp | pattern occOf: tnp content ].

	tree columns: {col1 . col2 }.
	tree childrenBlock: [ :item | pattern childrenOf: item ].

	self resetRoots
]

{ #category : #accessing }
RCPatternUI >> listener: anObject [
	listener := anObject
]

{ #category : #api }
RCPatternUI >> matchFileNames [

	^ pattern matchFileNames
]

{ #category : #accessing }
RCPatternUI >> pattern: anObject [
	pattern := anObject
]

{ #category : #api }
RCPatternUI >> resetRoots [
	pattern ifNotNil: [
			tree roots: pattern treeRoots.
		]
]

{ #category : #accessing }
RCPatternUI >> tree [
	^ tree
]

{ #category : #accessing }
RCPatternUI >> tree: anObject [
	tree := anObject
]
