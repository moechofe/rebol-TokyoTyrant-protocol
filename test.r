REBOL
[
	Title: "Tokyo Tyrant Protocol/Driver test"
	Date: 17-Jan-2011
	Version: 0.4.0
	File: %tokyo-tyrant-test.r
	Home: http://github.com/moechofe/TokyoTyrant-protocol-for-Rebol
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	Needs: [%tokyo-tyrant-protocol.r %tokyo-tyrant-driver.r]
	Usage: none
	Purpose: {This is a script to test the implementation of the ToykyoTyrant protocol via the TykyoTyrant driver.}
	Comment: {This is more a sanbox than a fully effective program.}
	History: [
		0.4.0 [17-Jan-2011 {Restarting all tests.}]
		0.3.0 [15-Jan-2011 {Add test for PUTNR. Only use query. Remove driver.}]
		0.2.1 [12-Dec-2009 {Add test for the query style.}]
		0.1.4 [11-Dec-2009 {Add test for VSIZ and PUTCAT.}]
		0.1.3 [10-Dec-2009 {Add test for PUT and GET integer!, string!, binary!.}] ]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		tested-under: [core 2.7.8.4.2 Ubuntu]
		license: 'Copyleft
		see-also: [%tokyo-tyrant-protocol.r] ]
]

do %tokyo-tyrant-protocol.r

; Launching the server :
; on-memory hash database = ttserver *
; on-memory tree database = ttserver +
; hash database = ttserver <path/file>.tcf
; B+ tree database = ttserver <path/file>.tcb
; fixed-length database = ttserver <path/file>.tcf
; table database = ttserver <path/file>.tct

{
tt1: tokyo tokyo://localhost:1978
tt1 compose [
	bitset: (charset [#"a" - #"z"])
	binary: #{3A18427F 899AEFD8}
	block: [123 data "hi"]
	char: #"c"
	date: 9-Jan-1979
	decimal: +100'234'562.3782e1
	email: luke@rebol.com
	file: %file.r
	;function: (does [])
	get-word: :word
	hash: (make hash! ['ha "ha" 'sh "sh"])
	integer: -123'456
	image: (make image! 4x2)
	issue: #888-555-1212
	lit-path: 'l/i/t
	lit-word: 'lit
	logic: true
	op: =
	pair: 4x2
	path: p/a/t/h
	refinement: /refine
	set-path: p/a/t/h:
	set-word: word:
	string: "chocolat"
	tag: <html>
	time: 09:14
	tuple: 127.0.0.1
	url: http://test:test@localhost
	word: 'word::
]
}

tt1: tokyo/table tokyo://localhost
tt1 compose [ t: (context [test: "test"]) ]

halt

print mold equal? [ 123 "chocolat" #{c810} ] tt1 [ integer! :a string! :b binary! :c ]

prin "PUT/GET (path!) = "
tt1 [d: a/b/c/d/e]
print mold equal? 'a/b/c/d/e first tt1 [ :d ]

prin "PUT/GET/PUTKEEP/GET (string!) = "
tt1 [ e: 456 ]
print mold equal? 456 first tt1 [ integer! :e ]
print mold error? try [	tt1 [ attempt e: 789 ] ]
print mold equal? 456 first tt1 [ integer! :e ]

prin "PUTNR/GET (string!) = "
print mold equal? "fallabs" first tt1 [ quick f: "fallabs" string! :f ]

halt
