"
I am a collection of ASTs that have been exported in xml format (supposedly in the Intimals metamodel format.)

self resetGlobal
"
Class {
	#name : #RCASTCollection,
	#superclass : #Object,
	#instVars : [
		'asts'
	],
	#classVars : [
		'global'
	],
	#category : #'Intimals-AST'
}

{ #category : #accessing }
RCASTCollection class >> global [
	global isNil ifTrue: [ ^self resetGlobal ].
	^global
]

{ #category : #accessing }
RCASTCollection class >> resetGlobal [
	global := self new.
	^global
]

{ #category : #accessing }
RCASTCollection >> fetchASTAt: fileName [
	^asts
		at: fileName
		ifAbsentPut: [ | domparser |
			domparser := XMLDOMParser onFileNamed: fileName.
			domparser optimizeForLargeDocuments.
			domparser parseDocument. ]
]

{ #category : #initialization }
RCASTCollection >> initialize [
	asts := Dictionary new.
]
