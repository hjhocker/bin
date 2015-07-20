#!/usr/bin/python

import sys

try:
	with open('iso_conversion.py') as inp, open('test.py', 'w+') as out:
	    txt = inp.read()
	    txt = txt.replace('\r\n', '\n')
	    out.write(txt)
except:
	print "There was an error converting from Dos to Unix new lines!"
	sys.exit(1)

sys.exit(0)
