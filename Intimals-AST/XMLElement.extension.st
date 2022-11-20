Extension { #name : #XMLElement }

{ #category : #'*Intimals-AST' }
XMLElement >> characterOffsetFrom: startLine toLine: endLine andColumn: endColumn [
	"calculate this based on the source code string obtained through getSourceFragment"
	| srcoll dl count |

	srcoll := self getSourceFragment lines.
	dl := endLine - startLine.
	
	dl = 0 ifTrue: [
			self srcLang = #python ifTrue:[^endColumn].
		 	^endColumn + 1 ].
	
	count := 1.
	1 to: dl do: [:idx | count := count + ((srcoll at: idx) size) + 1].
	
	self srcLang = #java ifTrue:  [^ count + endColumn ].
	^ count + endColumn - 1
]

{ #category : #'*Intimals-AST' }
XMLElement >> characterOffsetToEnd [
	"What is the char offset of my end with regard to my getSourceFragment"
	^ self
		characterOffsetFrom: (self attributeAt: 'LineNr') asInteger 
		toLine: (self attributeAt: 'EndLineNr') asInteger
		andColumn: (self attributeAt: 'EndColNr') asInteger
]

{ #category : #'*Intimals-AST' }
XMLElement >> characterOffsetToLine: endLine andColumn: endColumn [
	^self characterOffsetFrom: (self attributeAt: 'LineNr') asInteger toLine: endLine andColumn: endColumn
	
]

{ #category : #'*Intimals-AST' }
XMLElement >> characterOffsetToStart [
	"What is the char offset of my start with regard to my getSourceFragment"
	
	
	(self srcLang = #java)
		ifTrue: [ ^(self attributeAt: 'ColNr') asInteger + 1  ].

	^(self attributeAt: 'ColNr') asInteger
]

{ #category : #'*Intimals-AST' }
XMLElement >> fileReference [

	self document ifNil: [  FileException signal: 'No document specified.' ].
	^(self document root
		attributeAt: 'SourceFileName'
		ifAbsent: [ FileException signal: 'No document file specified.' ]) asFileReference.

	
]

{ #category : #'*Intimals-AST' }
XMLElement >> getExactSource [
	| source start end |
	source := self getSourceFragment.
	start := self characterOffsetToStart.
	end := self characterOffsetToEnd.
	^source copyFrom: start to: (end min: source size) . 
]

{ #category : #'*Intimals-AST' }
XMLElement >> getFullSource [
	^RCSourcesCollection global sourcesAt: self
]

{ #category : #'*Intimals-AST' }
XMLElement >> getSourceFragment [
	^RCSourcesCollection global fragmentAt: self
]

{ #category : #'*Intimals-AST' }
XMLElement >> gtInspectorSourceFragmentIn: composite [

	<gtInspectorPresentationOrder: -2>
	^composite spec
		title: 'File Source';
		display: [ :elt | | cm source |
			source := [self getSourceFragment] on: FileException do: [:ex | ex messageText].
			cm := RCIntSourceView on: source.
			cm buildWithSpec.
			cm ]
]

{ #category : #'*Intimals-AST' }
XMLElement >> hasSameCharacterRangeAs: aNode [
	^(self attributeAt: 'LineNr') = (aNode attributeAt: 'LineNr') and: [
		(self attributeAt: 'ColNr') = (aNode attributeAt: 'ColNr') and: [ 
		(self attributeAt: 'EndLineNr') = (aNode attributeAt: 'EndLineNr') and: [
		(self attributeAt: 'EndColNr') = (aNode attributeAt: 'EndColNr') ]]]
]

{ #category : #'*Intimals-AST' }
XMLElement >> isIgnorable [
	^false
]

{ #category : #'*Intimals-AST' }
XMLElement >> isImage [
	^{'TheImage' . 'AImage' . 'TheOriginalImage' . 'TheParsedImage' }
		anySatisfy: [ :nam | nam = self name ]
]

{ #category : #'*Intimals-AST' }
XMLElement >> readFragmentFrom: fileRef start: start stop: stop [
	| fileOffset line textbuf  |

	fileOffset := 0.
	
	fileRef readStreamDo: [ :stream |
			[(line := stream nextLine) isNil] whileFalse: [
					fileOffset := fileOffset + 1.
					fileOffset = start ifTrue: [ 
						textbuf := WriteStream with: String new.
						[fileOffset <= stop] whileTrue: [
							textbuf nextPutAll: (self srcLang = #undef
									ifFalse: [ line ] ifTrue: [line copyFrom: 7 to: (72 min: line size)]).
							textbuf nextPut: Character cr.
							line := stream nextLine. fileOffset := fileOffset + 1.].									
							^textbuf contents.
					 ]]
				].
	^nil
]

{ #category : #'*Intimals-AST' }
XMLElement >> readFullSource [

	^self fileReference contents

]

{ #category : #'*Intimals-AST' }
XMLElement >> readSourceFragment [
	| start stop txt |

	start := (self attributeAt: 'LineNr' ifAbsent: [ 0 ]) asNumber.
	stop := (self attributeAt: 'EndLineNr' ifAbsent: [ 0 ]) asNumber.
	
	((start = 0) or: [ stop = 0 ]) ifTrue: [ FileException signal: 'Start or end line number missing.' ].

	txt := self readFragmentFrom: self fileReference start: start stop: stop.
	txt isNil	 ifTrue: [ FileException signal: 'Not all source lines were found.' ].
	^txt

]

{ #category : #'*Intimals-AST' }
XMLElement >> srcLang [
	| fname |
	
	fname := (self document root attributeAt: 'FullName' ifAbsent: '') .
	
	^({'.java' -> #java . '.cs' -> #cs . '.py' -> #python} asDictionary)
			at: (fname copyFrom: (fname lastIndexOf: $.) to: (fname size))
			ifAbsent: [#undef]
]
