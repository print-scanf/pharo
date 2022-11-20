"
I am a transparent aggregate over different RCMatchCollections
"
Class {
	#name : #RCMatchAggregateCollection,
	#superclass : #Object,
	#instVars : [
		'collections'
	],
	#category : #'Intimals-AST'
}

{ #category : #'instance creation' }
RCMatchAggregateCollection class >> on: aCollection [
	| inst |
	inst := self new.
	inst collections: aCollection.
	^inst
]

{ #category : #accessing }
RCMatchAggregateCollection >> collections [
	^ collections
]

{ #category : #accessing }
RCMatchAggregateCollection >> collections: anObject [
	collections := anObject
]

{ #category : #'inspector extensions' }
RCMatchAggregateCollection >> gtsourceFragmentIn: composite [
	<gtInspectorPresentationOrder: -30>
	^ composite fastTable
		title: 'Match src';
		display: [ self matches ];
		enableElementIndex;
		column: 'Index' evaluated: [ :val :i | i asString  ] width: 40;
		column: 'Item' evaluated: [ :val | GTObjectPrinter asTruncatedTextFrom: (val to getExactSource) ].
]

{ #category : #mimicing }
RCMatchAggregateCollection >> matches [
	| result |
	result := OrderedCollection new.
	collections do: [:col | result addAll: col matches].
	^result
]

{ #category : #mimicing }
RCMatchAggregateCollection >> size [
	^ collections inject: 0 into: [ :tot :next | tot + next size ]. 
]
