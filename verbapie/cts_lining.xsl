<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php


Specific Galenus, normalize line breaks.

-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  
  xmlns:ext="http://exslt.org/common" 
  extension-element-prefixes="ext"
>
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <!--
  <xsl:strip-space elements="tei:div,tei:head,tei:l,tei:p,tei:quote "/>
  DO NOT <xsl:strip-space elements="*"/>, lose spaces between inlines
  -->
  <xsl:variable name="lf" select="'&#10;'"/> 
  <!-- A handle on each line breaks by its page to count lines -->
  <xsl:key name="line-by-page" match="tei:l | tei:lb[not(ancestor::tei:head)][not(parent::tei:lg[tei:l])]"
    use="generate-id(preceding::tei:pb[1])"/>
  
  <xsl:variable name="lbs" select="count(.//tei:lb[ancestor::tei:p])"/>
  <xsl:variable name="lbn" select="boolean(count(.//tei:lb[@n][ancestor::tei:p]) &gt; ($lbs * 0.7))"/>
  
  <xsl:template match="/">
    <xsl:choose>
      <!-- 70% of <lb/> have @n, do nothing here -->
      <xsl:when test="$lbn = true()">
        <xsl:apply-templates mode="mode1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="lb">
          <xsl:apply-templates mode="mode1"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$lbs &gt; 10">
            <xsl:apply-templates select="ext:node-set($lb)" mode="mode2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$lb"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- First copy all -->
  <xsl:template match="node()|@*" mode="mode1">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="mode1"/>
    </xsl:copy>
  </xsl:template>

  
  <xsl:template match="tei:pb" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy-of select="."/>
    <xsl:variable name="next" select="name(following-sibling::tei:*[1])"/>
    <xsl:choose>
      <xsl:when test="$lbn = true()"/>
      <xsl:when test="ancestor-or-self::tei:lg[tei:l]"/>
      <xsl:when test="$next = 'div'"/>
      <xsl:when test="$next = 'p'"/>
      <xsl:when test="$next = 'l'"/>
      <xsl:when test="$lbs &lt; 10"/>
      <xsl:when test="(following::tei:lb)[1]/preceding-sibling::text()[normalize-space(.) != '']">
        <xsl:value-of select="$lf"/>
        <lb/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:lg[tei:l]/tei:lb" mode="mode1"/>

  <xsl:template match="tei:l" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="mode1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div | tei:head" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="mode1"/>
      <xsl:value-of select="$lf"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:quote[@type='lemma'][@n]" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="$lf"/>
      <lb rend="line"/>
      <xsl:value-of select="$lf"/>
      <lb/>
      <xsl:value-of select="$lf"/>
      <lb/>
      <xsl:apply-templates select="node()" mode="mode1"/>
      <xsl:value-of select="$lf"/>
      <lb rend="line"/>
      <xsl:value-of select="$lf"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:lg" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="mode1"/>
      <xsl:value-of select="$lf"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:p" mode="mode1">
    <xsl:value-of select="$lf"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="name(following-sibling::tei:*[1]) = 'div'"/>
        <xsl:when test="$lbs &lt; 10"/>
        <xsl:when test="name(*[1]) != 'lb' and name(*[1]) != 'pb'">
          <xsl:value-of select="$lf"/>
        </xsl:when>
        <xsl:when test="$lbn = true()"/>
        <xsl:otherwise>
          <lb/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="mode1"/>
      <xsl:if test="$lbs &gt; 10">
        <xsl:value-of select="$lf"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:lb" mode="mode1">
    <xsl:variable name="prev" select="name(preceding-sibling::tei:*[1])"/>
    <xsl:variable name="next" select="name(following-sibling::tei:*[1])"/>
    <xsl:choose>
      <xsl:when test="$prev = 'lg'"/>
      <xsl:when test="$prev = 'p'"/>
      <xsl:when test="$next = 'lg'"/>
      <xsl:when test="$next = 'p'"/>
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Second copy all -->
  <xsl:template match="node()|@*" mode="mode2">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="mode2"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- numbering lines -->
  <xsl:template match="tei:lb[not(@n)] | tei:l[not(@n)]" mode="mode2">
    <xsl:variable name="id" select="generate-id(.)"/>
    <xsl:variable name="pb" select="generate-id(preceding::tei:pb[1])"/>
    <xsl:variable name="n">
      <xsl:for-each select="key('line-by-page', $pb)">
        <xsl:if test="generate-id(.) = $id">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>    </xsl:text>
    <xsl:copy>
      <xsl:if test="string(number($n)) != 'NaN'">
        <xsl:attribute name="n">
          <xsl:value-of select="$n"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="mode2"/>
    </xsl:copy>
  </xsl:template>
    

</xsl:transform>
