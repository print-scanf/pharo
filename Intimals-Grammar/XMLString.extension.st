Extension { #name : #XMLString }

{ #category : #'*Intimals-Grammar' }
XMLString >> isChildLess [
	^true
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isGrandparent [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isListNode [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isOptNode [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isOr2Node [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isOrNode [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> isSepNode [
	^false
]

{ #category : #'*Intimals-Grammar' }
XMLString >> relevantNodes [
	^#()
]
