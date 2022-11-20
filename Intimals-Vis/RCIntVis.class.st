"
I am a visualization of Intimals metamodel AST's.

I need Roassal2 to be loaded, e.g. from the catalog browser.

See my class side for how to use me.
"
Class {
	#name : #RCIntVis,
	#superclass : #Object,
	#category : #'Intimals-Vis'
}

{ #category : #'instance creation' }
RCIntVis class >> visDir: aDirectoryName [
	"do a small multiples visualization on a directory"
	| names composer |
	
	names := aDirectoryName asFileReference entries
		collect: [:entry | entry fullName].

	names := names select: [ :nam | nam endsWith: '.trs.xml'].
	
	composer := RTComposer new.
	
	names do: [:nam | | root |
			root := (XMLDOMParser parseFileNamed: nam) nodes first nodes second.
			self new visOf: root onView: composer view.
			composer group: (nam copyFrom: nam size - 10 to: nam size). 
		 ].
	
	composer layout: RTCellLayout new centered.
	
	^ composer view
	
]

{ #category : #building }
RCIntVis >> popupTextFor: anXMLElement [
	
	^anXMLElement isUnaryTree
	 ifTrue: [ | children |
		children := anXMLElement nodesNoString.
		children isEmpty
			ifTrue: [ '`' , anXMLElement nodes first asString , '`']
			ifFalse: [ anXMLElement name , ': ', (self popupTextFor: children first) ]]
	 ifFalse: [ anXMLElement name ]
]

{ #category : #building }
RCIntVis >> visNodesOf: anXML [
	| nodes |
	
	nodes := anXML allElements reject: [:elt | elt isStringNode].
	
	"No unary trees without siblings (ingnoring StringNode)"
	nodes := nodes reject: [:n |
		n isUnaryTree and: [
			(n parent nodes reject: [:sib | sib isStringNode]) size = 1 ]].

	^nodes
]

{ #category : #building }
RCIntVis >> visOf: anXML onView: view [
	" !! Returns the highlighting interaction !!"
	| shape elements xmlNodes popup trans |

	xmlNodes := self visNodesOf: anXML.
	shape := RTEllipse new color: Color black trans; size: 30.	
	elements := shape elementsOn: xmlNodes.
	view addAll: elements.

	popup := RTPopup text: [:elt | self popupTextFor: elt ].
	popup backgroundColor: Color white.
	popup borderColor: Color lightGray.
	popup alphaPopupBackground: 1.
	elements @ popup.

	RTEdgeBuilder new
		view: view;
		objects: xmlNodes;
		moveBehind;
		connectToAll: [ :elt | elt elements ].
	
	trans := RTTransitivelyHighlightable new
		focusOnOutgoingElements;
		color: Color red;
		edgeColor: Color black.
	
	elements @ trans.

	"RTHorizontalTreeLayout"
	"RTRadialTreeLayout"
	RTForceBasedLayout on: elements edges: view edges.
	view @ RTDraggableView.
	^trans
]
