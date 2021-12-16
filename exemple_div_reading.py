"""Code to aquired a string object from a div in a tei file"""

from lxml import etree
 
namespaces = {'tei':'http://www.tei-c.org/ns/1.0'} # referencing the TEI namespace in lxml

xp_p = "xpath"  #the Xpath we are targeting

tree = etree.parse("file.xml")

div = tree.xpath(xp_p, namespaces=namespaces)

text = ' '.join(x.strip() for x in par.xpath('.//text()'))
print(text) # string file containing all the text within the XML element

