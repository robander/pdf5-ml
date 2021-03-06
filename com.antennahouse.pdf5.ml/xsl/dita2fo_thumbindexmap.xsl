<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Make thumb index map.
Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- Inner class (used this module)
     -->
    <xsl:variable name="cClassPart" select="'part'"/>
    <xsl:variable name="cClassChapter" select="'chapter'"/>
    <xsl:variable name="cClassAppendix" select="'appendix'"/>
    <xsl:variable name="cClassIndex" select="'index'"/>
    <xsl:variable name="cClassToc" select="'toc'"/>
    
    <!-- Part & Chapter Map -->
    <xsl:variable name="chapterMap">
        <xsl:call-template name="makeChapterMap"/>
    </xsl:variable>
    
    <!-- Thumb index map -->
    <xsl:variable name="thumbIndexMap">
        <xsl:call-template name="makeThumbIndexMap"/>
    </xsl:variable>
    
    <!-- 
     function:	make book chapter map template
     param:		none
     return:	chapter map node
     note:		Changed to store title from attribute to "title" element to realize multi-language processing.
                2015-08-23 t.makita
     -->
    <xsl:template name="makeChapterMap">
        <xsl:apply-templates select="/*/*[contains(@class, ' map/map ')]
                                       /*[contains(@class, ' map/topicref ')]
                                         [not(contains(@class, ' bookmap/appendices '))]
                                         [not(contains(@class, ' bookmap/frontmatter '))]
                                         [not(contains(@class, ' bookmap/backmatter '))]
                                   | /*/*[contains(@class, ' map/map ')]
                                       /*[contains(@class, ' bookmap/appendices ')]
                                       /*[contains(@class, ' bookmap/appendix ')]
                                   | /*/*[contains(@class, ' map/map ')]
                                       /*[contains(@class, ' bookmap/frontmatter ')]
                                      //*[contains(@class, ' bookmap/toc ')]
                                   | /*/*[contains(@class, ' map/map ')]
                                       /*[contains(@class, ' bookmap/backmatter ')]
                                      //*[contains(@class, ' bookmap/indexlist ')]"
                             mode="MAKE_CHAPTER_MAP">
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/toc ')]" mode="MAKE_CHAPTER_MAP" priority="2">
        <xsl:element name="chaptermap">
            <xsl:attribute name="id"/>
            <xsl:attribute name="class" select="$cClassToc"/>
            <xsl:attribute name="label" select="$cTocThumbnailLabel"/>
            <xsl:element name="title">
                <xsl:value-of select="$cTocThumbnailTitle"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/indexlist ')]" mode="MAKE_CHAPTER_MAP" priority="2">
        <xsl:element name="chaptermap">
            <xsl:attribute name="id"/>
            <xsl:attribute name="class" select="$cClassIndex"/>
            <xsl:attribute name="label" select="$cIndexThumbnailLabel"/>
            <xsl:element name="title">
                <xsl:value-of select="$cIndexThumbnailTitle"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MAKE_CHAPTER_MAP">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="linkContents" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="title" as="node()*">
            <xsl:choose>
                <xsl:when test="exists($linkContents)">
                    <xsl:variable name="title" as="element()" select="$linkContents/child::*[contains(@class, ' topic/title ')][1]"/>
                    <fo:inline>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsThumbIndexBlock'"/>
                            <xsl:with-param name="prmElem" select="$title"/>
                            <xsl:with-param name="prmDoInherit" select="true()"/>
                            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                        </xsl:call-template>
                        <xsl:apply-templates select="$title" mode="GET_CONTENTS">
                            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                        </xsl:apply-templates>
                    </fo:inline>
                </xsl:when>
                <xsl:when test="$topicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                    <xsl:variable name="navTitle" as="element()" select="$topicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')][1]"/>
                    <fo:inline>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsThumbIndexBlock'"/>
                            <xsl:with-param name="prmElem" select="$navTitle"/>
                            <xsl:with-param name="prmDoInherit" select="true()"/>
                            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                        </xsl:call-template>
                        <xsl:apply-templates select="$navTitle" mode="GET_CONTENTS">
                            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                        </xsl:apply-templates>
                    </fo:inline>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsThumbIndexBlock'"/>
                            <xsl:with-param name="prmElem" select="$topicRef"/>
                            <xsl:with-param name="prmDoInherit" select="true()"/>
                            <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                        </xsl:call-template>
                        <xsl:value-of select="@navtitle"/>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="id" select="ahf:generateId($topicRef,())"/>
        <xsl:variable name="class" as="xs:string">
            <xsl:choose>
                <xsl:when test="contains(@class, ' bookmap/part ')">
                    <xsl:sequence select="$cClassPart"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/chapter ')">
                    <xsl:sequence select="$cClassChapter"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/appendix ')">
                    <xsl:sequence select="$cClassAppendix"/>
                </xsl:when>
                <xsl:when test="contains(parent::*/@class, ' bookmap/part ')">
                    <xsl:sequence select="$cClassChapter"/>
                </xsl:when>
                <xsl:when test="contains(parent::*/@class, ' map/map ')">
                    <xsl:sequence select="$cClassChapter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes"
                                        select="ahf:replace($stMes700,('%class','%file'),(string(@class),string(@xtrf)))"/>
                    </xsl:call-template>
                    <xsl:sequence select="$cClassChapter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$class eq $cClassPart">
                <xsl:variable name="label" as="xs:string">
                    <xsl:variable name="partCount" as="xs:integer" select="count(preceding-sibling::*[contains(@class,' bookmap/part ')]|.)"/>
                    <xsl:variable name="partCountFormat" as="xs:string" select="ahf:getVarValue('Part_Count_Format')"/>
                    <xsl:number format="{$partCountFormat}" value="$partCount"/>
                </xsl:variable>
                <xsl:element name="chaptermap">
                    <xsl:attribute name="id" select="$id"/>
                    <xsl:attribute name="class" select="$class"/>
                    <xsl:attribute name="label" select="$label"/>
                    <xsl:element name="title">
                        <xsl:copy-of select="$title"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$class eq $cClassChapter">
                <xsl:variable name="label" as="xs:string">
                    <xsl:variable name="chapterCount" as="xs:integer" select="count(preceding-sibling::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/frontmatter '))]|.)"/>
                    <xsl:variable name="chapterCountFormat" as="xs:string" select="ahf:getVarValue('Chapter_Count_Format')"/>
                    <xsl:number format="{$chapterCountFormat}" value="$chapterCount"/>
                </xsl:variable>
                <xsl:element name="chaptermap">
                    <xsl:attribute name="id" select="$id"/>
                    <xsl:attribute name="class" select="$class"/>
                    <xsl:attribute name="label" select="$label"/>
                    <xsl:element name="title">
                        <xsl:copy-of select="$title"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$class eq $cClassAppendix">
                <xsl:variable name="label" as="xs:string">
                    <xsl:variable name="appendixCount" as="xs:integer" select="count(preceding-sibling::*[contains(@class,' bookmap/appendix ')]|.)"/>
                    <xsl:variable name="appendixCountFormat" as="xs:string" select="ahf:getVarValue('Appendix_Count_Format')"/>
                    <xsl:number format="{$appendixCountFormat}" value="$appendixCount"/>
                </xsl:variable>
                <xsl:element name="chaptermap">
                    <xsl:attribute name="id" select="$id"/>
                    <xsl:attribute name="class" select="$class"/>
                    <xsl:attribute name="label" select="$label"/>
                    <xsl:element name="title">
                        <xsl:copy-of select="$title"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	dump chapter map template
     param:		none
     return:	dump result
     note:		none
     -->
    <xsl:template name="dumpChapterMap">
        <xsl:for-each select="$chapterMap/*">
            <xsl:message select="'[dumpChapterMap] no=', position(), 'id=', string(@id), 'class=', string(@class), 'label=', string(@label), 'title=', title"/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	make thumb index map template
     param:		none
     return:	table start cout node
     note:		none
     -->
    <xsl:template name="makeThumbIndexMap">
        <!--xsl:call-template name="dumpBookChildMap"/-->
        <xsl:apply-templates select="$chapterMap/*[1]" mode="MAKE_THUMB_INDEX_MAP">
            <xsl:with-param name="prmOffset" select="0"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="chaptermap" mode="MAKE_THUMB_INDEX_MAP">
        <xsl:param name="prmOffset" required="yes" as="xs:integer"/>
    
        <xsl:variable name="indexOffset" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$prmOffset &lt; number($cThumbIndexMax)">
                    <xsl:sequence select="$prmOffset + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="thumbindex">
            <xsl:attribute name="index"><xsl:value-of select="$indexOffset"/></xsl:attribute>
            <xsl:copy-of select="@* | child::*"/>
        </xsl:element>
        
        <xsl:apply-templates select="following-sibling::chaptermap[1]" mode="MAKE_THUMB_INDEX_MAP">
            <xsl:with-param name="prmOffset" select="$indexOffset"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
     function:	dump thumb index map template
     param:		none
     return:	dump result
     note:		none
     -->
    <xsl:template name="dumpThumbIndexMap">
        <xsl:for-each select="$thumbIndexMap/*">
            <xsl:message select="'[dumpThumbIndexMap] no=',string(position()), 'id=', string(@id), 'class=', string(@class), 'label=', string(@label), 'index=', string(@index), 'title=', title"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>