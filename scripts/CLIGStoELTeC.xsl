<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xs h t"
    xmlns:h="http://www.w3.org/1999/xhtml" 
    xmlns:t="http://www.tei-c.org/ns/1.0"     
    xmlns="http://www.tei-c.org/ns/1.0" 
    version="2.0">
   
    <xsl:output encoding="UTF-8" exclude-result-prefixes="#all" omit-xml-declaration="yes"></xsl:output>
    
    <xsl:template match="processing-instruction('xml-stylesheet')"/>
    <xsl:template match="processing-instruction('xml-model')"/>
  
    <!-- first set up some variables -->
    
   <xsl:variable name="sex" select="substring(//t:term[@type='author-gender'],1,1)"/>
   <xsl:variable name="today" select="substring-before(string(current-dateTime()),'T')"/>
   <xsl:variable name="level"><xsl:text>eltec-1</xsl:text></xsl:variable>
   <xsl:variable name="date" select="//t:sourceDesc/t:bibl[@type='edition-first']/t:date"/>
    
    <xsl:variable name="timeSlot">
        <xsl:choose>
            <xsl:when test="$date le '1859'">T1</xsl:when>
            <xsl:when test="$date le '1879'">T2</xsl:when>
            <xsl:when test="$date le '1899'">T3</xsl:when>
            <xsl:when test="$date le '1920'">T4</xsl:when>            
        </xsl:choose></xsl:variable>
    
    <xsl:param name="wordCount">0</xsl:param>
    
    <xsl:variable name="size">
        <xsl:choose>
            <xsl:when test="$wordCount le '50000'">short</xsl:when>
            <xsl:when test="$wordCount le '150000'">medium</xsl:when>
            <xsl:when test="$wordCount gt '150000'">long</xsl:when>
            <xsl:otherwise>?</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="pageCount">
        <xsl:value-of select="count(t:text//t:pb)"/>
    </xsl:variable>
    
    <!-- process root element -->
    
    <xsl:template match="t:TEI">
        <xsl:variable name="id">
            <xsl:value-of select="//t:idno[@type='cligs']"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat('FR', substring($id,3,4))"/></xsl:attribute>
            <xsl:attribute name="xml:lang">fr</xsl:attribute>
            <xsl:apply-templates/>        
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:text[//t:note]">
        <text>
            <xsl:apply-templates/>
            <xsl:if test="not(t:back)">
                <back>  
                    <div type="notes">
                        <xsl:for-each select="//t:note">
                            <xsl:variable name="noteNum">
                                <xsl:value-of select="concat('N',position())"/>
                            </xsl:variable> 
                            <note xml:id="{$noteNum}">
                                <xsl:apply-templates/>
                            </note><xsl:text>
</xsl:text>          
                        </xsl:for-each>
                    </div>
                </back>
            </xsl:if>
        </text>
    </xsl:template>
    
<!-- assorted metadata tweaks in the header -->

    <xsl:template match="t:principal">
        <respStmt>
            <resp>principal</resp>
            <name><xsl:apply-templates/></name>
        </respStmt> 
    </xsl:template>
    
    <xsl:template match="t:titleStmt/t:title[@type='main']">
        <title>
            <xsl:if test="string-length(../t:title/t:idno) gt 1">
             <xsl:attribute name='ref'>
                    <xsl:text>viaf:</xsl:text>
                    <xsl:value-of select="../t:title/t:idno"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
            <xsl:if test='string-length(.)=0'>
            <xsl:text>[</xsl:text><xsl:value-of select="../t:title[@type='short']"/><xsl:text>]</xsl:text>
        </xsl:if>
            <xsl:if test="string-length(../t:title[@type='sub']) gt 1">
                <xsl:text> : </xsl:text>
                <xsl:value-of select="../t:title[@type='sub']"/>
            </xsl:if>
        <xsl:text> : ELTeC edition</xsl:text>
        </title>
    </xsl:template>
    
    <xsl:template match="t:titleStmt/t:title[not(@type='main')]"/>
        
    <xsl:template match="t:titleStmt/t:author">
        <author>
            <xsl:if test="string-length(t:idno) gt 1">
               <!-- <xsl:attribute name='ref'>
                    <xsl:text>viaf:</xsl:text>
                    <xsl:value-of select="t:idno"/>
                </xsl:attribute>-->
                <idno type="viaf"> <xsl:value-of select="t:idno"/></idno>
            </xsl:if>            
            <xsl:value-of select="t:name[@type='full']"/>
            <xsl:text>(? - ?)</xsl:text>
        </author>        
    </xsl:template>    
        
    <xsl:template match="t:titleStmt">
            <titleStmt>
                <xsl:apply-templates/>
            </titleStmt>
            <extent>    
                <measure unit="words"><xsl:value-of select="$wordCount"/>
                </measure>
                <measure unit="pages"><xsl:value-of select="$pageCount"/>
                </measure>
            </extent>
        </xsl:template>
    
    <xsl:template match="t:publicationStmt">
     <publicationStmt>   <p>Published as part of ELTeC <date><xsl:value-of select="$today"/></date></p>
  </publicationStmt>  </xsl:template>
    
    <xsl:template match="t:encodingDesc">
      <encodingDesc>  <xsl:attribute name="n"><xsl:value-of select="$level"/></xsl:attribute>
        <p/>
    </encodingDesc></xsl:template>
    
    <xsl:template match="t:abstract"/>
    
    <xsl:template match="t:profileDesc">
        <profileDesc>
            <langUsage><language ident="fra">French</language>
            </langUsage>
            <textDesc>
                <authorGender xmlns="http://distantreading.net/eltec/ns" key="{$sex}"></authorGender>
                <size xmlns="http://distantreading.net/eltec/ns" key="{$size}"></size>
                <canonicity xmlns="http://distantreading.net/eltec/ns" key="medium"></canonicity>
                <timeSlot xmlns="http://distantreading.net/eltec/ns" key="{$timeSlot}"></timeSlot>
            </textDesc>
        </profileDesc>    
    </xsl:template>
    
    <xsl:template match="t:revisionDesc">
    <revisionDesc>
        <change when="{$today}">Conversion with CLIGStoELTeC stylesheet for ELTeC-1</change>
        <xsl:apply-templates/>
    </revisionDesc>
    </xsl:template>

    <xsl:template match="t:change">
        <change when="{@when}">
            <xsl:value-of select="substring-after(@who,'#')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="."/>
        </change>
    </xsl:template>
    
     <!-- text retagging -->  
    
    <xsl:template match="t:front[t:div/t:p[string-length(.)=0]]"/>
    <xsl:template match="t:back[t:div/t:p[string-length(.)=0]]"/>
    
    
    <xsl:template match="t:body//t:div[not(t:div)]">
        <div>
            <xsl:attribute name="type">chapter</xsl:attribute>
         <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="t:body//t:div[t:div]">
        <div>
            <xsl:attribute name="type">part</xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- is it @type or @unit ? -->
    <xsl:template match="t:milestone">
        <milestone type="subChapter" rend='{@type}'/>
    </xsl:template>

    <xsl:template match="t:seg[@rend]">
        <hi><xsl:apply-templates/></hi>
    </xsl:template>
    <xsl:template match="t:seg[@type]">
        <hi><xsl:apply-templates/></hi>
    </xsl:template>
    <xsl:template match="t:floatingText">       
        <quote>
            <xsl:if test="@type">
                <xsl:attribute name="type" select="@type"/>
            </xsl:if>
            <xsl:apply-templates select="t:body/t:div/t:*"/>
        </quote>
    </xsl:template>

    <xsl:template match="t:body/t:div/t:head">
        <p><label><xsl:apply-templates/></label></p>
    </xsl:template>
 
    <xsl:template match="t:ab">
        <p><xsl:apply-templates/></p></xsl:template> 
    
  <xsl:template match="t:sp|t:lg">
      <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="t:speaker">
      <p><label><xsl:apply-templates/></label></p>
  </xsl:template>  
    
    <xsl:template match="t:note">
        <xsl:variable name="num">
            <xsl:value-of select="count(preceding::t:note)+1"/>
        </xsl:variable>
        <xsl:variable name="noteNum">
            <xsl:value-of select="concat('#N',$num)"/>
        </xsl:variable>
        <ref target="{$noteNum}"/>
    </xsl:template>
    
    <xsl:template match="t:back">
        <back>  
            <div type="notes">
            <xsl:for-each select="//t:note">
                <xsl:variable name="noteNum">
                    <xsl:value-of select="concat('N',position())"/>
                </xsl:variable> 
                <note xml:id="{$noteNum}">
                    <xsl:apply-templates/>
                </note><xsl:text>
</xsl:text>          
            </xsl:for-each>
        </div>
        <xsl:apply-templates/>
       </back>
    </xsl:template>
 
<!-- by default, copy everything -->
    
    <xsl:template match="* | @* | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="* | @* | processing-instruction() | comment() | text()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>