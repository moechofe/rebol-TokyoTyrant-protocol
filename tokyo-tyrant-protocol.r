REBOL
[
	Title: "Tokyo Tyrant Protocol"
	Date: 11-Dec-2009
	Version: 0.2.2
	File: %tokyo-tyrant-protocol.r
	Home: http://github.com/moechofe/TokyoTyrant-protocol-for-Rebol
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	Usage: none
	Purpose: {This is a implementation of the ToykyoTyrant protocol for REBOL.}
	Comment: {This is more a sanbox than a fully effective program.}
	History: [
		0.2.2 [11-Dec-2009 {support VSIZ, PUTKEEP, PUTCAT and PUTNR commands.}]
		0.2.1 [10-Dec-2009 {Support PUT and GET commands with integer!, string! and binary! data.}] ]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		license: 'Copyleft
		see-also: [%tokyo-tyrant-driver.r %tokyo-tyrant-test.r] ]
]

make root-protocol
[

	scheme: 'Tokyo
	port-id: 1978
	port-flags: system/standard/port-flags/pass-thru or 32

	to-binary: func [ "Convert value to binary value^/^- Return one or more 32bits binary values"
	value [integer! word! binary! string!] "The value to convert"
	/bytes "Return one 8bits value"
	/byte "Return one or more 8bits value"
	/local result ] [
		switch to-word type? value [
		integer! [ value: system/words/to-binary load rejoin [ "#{" to-hex value "}" ] ]
		word! [ value: system/words/to-binary value ]
		string! [ value: system/words/to-binary system/words/copy value ] ]
		either bytes
		[ while [ all [ greater? length? value 1 zero? first value ] ] [ remove value ] ] [ either byte ;/bytes
		[ while [ greater? length? value 1 ] [ remove value ] return head value ] ;/byte
		[ while [ not zero? modulo length? value 4 ] [ system/words/insert value #{00} ] ] ]
		return head value ]

	command: context
	[	magic: #{c8}

		put: func [ "Send a PUT, PUTKEEP ot PUTCAT command to the server and return TRUE if success."
		port [port!] "The port connected to the server."
		key [any-word!] "The key."
		value "The value"
		/keep /k "Send a PUTKEEP command instead of PUT."
		/concat /cat /c "Send a PUTCAT command instead of PUT."
		/noresponse /nr "Send a PUTNR command instead of PUT."] [
			write-io port rejoin [
				magic either any [keep k] [#{11}] [ either any [concat cat c] [#{12}] [ either any [noresponse nr] [#{18}] [#{10}] ] ] ;magic:2
				to-binary length? key: to-binary/bytes to-word key ;ksiz:4
				to-binary length? value: to-binary/bytes value ;vsiz:4
				key ;kbuf:*
				value ] ;vbuf:*
			either any [ noresponse nr ] [ true ]
			[ zero? to-integer to-binary/byte read-io port 1 ] ] ;code:1

		get: func [ "Send a GET command to the server and return TRUE if success. Place the result in the buffer."
		port [port!] "The port connected to the server."
		key [any-word!] "The key." ] [
			write-io port rejoin [
				magic #{30} ;magic:2
				to-binary length? key: to-binary/bytes to-word key ;ksiz:4
				key ] ;kbuf:*
			either zero? to-integer to-binary/byte read-io port 1 ;code:1
			[ port/state/outBuffer: system/words/copy to-binary/bytes read-io port ;vsiz:4
			  to-integer read-io port 4 true ] ;vbuf:*
			[ false ] ]

		vsiz: func [ "Send a VSIZ command to the server and return TRUE is success. Place the result in the buffer."
		port [port!] "The port connected to the server."
		key [any-word!] "The key." ] [
			write-io port rejoin [
				magic	#{38} ;magic:2
				to-binary length? key: to-binary/bytes to-word key ;ksiz:4
				key ] ;kbuf:*
			either zero? to-integer to-binary/byte read-io port 1 ;code:1
			[ port/state/outBuffer: system/words/copy to-binary/bytes read-io port 4 true ] ;vsiz:4
			[ false ] ]

	];command

	write-io: func [ "Write a command to the server."
	port [port!] "The port connected to the server."
	command [binary!] "The packed command." ] [
		net-utils/net-log reform [ "TOKYO write:" length? command "bytes ;" command ]
		system/words/write-io port/sub-port command length? command ]

	read-io: func [ "Read a result fropm the server."
	port [port!] "The port connected to the server."
	length [integer!] "The length of data to retrieve."
	/local buffer result ] [ result: system/words/copy ""
		while [ positive? length ] [
			buffer: system/words/copy ""
			system/words/read-io port/sub-port buffer length
			length: subtract length length? buffer
			append result buffer ]
		net-utils/net-log reform [ "TOKYO read:" length? result "bytes ;" to-binary/bytes result ]
		to-binary result ]

	insert: func [ "Send command to the port connected with the server."
	port [port!] "The port connected to the server."
	data [string! block!] {The rules
	 PUT = [key: value]
	 PUTKEEP = [attempt key: value]
	 PUTCAT = [append key: value]
	 GET = [:key]
	 VSIZ = [length? :key]}
	/local key value ] [ if block? data [ parse data [ some [

		;PUTKEEP
		'attempt set key [set-word!] set value [integer! | any-string!]
			(if not command/put/keep port key value [throw make error! "error when keep puting"]) |

		;PUTCAT
		'append set key [set-word!] set value [integer! | any-string!]
			(if not command/put/cat port key value [throw make error "error when concat puting"]) |

		;VSIZ
		'length? set key [get-word!]
			(if not command/vsiz port key [throw make error! "error when vsizing"]) |

		;PUT
		set key [set-word!] set value [integer! | any-string!]
			(if not command/put port key value [throw make error! "error when puting"]) |

		; GET
		set key [get-word!]
			(if not command/get port key [throw make error! "error when getting"]) ] ] ] ]

	copy: func [ "Return buffered received data from the port connected with the server."
	port [port!] "The port connected to the server."
	/result	] [ port/state/outBuffer ]

	net-utils/net-install TOKYO self 1978
]
