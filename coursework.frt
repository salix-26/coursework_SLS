( a -- 1\0 )
: is-even
	2 % if 0 else 1 then ;

( a -- a*a )
: sqr
	dup * ;

( a -- 1\0 )
: is-prime
	dup 2 <
	if drop 0 else 
		dup 2 = 
		if drop 1 else 
			1
			repeat
				1 + 2dup % if 0 else 1 then
				if 2drop 0 exit else 
					2dup sqr < 
					if 2drop 1 exit else 0 then
				then
			until 
		then
	then ;

( a -- addr_result )
: allot-prime-result
	is-prime 1 allot 2dup ! swap drop ;

( addr_1 addr_2 -- addr_3 )
: concat
	swap 2dup count swap count + 1 + heap-alloc
	( addr_2 addr_1 addr_3 )
	swap 2dup string-copy count over +
	rot string-copy ;

(a -- 1)
: collatc
	repeat
		dup is_even if 
			2 /
		else 
			3 * 1 + 
		then dup dup . ."  "
		1 =
	until
;