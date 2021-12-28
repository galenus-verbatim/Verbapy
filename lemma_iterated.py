#import all necessary modules
import os
from bs4 import BeautifulSoup
from xml.etree import ElementTree
from lxml import etree
from typing import List
from pie_extended.cli.utils import get_tagger, get_model, download
from pie_extended.models.grc.imports import get_iterator_and_processor
from bs4 import BeautifulSoup
import os
from os.path import dirname, join
import csv

directory=("test") # location of Epidoc files on the drive

for infile in os.listdir(directory):
    filename=join(directory, infile)
    indata=open(filename,"r", encoding="utf-8", errors="ignore") 
    contents = indata.read()
    name="" #using beatiful soup or other to extract the xml value title or chapter title
    soup = BeautifulSoup(contents,'xml') 
    text_data=soup.div.getText(separator='\n', strip=True) #get the text from the div tag
    sentences: List[str] = [text_data]
    model_name = "grc"
    tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
    dictionary=list()
    for sentence_group in sentences:
        iterator, processor = get_iterator_and_processor()
        for form in tagger.tag_str(sentence_group, iterator=iterator, processor=processor):
            dictionary.append({"form": form['form'], 'lemma': form["lemma"], 'pos': form["pos"]})
    keys = dictionary[0].keys()
    a_file = open(f"{name}.csv", "w", encoding='utf-8')
    dict_writer = csv.DictWriter(a_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(dictionary)
    a_file.close()
    
