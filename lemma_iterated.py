from cltk import NLP
from bs4 import BeautifulSoup
import os
from os.path import dirname, join

directory=("TEI") # location of XML files on local drive

for infile in os.listdir(directory):
    filename=join(directory, infile)
    indata=open(filename,"r", encoding="utf-8", errors="ignore") 
    contents = indata.read()
    soup = BeautifulSoup(contents,'xml') 
    df2=soup.div.getText(separator='\n', strip=True)#get the text from the div tag
    cltk_nlp_grc = NLP(language="grc")
    %time cltk_doc_grc = cltk_nlp_grc.analyze(text=df2)
    df2=cltk_doc_grc.stanza_doc.to_dict()
    print(df2)

#Problems with pie-extended need to replace cltk lemmas with that of pie 
#Other problem the saving, files perfectly ordered with an id but in what format and how to save them?
