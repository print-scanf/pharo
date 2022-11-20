"
I am the result of matching a pattern to  a program. See my class side for how to create me.
"
Class {
	#name : #RCOldMatch,
	#superclass : #Object,
	#instVars : [
		'name',
		'matches',
		'sourceMatches',
		'graphView',
		'graphHighlight',
		'emphasizedElements'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCOldMatch class >> name: aName matches: someMatches [
	| inst |
	inst := self new.
	inst name: aName.
	inst matches: someMatches.
	^inst.
]

{ #category : #calculating }
RCOldMatch >> calculateSourceMatches [
	| result lineNRs file |
	
	"sanity check"
	self matches isEmpty ifTrue: [ ^{} ].
	
	lineNRs := self matches collect: [:match |
		(match attributeAt: 'LineNr' ifAbsent: [ 1 ]) asNumber
			to: (match attributeAt: 'EndLineNr' ifAbsent: [ 1 ]) asNumber].
	
	file := (self matches first document root attributeAt: 'FileName') asFileReference.
	file exists ifFalse: [ ^{ 'Error: Source file not found!' } ].

	result := OrderedCollection new: lineNRs size.
	
	file readStreamDo: [:stream | | fileOffset linesOffset start stop line |
		fileOffset := 0.
		linesOffset := 1.
		start := (lineNRs at: linesOffset) first.
		stop := (lineNRs at: linesOffset) last.
		[line := stream nextLine. line isNil] whileFalse: [
			fileOffset := fileOffset + 1.
			
			"found the first line of the result"
			fileOffset = start ifTrue: [ | textbuf |
				textbuf := WriteStream with: String new.
				"read in the entire result"
				[fileOffset <= stop] whileTrue:
					[textbuf nextPutAll: line. textbuf nextPut: Character cr.
					line := stream nextLine. fileOffset := fileOffset + 1.].
				result add: textbuf contents.

				linesOffset := linesOffset + 1.
			   "found all matches?"
				linesOffset > lineNRs size ifTrue:[^result].
				start := (lineNRs at: linesOffset) first.
				stop := (lineNRs at: linesOffset) last.]
			]. 
		].

	Error signal: 'Read full file contents without finding all matches'.
	^ nil.
]

{ #category : #'inspector extensions' }
RCOldMatch >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: -2>
	
	^composite fastTable
			title: 'Source';
			display: [ self sourceMatches ];
			enableElementIndex;
			column: 'Index' evaluated: [ :val :i | i asString  ] width: 40;
			column: 'Source' evaluated: [ :val | GTObjectPrinter asTruncatedTextFrom: val  ]
]

{ #category : #'inspector extensions' }
RCOldMatch >> gtInspectorTreeIn: composite [
	<gtInspectorPresentationOrder: -1>
	
	^composite tree
			title: 'EG Tree';
			display: [ self matches anyOne ];
			children: [:each | each treeViewChildren];
			format: [:each | each treeViewLabelText];
			allExpanded.
]

{ #category : #accessing }
RCOldMatch >> matches [
	^ matches
]

{ #category : #accessing }
RCOldMatch >> matches: aCollection [
	matches := SortedCollection new: aCollection size.
	matches sortBlock: [:first :second |
		(first attributeAt: 'LineNr' ifAbsent: [0]) asNumber 
			<= (second attributeAt: 'LineNr' ifAbsent: [0]) asNumber].
	matches addAll: aCollection.
]

{ #category : #accessing }
RCOldMatch >> name [
	^ name
]

{ #category : #accessing }
RCOldMatch >> name: anObject [
	name := anObject
]

{ #category : #accessing }
RCOldMatch >> numberOfMatches [
	^matches size.
]

{ #category : #accessing }
RCOldMatch >> sourceMatches [
	sourceMatches ifNil: [ sourceMatches := self calculateSourceMatches].
	^sourceMatches.
]
