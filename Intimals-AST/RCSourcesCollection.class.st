"
I am a collection of strings of source code that belong to an XML Element. I exist as a singleton because it's not possible to add the source code as instance variable to the XML node without even uglier hacks.

RCSourcesCollection resetGlobal

RCSourcesCollection global
"
Class {
	#name : #RCSourcesCollection,
	#superclass : #Object,
	#instVars : [
		'sources',
		'fullsources'
	],
	#classVars : [
		'global'
	],
	#category : #'Intimals-AST'
}

{ #category : #accessing }
RCSourcesCollection class >> global [
	global isNil ifTrue: [^self resetGlobal].
	^global
]

{ #category : #accessing }
RCSourcesCollection class >> resetGlobal [
	global := self new.
	^global
]

{ #category : #accessing }
RCSourcesCollection >> fragmentAt: anXMLElement [
	^sources at: anXMLElement ifAbsentPut: [anXMLElement readSourceFragment]
]

{ #category : #initialization }
RCSourcesCollection >> initialize [
	sources := Dictionary new.
	fullsources := Dictionary new.
]

{ #category : #accessing }
RCSourcesCollection >> sourcesAt: anXMLElement [
	^fullsources at: anXMLElement ifAbsentPut: [anXMLElement readFullSource]
]
