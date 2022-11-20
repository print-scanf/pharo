"
I am a second implementation of the transformer of Raincode grammar xml files to Intimals metamodel grammar xml files.

I am structured as a sequence of multiple passes (that may be different visitors) over the XML file. Second system effect FTW!

RCCobolGrammarProducer transformFileNamed: 'C:\Users\johan\Documents\Intimals\Grammars_prop\cobolpre.xml'
"
Class {
	#name : #RCCobolGrammarProducer,
	#superclass : #Object,
	#instVars : [
		'xml'
	],
	#category : 'Intimals-Grammar'
}

{ #category : #transforming }
RCCobolGrammarProducer class >> transformFileNamed: aFileName [
	| inst domparser |

	domparser := XMLDOMParser onFileNamed: aFileName.
	domparser optimizeForLargeDocuments.
	
	inst := self new.
	inst xml: domparser parseDocument.

	inst transformAndDumpTo: (aFileName copyFrom: 1 to: (aFileName size ) - 7) , '-postgen.xml'

]

{ #category : #utility }
RCCobolGrammarProducer >> addAbstractNodeNamed: nam in: rules [
	| abstract |

	abstract := XMLElement named: nam.
	abstract attributeAt: 'abstract' put: 'true'.
	rules addNode: (XMLString string: String lf).
	rules addNode: abstract.
	
	^abstract
]

{ #category : #utility }
RCCobolGrammarProducer >> ensureORInListNode: aListNode [
	"if the list contains something else than a single OR, add an OR with one alternative"
	| contents fakeor alt |
	
	contents := aListNode nodesNoString.
	contents first isOrNode ifFalse: [
		fakeor := XMLElement name: 'OR'.
		alt := XMLElement name: 'ALT'.
		fakeor addNode: alt.
					
		(contents size = 1
			and: [ contents first includesAttribute: 'mandatory' ])
			ifTrue: [
				fakeor attributeAt: 'mandatory' put: 'false'.
				contents first removeAttribute: 'mandatory' ].
					
		alt addNodes: contents.
		aListNode addNode: fakeor.
	]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> flattenSingleElementListsIn: root [

	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
				(sub isListNode) ifTrue: [ | elems |
					elems := sub nodesNoString.
					((elems size = 1) and: [elems first isOrNode not]) ifTrue: [
						sub pushListAttribsDownTo: elems first.
						sub parent nodes at: (sub parent nodes indexOf: sub) put: elems first.
						]
					] 
		 ]]


]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> insertKeywordNodesIn: root [
	root nodesNoString do: [:node |
		node descendantNodes do: [:sub | | content |
			sub isStringNode ifTrue: [
				content := sub string findTokens: ' '.
				1 to: content size do: [:idx| | newnode |
					((content at: idx) = '(Token)' or: [ (content at: idx) = '(BOOL)'])
						ifTrue: [
							newnode := XMLElement name: 'The',(content at: idx-1).
							newnode attributeAt:'keyword' put: 'true'.
							sub parent nodes add: newnode after: sub.
						]].
				"Keep whitespace nodes, all others are removed"
				sub isIgnorable ifFalse: [
					(sub string first = Character lf)
						ifTrue: [sub string: '\'withCRs ]
						ifFalse: [sub parent removeNode: sub]]]
			]
		]
]

{ #category : #utility }
RCCobolGrammarProducer >> leastGeneral: first or: second [
	| fnodes snodes fmand smand least |

	fnodes := first nodesNoString.
	snodes := second nodesNoString.
	
	fmand := fnodes select: [:n | n includesAttribute: 'mandatory'].
	smand := snodes select: [:n | n includesAttribute: 'mandatory'].
	
	(fmand size = 0 and: [ smand size = 0 ])
		ifTrue:[ Error signal: 'Malformed rule for duplicate check' ].
	
	(fmand size = 1 and: [ smand size = 0 ]) ifTrue: [ ^second ].
	(smand size = 1 and: [ fmand size = 0 ]) ifTrue: [ ^first ].

	least := nil.

	"Data reveals that # nodes is the same and order is the same"	
	(fnodes size = snodes size) ifFalse: [ Error signal: 'Malformed rule for duplicate check' ].
	
	1 to: fnodes size do: [ :idx | | fm sm |
		((fnodes at: idx) name = (snodes at: idx) name) ifFalse: [ Error signal: 'Malformed rule for duplicate check' ].
		
		fm := (fnodes at: idx) includesAttribute: 'mandatory'.
		sm := (snodes at: idx) includesAttribute: 'mandatory'.
		(fm = sm) ifFalse: [
			least = nil
				" set least general node to the one without the flag "
				ifTrue: [ least := (fm ifTrue: [ second ] ifFalse: [ first ]) ]
				" check that this flag does not contradict least general"
				ifFalse: [ fm 
					ifTrue: [ least = second ifFalse: [^nil]]
					ifFalse: [ least = first ifFalse: [^nil]]].
			 ]
	].

	^least
]

{ #category : #utility }
RCCobolGrammarProducer >> leastGeneralList: first or: second [
	"data shows that we do not need to look inside the lists if a rule has only 1 node that is a list"
	| fnodes snodes fm sm |
		
	fnodes := first nodesNoString.
	snodes := second nodesNoString.
	
	
	fnodes size = 1 ifFalse: [ ^nil ].
	snodes size = 1 ifFalse: [ ^nil ].
	fnodes first name = 'LIST' ifFalse: [ ^nil ].
	snodes first name = 'LIST' ifFalse: [ ^nil ].
	
	fm := (fnodes first attributeAt: 'maybempty') = 'true'.
	sm := (snodes  first attributeAt: 'maybempty') = 'true'.
	
	fm = sm ifTrue: [ ^nil ].
	^ fm ifTrue: [ second ] ifFalse: [ first ].
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> listContentsToAbstractNodesIn: root [

	root nodesNoString do: [ :node | | counter |
		counter := 1.
		node descendantNodes do: [ :sub |
			sub isListNode ifTrue:[ | absName mbee |
				absName := node name , '_ElemOfList' , counter asString.
				mbee := self listORToAbstractNodes: sub in: node parent withName: absName.
				sub removeNodes.
				sub name: node name ,'_List_' , counter asString.
				sub attributeAt: 'ordered-nodelist' put: absName.
				(mbee or: (sub attributeAt: 'maybempty') = 'true')
					ifTrue: [ sub attributeAt: 'mandatory' put: 'false' ].
				sub removeAttribute: 'maybempty'.
				counter := counter + 1.
			]
		]
	]
]

{ #category : #utility }
RCCobolGrammarProducer >> listORToAbstractNodes: aListNode in: rules  withName: nam [
	| mayBeEmpty |

	mayBeEmpty := false.

	(aListNode nodesNoString first nodesNoString collect: [:alt | alt nodes])
		asOrderedCollection do: [:alt | | abstract filtered |
			
			filtered := alt select: [ :node | node isStringNode not ].
			(filtered size = 1
				and: [ filtered first includesAttribute: 'mandatory' ])
				ifTrue: [
					filtered first removeAttribute: 'mandatory'.
					mayBeEmpty := true. ].
			
			"this alternative is an OR -> expand it as well"
			(filtered size = 1 and: [ filtered first isOrNode ])
				ifTrue: [ | nor |
					nor := filtered first.	
					nor nodesNoString do: [:nalt|
						abstract := self addAbstractNodeNamed: nam in: rules.
						abstract addNodes: nalt nodes asOrderedCollection]]
				ifFalse: [ 
					abstract := self addAbstractNodeNamed: nam in: rules. 
					abstract addNodes: alt asOrderedCollection]
			].
		
	^mayBeEmpty

]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> optToMandFalseIn: root [

	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
				(sub isOptNode) ifTrue: [ | opts |
					opts := sub nodesNoString.
					(opts size = 1) ifTrue: [
						opts first attributeAt: 'mandatory' put: 'false'.
						sub nodes reversed do: [:sn |
							sub parent nodes add: sn before: sub].
						sub parent removeNode: sub.
						]
					] 
		 ]]


]

{ #category : #utility }
RCCobolGrammarProducer >> populateRulesDictFrom: root [
	| dict |
	
	dict := Dictionary new.
	
	root nodesNoString do: [ :node | | vals |
		vals := dict at: node name ifAbsentPut: [ OrderedCollection new ].
		vals add: node].
	
	^dict
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeDoubleOptsIn: root [
	| doubles |
	doubles := OrderedCollection new.

	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
				(sub isOptNode) ifTrue: [ | opts |
					opts := sub nodesNoString.
					((opts size = 1) and: [ opts first isOptNode ]) ifTrue: [
						doubles add: sub]] 
		 ]].

	doubles do: [:doub | | nopt |
		nopt := doub nodesNoString first.
		doub parent nodes add: nopt after: doub.
		doub parent removeNode: doub]

]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeDuplicateAlternativesIn: root [
	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
			(sub isOr2Node or: [sub isOrNode]) ifTrue: [ | alts  |
				alts := sub nodesNoString.
				alts size = 2 ifTrue: [ | lhs rhs |
					lhs := alts first nodesNoString.
					rhs := alts second nodesNoString.
					((lhs size = rhs size) and: [ lhs size = 1 ]) ifTrue: [ | l r |
						l := lhs first. r := rhs first.
						((l name = r name)
							and: [ l isOrNode not
							and: [ (l attributeAt: 'node') = (r attributeAt: 'node')]])
							ifTrue: [ | keep |
								(l includesAttribute: 'mandatory')
									ifTrue: [ keep := l ]
									ifFalse: [ keep := r ].
								sub parent addNode: keep before: sub.
								sub parent removeNode: sub.
								]].
					]
				]
			]
		]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeDuplicateRulesIn: root [
	| dict |

	dict := Dictionary new.
	root nodesNoString do: [ :node | | vals |
		vals := dict at: node name ifAbsentPut: [ OrderedCollection new ].
		vals add: node].
	
	dict valuesDo: [:coll | | tcoll | 
		tcoll := coll.
		[tcoll size > 1] whileTrue: [ | first dups |
			"go through all rules and remove dup of the first"
			first := tcoll first.
			dups := tcoll select: [ :cand | cand sameRuleAs: first ].
			dups remove: first.
			dups do: [:dup |
				self removeRule: dup.
				tcoll remove: dup].

			"next iteration considers subset of possible remaining duplicates"
			tcoll size > 1 ifTrue: [ tcoll := tcoll copyFrom: 2 to: tcoll size].
		 ]
	].

]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeEmptiesIn: root [

	root nodesNoString do: [:node | | retry |
		retry := true.
		[ retry ] whileTrue: [
			retry := false.
			node descendantNodes do: [:sub | 
				((sub isOptNode or: [sub isOr2Node or: [sub isOrNode or: [sub isListNode ]]])
					and: [ sub nodesNoString isEmpty ])
					ifTrue: [ sub parent removeNode: sub. retry := true]
		]]]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeEmptyAlternativesIn: root [
	"If there are a number of empty alternatives,
	this OR should be included in an OPT + empties should be removed	"
	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
			(sub isOr2Node or: [sub isOrNode]) ifTrue: [ | alts hasempty |
				alts := sub nodesNoString.
				hasempty := alts anySatisfy: [ :alt | alt nodes isEmpty ].
				hasempty ifTrue: [| opt |
					sub removeNodes: (alts select: [ :alt | alt nodes isEmpty ]).
					opt := XMLElement named: 'OPT'.
					sub parent addNode: opt before: sub.
					opt addNode: sub.]
				]]
		]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeEmptyRulesIn: root [
	
	root nodesNoString do: [:node|
		node nodesNoString isEmpty ifTrue: [self removeRule: node]].
]

{ #category : #utility }
RCCobolGrammarProducer >> removeRule: aNode [
	"We assume the node is a rule, remove the node and its subsequent cr XMLString"
	| parent nodes index post |	

	parent := aNode parent.
	nodes := parent nodes.
	index := nodes identityIndexOf: aNode.

	post := (nodes at: index + 1).
	
	(post isStringNode not or: [ (post string first = Character lf) not])
		ifTrue: [Error signal: 'Unexpected kind of node removal'].
		
	nodes removeAt: index + 1.
	nodes removeAt: index. 
]

{ #category : #utility }
RCCobolGrammarProducer >> removeSemanticDuplicates: aCollection [

	1 to: aCollection size - 1 do: [ :index | 
		| ref cand |
		ref := aCollection at: index.
		cand := aCollection at: index + 1.
		(ref approximateRepresentation = cand approximateRepresentation) ifTrue:[ |nodes trash|
			nodes := ref nodesNoString.
			trash := 	(nodes anySatisfy: [ :n | n isOrNode or: [ n isListNode ]])
				ifTrue: [ self leastGeneralList: cand or: ref ]
				ifFalse: [ self leastGeneral: cand or: ref ].
			trash ifNotNil: [
				self removeRule: trash.
				^self]
			]
	]
]

{ #category : #utility }
RCCobolGrammarProducer >> removeSemanticDuplicatesIn: root [
	| dict |

	dict := self populateRulesDictFrom: root.

	dict valuesDo: [ :coll | self removeSemanticDuplicates: coll]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> removeSingleAlternativesIn: root [

	root nodesNoString do: [:node | | retry |
		retry := true.
		[ retry ] whileTrue: [
			retry := false.
			node descendantNodes do: [:sub | 
				((sub isOr2Node or: [sub isOrNode]) and: [ sub nodesNoString size = 1 ])
					ifTrue: [ | contents |
						contents := sub nodesNoString first.
						contents nodes do: [:content |
							sub parent nodes add: content after: sub].	
						sub parent removeNode: sub. 
						retry := true]
		]]]
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> restructureDisjunctsIn: root [
	"Changes the <OR><foo></SEP><asdf></OR> to a real hierarchy" 

	root nodesNoString do: [:node | 
		node descendantNodes do: [:sub | 
			(sub isOr2Node or: [sub isOrNode]) ifTrue: [ | alts ralts |
				alts := sub nodesNoString.
				ralts := OrderedCollection new.
				ralts add: OrderedCollection new.
				alts do: [:alt |
					alt isSepNode
						ifTrue: [ ralts add: OrderedCollection new ]
						ifFalse: [ ralts last add: alt ]].
				sub removeNodes.
				ralts do: [ :ralt | |nalt|
					nalt := XMLElement named: 'ALT'.
					nalt addNodes: ralt.
					sub addNode: nalt.
					]
				]]
		]
]

{ #category : #public }
RCCobolGrammarProducer >> transformAndDumpTo: aFileName [

	self transformXML.
	xml printToFileNamed: aFileName
]

{ #category : #public }
RCCobolGrammarProducer >> transformXML [
	| root |
	
	root := xml nodes first.
	
	self insertKeywordNodesIn: root.
	self removeEmptiesIn: root.

	self removeEmptyRulesIn: root.
	self removeDuplicateRulesIn: root.	
	
	self flattenSingleElementListsIn: root.
	
	self restructureDisjunctsIn: root.
	self removeDuplicateAlternativesIn: root.
	self removeEmptyAlternativesIn: root.
	self removeSingleAlternativesIn: root.

	self removeEmptiesIn: root.

	"the above leaves empty singles"	
	self removeEmptyAlternativesIn: root.
	self removeSingleAlternativesIn: root.
	
	self removeDoubleOptsIn: root.
	self optToMandFalseIn: root.

	self removeDuplicateRulesIn: root.	
	self removeSemanticDuplicatesIn: root.
	
	self unifyListNodesIn: root.
	self listContentsToAbstractNodesIn: root.
	self removeDuplicateRulesIn: root.

	^self
]

{ #category : #'transform passes' }
RCCobolGrammarProducer >> unifyListNodesIn: root [

	root nodesNoString do: [ :node |
		node descendantNodes do: [ :sub |
			sub isListNode ifTrue:[ | or |
				self ensureORInListNode: sub.
				or := sub nodesNoString first.
				(or includesAttribute: 'mandatory') ifTrue: [ 
					sub attributeAt: 'maybempty' put: 'true'.
					or removeAttribute: 'mandatory'.
				].
				(sub includesAttribute: 'mandatory') ifTrue: [ 
					sub attributeAt: 'maybempty' put: 'true'.
					sub removeAttribute: 'mandatory'.
				]
			]	
		]
	]
]

{ #category : #accessing }
RCCobolGrammarProducer >> xml: anObject [
	xml := anObject
]
