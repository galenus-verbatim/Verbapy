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
  xmlns:ti="http://chs.harvard.edu/xmlns/cts"
  exclude-result-prefixes="tei ti"
>
  <xsl:import href="verbatim_html.xsl"/>
  <xsl:output encoding="UTF-8" method="text"/>
  <!-- Required, folder where to project the generated files -->
  <xsl:param name="dst_dir"/>
  <!-- Source file name (without extension) -->
  <xsl:param name="src_name"/>
  <!-- Shall we allow __cts__.xml search ? Default is true(), caller should check if no -->
  <xsl:param name="__cts__" select="'true'"/>
  <!-- first dic, file meta, and ordered array of chapters -->
  <xsl:variable name="title">
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
  <xsl:variable name="authors">
    <xsl:choose>
      <!-- avoid an xslt error if no cts file to get -->
      <xsl:when test="$__cts__ = ''">
        <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Load cts for author -->
        <xsl:variable name="cts_author" select="document('./../__cts__.xml', .)"/>
        <xsl:choose>
          <xsl:when test="$cts_author/*/ti:groupname[@xml:lang='lat']">
            <xsl:value-of select="normalize-space($cts_author/*/ti:groupname[@xml:lang='lat'])"/>
          </xsl:when>
          <xsl:when test="$cts_author/*/ti:groupname">
            <xsl:value-of select="normalize-space($cts_author/*/ti:groupname)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of  select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="editors">
    <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
      <xsl:value-of select="."/>
      <xsl:if test="position() != last()">; </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="date">
    <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc">
      <xsl:variable name="date_start" select="*[1]//tei:date"/>
      <xsl:value-of select="$date_start"/>
      <xsl:if test="*[2]">
        <xsl:variable name="date_end" select="*[position() = last()]//tei:date"/>
        <xsl:if test="$date_end != '' and $date_end != $date_start">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="$date_end"/>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="volume">
    <xsl:variable name="vols" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='vol']"/>
    <xsl:value-of select="$vols[1]"/>
    <xsl:variable name="vol2" select="$vols[last()]"/>
    <xsl:if test="$vol2 != '' and $vol2 != $vols[1]">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$vol2"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="page_start">
    <xsl:choose>
      <!-- more than one source volume, page number not relevant -->
      <xsl:when test="count(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']) &gt; 1"/>
      <xsl:otherwise>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@from"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="page_end">
    <xsl:choose>
      <!-- more than one source volume, page number not relevant -->
      <xsl:when test="count(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']) &gt; 1"/>
      <xsl:otherwise>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[@unit='pp']/@to"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- file extension to output -->
  <xsl:variable name="ext">.html</xsl:variable>
  <!-- Output page numbers, if we have the -->
  <xsl:variable name="pb" select="count(.//pb)"/>
  
  <xsl:template match="/" priority="5">
    <xsl:variable name="message">
      <xsl:if test="normalize-space($dst_dir) = ''">
        <xsl:text>[verbatim_split.xsl] $dst_dir param is required to output files&#10;</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space($src_name) = ''">
        <xsl:text>[verbatim_split.xsl] $src_name param is required to output files&#10;</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space($cts) = ''">
        <xsl:text>[verbatim_split.xsl] $cts is required for an urn:cts:… identifier for the edition. Default is found in /TEI/text/body/div[@type = 'edition'][1]/@n&#10;</xsl:text>
      </xsl:if>
      <xsl:variable name="filename" select="translate(substring-after($cts, 'urn:cts:greekLit:'), ':', '_')"/>
      <xsl:if test="$filename != $src_name">
        <xsl:text>[verbatim_split.xsl] Filename </xsl:text>
        <xsl:value-of select="$src_name"/> 
        <xsl:text> seems to not match CTS URN </xsl:text>
        <xsl:value-of select="$cts"/> 
        <xsl:text> (found in /TEI/text/body/div[@type = 'edition'][1]/@n, according to Epidoc)&#10;</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$message != ''">
      <xsl:message terminate="yes">
        <xsl:value-of select="$message"/>
      </xsl:message>
    </xsl:if>
    <root>
      <xsl:text>[
    {</xsl:text>
      <xsl:if test="$src_name != ''">
        "file": "<xsl:value-of select="$src_name"/>",
        "cts": "<xsl:value-of select="$cts"/>"</xsl:if>
      <xsl:if test="$title != ''">,
        "title": "<xsl:value-of select="normalize-space($title)"/>"</xsl:if>
      <xsl:if test="$authors != ''">,
        "authors": "<xsl:value-of select="normalize-space($authors)"/>"</xsl:if>
      <xsl:if test="$editors != ''">,
        "editors": "<xsl:value-of select="normalize-space($editors)"/>"</xsl:if>
      <xsl:if test="$date != ''">,
        "date": "<xsl:value-of select="$date"/>"</xsl:if>
      <xsl:if test="$volume != ''">,
        "volume": "<xsl:value-of select="$volume"/>"</xsl:if>
      <xsl:if test="$page_start != ''">,
        "page_start": "<xsl:value-of select="$page_start"/>"</xsl:if>
      <xsl:if test="$page_end != ''">,
        "page_end": "<xsl:value-of select="$page_end"/>"</xsl:if>
      <xsl:text>
    }</xsl:text>
      <xsl:choose>
        <!-- Idiomatic Cahal -->
        <xsl:when test="/tei:TEI/tei:text[2]">
          <xsl:call-template name="toc"/>
          <xsl:apply-templates select="/tei:TEI/tei:text"/>
        </xsl:when>
        <xsl:when test="//tei:div[@type='edition']">
          <xsl:apply-templates select="//tei:div[@type='edition']"/>
        </xsl:when>
      </xsl:choose>
      <xsl:text>
]</xsl:text>
</root>
  </xsl:template>
  
  <xsl:template match="tei:text | tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- chaptering -->
  <xsl:template match="tei:div[@type='edition'] ">
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
      <!-- Cahal, epidoc conform  -->
      <xsl:when test="tei:div[@type='textpart']">
        <xsl:call-template name="toc"/>
        <xsl:for-each select="tei:div">
          <xsl:call-template name="document"/>
        </xsl:for-each>
      </xsl:when>
      <!-- A book with no chapters -->
      <xsl:otherwise>
        <xsl:message terminate="yes">[cts_chapter.xsl] No chapters found in <xsl:value-of select="$src_name"/></xsl:message>
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
      method="xml"
      >
      <nav>
        <ul class="tree">
          <xsl:choose>
            <xsl:when test="/tei:TEI/tei:text[2]">
              <xsl:apply-templates select="/tei:TEI/tei:text" mode="toc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:div" mode="toc"/>
            </xsl:otherwise>
          </xsl:choose>
        </ul>
      </nav>
    </xsl:document>
  </xsl:template>

  <xsl:template name="href">
    <xsl:text>./</xsl:text>
    <xsl:for-each select="ancestor-or-self::tei:div[@subtype != 'section'][1]">
      <xsl:call-template name="cts"/>
    </xsl:for-each>
    <xsl:if test="@subtype = 'section' or not(self::tei:div)">
      <xsl:text>#</xsl:text>
      <xsl:call-template name="cts"/>
    </xsl:if>
  </xsl:template>

  <!-- Calculate the destination file name of a chapter -->
  <xsl:template name="dst_name">
    <xsl:variable name="cts">
      <xsl:call-template name="cts"/>
    </xsl:variable>
    <!-- First ancestor !! -->
    <xsl:choose>
      <xsl:when test="starts-with(@n, 'urn:cts:greekLit:')">
        <xsl:value-of select="substring-after(@n, 'urn:cts:greekLit:')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$src_name"/>
        <xsl:for-each select="ancestor-or-self::tei:div[@type='textpart']">
          <xsl:choose>
            <xsl:when test="position() = 1">_</xsl:when>
            <xsl:otherwise>.</xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="@n"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:variable name="page_start">
      <xsl:choose>
        <xsl:when test="contains($pbde, '.')">
          <xsl:value-of select="substring-after($pbde, '.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$pbde"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="line_start">
      <xsl:for-each select="(.//tei:lb[@n])[1]">
        <xsl:value-of select="@n"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="page_end">
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
    <xsl:variable name="line_end">
      <xsl:for-each select="(.//tei:lb[@n])[last()]">
        <xsl:value-of select="@n"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="volume">
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
    <xsl:variable name="title">
      <xsl:call-template name="title"/>
    </xsl:variable>
    <xsl:variable name="num">
      
    </xsl:variable>
    <xsl:variable name="cts">
      <xsl:call-template name="cts"/>
    </xsl:variable>
    <xsl:text>,
    {</xsl:text>
    <xsl:if test="true()">
        "file": "<xsl:value-of select="$dst_name"/>",
      "cts": "<xsl:value-of select="$cts"/>"</xsl:if>
    <xsl:if test="$volume != ''">,
        "volume": "<xsl:value-of select="$volume"/>"</xsl:if>
    <xsl:if test="$page_start != ''">,
        "page_start": "<xsl:value-of select="$page_start"/>"</xsl:if>
    <xsl:if test="$line_start != ''">,
        "line_start": "<xsl:value-of select="$line_start"/>"</xsl:if>
    <xsl:if test="$page_end != ''">,
        "page_end": "<xsl:value-of select="$page_end"/>"</xsl:if>
    <xsl:if test="$line_end != ''">,
        "line_end": "<xsl:value-of select="$line_end"/>"</xsl:if>
    <xsl:if test="$title != ''">,
        "title": "<xsl:value-of select="normalize-space($title)"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='book']/@n">,
        "liber": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='book'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='chapter']/@n">,
        "capitulum": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='chapter'][1]/@n"/>"</xsl:if>
    <xsl:if test="ancestor-or-self::tei:div[@subtype='section']/@n">,
        "sectio": "<xsl:value-of select="ancestor-or-self::tei:div[@subtype='section'][1]/@n"/>"</xsl:if>
    <xsl:text>
    }</xsl:text>
    <!--
    if method="xml" ensure to put a char inside <span>ㅤ</span> (to avoir <span/>)
    method="html" produce double <br></br>
    -->
    <xsl:document
      href="{$href}"
      indent="yes"
      method="xml"
      omit-xml-declaration="yes"
      encoding="UTF-8"
      >
      <article id="{$cts}">
        <xsl:text>&#10;</xsl:text>
        <xsl:if test="$text-before != '' or not(.//tei:pb)">
          <xsl:apply-templates select="preceding::tei:pb[1]">
            <xsl:with-param name="class">page1</xsl:with-param>
          </xsl:apply-templates>
        </xsl:if>
        <!-- Not generic, Galen specific -->
        <xsl:variable name="ed1" select="preceding::tei:milestone[@unit='ed1page'][1]"/>
        <xsl:choose>
          <xsl:when test="$ed1">
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="$ed1">
              <xsl:with-param name="class">page1</xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <!-- first section with a milestone in it -->
          <xsl:when test=".//tei:milestone[@unit='ed1page']">
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="(.//tei:milestone[@unit='ed1page'])[1]">
              <xsl:with-param name="class">page1</xsl:with-param>
              <xsl:with-param name="diff" select="-1"/>
            </xsl:apply-templates>
          </xsl:when>
          <!-- following axis excludes descendants -->
          <xsl:otherwise>
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="following::tei:milestone[@unit='ed1page'][1]">
              <xsl:with-param name="class">page1</xsl:with-param>
              <xsl:with-param name="diff" select="-1"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="ed2" select="preceding::tei:milestone[@unit='ed2page'][1]"/>
        <xsl:choose>
          <xsl:when test="$ed2">
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="$ed2">
              <xsl:with-param name="class">page1</xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <!-- first section with a milestone in it -->
          <xsl:when test=".//tei:milestone[@unit='ed2page']">
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="(.//tei:milestone[@unit='ed2page'])[1]">
              <xsl:with-param name="diff" select="-1"/>
              <xsl:with-param name="class">page1</xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <!-- following axis excludes descendants -->
          <xsl:otherwise>
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="following::tei:milestone[@unit='ed2page'][1]">
              <xsl:with-param name="diff" select="-1"/>
              <xsl:with-param name="class">page1</xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Content -->
        <xsl:apply-templates/>
      </article>
    </xsl:document>
  </xsl:template>

  


</xsl:transform>
