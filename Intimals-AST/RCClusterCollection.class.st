"
I am the resulting clusters of a pattern match run, I cluster the patterns from a pattern collection.
"
Class {
	#name : #RCClusterCollection,
	#superclass : #Object,
	#instVars : [
		'clusters',
		'patterns'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCClusterCollection class >> fromFile: aFileName withPatterns: aPatternCollection [
	| xml clusters |
	xml := XMLDOMParser parseFileNamed: aFileName.
	
	clusters := OrderedCollection new.
	clusters add: ('0' -> aPatternCollection).

	xml root nodesNoString do: [:cluster| | patcol |
		patcol := RCPatternCollection new.
		patcol astDir: aPatternCollection astDir.
		patcol patterns: (cluster nodesNoString asOrderedCollection collect: [:pat|
			aPatternCollection patternWithID: (pat attributeAt: 'ID')]).
		clusters add: ( (cluster attributeAt: 'ID') -> patcol).
		].

	^ self new clusters: clusters
]

{ #category : #'instance creation' }
RCClusterCollection class >> withPatterns: aPatternCollection [
	| clusters |
	
	clusters := OrderedCollection new.
	clusters add: ('0' -> aPatternCollection).

	^ self new clusters: clusters
]

{ #category : #accessing }
RCClusterCollection >> clusters [
	^ clusters
]

{ #category : #accessing }
RCClusterCollection >> clusters: anObject [
	clusters := anObject
]

{ #category : #'inspector extensions' }
RCClusterCollection >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: -10>
	^composite fastTreeTable
		title: 'Clusters';
		display: [ clusters ];
		children: [ :each | self inspectorChildrenOf: each ];
		column: 'ID' evaluated: [ :each| self inspectorIDOf: each ] width: 100;
		column: 'Count' evaluated: [ :each | self inspectorCountOf: each ] width: 60;
		column: 'Sup' evaluated: [ :each| self inspectorSupOf: each ] width: 40;
		column: 'WSup' evaluated: [ :each| self inspectorWSupOf: each ] width: 40;
		column: 'Size' evaluated: [ :each| self inspectorSizeOf: each ] width: 40;
		send: [ :each | self inspectorSendOf: each ] 
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorChildrenOf: element [
	^(element isVariableBinding)
		ifTrue: [ element value patterns sort: [:left :right|
				left id asInteger < right id asInteger ]]
		ifFalse:  [ {} ]
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorCountOf: element [
	^(element isVariableBinding)
		ifTrue: [ (element value patterns size asString padLeftTo: 3 with: $0) ,' P']
		ifFalse:  [ (element matches size asString padLeftTo: 3 with: $0),' M']
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorIDOf: element [
	^(element isVariableBinding)
		ifTrue: [ 'Clu: ' , (element key padLeftTo: 3)]
		ifFalse:  [ 'Pat: ', (element id padLeftTo: 3)]
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorSendOf: element [
	^(element isVariableBinding)
		ifTrue: [ element value]
		ifFalse:  [ element ]
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorSizeOf: element [
	^(element isVariableBinding)
		ifTrue: [ ' ']
		ifFalse:  [ element size padLeftTo: 3 with: $0]
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorSupOf: element [
	^(element isVariableBinding)
		ifTrue: [ ' ' ]
		ifFalse:  [ element support padLeftTo: 3 with: $0]
	
]

{ #category : #'inspector extensions' }
RCClusterCollection >> inspectorWSupOf: element [
	^(element isVariableBinding)
		ifTrue: [ ' ']
		ifFalse:  [ element wsupport padLeftTo: 3 with: $0]
	
]
