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
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
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
    <root>
      <xsl:apply-templates select="//tei:div[@type='edition']"/>
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

  <!-- Output a document -->
  <xsl:template name="document">
    <!-- The file path to output -->
    <xsl:param name="href">
      <xsl:value-of select="$dst_dir"/>
      <xsl:value-of select="$src_name"/>
      <xsl:text>/</xsl:text>
      <xsl:call-template name="dst_name"/>
      <xsl:value-of select="$ext"/>
    </xsl:param>
    <xsl:document 
      href="{$href}" 
      omit-xml-declaration="yes" 
      encoding="UTF-8" 
      indent="no"
      >
      <article>
        <xsl:apply-templates/>
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
