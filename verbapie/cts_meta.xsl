<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php


Split a single TEI file in a multi-pages site

TODO : prev / next and lots of other item metadata

-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ti="http://chs.harvard.edu/xmlns/cts"
  exclude-result-prefixes="tei ti"
>
  <xsl:import href="cts_chapters.xsl"/>
  <xsl:output encoding="UTF-8" method="text"/>
  <xsl:param name="iter"/>
  
  <xsl:template match="/*">
    <root>
      <xsl:value-of select="$iter"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$auctor"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$titulus"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$annuspub"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$editor"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$volumen"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$pagde"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$pagad"/>
    </root>
  </xsl:template>


</xsl:transform>
