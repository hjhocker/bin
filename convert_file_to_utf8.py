import codecs
outfile = codecs.open('bad_encoding.xml', 'w+', "utf-8")

try:
	with codecs.open("utf8_encoding.xml", "r", encoding="iso-8859-1") as f:
		content = f.readlines()	
		content2 = ''.join(content)
		#data = content.encode("iso-8859-1").decode("utf-8")
		#data = content.encode('utf-8','ignore')
		#print (bytes(content2, 'utf-8').decode("utf-8", "replace"))
		a = bytes(content2, 'utf-8').decode("iso-8859-1","ignore")
		b = str(bytes(a,'iso-8859-1'),'utf-8')
#		print (str(bytes(a,'utf-8')))
		outfile.write(b)
except:
	print ("Error during conversion process")

f.close()
outfile.close()
