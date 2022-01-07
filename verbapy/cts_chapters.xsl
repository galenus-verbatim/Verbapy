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
  exclude-result-prefixes="tei"
>
  <xsl:import href="cts_html.xsl"/>
  <xsl:output encoding="UTF-8" method="text"/>
  <!-- Required, folder where to project the generated files -->
  <xsl:param name="dst_dir"/>
  <!-- Source file name (without extension) -->
  <xsl:param name="src_name"/>
  <!-- file extension to output -->
  <xsl:variable name="ext">.html</xsl:variable>
  
  <xsl:template match="/*">
    <xsl:if test="normalize-space($dst_dir) = ''">
      <xsl:message terminate="yes">[cts_chapter.xsl] $dst_dir param is required to output files</xsl:message>
    </xsl:if>
    <xsl:if test="normalize-space($src_name) = ''">
      <xsl:message terminate="yes">[cts_chapter.xsl] $src_name param is required to output files</xsl:message>
    </xsl:if>
    <xsl:if test="count(//tei:div[@type='edition']) != 1">
      <xsl:message terminate="yes">[cts_chapter.xsl] 0 or more than one &lt;div type="edition"&gt;, not expected</xsl:message>
    </xsl:if>
    <!-- first dic, file meta, and ordered array of chapters -->
    <root xml:space="preserve">[
    {
        "identifier": "<xsl:value-of select="$src_name"/>",
        "title": "<xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>",
        "editor": "<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/>",
        "vol": "<xsl:value-of    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>",
        "from": "<xsl:value-of   select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@from"/>",
        "to": "<xsl:value-of     select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@to"/>",
        "date": "<xsl:value-of   select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date"/>"
    }<xsl:apply-templates select="//tei:div[@type='edition']"/>
]
</root>
  </xsl:template>

  <!-- chaptering -->
  <xsl:template match="tei:div[@type='edition']">
    <xsl:choose>
      <xsl:when test="tei:div[@type='textpart'][@subtype='work']">
        <xsl:for-each select="tei:div[@type='textpart'][@subtype='work']">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- chapters may be children of book -->
      <xsl:when test=".//tei:div[@type='textpart'][@subtype='chapter']">
        <xsl:for-each select=".//tei:div[@type='textpart'][@subtype='chapter']">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="tei:div[@type='textpart'][@subtype='section'][@n]">
        <xsl:for-each select="tei:div">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- A book with no chapters -->
      <xsl:when test="tei:div[not(tei:div)][@n]">
        <xsl:for-each select="tei:div">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">No chapters found</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <!-- Calculate the destination file name of a chapter, maybe used for  -->
  <xsl:template name="dst_name">
    <xsl:for-each select="ancestor-or-self::tei:div">
      <xsl:choose>
        <xsl:when test="starts-with(@n, 'urn:cts:greekLit:')">
          <xsl:value-of select="substring-after(@n, 'urn:cts:greekLit:')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@n"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">.</xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="text-before">
    <xsl:param name="before"/>
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="count($before|.) = 1"/>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:call-template name="text-before">
            <xsl:with-param name="before" select="$before"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="n"/>
    </xsl:for-each>
  </xsl:template>

  <!-- Output a document -->
  <xsl:template name="document">
    <xsl:param name="dst_name">
      <xsl:call-template name="dst_name"/>
    </xsl:param>
    <!-- The file path to output -->
    <xsl:param name="href">
      <xsl:value-of select="$dst_dir"/>
      <xsl:value-of select="$src_name"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="$dst_name"/>
      <xsl:value-of select="$ext"/>
    </xsl:param>
    <!-- get text before first page break in section -->
    <xsl:variable name="text-before">
      <xsl:call-template name="text-before">
        <xsl:with-param name="before" select="(.//tei:pb)[1]"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="from">
      <xsl:choose>
        <!-- section is starting in middle of a page -->
        <xsl:when test="$text-before != ''">
          <xsl:value-of select="preceding::tei:pb[1]/@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="(.//tei:pb)[1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <chapter xml:space="preserve">,
    {
        "identifier": "<xsl:value-of select="$dst_name"/>",
        "from": "<xsl:value-of select="$from"/>",
        "to": "<xsl:value-of select="(.//tei:pb)[last()]/@n"/>",
        "title": "<xsl:choose xml:space="default">
          <xsl:when test=".//tei:head">
            <xsl:value-of select="normalize-space(.//tei:head)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="str" select="normalize-space(.)"/>
            <xsl:value-of select="substring($str, 1, 50)"/>
            <xsl:value-of select="substring-before(substring($str, 50), ' ')"/>
            <xsl:text> […]</xsl:text>
          </xsl:otherwise>
    </xsl:choose>"
    }</chapter>
    <xsl:document 
      href="{$href}" 
      omit-xml-declaration="yes" 
      encoding="UTF-8" 
      >
      <article>
        <xsl:if test="$text-before != ''">
          <xsl:apply-templates select="(preceding::tei:pb)[last()]">
            <xsl:with-param name="class">pbprev</xsl:with-param>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:text>&#10;</xsl:text>
      </article>
    </xsl:document>
  </xsl:template>
  
  
  <!-- For debug, a linear xpath for an element -->
  <xsl:template name="idpath">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:if test="count(../*[name()=name(current())]) &gt; 1">
        <xsl:text>[</xsl:text>
        <xsl:number/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  

</xsl:transform>
