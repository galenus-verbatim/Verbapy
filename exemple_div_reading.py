"""Code to aquired a string object from a div in a tei file and obtaining a file of the lemmas"""

from bs4 import BeautifulSoup
from xml.etree import ElementTree
from lxml import etree
from typing import List
from pie_extended.models.grc.imports import get_iterator_and_processor

#get the file tei file and turn the text into a string
tei_doc = 'file.xml'
with open(tei_doc, 'r', encoding='utf-8') as tei:
    soup = BeautifulSoup(tei, 'lxml')  
div=soup.div.getText(separator=' ', strip=True)
