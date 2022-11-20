Extension { #name : #RCPatternMetadata }

{ #category : #'*Intimals-GUI' }
RCPatternMetadata >> configureUI: aMUI [

	aMUI qual value: quality.
	aMUI text text: text.
	
	aMUI t_1 state: (tags at: 1).
	aMUI t_2 state: (tags at: 2).
	aMUI t_3 state: (tags at: 3).
	aMUI t_4 state: (tags at: 4).
	aMUI t_5 state: (tags at: 5).
	aMUI t_6 state: (tags at: 6).
	aMUI t_7 state: (tags at: 7).
	aMUI t_8 state: (tags at: 8).
	aMUI t_9 state: (tags at: 9).
	aMUI t_a state: (tags at: 10).

	aMUI u_1 state: (utility at: 1).
	aMUI u_2 state: (utility at: 2).
	aMUI u_3 state: (utility at: 3).
	aMUI u_4 state: (utility at: 4).
	aMUI u_5 state: (utility at: 5).

]
