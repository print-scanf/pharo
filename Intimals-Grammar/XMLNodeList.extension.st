Extension { #name : #XMLNodeList }

{ #category : #'*Intimals-Grammar' }
XMLNodeList >> insertNodes: aCollection replacing: anIndex [

	aCollection isEmpty ifTrue: [ ^ self removeAt: anIndex ].

	self at: anIndex put: aCollection first.
	2 to: (aCollection size) do: [ :idx |
		self add: (aCollection at: idx) afterIndex: (anIndex + idx - 2) 
		]
]

{ #category : #'*Intimals-Grammar' }
XMLNodeList >> splitOn: aNameString [
	"split the list in different ordered collections separated by aNameString nodes (excluded)" 
	| disjuncts |
	
	disjuncts := OrderedCollection new.
	disjuncts add: OrderedCollection new.
	self do: [ :node |
		node isIgnorable ifFalse: [ 
			node isStringNode
				ifTrue: [ disjuncts last add: node ]
				ifFalse: [ node name = aNameString
					ifTrue: [ disjuncts add: OrderedCollection new. ]
					ifFalse: [ disjuncts last add: node ] ] ] ] .
	^ disjuncts
]
