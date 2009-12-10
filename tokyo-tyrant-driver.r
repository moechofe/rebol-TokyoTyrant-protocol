REBOL
[
]

do %tokyo-tyrant-protocol.r

tokyo-tyrant-object: context
[
	server-url: tokyo://localhost:1978
	port: none

	set 'tokyo-tyrant func [ url [url!] /local object ]
	[ make tokyo-tyrant-object [ port: open server-url: url ] ]

	put: func [
	"Put a value to the server identified by a key"
	key [word!] "The key"
	value "The value" ] [ insert port reduce [ to-set-word key value ] ]

	get: func [
	"Get a value from the server identified by a key"
	key [word!] "The key"
	/integer /int /i "Convert to integer"
	/raw /binary /b "Do not convert, return a binary value"
	/local value ] [
		insert port reduce [ to-get-word key ]
		if any [ integer int i ] [ return to-integer copy port ]
		if any [ raw binary b ] [ return copy port ]
		return any [
			attempt [ do mold to-string value: copy port ]
			to-integer value ] ]
]

