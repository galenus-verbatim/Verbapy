# Verbapy
 Python code that lemmatise files in the TE.I-Epidoc format using the pie-extened tool returning a PHP structure of tokens attached to a lemm.
 
# Windows 10

A python package suppose usually that you have already a running Python installation, but if not, and if you are on windows, the system will not help vou to make good choices like linux. Here some hints may save you some time, at least at date (2022-01).

* Install [Python 3.8](https://www.python.org/downloads/release/python-380/), don’t try to be newer than others. Verbapy is a Digital Humanity library, it requires research libs. Researchers are not paid to dicover new bugs on new versions of Python. Tick NOW (much more easier to explain than after) **Add Python 3.8 to PATH**, and **pip**.
* Don’t try to install python globally on windows (ex: ~~C:\Program Files\Python38~~). This good practice as a linux admin will run you in "deps hell" with windows.
* Verify thoses commands in your preferred console
<br>`> python -V`
<br>_Python 3.8.10_
<br>`> where python`
<br>_C:\Users\{YOU}\AppData\Local\Programs\Python\Python38\python.exe_
* Update pip (the python package installer)
<br>`> pip install --user --upgrade pip`
<br>(--user should not be required, but sometimes, it seems)
* Now you should have a Python correct to work, try to install an omportant requirement
<br>`> pip install pie-extended`
