"
I am a small UI that is used to configure and run external commands.
"
Class {
	#name : #RCExternalCommandRunner,
	#superclass : #ComposableModel,
	#instVars : [
		'label',
		'selection',
		'cmd',
		'runner',
		'config',
		'configBlock',
		'output',
		'cmdDict',
		'lastResult',
		'replacements'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCExternalCommandRunner class >> defaultSpec [
	^SpecColumnLayout composed
		newRow: [ :r |	r
				newColumn: [ :c | c add: #runner ] width: 30;
				newColumn: [ :c | c add: #output] width: 30; 
				newColumn: [ :c | c add: #config] width: 30;
				newColumn: [ :c | c add: #label] ]
			height: 30;
		newRow: [ :r | r 
				newColumn: [ :c | c add: #selection] width: 90;
				newColumn: [ :c | c add: #cmd]]
			height: 30;
		yourself
]

{ #category : #private }
RCExternalCommandRunner >> applyReplacementsTo: aString [ 
	| result |
	
	result := aString.
	
	replacements keys do: [:key | | idx remidx |
		idx := result findString: key.
		idx > 0 ifTrue: [
			remidx := (idx + key size ).
			result := (result copyFrom: 1 to: idx - 1 ) ,
							(replacements at: key) ,
							(result copyFrom: remidx to: result size)]].
	
	^ result
]

{ #category : #accessing }
RCExternalCommandRunner >> cmd [
	^ cmd
]

{ #category : #accessing }
RCExternalCommandRunner >> cmd: anObject [
	cmd := anObject
]

{ #category : #accessing }
RCExternalCommandRunner >> config [
	^ config
]

{ #category : #accessing }
RCExternalCommandRunner >> config: anObject [
	config := anObject
]

{ #category : #'api-configuration' }
RCExternalCommandRunner >> configureBlock: aDictionary [
	configBlock := aDictionary.
	config enable.
]

{ #category : #initialization }
RCExternalCommandRunner >> initialize [
	cmdDict := Dictionary new.
	replacements := Dictionary new.
	lastResult := ''.
	^super initialize
]

{ #category : #initialization }
RCExternalCommandRunner >> initializePresenter [
	selection
		whenSelectedItemChanged: [ :new | new ifNotNil: [ cmd text: (cmdDict at: new) ] ].
	runner
		action: [ cmd text
				ifNotNil: [ | replaced |
					replaced := self applyReplacementsTo: cmd text.
					(cmd text beginsWith: '<ST>')
						ifTrue: [ | expr |
							expr := replaced copyFrom: 5 to: replaced size.
							lastResult := (OpalCompiler new
								source: expr;
								logged: false;
								evaluate) asString ]
						ifFalse: [ lastResult := RCExecFacade exec: replaced ].
					self showLastResult ] ].
	config
		action: [ (configBlock at: selection selectedItem ifAbsent: [  ]) value ]
]

{ #category : #initialization }
RCExternalCommandRunner >> initializeWidgets [
	label := self newLabel.
	label label: 'Some to be defined command'.
	
	runner := self newButton.
	runner icon: (self iconNamed: 'glamorousGo').
	
	output := self newButton.
	output icon: (self iconNamed: 'glamorousSearch').
	output action: [ self showLastResult ].
	
	config := self newButton.
	config icon: (self iconNamed: 'configuration').
	config enabled: false.
	
	selection := self newDropList.
	selection displayBlock: [ :item | item ].
	selection items: { '*Custom' }.
	
	cmd := self newTextInput.
	cmd ghostText: 'Enter command line here.'.
	cmd autoAccept: true.
	
	
]

{ #category : #accessing }
RCExternalCommandRunner >> label [
	^ label
]

{ #category : #'api-configuration' }
RCExternalCommandRunner >> label: aString [
	label label: aString
]

{ #category : #accessing }
RCExternalCommandRunner >> output [
	^ output
]

{ #category : #accessing }
RCExternalCommandRunner >> output: anObject [
	output := anObject
]

{ #category : #'api-configuration' }
RCExternalCommandRunner >> replacements: anObject [
	replacements := anObject
]

{ #category : #accessing }
RCExternalCommandRunner >> runner [
	^ runner
]

{ #category : #accessing }
RCExternalCommandRunner >> runner: anObject [
	runner := anObject
]

{ #category : #accessing }
RCExternalCommandRunner >> selection [
	^ selection
]

{ #category : #accessing }
RCExternalCommandRunner >> selection: anObject [
	selection := anObject
]

{ #category : #'api-configuration' }
RCExternalCommandRunner >> selections: aDictionary [
	"data for the selection droplist and the cmd field"
	
	cmdDict := aDictionary.
	self selection items: aDictionary keys.
]

{ #category : #private }
RCExternalCommandRunner >> showLastResult [
	| win |
	
	win := TextModel new.
	win text: lastResult.
	win openWithSpec
]
