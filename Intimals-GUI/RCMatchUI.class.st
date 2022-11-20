"
I am a UI for a source code match.

I present source code as a match and the complete source code in 2 different tabs
"
Class {
	#name : #RCMatchUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'tabs',
		'match',
		'source'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCMatchUI class >> defaultSpec [

	^ SpecLayout composed add: #tabs ; yourself
]

{ #category : #api }
RCMatchUI >> addHighlightFrom: start to: stop color: aColor [ 
	^match addHighlightFrom: start to: stop color: aColor 
]

{ #category : #api }
RCMatchUI >> fragment: aString [ 
	^ match show: aString
]

{ #category : #initialization }
RCMatchUI >> initializeWidgets [
	| tab |

	match := RCIntSourceView on: 'Select a pattern to start.'.
	source := RCIntSourceView on: 'Select a pattern to start.'.

	tabs := self newTabManager.
	tab := self newTab label: 'Match'; closeable: false.
	tab presenter: match.
	tabs addTab: tab.
	
	tab := self newTab label: 'Source'; closeable: false.
	tab presenter: source.
	tabs addTab: tab.
	
]

{ #category : #api }
RCMatchUI >> source: aString [ 
	^ source show: aString
]

{ #category : #accessing }
RCMatchUI >> tabs [
	^ tabs
]

{ #category : #accessing }
RCMatchUI >> tabs: anObject [
	tabs := anObject
]
