REBOL
[
]

do %tokyo-tyrant-driver.r
trace/net off

t: tokyo-tyrant tokyo://moechofe.info:1978

prin "PUT (word!,integer!) = " t/put 'a tmp: 255 print mold equal? tmp t/get/i 'a
prin "PUT (word!,string!) = " t/put 'a tmp: copy "Ceci est une phrase" print mold equal? tmp t/get 'a
prin "PUT (word!,binary!) = " t/put 'a tmp: copy to-binary reduce [ random 255 random 255 ] print mold equal? tmp t/get/b 'a

halt
