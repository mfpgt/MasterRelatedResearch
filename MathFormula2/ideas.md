Priming
=======

Main
----

condition   prime        target       scrambledtarget

sametree    a * sin(b)   x + ln(y)     x)ln+y(
sametree?   sin(a) * b   x + ln(y)     ln) xy (
diff	    sin(a * b)   x + ln(y)      

sametree    sin(a + b)   ln(x * y)     
diff	    a + sin(b)   ln(x * y)

sametree    sin(a) * b   ln(x) + y
sametree?   a * sin(b)   ln(x) + y
diff   	    sin(a * b)	 ln(x) + y


-----------------------

sametree    sin(y)      log(x)        x)(log
diff2       (x + y)     log(x)        )x(log


sametree    (a * b)    	(x + y)       y)x(+   
diff        sin(a)    	(x + y)       )x(y+  


Confound: sametree conditions have () at the same place 

----------------------------------


Bloc Design version
-------------------


keep surface      x+ln(y) ln(x+y)  ln(y)+x ln(y+x)
keep hierarchy    x+log(y) a*cos(b) z^exp(t) w-sin(r)
keep both         x+ln(y) x+ln(y) x+ln(y) x+ln(y) 
keep none	  x+ln(y) cos()


+ scrambled  






Variant2: 
--------

condition   prime     target

sameall	    x+ln(y)   x+ln(y)
samelex	    ln(x+y)   x+ln(y)
sametree    a.sin(b)  x+ln(y)
diff	    sin(a+b)  x+ln(y)

sameall	    ln(x+y)   ln(x+y)
samelex	    x+ln(y)   ln(x+y)
sametree    sin(a.b)  ln(x+y)
diff	    a+sin(b)  ln(x+y)

	    



