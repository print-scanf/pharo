"
I am the result of a frequent itsemset match run, I contain the  document in the adhoc output format.
"
Class {
	#name : #RCPathCollection,
	#superclass : #Object,
	#instVars : [
		'paths'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCPathCollection class >> fromPatterns: patname withMatches: aMatchesXMLName andASTDir: aDirName [
	| inst astDirectory patlines matxml patterns matches count |
	
	astDirectory := RCDirectoryMagic onFileReference: (aDirName asFileReference).
	
	'Reading paths and matches files.'
		displayProgressFrom: 0 to: 2 during: [:bar | 
			bar current: 1.
			patlines := patname asFileReference readStream upToEnd lines.

			bar current: 2.
			matxml := self parseXML: aMatchesXMLName.
			
			matches := Dictionary new: patlines size.
			matxml nodes first nodes do: [ :node |
					node isStringNode ifFalse: [ 
						(matches at: (node attributeAt: 'PatternID')
									ifAbsentPut: [OrderedCollection new]) add: node ]
				 ]
			].
	
	RCASTCollection resetGlobal.
	RCSourcesCollection resetGlobal.

	count := 0.
	patterns := OrderedCollection new: patlines size.
	patlines
		do: [:line |
			count := count + 1.
			patterns add: (RCFISPattern fromLine: line withID: count asString withMatches: matches andASTDir: astDirectory) ]
		displayingProgress: 'Reading patterns ...'.
	
	inst := self new.
	inst paths: patterns.
	^inst
]

{ #category : #utility }
RCPathCollection class >> parseXML: aFileName [
	| domparser |
	domparser := XMLDOMParser onFileNamed: aFileName.
	domparser optimizeForLargeDocuments.
	^domparser parseDocument.
]

{ #category : #'inspector extensions' }
RCPathCollection >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: -10>
	^ composite fastTable
		title: 'Patterns';
		display: [ self paths ];
		enableElementIndex;
		column: 'Id' evaluated: [ :val | val id padLeftTo: 4 with: $0 ] width: 40;
		column: 'Sup' evaluated: [ :val | val support padLeftTo: 3 with: $0 ] width: 40;
		column: 'Path' evaluated: [ :val | val paths]
]

{ #category : #accessing }
RCPathCollection >> paths [
	^ paths
]

{ #category : #accessing }
RCPathCollection >> paths: anObject [
	paths := anObject
]
