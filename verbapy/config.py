"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
"""
import os
import logging

logging.basicConfig(
    # for dev, logging level: debug
    level=logging.DEBUG,
    format='%(module)s %(relativeCreated)d ms. %(levelname)s — %(message)s'
)

# directory from which resolve path to resources like xsl
home =  os.path.dirname(__file__)
