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
  <xsl:import href="cts_html.xsl"/>
  <xsl:output encoding="UTF-8" method="text"/>
  <!-- Required, folder where to project the generated files -->
  <xsl:param name="dst_dir"/>
  <!-- Source file name (without extension) -->
  <xsl:param name="src_name"/>
  <!-- Shall we allow __cts__.xml search ? Default is true(), caller should check if no -->
  <xsl:param name="__cts__" select="'true'"/>
  <!-- file extension to output -->
  <xsl:variable name="ext">.html</xsl:variable>
  <!-- Output page numbers, if we have the -->
  <xsl:variable name="pb" select="count(.//pb)"/>
  
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
    <xsl:variable name="titulus">
      <xsl:choose>
        <!-- avoid an xslt error if no cts file to get -->
        <xsl:when test="$__cts__ = ''">
          <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Load cts for opus -->
          <xsl:variable name="cts_opus" select="document('__cts__.xml', /)"/>
          <xsl:choose>
            <xsl:when test="$cts_opus/ti:work/ti:title[@xml:lang='lat']">
              <xsl:value-of select="normalize-space($cts_opus/ti:work/ti:title[@xml:lang='lat'])"/>
            </xsl:when>
            <xsl:when test="$cts_opus/ti:work/ti:title">
              <xsl:value-of select="normalize-space($cts_opus/ti:work/ti:title)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>   
    <xsl:variable name="auctor">
      <xsl:choose>
        <!-- avoid an xslt error if no cts file to get -->
        <xsl:when test="$__cts__ = ''">
          <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Load cts for auctor -->
          <xsl:variable name="cts_auctor" select="document('./../__cts__.xml', .)"/>
          <xsl:choose>
            <xsl:when test="$cts_auctor/*/ti:groupname[@xml:lang='lat']">
              <xsl:value-of select="normalize-space($cts_auctor/*/ti:groupname[@xml:lang='lat'])"/>
            </xsl:when>
            <xsl:when test="$cts_auctor/*/ti:groupname">
              <xsl:value-of select="normalize-space($cts_auctor/*/ti:groupname)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="editor" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/>
    <xsl:variable name="annuspub">
      <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc">
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
      <xsl:variable name="vols" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>
      <xsl:value-of select="$vols[1]"/>
      <xsl:variable name="vol2" select="$vols[last()]"/>
      <xsl:if test="$vol2 != '' and $vol2 != $vols[1]">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$vol2"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="pagde">
      <xsl:choose>
        <!-- more than one source volume, page number not relevant -->
        <xsl:when test="count(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']) &gt; 1"/>
        <xsl:otherwise>
          <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@from"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pagad">
      <xsl:choose>
        <!-- more than one source volume, page number not relevant -->
        <xsl:when test="count(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']) &gt; 1"/>
        <xsl:otherwise>
          <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@to"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <root>
      <xsl:text>[
    {</xsl:text>
      <xsl:if test="$src_name != ''">
        "clavis": "<xsl:value-of select="$src_name"/>"</xsl:if>
      <xsl:if test="$titulus != ''">,
        "titulus": "<xsl:value-of select="$titulus"/>"</xsl:if>
      <xsl:if test="$auctor != ''">,
        "auctor": "<xsl:value-of select="$auctor"/>"</xsl:if>
      <xsl:if test="$editor != ''">,
        "editor": "<xsl:value-of select="$editor"/>"</xsl:if>
      <xsl:if test="$annuspub != ''">,
        "annuspub": "<xsl:value-of select="$annuspub"/>"</xsl:if>
      <xsl:if test="$volumen != ''">,
        "volumen": "<xsl:value-of select="$volumen"/>"</xsl:if>
      <xsl:if test="$pagde != ''">,
        "pagde": "<xsl:value-of select="$pagde"/>"</xsl:if>
      <xsl:if test="$pagad != ''">,
        "pagad": "<xsl:value-of select="$pagad"/>"</xsl:if>
      <xsl:text>
    }</xsl:text>
      <xsl:apply-templates select="//tei:div[@type='edition']"/>
      <xsl:text>
]</xsl:text>
</root>
  </xsl:template>

  <!-- chaptering -->
  <xsl:template match="tei:div[@type='edition']">
    <xsl:choose>
      <!-- chapters may be children of book -->
      <xsl:when test="count(.//tei:div[@type='textpart'][@subtype='chapter']) &gt; 1">
        <xsl:call-template name="toc"/>
        <xsl:for-each select=".//tei:div[@type='textpart'][@subtype='chapter']">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- sections seems to work like chapters -->
      <xsl:when test="count(tei:div[@type='textpart'][@subtype='section'][@n]) &gt; 1">
        <xsl:call-template name="toc"/>
        <xsl:for-each select="tei:div">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- Only one div -->
      <xsl:when test="count(tei:div) = 1 and tei:div[@type='textpart'][@subtype='work' or @subtype='book' or @subtype='chapter']">
        <xsl:for-each select="tei:div[@type='textpart']">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- A book with no chapters -->
      <xsl:otherwise>
        <xsl:message terminate="yes">No chapters found in <xsl:value-of select="$src_name"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Generate a toc when relevant  -->
  <xsl:template name="toc">
    <xsl:param name="href">
      <xsl:value-of select="$dst_dir"/>
      <xsl:value-of select="$src_name"/>
      <xsl:text>/</xsl:text>
      <xsl:text>toc</xsl:text>
      <xsl:value-of select="$ext"/>
    </xsl:param>
    <xsl:document
      href="{$href}"
      omit-xml-declaration="yes"
      indent="yes"
      encoding="UTF-8"
      >
      <nav>
        <ul>
          <xsl:apply-templates select="tei:div" mode="toc"/>
        </ul>
      </nav>
    </xsl:document>
  </xsl:template>

  <xsl:template match="tei:div" mode="toc">
    <xsl:choose>
      <xsl:when test="@n and tei:div[@type='textpart'][@subtype='chapter']">
        <li>
          <span>Liber <xsl:value-of select="@n"/></span>
          <ul>
            <xsl:apply-templates select="tei:div[@type='textpart'][@subtype='chapter']" mode="toc"/>
          </ul>
        </li>
      </xsl:when>
      <xsl:when test="@type='textpart' and @subtype='chapter' and @n">
        <li>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dst_name"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="number(@n) &gt; 0">
                <xsl:text>Capitulum </xsl:text>
                <xsl:value-of select="@n"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@n"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </xsl:when>
      <xsl:when test="@type='textpart' and @subtype='section' and @n">
        <li>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dst_name"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="number(@n) &gt; 0">
                <xsl:text>Sectio </xsl:text>
                <xsl:value-of select="@n"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@n"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:value-of select="$src_name"/>
        </xsl:message>
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
    <xsl:variable name="pbde">
      <xsl:choose>
        <!-- section is starting in middle of a page -->
        <xsl:when test="$text-before != ''">
          <xsl:value-of select="preceding::tei:pb[1]/@n"/>
        </xsl:when>
        <!-- small section with no <pb> -->
        <xsl:when test="not(.//tei:pb)">
          <xsl:value-of select="preceding::tei:pb[1]/@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="(.//tei:pb)[1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pagde">
      <xsl:choose>
        <xsl:when test="contains($pbde, '.')">
          <xsl:value-of select="substring-after($pbde, '.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$pbde"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pagad">
      <xsl:variable name="pbad" select="(.//tei:pb)[last()]/@n"/>
      <xsl:choose>
        <xsl:when test="contains($pbad, '.')">
          <xsl:value-of select="substring-after($pbad, '.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$pbad"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="volumen">
      <xsl:choose>
        <xsl:when test="contains($pbde, '.')">
          <xsl:value-of select="substring-before($pbde, '.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- In there are no notes in heading -->
    <xsl:variable name="titulus">
      <xsl:choose>
        <xsl:when test="not(tei:head)"/>
        <!-- In Galenus, only first head has a title, not significant -->
        <xsl:when test="not(../tei:div[2]/tei:head)"/>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(tei:head)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>,
    {</xsl:text>
    <xsl:if test="true()">
      "clavis": "<xsl:value-of select="$dst_name"/>"</xsl:if>
    <xsl:if test="$titulus != ''">,
      "titulus": "<xsl:value-of select="$titulus"/>"</xsl:if>
    <xsl:if test="$pagde != ''">,
      "pagde": "<xsl:value-of select="$pagde"/>"</xsl:if>
    <xsl:if test="$pagad != ''">,
      "pagad": "<xsl:value-of select="$pagad"/>"</xsl:if>
    <xsl:if test="$volumen != ''">,
      "volumen": "<xsl:value-of select="$volumen"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='book']/@n">,
      "liber": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='book'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='chapter']/@n">,
      "capitulum": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='chapter'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='section']/@n">,
      "sectio": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='section'][1]/@n"/>"</xsl:if>
    <xsl:text>
    }</xsl:text>
    <!--
    method html is needed to have <span></span> (and not <span/>)
    -->
    <xsl:document
      href="{$href}"
      indent="yes"
      method="html"
      omit-xml-declaration="yes"
      encoding="UTF-8"
      >
      <article id="{$dst_name}">
        <xsl:if test="$text-before != '' or not(.//tei:pb)">
          <xsl:apply-templates select="(preceding::tei:pb)[last()]">
            <xsl:with-param name="class">pbde</xsl:with-param>
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
