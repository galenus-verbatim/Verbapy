<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php


Split a single TEI file in a multi-pages site

output method="html" for <span></span>

-->
<xsl:transform version="1.1"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:exslt="http://exslt.org/common"
  xmlns:saxon="http://icl.com/saxon" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  exclude-result-prefixes="tei" 
  extension-element-prefixes="exslt saxon date">
  <!-- output html requested with xsltproc, < -->
  <xsl:output 
    indent="yes" 
    encoding="UTF-8"
    method="html"
    omit-xml-declaration="yes"
    doctype-public="HTML"
    doctype-system=""
  />
  <!-- Maybe modified by caller -->
  <xsl:param name="cts" select="/tei:TEI/tei:text/tei:body/tei:div[@type = 'edition'][1]/@n"/>
  <!-- To produce a view helping proof reading -->
  <xsl:param name="proof"/>
  
  <!-- To produce a normalised id without diacritics translate("Déjà vu, 4", $idfrom, $idto) = "dejavu4"  To produce a normalised id -->
  <xsl:variable name="idfrom">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû_ ,.'’ #()</xsl:variable>
  <xsl:variable name="idto"  >abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu_</xsl:variable>
  <!-- Where to find static assets like CSS or JS -->
  <xsl:param name="xslbase">
    <xsl:call-template name="xslbase"/>
  </xsl:param>
  <!-- Generation date, maybe modified by caller -->
  <xsl:param name="date">
    <xsl:choose>
      <xsl:when test="function-available('date:date-time')">
        <xsl:variable name="date">
          <xsl:value-of select="date:date-time()"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($date, '+')">
            <xsl:value-of select="substring-before($date, '+')"/>
          </xsl:when>
          <xsl:when test="contains($date, '-')">
            <xsl:value-of select="substring-before($date, '-')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$date"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:param>

  
  <xsl:template match="/*">
    <article>
      <header>
        <xsl:apply-templates select="/tei:TEI/tei:teiHeader"/>
      </header>
      <xsl:apply-templates select="/tei:TEI/tei:text"/>
    </article>
  </xsl:template>

  <xsl:template match="tei:*" priority="-5">
    <xsl:message terminate="no">
      <xsl:text>[verbatim_html.xsl] </xsl:text>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:text> TEI tag not yet handled</xsl:text>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>



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
    <span class="{local-name()}" rel="{@when}{@notBefore}-{@notAfter}">
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
    <section>
      <xsl:attribute name="id">
        <xsl:call-template name="cts"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat(@type, ' ', @subtype))"/>
      </xsl:attribute>
      <!-- generate a title ? -->
      <xsl:choose>
        <xsl:when test="@type = 'edition'"/>
        <xsl:when test="tei:head"/>
        <xsl:when test="@subtype = 'chapter' and @n">
          <xsl:variable name="level" select="count(ancestor-or-self::tei:div[@type='textpart'])"/>
          <xsl:element name="h{$level}">
            <xsl:call-template name="tree_back">
              <xsl:with-param name="contents">
                <xsl:text>[Capitulum </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:element>
        </xsl:when>
        <xsl:when test="tei:p/tei:label[@type = 'head']"/>
        <xsl:otherwise>
          <xsl:variable name="level" select="count(ancestor-or-self::tei:div[@type='textpart'])"/>
          <xsl:element name="h{$level}">
            <xsl:call-template name="tree_back">
              <xsl:with-param name="contents">
                <xsl:text>[</xsl:text>
                <xsl:call-template name="title"/>
                <xsl:text>]</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
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
  
  
  <xsl:template match="tei:forename">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <!-- Graphic founds were links and not images, no output for Galen
  <graphic url="https://babel.hathitrust.org/cgi/pt?id=hvd.hxpp8p;view=2up;seq=514"/>
  -->
  <xsl:template match="tei:graphic">
  </xsl:template>
  
  
  <xsl:template match="tei:gap"/>
  
  <xsl:template match="tei:head">
    <xsl:param name="level" select="count(ancestor::tei:div[@type='textpart'])"/>
    <xsl:element name="h{$level}">
      <xsl:call-template name="tree_back">
        <xsl:with-param name="contents">
          <xsl:if test="parent::tei:div[@subtype='chapter'][@n][number(@n) &gt; 0]">
            <xsl:text>[Capitulum </xsl:text>
            <xsl:value-of select="../@n"/>
            <xsl:text>] </xsl:text>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- line identifier -->
  <xsl:template match="tei:lb" name="lb">
    <xsl:param name="n">
      <xsl:choose>
        <xsl:when test="@n != ''">
          <xsl:value-of select="@n"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="page">
      <xsl:call-template name="data-page"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$n != ''">
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="normalize-space(concat('lb ', @rend))"/>
          </xsl:attribute>
          <xsl:attribute name="data-page">
            <xsl:value-of select="$page"/>
          </xsl:attribute>
          <xsl:attribute name="data-line">
            <xsl:value-of select="$n"/>
          </xsl:attribute>
          <xsl:attribute name="id">
            <xsl:choose>
              <xsl:when test="@xml:id">
                <xsl:value-of select="@xml:id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>l</xsl:text>
                <xsl:value-of select="$page"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="$n"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:text>ㅤ</xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!-- xmlns="http://www.w3.org/1999/xhtml" will produce <br></br>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br/>]]></xsl:text>
 will output <br/> as text
        <xsl:value-of disable-output-escaping="yes"><br/></xsl:value-of>
      break XSLT in browser
 -->
        <br/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <xsl:template match="tei:l">
    <div class="l">
      <xsl:if test="@n">
        <xsl:call-template name="lb">
          <xsl:with-param name="n">
            <xsl:value-of select="@n"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <label>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </label>
  </xsl:template>

  <xsl:template match="tei:label[@type = 'head']">
    <xsl:call-template name="tree_back"/>
  </xsl:template>
  

  <xsl:template name="tree_back">
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:variable name="cts">
      <xsl:call-template name="cts"/>
    </xsl:variable>
    <a>
      <xsl:call-template name="class">
        <xsl:with-param name="class">tree_back</xsl:with-param>
      </xsl:call-template>
      <xsl:attribute name="href">
        <xsl:text>#tree_</xsl:text>
        <xsl:value-of select="$cts"/>
      </xsl:attribute>
      <xsl:copy-of select="$contents"/>
    </a>
  </xsl:template>

  <xsl:template match="tei:label/tei:num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:list[@rend = 'table']">
    <table class="list">
      <!-- No page breaks between table rows --> 
      <xsl:choose>
        <xsl:when test="count(tei:item) &gt; 1">
          <thead>
            <xsl:apply-templates select="tei:item[1]/tei:list"/>
          </thead>
          <tbody>
            <xsl:apply-templates select="tei:item[position() &gt; 1]/tei:list"/>
          </tbody>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="tei:item/tei:list"/>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:template>
  
  <!-- table row from list  -->
  <xsl:template match="tei:list[@rend='row'] | tei:list[@rend='table']/tei:item/tei:list">
    <tr>
      <xsl:if test="@n">
        <td class="lb" data-line="{@n}"/>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="pb" select="preceding-sibling::tei:*[1][self::tei:pb]"/>
      </xsl:apply-templates>
    </tr>
  </xsl:template>
 
  
  <xsl:template match="tei:list[@rend='row']/tei:item">
    <xsl:param name="pb"/>
    <xsl:variable name="page">
      <xsl:variable name="nb">
        <xsl:number/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$nb != 1"/>
        <xsl:otherwise>
          <xsl:apply-templates select="$pb"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="ancestor::tei:item[@rend = 'header']">
        <th>
          <xsl:copy-of select="$page"/>
          <xsl:apply-templates/>
        </th>
      </xsl:when>
      <xsl:when test="tei:label and count(*) = 1 and not(text()[normalize-space(.) != ''])">
        <th>
          <xsl:copy-of select="$page"/>
          <xsl:apply-templates select="tei:label/node()"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:copy-of select="$page"/>
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
    <xsl:param name="class"/>
    <xsl:param name="diff"/>
    <span>
      <xsl:variable name="unit" select="translate(@unit, $idfrom, $idto)"/>
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat('milestone ', $unit, ' ', $class))"/>
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
      <xsl:for-each select="@corresp|@facs|@source|@unit">
        <xsl:attribute name="data-{name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <!-- required for empty tag -->
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@unit"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="@n"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:text>ㅤ</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:name">
    <span class="{local-name()}">
      <xsl:apply-templates/>
    </span>
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
      <!-- give volume number
      <xsl:when test="contains($n, '.')">
        <xsl:value-of select="substring-after($n, '.')"/>
      </xsl:when>
      -->
      <xsl:otherwise>
        <xsl:value-of select="$n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:param name="class"/>
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
      </xsl:if>
      <!-- required for empty tag -->
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>p</xsl:text>
            <xsl:value-of select="$n"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:text>ㅤ</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="tei:persName">
    <a class="{local-name()}" type="{@type}" subtype="{@subtype}" rel="{@nymRef}">
    <a href="http://cahal.me/italikos/tablepers">
      <xsl:apply-templates/>
    </a>
    </a>
  </xsl:template>
  
  <xsl:template match="tei:cit">
  <i>
    <xsl:variable name="CTSURN" select="concat('https://scaife.perseus.org/reader/', descendant::tei:title/@key)"/>
    <a href="{$CTSURN}" >
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
  <!--need to fix the quote code because it doubles the text<xsl:variable name="CTSURN2" select="concat('https://scaife.perseus.org/reader/', descendant::tei:title/@key)"/>
    <a href="{$CTSURN2}" >
		<xsl:apply-templates/>
    </a>-->
    <xsl:variable name="class" select="normalize-space(concat('quote ', @rend, ' ', @type))"/>
    <xsl:choose>
      <!-- level block -->
      <xsl:when test="not(ancestor::tei:p) or parent::tei:div">
        <blockquote class="{$class}">
          <xsl:apply-templates/>
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
  
  <xsl:template match="tei:space">
    <xsl:text> </xsl:text>
  </xsl:template>
  
    <!-- Should I go now ? La, la, la -->
  <xsl:template match="tei:back | tei:body | tei:front | tei:group" mode="toc">
    <xsl:apply-templates select="tei:div" mode="toc"/>
  </xsl:template>
  
  <!-- Title for toc. -->
  <xsl:template name="title">
    <xsl:choose>
      <xsl:when test="@type='textpart'  and (@subtype='chapter' or @subtype='section')">
        <xsl:variable name="label">
          <xsl:choose>
            <xsl:when test="@subtype='chapter'">Capitulum </xsl:when>
            <xsl:when test="@subtype='section'">Sectio </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="@n and number(@n) &gt; 0">
            <xsl:value-of select="$label"/>
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:when test="@n and @n != ''">
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$label"/>
            <xsl:number/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <!-- Title in chapter are not systematic, reason why the prefix “Capitulum” is useful -->
          <xsl:when test="tei:head">
            <xsl:text>. </xsl:text>
            <xsl:value-of select="tei:head"/>
          </xsl:when>
          <xsl:when test="./tei:p/tei:label[@type='head']">
            <xsl:text>. </xsl:text>
            <xsl:value-of select="normalize-space(./tei:p/tei:label[@type='head'])"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="tei:head">
        <xsl:value-of select="normalize-space(tei:head)"/>
      </xsl:when>
      <xsl:when test="./tei:label[@type='head']">
        <xsl:value-of select="normalize-space(./tei:label[@type='head'])"/>
      </xsl:when>
      <xsl:when test="./tei:p/tei:label[@type='head']">
        <xsl:value-of select="normalize-space(./tei:p/tei:label[@type='head'])"/>
      </xsl:when>
      <xsl:when test="@type='textpart' and (@subtype='chapter' or @subtype='section')">
        <xsl:variable name="label">
          <xsl:choose>
            <xsl:when test="@subtype='chapter'">Capitulum </xsl:when>
            <xsl:when test="@subtype='section'">Sectio </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="number(@n) &gt; 0">
            <xsl:value-of select="$label"/>
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:when test="@n and @n != ''">
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$label"/>
            <xsl:number/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="./tei:p/tei:label[@type='head']">
          <xsl:text>. </xsl:text>
          <xsl:value-of select="normalize-space(./tei:p/tei:label[@type='head'])"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@n and tei:div[@type='textpart'][@subtype='chapter']">
        <xsl:text>Liber </xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cts"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:div" mode="toc">
    <xsl:variable name="cts">
      <xsl:call-template name="cts"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@type = 'edition'">
        <ul class="tree">
          <xsl:apply-templates select="tei:div" mode="toc"/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <li>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:value-of select="$cts"/>
            </xsl:attribute>
            <xsl:attribute name="id">
              <xsl:text>tree_</xsl:text>
              <xsl:value-of select="$cts"/>
            </xsl:attribute>
            <xsl:call-template name="title"/>
          </a>
          <xsl:if test="tei:div">
            <ul>
              <xsl:apply-templates select="tei:div" mode="toc"/>
            </ul>
          </xsl:if>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:text " mode="toc">
    <xsl:apply-templates select="*" mode="toc"/>
  </xsl:template>
  
  <xsl:template match="node()" mode="toc" priority="-1"/>

  <xsl:template name="cts">
    <xsl:value-of select="ancestor-or-self::tei:div[@type = 'edition']/@n"/>
    <xsl:variable name="n">
      <xsl:call-template name="n"/>
    </xsl:variable>
    <xsl:if test="$n != ''">
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$n"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="n">
    <xsl:for-each select="ancestor-or-self::tei:div[@type = 'textpart']">
      <xsl:if test="position() != 1">.</xsl:if>
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
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
  
    <!-- In case of direct XSLT transformation in browser, get the folder -->
  <xsl:template name="xslbase">
    <xsl:param name="path" select="/processing-instruction('xml-stylesheet')[contains(., '.xsl')]"/>
    <xsl:choose>
      <xsl:when test="contains($path, 'href=&quot;')">
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, 'href=&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '&quot;')">
        <xsl:variable name="p" select="substring-before($path, '&quot;')"/>
        <xsl:choose>
          <xsl:when test="not(contains($p, '/')) and not(contains($p, '\'))">./</xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xslbase">
              <xsl:with-param name="path" select="$p"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- Absolute, do nothing -->
      <xsl:when test="starts-with($path, 'http')"/>
      <!-- cut beforer quote -->
      <xsl:when test="contains($path, '/')">
        <xsl:value-of select="substring-before($path, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- win centric -->
      <xsl:when test="contains($path, '\')">
        <xsl:value-of select="substring-before($path, '\')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="class">
    <xsl:param name="class"/>
    <xsl:variable name="cls">
      <xsl:variable name="txt">
        <xsl:value-of select="$class"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@subtype"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@rend"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($txt)"/>
    </xsl:variable>
    <xsl:if test="$cls != ''">
      <xsl:attribute name="class">
        <xsl:value-of select="$cls"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

</xsl:transform>
