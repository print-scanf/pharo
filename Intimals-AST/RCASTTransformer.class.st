"
This visitor destructively transforms  a filtered Raincode AST XML dump, to an XML that is better suited for mining
"
Class {
	#name : #RCASTTransformer,
	#superclass : #XMLNodeVisitor,
	#instVars : [
		'counter'
	],
	#category : #'Intimals-AST'
}

{ #category : #transforming }
RCASTTransformer >> addRestructuredNodes: coll to: aRCASTNode [
	| first last |

	first := nil.

	"heterogeneous collections should be added as-is"
	(self isHetero: coll) ifTrue: [ 
		 aRCASTNode nodes addAll: coll.
		^self].
	
	"if all to be added are string nodes, we should do nothing"
	(coll reject: [ :node | node isStringNode ]) ifEmpty: [^self].
	
	" set the first and last to real nodes, not ignorable strings "
	coll do: [:node |
			node isIgnorable ifFalse: [
				first ifNil: [first := node ].
				last := node.]].

	"actually there is only one content node. Add all to preserve layout"
	first = last ifTrue: [
		aRCASTNode nodes addAll: coll.
		^self].

	"merge the different nodes' content"
	coll do: [ :node |	(node = first) ifFalse: [
			node isStringNode
				ifTrue: [ first addNode: node ] 
				ifFalse: [first addNode: (node nodes first)]]].
	
	first attributeAt: 'EndLineNr' put: (last attributeAt: 'EndLineNr'). 
	first attributeAt: 'EndColNr' put: (last attributeAt: 'EndColNr').
	
	aRCASTNode nodes add: first. 
]

{ #category : #transforming }
RCASTTransformer >> buildHierarchyIn: aRCASTNode [
	"This node is a DataDecl node"
	| idDict levelDict |
	
	idDict := Dictionary new.
	levelDict := Dictionary new.
	
	aRCASTNode elementsDo: [ :elt | | level |
		level := (elt attributeAt: 'Level') asNumber.
		level > 1 ifTrue: [
			(levelDict at: level ifAbsentPut: [OrderedCollection new])
				add: elt ].
		idDict at: (elt attributeAt: 'ID') put: elt.].
		
	levelDict keys asSortedCollection reverse do: [ :key |
		(levelDict at: key) do: [ :elt | |parent linenr |
			parent := idDict at: (elt attributeAt: 'ParentLevel' ifAbsent: [-1]) ifAbsent: [nil].
			parent isNil ifFalse: [ "Level 77 (e.g.) has no parent"
				linenr := (parent attributeAt: 'EndLineNr' ifAbsent: [1]) asNumber.
				parent addNode: elt.
				parent attributeAt: 'EndLineNr' put:
					(linenr max: (elt attributeAt: 'EndLineNr' ifAbsent: [1]) asNumber) asString. ]]
		 ]
]

{ #category : #accessing }
RCASTTransformer >> counter [
	^ counter
]

{ #category : #transforming }
RCASTTransformer >> filterConfigurationSection: aRCAstNode [
	| procID |
	"Configuration section can have duplicate nodes.
	See RC Online bugreport 1149869714"

	procID := OrderedCollection new.	

	aRCAstNode nodesNoString do: [:node | | id |
		id := node attributeAt: 'ID' ifAbsent: [ Exception signal: 'AST node missing an ID' ].
		(procID includes: id)
			ifTrue: [ aRCAstNode removeNode: node ]
			ifFalse: [ procID add: id ] 		 
		].		

]

{ #category : #transforming }
RCASTTransformer >> inheritMissingAttribute: aString node: aRCASTNode [

	(aRCASTNode includesAttribute: aString) ifFalse: [
		aRCASTNode attributeAt: aString
						put: (aRCASTNode parent attributeAt: aString ifAbsent: ['1']) ]
]

{ #category : #testing }
RCASTTransformer >> isHetero: aCollection [
	"do the xml nonstring nodes of this collection have different names?"
	| firstname |
	
	firstname := nil.
	
	aCollection
		reject: [ :node | node isStringNode ]
		thenDo: [ :node | 
			firstname isNil
				ifTrue: [ firstname := node name ]
				ifFalse: [ (firstname = node name) ifFalse: [^true]]
			].
		
	^false.
]

{ #category : #transforming }
RCASTTransformer >> joinDisparateChildrenOf: aRCASTNode [
	| nodes dict |
	"lists that should be
	<TheXXs><XXELEM></XXELEM><XXELEM></XXELEM>...</TheXXs>
	are actually exported as
	<TheXXs><XXELEM></XXELEM></TheXXs><TheXXs><XXELEM></XXELEM></TheXXs>...
	"
	
	"only look if aRCASTNode corresponds to a rule"
	((aRCASTNode attributeAt: 'ID') first = $-) ifTrue:[^self].
	
	nodes := aRCASTNode nodesNoString asOrderedCollection.		
	nodes size < 2 ifTrue: [^self].
	
	dict := Dictionary new.
	nodes do: [:node |
		(dict at: node name ifAbsentPut: [OrderedCollection new]) add: node].
	
	dict values do: [:coll | | sorted |
		coll size > 1 ifTrue: [ | first last | 
			sorted := coll sort: [ :left :right |
					(((left attributeAt: 'LineNr') asNumber)
					 + ((left attributeAt: 'ColNr') asNumber / 1000)) <
					(((right attributeAt: 'LineNr') asNumber)
					+ ((right attributeAt: 'ColNr') asNumber / 1000))].
			first := sorted first.
			last := sorted last.
			first attributeAt: 'EndLineNr' put: (last attributeAt: 'EndLineNr'). 
			first attributeAt: 'EndColNr' put: (last attributeAt: 'EndColNr').
			(sorted copyFrom: 2 to: sorted size) do: [:dup |
				dup nodes do: [:sub | first addNode: sub ].
				aRCASTNode removeNode: dup]
			]
		]
		
]

{ #category : #transforming }
RCASTTransformer >> restructureNode: aRCASTNode [
	 | name newnode rrl newname |
	
	name := aRCASTNode name.
	
	(aRCASTNode includesAttribute: 'xsi:type')
		ifTrue: [
			aRCASTNode name: (aRCASTNode attributeAt: 'xsi:type').
			aRCASTNode removeAttribute: 'xsi:type'.
			
			rrl := RCXMLGenerator relationsRenameList.
			newname := (rrl keys includes: name)
							ifTrue: [ rrl at: name ]
							ifFalse: [ name ].
			
			newnode := XMLElement name: newname attributes: aRCASTNode attributes.
			newnode attributeAt: 'ID' put: '-',(newnode attributeAt: 'ID').
			newnode addNode: aRCASTNode.
	
			^newnode].
	
	^nil
]

{ #category : #transforming }
RCASTTransformer >> restructureProcedureDivision: aPCDNode [
	| currentsec csblocks|
	
	aPCDNode nodesNoString do:[:node |
		(node attributeAt: 'xsi:type') = 'SectionStatementBlock'
			ifTrue:[
				currentsec := node.
				csblocks := XMLElement named: 'TheBlocks'.
				]
			ifFalse:[ 
				(((node attributeAt: 'xsi:type') = 'ParagraphStatementBlock')
					and: [ currentsec isNotNil ])
					ifTrue: [	currentsec addNode: node. ]]
		].
]

{ #category : #visiting }
RCASTTransformer >> visitDocument: aDocument [
	| calc root cp tp |
	" get the highest ID of the tree"
	calc := RCTreeCalculator new.
	calc result: 0.
	calc calcBlock: [:node |
		calc result max:
			(Integer readFrom: (node attributeAt: 'ID' ifAbsent: ['0']))
		].
	counter := (aDocument acceptNodeVisitor: calc) + 1.

	aDocument root acceptNodeVisitor: self.	

	root := aDocument root nodesNoString first.
	cp  := root nodesNoString first.

	tp := XMLElement named: 'ThePrograms'.	
	tp attributeAt: 'ID' put: counter asString.
	counter := counter + 1.
	tp attributeAt: 'LineNr' put: (cp attributeAt: 'LineNr').
	tp attributeAt: 'EndLineNr' put: (cp attributeAt: 'EndLineNr').
	tp attributeAt: 'ColNr' put: (cp attributeAt: 'ColLineNr').
	tp attributeAt: 'EndColNr' put: (cp attributeAt: 'EndColNr').

	root nodes add: tp.
	tp nodes add: cp.

	^aDocument
]

{ #category : #visiting }
RCASTTransformer >> visitNodeWithElements: aRCASTNode [
	| recursed |
	
 	((aRCASTNode name beginsWith: 'Cics') or: [ aRCASTNode name beginsWith: 'Idms'])
		ifTrue: [
			aRCASTNode parent removeNode: aRCASTNode.
			^nil ].
	
	aRCASTNode isImage ifTrue: [ aRCASTNode name: 'TheValue' ].
	
	(aRCASTNode name = 'TheProcedureDivision') ifTrue: [ 
		self restructureProcedureDivision: aRCASTNode ].
	
	(aRCASTNode includesAttribute: 'ID') ifFalse: [
		aRCASTNode attributeAt: 'ID' put: counter asString.
		counter := counter + 1].

	aRCASTNode isRoot ifFalse: [ 
		self inheritMissingAttribute: 'LineNr' node: aRCASTNode.
		self inheritMissingAttribute: 'EndLineNr' node: aRCASTNode.
		self inheritMissingAttribute: 'ColNr' node: aRCASTNode.
		self inheritMissingAttribute: 'EndColNr' node: aRCASTNode ].
	
	recursed := (aRCASTNode nodes asOrderedCollection
			collect: [:node | node acceptNodeVisitor: self ]
			thenReject: [:node | node isNil]).
	
	self addRestructuredNodes: recursed to: aRCASTNode.

	self joinDisparateChildrenOf: aRCASTNode. 

	(aRCASTNode name = 'DataDecl')
		ifTrue: [self buildHierarchyIn: aRCASTNode. ^aRCASTNode ].
	(aRCASTNode name = 'ConfigurationSection')
		ifTrue: [ self filterConfigurationSection: aRCASTNode. ^aRCASTNode ].
	(aRCASTNode name = 'SourceFile')
		ifFalse: [^self restructureNode: aRCASTNode. ].

	^aRCASTNode

]
