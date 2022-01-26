<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapie https://github.com/galenus-verbatim/verbapie
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php

Input, a __cts_.xml for a work, output, zotero records, each edition is linked to the work.

-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ti="http://chs.harvard.edu/xmlns/cts"
  exclude-result-prefixes="tei ti"
>
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:param name="CMGabbr"/>
  <xsl:param name="no"/>
  <xsl:param name="CMGgrc"/>
  <xsl:param name="BMfr"/>
  <xsl:param name="CGTen"/>
  <xsl:param name="CMGla"/>
  <xsl:param name="CGTabbr"/>
  <xsl:param name="fichtner"/>
  <xsl:param name="rem"/>
  
  <xsl:variable name="titulus">
    <xsl:choose>
      <xsl:when test="/ti:work/ti:title[@xml:lang='lat']">
        <xsl:value-of select="normalize-space(/ti:work/ti:title[@xml:lang='lat'])"/>
      </xsl:when>
      <xsl:when test="/ti:work/ti:title">
        <xsl:value-of select="normalize-space(/ti:work/ti:title)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Title not found</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>   
  
  <xsl:variable name="auctor">
    <xsl:variable name="cts_auctor" select="document('./../__cts__.xml', .)"/>
    <xsl:choose>
      <xsl:when test="$cts_auctor/*/ti:groupname[@xml:lang='lat']">
        <xsl:value-of select="normalize-space($cts_auctor/*/ti:groupname[@xml:lang='lat'])"/>
      </xsl:when>
      <xsl:when test="$cts_auctor/*/ti:groupname">
        <xsl:value-of select="normalize-space($cts_auctor/*/ti:groupname)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Author no found</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template name="about">
    <xsl:param name="urn" select="@urn"/>
    <xsl:value-of select="substring-after($urn, 'urn:cts:greekLit:')"/>
  </xsl:template>
  
  <xsl:template match="/ti:work">
    <rdf:RDF
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:z="http://www.zotero.org/namespaces/export#"
      xmlns:bib="http://purl.org/net/biblio#"
      xmlns:foaf="http://xmlns.com/foaf/0.1/"
      xmlns:dcterms="http://purl.org/dc/terms/"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/">
      <xsl:variable name="aboutWork">
        <xsl:call-template name="about"/>
      </xsl:variable>
      <bib:Book>
        <xsl:attribute name="rdf:about">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$aboutWork"/>
        </xsl:attribute>
        <z:itemType>book</z:itemType>
        <dc:subject>
          <dcterms:LCC>
            <rdf:value>
              <xsl:value-of select="$aboutWork"/>
            </rdf:value>
          </dcterms:LCC>
        </dc:subject>
        <bib:authors>
          <rdf:Seq>
            <rdf:li>
              <foaf:Person>
                <foaf:surname>
                  <xsl:value-of select="$auctor"/>
                </foaf:surname>
              </foaf:Person>
            </rdf:li>
          </rdf:Seq>
        </bib:authors>
        <dc:title>
          <!--
          <xsl:if test="$no">
            <xsl:value-of select="$no"/>
            <xsl:text>. </xsl:text>
          </xsl:if>
          <xsl:value-of select="$titulus"/>
          -->
          <xsl:value-of select="$CMGla"/>
        </dc:title>
        <xsl:if test="$CMGabbr != ''">
          <z:shortTitle>
            <xsl:value-of select="$CMGabbr"/>
          </z:shortTitle>
        </xsl:if>
        <xsl:for-each select="ti:edition">
          <dc:relation>
            <xsl:attribute name="rdf:resource">
              <xsl:text>#</xsl:text>
              <xsl:call-template name="about"/>
            </xsl:attribute>
          </dc:relation>
        </xsl:for-each>
        <xsl:if test="$CMGgrc != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_CMGgrc"/>
        </xsl:if>
        <xsl:if test="$BMfr != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_BMfr"/>
        </xsl:if>
        <xsl:if test="$CGTen != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_CGTen"/>
        </xsl:if>
        <xsl:if test="$CGTabbr != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_CGTabbr"/>
        </xsl:if>
        <xsl:if test="$fichtner != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_fichtner"/>
        </xsl:if>
        <xsl:if test="$rem != ''">
          <dcterms:isReferencedBy rdf:resource="#{$aboutWork}_rem"/>
        </xsl:if>
      </bib:Book>
      <xsl:if test="$CMGgrc != ''">
        <bib:Memo rdf:about="#{$aboutWork}_CMGgrc">
          <rdf:value>CMGgrc: <xsl:value-of select="$CMGgrc"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:if test="$BMfr != ''">
        <bib:Memo rdf:about="#{$aboutWork}_BMfr">
          <rdf:value>BMfr: <xsl:value-of select="$BMfr"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:if test="$CGTen != ''">
        <bib:Memo rdf:about="#{$aboutWork}_CGTen">
          <rdf:value>CGTen: <xsl:value-of select="$CGTen"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:if test="$CGTabbr != ''">
        <bib:Memo rdf:about="#{$aboutWork}_CGTabbr">
          <rdf:value>CGTAbbr: <xsl:value-of select="$CGTabbr"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:if test="$fichtner != ''">
        <bib:Memo rdf:about="#{$aboutWork}_fichtner">
          <rdf:value>fichtner: <xsl:value-of select="$fichtner"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:if test="$rem != ''">
        <bib:Memo rdf:about="#{$aboutWork}_rem">
          <rdf:value>Note: <xsl:value-of select="$rem"/></rdf:value>
        </bib:Memo>
      </xsl:if>
      <xsl:for-each select="ti:edition">
        <xsl:variable name="tei" select="document(concat(substring-after(@urn, 'urn:cts:greekLit:'), '.xml'), .)"/>
        
        <xsl:variable name="editor" select="$tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/>
        <xsl:variable name="annuspub">
          <xsl:for-each select="$tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc">
            <xsl:variable name="annusde" select="*[1]//tei:date"/>
            <xsl:value-of select="$annusde"/>
            <xsl:if test="*[2]">
              <xsl:variable name="annusad" select="*[position() = last()]//tei:date"/>
              <xsl:if test="$annusad != '' and $annusad != $annusde">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$annusad"/>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="volumen">
          <xsl:variable name="vols" select="$tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>
          <xsl:value-of select="$vols[1]"/>
          <xsl:variable name="vol2" select="$vols[last()]"/>
          <xsl:if test="$vol2 != '' and $vol2 != $vols[1]">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$vol2"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="pagina">
          <xsl:choose>
            <!-- more than one source volume, page number not relevant -->
            <xsl:when test="count($tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']) &gt; 1"/>
            <xsl:otherwise>
              <xsl:for-each select="$tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']">
                <xsl:value-of select="@from"/>
                <xsl:if test="@to">
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="@to"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="about">
          <xsl:call-template name="about"/>
        </xsl:variable>
        
        <bib:Book rdf:about="#{$about}">
          <z:itemType>book</z:itemType>
          <dc:subject>
            <dcterms:LCC>
              <rdf:value>
                <xsl:value-of select="$about"/>
              </rdf:value>
            </dcterms:LCC>
          </dc:subject>
          <bib:authors>
            <rdf:Seq>
              <rdf:li>
                <foaf:Person>
                  <foaf:surname>
                    <xsl:value-of select="$auctor"/>
                  </foaf:surname>
                </foaf:Person>
              </rdf:li>
            </rdf:Seq>
          </bib:authors>
          <dc:title>
            <xsl:value-of select="$tei/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
          </dc:title>
          <dc:relation>
            <xsl:attribute name="rdf:resource">
              <xsl:text>#</xsl:text>
              <xsl:value-of select="$aboutWork"/>
            </xsl:attribute>
          </dc:relation>
          <prism:edition>
            <xsl:value-of select="$editor"/>
          </prism:edition>
          <dc:date>
            <xsl:value-of select="$annuspub"/>
          </dc:date>
          <prism:volume>
            <xsl:value-of select="$volumen"/>
          </prism:volume>
          <z:numPages>
            <xsl:value-of select="$pagina"/>
          </z:numPages>
        </bib:Book>
      </xsl:for-each>
    </rdf:RDF>
  </xsl:template>


</xsl:transform>
