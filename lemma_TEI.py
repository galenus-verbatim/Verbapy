import os
from bs4 import BeautifulSoup
from xml.etree import ElementTree
from lxml import etree
from typing import List
from pie_extended.cli.utils import get_tagger, get_model, download
from pie_extended.models.grc.imports import get_iterator_and_processor
import pandas as pd 

#improting all the texte from a TEI file
tei_doc = 'test.xml'
with open(tei_doc, 'r', encoding='utf-8') as tei:
    soup = BeautifulSoup(tei, 'lxml')
soup.div.getText()
data=soup.div.getText(separator='\n', strip=True)

sentences: List[str] = [df]
 
#using pie-extended to generate a list of lemma and words
model_name = "grc"
tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
dictionary=list()
for sentence_group in sentences:
    iterator, processor = get_iterator_and_processor()
    for form in tagger.tag_str(sentence_group, iterator=iterator, processor=processor):
        #form is a dictionary, you can call the value you want by key.
        dictionary.append({"form": form['form'], 'lemma': form["lemma"]})
        
#saving the result a csv file
import pandas
df = pandas.DataFrame(dictionary)
df.to_csv("test.csv", sep=';', encoding='utf-8')
