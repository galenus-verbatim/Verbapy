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
        "author": "<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>",
        "editor": "<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/>",
        "issued": "<xsl:value-of   select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date"/>",
        "volume": "<xsl:value-of    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>",
        "pagefrom": "<xsl:value-of   select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@from"/>",
        "pageto": "<xsl:value-of     select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@to"/>"
    }<xsl:apply-templates select="//tei:div[@type='edition']"/>
]
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
          <span>Livre <xsl:value-of select="@n"/></span>
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
                <xsl:text>Chapitre </xsl:text>
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
                <xsl:text>Section </xsl:text>
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
    <xsl:variable name="from">
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
    <!-- title is not relevant here
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
    -->
    <xsl:text>,
    {</xsl:text>
    <xsl:if test="true()">
        "identifier": "<xsl:value-of select="$dst_name"/>"</xsl:if>
    <xsl:if test=".//tei:pb">,
        "pagefrom": "<xsl:value-of select="$from"/>",
        "pageto": "<xsl:value-of select="(.//tei:pb)[last()]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='book']/@n">,
        "book": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='book'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='chapter']/@n">,
        "chapter": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='chapter'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='section']/@n">,
        "chapter": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='section'][1]/@n"/>"</xsl:if>
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
      <article>
        <xsl:if test="$text-before != '' or not(.//tei:pb)">
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
