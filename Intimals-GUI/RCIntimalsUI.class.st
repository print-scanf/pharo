"
I am the main UI for the Intimals pipeline

RCIntimalsUI open
"
Class {
	#name : #RCIntimalsUI,
	#superclass : #ComposablePresenter,
	#instVars : [
		'importer',
		'prepro',
		'miner',
		'matcher',
		'explore',
		'astPath',
		'ast2Path',
		'aPLabel',
		'theASTPath',
		'theAST2Path',
		'resultsPath',
		'rPLabel',
		'patternsFile',
		'pFLabel',
		'matchesFile',
		'matches2File',
		'mFLabel',
		'clustersFile',
		'cFLabel',
		'configLabel',
		'theResultsPath',
		'bl',
		'resume',
		'exploreDiff'
	],
	#category : #'Intimals-GUI'
}

{ #category : #specs }
RCIntimalsUI class >> defaultSpec [
	^SpecRowLayout composed
	   newColumn: [ :c | ] width: 5;
		newColumn: [ :c | c
			add: #configLabel;
			add: #aPLabel;
			add: #astPath;
			add: #ast2Path;
			add: #rPLabel;
			add: #resultsPath;
			add: #pFLabel;
			add: #patternsFile;
			add: #mFLabel;
			add: #matchesFile;
			add: #matches2File;
			add: #cFLabel;
			add: #clustersFile
						] width: 230;
		newColumn: [ :c | c
			add: #importer height: 60;
			add: #prepro height: 60;
			add: #miner height: 60;
			add: #matcher height: 60;
			newRow: [:r | r add: #explore; add: #exploreDiff; add: #resume] height: 50] width: 800;
		yourself
]

{ #category : #opening }
RCIntimalsUI class >> open [
	| inst |
	inst := self new.
	inst extent: 1055@360.
	inst openWithSpec.
	^inst
]

{ #category : #accessing }
RCIntimalsUI >> aPLabel [
	^ aPLabel
]

{ #category : #accessing }
RCIntimalsUI >> aPLabel: anObject [
	aPLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> ast2Path [
	^ ast2Path
]

{ #category : #accessing }
RCIntimalsUI >> ast2Path: anObject [
	ast2Path := anObject
]

{ #category : #accessing }
RCIntimalsUI >> astPath [
	^ astPath
]

{ #category : #accessing }
RCIntimalsUI >> astPath: anObject [
	astPath := anObject
]

{ #category : #accessing }
RCIntimalsUI >> bl [
	^ bl
]

{ #category : #accessing }
RCIntimalsUI >> bl: anObject [
	bl := anObject
]

{ #category : #utility }
RCIntimalsUI >> buildClustersFor: aFileName andPatterns: aPatternCollection [

	aFileName asFileReference exists ifTrue: [ ^ RCClusterCollection fromFile: aFileName withPatterns: aPatternCollection ].

	GrowlMorph openWithLabel: 'Warning'
				contents: 'Clusters file not found!'
				color: Color orange darker. 

	^RCClusterCollection withPatterns: aPatternCollection

]

{ #category : #accessing }
RCIntimalsUI >> cFLabel [
	^ cFLabel
]

{ #category : #accessing }
RCIntimalsUI >> cFLabel: anObject [
	cFLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> clustersFile [
	^ clustersFile
]

{ #category : #accessing }
RCIntimalsUI >> clustersFile: anObject [
	clustersFile := anObject
]

{ #category : #accessing }
RCIntimalsUI >> configLabel [
	^ configLabel
]

{ #category : #accessing }
RCIntimalsUI >> configLabel: anObject [
	configLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> explore [
	^ explore
]

{ #category : #accessing }
RCIntimalsUI >> explore: anObject [
	explore := anObject
]

{ #category : #accessing }
RCIntimalsUI >> exploreDiff [
	^ exploreDiff
]

{ #category : #accessing }
RCIntimalsUI >> exploreDiff: anObject [
	exploreDiff := anObject
]

{ #category : #actions }
RCIntimalsUI >> exploreDifferences [
	| fulldir patname matname mat2name astname ast2name pats pats2 dialog |

	fulldir := theResultsPath fullName.
	fulldir last = FileSystem disk delimiter
		ifFalse: [ fulldir := fulldir , FileSystem disk delimiter asString ].	

	patname := fulldir,(patternsFile text).
	matname := fulldir,(matchesFile text).
	mat2name := fulldir,(matches2File text).
	
	astname := theASTPath fullName.
	ast2name 	:= theAST2Path fullName.
		
	RCDirectoryMagic resetMapping.
	dialog := MessageDialogWindow labelled: 'Loading OLD patterns'.
	dialog text: 'If directories of matches are requested, provide those of the OLD files.'.
	dialog openInWorld.
	[pats := RCPatternCollection fromPatterns: patname withMatches: matname andASTDir: astname.]
		on: XMLFileException
		do: [:ex |
			Smalltalk ui theme
					abortIn: World
					text: 'There was a problem loading a file. Are XML files of Old ASTs in the same directories as the source files?' withCRs
					title: ex messageText.
				^self].
	dialog close.
	
	dialog := MessageDialogWindow labelled: 'Loading NEW patterns'.
	dialog text: 'If directories of matches are requested, provide those of the NEW files.'.
	dialog openInWorld.
	RCDirectoryMagic resetMapping.		
	[pats2 := RCPatternCollection fromPatterns: patname withMatches: mat2name andASTDir: ast2name.]
		on: XMLFileException
		do: [:ex |
			Smalltalk ui theme
					abortIn: World
					text: 'There was a problem loading a file. Are XML files of New ASTs in the same directories as the source files?' withCRs
					title: ex messageText.
				^self].
	dialog close.

	(RCHistoryPatternBrowserUI onOldPatternCollection: pats newPatternCollection: pats2) openWithSpec 

]

{ #category : #actions }
RCIntimalsUI >> exploreResults [
	| fulldir patname matname astname pats clusters pcomname mcomname ui |

	fulldir := theResultsPath fullName.
	fulldir last = FileSystem disk delimiter
		ifFalse: [ fulldir := fulldir , FileSystem disk delimiter asString ].	

	patname := fulldir,(patternsFile text).
	matname := fulldir,(matchesFile text).
	astname := theASTPath fullName.
	
	[pats := RCPatternCollection fromPatterns: patname withMatches: matname andASTDir: astname.]
		on: XMLFileException
		do: [:ex |
			Smalltalk ui theme
					abortIn: World
					text: 'There was a problem loading a file. Are XML files of ASTs in the same directories as the source files?' withCRs
					title: ex messageText.
				^self].
	
	clusters := self buildClustersFor: fulldir,(clustersFile text) andPatterns: pats.

	pcomname := (patname copyFrom: 1 to: patname size - 4),'_common.xml'.
	mcomname := (matname copyFrom: 1 to: matname size - 4),'_common.xml'.
	(pcomname asFileReference exists and: [mcomname asFileReference exists])
		ifTrue: [ | compats |
			compats := RCPatternCollection fromPatterns: pcomname withMatches: mcomname andASTDir: astname.
			ui := RCPatternBrowserUI onClusterCollection: clusters andCommonCollection: compats.
			]
		ifFalse: [
			GrowlMorph openWithLabel: 'Warning'
				contents: 'Common patterns and matches not found!'
				color: Color orange darker. 
			ui := RCPatternBrowserUI onClusterCollection: clusters].
	ui title: patname , ' | ' , matname.
	ui openWithSpec.
]

{ #category : #accessing }
RCIntimalsUI >> importer [
	^ importer
]

{ #category : #accessing }
RCIntimalsUI >> importer: anObject [
	importer := anObject
]

{ #category : #initialization }
RCIntimalsUI >> initConfigPart [
	
	configLabel := self newLabel.
	configLabel label: 'Config options:'.
	
	aPLabel := self newLabel.
	aPLabel label: '[astPath] / [ast2Path]'.

	astPath := self newButton.
	astPath icon: (self iconNamed: 'package').
	astPath label: '?'.
	astPath action: [self updateASTPath].

	ast2Path := self newButton.
	ast2Path icon: (self iconNamed: 'package').
	ast2Path label: '?'.
	ast2Path action: [self updateASTPath2].

	rPLabel := self newLabel.
	rPLabel label: 'Results file path'.
	
	resultsPath := self newButton.
	resultsPath icon: (self iconNamed: 'package').
	resultsPath label: '?'.
	resultsPath action: [self updateResultsPath].

	pFLabel := self newLabel.
	pFLabel label: '[patternsFile]'.
	patternsFile := self newTextInput.
	patternsFile text: 'patterns.xml'.
	patternsFile acceptBlock: [:text | self updateConfig. true ].
	
	mFLabel := self newLabel.
	mFLabel label: '[matchesFile] / [matches2File]'.
	
	matchesFile := self newTextInput.
	matchesFile text: 'matches.xml'.
	matchesFile  acceptBlock: [:text | self updateConfig. true ].

	matches2File := self newTextInput.
	matches2File text: 'matchesNew.xml'.
	matches2File  acceptBlock: [:text | self updateConfig. true ].
	
	cFLabel := self newLabel.
	cFLabel label: '[clustersFile]'.
	clustersFile := self newTextInput.
	clustersFile text: 'matches_clusters.xml'.
	clustersFile  acceptBlock: [:text | self updateConfig. true ].
]

{ #category : #initialization }
RCIntimalsUI >> initialize [
	theASTPath := FileSystem workingDirectory.
	theAST2Path := theASTPath.
	theResultsPath := theASTPath.
	^super initialize 
]

{ #category : #initialization }
RCIntimalsUI >> initializePresenter [
	self updateConfig.
]

{ #category : #initialization }
RCIntimalsUI >> initializeWidgets [

	self initConfigPart.
	bl := self newLabel.
	bl label: ''.

	importer := self instantiate: RCExternalCommandRunner.
	importer label: 'Import sources'.
	importer selections: { 
		'Java' -> 'java -jar java-importer.jar import [astPath]'.
		'Cobol' -> '<ST> RCXMLGenerator import: #COBOL from: ''[astPath]'' '.
		'*Custom' -> ''
	} asDictionary.
	
	prepro := self instantiate: RCExternalCommandRunner.
	prepro label: 'Preprocess ASTs'.
	
	miner := self instantiate: RCExternalCommandRunner.
	miner label: 'Perform mining'.
	miner selections: { 
		'FreqT' -> 'java -Xmx1400m -jar freqt_java.jar'.
		'*Custom' -> ''
	} asDictionary.
	miner configureBlock: {
		'FreqT' -> [(FileSystem workingDirectory / 'conf' / 'config.properties') inspect] } asDictionary.
	
	matcher := self instantiate: RCExternalCommandRunner.
	matcher label: 'Match patterns to ASTs'.
	matcher selections: {
		'Default' -> 'java -Xmx1024M -jar forestmatcher.jar [astPath] [patternsFile] [matchesFile]' .
		'*Custom' -> ''
			 } asDictionary.
	
	explore := self newButton.
	explore label: 'Explore results ...'.
	explore action: [ self exploreResults ].	
	
	exploreDiff := self newButton.
	exploreDiff label: 'Explore differences ...'.
	exploreDiff action: [ self exploreDifferences ].
		
	resume := self newButton.
	resume label: 'Resume session ...'.
	resume action: [ Error signal: 'Session resumption not supported.' "self resumeSession" ].
]

{ #category : #accessing }
RCIntimalsUI >> mFLabel [
	^ mFLabel
]

{ #category : #accessing }
RCIntimalsUI >> mFLabel: anObject [
	mFLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> matcher [
	^ matcher
]

{ #category : #accessing }
RCIntimalsUI >> matcher: anObject [
	matcher := anObject
]

{ #category : #accessing }
RCIntimalsUI >> matches2File [
	^ matches2File
]

{ #category : #accessing }
RCIntimalsUI >> matches2File: anObject [
	matches2File := anObject
]

{ #category : #accessing }
RCIntimalsUI >> matchesFile [
	^ matchesFile
]

{ #category : #accessing }
RCIntimalsUI >> matchesFile: anObject [
	matchesFile := anObject
]

{ #category : #accessing }
RCIntimalsUI >> miner [
	^ miner
]

{ #category : #accessing }
RCIntimalsUI >> miner: anObject [
	miner := anObject
]

{ #category : #accessing }
RCIntimalsUI >> pFLabel [
	^ pFLabel
]

{ #category : #accessing }
RCIntimalsUI >> pFLabel: anObject [
	pFLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> patternsFile [
	^ patternsFile
]

{ #category : #accessing }
RCIntimalsUI >> patternsFile: anObject [
	patternsFile := anObject
]

{ #category : #accessing }
RCIntimalsUI >> prepro [
	^ prepro
]

{ #category : #accessing }
RCIntimalsUI >> prepro: anObject [
	prepro := anObject
]

{ #category : #accessing }
RCIntimalsUI >> rPLabel [
	^ rPLabel
]

{ #category : #accessing }
RCIntimalsUI >> rPLabel: anObject [
	rPLabel := anObject
]

{ #category : #accessing }
RCIntimalsUI >> resultsPath [
	^ resultsPath
]

{ #category : #accessing }
RCIntimalsUI >> resultsPath: anObject [
	resultsPath := anObject
]

{ #category : #accessing }
RCIntimalsUI >> resume [
	^ resume
]

{ #category : #accessing }
RCIntimalsUI >> resume: anObject [
	resume := anObject
]

{ #category : #actions }
RCIntimalsUI >> resumeSession [
	| filename data |
	
	filename := UIManager default chooseExistingFileReference: 'Please enter filename of stored session.' extensions: nil path: FileSystem workingDirectory. 
	
	filename isNil ifTrue: [ ^self ].
	
	Cursor wait showWhile: [data := FLMaterializer materializeFromFileNamed: filename pathString].
	
	(RCPatternBrowserUI onClusterCollection: data first andCommonCollection: data second) openWithSpec.
]

{ #category : #accessing }
RCIntimalsUI >> title [
	^'INTiMALS pipeline'
]

{ #category : #configuration }
RCIntimalsUI >> updateASTPath [
	| newpath |
	newpath := UIManager default chooseDirectoryFrom: theASTPath.

	newpath ifNotNil: [
		theASTPath := newpath .
		RCDirectoryMagic resetMapping.
		self updateConfig.]
]

{ #category : #configuration }
RCIntimalsUI >> updateASTPath2 [
	| newpath |
	newpath := UIManager default chooseDirectoryFrom: theAST2Path.

	newpath ifNotNil: [
		theAST2Path := newpath .
		RCDirectoryMagic resetMapping.
		self updateConfig.]
]

{ #category : #configuration }
RCIntimalsUI >> updateConfig [
	| mapping afn a2fn rfn siz|
	
	afn := theASTPath fullName.
	a2fn := theAST2Path fullName.
	rfn := theResultsPath fullName.
	
	mapping := { 
		'[astPath]' -> afn.
		'[ast2Path]' -> a2fn.
		'[hidden-results-path]' -> rfn.
		'[patternsFile]' -> patternsFile text.
		'[matchesFile]' -> matchesFile text.
		'[matches2File]' -> matches2File text.
		'[clustersFile]' -> clustersFile text.
	 } asDictionary.

	siz := afn size.
	astPath label: '...',(afn copyFrom: (siz - 25 max: 1) to: siz).

	siz := a2fn size.
	ast2Path label: '...',(a2fn copyFrom: (siz - 25 max: 1) to: siz).

	siz := rfn size.
	resultsPath label: '...',(rfn copyFrom: (siz - 25 max: 1) to: siz).
	
	importer replacements: mapping.
	prepro replacements: mapping.
	miner replacements: mapping.
	matcher replacements: mapping.
]

{ #category : #configuration }
RCIntimalsUI >> updateResultsPath [
	| newpath |
	newpath := UIManager default chooseDirectoryFrom: theResultsPath.

	newpath ifNotNil: [
		theResultsPath := newpath .
		self updateConfig.]
]
