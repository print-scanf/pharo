"
I am a repository for palettes used in the different visualizations. See my class side for how to use me.
"
Class {
	#name : #RCIntPalettes,
	#superclass : #Object,
	#classVars : [
		'ast',
		'pattern'
	],
	#category : #'Intimals-Vis'
}

{ #category : #accessing }
RCIntPalettes class >> ast [

	ast = nil ifTrue: [ ast := RTColorPalette qualitative colors: 8 scheme:'Dark2' ].
	^ast
]

{ #category : #accessing }
RCIntPalettes class >> astColorFor: aString [

	aString = '?_root' ifTrue: [ ^self ast at: 1 ].
	aString = '?_visited' ifTrue: [ ^self ast at: 2 ].
	aString = 'error' ifTrue: [^self ast at: 4].
	^self ast at: ( Random new useClockBasedSeed nextInt: 6 ) + 2
]

{ #category : #accessing }
RCIntPalettes class >> pattern [

	pattern = nil ifTrue: [ pattern := RTColorPalette qualitative colors: 9 scheme:'Set1' ].
	^pattern
]
