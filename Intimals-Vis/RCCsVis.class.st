"
I am a visualisation for C# code, exported as XML compliant to the metamodel. I show a system complexity style view and a derivative that also shows some method information.

I am a bit of a hack and my author apologises for my uglyness

See my class side on how to use me.
"
Class {
	#name : #RCCsVis,
	#superclass : #Object,
	#instVars : [
		'xmls',
		'classesDict'
	],
	#category : #'Intimals-Vis'
}

{ #category : #'instance creation' }
RCCsVis class >> collectFilesOf: aDirectoryRef in: aCollection [
	| names |
	
	names := aDirectoryRef entries collect: [:entry | entry fullName].
		
	aCollection addAll:
		(names select: [ :nam | nam endsWith: '.cs.xml']).

	(aDirectoryRef entries select: [:entry | entry isDirectory])
		do: [:dir| self collectFilesOf: dir reference in: aCollection].
	
]

{ #category : #'instance creation' }
RCCsVis class >> visDir: aDirectoryName [
	"vis the relations between C# classes"
	| inst names |
	
	names := OrderedCollection new.
	self collectFilesOf: aDirectoryName asFileReference in: names.

	inst := self new.
	inst xmls: (names collect: [:nam | (XMLDOMParser parseFileNamed: nam)]).
	^inst	
]

{ #category : #accessing }
RCCsVis >> classes [
	classesDict isNil ifTrue: [ self initializeClassesDict ].
	^classesDict value.
]

{ #category : #utility }
RCCsVis >> colorOf: aName [
	| meths over |
	(aName includesSubstring: 'Generated') ifTrue: [ ^Color green ]. 
	meths := (self methodsOf: aName) size.
	meths = 0 ifTrue: [^Color red].
	over := (self overrideMethodsOf: aName) size.
	^Color grayScale256: (1-(over/meths))*256.
]

{ #category : #'inspector extensions' }
RCCsVis >> gtInspectorMethodPreviewIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite roassal2
		title: 'Method relations';
		initializeView: [ RTMondrian new ];
		painting: [:view |
			view shape rectangle
				color: [:node| self colorOf: node];
				borderColor: Color black.
			view nodes: (self classes keys)
				forEach: [:node |
					view shape rectangle
						color: Color white;
						borderColor: [:meth | (self isOverride: meth) ifTrue: [ Color red ] ifFalse: [Color black]];
						size: [:meth | self sizeOfXMLNode: meth].
					view interaction addExclusiveInteraction:
						(RTPopup new text: [:meth | self signatureOfMethod: meth];
							backgroundColor: Color white;
							alphaPopupBackground: 1).
					view nodes: (self methodsOf: node).
					view layout grid].
			view interaction addExclusiveInteraction:
						(RTPopup new text: [:cls | cls];
							backgroundColor: Color white;
							alphaPopupBackground: 1).
			view edges connectFrom: [:node | self superclassOf: node ].
			view layout tree.
			view build ].
]

{ #category : #'inspector extensions' }
RCCsVis >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: -2>
	
	^composite roassal2
		title: 'System Complexity';
		initializeView: [ RTMondrian new ];
		painting: [:view |
			view shape rectangle
				height: [:node | self sizeOf: node ];
				width: [:node | (self varsOf: node) size];
				color: [:node | self colorOf: node];
				borderColor: Color black.
			view nodes: self classes keys.
			view edges connectFrom: [:node | self superclassOf: node ].
			view layout tree.
			view build ].
]

{ #category : #utility }
RCCsVis >> identifierOf: anXML [
	^(anXML descendantNodesSelect: [:node|
			node isStringNode not and: [
				node name = 'Identifier' ]])
	 	first
]

{ #category : #'initalize-release' }
RCCsVis >> initializeClassesDict [

	classesDict := Dictionary new.

	xmls do: [:xml | |classes|
		classes := xml root allNodesSelect: [:node | node isStringNode not and: [node name = 'Class']].
		classes do: [:class | |idNode|
			idNode := (class nodesNoString select: [:node | node name = 'Identifier']) first.
			classesDict at: idNode nodes first asString trim put: class]].
]

{ #category : #utility }
RCCsVis >> isOverride: aMethodXML [
	^aMethodXML nodesNoString anySatisfy: [:sub | sub name = 'Overrides' ].
]

{ #category : #utility }
RCCsVis >> methodsOf: aClassName [
	| xml |
	
	xml := classesDict at: aClassName.
	^xml descendantNodesSelect:	[:node| node isStringNode not and: [node name = 'Method']]
]

{ #category : #utility }
RCCsVis >> overrideMethodsOf: aClassName [
	| xml |
	
	xml := classesDict at: aClassName.
	^xml descendantNodesSelect: [:node|
		(node isStringNode not) and: [
			(node name = 'Method') and: [
				self isOverride: node]]].
]

{ #category : #utility }
RCCsVis >> signatureOfMethod: aMethodXML [
	^(self identifierOf: aMethodXML) nodes first asString trim
]

{ #category : #utility }
RCCsVis >> sizeOf: aClassName [

	^self sizeOfXMLNode: (classesDict at: aClassName).
]

{ #category : #utility }
RCCsVis >> sizeOfXMLNode: anXML [
	
	^((anXML attributeAt:'EndLineNr')asNumber - (anXML attributeAt:'LineNr')asNumber)/10
]

{ #category : #utility }
RCCsVis >> superclassOf: aClassName [
	| xml parents ident |
	
	xml := classesDict at: aClassName.
	parents := xml nodesNoString select: [:node| node name = 'Parent'].
	parents ifEmpty: [ ^nil].
	ident := self identifierOf: parents first.
	^ident nodes first asString trim.

]

{ #category : #utility }
RCCsVis >> varsOf: aClassName [
	| xml |
	
	xml := classesDict at: aClassName.
	^xml descendantNodesSelect:	[:node| node isStringNode not and: [node name = 'Field']]
]

{ #category : #accessing }
RCCsVis >> xmls [
	^ xmls
]

{ #category : #accessing }
RCCsVis >> xmls: anObject [
	xmls := anObject
]
