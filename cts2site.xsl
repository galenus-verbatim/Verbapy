<?xml version="1.0" encoding="UTF-8"?>
<!--
Part of verbatim{???} https://github.com/galenus-verbatim/verbatim{???}
© 2021 {qui répond par mail ?}
BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
Split a single TEI file in a multi-pages site
TODo : prev / next and lots of other item metadata
-->
<xsl:transform version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    >
    <xsl:output indent="yes" encoding="UTF-8" method="xml" />
    <!-- Required, folder where to project the generated files -->
    <xsl:param name="dst_dir"/>
    <!-- Source file name (without extension) -->
    <xsl:param name="src_name"/>
    <!-- file extension to output -->
    <xsl:variable name="ext">.xml</xsl:variable>
    
    <xsl:template match="/*">
        <xsl:if test="normalize-space($dst_dir) = ''">
            <xsl:message terminate="yes">[cts2site.xsl] $dst_dir param is required to output files</xsl:message>
        </xsl:if>
        <xsl:message>$dst_dir=<xsl:value-of select="$dst_dir"/></xsl:message>
        <xsl:if test="count(//tei:div[@type='edition']) &gt; 1">
            <xsl:message terminate="yes">More than one &lt;div type="edition"&gt;, not expected</xsl:message>
        </xsl:if>
        <book>
            <xsl:for-each select="//tei:div[@type='textpart'][@subtype='chapter']">
                <chapter>
                    <xsl:call-template name="dst_name"/>
                    <xsl:text> : </xsl:text>
                    <xsl:call-template name="idpath"/>
                </chapter>
                <xsl:call-template name="document"/>
            </xsl:for-each>
        </book>
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
            <xsl:call-template name="dst_name"/>
            <xsl:value-of select="$ext"/>
        </xsl:param>
        <xsl:document 
            href="{$href}" 
            omit-xml-declaration="no" 
            encoding="UTF-8" 
            indent="yes"
            >
            <TEI>
                <teiHeader>
                    <fileDesc>
                        <xsl:copy-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:title"/>
                    </fileDesc>
                </teiHeader>
                <body>
                    <text>
                        <xsl:copy-of select="*"/>
                    </text>
                </body>
            </TEI>
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