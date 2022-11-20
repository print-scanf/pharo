"
I am the transformer of Raincode grammar xml files to intimals metamodel grammar xml files
"
Class {
	#name : #RCCobolXForm,
	#superclass : #Object,
	#instVars : [
		'rulesSeen',
		'spuriousRules',
		'ahCounter',
		'xpansions'
	],
	#category : 'Intimals-Grammar'
}

{ #category : #rules }
RCCobolXForm >> addAdhocRuleFor: aNode ofRule: aXMLNode [
	"this makes an adhoc rule, 
	 sets its nodes to to the nodes of aNode,
	 and adds it to the list of rules after aXMLNode"
	| parentnodes adhoc |
	parentnodes := aXMLNode parent nodes.
	
	adhoc := XMLElement named: (aXMLNode name, '_' , aNode name , ahCounter asString).
	ahCounter := ahCounter + 1.

	adhoc attributeAt: 'synthetic' put: 'true'.
	adhoc addNodes: aNode nodes asOrderedCollection.

	parentnodes add: adhoc after: aXMLNode.
	parentnodes add: (XMLString string: '\' withCRs ) after: aXMLNode.

	^adhoc
		

	
]

{ #category : #transforming }
RCCobolXForm >> displayMappingFor: root [
	| nodes mapping |
	" show the mapping for renaming needed to execute when producing the ASTs"
	
	self deprecated: 'No longer needed?'.
		
	nodes := root nodesNoString.
	
	mapping := nodes collect: [:node | | children | 
		children := node nodesNoString select: [:child |
			child name = 'TheArgs'
				and: [ (child includesAttribute: 'ordered-nodelist') not ]].
		children isEmpty
			ifTrue: [ nil ]
			ifFalse: [
				(node name substrings: {$_}) first
				 -> (children first attributeAt: 'node')] 
		] thenReject: [:node | node isNil ].
	
	mapping inspect.
]

{ #category : #transforming }
RCCobolXForm >> expansivelyTransform: root [
	| continue |
	" do the transformations that add extra rules,
	iterate until no more rules have been added."
	
	continue := true.
	[ continue ]	whileTrue: [
		continue := false.
		"note that we work on a node list that is not the root's node list"
		root nodesNoString do: [:node |
			continue := (self splitRuleForOpt: node) or: [ continue ].
			continue := (self splitRuleForOr: node) or: [continue].
			continue := (self splitRuleForList: node) or: [continue].
			]].

]

{ #category : #transforming }
RCCobolXForm >> filterStringNodesFrom: anXMLNode [
	"filter out keywords and newlines/spaces"
	(anXMLNode nodes
		select: [ :node | node isStringNode ])
		do: [ :node | anXMLNode removeNode: node ].
]

{ #category : #'initialize-release' }
RCCobolXForm >> initialize [
	rulesSeen := OrderedCollection new.
	ahCounter := 1.
	xpansions := Dictionary new.
]

{ #category : #transforming }
RCCobolXForm >> insertKeywordNodesIn: root [

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
				sub parent removeNode: sub].
			]
		]
]

{ #category : #rules }
RCCobolXForm >> manualCheckRules: root [
	| dict manual |

	dict := self populateRulesDictFrom: root.

	manual := 'Manual duplicate check needed for:' withCRs. 
	dict valuesDo: [ :coll | | checkme |
		checkme := self manualCheckRules: coll asOrderedCollection of: root nodes.
		checkme ifNotNil: [ 
			checkme = 'PerformStatement' ifFalse: [
				manual := manual , ('\' withCRs) , checkme ]].
		].
	manual inspect.
]

{ #category : #rules }
RCCobolXForm >> manualCheckRules: aCollection of: allRules [
	"there may be semantically equivalent rules, keep the most general one"

	1 to: aCollection size - 1 do: [ :index | 
		| ref cand |
		ref := aCollection at: index.
		cand := aCollection at: index + 1.
		ref ifNotNil: [
			ref approximateRepresentationWithAdhocery = cand approximateRepresentationWithAdhocery 
				ifTrue: [^ref name.
			] ] ].

	^nil
]

{ #category : #parsing }
RCCobolXForm >> parse: aFileName [
	| domparser |
	domparser := XMLDOMParser onFileNamed: aFileName.
	domparser optimizeForLargeDocuments.
	^domparser parseDocument.
]

{ #category : #rules }
RCCobolXForm >> populateRulesDictFrom: root [
	| dict |
	
	dict := Dictionary new.
	
	root nodesNoString do: [ :node | | vals |
		vals := dict at: node name ifAbsentPut: [ OrderedCollection new ].
		vals add: node].
	
	^dict
]

{ #category : #rules }
RCCobolXForm >> removeDuplicateRulesFrom: root [
	| dict |

	dict := self populateRulesDictFrom: root.
	
	dict valuesDo: [:coll | | tcoll | 
		tcoll := coll.
		[tcoll size > 1] whileTrue: [ | first dups |
			"go through all rules and remove dup of the first"
			first := tcoll first.
			dups := tcoll select: [ :cand | cand sameRuleAs: first ].
			dups remove: first.
			dups do: [:dup |
				root nodes remove: dup.
				tcoll remove: dup].

			"next iteration considers subset of possible remaining duplicates"
			tcoll size > 1 ifTrue: [ tcoll := tcoll copyFrom: 2 to: tcoll size].
		 ]
	].

	dict := self populateRulesDictFrom: root.
	dict valuesDo: [ :coll | self removeOneMandatoryIn: coll of: root nodes].

]

{ #category : #rules }
RCCobolXForm >> removeEmptyRulesFrom: root [
	| empties nonempties rules names |

	"empty synthetic rules should be removed"	
	rules := root nodesNoString asOrderedCollection.
	empties := rules select: [ :rule | 
		(rule attributeAt: 'synthetic') = 'true' and: [
			 rule nodesNoString isEmpty]].
	
	"end of the recursion"
	empties isEmpty ifTrue: [^self].
	
	empties do: [ :empty | root nodes remove: empty ].
	
	"if there is a nonempty alternate, the ref should not be removed"
	names := empties collect: [:rule | rule name ].
	rules := root nodesNoString.
	nonempties := rules
		select: [:rule | names includes: rule name ]
		thenCollect: [ :rule | rule name ].

	names removeAll: nonempties asSet.

	rules do: [:rule |
		rule nodesNoString asOrderedCollection
			select: [:node | "nodes that refer to the empties"
				{ node attributeAt: 'node' . node attributeAt: 'ordered-nodelist' }
					includesAny: names ]
			thenDo: [:node | rule nodes remove: node]
		].

	self removeEmptyRulesFrom: root.
]

{ #category : #rules }
RCCobolXForm >> removeOneMandatoryIn: aCollection of: allRules [
	"tackle the case of nearly duplicate rules:
	 one rule has a nonterminal with mandatory=false
	 and another does not have this attrubute"
	
	1 to: aCollection size - 1 do: [ :index | 
		| ref cand |
		ref := aCollection at: index.
		cand := aCollection at: index + 1.
		ref approximateRepresentation = cand approximateRepresentation
			ifTrue: [ | refmand candmand refsize candsize |
				refmand := ref nodesNoString select: [ :sub |
					sub includesAttribute: 'mandatory' ].
				candmand := cand nodesNoString select: [ :sub |
					sub includesAttribute: 'mandatory' ].
				refsize := refmand size.
				candsize := candmand size.
				
				refsize = candsize ifFalse: [
					(refsize - candsize) abs = 1 ifTrue:[
						refsize > candsize
							ifTrue: [ allRules remove: cand. ]
							ifFalse: [ allRules remove: ref. ].
						^self
						]
					]
			]
	]

]

{ #category : #transforming }
RCCobolXForm >> renameRelationsFor: root [
	| renaming keys |
	"Rename the relations inside rules e.g. 'TheArgs' -> 'TheArg' "
	renaming := RCXMLGenerator relationsRenameList.
	keys := renaming keys.
	
	root nodesNoString do: [:node |
		node nodesNoString do: [:sub| |name|
			name := sub name.
			(keys includes: name) ifTrue: [sub name: (renaming at: name)]
			]]
]

{ #category : #rules }
RCCobolXForm >> splitRuleForList: anXMLNode [
	"I split a rule in 2 when there is a list inside
	the list is transformed into a an adhoc rule that is referenced
	return true if I really split"
	| lists split |
	
	split := false.
	
	"get all list nodes"
	lists := anXMLNode nodes select: [:node | node isListNode  ]. 
	
	"check relevant nodes. ignore if there are none or 1, unless the 1 is an OR
	 this because that list will be inlined later"
	lists := lists select: [:node | | sub |
		sub := node relevantNodes.
		sub size = 0
			ifTrue: [false]
			ifFalse: [ sub size > 1
				ifTrue: [true]
				ifFalse: [ sub first isOrNode ]]
		].
	
	lists do: [:listNode | | adhoc ref idx nodes |
		adhoc := self addAdhocRuleFor: listNode ofRule: anXMLNode.
		ref := XMLElement named: 'Adhoc_', adhoc name.
		listNode pushListAttribsDownTo: ref.
		ref attributeAt: 'ordered-nodelist' put: adhoc name.
		nodes := anXMLNode nodes.
		idx := nodes identityIndexOf: listNode.
		nodes at: idx put: ref.
		split := true.
		].
	
	^split.
]

{ #category : #rules }
RCCobolXForm >> splitRuleForOpt: anXMLNode [
	"split a rule in different rules if there is an OPT"
	"return true if I really split"
	| nodes split |
	
	"try to transform OPT nodes in place"
	self transformOptIn: anXMLNode. 

	nodes := anXMLNode nodes.

	split := false.	
	nodes
		select: [ :node | node isOptNode ]
		thenDo: [ :optNode | | adhoc ref idx |
		adhoc := self addAdhocRuleFor: optNode ofRule: anXMLNode. 
		ref := XMLElement named: 'Adhoc_', adhoc name.
		ref attributeAt: 'node' put: adhoc name.
		ref attributeAt: 'mandatory' put: 'false'.
		idx := nodes identityIndexOf: optNode.
		nodes at: idx put: ref.
		split := true.
		].

	^split.
]

{ #category : #rules }
RCCobolXForm >> splitRuleForOr: anXMLNode [
	"split a rule in different rules if there is an OR"
	"return true if I really split"
	| nodes ortag disjuncts parent index parentindex |

	"first try to convert the or to an optional"
	(anXMLNode nodes
		select: [:node | node isOrNode and: [node relevantNodes size = 3 ]])
		do: [:node | anXMLNode orToOptional: node].

	nodes := anXMLNode nodes.
	ortag := 	nodes detect: [ :node | node isOrNode ] ifNone: [ ^false ].
	
	index := nodes identityIndexOf: ortag.
	parent := anXMLNode parent.
	parentindex := parent nodes identityIndexOf: anXMLNode.
	
	disjuncts := ortag nodes splitOn: 'SEP'.
	disjuncts size < 2 ifTrue: [ Error signal: 'OR with less than 2 options' ].

	(disjuncts copyFrom: 2 to: disjuncts size) do: [:dj | | copy |
		copy := anXMLNode copy.
		copy nodes insertNodes: dj replacing: index.
		parent nodes add: copy afterIndex: parentindex.
		parent nodes add: (XMLString string: '\' withCRs ) afterIndex: parentindex
	].

	nodes insertNodes: disjuncts first replacing: index.

	^true 

]

{ #category : #transforming }
RCCobolXForm >> transformFileNamed: aFileName [
	| xml root name |

	xml := self parse: aFileName.
	
	root := xml root.

	"Remove all CICS and Idms rules"
	root nodesNoString do: [ :node |
		((node name beginsWith: 'Cics') or: [node name beginsWith: 'Idms'])
			ifTrue: [ root nodes remove: node]].

	self insertKeywordNodesIn: root.
	self transformOr2: root.

	self expansivelyTransform: root.
	
	"add abstract tag where needed"
	root nodesNoString do: [ :node |
		node isAbstract ifTrue: [ node attributeAt: 'abstract' put: 'true'.]].

	spuriousRules := OrderedCollection new.	
	root nodesNoString do: [ :node |
		((node attributeAt: 'abstract') = 'true') ifFalse:[
				self transformRule: node]].
	spuriousRules do: [ :node | root removeNode: node ].

	self removeEmptyRulesFrom: root.
	
	self removeDuplicateRulesFrom: root.
	
	self manualCheckRules: root.	

	self renameRelationsFor: root.

	name := aFileName copyFrom: 1 to: (aFileName size ) - 7. 
	xml printToFileNamed: name , '-postgen.xml'
	
]

{ #category : #transforming }
RCCobolXForm >> transformOptIn: anXMLNode [
	| opts |
	
	"try to transform OPT nodes in place, recursing down nested OPTs"
	
	anXMLNode isAbstract ifFalse:[
		opts := anXMLNode nodes select: [:node | node isOptNode ].

		"filter out nested OPT nodes if possible"
		opts do: [:opt | self transformOptIn: opt ].

		self filterStringNodesFrom: anXMLNode.
		
		"try to pull up the opt's"
		opts do: [:opt | anXMLNode pullUpOpt: opt]].

]

{ #category : #transforming }
RCCobolXForm >> transformOr2: root. [

	root nodesNoString do: [:node | | els |
		els := node allElements asOrderedCollection.
		els do: [ :sub |
			sub isOr2Node ifTrue: [ | orsub |
				orsub := sub nodes.
				orsub size > 1 ifTrue: [ Error signal: 'Unexpected OR2 entry.'].
				orsub size = 0 ifFalse: [ sub parent nodes add: sub nodes first after: sub].
				sub parent removeNode: sub ].
		]
	]

]

{ #category : #transforming }
RCCobolXForm >> transformRule: anXMLNode [

	"filter out top level keywords and newlines/spaces"
	self filterStringNodesFrom: anXMLNode.

	"filter out empty OPTs of keywords"
	self transformOptIn: anXMLNode.
	
	"filter out lists of nothing because their contents are keywords"
	(anXMLNode nodes 
		select: [:node | node isListNode and: [ node relevantNodes isEmpty  ] ])
		do: [:node | anXMLNode removeNode: node ].
	
	"pull up <LIST>s with one child"
	(anXMLNode nodes
		select: [:node | node isListNode and: [
								node relevantNodes size = 1 and: [
									node isGrandparent not ]]])
		do: [:node | 
	"				anXMLNode name = 'AddStatement' ifTrue: [ self halt ]."
			anXMLNode pullUpList: node].
		
	"if I end up being empty, and nodes like me have been seen before, signal me for removal later"
	(rulesSeen includes: anXMLNode name)
		ifTrue: [ anXMLNode isChildLess ifTrue: [spuriousRules add: anXMLNode]]
		ifFalse: [rulesSeen add: anXMLNode name].

		
]
