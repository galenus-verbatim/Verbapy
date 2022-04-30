<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php

A too

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ti="http://chs.harvard.edu/xmlns/cts"
  exclude-result-prefixes="tei ti"
>
  <xsl:output encoding="UTF-8" method="text"/>
  <!-- Source file name (without extension) -->
  <xsl:param name="src_name"/>
  
  
  <xsl:template match="/*">
    <root>
      <xsl:text>  "</xsl:text>
      <xsl:value-of select="$src_name"/>
      <xsl:text>":{
</xsl:text>
      <!--
      https://iiif.archivelab.org/iiif/hapantaoperaomni14galeuoft$110/full/full/0/default.jpg
      -->
      <xsl:variable name="ed" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>
      <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor = 'Karl Gottlob Kühn'">
        <xsl:text>    "ed":{
      "name": "Kühn", "vol":"</xsl:text>
        <xsl:value-of select="$ed"/>
        <xsl:text>", "p1":4,
      "url":"https://iiif.archivelab.org/iiif/hapantaoperaomni</xsl:text>
        <xsl:value-of select="$ed"/>
        <xsl:text>galeuoft$::/full/full/0/default.jpg"
    }</xsl:text>
      </xsl:if>
      <!--
      <xsl:variable name="ed1" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='ed1vol']"/>
      <xsl:variable name="ed2" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='ed2vol']"/>
      <xsl:if test="$ed1">
        <xsl:text>    "ed1":{
      "vol":"</xsl:text>
        <xsl:value-of select="$ed1"/>
        <xsl:text>",
      "url":"https://www.biusante.parisdescartes.fr/histmed/medica/page?00013x0</xsl:text>
        <xsl:value-of select="$ed1"/>
        <xsl:text>&amp;p={0}",
      "p1":1
    }</xsl:text>
        <xsl:if test="$ed2">,
</xsl:if>
      </xsl:if>
      <xsl:if test="$ed2">
        <xsl:text>    "ed2":{
      "vol":"</xsl:text>
        <xsl:value-of select="$ed2"/>
        <xsl:text>",
      "url":"https://www.biusante.parisdescartes.fr/histmed/medica/page?00039x0</xsl:text>
        <xsl:value-of select="$ed2"/>
        <xsl:text>&amp;p={0}",
      "p1":1
    }</xsl:text>
    </xsl:if>
    -->
      <xsl:text>
  },</xsl:text>
    </root>
  </xsl:template>


</xsl:transform>
