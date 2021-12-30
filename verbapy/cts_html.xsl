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
  <xsl:output indent="no" encoding="UTF-8" method="xml" />
  <xsl:strip-space elements="tei:div"/>

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

  <xsl:template match="tei:add">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:del"/>
  
  <xsl:template match="tei:div">
    <section>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="tei:figDesc">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:figure">
    <figure>
      <xsl:apply-templates/>
    </figure>
  </xsl:template>  
  
  <!-- Graphic founds seem links 
  <graphic url="https://babel.hathitrust.org/cgi/pt?id=hvd.hxpp8p;view=2up;seq=514"/>
  -->
  <xsl:template match="tei:graphic">
    <a href="{@url}">
      <xsl:text>[p. </xsl:text>
      <xsl:value-of select="preceding::tei:pb/@n"/>
      <xsl:text>]</xsl:text>
    </a>
  </xsl:template>
  
  
  <xsl:template match="tei:gap"/>
  
  <xsl:template match="tei:head">
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="tei:lb">
    <br class="cts">
      <xsl:apply-templates/>
    </br>
  </xsl:template>

  <xsl:template match="tei:l">
    <div class="l">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <label>
      <xsl:apply-templates/>
    </label>
  </xsl:template>
  
  <xsl:template match="tei:label/tei:num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <xsl:template match="tei:list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  
  
  <xsl:template match="tei:list[@rend='table']">
    <table>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item">
    <tbody>
      <xsl:apply-templates/>
    </tbody>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item[1]">
    <thead>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']/tei:item">
    <xsl:choose>
      <xsl:when test="tei:label and count(*) = 1 and not(text()[normalize-space(.) != ''])">
        <th>
          <xsl:apply-templates select="tei:label/node()"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:apply-templates/>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lg">
    <div class="lg">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:milestone">
    <!-- Something ? -->
  </xsl:template>
  

  <!-- Check if notes are interesting and find a good way to display and index -->
  <xsl:template match="tei:note">
    <xsl:comment>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt; </xsl:text>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="tei:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:q">
    <q class="q">
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  
  <!-- Will produce bad html for p/quote -->
  <xsl:template match="tei:quote">
    <blockquote class="quote">
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  
</xsl:transform>
