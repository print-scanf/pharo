"
I am a ui for history pattern browsing: I show tabs with old and new patterns
"
Class {
	#name : #RCHistoryPatternUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'oldpatterns',
		'newpatterns',
		'tabs',
		'listener'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCHistoryPatternUI class >> defaultSpec [

	^ SpecLayout composed add: #tabs ; yourself
]

{ #category : #utility }
RCHistoryPatternUI >> bestMatch: aPathNameString in: aPathNameCollection [ 
	| rev best count fname bestname index |
	
	aPathNameCollection isEmpty ifTrue: [ ^nil ].
	
	count := 0.
	rev := aPathNameString reversed.
	aPathNameCollection do:[:name| | tmpCount |
		tmpCount := rev howManyMatch: name reversed.
		tmpCount > count ifTrue:[
			count := tmpCount.
			best := name.
			]
		].
	
	"FileSystem disk separator seems not to work on MacOS so we search for the last / and \"
	"plus we do max: 1 just to be sure that we don't crash"
	index := ((aPathNameString lastIndexOf: $\) max: (aPathNameString lastIndexOf: $/)) max: 1.
	fname :=  aPathNameString copyFrom: index to: aPathNameString size.

	index := ((best lastIndexOf: $\) max:  (best lastIndexOf: $/)) max: 1.
	bestname := best copyFrom: index to: best size.
	
	fname = bestname ifTrue: [ ^best ].
	"filenames are different so no match was actually found"
	^nil	

]

{ #category : #api }
RCHistoryPatternUI >> collapseAll [
	oldpatterns collapseAll.
	newpatterns collapseAll.
]

{ #category : #initialization }
RCHistoryPatternUI >> initializeWidgets [
	| tab |
	
	oldpatterns := self instantiate: RCPatternUI.
	oldpatterns listener: self.
	newpatterns := self instantiate: RCPatternUI.
	newpatterns listener: self.
	
	tabs := self newTabManager.
	tab := self newTab.
	tab label: 'Matches in Old'; closeable: false.
	tab presenter: oldpatterns.
	tabs addTab: tab.
	
	tab := self newTab.
	tab label: 'Matches in New'; closeable: false.
	tab presenter: newpatterns.
	tabs addTab: tab.
]

{ #category : #accessing }
RCHistoryPatternUI >> listener: aListener [ 
	listener := aListener
]

{ #category : #'api-events' }
RCHistoryPatternUI >> matchSelected: aTNP [ 
	| matchfile |
	
	(aTNP container owner = oldpatterns)
		ifTrue: [
			matchfile := self bestMatch: aTNP content sourcePath in: newpatterns matchFileNames.
			listener oldMatchSelected: aTNP content withEquivalentFile: matchfile]
		ifFalse: [
			matchfile := self bestMatch: aTNP content sourcePath in: oldpatterns matchFileNames.
			listener newMatchSelected: aTNP content withEquivalentFile: matchfile
			].

]

{ #category : #accessing }
RCHistoryPatternUI >> newpatterns [
	^ newpatterns
]

{ #category : #accessing }
RCHistoryPatternUI >> newpatterns: anObject [
	newpatterns := anObject
]

{ #category : #api }
RCHistoryPatternUI >> oldPattern: old newPattern: new [

	oldpatterns pattern: old.
	newpatterns pattern: new.
]

{ #category : #accessing }
RCHistoryPatternUI >> oldpatterns [
	^ oldpatterns
]

{ #category : #accessing }
RCHistoryPatternUI >> oldpatterns: anObject [
	oldpatterns := anObject
]

{ #category : #api }
RCHistoryPatternUI >> resetRoots [
	oldpatterns resetRoots.
	newpatterns resetRoots.
]

{ #category : #accessing }
RCHistoryPatternUI >> tabs [
	^ tabs
]

{ #category : #accessing }
RCHistoryPatternUI >> tabs: anObject [
	tabs := anObject
]
