REBOL
[
	Title: "Tokyo Tyrant Driver"
	Date: 12-Dec-2009
	Version: 0.2.3
	File: %tokyo-tyrant-driver.r
	Home: http://github.com/moechofe/TokyoTyrant-protocol-for-Rebol
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	Needs: %tokyo-tyrant-protocol.r
	Usage: none
	Purpose: {This is a front-end to send command to a ToykyoTyrant server.}
	Comment: {This is more a sanbox than a fully effective program.}
	History: [
	  0.2.3 [24-Sep:2010 {Support PUTKEEP command. }
		0.2.2 [12-Dec-2009 {Support PUTNR command. Add a new driver to send query directly to protocol, convertion are also perform by the protocol.}]
		0.1.2 [11-Dec-2009 {Support VSIZ, PUTKEEP and PUTCAT commands.}]
		0.1.1 [10-Dec-2009 {Support PUT and GET commands.}] ]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		license: 'Copyleft
		see-also: [%tokyo-tyrant-protocol.r %tokyo-tyrant-test.r] ]
]

do %tokyo-tyrant-protocol.r

tokyo-tyrant-object: context
[
	server-url: tokyo://localhost:1978
	port: none

	set 'tokyo-tyrant func [ url [url!] /local object ]
	[ make tokyo-tyrant-object [ port: open server-url: url ] ]

	put: func [ "Put or keep a value identified by a key."
	key [word!] "The key."
	value "The value."
	/keep /k "Put a value only if the key isn't exists."
	/concat /cat /c "Concat a value with an existing key."
	/noerror /no-error /nr "Do not wait for a response from server, always return TRUE."
	/local data ] [
		data: system/words/copy reduce [ to-set-word key value ]
		either any [keep k]	[ insert data [attempt] ] ;PUTKEEP
		[ either any [concat cat c] [ insert data [append] ] ;PUTCAT
		[ if any [noerror no-error nr] [ insert data [noerror] ] ] ] ;PUTNR
		insert port data first copy port ]

	get: func [ "Get a value identified by a key."
	key [word!] "The key."
	/integer /int /i "Convert to integer."
	/raw /binary /b "Do not convert, return a binary value."
	/local value ] [
		insert port reduce [ to-get-word key ]
		if any [ integer int i ] [ return to-integer first copy port ]
		if any [ raw binary b ] [ return first copy port ]
		return any [
			attempt [ do mold to-string value: first copy port ]
			to-integer value ] ]

	length?: func [ "Return the length of a value identified by a key."
	key [word!] "The key." ] [
		insert port reduce [ 'length? to-get-word key ]
		to-integer first copy port ]
]

tokyo: func [ "Return a function to send query for a Tokyo Tyrant server."
url [url!] "The URL of the server. Format: tokyo://localhost:1978" ] [ do compose/deep [
	func [ "Send query to a Tokyo Tyrant server and receive result from it."
	query [block!] {The query can be one or more of the followed format:
		PUT = [key: value] Store a value identified by the key.
		GET = [:key] Retrieve a value identified by the key.}
	/local port ] [ port: open (url) insert port query copy port ] ] ]
