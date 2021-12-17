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
sentences: List[str] = [div]

 
# if you havent downlowaded the model change to "True"
do_download = False
if do_download:
    for dl in download("grc"):
        x = 1


model_name = "grc"
tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None
from pie_extended.models.lasla.imports import get_iterator_and_processor
for sentence_group in sentences:
    iterator, processor = get_iterator_and_processor()
    print(tagger.tag_str(sentence_group, iterator=iterator, processor=processor) )
