"
I am a tab where metadata for a pattern can be annotated
"
Class {
	#name : #RCPatternMetadataUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'pattern',
		'text',
		't_1',
		't_2',
		't_3',
		't_4',
		't_5',
		't_6',
		't_7',
		't_8',
		't_9',
		't_a',
		'u_1',
		'u_2',
		'u_3',
		'u_4',
		'u_5',
		'qual',
		'save',
		'export',
		'browser'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCPatternMetadataUI class >> defaultSpec [

	^ SpecLayout composed 
		newColumn: [ :root | 
			root newRow: [:r | r add: #qual. r add: #export. r add: #save.]  height: 30.
			root newRow: [:r |
				r newColumn: [ :c | c add: #t_1. c add: #t_2. c add: #t_3. c add: #t_4. c add: #t_5 ] width: 100.
				r newColumn: [ :c | c add: #t_6. c add: #t_7. c add: #t_8. c add: #t_9. c add: #t_a ] width: 100.
				r newColumn: [ :c | c add: #text ].
				r newColumn: [ :c | c add: #u_1. c add: #u_2. c add: #u_3. c add: #u_4. c add: #u_5 ] width: 150.]]
]

{ #category : #acccessing }
RCPatternMetadataUI class >> tagCategories [
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
RCPatternMetadataUI class >> utilityCategories [
	^{ 
	'Recom. structure' .
	'Coding Practice' .
	'Usage Protocol' .
	'Uninteresting' .
	'Misc'
	}
]

{ #category : #accessing }
RCPatternMetadataUI >> browser [
	^ browser
]

{ #category : #accessing }
RCPatternMetadataUI >> browser: anObject [
	browser := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> export [
	^ export
]

{ #category : #accessing }
RCPatternMetadataUI >> export: anObject [
	export := anObject
]

{ #category : #actions }
RCPatternMetadataUI >> exportMetadata [
	| filename stream |
	
	filename := UIManager default request: 'Please enter filename to export to.' initialAnswer: FileSystem workingDirectory pathString.
	
	filename ifNil: [ ^self ].
	
	stream := filename asFileReference writeStream.

	[ browser clusterColl clusters first value exportTo: stream] ensure: [ stream close.]

]

{ #category : #initialization }
RCPatternMetadataUI >> initializePresenter [ 

	qual whenValueChangedDo: [:new | pattern ifNotNil: [
			new = pattern metadata ifFalse: [ 
				pattern metadata quality: qual value.
				browser metadataChanged: pattern]]].
	
	text acceptBlock: [ :t | pattern ifNotNil: [ pattern metadata text: (t asString)]].
	
	t_1 activationAction:   [ pattern metadata tagCheck:   1].
	t_1 deactivationAction: [ pattern metadata tagUnCheck: 1].
	t_2 activationAction:   [ pattern metadata tagCheck:   2].
	t_2 deactivationAction: [ pattern metadata tagUnCheck: 2].	
	t_3 activationAction:   [ pattern metadata tagCheck:   3].
	t_3 deactivationAction: [ pattern metadata tagUnCheck: 3].
	t_4 activationAction:   [ pattern metadata tagCheck:   4].
	t_4 deactivationAction: [ pattern metadata tagUnCheck: 4].		
	t_5 activationAction:   [ pattern metadata tagCheck:   5].
	t_5 deactivationAction: [ pattern metadata tagUnCheck: 5].
	t_6 activationAction:   [ pattern metadata tagCheck:   6].
	t_6 deactivationAction: [ pattern metadata tagUnCheck: 6].
	t_7 activationAction:   [ pattern metadata tagCheck:   7].
	t_7 deactivationAction: [ pattern metadata tagUnCheck: 7].
	t_8 activationAction:   [ pattern metadata tagCheck:   8].
	t_8 deactivationAction: [ pattern metadata tagUnCheck: 8].
	t_9 activationAction:   [ pattern metadata tagCheck:   9].
	t_9 deactivationAction: [ pattern metadata tagUnCheck: 9].
	t_a activationAction:   [ pattern metadata tagCheck:  10].
	t_a deactivationAction: [ pattern metadata tagUnCheck:10].	
		
	u_1 activationAction:   [ pattern metadata utilCheck:   1].
	u_1 deactivationAction: [ pattern metadata utilUnCheck: 1].
	u_2 activationAction:   [ pattern metadata utilCheck:   2].
	u_2 deactivationAction: [ pattern metadata utilUnCheck: 2].	
	u_3 activationAction:   [ pattern metadata utilCheck:   3].
	u_3 deactivationAction: [ pattern metadata utilUnCheck: 3].
	u_4 activationAction:   [ pattern metadata utilCheck:   4].
	u_4 deactivationAction: [ pattern metadata utilUnCheck: 4].		
	u_5 activationAction:   [ pattern metadata utilCheck:   5].
	u_5 deactivationAction: [ pattern metadata utilUnCheck: 5].
]

{ #category : #initialization }
RCPatternMetadataUI >> initializeWidgets [
	
	qual := self newSlider.
	qual min: -2;
		max: 2;
		label: 'Relevance: '.
	
	qual whenValueChangedDo: [:newVal | | range |
		range := { '--' . '-' . '0' . '+' . '++'}.
		qual label: 'Relevance: ', (range at: newVal +3 )].
	
	export := self newButton.
	export label: 'Export ...'.
	export action: [ self exportMetadata ].
	
	save := self newButton.
	save label: 'Save session ...'.
	save action: [ self saveAll ].
	
	text := self newText.
	text autoAccept: true.
	
	t_1 := self newCheckBox.
	t_1 label: (RCPatternMetadata tagCategories at: 1).
	
	t_2 := self newCheckBox.
	t_2 label: (RCPatternMetadata tagCategories at: 2).
	
	t_3 := self newCheckBox.
	t_3 label: (RCPatternMetadata tagCategories at: 3).
	
	t_4 := self newCheckBox.
	t_4 label: (RCPatternMetadata tagCategories at: 4).
	
	t_5 := self newCheckBox.
	t_5 label: (RCPatternMetadata tagCategories at: 5).
	
	t_6 := self newCheckBox.
	t_6 label: (RCPatternMetadata tagCategories at: 6).
	
	t_7 := self newCheckBox.
	t_7 label: (RCPatternMetadata tagCategories at: 7).
	
	t_8 := self newCheckBox.
	t_8 label: (RCPatternMetadata tagCategories at: 8).
	
	t_9 := self newCheckBox.
	t_9 label: (RCPatternMetadata tagCategories at: 9).

	t_a := self newCheckBox.
	t_a label: (RCPatternMetadata tagCategories at: 10).
	
	u_1 := self newCheckBox.
	u_1 label: (RCPatternMetadata utilityCategories at: 1).
	
	u_2 := self newCheckBox.
	u_2 label: (RCPatternMetadata utilityCategories at: 2).
	
	u_3 := self newCheckBox.
	u_3 label: (RCPatternMetadata utilityCategories at: 3).

	u_4 := self newCheckBox.
	u_4 label: (RCPatternMetadata utilityCategories at: 4).
	
	u_5 := self newCheckBox.
	u_5 label: (RCPatternMetadata utilityCategories at: 5).
]

{ #category : #api }
RCPatternMetadataUI >> pattern: aRCPattern [

	pattern := aRCPattern.
	aRCPattern metadata configureUI: self.
"	qual value: aRCPattern metadata quality."
]

{ #category : #accessing }
RCPatternMetadataUI >> qual [
	^ qual
]

{ #category : #accessing }
RCPatternMetadataUI >> qual: anObject [
	qual := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> save [
	^ save
]

{ #category : #accessing }
RCPatternMetadataUI >> save: anObject [
	save := anObject
]

{ #category : #actions }
RCPatternMetadataUI >> saveAll [
	| data filename |
	
	data := Array with: browser clusterColl with: browser commonColl.
	
	filename := UIManager default request: 'Please enter filename to save your session as.' initialAnswer: FileSystem workingDirectory pathString.
	
	filename isNil ifFalse: [
		Cursor wait showWhile: [
			FLSerializer serialize: data toFileNamed: filename]].
]

{ #category : #accessing }
RCPatternMetadataUI >> t_1 [
	^ t_1
]

{ #category : #accessing }
RCPatternMetadataUI >> t_1: anObject [
	t_1 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_2 [
	^ t_2
]

{ #category : #accessing }
RCPatternMetadataUI >> t_2: anObject [
	t_2 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_3 [
	^ t_3
]

{ #category : #accessing }
RCPatternMetadataUI >> t_3: anObject [
	t_3 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_4 [
	^ t_4
]

{ #category : #accessing }
RCPatternMetadataUI >> t_4: anObject [
	t_4 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_5 [
	^ t_5
]

{ #category : #accessing }
RCPatternMetadataUI >> t_5: anObject [
	t_5 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_6 [
	^ t_6
]

{ #category : #accessing }
RCPatternMetadataUI >> t_6: anObject [
	t_6 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_7 [
	^ t_7
]

{ #category : #accessing }
RCPatternMetadataUI >> t_7: anObject [
	t_7 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_8 [
	^ t_8
]

{ #category : #accessing }
RCPatternMetadataUI >> t_8: anObject [
	t_8 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_9 [
	^ t_9
]

{ #category : #accessing }
RCPatternMetadataUI >> t_9: anObject [
	t_9 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> t_a [
	^ t_a
]

{ #category : #accessing }
RCPatternMetadataUI >> t_a: anObject [
	t_a := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> text [
	^ text
]

{ #category : #accessing }
RCPatternMetadataUI >> text: anObject [
	text := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> u_1 [
	^ u_1
]

{ #category : #accessing }
RCPatternMetadataUI >> u_1: anObject [
	u_1 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> u_2 [
	^ u_2
]

{ #category : #accessing }
RCPatternMetadataUI >> u_2: anObject [
	u_2 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> u_3 [
	^ u_3
]

{ #category : #accessing }
RCPatternMetadataUI >> u_3: anObject [
	u_3 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> u_4 [
	^ u_4
]

{ #category : #accessing }
RCPatternMetadataUI >> u_4: anObject [
	u_4 := anObject
]

{ #category : #accessing }
RCPatternMetadataUI >> u_5 [
	^ u_5
]

{ #category : #accessing }
RCPatternMetadataUI >> u_5: anObject [
	u_5 := anObject
]
