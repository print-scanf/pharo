"
I am a facade on the underlying infrastructure to run command line programs.

For Windows, I need the OSWindows package to be loaded from the Pharo Catalog
See http://www.smalltalkhub.com/#!/~OS/OS-Windows
 https://github.com/astares?utf8=%E2%9C%93&tab=repositories&q=Pharo-OS&type=&language=

See also https://github.com/astares/Pharo-OS-Unix
"
Class {
	#name : #RCExecFacade,
	#superclass : #Object,
	#category : #'Intimals-GUI'
}

{ #category : #running }
RCExecFacade class >> exec: aString [
	"I execute the string given as argument as if it were a commandline program
	I return the results of stdout when the program has finished"
	
	"only windows for now"
	Smalltalk os isWin32
		ifTrue: [^WinProcess resultOfCommand: aString]
		ifFalse: [ Error signal: 'Non-windows OS not yet supported' ]
	
	"Alternate Win solution: ProcessWrapper new
        useStdout;
        startWithCommand: aString;
        upToEnd"

	"For MacOS and Linux investigate OSSubProcess"
]
