<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php


Split a single TEI file in a multi-pages site

-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:strip-space elements="*"/>
  <xsl:output indent="yes" encoding="UTF-8" method="html" />

  <xsl:template match="tei:*">
    <xsl:message terminate="yes">
      <xsl:text>[cts_html.xsl] </xsl:text>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:text> TEI tag not yet handled</xsl:text>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:teiHeader"/>

  <xsl:template match="tei:TEI | tei:text | tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:add">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:author">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:bibl">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:choice">
    <xsl:choose>
      <xsl:when test="tei:supplied">
        <xsl:apply-templates select="tei:supplied"/>
      </xsl:when>
      <xsl:when test="tei:corr">
        <xsl:apply-templates select="tei:corr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:cit">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:date">
    <span class="{local-name()}" rel="{@notBefore}-{@notAfter}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:del"/>
  
  <xsl:template match="tei:desc">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:div">
    <xsl:text>&#10;</xsl:text>
    <section>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </section>
  </xsl:template>
  
  <xsl:template match="tei:figDesc">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:figure">
    <xsl:text>&#10;</xsl:text>
    <figure>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </figure>
  </xsl:template>  
  
  
  <xsl:template match="tei:forename">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <!-- Graphic founds seem links 
  <graphic url="https://babel.hathitrust.org/cgi/pt?id=hvd.hxpp8p;view=2up;seq=514"/>
  -->
  <xsl:template match="tei:graphic">
    <xsl:text>&#10;</xsl:text>
    <a href="{@url}">
      <xsl:text>[p. </xsl:text>
      <xsl:value-of select="(preceding::tei:pb)[1]/@n"/>
      <xsl:text>]</xsl:text>
    </a>
  </xsl:template>
  
  
  <xsl:template match="tei:gap"/>
  
  <xsl:template match="tei:head">
    <xsl:text>&#10;</xsl:text>
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <!-- line identifier -->
  <xsl:template match="tei:lb" name="lb">
    <xsl:param name="n">
      <xsl:choose>
        <xsl:when test="self::tei:lb and @n != ''">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="line"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:text>&#10;</xsl:text>
    <xsl:variable name="page">
      <xsl:call-template name="data-page"/>
    </xsl:variable>
    <xsl:if test="$n != ''">
      <span class="lb">
        <xsl:attribute name="data-page">
          <xsl:value-of select="$page"/>
        </xsl:attribute>
        <xsl:attribute name="data-line">
          <xsl:value-of select="$n"/>
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:text>p</xsl:text>
          <xsl:value-of select="$page"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$n"/>
        </xsl:attribute>
      </span>
    </xsl:if>
  </xsl:template>
  

  <xsl:template match="tei:l">
    <xsl:text>&#10;</xsl:text>
    <div class="l">
      <xsl:call-template name="lb"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <xsl:text>&#10;</xsl:text>
    <label>
      <xsl:apply-templates/>
    </label>
  </xsl:template>
  
  <xsl:template match="tei:label/tei:num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:item">
    <xsl:text>&#10;</xsl:text>
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <xsl:template match="tei:list">
    <xsl:text>&#10;</xsl:text>
    <ul>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </ul>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']">
    <xsl:text>&#10;</xsl:text>
    <table>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </table>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item">
    <xsl:text>&#10;</xsl:text>
    <tbody>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </tbody>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item[1]">
    <xsl:text>&#10;</xsl:text>
    <thead>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </thead>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']">
    <xsl:text>&#10;</xsl:text>
    <tr>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </tr>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']/tei:item">
    <xsl:choose>
      <xsl:when test="tei:label and count(*) = 1 and not(text()[normalize-space(.) != ''])">
        <xsl:text>&#10;</xsl:text>
        <th>
          <xsl:apply-templates select="tei:label/node()"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>
        <td>
          <xsl:apply-templates/>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lg">
    <xsl:text>&#10;</xsl:text>
    <div class="lg">
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:milestone">
    <xsl:param name="class"/>
    <xsl:param name="diff"/>
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat('milestone ', @unit, ' ', $class))"/>
      </xsl:attribute>
      <xsl:if test="@n">
        <xsl:attribute name="data-n">
          <xsl:choose>
            <xsl:when test="string($diff) != ''">
              <xsl:value-of select="number(@n) + number($diff)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@n"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@unit">
        <xsl:attribute name="data-unit">
          <xsl:value-of select="@unit"/>
        </xsl:attribute>
      </xsl:if>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:name">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  

  <!-- Check if notes are interesting and find a good way to display and index -->
  <xsl:template match="tei:note">
    <xsl:text>&#10;</xsl:text>
    <xsl:comment>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt; </xsl:text>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="tei:p">
    <xsl:text>&#10;</xsl:text>
    <p>
      <xsl:choose>
        <xsl:when test="not(tei:lb)"/>
        <xsl:when test="tei:lb[@n]"/>
        <!-- text between <p> and first <lb/> -->
        <xsl:when test="tei:lb[1]/preceding-sibling::text()[normalize-space(.)] != ''">
          <xsl:call-template name="lb"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <xsl:template match="tei:orgName">
    <a class="{local-name()}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="tei:orig">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Get page number -->
  <xsl:template name="data-page">
    <xsl:variable name="n">
      <xsl:choose>
        <xsl:when test="self::tei:pb">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="preceding::tei:pb[1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$n = ''"/>
      <xsl:when test="contains($n, '.')">
        <xsl:value-of select="substring-after($n, '.')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:param name="class"/>
    <xsl:text>&#10;</xsl:text>
    <!-- Do not try to count <pb/> if no @n -->
    <xsl:variable name="n">
      <xsl:call-template name="data-page"/>
    </xsl:variable>
    <span class="pb">
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat('pb ', $class))"/>
      </xsl:attribute>
      <xsl:if test="$n != ''">
        <xsl:attribute name="data-page">
          <xsl:value-of select="$n"/>
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:text>p</xsl:text>
          <xsl:value-of select="$n"/>
        </xsl:attribute>
      </xsl:if>
    </span>
    <!-- text between <p> and first <lb/> -->
    <xsl:choose>
      <!-- Do not add a line break for first page before a section -->
      <xsl:when test="$class = 'page1'"/>
      <!-- no line break for first line -->
      <xsl:when test="(following::tei:lb)[1]/preceding-sibling::text()[normalize-space(.) != '']">
        <xsl:call-template name="lb">
          <xsl:with-param name="n" select="1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:persName">
    <a class="{local-name()}" type="{@type}" rel="{@nymRef}">
    <a href="http://cahal.me/italikos/tablepers">
      <xsl:apply-templates/>
    </a>
    </a>
  </xsl:template>
  
  <xsl:template match="tei:cit">
  <i>
    <a href="http://cahal.me/italikos/tablequote">
      <xsl:apply-templates/>
    </a>
  </i>
  </xsl:template>
  
  <xsl:template match="tei:placeName">
    <a class="{local-name()}" type="{@type}" rel="{@nymRef}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="tei:q">
    <q class="q">
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <xsl:template match="tei:rs">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <!-- Will produce bad html for p/quote -->
  <xsl:template match="tei:quote">
    <xsl:choose>
      <!-- level block -->
      <xsl:when test="not(ancestor::tei:p) or parent::tei:div">
        <xsl:text>&#10;</xsl:text>
        <blockquote class="quote">
          <xsl:apply-templates/>
          <xsl:text>&#10;</xsl:text>
        </blockquote>
      </xsl:when>
      <xsl:otherwise>
        <q class="{local-name()}">
          <xsl:apply-templates/>
        </q>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:roleName">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:state">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:supplied">
      <a class="{@reason}"><xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template match="tei:surname">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:title">
    <em class="{local-name()}">
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  
</xsl:transform>
