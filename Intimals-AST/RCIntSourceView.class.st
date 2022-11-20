"
I am a visualization of source code (text) using a RubScrolledTextMorph. I allow all kinds of highlighting on different regions of the text.

My reason for existence is to be embedded in a Glamourous pane like e.g. the inspector because the Glamourous source code view is too basic. 
"
Class {
	#name : #RCIntSourceView,
	#superclass : #ComposablePresenter,
	#instVars : [
		'morph',
		'rubric',
		'tabs'
	],
	#category : #'Intimals-AST'
}

{ #category : #specs }
RCIntSourceView class >> defaultSpec [
	^SpecLayout composed add: #morph; yourself.
	
]

{ #category : #'instance creation' }
RCIntSourceView class >> on: aString [
	| inst | 
	
	inst := self new.
	inst show: aString.
	^inst. 
]

{ #category : #'instance creation' }
RCIntSourceView class >> onFileName: aFileName [
	| inst | 
	
	inst := self new.
	inst show: (aFileName asFileReference contents asText).
	^inst. 
]

{ #category : #public }
RCIntSourceView >> addHighlightFrom: start to: stop color: aColor [
	| txt |

	txt := rubric text.
	
	txt makeColor: aColor from: start to: (stop min: txt size).
]

{ #category : #initialization }
RCIntSourceView >> initializeWidgets [

	rubric := RubScrolledTextMorph new
				vResizing: #spaceFill; 
      			hResizing: #spaceFill;
				beWrapped; withColumns;
				textColor: Smalltalk ui theme  textColor;
				textFont: StandardFonts codeFont;
				withLineNumbers; withTextSegmentIcons.

	morph := rubric asSpecAdapter.
]

{ #category : #accessing }
RCIntSourceView >> morph [
	^ morph
]

{ #category : #accessing }
RCIntSourceView >> morph: anObject [
	morph := anObject
]

{ #category : #api }
RCIntSourceView >> show: aString [

	rubric updateTextWith: aString asText.
]
