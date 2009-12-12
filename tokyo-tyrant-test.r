REBOL
[
	Title: "Tokyo Tyrant Protocol/Driver test"
	Date: 12-Dec-2009
	Version: 0.2.1
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
		0.2.1 [12-Dec-2009 {Add test fot the query style.}]
		0.1.4 [11-Dec-2009 {Add test for VSIZ and PUTCAT.}]
		0.1.3 [10-Dec-2009 {Add test for PUT and GET integer!, string!, binary!.}] ]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		license: 'Copyleft
		see-also: [%tokyo-tyrant-driver.r %tokyo-tyrant-protocol.r] ]
]

do %tokyo-tyrant-driver.r
trace/net off
;trace/net on

; Launching the server :
; on-memory hash database = ttserver *
; on-memory tree database = ttserver +
; hash database = ttserver <path/file>.tcf
; B+ tree database = ttserver <path/file>.tcb
; fixed-length database = ttserver <path/file>.tcf
; table database = ttserver <path/file>.tct

;delete this
;t: tokyo-tyrant tokyo://moechofe.info:1978
;prin "object style PUT/GET (integer!) = " t/put 'a tmp: 255 print mold equal? tmp t/get 'a
;prin "object style PUT/GET (string!) = " t/put 'a tmp: copy "Ceci est une phrase" print mold equal? tmp t/get 'a
;prin "object style PUT/GET (binary!) = " t/put 'a tmp: copy to-binary reduce [ random 255 random 255 ] print mold equal? tmp t/get/b 'a
;prin "object style PUT/VSIZ (string!) = " t/put 'a tmp: copy "123" print mold equal? t/length? 'a length? tmp
;prin "object style PUT/PUTCAT/GET (string!) = " t/put 'a "Prome" t/put/cat 'a "nade" print mold equal? "Promenade" t/get 'a

tt1: tokyo tokyo://moechofe.info:1978

prin "query style PUT/GET (integer!,string!,binary!) = " tt1 [ a: 123 b: "chocolat" c: #{c810} ] print mold equal? [ 123 "chocolat" #{c810} ] tt1 [ integer! :a string! :b binary! :c ]
prin "query style PUT/GET (path!) = " tt1 [d: a/b/c/d/e] print mold equal? 'a/b/c/d/e first tt1 [ :d ]

;FIXME need OUT
;prin "PUTKEEP (integer!) = " t/put/keep 'a 61

halt
