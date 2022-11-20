Extension { #name : #XMLElement }

{ #category : #'*Intimals-Grammar' }
XMLElement >> approximateRepresentation [
	"a summary representation of myself that serves for approximate equals comparisons"
	^ self nodesNoString collect: [ :sub | sub name , '-', (sub attributeAt: 'node') ].
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> approximateRepresentationWithAdhocery [
	"a summary representation of myself that serves for some approximate equals comparisons	"
	^ self nodesNoString collect: [ :sub | | nam |
		nam := sub name.
		(nam beginsWith: 'Adhoc_')
			ifTrue: [ nam := nam copyFrom: 1 to: (nam lastIndexOf: $_)]
			ifFalse: [ nam := sub name ].
		nam , '-', (sub attributeAt: 'node') ].
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isAbstract [
	| content |
	content := self relevantNodes.
	
	(content size = 1) ifFalse: [ ^false ].
	content first isStringNode ifTrue: [ ^false ].
	content first attributes isEmpty ifFalse: [ ^false ].
	content first name = 'UNKNOWN' ifTrue: [ ^false ].	
	^content first nodes isEmpty 

]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isChildLess [
	^self relevantNodes isEmpty
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isGrandparent [
	^self relevantNodes anySatisfy: [:child | child relevantNodes size > 0]
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isListNode [
	^self name = 'LIST'
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isOptNode [
	^self name = 'OPT'
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isOr2Node [
	^self name = 'OR2'
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isOrNode [
	^self name = 'OR'
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> isSepNode [
	^self name = 'SEP'
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> orToOptional: anOrNode [
	| relevant |
	
	"abort if this has been marked with a mandatory attribute"
	(anOrNode attributeAt: 'mandatory') = '' ifFalse: [ ^self].
	
	relevant := anOrNode relevantNodes.
	relevant size = 3 ifFalse: [Error signal: 'OR to optional with wrong number of children.'].
	
	relevant second isSepNode ifFalse: [ ^self ].
	
	relevant first isStringNode ifTrue: [ 
		relevant third isStringNode
			ifTrue: [ self removeNode: anOrNode. ^self ] "<OR> 'foo' </SEP> 'bar' </OR>"
			ifFalse: [
				relevant third isOptNode ifFalse: [
					relevant third attributeAt: 'mandatory' put: 'false'].
				self replaceNode: anOrNode with: relevant third.
				^self]].	
	
	relevant third isStringNode ifTrue: [
		relevant first attributeAt: 'mandatory' put: 'false'.
		self replaceNode: anOrNode with: relevant first.
		^self ].

]

{ #category : #'*Intimals-Grammar' }
XMLElement >> pullUpList: aListNode [
	| rel contents |
	
	rel := aListNode relevantNodes.
	rel size = 1 ifFalse: [Error signal: 'Only <LIST>s with 1 entry are supported.'].
	
	contents := rel first.
	
	contents isStringNode
		ifTrue: [ self removeNode: aListNode. ] "lists of keywords are removed"
		ifFalse: [ 
			aListNode pushListAttribsDownTo: contents.
			self nodes at: (self nodes indexOf: aListNode) put: contents].
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> pullUpOpt: anOptNode [
	| contents |

	anOptNode nodes size = 0 ifTrue: [ self removeNode: anOptNode. ^self ].
	anOptNode nodes size = 1 ifFalse: [^self]. "complex opts are handled differently"
	
	contents := anOptNode nodes first.
	contents isOrNode ifTrue: [ ^self ].
	contents isOptNode ifFalse: [
		contents attributeAt: 'mandatory' put: 'false']. 
	self nodes at: (self nodes indexOf: anOptNode) put: contents.

]

{ #category : #'*Intimals-Grammar' }
XMLElement >> pushListAttribsDownTo: contents [ 
	| memp mand |
	"the UNKNOWN node has no attributes"
	(contents attributeAt: 'node') = '' ifFalse: [ 
		contents attributeAt: 'ordered-nodelist' put: (contents attributeAt: 'node').
		contents removeAttribute: 'node'].
	memp := ((self attributeAt: 'maybempty') = 'true').
	mand := ((self attributeAt: 'mandatory') = 'false') not.
	((memp or: [ mand not ]) and: [ contents isOptNode not ])
		ifTrue: [ contents attributeAt: 'mandatory' put: 'false'].
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> relevantNodes [
	^ self nodes reject: [ :node | node isIgnorable ]
]

{ #category : #'*Intimals-Grammar' }
XMLElement >> sameRuleAs: aNode [
	| mysub nodesub |

	(self name = aNode name) ifFalse: [ ^false ].

	mysub := self nodesNoString.
	nodesub := aNode nodesNoString.
	
	mysub size = nodesub size ifFalse: [ ^false ].
	
	1 to: mysub size do: [:i | |myref noderef|
		myref := mysub at: i.
		noderef := nodesub at: i.
		myref name = noderef name ifFalse: [ ^false ].
		myref attributes = noderef attributes ifFalse: [ ^false ].
	  ].
	
	^true.
]
