"
I am a UI for a source code match when browsing histories.

I present source code as a match and the complete source code of old and new in 3 different tabs
"
Class {
	#name : #RCHistoryMatchUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'tabs',
		'match',
		'oldSource',
		'newSource'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCHistoryMatchUI class >> defaultSpec [

	^ SpecLayout composed add: #tabs ; yourself
]

{ #category : #api }
RCHistoryMatchUI >> addHighlightFrom: start to: stop color: aColor [ 
	^match addHighlightFrom: start to: stop color: aColor 
]

{ #category : #api }
RCHistoryMatchUI >> fragment: aString [ 
	^ match show: aString
]

{ #category : #initialization }
RCHistoryMatchUI >> initializeWidgets [
	| tab |

	match := RCIntSourceView on: 'Select a pattern to start.'.
	oldSource := RCIntSourceView on: 'Select a pattern to start.'.
	newSource := RCIntSourceView on: 'Select a pattern to start.'.

	tabs := self newTabManager.
	tab := self newTab label: 'Match'; closeable: false.
	tab presenter: match.
	tabs addTab: tab.
	
	tab := self newTab label: 'Old source'; closeable: false.
	tab presenter: oldSource.
	tabs addTab: tab.
	
	tab := self newTab label: 'New source'; closeable: false.
	tab presenter: newSource.
	tabs addTab: tab.
]

{ #category : #api }
RCHistoryMatchUI >> newSource: aString [ 
	^ newSource show: aString
]

{ #category : #api }
RCHistoryMatchUI >> oldSource: aString [ 
	^ oldSource show: aString
]

{ #category : #accessing }
RCHistoryMatchUI >> tabs [
	^ tabs
]

{ #category : #accessing }
RCHistoryMatchUI >> tabs: anObject [
	tabs := anObject
]
