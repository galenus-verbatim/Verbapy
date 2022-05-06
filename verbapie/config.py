"""
Part of verbapie https://github.com/galenus-verbatim/verbapie
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
"""
import os
import logging

logging.basicConfig(
    # for dev, logging level: debug
    level=logging.DEBUG,
    format='%(module)s %(asctime)s %(levelname)s — %(message)s',
    datefmt='%H:%M:%S'
)
