"
I am the metadata for a RC pattern, to be edited by my UI.
"
Class {
	#name : #RCPatternMetadata,
	#superclass : #Object,
	#instVars : [
		'tags',
		'utility',
		'text',
		'quality'
	],
	#category : #'Intimals-AST'
}

{ #category : #acccessing }
RCPatternMetadata class >> tagCategories [
	^{ 
	'Constructor' .
	'Delegating' .
	'Loop' .
	'Getter/Setter' .
	'Structure' .
	
	'Paired def' .
	'Var dec' .
	'Other' .
	'Misc 1' . 
	'Misc 2'
	}
]

{ #category : #acccessing }
RCPatternMetadata class >> utilityCategories [
	^{ 
	'Recom. structure' .
	'Coding Practice' .
	'Usage Protocol' .
	'Uninteresting' .
	'Misc'
	}
]

{ #category : #exporting }
RCPatternMetadata >> exportTo: aWriteStream [
	| accum |

	accum := OrderedCollection new.
	tags doWithIndex: [ :el :idx | el ifTrue: [ accum add: (self class tagCategories at: idx) ]].

	aWriteStream nextPutAll: '- Tag: '.
	accum do: [:el | aWriteStream nextPutAll: el ] separatedBy: [ aWriteStream nextPutAll: ' + ' ].
	aWriteStream nextPut: Character cr.
	
	accum := OrderedCollection new.
	utility doWithIndex: [ :el :idx | el ifTrue: [ accum add: (self class utilityCategories at: idx) ]].

	aWriteStream nextPutAll: '- Utility: '.
	accum do: [:el | aWriteStream nextPutAll: el ] separatedBy: [ aWriteStream nextPutAll: ' + ' ].	
	aWriteStream nextPut: Character cr.

	aWriteStream nextPutAll: '- Relevance: '.
	aWriteStream nextPutAll: quality asString.
	aWriteStream nextPut: Character cr.
	
	aWriteStream nextPutAll: '- Comment: '.
	aWriteStream nextPutAll: text asString.
	aWriteStream nextPut: Character cr.
]

{ #category : #initialization }
RCPatternMetadata >> initialize [
	tags := Array new: 10 withAll: false.
	utility := Array new: 5 withAll: false.
	text := ''.
	quality := 0.
	
]

{ #category : #accessing }
RCPatternMetadata >> quality [
	^ quality
]

{ #category : #accessing }
RCPatternMetadata >> quality: anObject [
	quality := anObject
]

{ #category : #accessing }
RCPatternMetadata >> tagCheck: aNum [
	tags at: aNum put: true
]

{ #category : #accessing }
RCPatternMetadata >> tagUnCheck: aNum [
	tags at: aNum put: false
]

{ #category : #accessing }
RCPatternMetadata >> text: anObject [
	text := anObject
]

{ #category : #accessing }
RCPatternMetadata >> utilCheck: aNum [
	utility at: aNum put: true
]

{ #category : #accessing }
RCPatternMetadata >> utilUnCheck: aNum [
	utility at: aNum put: false
]
