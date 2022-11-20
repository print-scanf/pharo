"
I am a wrapper around a FileReference for a directory that caches its list of entries. This is done for speed at import time of  Intimals AST's

RCDirectoryMagic resetMapping
"
Class {
	#name : #RCDirectoryMagic,
	#superclass : #Object,
	#instVars : [
		'dir',
		'entries',
		'dirPrefix'
	],
	#classVars : [
		'mapping'
	],
	#category : #'Intimals-AST'
}

{ #category : #mappings }
RCDirectoryMagic class >> mapping [
	mapping ifNil: [ self resetMapping ].
	^mapping
]

{ #category : #'instance creation' }
RCDirectoryMagic class >> onFileReference: aDirectory [
	aDirectory isDirectory ifFalse: [ Error signal: 'Directory path is is not a directory!' ].
	^self new dir: aDirectory.
]

{ #category : #mappings }
RCDirectoryMagic class >> resetMapping [
	mapping := Dictionary new.
]

{ #category : #'file resolving' }
RCDirectoryMagic >> canonicalFormOf: aFileString [
	"transform the dir separator to the version of this file system"
	| sep |
	sep := FileSystem disk separator.

	^aFileString collect: [ :char |
		(char = $/ or: [ char = $\ ]) ifTrue: [ sep ]	ifFalse: [ char ] ].
	
]

{ #category : #accessing }
RCDirectoryMagic >> dir: anObject [
	dir := anObject
]

{ #category : #'dir mimicing' }
RCDirectoryMagic >> entries [
	entries ifNil: [ entries := dir entries ].
	^entries
]

{ #category : #'file resolving' }
RCDirectoryMagic >> findSubDir: aDirName [
	"if aDirName is a subdir of myself, return a magic for that dir"
	| ref |
	dirPrefix isNil ifTrue: [^ nil].
	
	"Workaround for strange behavior seen by Son"
	((dirPrefix key size + 1) >= aDirName size) ifTrue: [
		GrowlMorph openWithLabel: 'Warning'
					contents: aDirName , ' has invalid super directory: ' , dirPrefix key
					color: Color orange darker. 
		^ nil].
	
	ref := (dirPrefix value, (aDirName copyFrom: dirPrefix key size + 1 to: aDirName size)) asFileReference.
	^(ref exists and: [ref isDirectory])
	 	ifTrue: [self class onFileReference: ref]
		ifFalse: [ nil ].

]

{ #category : #'dir mimicing' }
RCDirectoryMagic >> fullName [
	^dir fullName
]

{ #category : #'file resolving' }
RCDirectoryMagic >> mapLookup: aDirName [
	| result ref |

	self class mapping at: aDirName ifPresent: [:fdir | ^fdir].

	result := self findSubDir: aDirName.
	result ifNil: [ | dr fr idx | 
		Smalltalk ui theme
			messageIn: World
			text: 'Matches are said to be in files in:\' withCRs
				,aDirName
				,'\ which is not found. Please locate the equivalent directory.' withCRs
			title: 'Directory not found.'.
		ref := (	UIManager default
				chooseDirectory: 'Looking for :',aDirName
				from: self).
		ref ifNil: [Error signal: 'No directory given'.].
		dr := aDirName reversed.
		fr := ref fullName reversed.
		idx := dr charactersExactlyMatching: fr.
		dirPrefix := (dr copyFrom: idx + 1 to: dr size) reversed
							-> (fr copyFrom: idx + 1 to: fr size) reversed.
		result := self class onFileReference: ref.].

	self class mapping at: aDirName put: result.
	^result
]

{ #category : #'file resolving' }
RCDirectoryMagic >> resolveFileName: aFullName [
	| canonical idx dirpart filepart localdir localfile |
	
	canonical := self canonicalFormOf: aFullName.
	
	idx := canonical
		lastIndexOf: FileSystem disk separator
		ifAbsent: [Error signal: 'Cannot split file name ' , aFullName ].
					
	dirpart := canonical copyFrom: 1 to: idx-1.
	filepart := canonical copyFrom: idx+1 to: canonical size.  

	localfile := dir entries
		detect: [ :nam | nam basename = filepart ]
		ifNone: [
			localfile := (self mapLookup: dirpart) entries
				detect: [ :nam | nam basename = filepart ]
				ifNone: [RCDirectoryMagic resetMapping. Error signal: 'File not found: ', aFullName]].

	^localfile fullName.
]
