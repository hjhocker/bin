#!/usr/bin/python

import sys

try: 
	with open('input.txt') as inp, open('output.txt', 'w+') as out:
	    txt = inp.read()
	    txt = txt.replace('\n', '\r\n')
	    out.write(txt)
except:
	print "There was an error converting Unix to Dos newlines!"
	sys.exit(1)

sys.exit(0)
