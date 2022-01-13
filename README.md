# Verbapie
 Python code to produce an SQLite database, ready to offer lemma search on the web for Epidocs XML greek documents. 

## Caution

This code is at a very early stage and is not ready for distribution. It works, at least for the developpers. Fill an issue upper if you want to work with the developpers to make it work for your corpus.

## Requirements

* A corpus of greek texts conforming to the tei-epidoc.rng schema. Example
<br>…/myprojects$ `git clone https://github.com/OpenGreekAndLatin/First1KGreek.git`
* A python 3 installation, >= 3.6, < 3.10 (at 2022-01)
<br>ubuntu.21.10:…$ `python3 -V`
<br>_Python 3.9.7_
* The pip packager
* The Python libxml wrapper for XSLT transformations
<br>ubuntu.21.10:…$ `sudo pip3 install lxml`
* [pie_extended](https://github.com/hipster-philology/nlp-pie-taggers), the lemmatizer from Thibault Clérice, with the greek model, takes a while, and can fall in a depedencies hell if you have some required packages installed in other versions than desired by pie. This scenario has worked (Cython allow scikit to recompile itself)
<br>ubuntu.21.10:…$ `sudo pip3 install Cython`
<br>ubuntu.21.10:…$ `sudo pip3 install pie-extended`
<br>ubuntu.21.10:…$ `pie-extended download grc`

## Usage

Not stable for now.

## Optional, Cuda with nvidia graphic cards

For a faster lemmatisation, if you have an Nvidia graphic card, you can use it for work (and not only gaming). Install the latest Nvidia pilots, and the Cuda toolkit to use the processors of your graphic card, ant install the python lib 
<br>ubuntu.21.10:~$ `sudo apt install nvidia-cuda-toolkit`

Installation for Windows
* Install [nvidia cuda pilots](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)
* Install [PyTorch 1.7.1](https://pytorch.org/get-started/previous-versions/#linux-and-windows-7), lemmatization with papie 0.3.9 requires torch<=1.7.1,>=1.3.1, chose the torch version according to your cuda pilot version

## Install Python for Windows 10

A python package suppose usually that you have already a running Python installation, but if not, and if you are on windows, the system will not help vou to make good choices like linux. Here some hints that may save you time, at least at date (2022-01).

* Install [Python 3.8](https://www.python.org/downloads/release/python-380/), don’t try to be newer than others. Verbapy is a Digital Humanity library, it requires research libs. Researchers are not paid to dicover new bugs on new versions of Python. Tick NOW (much more easier to explain than after) **Add Python 3.8 to PATH**, and **pip**.
* Don’t try to install python globally on windows (ex: ~~C:\Program Files\Python38~~). This good practice as a linux admin will run you in "deps hell" with windows.
* Verify thoses commands in your preferred console
<br>win10> `python -V`
<br>_Python 3.8.10_
<br>win10> `where python`
<br>_C:\Users\{YOU}\AppData\Local\Programs\Python\Python38\python.exe_
* Update pip (the python package installer)
<br>win10> `pip install --user --upgrade pip`
<br>(--user should not be required, but sometimes, it seems)
* Now you should have a Python correct to work, try to install an omportant requirement
<br>win10> `pip install lxml`
