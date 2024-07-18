<?xml version="1.0" encoding="utf-8"?>
<!-- ********************************************************************************* -->
<!-- File:   df2fo-V21.xsl                                                             -->
<!-- Description: This stylesheet converts V2.1.0 compliant define.xml to fo format    -->
<!-- the stylesheet is adapted from define2-1-0.xsl file from CDISC XML V2.0 standard  -->
<!-- package                                                                           -->
<!-- Author: Victor Cao                                                                -->
<!-- ********************************************************************************* -->
<xsl:stylesheet
   version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:def="http://www.cdisc.org/ns/def/v2.1"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:arm="http://www.cdisc.org/ns/arm/v1.0"
   xmlns:fo="http://www.w3.org/1999/XSL/Format"
   xml:lang="en"
   exclude-result-prefixes="def xlink odm xsi arm fo"
   >
   <xsl:output method="xml" indent="yes" encoding="utf-8" version="1.0" />
   
   <!-- ********************************************************************************************************* -->
   <!--            Stylesheet Parameters - These parameters can be set in the XSLT processor.                     -->
   <!-- ********************************************************************************************************* -->
   
   <!-- Number of CodeListItems to display in Controlled Terms or Format column (default=5) 
        To display all CodeListItems, specify 999; to display no CodeListItems, specify 0. -->
   <xsl:param name="nCodeListItemDisplay" select="5" />
   <!-- Display Methods table (0/1)? -->
   <xsl:param name="displayMethodsTable" select="1" />
   <!-- Display Comments table (0/1)? -->
   <xsl:param name="displayCommentsTable" select="0" />
   <!-- Display Prefixes ([Comment], [Method], [Origin]) (0/1)? -->
   <xsl:param name="displayPrefix" select="0" />
   <!-- Display Length, DisplayFormat and Significant Digits (0/1)? -->
   <xsl:param name="displayLengthDFormatSD" select="0" />
   
   <!-- ********************************************************************************************************* -->
   <!--                                            Global Variables.                                              -->
   <!-- ********************************************************************************************************* -->
   <!-- Global Variables (constants) -->
   <xsl:variable name="STYLESHEET_VERSION" select="'2019-02-11'" />
   <!-- XSLT 1.0 does not support the function 'upper-case()', so we need to use the 'translate() function, 
        which uses the variables $lowercase and $uppercase. -->
   <xsl:variable name="LOWERCASE" select="'abcdefghijklmnopqrstuvwxyz'" />
   <xsl:variable name="UPPERCASE" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
   <xsl:variable name="REFTYPE_PHYSICALPAGE">PhysicalRef</xsl:variable>
   <xsl:variable name="REFTYPE_NAMEDDESTINATION">NamedDestination</xsl:variable>
   <xsl:variable name="Comparator_EQ">
      <fo:inline font-family="Arial Unicode MS">
         <text> = </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="Comparator_NE">
      <fo:inline font-family="Arial Unicode MS">
         <text> &#x2260; </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="Comparator_LT">
      <fo:inline font-family="Arial Unicode MS">
         <text> &lt; </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="Comparator_LE">
      <fo:inline font-family="Arial Unicode MS">
         <text> &#x2264; </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="Comparator_GT">
      <fo:inline font-family="Arial Unicode MS">
         <text> &gt; </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="Comparator_GE">
      <fo:inline font-family="Arial Unicode MS">
         <text> &#x2265; </text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="PREFIX_COMMENT_TEXT">
      <fo:inline xsl:use-attribute-sets="prefix">
         <xsl:text>[Comment] </xsl:text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="PREFIX_METHOD_TEXT">
      <fo:inline xsl:use-attribute-sets="prefix">
         <xsl:text>[Method]</xsl:text>
      </fo:inline>
   </xsl:variable>
   <xsl:variable name="PREFIX_ORIGIN_TEXT">
      <fo:inline xsl:use-attribute-sets="prefix">
         <xsl:text>[Origin] </xsl:text>
      </fo:inline>
   </xsl:variable>
   
   <!-- ******************************************************************** -->
   <!-- ******************** Global Variables (XPath) ********************** -->
   <!-- ******************************************************************** -->
   <xsl:variable name="g_StudyName" select="/odm:ODM/odm:Study[1]/odm:GlobalVariables[1]/odm:StudyName" />
   <xsl:variable name="g_StudyDescription" select="/odm:ODM/odm:Study[1]/odm:GlobalVariables[1]/odm:StudyDescription" />
   <xsl:variable name="g_ProtocolName" select="/odm:ODM/odm:Study[1]/odm:GlobalVariables[1]/odm:ProtocolName" />
   <xsl:variable name="g_MetaDataVersion" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion[1]" />
   <xsl:variable name="g_MetaDataVersionName" select="$g_MetaDataVersion/@Name" />
   <xsl:variable name="g_MetaDataVersionDescription" select="$g_MetaDataVersion/@Description" />
   <xsl:variable name="g_DefineVersion" select="$g_MetaDataVersion/@def:DefineVersion" />
   <xsl:variable name="g_seqStandard" select="$g_MetaDataVersion/def:Standards/def:Standard" />
   <xsl:variable name="g_seqItemGroupDefs" select="$g_MetaDataVersion/odm:ItemGroupDef" />
   <xsl:variable name="g_seqItemDefs" select="$g_MetaDataVersion/odm:ItemDef" />
   <xsl:variable name="g_seqItemDefsValueListRef" select="$g_MetaDataVersion/odm:ItemDef/def:ValueListRef" />
   <xsl:variable name="g_seqCodeLists" select="$g_MetaDataVersion/odm:CodeList" />
   <xsl:variable name="g_seqValueListDefs" select="$g_MetaDataVersion/def:ValueListDef" />
   <xsl:variable name="g_seqMethodDefs" select="$g_MetaDataVersion/odm:MethodDef" />
   <xsl:variable name="g_seqCommentDefs" select="$g_MetaDataVersion/def:CommentDef" />
   <xsl:variable name="g_seqWhereClauseDefs" select="$g_MetaDataVersion/def:WhereClauseDef" />
   <xsl:variable name="g_seqleafs" select="$g_MetaDataVersion/def:leaf" />
   <xsl:variable name="g_StandardName" select="$g_MetaDataVersion/def:Standards/def:Standard[1][@Type='IG']/@Name" />
   <xsl:variable name="g_StandardVersion" select="$g_MetaDataVersion/def:Standards/def:Standard[1][@Type='IG']/@Version" />
   
   <!-- ******************************************************************** -->
   <!-- *********************** General Colors ***************************** -->
   <!-- ******************************************************************** -->
   <xsl:variable name="COLOR_MENU_BODY_BACKGROUND">#FFFFFF</xsl:variable>
   <xsl:variable name="COLOR_MENU_BODY_FOREGROUND">#000000</xsl:variable>
   <xsl:variable name="COLOR_HMENU_TEXT">#004A95</xsl:variable>
   <xsl:variable name="COLOR_HMENU_BULLET">#AAAAAA</xsl:variable>
   <xsl:variable name="COLOR_CAPTION">#696969</xsl:variable>
   <xsl:variable name="COLOR_TABLE_BACKGROUND">#EEEEEE</xsl:variable>
   <xsl:variable name="COLOR_TR_HEADER_BACK">#6699CC</xsl:variable>
   <xsl:variable name="COLOR_TR_HEADER">#FFFFFF</xsl:variable>
   <xsl:variable name="COLOR_TABLEROW_ODD">#FFFFFF</xsl:variable>
   <xsl:variable name="COLOR_TABLEROW_EVEN">#EEEEEE</xsl:variable>
   <xsl:variable name="COLOR_TR_VLM_BACK">#D3D3D3</xsl:variable>
   <xsl:variable name="COLOR_BORDER">#000000</xsl:variable>
   <xsl:variable name="COLOR_ERROR">#000000</xsl:variable>
   <xsl:variable name="COLOR_WARNING">#000000</xsl:variable>
   <xsl:variable name="COLOR_LINK">#0000FF</xsl:variable>
   <xsl:variable name="COLOR_LINK_HOVER">#FF9900</xsl:variable>
   <xsl:variable name="COLOR_LINK_VISITED">#551A8B</xsl:variable>
   
   <!-- ******************************************************************** -->
   <!-- ********************** Define Global Styles ************************ -->
   <!-- ******************************************************************** -->
   <xsl:attribute-set name="body">
      <xsl:attribute name="font-size">62.5%</xsl:attribute>
      <xsl:attribute name="font-family">Verdana, Arial, Helvetica, sans-serif</xsl:attribute>
      <!-- <xsl:attribute name="font-family">Segoe UI</xsl:attribute> -->
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_MENU_BODY_BACKGROUND" />
      </xsl:attribute>
      <xsl:attribute name="color">black</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="docinfo">
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="text-align">right</xsl:attribute>
      <xsl:attribute name="padding">0px 5px</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="docinfo-line">
      <xsl:attribute name="font-size">1.1em</xsl:attribute>
      <xsl:attribute name="padding">2pt 5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="page">
      <xsl:attribute name="font-size">80%</xsl:attribute>
      <xsl:attribute name="font-family">Verdana, Arial, Helvetica, sans-serif</xsl:attribute>
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="link">
      <xsl:attribute name="text-decoration">underline</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_LINK" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="linebreakcell">
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="margin-top">3pt</xsl:attribute>
      <xsl:attribute name="margin-bottom">3pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="study-metadata">
      <xsl:attribute name="font-size">1.6em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="text-align">left</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="study-metadata-list">
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="font-size">0.8em</xsl:attribute>
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="padding">5pt 0pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="study-metadata-term">
      <xsl:attribute name="clear">left</xsl:attribute>
      <xsl:attribute name="float">left</xsl:attribute>
      <xsl:attribute name="padding">5pt 0pt 5pt 0pt</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="study-metadata-value">
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="min-height">20pt</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="prefix">
      <xsl:attribute name="font-weight">normal</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="unresolved">
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_ERROR" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="containerbox">
      <xsl:attribute name="margin">10px 0px</xsl:attribute>
      <!-- <xsl:attribute name="page-break-after">always</xsl:attribute> -->
   </xsl:attribute-set>
   <xsl:attribute-set name="table">
      <xsl:attribute name="table-layout">fixed</xsl:attribute>
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="border-spacing">4pt</xsl:attribute>
      <xsl:attribute name="border">1px solid <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLE_BACKGROUND" />
      </xsl:attribute>
      <xsl:attribute name="margin-top">5pt</xsl:attribute>
      <xsl:attribute name="border-collapse">collapse</xsl:attribute>
      <xsl:attribute name="empty-cells">show</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="dataset-table">
      <xsl:attribute name="table-layout">fixed</xsl:attribute>
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="border-spacing">4pt</xsl:attribute>
      <xsl:attribute name="border">1px solid <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLE_BACKGROUND" />
      </xsl:attribute>
      <xsl:attribute name="border-collapse">collapse</xsl:attribute>
      <xsl:attribute name="empty-cells">show</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-caption">
      <xsl:attribute name="left">20pt</xsl:attribute>
      <xsl:attribute name="font-size">1.4em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
      <xsl:attribute name="margin">10px auto</xsl:attribute>
      <xsl:attribute name="text-align">left</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="caption-header-left">
      <xsl:attribute name="font-size">1.6em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="text-align">left</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-caption-header">
      <xsl:attribute name="font-size">1.6em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="text-align">center</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-tr">
      <xsl:attribute name="border">
         <xsl:text>1px solid </xsl:text>
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-tr-header">
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TR_HEADER_BACK" />
      </xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_TR_HEADER" />
      </xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-th">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="border"> 1px solid <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="font-size">1.3em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-td">
      <xsl:attribute name="line-height">150%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="border"> 
         <xsl:text>1px solid </xsl:text>
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-tr-odd">
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLEROW_ODD" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-tr-even">
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLEROW_EVEN" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-summary">
      <xsl:attribute name="border-spacing">5pt</xsl:attribute>
      <xsl:attribute name="border-width">1pt</xsl:attribute>
      <xsl:attribute name="border-color">
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="border-style">solid solid none solid</xsl:attribute>
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLEROW_EVEN" />
      </xsl:attribute>
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
      <xsl:attribute name="line-height">150%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-summary-resultdisplay">
      <xsl:attribute name="margin">0</xsl:attribute>
      <xsl:attribute name="padding">10pt</xsl:attribute>
      <xsl:attribute name="border-color">
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="border-spacing">5pt</xsl:attribute>
      <xsl:attribute name="border-width">1pt</xsl:attribute>
      <xsl:attribute name="border-style">none none solid none</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-label">
      <xsl:attribute name="line-height">150%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="border"> 
         <xsl:text>1px solid </xsl:text>
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="font-size">1.3em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-display-title">
      <xsl:attribute name="padding-left">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-summary-result">
      <xsl:attribute name="margin">5pt 20pt 5pt 0pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="analysisresults-detail">
      <xsl:attribute name="table-layout">fixed</xsl:attribute>
      <xsl:attribute name="background-color"> 
         <xsl:value-of select="$COLOR_TABLEROW_EVEN" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-analysisresult">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="color"> 
         <xsl:value-of select="$COLOR_TR_HEADER" />
      </xsl:attribute>
      <xsl:attribute name="background-color"> 
         <xsl:value-of select="$COLOR_TR_HEADER_BACK" />
      </xsl:attribute>
      <xsl:attribute name="border"> 
         <xsl:text>1px solid </xsl:text>
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-displaylabel">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-displaytitle">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="font-size">1.1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-resultlabel">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="text-align">left</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="border"> 1px solid <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="font-size">1.3em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-resulttitle">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-analysisvariable">
      <xsl:attribute name="margin-top">5pt</xsl:attribute>
      <xsl:attribute name="margin-bottom">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-code-context">
      <xsl:attribute name="padding">5pt 0pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-code">
      <xsl:attribute name="font-family">"Courier New", monospace, serif</xsl:attribute>
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
      <xsl:attribute name="line-height">120%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="white-space">pre</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="arm-code-ref">
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
      <xsl:attribute name="line-height">150%</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="super">
      <xsl:attribute name="vertical-align">super</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="valuelist-reference">
      <xsl:attribute name="vertical-align">super</xsl:attribute>
      <xsl:attribute name="font-size">0.8em</xsl:attribute>
      <xsl:attribute name="padding-left">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="valuelist-no-reference">
      <xsl:attribute name="vertical-align">super</xsl:attribute>
      <xsl:attribute name="font-size">0.8em</xsl:attribute>
      <xsl:attribute name="padding-left">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="nci">
      <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="extended">
      <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="footnote">
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="description">
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="font-size">0.85em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="formalexpression">
      <xsl:attribute name="font-family">"Courier New", monospace, serif</xsl:attribute>
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
      <xsl:attribute name="line-height">120%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt 0 0 20pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="method-code">
      <xsl:attribute name="vertical-align">top</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="formalexpression-code">
      <xsl:attribute name="font-family">"Courier New", monospace, serif</xsl:attribute>
      <xsl:attribute name="font-size">1em</xsl:attribute>
      <xsl:attribute name="line-height">120%</xsl:attribute>
      <xsl:attribute name="vertical-align">top</xsl:attribute>
      <xsl:attribute name="padding">5pt 0 0 20pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="formalexpression-reference">
      <xsl:attribute name="font-size">0.8em</xsl:attribute>
      <xsl:attribute name="vertical-align">super</xsl:attribute>
      <xsl:attribute name="padding-left">5pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="codelist-caption">
      <xsl:attribute name="font-size">1.4em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="text-align">left</xsl:attribute>
      <xsl:attribute name="margin">20pt 0pt 10pt 0pt</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="codelist">
      <xsl:attribute name="page-break-after">avoid</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="label">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="codelist-item-decode"> </xsl:attribute-set>
   <xsl:attribute-set name="dataset">
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="float">right</xsl:attribute>
      <xsl:attribute name="alignment-baseline">after-edge</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="supp_parent_link">
      <xsl:attribute name="background-color">
         <xsl:value-of select="$COLOR_TABLEROW_EVEN" />
      </xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="margin">0 0.05em - 1pt</xsl:attribute>
      <xsl:attribute name="border"> 
         <xsl:text>1px solid </xsl:text>
         <xsl:value-of select="$COLOR_BORDER" />
      </xsl:attribute>
      <xsl:attribute name="border-style">1px 1px none 1px</xsl:attribute>
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="font-size">1.2em</xsl:attribute>
   </xsl:attribute-set>
   
   <!-- ******************************************************************** -->
   <!-- ******** Create Bookmarks and initialize page dimensions *********** -->
   <!-- ******************************************************************** -->
   <xsl:template match="/">
      <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"
               xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">
         <fo:layout-master-set>
            <fo:simple-page-master page-height="300mm" page-width="400mm" margin="5mm 5mm 1cm 5mm" master-name="PageMaster">
               <fo:region-body margin="5mm 5mm 5mm 5mm" />
               <fo:region-before extent="0mm" />
               <fo:region-after extent="5mm" />
            </fo:simple-page-master>
         </fo:layout-master-set>
         
         <!--  ******************************************************************** -->
         <!--  ************************* Generate Bookmarks *********************** -->
         <!--  ******************************************************************** -->
         <xsl:call-template name="generateMenu" />
         
         <!--  ******************************************************************** -->
         <!--  ************************ Generate Contents Page ******************** -->
         <!--  ******************************************************************** -->
         <fo:page-sequence master-reference="PageMaster">
            <fo:static-content flow-name="xsl-region-before">
               <fo:block></fo:block>
            </fo:static-content>
            <fo:static-content flow-name="xsl-region-after">
               <fo:block text-align="end" xsl:use-attribute-sets="page">
                  <xsl:text>Page </xsl:text>
                  <fo:page-number />
               </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body">
               <fo:block xsl:use-attribute-sets="body" id="main">
                  <xsl:call-template name="generateMain" />
               </fo:block>
            </fo:flow>
         </fo:page-sequence>
      </fo:root>
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- **************  Create the Main Content ************ -->
   <!-- **************************************************** -->
   <xsl:template name="generateMain">
      
      <!-- Display Document Info -->
      <fo:block xsl:use-attribute-sets="docinfo">
         <xsl:call-template name="displayODMCreationDateTimeDate" />
         <xsl:call-template name="displayDefineXMLVersion" />
         <xsl:call-template name="displayContext" />
         <xsl:call-template name="displayStylesheetDate" />
      </fo:block>
      
      <!-- Display Study metadata -->
      <xsl:call-template name="tableStudyMetadata">
         <xsl:with-param name="g_StandardName" select="$g_StandardName" />
         <xsl:with-param name="g_StandardVersion" select="$g_StandardVersion" />
         <xsl:with-param name="g_StudyName" select="$g_StudyName" />
         <xsl:with-param name="g_StudyDescription" select="$g_StudyDescription" />
         <xsl:with-param name="g_ProtocolName" select="$g_ProtocolName" />
         <xsl:with-param name="g_MetaDataVersionName" select="$g_MetaDataVersionName" />
         <xsl:with-param name="g_MetaDataVersionDescription" select="$g_MetaDataVersionDescription" />
      </xsl:call-template>
      
      <!-- ***************************************************************** -->
      <!-- Create the Standards Table                                        -->
      <!-- ***************************************************************** -->
      <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/def:Standards">
         <xsl:call-template name="tableStandards" />    
      </xsl:if>
      
      <!-- ***************************************************************** -->
      <!-- Create the ADaM Results Metadata Tables                           -->
      <!-- ***************************************************************** -->
      <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays">
         <xsl:call-template name="tableAnalysisResultsSummary" />
         <xsl:call-template name="tableAnalysisResultsDetails" />
      </xsl:if>
      
      <!-- ***************************************************************** -->
      <!-- Create the Data Definition Tables                                 -->
      <!-- ***************************************************************** -->
      <xsl:call-template name="tableItemGroups" />
      
      <!-- ***************************************************************** -->
      <!-- Detail for the Data Definition Tables                             -->
      <!-- ***************************************************************** -->
      <xsl:for-each select="$g_seqItemGroupDefs">
         <xsl:call-template name="tableItemDefs" />
      </xsl:for-each>
      
      <!-- ***************************************************************** -->
      <!-- Create the Code Lists, Enumerated Items and External Dictionaries -->
      <!-- ***************************************************************** -->
      <xsl:call-template name="tableCodeLists" />
      <xsl:call-template name="tableExternalCodeLists" />
      
      <!-- ***************************************************************** -->
      <!-- Create the Methods                                                -->
      <!-- ***************************************************************** -->
      <xsl:if test="$displayMethodsTable = '1'">
         <xsl:call-template name="tableMethods" />
      </xsl:if>
      
      <!-- ***************************************************************** -->
      <!-- Create the Comments                                               -->
      <!-- ***************************************************************** -->
      <xsl:if test="$displayCommentsTable = '1'">
         <xsl:call-template name="tableComments" />
      </xsl:if>
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- **************  Create the Bookmarks  ************** -->
   <!-- **************************************************** -->
   <xsl:template name="generateMenu">
      <fo:bookmark-tree>
         <fo:bookmark starting-state="hide" internal-destination="Standards_table">
            <fo:bookmark-title>
               <xsl:text>Study </xsl:text>
               <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName" />
            </fo:bookmark-title>
            
            <!-- *************************************************************** -->
            <!-- ***************************** aCRF **************************** -->
            <!-- *************************************************************** -->
            <xsl:choose>
               <xsl:when test="$g_MetaDataVersion/def:AnnotatedCRF">
                  <xsl:for-each select="$g_MetaDataVersion/def:AnnotatedCRF/def:DocumentRef">
                     <xsl:variable name="leafIDs" select="@leafID" />
                     <xsl:variable name="leaf" select="../../def:leaf[@ID=$leafIDs]" />
                     <xsl:variable name="leafID" select="$leaf/@ID" />
                     <fo:bookmark starting-state="hide">
                        <xsl:attribute name="internal-destination">
                           <xsl:value-of select="$leaf/@xlink:href" />
                        </xsl:attribute>
                        <fo:bookmark-title>
                           <xsl:value-of select="$leaf/def:title" />
                        </fo:bookmark-title>
                     </fo:bookmark>
                  </xsl:for-each>
               </xsl:when>
               <xsl:otherwise> 
                  <xsl:for-each select="$g_MetaDataVersion/def:leaf">
                     <xsl:variable name="leafID" select="@ID" />
                     <!-- Define-XML v2.0: @Type='CRF', Define-XML v2.1: @Type='Collected' -->
                     <xsl:if test="$g_seqItemDefs/def:Origin[@Type='CRF' or @Type='Collected']/def:DocumentRef[@leafID=$leafID]">
                        <fo:bookmark starting-state="hide">
                           <xsl:attribute name="internal-destination">
                              <xsl:value-of select="@xlink:href" />
                           </xsl:attribute>
                           <fo:bookmark-title>
                              <xsl:value-of select="def:title" />
                           </fo:bookmark-title>
                        </fo:bookmark>
                     </xsl:if> 
                  </xsl:for-each>
               </xsl:otherwise>
            </xsl:choose>
            
            <!-- *************************************************************** -->
            <!-- ******************** Supplemental Documents ******************* -->
            <!-- *************************************************************** -->
            <xsl:if test="$g_MetaDataVersion/def:SupplementalDoc">
               <fo:bookmark starting-state="hide" internal-destination="xxx">
                  <fo:bookmark-title>
                     <xsl:text>Supplemental Documents </xsl:text>
                  </fo:bookmark-title>
                  <xsl:for-each select="$g_MetaDataVersion/def:SupplementalDoc/def:DocumentRef">
                     <xsl:variable name="leafIDs" select="@leafID" />
                     <xsl:variable name="leaf" select="../../def:leaf[@ID=$leafIDs]" />
                     <xsl:variable name="leafID" select="$leaf/@ID" />
                     
                     <xsl:choose>
                        <!-- Only display when the document is not part of the def:AnnotatedCRF container 
                             or linked from an ItemDef/def:Origin/def:DocumentRef -->
                        <xsl:when test="$g_MetaDataVersion/def:AnnotatedCRF/def:DocumentRef[@leafID=$leafID]" />
                        <xsl:otherwise>
                           <xsl:choose>
                              <xsl:when test="../../def:leaf[@ID=$leafIDs]">
                                 <fo:bookmark starting-state="hide">
                                    <xsl:attribute name="internal-destination">
                                       <xsl:value-of select="$leaf/@xlink:href" />
                                    </xsl:attribute>
                                    <fo:bookmark-title>
                                       <xsl:value-of select="$leaf/def:title" />
                                    </fo:bookmark-title>
                                 </fo:bookmark>
                              </xsl:when>
                              <xsl:otherwise>
                                 <fo:bookmark starting-state="hide">
                                    <fo:bookmark-title xsl:use-attribute-sets="unresolved">
                                       <xsl:text>[unresolved: </xsl:text>
                                       <xsl:value-of select="$leafIDs" />
                                       <xsl:text>]</xsl:text>
                                    </fo:bookmark-title>
                                 </fo:bookmark>
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:for-each>
               </fo:bookmark>
            </xsl:if>
            
            <!-- *************************************************************** -->
            <!-- ************************ Standards **************************** -->
            <!-- *************************************************************** -->
            <xsl:if test="$g_MetaDataVersion/def:Standards">
               <fo:bookmark starting-state="hide" internal-destination="Standards_table">
                  <fo:bookmark-title>
                     <xsl:text>Standards </xsl:text>
                  </fo:bookmark-title>
               </fo:bookmark>
            </xsl:if>
            
            <!-- *************************************************************** -->
            <!-- **************************** ARM ****************************** -->
            <!-- *************************************************************** -->
            <xsl:if test="$g_MetaDataVersion/arm:AnalysisResultDisplays">
               <fo:bookmark starting-state="hide" internal-destination="ARM_Table_Summary">
                  <fo:bookmark-title>
                     <xsl:text>Analysis Results Metadata </xsl:text>
                  </fo:bookmark-title>
                  <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay">
                     <fo:bookmark starting-state="hide">
                        <xsl:attribute name="internal-destination">ARD.<xsl:value-of select="@OID" /></xsl:attribute>
                        <fo:bookmark-title>
                           <xsl:value-of select="@Name" />
                        </fo:bookmark-title>
                     </fo:bookmark>
                  </xsl:for-each>
               </fo:bookmark>
            </xsl:if>
            
            <!-- ************************************************************** -->
            <!-- ***************************** Datasets *********************** -->
            <!-- ************************************************************** -->
            <fo:bookmark starting-state="hide" internal-destination="Datasets_table">
               <fo:bookmark-title>
                  <xsl:text>Datasets </xsl:text>
               </fo:bookmark-title>
               <xsl:for-each select="$g_seqItemGroupDefs">
                  <fo:bookmark starting-state="hide">
                     <xsl:attribute name="internal-destination">IG.<xsl:value-of select="@OID" />
                     </xsl:attribute>
                     <fo:bookmark-title>
                        <xsl:value-of select="concat(@Name, ' (',./odm:Description/odm:TranslatedText, ')')" />
                     </fo:bookmark-title>
                  </fo:bookmark>
               </xsl:for-each>
            </fo:bookmark>
            
            <!-- ************************************************************** -->
            <!-- ***************************** Code Lists ********************* -->
            <!-- ************************************************************** -->
            <xsl:if test="$g_seqCodeLists">
               <fo:bookmark starting-state="hide" internal-destination="decodelist">
                  <fo:bookmark-title>Controlled Terminology</fo:bookmark-title>
                  <xsl:if test="$g_seqCodeLists[odm:CodeListItem|odm:EnumeratedItem]">
                     <fo:bookmark starting-state="hide" internal-destination="decodelist">
                        <fo:bookmark-title>CodeLists </fo:bookmark-title>
                        <xsl:for-each select="$g_seqCodeLists[odm:CodeListItem|odm:EnumeratedItem]">
                           <fo:bookmark starting-state="hide">
                              <xsl:attribute name="internal-destination">CL.<xsl:value-of select="@OID" />
                              </xsl:attribute>
                              <fo:bookmark-title>
                                 <xsl:value-of select="@Name" />
                              </fo:bookmark-title>
                           </fo:bookmark>
                        </xsl:for-each>
                     </fo:bookmark>
                  </xsl:if>
                  <xsl:if test="$g_seqCodeLists[odm:ExternalCodeList]">
                     <fo:bookmark starting-state="hide" internal-destination="externaldictionary">
                        <fo:bookmark-title>External Dictionaries </fo:bookmark-title>
                        <xsl:for-each select="$g_seqCodeLists[odm:ExternalCodeList]">
                           <fo:bookmark starting-state="hide">
                              <xsl:attribute name="internal-destination">CL.<xsl:value-of select="@OID" />
                              </xsl:attribute>
                              <fo:bookmark-title>
                                 <xsl:value-of select="@Name" />
                              </fo:bookmark-title>
                           </fo:bookmark>
                        </xsl:for-each>
                     </fo:bookmark>
                  </xsl:if>
               </fo:bookmark>
            </xsl:if>
            
            <!-- ************************************************************** -->
            <!-- ****************************** Methods *********************** -->
            <!-- ************************************************************** -->
            <xsl:if test="$displayMethodsTable = '1'">
               <xsl:if test="$g_seqMethodDefs">
                  <fo:bookmark starting-state="hide" internal-destination="compmethod">
                     <fo:bookmark-title>Methods</fo:bookmark-title>
                     <xsl:for-each select="$g_seqMethodDefs">
                        <fo:bookmark starting-state="hide">
                           <xsl:attribute name="internal-destination">MT.<xsl:value-of select="@OID" />
                           </xsl:attribute>
                           <fo:bookmark-title>
                              <xsl:value-of select="@Name" />
                           </fo:bookmark-title>
                        </fo:bookmark>
                     </xsl:for-each>
                  </fo:bookmark>
               </xsl:if>
            </xsl:if>
            
            <!-- ************************************************************** -->
            <!-- ****************************** Comments ********************** -->
            <!-- ************************************************************** -->
            <xsl:if test="$displayCommentsTable = '1'">
               <xsl:if test="$g_seqCommentDefs">
                  <fo:bookmark starting-state="hide" internal-destination="comment">
                     <fo:bookmark-title>Comments</fo:bookmark-title>
                     <xsl:for-each select="$g_seqCommentDefs">
                        <fo:bookmark starting-state="hide">
                           <xsl:attribute name="internal-destination">COMM.<xsl:value-of select="@OID" />
                           </xsl:attribute>
                           <fo:bookmark-title>
                              <xsl:value-of select="@OID" />
                           </fo:bookmark-title>
                        </fo:bookmark>
                     </xsl:for-each>
                  </fo:bookmark>
               </xsl:if>
            </xsl:if>
         </fo:bookmark>
      </fo:bookmark-tree>
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Display Study Metadata                               -->
   <!-- **************************************************** -->
   <xsl:template name="tableStudyMetadata">
      <xsl:param name="g_StandardName" />
      <xsl:param name="g_StandardVersion" />
      <xsl:param name="g_StudyName" />
      <xsl:param name="g_StudyDescription" />
      <xsl:param name="g_ProtocolName" />
      <xsl:param name="g_MetaDataVersionName" />
      <xsl:param name="g_MetaDataVersionDescription" />
      
      <fo:block xsl:use-attribute-sets="study-metadata">
         <fo:list-block
            provisional-distance-between-starts="130pt"
            provisional-label-separation="0pt"
            xsl:use-attribute-sets="study-metadata-list">
            <xsl:if test="$g_MetaDataVersion/@def:StandardName">
               <fo:list-item>
                  <fo:list-item-label end-indent="label-end()">
                     <fo:block xsl:use-attribute-sets="study-metadata-term">Standard</fo:block>
                  </fo:list-item-label>
                  <fo:list-item-body start-indent="body-start()">
                     <fo:block xsl:use-attribute-sets="study-metadata-value">
                        <xsl:value-of select="$g_StandardName" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$g_StandardVersion" />
                     </fo:block>
                  </fo:list-item-body>
               </fo:list-item>
            </xsl:if>
            <fo:list-item>
               <fo:list-item-label end-indent="label-end()">
                  <fo:block xsl:use-attribute-sets="study-metadata-term">Study Name</fo:block>
               </fo:list-item-label>
               <fo:list-item-body start-indent="body-start()">
                  <fo:block xsl:use-attribute-sets="study-metadata-value">
                     <xsl:value-of select="$g_StudyName" />
                  </fo:block>
               </fo:list-item-body>
            </fo:list-item>
            <fo:list-item>
               <fo:list-item-label end-indent="label-end()">
                  <fo:block xsl:use-attribute-sets="study-metadata-term">Study Description</fo:block>
               </fo:list-item-label>
               <fo:list-item-body start-indent="body-start()">
                  <fo:block xsl:use-attribute-sets="study-metadata-value">
                     <xsl:value-of select="$g_StudyDescription" />
                  </fo:block>
               </fo:list-item-body>
            </fo:list-item>
            <fo:list-item>
               <fo:list-item-label end-indent="label-end()">
                  <fo:block xsl:use-attribute-sets="study-metadata-term">Protocol Name</fo:block>
               </fo:list-item-label>
               <fo:list-item-body start-indent="body-start()">
                  <fo:block xsl:use-attribute-sets="study-metadata-value">
                     <xsl:value-of select="$g_ProtocolName" />
                  </fo:block>
               </fo:list-item-body>
            </fo:list-item>
            <fo:list-item>
               <fo:list-item-label end-indent="label-end()">
                  <fo:block xsl:use-attribute-sets="study-metadata-term">Metadata Name</fo:block>
               </fo:list-item-label>
               <fo:list-item-body start-indent="body-start()">
                  <fo:block xsl:use-attribute-sets="study-metadata-value">
                     <xsl:value-of select="$g_MetaDataVersionName" />
                  </fo:block>
               </fo:list-item-body>
            </fo:list-item>
            <xsl:if test="$g_MetaDataVersionDescription">
               <fo:list-item>
                  <fo:list-item-label end-indent="label-end()">
                     <fo:block xsl:use-attribute-sets="study-metadata-term">Metadata Description</fo:block>
                  </fo:list-item-label>
                  <fo:list-item-body start-indent="body-start()">
                     <fo:block xsl:use-attribute-sets="study-metadata-value">
                        <xsl:value-of select="$g_MetaDataVersionDescription" />
                     </fo:block>
                  </fo:list-item-body>
               </fo:list-item>
            </xsl:if>
         </fo:list-block>
         <!--  Define-XML v2.1 -->
         <xsl:if test="$g_MetaDataVersion/@def:CommentOID">
            <fo:block>
               <xsl:call-template name="displayComment">
                  <xsl:with-param name="CommentOID" select="$g_MetaDataVersion/@def:CommentOID" />
                  <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                  <xsl:with-param name="element" select="'fo:block'" />
               </xsl:call-template>
            </fo:block>
         </xsl:if>
      </fo:block>
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Display Standards Metadata (Define-XML v2.1)         -->
   <!-- **************************************************** -->
   <xsl:template name="tableStandards">
      <fo:block xsl:use-attribute-sets="containerbox">
         <fo:block id="Standards_table" xsl:use-attribute-sets="table-caption-header">
            <xsl:text> Standards for Study </xsl:text>
            <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName" />
         </fo:block>
         <fo:table xsl:use-attribute-sets="table">
            <fo:table-column column-width="32%" />
            <fo:table-column column-width="9%" />
            <fo:table-column column-width="9%" />
            <fo:table-column column-width="50%" />
            <fo:table-header xsl:use-attribute-sets="table-tr-header">
               <fo:table-row xsl:use-attribute-sets="table-tr-header">
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Standard</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Type</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Status</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Documentation</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-header>
            <fo:table-body>
               <xsl:for-each select="$g_seqStandard">
                  <xsl:call-template name="tableRowStandards" />
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
      </fo:block>
      <xsl:call-template name="lineBreak" />
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Template: TableRowStandards (Define-XML v2.1)        -->
   <!-- **************************************************** -->
   <xsl:template name="tableRowStandards">
      <xsl:element name="fo:table-row">
         <xsl:call-template name="setRowClassOddeven">
            <xsl:with-param name="rowNum" select="position()" />
         </xsl:call-template>
         <!-- Create an anchor -->
         <xsl:attribute name="id">STD.<xsl:value-of select="@OID" /></xsl:attribute>
         
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="@Name" />
               <xsl:text> </xsl:text>
               <xsl:if test="@PublishingSet">
                  <xsl:value-of select="@PublishingSet" />
                  <xsl:text> </xsl:text>
               </xsl:if>
               <xsl:value-of select="@Version" />
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="@Type" />
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="@Status" />
            </fo:block>
         </fo:table-cell>
         
         <!-- ************************************************ -->
         <!-- Comments                                         -->
         <!-- ************************************************ -->
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:call-template name="displayComment">
                  <xsl:with-param name="CommentOID" select="@def:CommentOID" />
                  <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
               </xsl:call-template>
            </fo:block>
         </fo:table-cell>
      </xsl:element>
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Analysis Results Summary                             -->
   <!-- **************************************************** -->
   <xsl:template name="tableAnalysisResultsSummary">
      <fo:block xsl:use-attribute-sets="containerbox">
         <fo:block id="ARM_Table_Summary" xsl:use-attribute-sets="caption-header-left">
            <xsl:text> Analysis Results Metadata - Summary </xsl:text>
            <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName" />
         </fo:block>
         <fo:block xsl:use-attribute-sets="arm-summary" margin-top="5pt">
            <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay">
               <xsl:variable name="DisplayOID" select="@OID" />
               <xsl:variable name="DisplayName" select="@Name" />
               <xsl:variable name="Display" select="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay[@OID=$DisplayOID]" />
               <fo:block xsl:use-attribute-sets="arm-summary-resultdisplay">
                  <fo:basic-link xsl:use-attribute-sets="link">
                     <xsl:attribute name="internal-destination">
                        <xsl:text>ARD.</xsl:text>
                        <xsl:value-of select="$DisplayOID" />
                     </xsl:attribute>
                     <xsl:value-of select="$DisplayName" />
                  </fo:basic-link>
                  <fo:inline xsl:use-attribute-sets="arm-display-title">
                     <xsl:value-of select="./odm:Description/odm:TranslatedText" />
                  </fo:inline>
                  <!-- list each analysis result linked to the respective rows in the detail tables-->
                  <xsl:for-each select="./arm:AnalysisResult">
                     <xsl:variable name="AnalysisResultID" select="./@OID" />
                     <xsl:variable name="AnalysisResult" select="$Display/arm:AnalysisResults[@OID=$AnalysisResultID]" />
                     <fo:block xsl:use-attribute-sets="arm-summary-result">
                        <fo:inline padding-left="20pt">
                           <fo:basic-link xsl:use-attribute-sets="link">
                              <xsl:attribute name="internal-destination">
                                 <xsl:text>AR.</xsl:text>
                                 <xsl:value-of select="$AnalysisResultID" />
                              </xsl:attribute>
                              <xsl:value-of select="./odm:Description/odm:TranslatedText" />
                           </fo:basic-link>
                        </fo:inline>
                     </fo:block>
                  </xsl:for-each>
               </fo:block>
            </xsl:for-each>
         </fo:block>
      </fo:block>
      <xsl:call-template name="lineBreak" />
   </xsl:template>
   
   <!-- **************************************************** -->
   <!--  Analysis Results Details                            -->
   <!-- **************************************************** -->
   <xsl:template name="tableAnalysisResultsDetails">
      <fo:block xsl:use-attribute-sets="caption-header-left">
         <xsl:text> Analysis Results Metadata - Detail </xsl:text>
      </fo:block>
      <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay">
         <fo:block xsl:use-attribute-sets="containerbox">
            <xsl:variable name="DisplayOID" select="@OID" />
            <xsl:variable name="DisplayName" select="@Name" />
            <xsl:variable name="Display" select="/odm:ODM/odm:Study/odm:MetaDataVersion/arm:AnalysisResultDisplays/arm:ResultDisplay[@OID=$DisplayOID]" />
            <xsl:attribute name="id">
               <xsl:text>ARD.</xsl:text>
               <xsl:value-of select="$DisplayOID" />
            </xsl:attribute>
            <fo:block xsl:use-attribute-sets="table-caption">
               <xsl:value-of select="$DisplayName" />
            </fo:block>
            <fo:table xsl:use-attribute-sets="analysisresults-detail">
               <fo:table-column column-width="20%" />
               <fo:table-column column-width="80%" />
               <fo:table-header>
                  <fo:table-row>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block xsl:use-attribute-sets="arm-displaytitle">Display</fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block xsl:use-attribute-sets="arm-displaytitle">
                           <xsl:for-each select="def:DocumentRef">
                              <xsl:call-template name="displayDocumentRef">
                                 <xsl:with-param name="element" select="'fo:inline'" />
                              </xsl:call-template>
                           </xsl:for-each>
                           <xsl:text> </xsl:text>
                           <fo:inline>
                              <xsl:value-of select="$Display/odm:Description/odm:TranslatedText" />
                           </fo:inline>
                        </fo:block>
                     </fo:table-cell>
                  </fo:table-row>
               </fo:table-header>
               <fo:table-body>
                  <xsl:for-each select="$Display/arm:AnalysisResult">
                     <xsl:variable name="AnalysisResultOID" select="@OID" />
                     <xsl:variable name="AnalysisResult" select="$Display/arm:AnalysisResult[@OID=$AnalysisResultOID]" />
                     <fo:table-row xsl:use-attribute-sets="table-tr-header">
                        <fo:table-cell xsl:use-attribute-sets="table-th">
                           <fo:block>Analysis Result</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-th">
                           <fo:block>
                              <!--  add an identifier to Analysis Results xsl:value-of select="OID"/-->
                              <fo:inline xsl:use-attribute-sets="arm-resulttitle">
                                 <xsl:attribute name="id">AR.<xsl:value-of select="$AnalysisResultOID" /></xsl:attribute>
                                 <xsl:value-of select="odm:Description/odm:TranslatedText" />
                              </fo:inline>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <xsl:variable name="ParameterOID" select="$AnalysisResult/@ParameterOID" />
                     <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="arm-label">
                           <fo:block>Analysis Parameter(s)</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:if test="$ParameterOID">
                                 <xsl:if test="count($g_seqItemDefs[@OID=$ParameterOID]) = 0">
                                    <fo:inline xsl:use-attribute-sets="unresolved">
                                       <xsl:text>[unresolved: </xsl:text>
                                       <xsl:value-of select="$ParameterOID" />
                                       <xsl:text>]</xsl:text>
                                    </fo:inline>
                                 </xsl:if>
                              </xsl:if>
                              <xsl:for-each select="$AnalysisResult/arm:AnalysisDatasets/arm:AnalysisDataset">
                                 <xsl:variable name="WhereClauseOID" select="def:WhereClauseRef/@WhereClauseOID" />
                                 <xsl:variable name="WhereClauseDef" select="$g_seqWhereClauseDefs[@OID=$WhereClauseOID]" />
                                 <xsl:variable name="ItemGroupOID" select="@ItemGroupOID" />
                                 <!--  Get the RangeCheck associated with the parameter (typically only one ...) --> 
                                 <xsl:for-each select="$WhereClauseDef/odm:RangeCheck[@def:ItemOID=$ParameterOID]">
                                    <xsl:variable name="whereRefItemOID" select="./@def:ItemOID" />
                                    <xsl:variable name="whereRefItemName" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@Name" />
                                    <xsl:variable name="whereRefItemDataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                                    <xsl:variable name="whereOP" select="./@Comparator" />
                                    <xsl:variable name="whereRefItemCodeListOID"
                                                  select="$g_seqItemDefs[@OID=$whereRefItemOID]/odm:CodeListRef/@CodeListOID" />
                                    <xsl:variable name="whereRefItemCodeList"
                                                  select="$g_seqCodeLists[@OID=$whereRefItemCodeListOID]" />
                                    
                                    <xsl:call-template name="ItemGroupItemLink">
                                       <xsl:with-param name="ItemGroupOID" select="$ItemGroupOID" />
                                       <xsl:with-param name="ItemOID" select="$whereRefItemOID" />
                                       <xsl:with-param name="ItemName" select="$whereRefItemName" />
                                    </xsl:call-template> 
                                    
                                    <xsl:choose>
                                       <xsl:when test="$whereOP = 'IN' or $whereOP = 'NOTIN'">
                                          <xsl:text> </xsl:text>
                                          <xsl:variable name="Nvalues" select="count(./odm:CheckValue)" />
                                          <xsl:choose>
                                             <xsl:when test="$whereOP='IN'">
                                                <xsl:text> IN </xsl:text>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                <xsl:text> NOT IN </xsl:text>
                                             </xsl:otherwise>
                                          </xsl:choose>
                                          <xsl:text> (</xsl:text>
                                          <xsl:for-each select="./odm:CheckValue">
                                             <xsl:variable name="CheckValueINNOTIN" select="." />
                                             <fo:block xsl:use-attribute-sets="linebreakcell">
                                                <xsl:call-template name="displayValue">
                                                   <xsl:with-param name="Value" select="$CheckValueINNOTIN" />
                                                   <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                                                   <xsl:with-param name="decode" select="1" />
                                                   <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                                                </xsl:call-template>
                                                <xsl:if test="position() != $Nvalues">
                                                   <xsl:value-of select="', '" />
                                                </xsl:if>
                                             </fo:block>
                                          </xsl:for-each><xsl:text> ) </xsl:text>
                                       </xsl:when>
                                       <xsl:when test="$whereOP = 'EQ'">
                                          <xsl:variable name="CheckValueEQ" select="./odm:CheckValue" />
                                          <xsl:text> = </xsl:text>
                                          <xsl:call-template name="displayValue">
                                             <xsl:with-param name="Value" select="$CheckValueEQ" />
                                             <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                                             <xsl:with-param name="decode" select="1" />
                                             <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                                          </xsl:call-template>
                                       </xsl:when>
                                       <xsl:when test="$whereOP = 'NE'">
                                          <xsl:variable name="CheckValueNE" select="./odm:CheckValue" />
                                          <xsl:text> &#x2260; </xsl:text>
                                          <xsl:call-template name="displayValue">
                                             <xsl:with-param name="Value" select="$CheckValueNE" />
                                             <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                                             <xsl:with-param name="decode" select="1" />
                                             <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                                          </xsl:call-template>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:variable name="CheckValueOTH" select="./odm:CheckValue" />
                                          <xsl:text> </xsl:text>
                                          <xsl:choose>
                                             <xsl:when test="$whereOP='LT'">
                                                <xsl:text> &lt; </xsl:text>
                                             </xsl:when>
                                             <xsl:when test="$whereOP='LE'">
                                                <xsl:text> &lt;= </xsl:text>
                                             </xsl:when>
                                             <xsl:when test="$whereOP='GT'">
                                                <xsl:text> &gt; </xsl:text>
                                             </xsl:when>
                                             <xsl:when test="$whereOP='GE'">
                                                <xsl:text> &gt;= </xsl:text>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                <xsl:value-of select="$whereOP" />
                                             </xsl:otherwise>
                                          </xsl:choose>
                                          <xsl:call-template name="displayValue">
                                             <xsl:with-param name="Value" select="$CheckValueOTH" />
                                             <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                                             <xsl:with-param name="decode" select="1" />
                                             <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                                          </xsl:call-template>                        
                                       </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="position() != last()">
                                       <xsl:text> and </xsl:text>
                                    </xsl:if>
                                 </xsl:for-each>
                                 <!--  END - Get the RangeCheck associated with the parameter (typically only one ...) --> 
                              </xsl:for-each>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="arm-label">
                           <fo:block>Analysis Variable(s)</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:for-each select="arm:AnalysisDatasets/arm:AnalysisDataset">
                                 <xsl:variable name="ItemGroupOID" select="@ItemGroupOID" />
                                 <xsl:for-each select="arm:AnalysisVariable">
                                    <xsl:variable name="ItemOID" select="@ItemOID" />
                                    <xsl:variable name="ItemDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$ItemOID]" />
                                    <fo:block xsl:use-attribute-sets="arm-analysisvariable">
                                       <xsl:choose>
                                          <xsl:when test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]">
                                             <fo:basic-link xsl:use-attribute-sets="link">
                                                <xsl:attribute name="internal-destination">
                                                   <xsl:value-of select="$ItemGroupOID" />
                                                </xsl:attribute>
                                                <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/@Name" />
                                             </fo:basic-link>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <fo:inline xsl:use-attribute-sets="unresolved">
                                                <xsl:text>[unresolved: </xsl:text>
                                                <xsl:value-of select="$ItemGroupOID" />
                                                <xsl:text>]</xsl:text>
                                             </fo:inline>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                       <xsl:text>.</xsl:text>
                                       <xsl:choose>
                                          <xsl:when test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID] and /odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$ItemOID]">
                                             <fo:basic-link xsl:use-attribute-sets="link">
                                                <xsl:attribute name="internal-destination">
                                                   <xsl:value-of select="$ItemGroupOID" />.<xsl:value-of select="$ItemOID" />
                                                </xsl:attribute>
                                                <xsl:value-of select="$ItemDef/@Name" />
                                             </fo:basic-link>
                                             <xsl:text> (</xsl:text>
                                             <xsl:value-of select="$ItemDef/odm:Description/odm:TranslatedText" />
                                             <xsl:text>) </xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <fo:inline xsl:use-attribute-sets="unresolved">
                                                <xsl:text>[unresolved: </xsl:text>
                                                <xsl:value-of select="$ItemOID" />
                                                <xsl:text>]</xsl:text>
                                             </fo:inline>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                    </fo:block>
                                 </xsl:for-each>
                              </xsl:for-each>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="arm-label">
                           <fo:block>Analysis Reason</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="$AnalysisResult/@AnalysisReason" />
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="arm-label">
                           <fo:block>Analysis Purpose</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="$AnalysisResult/@AnalysisPurpose" />
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="arm-label">
                           <fo:block>Data References (incl. Selection Criteria)</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:for-each select="$AnalysisResult/arm:AnalysisDatasets/arm:AnalysisDataset">
                                 <xsl:variable name="ItemGroupOID" select="@ItemGroupOID" />
                                 <xsl:variable name="ItemGroupDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]" />
                                 <fo:block>
                                    <xsl:choose>
                                       <xsl:when test="$ItemGroupDef/@OID">
                                          <fo:basic-link xsl:use-attribute-sets="link">
                                             <xsl:attribute name="internal-destination">
                                                <xsl:value-of select="$ItemGroupDef/@OID" />
                                             </xsl:attribute>
                                             <xsl:value-of select="$ItemGroupDef/@Name" />
                                          </fo:basic-link>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <fo:inline xsl:use-attribute-sets="unresolved">
                                             <xsl:text>[unresolved: </xsl:text>
                                             <xsl:value-of select="$ItemGroupOID" />
                                             <xsl:text>]</xsl:text>
                                          </fo:inline>
                                       </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>  [</xsl:text>
                                    <xsl:call-template name="displayWhereClause">
                                       <xsl:with-param name="ValueItemRef"
                                                       select="$AnalysisResult/arm:AnalysisDatasets/arm:AnalysisDataset[@ItemGroupOID=$ItemGroupOID]" />
                                       <xsl:with-param name="ItemGroupLink" select="$ItemGroupOID" />
                                       <xsl:with-param name="decode" select="0" />
                                       <xsl:with-param name="break" select="0" />
                                    </xsl:call-template>
                                    <xsl:text>]</xsl:text>
                                 </fo:block>
                              </xsl:for-each>
                              <xsl:for-each select="$AnalysisResult/arm:AnalysisDatasets">
                                 <xsl:call-template name="displayComment">
                                    <xsl:with-param name="CommentOID" select="@def:CommentOID" />
                                    <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                                 </xsl:call-template>
                              </xsl:for-each>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                     <xsl:for-each select="$AnalysisResult/arm:Documentation">
                        <fo:table-row>
                           <fo:table-cell xsl:use-attribute-sets="arm-label">
                              <fo:block>Documentation</fo:block>
                           </fo:table-cell>
                           <fo:table-cell xsl:use-attribute-sets="table-td">
                              <fo:block>
                                 <fo:inline>
                                    <xsl:value-of select="$AnalysisResult/arm:Documentation/odm:Description/odm:TranslatedText" />
                                 </fo:inline>
                                 <xsl:for-each select="def:DocumentRef">
                                    <xsl:call-template name="displayDocumentRef" />
                                 </xsl:for-each>
                              </fo:block>
                           </fo:table-cell>
                        </fo:table-row>
                     </xsl:for-each>
                     <xsl:for-each select="$AnalysisResult/arm:ProgrammingCode">
                        <fo:table-row>
                           <fo:table-cell xsl:use-attribute-sets="arm-label">
                              <fo:block>Programming Statements</fo:block>
                           </fo:table-cell>
                           <fo:table-cell xsl:use-attribute-sets="table-td">
                              <fo:block>
                                 <xsl:if test="@Context">
                                    <fo:inline xsl:use-attribute-sets="arm-code-context">[<xsl:value-of select="@Context" />]</fo:inline>
                                 </xsl:if>
                                 <xsl:if test="arm:Code">
                                    <fo:wrapper xsl:use-attribute-sets="arm-code">
                                       <fo:block>
                                          <xsl:value-of select="arm:Code" />
                                       </fo:block>
                                    </fo:wrapper>
                                 </xsl:if>
                                 <fo:block xsl:use-attribute-sets="arm-code-ref">
                                    <xsl:for-each select="def:DocumentRef">
                                       <xsl:call-template name="displayDocumentRef" />
                                    </xsl:for-each>
                                 </fo:block>
                              </fo:block>
                           </fo:table-cell>
                        </fo:table-row>
                     </xsl:for-each>
                  </xsl:for-each>
               </fo:table-body>
            </fo:table>
         </fo:block>
         <!-- <xsl:call-template name="linkTop" /> -->
         <xsl:call-template name="lineBreak" />
         
      </xsl:for-each>
      <xsl:call-template name="lineBreak" />
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Template: TableItemGroups                            -->
   <!-- **************************************************** -->
   <xsl:template name="tableItemGroups">
      <fo:block xsl:use-attribute-sets="table-caption-header" id="Datasets_table"> Datasets </fo:block>
      <fo:block xsl:use-attribute-sets="containerbox">
         <fo:table xsl:use-attribute-sets="table">
            <fo:table-column column-width="14%" />
            <fo:table-column column-width="10%" />
            <xsl:choose>
               <xsl:when test="$g_seqItemGroupDefs/def:Class/def:SubClass/@Name">
                  <fo:table-column column-width="14%" />
               </xsl:when>
               <xsl:otherwise>
                  <fo:table-column column-width="10%" />
               </xsl:otherwise>
            </xsl:choose>
            <fo:table-column column-width="12%" />
            <fo:table-column column-width="6%" />
            <fo:table-column column-width="12%" />
            <xsl:choose>
               <xsl:when test="$g_seqItemGroupDefs/def:Class/def:SubClass/@Name">
                  <fo:table-column column-width="25%" />
               </xsl:when>
               <xsl:otherwise>
                  <fo:table-column column-width="29%" />
               </xsl:otherwise>
            </xsl:choose>
            <fo:table-column column-width="7%" />
            <fo:table-header xsl:use-attribute-sets="table-tr-header">
               <fo:table-row xsl:use-attribute-sets="table-tr-header">
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Dataset</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Description</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>
                        <xsl:text>Class</xsl:text>
                        <xsl:if test="$g_seqItemGroupDefs/def:Class/def:SubClass/@Name">
                           <xsl:text> - SubClass</xsl:text>
                        </xsl:if>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Structure</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Purpose</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Keys</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Documentation</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Location</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-header>
            <fo:table-body>
               <xsl:for-each select="$g_seqItemGroupDefs">
                  <xsl:call-template name="tableRowItemGroupDefs" />
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
      </fo:block>
      <!-- <xsl:call-template name="linkTop" /> -->
      <xsl:call-template name="lineBreak" />
   </xsl:template>
   
   <!-- **************************************************** -->
   <!-- Template: TableRowItemGroupDefs                      -->
   <!-- **************************************************** -->
   <xsl:template name="tableRowItemGroupDefs">
      
      <fo:table-row xsl:use-attribute-sets="table-tr-header">
         <xsl:call-template name="setRowClassOddeven">
            <xsl:with-param name="rowNum" select="position()" />
         </xsl:call-template>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:attribute name="id"><xsl:value-of select="@OID" /></xsl:attribute>
               <fo:basic-link xsl:use-attribute-sets="link">
                  <xsl:attribute name="internal-destination">
                     <xsl:text>IG.</xsl:text>
                     <xsl:value-of select="@OID" />
                  </xsl:attribute>
                  <xsl:value-of select="@Name" />
               </fo:basic-link>
               <!--  Define-XML v2.1 -->
               <xsl:call-template name="displayStandard">
                  <xsl:with-param name="element" select="'fo:inline'" />
               </xsl:call-template>
               <!--  Define-XML v2.1 -->
               <xsl:call-template name="displayNonStandard">
                  <xsl:with-param name="element" select="'fo:inline'" />
               </xsl:call-template>
               <!--  Define-XML v2.1 -->
               <xsl:call-template name="displayNoData">
                  <xsl:with-param name="element" select="'fo:inline'" />
               </xsl:call-template>
            </fo:block>
         </fo:table-cell>
         <!-- *************************************************************** -->
         <!-- Link each ItemGroup to its corresponding section in the define  -->
         <!-- *************************************************************** -->
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="odm:Description/odm:TranslatedText" />
               <xsl:variable name="ParentDescription">
                  <xsl:call-template name="getParentDescription">
                     <xsl:with-param name="OID" select="@OID" />
                  </xsl:call-template>  
               </xsl:variable>
               <xsl:if test="string-length(normalize-space($ParentDescription)) &gt; 0">
                  <xsl:text> (</xsl:text><xsl:value-of select="$ParentDescription" /><xsl:text>)</xsl:text>
               </xsl:if>
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:call-template name="displayItemGroupClass" />
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="@def:Structure" />
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:value-of select="@Purpose" />
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:call-template name="displayItemGroupKeys" />
            </fo:block>
         </fo:table-cell>
         <!-- ************************************************ -->
         <!-- Comments                                         -->
         <!-- ************************************************ -->
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:call-template name="displayComment">
                  <xsl:with-param name="CommentOID" select="@def:CommentOID" />
                  <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
               </xsl:call-template>
            </fo:block>
         </fo:table-cell>
         <!-- **************************************************** -->
         <!-- Link each Dataset to its corresponding archive file  -->
         <!-- **************************************************** -->
         <xsl:variable name="archiveLocationID" select="@def:ArchiveLocationID" />
         <xsl:variable name="archiveTitle">
            <xsl:choose>
               <xsl:when test="def:leaf[@ID=$archiveLocationID]"><xsl:value-of select="def:leaf[@ID=$archiveLocationID]/def:title" /></xsl:when>
               <xsl:otherwise><xsl:text>[unresolved: </xsl:text><xsl:value-of select="@def:ArchiveLocationID" /><xsl:text>]</xsl:text></xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <fo:table-cell xsl:use-attribute-sets="table-td">
            <fo:block>
               <xsl:if test="@def:ArchiveLocationID">
                  <xsl:call-template name="displayHyperlink">
                     <xsl:with-param name="href" select="def:leaf[@ID=$archiveLocationID]/@xlink:href" />
                     <xsl:with-param name="anchor" select="''" />
                     <xsl:with-param name="title" select="$archiveTitle" />
                  </xsl:call-template>
               </xsl:if>
            </fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>
   
   <!-- ************************************************************ -->
   <!-- Template: tabelItemDefs                                      -->
   <!-- ************************************************************ -->
   <xsl:template name="tableItemDefs">
      <fo:block xsl:use-attribute-sets="containerbox">
         <xsl:attribute name="id">
            <xsl:text>IG.</xsl:text>
            <xsl:value-of select="@OID" />
         </xsl:attribute>
         <fo:block xsl:use-attribute-sets="table-caption">
            <fo:block text-align-last="justify">
               <xsl:call-template name="displayItemGroupDefHeader" />
            </fo:block>
         </fo:block>
         
         <!-- *************************************************** -->
         <!-- Link to SUPPXX or SQAPXX domain                     -->
         <!-- For those domains with Suplemental Qualifiers       -->
         <!-- *************************************************** -->
         <xsl:call-template name="linkSuppQual" />
         <xsl:call-template name="linkSQAP" />
         
         <!-- *************************************************** -->
         <!-- Link to Parent domain                               -->
         <!-- For those domains that are Suplemental Qualifiers   -->
         <!-- *************************************************** -->
         <xsl:call-template name="linkParentDomain" />
         <xsl:call-template name="linkApParentDomain" />
         <fo:table xsl:use-attribute-sets="dataset-table">
            <xsl:variable name="nItemsWithVLM"><xsl:value-of select="count(./odm:ItemRef[@ItemOID=$g_seqItemDefsValueListRef/../@OID])" /></xsl:variable>
            <xsl:variable name="isSuppQual">
               <xsl:choose>
                  <xsl:when test="starts-with(@Name, 'SUPP') or starts-with(@Name, 'SQAP')">1</xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
               </xsl:choose>              
            </xsl:variable>
            <xsl:variable name="addRoleColumn">
               <xsl:choose>
                  <xsl:when test="count(./odm:ItemRef/@Role) > 0 or $isSuppQual='1'">1</xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
               </xsl:choose>              
            </xsl:variable>
            <xsl:variable name="addConditionColumn">
               <xsl:choose>
                  <xsl:when test="$nItemsWithVLM > 0 and $isSuppQual='0'">1</xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
               </xsl:choose>              
            </xsl:variable>
            
            <!-- Table Columns Width -->
            <xsl:choose>
               <xsl:when test="$addConditionColumn='1' and $addRoleColumn='1'">
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="18%" />
                  <fo:table-column column-width="10%" />
                  <fo:table-column column-width="5%" />
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="12%" />
                  <fo:table-column column-width="17%" />
                  <fo:table-column column-width="22%" />
               </xsl:when>
               <xsl:when test="$addConditionColumn='1'">
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="18%" />
                  <fo:table-column column-width="15%" />
                  <fo:table-column column-width="6%" />
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="15%" />
                  <fo:table-column column-width="30%" />
               </xsl:when>
               <xsl:when test="$addRoleColumn='1'">
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="15%" />
                  <fo:table-column column-width="6%" />
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="10%" />
                  <fo:table-column column-width="20%" />
                  <fo:table-column column-width="33%" />
               </xsl:when>
               <xsl:otherwise>
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="15%" />
                  <fo:table-column column-width="6%" />
                  <fo:table-column column-width="8%" />
                  <fo:table-column column-width="24%" />
                  <fo:table-column column-width="39%" />
               </xsl:otherwise>
            </xsl:choose>
            <fo:table-header xsl:use-attribute-sets="table-tr-header">
               <!-- Main Table -->
               <fo:table-row xsl:use-attribute-sets="table-tr-header">
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block> Variable </fo:block>
                  </fo:table-cell>
                  <xsl:if test="$addConditionColumn='1'">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block>Where Condition</fo:block>
                     </fo:table-cell>
                  </xsl:if>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Label / Description</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block> Type</fo:block>
                  </fo:table-cell>
                  <xsl:if test="$addRoleColumn='1'">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block>Role</fo:block>
                     </fo:table-cell>
                  </xsl:if>
                  <xsl:choose>
                     <xsl:when test="$displayLengthDFormatSD='1'">
                        <fo:table-cell xsl:use-attribute-sets="table-th">
                           <fo:block>Length [SignificantDigits] : Display Format</fo:block>
                        </fo:table-cell>
                     </xsl:when>
                     <xsl:otherwise>
                        <fo:table-cell xsl:use-attribute-sets="table-th">
                           <fo:block>Length or Display Format</fo:block>
                        </fo:table-cell>
                     </xsl:otherwise>
                  </xsl:choose>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Controlled Terms or ISO Format</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Origin / Source / Method / Comment</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-header>
            <fo:table-body> 
               <!-- Get the individual data points -->
               <xsl:for-each select="./odm:ItemRef">
                  <xsl:sort data-type="number" order="ascending" select="@OrderNumber" />
                  <xsl:variable name="ItemRef" select="." />
                  <xsl:variable name="ItemDefOID" select="@ItemOID" />
                  <xsl:variable name="ItemGroupDefOID" select="../@OID" />
                  <xsl:variable name="ItemDef" select="../../odm:ItemDef[@OID=$ItemDefOID]" />      
                  
                  <xsl:variable name="VLMClass">
                     <xsl:choose>
                        <xsl:when test="position() mod 2 = 0">
                           <xsl:text>tableroweven</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:text>tablerowodd</xsl:text>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable> 
                  
                  <fo:table-row>
                     <xsl:call-template name="setRowClassOddeven">
                        <xsl:with-param name="rowNum" select="position()" />
                     </xsl:call-template>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:choose>
                              <xsl:when test="$ItemDef/def:ValueListRef/@ValueListOID">
                                 <xsl:value-of select="$ItemDef/@Name" />
                                 <xsl:choose>
                                    <xsl:when test="$g_seqValueListDefs[@OID = $ItemDef/def:ValueListRef/@ValueListOID]">
                                       <fo:inline xsl:use-attribute-sets="valuelist-reference">
                                          <fo:inline xsl:use-attribute-sets="link">
                                             <xsl:attribute name="id">
                                                <xsl:value-of select="../@OID" />.<xsl:value-of select="$ItemDef/@OID" />
                                             </xsl:attribute>
                                             <xsl:text>VLM</xsl:text>
                                          </fo:inline>
                                       </fo:inline>
                                    </xsl:when>
                                    <xsl:otherwise>
                                       <fo:inline xsl:use-attribute-sets="valuelist-no-reference">
                                          <fo:inline xsl:use-attribute-sets="unresolved">
                                             <xsl:text>[unresolved: VLM]</xsl:text>
                                          </fo:inline>
                                       </fo:inline>
                                    </xsl:otherwise>
                                 </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:choose>
                                    <xsl:when test="$ItemDef">
                                       <!-- Make unique anchor link to Variable Name -->
                                       <fo:block>
                                          <xsl:attribute name="id">
                                             <xsl:value-of select="../@OID" />.<xsl:value-of select="$ItemDef/@OID" />
                                          </xsl:attribute>
                                       </fo:block>
                                       <xsl:value-of select="$ItemDef/@Name" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                       <fo:inline xsl:use-attribute-sets="unresolved">
                                          <xsl:text>[unresolved: </xsl:text>
                                          <xsl:value-of select="$ItemDefOID" />
                                          <xsl:text>]</xsl:text>
                                       </fo:inline>
                                    </xsl:otherwise>
                                 </xsl:choose>
                              </xsl:otherwise>
                           </xsl:choose>
                           <!--  Define-XML v2.1 -->
                           <xsl:call-template name="displayNonStandard">
                              <xsl:with-param name="element" select="'fo:inline'" />
                           </xsl:call-template>
                           <!--  Define-XML v2.1 -->
                           <xsl:call-template name="displayNoData">
                              <xsl:with-param name="element" select="'fo:inline'" />
                           </xsl:call-template>
                        </fo:block>
                     </fo:table-cell>
                     <xsl:if test="$addConditionColumn='1'">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block></fo:block>
                        </fo:table-cell>
                     </xsl:if>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:value-of select="$ItemDef/odm:Description/odm:TranslatedText" />
                        </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:value-of select="$ItemDef/@DataType" />
                        </fo:block>
                     </fo:table-cell>
                     <xsl:if test="$addRoleColumn='1'">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="@Role" />
                           </fo:block>
                        </fo:table-cell>
                     </xsl:if>
                     <xsl:choose>
                        <xsl:when test="$displayLengthDFormatSD='1'">
                           <fo:table-cell xsl:use-attribute-sets="table-td" text-align="right">
                              <fo:block>
                                 <xsl:call-template name="displayItemDefLengthSignDigitsDisplayFormat">
                                    <xsl:with-param name="ItemDef" select="$ItemDef" />
                                 </xsl:call-template>
                              </fo:block>
                           </fo:table-cell>
                        </xsl:when>
                        <xsl:otherwise>
                           <fo:table-cell xsl:use-attribute-sets="table-td" text-align="right">
                              <fo:block>
                                 <xsl:call-template name="displayItemDefLengthDFormat">
                                    <xsl:with-param name="ItemDef" select="$ItemDef" />
                                 </xsl:call-template>
                              </fo:block>
                           </fo:table-cell>
                        </xsl:otherwise>
                     </xsl:choose>
                     
                     <!-- *************************************************** -->
                     <!-- Hypertext Link to the Decode Appendix               -->
                     <!-- *************************************************** -->
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:call-template name="displayItemDefDecodeList">
                              <xsl:with-param name="itemDef" select="$ItemDef" />
                           </xsl:call-template>
                           <xsl:call-template name="displayItemDefISO8601">
                              <xsl:with-param name="itemDef" select="$ItemDef" />
                           </xsl:call-template>
                        </fo:block>
                     </fo:table-cell>
                     
                     <!-- *************************************************** -->
                     <!-- Origin / Source / Method / Comment              -->
                     <!-- *************************************************** -->
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:call-template name="displayItemDefOrigin">
                              <xsl:with-param name="itemDef" select="$ItemDef" />
                              <xsl:with-param name="OriginPrefix" select="$displayPrefix" />
                           </xsl:call-template>
                           <xsl:call-template name="displayItemDefMethod">
                              <xsl:with-param name="MethodOID" select="$ItemRef/@MethodOID" />
                              <xsl:with-param name="MethodPrefix" select="$displayPrefix" />
                           </xsl:call-template>
                           <xsl:call-template name="displayComment">
                              <xsl:with-param name="CommentOID" select="$ItemDef/@def:CommentOID" />
                              <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                           </xsl:call-template>
                        </fo:block>
                     </fo:table-cell>
                  </fo:table-row>
                  <xsl:if test="$ItemDef/def:ValueListRef/@ValueListOID">
                     <xsl:call-template name="tableValueListsInTable">
                        <xsl:with-param name="OID"
                                        select="$ItemDef/def:ValueListRef/@ValueListOID" />
                        <xsl:with-param name="ParentItemDefOID"
                                        select="concat($ItemGroupDefOID, '.', $ItemDefOID)" />
                        <xsl:with-param name="addRoleColumn"
                                        select="$addRoleColumn" />
                        <xsl:with-param name="isSuppQual"
                                        select="$isSuppQual" />
                        <xsl:with-param name="VLMClass"
                                        select="$VLMClass" />
                     </xsl:call-template>
                  </xsl:if>
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
      </fo:block>
      <!-- <xsl:call-template name="linkTop" /> -->
      <xsl:call-template name="lineBreak" />
   </xsl:template>
   
   <!-- ************************************************************************* -->
   <!-- Template: TableValueList InLine (handles the def:ValueListDef elements    -->
   <!-- ************************************************************************* -->
   <xsl:template name="tableValueListsInTable">
      
      <xsl:param name="OID" />
      <xsl:param name="ParentItemDefOID" />
      <xsl:param name="addRoleColumn" />
      <xsl:param name="isSuppQual" />
      <xsl:param name="VLMClass" />
      
      <xsl:for-each select="$g_seqValueListDefs[@OID=$OID]">
         <!-- Get the individual data points -->
         <xsl:for-each select="./odm:ItemRef">
            
            <xsl:sort data-type="number" order="ascending" select="@OrderNumber" />
            
            <xsl:variable name="ItemRef" select="." />
            <xsl:variable name="valueDefOID" select="@ItemOID" />
            <xsl:variable name="valueDef" select="../../odm:ItemDef[@OID=$valueDefOID]" />
            
            <xsl:variable name="vlOID" select="../@OID" />
            <xsl:variable name="parentDef" select="../../odm:ItemDef/def:ValueListRef[@ValueListOID=$vlOID]" />
            <xsl:variable name="parentOID" select="$parentDef/../@OID" />
            <xsl:variable name="ParentVName" select="$parentDef/../@Name" />
            
            <xsl:variable name="ValueItemGroupOID"
                          select="$g_seqItemGroupDefs/odm:ItemRef[@ItemOID=$parentOID]/../@OID" />
            
            <xsl:variable name="whereOID" select="./def:WhereClauseRef/@WhereClauseOID" />
            <xsl:variable name="whereDef" select="$g_seqWhereClauseDefs[@OID=$whereOID]" />
            <xsl:variable name="whereRefItemOID" select="$whereDef/odm:RangeCheck/@def:ItemOID" />
            <xsl:variable name="whereRefItem"
                          select="$g_seqItemDefs[@OID=$whereRefItemOID]/@Name" />
            <xsl:variable name="whereOP" select="$whereDef/odm:RangeCheck/@Comparator" />
            <xsl:variable name="whereVal" select="$whereDef/odm:RangeCheck/odm:CheckValue" />
            
            <fo:table-row>
               <xsl:choose>
                  <xsl:when test="$VLMClass='tableroweven'"> 
                     <xsl:attribute name="background-color">
                        <xsl:value-of select="$COLOR_TABLEROW_EVEN" /> 
                     </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise> 
                     <xsl:attribute name="background-color">
                        <xsl:value-of select="$COLOR_TABLEROW_ODD" />
                     </xsl:attribute>
                  </xsl:otherwise>
               </xsl:choose>
               <!-- Source Variable column -->
               <fo:table-cell xsl:use-attribute-sets="table-td">
                  <xsl:if test="$isSuppQual='0'"> <fo:block></fo:block></xsl:if>
                  <xsl:if test="$isSuppQual='1'">
                     <fo:block margin-left="20pt">
                        <fo:inline font-family="Arial Unicode MS">
                           <xsl:text>&#x27A4;  </xsl:text>
                        </fo:inline>
                        <xsl:call-template name="displayWhereClause">
                           <xsl:with-param name="ValueItemRef" select="$ItemRef" />
                           <xsl:with-param name="ItemGroupLink" select="$ValueItemGroupOID" />
                           <xsl:with-param name="decode" select="0" />
                           <xsl:with-param name="break" select="1" />
                        </xsl:call-template>
                     </fo:block>
                  </xsl:if>
                  <xsl:if test="$isSuppQual='2'">
                     <fo:block margin-left="40pt">
                        <fo:inline font-family="Arial Unicode MS">
                           <xsl:text>&#x27A4;  </xsl:text>
                        </fo:inline>
                        <xsl:call-template name="displayWhereClause">
                           <xsl:with-param name="ValueItemRef" select="$ItemRef" />
                           <xsl:with-param name="ItemGroupLink" select="$ValueItemGroupOID" />
                           <xsl:with-param name="decode" select="1" />
                           <xsl:with-param name="break" select="1" />
                        </xsl:call-template>
                     </fo:block>  
                  </xsl:if>
                  
                  <!--  Define-XML v2.1 -->
                  <fo:block>
                     <xsl:call-template name="displayNoData">
                        <xsl:with-param name="element" select="'fo:inline'" />
                     </xsl:call-template>
                  </fo:block>     
               </fo:table-cell> 
               
               <!-- 'WhereClause' column -->
               <xsl:if test="$isSuppQual='0'">
                  <fo:table-cell xsl:use-attribute-sets="table-td">
                     <fo:block>
                        <xsl:call-template name="displayWhereClause">
                           <xsl:with-param name="ValueItemRef" select="$ItemRef" />
                           <xsl:with-param name="ItemGroupLink" select="$ValueItemGroupOID" />
                           <xsl:with-param name="decode" select="1" />
                           <xsl:with-param name="break" select="1" />
                        </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
               </xsl:if> 
               
               <!-- Label column for SuppQuals -->
               <xsl:choose>
                  <xsl:when test="$isSuppQual='1'">
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:if test="$valueDef/odm:Description/odm:TranslatedText">
                              <xsl:value-of select="$valueDef/odm:Description/odm:TranslatedText" />
                           </xsl:if>
                        </fo:block>
                     </fo:table-cell>
                  </xsl:when>
                  <xsl:when test="$isSuppQual='2'">
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:if test="$valueDef/odm:Description/odm:TranslatedText">
                              <xsl:value-of select="$valueDef/odm:Description/odm:TranslatedText" />
                           </xsl:if>
                        </fo:block>
                     </fo:table-cell>
                  </xsl:when>
                  <xsl:otherwise>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:if test="$valueDef/odm:Description/odm:TranslatedText">
                              <xsl:value-of select="$valueDef/odm:Description/odm:TranslatedText" />
                           </xsl:if>
                        </fo:block>
                     </fo:table-cell>
                  </xsl:otherwise>
               </xsl:choose>
               
               <!-- Datatype -->
               <fo:table-cell xsl:use-attribute-sets="table-td">
                  <fo:block>
                     <xsl:value-of select="$valueDef/@DataType" />
                  </fo:block>
               </fo:table-cell>
               
               <!-- Role (when defined) -->
               <xsl:if test="count($ItemRef/@Role) > 0 or $addRoleColumn='1'">
                  <fo:table-cell xsl:use-attribute-sets="table-td">
                     <fo:block>
                        <xsl:value-of select="$ItemRef/@Role" />
                     </fo:block>
                  </fo:table-cell>
               </xsl:if>
               
               <!-- Length [Significant Digits] : DisplayFormat -->
               <xsl:choose>
                  <xsl:when test="$displayLengthDFormatSD='1'">
                     <fo:table-cell xsl:use-attribute-sets="table-td" text-align="right">
                        <fo:block>
                           <xsl:call-template name="displayItemDefLengthSignDigitsDisplayFormat">
                              <xsl:with-param name="ItemDef" select="$valueDef" />
                           </xsl:call-template>
                        </fo:block>
                     </fo:table-cell>
                  </xsl:when>
                  <xsl:otherwise>
                     <fo:table-cell xsl:use-attribute-sets="table-td" text-align="right">
                        <fo:block>
                           <xsl:call-template name="displayItemDefLengthDFormat">
                              <xsl:with-param name="ItemDef" select="$valueDef" />
                           </xsl:call-template>
                        </fo:block>
                     </fo:table-cell>
                  </xsl:otherwise>
               </xsl:choose>
               
               <!-- Controlled Terms or Format -->
               <fo:table-cell xsl:use-attribute-sets="table-td">
                  <fo:block>
                     <xsl:call-template name="displayItemDefDecodeList">
                        <xsl:with-param name="itemDef" select="$valueDef" />
                     </xsl:call-template>
                     <xsl:call-template name="displayItemDefISO8601">
                        <xsl:with-param name="itemDef" select="$valueDef" />
                     </xsl:call-template>
                  </fo:block>
               </fo:table-cell>
               
               <!-- Origin/Source/Method/Comment    -->
               <fo:table-cell xsl:use-attribute-sets="table-td">
                  <fo:block>
                     <xsl:call-template name="displayItemDefOrigin">
                        <xsl:with-param name="itemDef" select="$valueDef" />
                        <xsl:with-param name="OriginPrefix" select="$displayPrefix" />
                     </xsl:call-template>
                     <xsl:call-template name="displayItemDefMethod">
                        <xsl:with-param name="MethodOID" select="$ItemRef/@MethodOID" />
                        <xsl:with-param name="MethodPrefix" select="$displayPrefix" />
                     </xsl:call-template>
                     <xsl:call-template name="displayComment">
                        <xsl:with-param name="CommentOID" select="$valueDef/@def:CommentOID" />
                        <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                     </xsl:call-template>
                     <xsl:call-template name="displayComment">
                        <xsl:with-param name="CommentOID" select="$whereDef/@def:CommentOID" />
                        <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                     </xsl:call-template>
                  </fo:block>
               </fo:table-cell>
               
               <!-- end of loop over all def:ValueListDef elements -->
               <xsl:if test="$valueDef/def:ValueListRef/@ValueListOID and $isSuppQual = '1'">
                  <xsl:call-template name="tableValueListsInTable">
                     <xsl:with-param name="OID"
                                     select="$valueDef/def:ValueListRef/@ValueListOID" />
                     <xsl:with-param name="ParentItemDefOID"
                                     select="$ParentItemDefOID" />
                     <xsl:with-param name="addRoleColumn"
                                     select="$addRoleColumn" />
                     <xsl:with-param name="isSuppQual"
                                     select="'2'" />
                     <xsl:with-param name="VLMClass"
                                     select="$VLMClass" />
                  </xsl:call-template>
               </xsl:if>
               <!-- end of loop over all ValueListDefs -->
            </fo:table-row>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- CodeLists                                 -->
   <!-- ***************************************** -->
   <xsl:template name="tableCodeLists">
      <xsl:if test="$g_seqCodeLists[odm:CodeListItem|odm:EnumeratedItem]">
         <fo:block xsl:use-attribute-sets="containerbox" id="decodelist">
            <fo:block xsl:use-attribute-sets="table-caption-header">CodeLists</fo:block>
            <xsl:for-each select="$g_seqCodeLists[odm:CodeListItem|odm:EnumeratedItem]">
               <xsl:choose>
                  <xsl:when test="./odm:CodeListItem">
                     <xsl:call-template name="tableCodeListItems" />
                  </xsl:when>
                  <xsl:when test="./odm:EnumeratedItem">
                     <xsl:call-template name="tableEnumeratedItems" />
                  </xsl:when>
                  <xsl:otherwise />
               </xsl:choose>
            </xsl:for-each>
            <!-- <xsl:call-template name="linkTop" /> -->
            <xsl:call-template name="lineBreak" />
         </fo:block>
      </xsl:if>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- Display CodeList Items table              -->
   <!-- ***************************************** -->
   <xsl:template name="tableCodeListItems">
      <xsl:variable name="n_extended" select="count(odm:CodeListItem/@def:ExtendedValue)" />
      
      <fo:block xsl:use-attribute-sets="codelist">
         <xsl:attribute name="id">CL.<xsl:value-of select="@OID" /></xsl:attribute>
         <fo:block xsl:use-attribute-sets="codelist-caption">
            <xsl:value-of select="@Name" />
            <xsl:if test="./odm:Alias/@Context = 'nci:ExtCodeID'">
               <xsl:text> [</xsl:text>
               <fo:inline xsl:use-attribute-sets="nci">
                  <xsl:value-of select="./odm:Alias/@Name" />
               </fo:inline>
               <xsl:text>]</xsl:text>
            </xsl:if>
            <!--  Define-XML v2.1 -->
            <xsl:call-template name="displayStandard">
               <xsl:with-param name="element" select="'fo:inline'" />
            </xsl:call-template>
            <!--  Define-XML v2.1 -->
            <xsl:call-template name="displayNonStandard">
               <xsl:with-param name="element" select="'fo:inline'" />
            </xsl:call-template>
            <xsl:call-template name="displayDescription" />
            <!--  Define-XML v2.1 -->
            <xsl:if test="@def:CommentOID">
               <fo:block xsl:use-attribute-sets="description">
                  <xsl:call-template name="displayComment">
                     <xsl:with-param name="CommentOID" select="@def:CommentOID" />
                     <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                     <xsl:with-param name="element" select="'fo:block'" />
                  </xsl:call-template>
               </fo:block>
            </xsl:if>
         </fo:block>
         <fo:table xsl:use-attribute-sets="table">
            <!-- Table Columns Width -->
            <xsl:choose>
               <xsl:when test="./odm:CodeListItem/odm:Description/odm:TranslatedText and ./odm:CodeListItem/@Rank">
                  <fo:table-column column-width="20%" />
                  <fo:table-column column-width="30%" />
                  <fo:table-column column-width="40%" />
                  <fo:table-column column-width="10%" />
               </xsl:when>
               <xsl:when test="./odm:CodeListItem/odm:Description/odm:TranslatedText">
                  <fo:table-column column-width="20%" />
                  <fo:table-column column-width="40%" />
                  <fo:table-column column-width="40%" />
               </xsl:when>
               <xsl:when test="./odm:CodeListItem/@Rank">
                  <fo:table-column column-width="20%" />
                  <fo:table-column column-width="70%" />
                  <fo:table-column column-width="10%" />
               </xsl:when>
               <xsl:otherwise>
                  <fo:table-column column-width="20%" />
                  <fo:table-column column-width="80%" />
               </xsl:otherwise>
            </xsl:choose>
            <fo:table-header xsl:use-attribute-sets="table-tr-header">
               <fo:table-row xsl:use-attribute-sets="table-tr-header">
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block> Permitted Value (Code) </fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block>Display Value (Decode)</fo:block>
                  </fo:table-cell>
                  <xsl:if test="./odm:CodeListItem/odm:Description/odm:TranslatedText">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block>Description</fo:block>
                     </fo:table-cell>
                  </xsl:if>
                  <xsl:if test="./odm:CodeListItem/@Rank">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block>Rank</fo:block>
                     </fo:table-cell>
                  </xsl:if>
               </fo:table-row>
            </fo:table-header>
            <fo:table-body>
               <xsl:for-each select="./odm:CodeListItem">
                  <xsl:sort data-type="number" select="@OrderNumber" order="ascending" />
                  <xsl:sort data-type="number" select="@Rank" order="ascending" />
                  <fo:table-row>
                     <xsl:call-template name="setRowClassOddeven">
                        <xsl:with-param name="rowNum" select="position()" />
                     </xsl:call-template>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:value-of select="@CodedValue" />
                           <xsl:if test="./odm:Alias/@Context = 'nci:ExtCodeID'">
                              <xsl:text> [</xsl:text>
                              <fo:inline xsl:use-attribute-sets="nci">
                                 <xsl:value-of select="./odm:Alias/@Name" />
                              </fo:inline>
                              <xsl:text>]</xsl:text> 
                           </xsl:if>
                           <xsl:if test="@def:ExtendedValue='Yes'">
                              <xsl:text> [</xsl:text>
                              <fo:inline xsl:use-attribute-sets="extended">*</fo:inline>
                              <xsl:text>]</xsl:text>
                           </xsl:if>
                        </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:value-of select="./odm:Decode/odm:TranslatedText" />
                        </fo:block>
                     </fo:table-cell>
                     <xsl:if test="../odm:CodeListItem/odm:Description/odm:TranslatedText">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:call-template name="displayItemDescription" />
                           </fo:block>
                        </fo:table-cell>
                     </xsl:if>
                     <xsl:if test="../odm:CodeListItem/@Rank">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="@Rank" />
                           </fo:block>
                        </fo:table-cell>
                     </xsl:if>
                  </fo:table-row>
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
         <xsl:if test="$n_extended &gt; 0">
            <fo:block xsl:use-attribute-sets="footnote">
               <fo:inline xsl:use-attribute-sets="super">*</fo:inline>
               <xsl:text>Extended Value</xsl:text>
            </fo:block>
         </xsl:if>
      </fo:block>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- Display Enumerated Items Table            -->
   <!-- ***************************************** -->
   <xsl:template name="tableEnumeratedItems">
      <xsl:variable name="n_extended" select="count(odm:EnumeratedItem/@def:ExtendedValue)" />
      
      <fo:block xsl:use-attribute-sets="codelist">
         <xsl:attribute name="id">CL.<xsl:value-of select="@OID" /></xsl:attribute>
         <fo:block xsl:use-attribute-sets="codelist-caption">
            <xsl:value-of select="@Name" />
            <xsl:if test="./odm:Alias/@Context = 'nci:ExtCodeID'">
               <xsl:text> [</xsl:text>
               <fo:inline xsl:use-attribute-sets="nci">
                  <xsl:value-of select="./odm:Alias/@Name" />
               </fo:inline>
               <xsl:text>]</xsl:text>
            </xsl:if>
            <!--  Define-XML v2.1 -->
            <xsl:call-template name="displayStandard">
               <xsl:with-param name="element" select="'fo:inline'" />
            </xsl:call-template>
            <!--  Define-XML v2.1 -->
            <xsl:call-template name="displayNonStandard">
               <xsl:with-param name="element" select="'fo:inline'" />
            </xsl:call-template>
            <xsl:call-template name="displayDescription" />
            <!--  Define-XML v2.1 -->
            <xsl:if test="@def:CommentOID">
               <fo:block xsl:use-attribute-sets="description">
                  <xsl:call-template name="displayComment">
                     <xsl:with-param name="CommentOID" select="@def:CommentOID" />
                     <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                     <xsl:with-param name="element" select="'fo:block'" />
                  </xsl:call-template>
               </fo:block>
            </xsl:if>
         </fo:block>
         <fo:table xsl:use-attribute-sets="table">
            <!-- Table Columns Width -->
            <xsl:choose>
               <xsl:when test="./odm:CodeListItem/odm:Description/odm:TranslatedText and ./odm:CodeListItem/@Rank">
                  <fo:table-column column-width="30%" />
                  <fo:table-column column-width="60%" />
                  <fo:table-column column-width="10%" />
               </xsl:when>
               <xsl:when test="./odm:CodeListItem/odm:Description/odm:TranslatedText">
                  <fo:table-column column-width="40%" />
                  <fo:table-column column-width="60%" />
               </xsl:when>
               <xsl:when test="./odm:CodeListItem/@Rank">
                  <fo:table-column column-width="50%" />
                  <fo:table-column column-width="50%" />
               </xsl:when>
               <xsl:otherwise />
            </xsl:choose>
            <fo:table-header xsl:use-attribute-sets="table-tr-header">
               <fo:table-row xsl:use-attribute-sets="table-tr-header">
                  <fo:table-cell xsl:use-attribute-sets="table-th">
                     <fo:block> Permitted Value (Code) </fo:block>
                  </fo:table-cell>
                  <xsl:if test="./odm:EnumeratedItem/odm:Description/odm:TranslatedText">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Description </fo:block>
                     </fo:table-cell>
                  </xsl:if>
                  <xsl:if test="./odm:EnumeratedItem/@Rank">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Rank </fo:block>
                     </fo:table-cell>
                  </xsl:if>
               </fo:table-row>
            </fo:table-header>
            <fo:table-body>
               <xsl:for-each select="./odm:EnumeratedItem">
                  <xsl:sort data-type="number" select="@OrderNumber" order="ascending" />
                  <xsl:sort data-type="number" select="@Rank" order="ascending" />
                  <fo:table-row>
                     <xsl:call-template name="setRowClassOddeven">
                        <xsl:with-param name="rowNum" select="position()" />
                     </xsl:call-template>
                     <fo:table-cell xsl:use-attribute-sets="table-td">
                        <fo:block>
                           <xsl:value-of select="@CodedValue" />
                           <xsl:if test="./odm:Alias/@Context = 'nci:ExtCodeID'">
                              <xsl:text> [</xsl:text>
                              <fo:inline xsl:use-attribute-sets="nci">
                                 <xsl:value-of select="./odm:Alias/@Name" />
                              </fo:inline>
                              <xsl:text>]</xsl:text> 
                           </xsl:if>
                           <xsl:if test="@def:ExtendedValue='Yes'">
                              <xsl:text> [</xsl:text>
                              <fo:inline xsl:use-attribute-sets="extended">*</fo:inline>
                              <xsl:text>]</xsl:text>
                           </xsl:if>
                        </fo:block>
                     </fo:table-cell>
                     <!--  Define-XML v2.1 -->
                     <xsl:if test="../odm:EnumeratedItem/odm:Description/odm:TranslatedText">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:call-template name="displayItemDescription" />
                           </fo:block>
                        </fo:table-cell>
                     </xsl:if>
                     <xsl:if test="../odm:EnumeratedItem/@Rank">
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="@Rank" />
                           </fo:block>
                        </fo:table-cell>
                     </xsl:if>
                  </fo:table-row>
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
         <xsl:if test="$n_extended &gt; 0">
            <fo:block xsl:use-attribute-sets="footnote">
               <fo:inline xsl:use-attribute-sets="super">*</fo:inline>
               <xsl:text>Extended Value</xsl:text>
            </fo:block>
         </xsl:if>
      </fo:block>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- External Dictionaries                     -->
   <!-- ***************************************** -->
   <xsl:template name="tableExternalCodeLists">
      
      <xsl:if test="$g_seqCodeLists[odm:ExternalCodeList]">
         <fo:block xsl:use-attribute-sets="containerbox" id="externaldictionary">
            <fo:block xsl:use-attribute-sets="table-caption-header"> External Dictionaries </fo:block>
            <fo:table xsl:use-attribute-sets="table">
               <fo:table-column column-width="40%" />
               <fo:table-column column-width="40%" />
               <fo:table-column column-width="20%" />
               <fo:table-header xsl:use-attribute-sets="table-tr-header">
                  <fo:table-row xsl:use-attribute-sets="table-tr-header">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Reference Name </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> External Dictionary </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Dictionary Version </fo:block>
                     </fo:table-cell>
                  </fo:table-row>
               </fo:table-header>
               <fo:table-body>
                  <xsl:for-each select="$g_seqCodeLists/odm:ExternalCodeList">
                     <fo:table-row>
                        <xsl:call-template name="setRowClassOddeven">
                           <xsl:with-param name="rowNum" select="position()" />
                        </xsl:call-template>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <!-- Create an anchor -->
                              <xsl:attribute name="id">CL.<xsl:value-of select="../@OID" /></xsl:attribute>
                              <xsl:value-of select="../@Name" />
                              <xsl:if test="../odm:Description/odm:TranslatedText">
                                 <fo:block xsl:use-attribute-sets="description">
                                    <xsl:value-of select="../odm:Description/odm:TranslatedText" />
                                 </fo:block> 
                              </xsl:if>
                              <!--  Define-XML v2.1 -->
                              <xsl:if test="../@def:CommentOID">
                                 <fo:block xsl:use-attribute-sets="description">
                                    <xsl:call-template name="displayComment">
                                       <xsl:with-param name="CommentOID" select="../@def:CommentOID" />
                                       <xsl:with-param name="CommentPrefix" select="$displayPrefix" />
                                       <xsl:with-param name="element" select="'fo:block'" />
                                    </xsl:call-template>
                                 </fo:block>
                              </xsl:if>
                           </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:choose>
                                 <xsl:when test="@href">
                                    <xsl:call-template name="displayHyperlink">
                                       <xsl:with-param name="href" select="@href" />
                                       <xsl:with-param name="anchor" select="''" />
                                       <xsl:with-param name="title" select="@Dictionary" />
                                    </xsl:call-template>
                                 </xsl:when>
                                 <xsl:otherwise>
                                    <xsl:value-of select="@Dictionary" />
                                 </xsl:otherwise>
                              </xsl:choose>
                              <xsl:choose>
                                 <xsl:when test="@ref">
                                    <xsl:text> (</xsl:text>
                                    <xsl:call-template name="displayHyperlink">
                                       <xsl:with-param name="href" select="@ref" />
                                       <xsl:with-param name="anchor" select="''" />
                                       <xsl:with-param name="title" select="@ref" />
                                    </xsl:call-template>
                                    <xsl:text>)</xsl:text>
                                 </xsl:when>
                                 <xsl:otherwise> </xsl:otherwise>
                              </xsl:choose>
                           </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="@Version" />
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                  </xsl:for-each>
               </fo:table-body>
            </fo:table>
         </fo:block>
         <!--<xsl:call-template name="linkTop" />-->
         <xsl:call-template name="lineBreak" />
      </xsl:if>
   </xsl:template>
   
   <!-- *************************************************************** -->
   <!-- Methods                                                         -->
   <!-- *************************************************************** -->
   <xsl:template name="tableMethods">
      
      <xsl:if test="$g_seqMethodDefs">
         
         <fo:block xsl:use-attribute-sets="containerbox" id="compmethod">
            <fo:block xsl:use-attribute-sets="table-caption-header"> Methods </fo:block>
            <fo:table xsl:use-attribute-sets="table">
               <fo:table-column column-width="15%" />
               <fo:table-column column-width="8%" />
               <fo:table-column column-width="77%" />
               <fo:table-header xsl:use-attribute-sets="table-tr-header">
                  <fo:table-row xsl:use-attribute-sets="table-tr-header">
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Method </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Type </fo:block>
                     </fo:table-cell>
                     <fo:table-cell xsl:use-attribute-sets="table-th">
                        <fo:block> Description </fo:block>
                     </fo:table-cell>
                  </fo:table-row>
               </fo:table-header>
               <fo:table-body>
                  <xsl:for-each select="$g_seqMethodDefs">
                     <fo:table-row>
                        <xsl:call-template name="setRowClassOddeven">
                           <xsl:with-param name="rowNum" select="position()" />
                        </xsl:call-template>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <!-- Create an anchor -->
                              <xsl:attribute name="id">MT.<xsl:value-of select="@OID" /></xsl:attribute>
                              <xsl:value-of select="@Name" />
                           </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <xsl:value-of select="@Type" />
                           </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="table-td">
                           <fo:block>
                              <fo:block xsl:use-attribute-sets="method-code">
                                 <xsl:value-of select="./odm:Description/odm:TranslatedText" />
                              </fo:block>
                              <xsl:if test="string-length(./odm:FormalExpression) &gt; 0">
                                 <xsl:for-each select="odm:FormalExpression">
                                    <fo:block xsl:use-attribute-sets="formalexpression">
                                       <fo:inline xsl:use-attribute-sets="label">Formal Expression</fo:inline>
                                       <xsl:if test="string-length(@Context) &gt; 0">
                                          <xsl:text> [</xsl:text>
                                          <xsl:value-of select="@Context" />
                                          <xsl:text>]</xsl:text>
                                       </xsl:if>
                                       <xsl:text>:</xsl:text>
                                       <fo:block xsl:use-attribute-sets="formalexpression-code">
                                          <fo:wrapper>
                                             <xsl:value-of select="." />
                                          </fo:wrapper>
                                       </fo:block>
                                    </fo:block>
                                 </xsl:for-each>
                              </xsl:if>
                              <xsl:for-each select="./def:DocumentRef">
                                 <xsl:call-template name="displayDocumentRef" />
                              </xsl:for-each>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                  </xsl:for-each>
               </fo:table-body>
            </fo:table>
            <!-- <xsl:call-template name="linkTop" /> -->
            <xsl:call-template name="lineBreak" />
         </fo:block>
      </xsl:if>
   </xsl:template>
   
   <!-- *************************************************************** -->
   <!-- Comments                                                        -->
   <!-- *************************************************************** -->
   <xsl:template name="tableComments">
      <xsl:if test="$g_seqCommentDefs">
         <fo:block xsl:use-attribute-sets="containerbox" id="comment">
            <fo:table xsl:use-attribute-sets="table">
               <fo:block xsl:use-attribute-sets="table-caption-header">Comments</fo:block>
               <fo:table-column column-width="10%" />
               <fo:table-column column-width="90%" />
               <fo:table-header xsl:use-attribute-sets="table-tr-header">
                  <fo:table-row xsl:use-attribute-sets="table-tr-header">
                     <fo:table-cell>
                        <fo:block> CommentOID </fo:block>
                     </fo:table-cell>
                     <fo:table-cell>
                        <fo:block> Description </fo:block>
                     </fo:table-cell>
                  </fo:table-row>
               </fo:table-header>
               <fo:table-body>
                  <xsl:for-each select="$g_seqCommentDefs">
                     <fo:table-row>
                        <!-- Create an anchor -->
                        <xsl:attribute name="id">COMM.<xsl:value-of select="@OID" /></xsl:attribute>
                        <xsl:call-template name="setRowClassOddeven">
                           <xsl:with-param name="rowNum" select="position()" />
                        </xsl:call-template>
                        <fo:table-cell>
                           <fo:block>
                              <xsl:value-of select="@OID" />
                           </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                           <fo:block>
                              <xsl:value-of select="normalize-space(.)" />
                              <xsl:for-each select="./def:DocumentRef">
                                 <xsl:call-template name="displayDocumentRef" />
                              </xsl:for-each>
                           </fo:block>
                        </fo:table-cell>
                     </fo:table-row>
                  </xsl:for-each>
               </fo:table-body>
            </fo:table>
         </fo:block>
         <!--<xsl:call-template name="linkTop" />-->
         <xsl:call-template name="lineBreak" />
      </xsl:if>
   </xsl:template>
   
   <!-- *************************************************** -->
   <!-- Templates for special features like hyperlinks      -->
   <!-- *************************************************** -->
   <!-- *************************************************************** -->
   <!-- Document References                                             -->
   <!-- *************************************************************** -->
   <xsl:template name="displayDocumentRef">
      
      <xsl:param name="element" select="'fo:block'" />
      
      <xsl:variable name="leafID" select="@leafID" />
      <xsl:variable name="leaf" select="$g_seqleafs[@ID = $leafID]" />
      <xsl:variable name="href" select="$leaf/@xlink:href" />
      
      <xsl:choose>
         <xsl:when test="def:PDFPageRef">
            <xsl:for-each select="def:PDFPageRef">
               <xsl:variable name="title">
                  <xsl:choose>
                     <xsl:when test="count($leaf) = 0">
                        <fo:inline xsl:use-attribute-sets="unresolved">
                           <xsl:text>[unresolved: </xsl:text>
                           <xsl:value-of select="$leafID" />
                        </fo:inline>
                        <xsl:text>] </xsl:text>
                     </xsl:when>
                     <!--  Define-XML v2.1 -->
                     <xsl:when test="@Title">
                        <xsl:value-of select="@Title" />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$leaf/def:title" />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <xsl:variable name="PageRefType" select="normalize-space(@Type)" />
               <xsl:variable name="PageRefs" select="normalize-space(@PageRefs)" />
               <xsl:variable name="PageFirst" select="normalize-space(@FirstPage)" />
               <xsl:variable name="PageLast" select="normalize-space(@LastPage)" />
               <xsl:element name="{$element}">  
                  <xsl:choose>
                     <xsl:when test="$PageRefType = $REFTYPE_PHYSICALPAGE">
                        <xsl:call-template name="linkPages2Hyperlinks">
                           <xsl:with-param name="href" select="$href" />
                           <xsl:with-param name="pagenumbers">
                              <xsl:choose>
                                 <xsl:when test="$PageRefs">
                                    <xsl:value-of select="normalize-space($PageRefs)" />
                                 </xsl:when>
                                 <xsl:when test="$PageFirst">
                                    <xsl:value-of select="normalize-space(concat($PageFirst, '-', $PageLast))" />
                                 </xsl:when>
                                 <xsl:otherwise> </xsl:otherwise>
                              </xsl:choose>
                           </xsl:with-param>
                           <xsl:with-param name="title" select="$title" />
                           <xsl:with-param name="ShowTitle" select="1" />
                           <xsl:with-param name="Separator">
                              <xsl:choose>
                                 <xsl:when test="$PageRefs">
                                    <xsl:value-of select="' '" />
                                 </xsl:when>
                                 <xsl:when test="$PageFirst">
                                    <xsl:value-of select="'-'" />
                                 </xsl:when>
                                 <xsl:otherwise> </xsl:otherwise>
                              </xsl:choose>
                           </xsl:with-param>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:when test="$PageRefType = $REFTYPE_NAMEDDESTINATION">
                        <xsl:call-template name="linkNamedDestinations2Hyperlinks">
                           <xsl:with-param name="href" select="$href" />
                           <xsl:with-param name="destinations" select="$PageRefs" />
                           <xsl:with-param name="title" select="$title" />
                           <xsl:with-param name="ShowTitle" select="1" />
                           <xsl:with-param name="Separator" select="' '" />
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise />
                  </xsl:choose>
               </xsl:element>
            </xsl:for-each>        
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="title">
               <xsl:choose>
                  <xsl:when test="count($leaf) = 0">
                     <fo:inline xsl:use-attribute-sets="unresolved">
                        <xsl:text>[unresolved: </xsl:text>
                        <xsl:value-of select="$leafID" />
                        <xsl:text>]</xsl:text>
                     </fo:inline>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$leaf/def:title" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            
            <xsl:element name="{$element}">  
               <xsl:call-template name="displayHyperlink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="anchor" select="''" />
                  <xsl:with-param name="title" select="$title" />
               </xsl:call-template>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ******************************************************** -->
   <!-- Hypertext Link to CRF Pages (if necessary)               -->
   <!-- New mechanism: transform all numbers found in the string -->
   <!-- to hyperlinks                                            -->
   <!-- ******************************************************** -->
   <xsl:template name="linkPages2Hyperlinks">
      <xsl:param name="href" />
      <xsl:param name="pagenumbers" />
      <xsl:param name="title" />
      <xsl:param name="ShowTitle" />
      <xsl:param name="Separator" />
      
      <xsl:variable name="OriginString" select="$pagenumbers" />
      <xsl:variable name="first">
         <xsl:choose>
            <xsl:when test="contains($OriginString,$Separator)">
               <xsl:value-of select="substring-before($OriginString,$Separator)" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$OriginString" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="rest" select="substring-after($OriginString,$Separator)" />
      <xsl:variable name="stringlengthfirst" select="string-length($first)" />
      
      <xsl:if test="$ShowTitle != '0'">
         <xsl:value-of select="$title" />
         <xsl:text> [</xsl:text>
      </xsl:if>  
      
      <xsl:if test="string-length($first) > 0">
         <xsl:choose>
            <xsl:when test="number($first)">
               <!-- it is a number, create the hyperlink -->
               <xsl:call-template name="displayHyperlink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="anchor" select="concat('#page=', $first)" />
                  <xsl:with-param name="title" select="$first" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <!-- it is not a number -->
               <xsl:value-of select="$first" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <!-- split up the second part in words (recursion) -->
      <xsl:if test="string-length($rest) > 0">
         
         <xsl:choose>
            <xsl:when test="contains($rest,$Separator)">
               <xsl:call-template name="linkPages2Hyperlinks">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="pagenumbers" select="$rest" />
                  <xsl:with-param name="title" select="$title" />
                  <xsl:with-param name="ShowTitle" select="0" />
                  <xsl:with-param name="Separator" select="' '" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:value-of select="$Separator" />
               <xsl:text> </xsl:text>
               
               <xsl:choose>
                  <xsl:when test="number($rest)">
                     <!-- it is a number, create the hyperlink -->
                     <xsl:call-template name="displayHyperlink">
                        <xsl:with-param name="href" select="$href" />
                        <xsl:with-param name="anchor" select="concat('#page=', $rest)" />
                        <xsl:with-param name="title" select="$rest" />
                     </xsl:call-template>
                     <xsl:text>]</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- it is not a number -->
                     <xsl:value-of select="$rest" />
                     <xsl:text>]</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      
      <xsl:if test="string-length($rest) = 0">
         <xsl:text>]</xsl:text>
      </xsl:if>
      
   </xsl:template>
   
   <!-- ******************************************************** -->
   <!-- Hypertext Link to Named Destinations (if necessary)      -->
   <!-- ******************************************************** -->
   <xsl:template name="linkNamedDestinations2Hyperlinks">
      <xsl:param name="href" />
      <xsl:param name="destinations" />
      <xsl:param name="title" />
      <xsl:param name="ShowTitle" />
      <xsl:param name="Separator" />
      
      <xsl:variable name="OriginString" select="$destinations" />
      <xsl:variable name="first">
         <xsl:choose>
            <xsl:when test="contains($OriginString,$Separator)">
               <xsl:value-of select="substring-before($OriginString,$Separator)" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$OriginString" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="rest" select="substring-after($OriginString,$Separator)" />
      <xsl:variable name="stringlengthfirst" select="string-length($first)" />
      
      <xsl:if test="$ShowTitle != '0'">
         <xsl:value-of select="$title" />
         <xsl:text> [</xsl:text>
      </xsl:if>  
      
      <xsl:if test="string-length($first) > 0">
         <xsl:call-template name="displayHyperlink">
            <xsl:with-param name="href" select="$href" />
            <xsl:with-param name="anchor" select="concat('#', $first)" />
            <xsl:with-param name="title">
               <xsl:call-template name="stringReplace">
                  <!-- Replace occurrences of #20 with blanks -->
                  <xsl:with-param name="string" select="$first" />
                  <xsl:with-param name="from" select="'#20'" />
                  <xsl:with-param name="to" select="' '" />
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <!-- split up the second part in words (recursion) -->
      <xsl:if test="string-length($rest) > 0">
         <xsl:choose>
            <xsl:when test="contains($rest,$Separator)">
               <xsl:call-template name="linkNamedDestinations2Hyperlinks">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="destinations" select="$rest" />
                  <xsl:with-param name="title" select="$title" />
                  <xsl:with-param name="ShowTitle" select="0" />
                  <xsl:with-param name="Separator" select="' '" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:value-of select="$Separator" />
               <xsl:text> </xsl:text>
               
               <xsl:call-template name="displayHyperlink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="anchor" select="concat('#', $rest)" />
                  <xsl:with-param name="title">
                     <!-- Replace occurrences of #20 with blanks -->
                     <xsl:call-template name="stringReplace">
                        <xsl:with-param name="string" select="$rest" />
                        <xsl:with-param name="from" select="'#20'" />
                        <xsl:with-param name="to" select="' '" />
                     </xsl:call-template>
                  </xsl:with-param>
               </xsl:call-template>
               <xsl:text>]</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      
      <xsl:if test="string-length($rest) = 0">
         <xsl:text>]</xsl:text>
      </xsl:if>
   </xsl:template>
   
   <!-- ******************************************************** -->
   <!-- Hypertext Link to a Document                             -->
   <!-- ******************************************************** -->
   <xsl:template name="displayHyperlink">
      <xsl:param name="href" />
      <xsl:param name="anchor" />
      <xsl:param name="title" />
      <!-- create the hyperlink itself -->
      <xsl:choose>
         <xsl:when test="$href != ''">
            <fo:basic-link xsl:use-attribute-sets="link">
               <xsl:attribute name="external-destination">
                  <xsl:value-of select="concat($href, $anchor)" />
               </xsl:attribute>
               <xsl:value-of select="$title" />
            </fo:basic-link>
            <xsl:call-template name="displayImage" />
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$title" />
            <xsl:call-template name="displayImage" />
            <xsl:text> </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to Parent Domain                                         -->
   <!-- ************************************************************* -->
   <xsl:template name="linkParentDomain">
      <!-- REMARK that we are still in the 'ItemRef' template
           but at the 'ItemGroupDef' level -->
      
      <xsl:if test="starts-with(@Name, 'SUPP')">
         <!-- create an extra row to the XX dataset when there is one -->
         <xsl:variable name="parentDatasetName" select="substring(@Name, 5)" />
         <xsl:if test="../odm:ItemGroupDef[@Name = $parentDatasetName]">
            <xsl:variable name="datasetOID" select="../odm:ItemGroupDef[@Name = $parentDatasetName]/@OID" />
            <fo:block xsl:use-attribute-sets="supp_parent_link" margin-top="5pt">
               <xsl:text>Related Parent Dataset: </xsl:text>
               <fo:basic-link xsl:use-attribute-sets="link">
                  <xsl:attribute name="internal-destination">
                     <xsl:text>IG.</xsl:text><xsl:value-of select="$datasetOID" />
                  </xsl:attribute>
                  <xsl:value-of select="$parentDatasetName" />
               </fo:basic-link>
               <xsl:text> (</xsl:text>
               <xsl:value-of select="//odm:ItemGroupDef[@OID = $datasetOID]/odm:Description/odm:TranslatedText" />
               <xsl:text>)</xsl:text>
            </fo:block>  
         </xsl:if>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to Associated Persons Parent Domain                      -->
   <!-- ************************************************************* -->
   <xsl:template name="linkApParentDomain">
      <!-- REMARK that we are still in the 'ItemRef' template
           but at the 'ItemGroupDef' level -->
      <xsl:if test="starts-with(@Name, 'SQAP')">
         <!-- create an extra row to the XX dataset when there is one -->
         <xsl:variable name="parentDatasetName" select="concat('AP', substring(@Name, 5))" />
         <xsl:if test="../odm:ItemGroupDef[@Name = $parentDatasetName]">
            <xsl:variable name="datasetOID" select="../odm:ItemGroupDef[@Name = $parentDatasetName]/@OID" />
            <fo:block xsl:use-attribute-sets="supp_parent_link" margin-top="5pt">
               <xsl:text>Related Parent Dataset: </xsl:text>
               <fo:basic-link xsl:use-attribute-sets="link">
                  <xsl:attribute name="internal-destination">
                     <xsl:text>IG.</xsl:text><xsl:value-of select="$datasetOID" />
                  </xsl:attribute>
                  <xsl:value-of select="$parentDatasetName" />
               </fo:basic-link>
               <xsl:text> (</xsl:text>
               <xsl:value-of select="//odm:ItemGroupDef[@OID = $datasetOID]/odm:Description/odm:TranslatedText" />
               <xsl:text>)</xsl:text>
            </fo:block>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to Supplemental Qualifiers                               -->
   <!-- ************************************************************* -->
   <xsl:template name="linkSuppQual">
      <!-- REMARK that we are still in the 'ItemRef' template
           but at the 'ItemGroupDef' level -->
      
      <xsl:variable name="suppDatasetName" select="concat('SUPP', @Name)" />
      
      <xsl:if test="../odm:ItemGroupDef[@Name = $suppDatasetName]">
         <!-- create an extra row to the SUPPXX dataset when there is one -->
         <xsl:variable name="datasetOID" select="../odm:ItemGroupDef[@Name = $suppDatasetName]/@OID" />
         <fo:block xsl:use-attribute-sets="supp_parent_link" margin-top="5pt">
            <xsl:text>Related Supplemental Qualifiers Dataset: </xsl:text>
            <fo:basic-link xsl:use-attribute-sets="link">
               <xsl:attribute name="internal-destination">
                  <xsl:text>IG.</xsl:text><xsl:value-of select="$datasetOID" />
               </xsl:attribute>
               <xsl:value-of select="$suppDatasetName" />
            </fo:basic-link>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="//odm:ItemGroupDef[@OID = $datasetOID]/odm:Description/odm:TranslatedText" />
            <xsl:text>)</xsl:text>
         </fo:block> 
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to Associated Domain Supplemental Qualifiers             -->
   <!-- ************************************************************* -->
   <xsl:template name="linkSQAP">
      <!-- REMARK that we are still in the 'ItemRef' template
           but at the 'ItemGroupDef' level -->
      
      <xsl:if test="substring(@Name, 1, 2)='AP'">
         <xsl:variable name="suppDatasetName" select="concat('SQAP', substring(@Name, 3))" />
         
         <xsl:if test="../odm:ItemGroupDef[@Name = $suppDatasetName]">
            <!-- create an extra row to the SUPPXX dataset when there is one -->
            <xsl:variable name="datasetOID" select="../odm:ItemGroupDef[@Name = $suppDatasetName]/@OID" />
            <fo:block xsl:use-attribute-sets="supp_parent_link" margin-top="5pt">
               <xsl:text>Related Supplemental Qualifiers Dataset: </xsl:text>
               <fo:basic-link xsl:use-attribute-sets="link">
                  <xsl:attribute name="internal-destination">
                     <xsl:text>IG.</xsl:text><xsl:value-of select="$datasetOID" />
                  </xsl:attribute>
                  <xsl:value-of select="$suppDatasetName" />
               </fo:basic-link>
               <xsl:text> (</xsl:text>
               <xsl:value-of select="//odm:ItemGroupDef[@OID = $datasetOID]/odm:Description/odm:TranslatedText" />
               <xsl:text>)</xsl:text>
            </fo:block>
         </xsl:if>
      </xsl:if>  
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Get Parent Dataset Description                                -->
   <!-- ************************************************************* -->
   <xsl:template name="getParentDescription">  
      
      <xsl:param name="OID" />
      
      <xsl:variable name="Domain" select="$g_seqItemGroupDefs[@OID=$OID]/@Domain" />
      <xsl:variable name="Name" select="$g_seqItemGroupDefs[@OID=$OID]/@Name" />
      <xsl:variable name="ParentDescription" select="$g_seqItemGroupDefs[@Domain = $Domain and @Domain = @Name and @Name != $Name]/odm:Description/odm:TranslatedText" />
      
      <xsl:choose>
         <xsl:when test="odm:Alias[@Context='DomainDescription']">
            <xsl:value-of select="odm:Alias/@Name" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$ParentDescription" />
         </xsl:otherwise>
      </xsl:choose>    
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display Comment                                               -->
   <!-- ************************************************************* -->
   <xsl:template name="displayComment">
      
      <xsl:param name="CommentOID" />
      <xsl:param name="CommentPrefix" />
      <xsl:param name="element" select="'fo:block'" />
      
      <xsl:if test="$CommentOID">
         <xsl:variable name="Comment" select="$g_seqCommentDefs[@OID=$CommentOID]" />
         <xsl:variable name="CommentTranslatedText">
            <xsl:value-of select="normalize-space($g_seqCommentDefs[@OID=$CommentOID]/odm:Description/odm:TranslatedText)" />
         </xsl:variable> 
         
         <xsl:element name="{$element}">  
            <xsl:attribute name="vertical-align">
               <xsl:text>top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="margin-top">
               <xsl:text>3pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="margin-bottom">
               <xsl:text>3pt</xsl:text>
            </xsl:attribute>
            <xsl:choose>
               <xsl:when test="string-length($CommentTranslatedText) &gt; 0">
                  <xsl:if test="$CommentPrefix != '0'">
                     <fo:inline xsl:use-attribute-sets="prefix">
                        <xsl:value-of select="$PREFIX_COMMENT_TEXT" />
                     </fo:inline>
                  </xsl:if>  
                  <xsl:value-of select="$CommentTranslatedText" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:if test="$CommentPrefix != '0'">
                     <fo:inline xsl:use-attribute-sets="prefix">
                        <xsl:value-of select="$PREFIX_COMMENT_TEXT" />
                     </fo:inline>
                  </xsl:if>  
                  <fo:inline xsl:use-attribute-sets="unresolved">
                     <xsl:text>[unresolved: </xsl:text>
                     <xsl:value-of select="$CommentOID" />
                     <xsl:text>]</xsl:text>
                  </fo:inline>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
         
         <xsl:for-each select="$Comment/def:DocumentRef">
            <xsl:call-template name="displayDocumentRef">
               <xsl:with-param name="element" select="$element" />
            </xsl:call-template>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- Display Description                       -->
   <!-- ***************************************** -->
   <xsl:template name="displayDescription">
      <xsl:if test="odm:Description/odm:TranslatedText">
         <xsl:call-template name="lineBreak" />
         <fo:inline xsl:use-attribute-sets="description">
            <xsl:value-of select="odm:Description/odm:TranslatedText" />
         </fo:inline>
      </xsl:if>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- Display Item Description                       -->
   <!-- ***************************************** -->
   <xsl:template name="displayItemDescription">
      <xsl:if test="odm:Description/odm:TranslatedText">
         <fo:inline>
            <xsl:value-of select="odm:Description/odm:TranslatedText" />
         </fo:inline>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemDef Length                                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemDefLength">
      
      <xsl:param name="ItemDef" />
      
      <xsl:choose>
         <xsl:when test="$ItemDef/@Length">
            <xsl:value-of select="$ItemDef/@Length" />
         </xsl:when>
         <xsl:otherwise> </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemDef Length / DisplayFormat                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemDefLengthDFormat">
      
      <xsl:param name="ItemDef" />
      
      <xsl:choose>
         <xsl:when test="$ItemDef/@def:DisplayFormat">
            <xsl:value-of select="$ItemDef/@def:DisplayFormat" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$ItemDef/@Length" />
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemDef Length [Significant Digits] : DisplayFormat   -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemDefLengthSignDigitsDisplayFormat">
      
      <xsl:param name="ItemDef" />
      
      <xsl:choose>
         <xsl:when test="$ItemDef/@Length">
            <xsl:value-of select="$ItemDef/@Length" />
            <xsl:if test="$ItemDef/@SignificantDigits">
               <xsl:text>  [</xsl:text>
               <xsl:value-of select="$ItemDef/@SignificantDigits" />
               <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:if test="$ItemDef/@def:DisplayFormat">
               <xsl:text> : </xsl:text>
               <xsl:value-of select="$ItemDef/@def:DisplayFormat" />
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$ItemDef/@def:DisplayFormat">
               <xsl:value-of select="$ItemDef/@def:DisplayFormat" />
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemDef Method                                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemDefMethod">
      
      <xsl:param name="MethodOID" />
      <xsl:param name="MethodPrefix" />
      
      <xsl:if test="$MethodOID">
         <xsl:variable name="Method" select="$g_seqMethodDefs[@OID=$MethodOID]" />
         <xsl:variable name="MethodType" select="$g_seqMethodDefs[@OID=$MethodOID]/@Type" />
         <xsl:variable name="MethodTranslatedText" select="$Method/odm:Description/odm:TranslatedText" />
         <xsl:variable name="MethodFormalExpression" select="$Method/odm:FormalExpression" />
         
         <fo:block xsl:use-attribute-sets="method-code">
            <xsl:choose>
               <xsl:when test="string-length($MethodTranslatedText) &gt; 0">
                  <xsl:if test="$MethodPrefix = '1'">
                     <fo:inline xsl:use-attribute-sets="prefix">
                        <xsl:value-of select="$PREFIX_METHOD_TEXT" />
                     </fo:inline>
                  </xsl:if>
                  <xsl:value-of select="$MethodTranslatedText" />
                  <xsl:if test="$MethodFormalExpression">
                     <fo:inline xsl:use-attribute-sets="formalexpression-reference">
                        <fo:basic-link xsl:use-attribute-sets="link">
                           <xsl:attribute name="internal-destination">MT.<xsl:value-of select="$MethodOID" />
                           </xsl:attribute>
                           <xsl:text>Formal Expression</xsl:text>
                        </fo:basic-link>
                     </fo:inline>  
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:if test="$MethodPrefix = '1'">
                     <fo:inline xsl:use-attribute-sets="prefix">
                        <xsl:value-of select="$PREFIX_METHOD_TEXT" />
                     </fo:inline>
                  </xsl:if>
                  <fo:inline xsl:use-attribute-sets="unresolved">
                     <xsl:text>[unresolved: </xsl:text>
                     <xsl:value-of select="$MethodOID" />
                     <xsl:text>]</xsl:text>
                  </fo:inline>
               </xsl:otherwise>
            </xsl:choose>
         </fo:block>
         <xsl:for-each select="$Method/def:DocumentRef">
            <xsl:call-template name="displayDocumentRef" />
         </xsl:for-each>
      </xsl:if>
   </xsl:template>
   
   <!-- ******************************************************** -->
   <!-- Display ItemDef Origin                                   -->
   <!-- ******************************************************** -->
   <xsl:template name="displayItemDefOrigin">
      
      <xsl:param name="itemDef" />
      <xsl:param name="OriginPrefix" />
      
      <xsl:for-each select="$itemDef/def:Origin"> 	
         
         <xsl:variable name="OriginType" select="@Type" />
         <!--  Define-XML v2.1 -->
         <xsl:variable name="OriginSource" select="@Source" />
         <xsl:variable name="OriginDescription" select="./odm:Description/odm:TranslatedText" />
         
         <fo:block xsl:use-attribute-sets="linebreakcell">
            <xsl:if test="$OriginPrefix != '0'">
               <fo:inline xsl:use-attribute-sets="prefix">
                  <xsl:value-of select="$PREFIX_ORIGIN_TEXT" />
               </fo:inline>
            </xsl:if>
            <xsl:value-of select="$OriginType" />
            <!--  Define-XML v2.1 -->
            <xsl:if test="$OriginSource">
               <xsl:text> (</xsl:text>
               <fo:inline xsl:use-attribute-sets="linebreakcell">Source: <xsl:value-of select="$OriginSource" /></fo:inline>
               <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:if test="$OriginDescription">
               <xsl:choose>
                  <!--  Define-XML v2.1 -->
                  <xsl:when test="$OriginSource">
                     <fo:block xsl:use-attribute-sets="linebreakcell">
                        <xsl:value-of select="$OriginDescription" />
                     </fo:block>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:choose>
                        <xsl:when test="$OriginType = 'Predecessor'">
                           <xsl:text>: </xsl:text>
                           <xsl:value-of select="$OriginDescription" />
                        </xsl:when>
                        <xsl:otherwise>
                           <fo:block xsl:use-attribute-sets="linebreakcell">
                              <xsl:value-of select="$OriginDescription" />
                           </fo:block>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:if>
         </fo:block>
         
         <xsl:for-each select="def:DocumentRef">	
            <xsl:call-template name="displayDocumentRef" />
         </xsl:for-each>  
         
         <xsl:if test="position() != last()">
            <xsl:call-template name="lineBreak" />
         </xsl:if>
      </xsl:for-each>  		
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemGroup Class                                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemGroupClass">
      
      <xsl:if test="@def:Class">
         <xsl:value-of select="@def:Class" />    
      </xsl:if>
      
      <xsl:if test="def:Class/@Name">
         <!--  Define-XML v2.1 (only one SubClass level supported currently) -->
         <xsl:variable name="ClassName" select="def:Class/@Name" />
         <xsl:value-of select="$ClassName" />
         <xsl:if test="def:Class/def:SubClass/@Name">
            <fo:list-block>
               <xsl:for-each select="def:Class/def:SubClass[@ParentClass=$ClassName or not(@ParentClass)]">
                  <fo:list-item provisional-distance-between-starts="12mm"
                                provisional-label-separation="2mm">
                     <fo:list-item-label start-indent="10mm" end-indent="label-end()">
                        <fo:block>-</fo:block>
                     </fo:list-item-label>
                     <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                           <xsl:value-of select="@Name" />
                        </fo:block>
                     </fo:list-item-body>
                  </fo:list-item>
               </xsl:for-each>
            </fo:list-block>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemGroup Keys                                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemGroupKeys">
      <xsl:variable name="datasetName" select="@Name" />
      <xsl:variable name="suppDatasetName" select="concat('SUPP', $datasetName)" />
      <xsl:variable name="sqDatasetName" select="concat('SQ', $datasetName)" />
      
      <xsl:variable name="ItemDef" select="$g_seqItemDefs[@Name='QVAL']" />
      <xsl:variable name="ItemDefValueListOID" select="$ItemDef[@OID=$g_seqItemGroupDefs[@Name = $suppDatasetName or @Name = $sqDatasetName]/odm:ItemRef/@ItemOID]/def:ValueListRef/@ValueListOID" />
      
      <xsl:for-each select="odm:ItemRef|$g_seqValueListDefs[@OID=$ItemDefValueListOID]/odm:ItemRef">
         <xsl:sort select="@KeySequence" data-type="number" order="ascending" />
         <xsl:if test="@KeySequence[ .!='' ]">
            <xsl:variable name="ItemOID" select="@ItemOID" />
            <xsl:variable name="Name" select="$g_seqItemDefs[@OID=$ItemOID]" />
            <xsl:if test="../@OID = $ItemDefValueListOID">QNAM.</xsl:if>  
            <xsl:value-of select="$Name/@Name" />
            <xsl:if test="position() != last()">, </xsl:if>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemGroup Header                                      -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemGroupDefHeader">
      <xsl:value-of select="concat(@Name, ' (', ./odm:Description/odm:TranslatedText)" />
      
      <xsl:variable name="ParentDescription">
         <xsl:call-template name="getParentDescription">
            <xsl:with-param name="OID" select="@OID" />
         </xsl:call-template>  
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($ParentDescription)) &gt; 0">
         <xsl:text>, </xsl:text><xsl:value-of select="$ParentDescription" /><xsl:text></xsl:text>
      </xsl:if>
      <xsl:text>) - </xsl:text>
      <xsl:value-of select="@def:Class" />
      <xsl:text> </xsl:text>
      <!--  Define-XML v2.1 -->
      <xsl:call-template name="displayStandard">
         <xsl:with-param name="element" select="'fo:inline'" />
      </xsl:call-template>
      <!--  Define-XML v2.1 -->
      <xsl:call-template name="displayNonStandard">
         <xsl:with-param name="element" select="'fo:inline'" />
      </xsl:call-template>
      <!--  Define-XML v2.1 -->
      <xsl:call-template name="displayNoData">
         <xsl:with-param name="element" select="'fo:inline'" />
      </xsl:call-template>  
      
      <xsl:variable name="archiveLocationID" select="@def:ArchiveLocationID" />
      <xsl:variable name="archiveTitle">
         <xsl:choose>
            <xsl:when test="def:leaf[@ID=$archiveLocationID]">
               <xsl:value-of select="def:leaf[@ID=$archiveLocationID]/def:title" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>[unresolved: </xsl:text><xsl:value-of select="@def:ArchiveLocationID" /><xsl:text>]</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <fo:leader leader-pattern="space" />
      <xsl:if test="@def:ArchiveLocationID">
         <fo:inline xsl:use-attribute-sets="dataset">
            <xsl:text>Location: </xsl:text>
            <xsl:call-template name="displayHyperlink">
               <xsl:with-param name="href" select="def:leaf[@ID=$archiveLocationID]/@xlink:href" />
               <xsl:with-param name="anchor" select="''" />
               <xsl:with-param name="title" select="$archiveTitle" />
            </xsl:call-template>
         </fo:inline>
      </xsl:if>
   </xsl:template>
   
   <!-- standard-refeference class  -->
   <xsl:template name="standard-refeference">
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="font-size">1em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_CAPTION" />
      </xsl:attribute>
      <xsl:attribute name="white-space">nowrap</xsl:attribute>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display Standard  (Define-XML v2.1)                           -->
   <!-- ************************************************************* -->
   <xsl:template name="displayStandard">
      
      <xsl:param name="element" select="'fo:inline'" />
      <xsl:variable name="StandardOID" select="@def:StandardOID" />
      <xsl:variable name="Standard" select="$g_seqStandard[@OID=$StandardOID]" />
      
      <xsl:if test="$StandardOID">
         <xsl:element name="{$element}">  
            <xsl:call-template name="standard-refeference" />
            <xsl:text>[</xsl:text>
            <xsl:value-of select="$Standard/@Name" /><xsl:text> </xsl:text>
            <xsl:if test="$Standard/@PublishingSet">
               <xsl:value-of select="$Standard/@PublishingSet" /><xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$Standard/@Version" />
            <xsl:text>]</xsl:text>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display NonStandard  (Define-XML v2.1)                        -->
   <!-- ************************************************************* -->
   <xsl:template name="displayNonStandard">
      
      <xsl:param name="element" select="'fo:inline'" />
      
      <xsl:if test="@def:IsNonStandard='Yes'">
         <xsl:element name="{$element}">  
            <xsl:call-template name="standard-refeference" />
            <xsl:text>[Non Standard]</xsl:text>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   
   <!-- no data  -->
   <xsl:template name="nodata">
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="font-size">1em</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="padding">5pt</xsl:attribute>
      <xsl:attribute name="color">
         <xsl:value-of select="$COLOR_WARNING" />
      </xsl:attribute>
      <xsl:attribute name="white-space">nowrap</xsl:attribute>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display NoData (Define-XML v2.1)                              -->
   <!-- ************************************************************* -->
   <xsl:template name="displayNoData">
      <xsl:param name="element" select="'fo:block'" />
      <xsl:if test="@def:HasNoData='Yes'">
         <xsl:element name="{$element}">  
            <xsl:call-template name="nodata" />
            <xsl:text>[No Data]</xsl:text>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display WhereClause                                           -->
   <!-- ************************************************************* -->
   <xsl:template name="displayWhereClause">
      <xsl:param name="ValueItemRef" />
      <xsl:param name="ItemGroupLink" />
      <xsl:param name="decode" />
      <xsl:param name="break" />
      
      <xsl:variable name="ValueRef" select="$ValueItemRef" />
      <xsl:variable name="Nwhereclauses" select="count(./def:WhereClauseRef)" />
      
      <xsl:for-each select="$ValueRef/def:WhereClauseRef">
         
         <xsl:if test="$Nwhereclauses &gt; 1"><xsl:text>(</xsl:text></xsl:if>
         <xsl:variable name="whereOID" select="./@WhereClauseOID" />
         <xsl:variable name="whereDef" select="$g_seqWhereClauseDefs[@OID=$whereOID]" />
         
         <xsl:if test="count($g_seqWhereClauseDefs[@OID=$whereOID])=0">
            <fo:inline> xsl:use-attribute-sets="unresolved">[unresolved: <xsl:value-of select="$whereOID" />]</fo:inline>
         </xsl:if>
         
         <xsl:for-each select="$whereDef/odm:RangeCheck">
            
            <xsl:variable name="whereRefItemOID" select="./@def:ItemOID" />
            <xsl:variable name="whereRefItemName" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@Name" />
            <xsl:variable name="whereOP" select="./@Comparator" />
            <xsl:variable name="whereRefItemCodeListOID"
                          select="$g_seqItemDefs[@OID=$whereRefItemOID]/odm:CodeListRef/@CodeListOID" />
            <xsl:variable name="whereRefItemCodeList"
                          select="$g_seqCodeLists[@OID=$whereRefItemCodeListOID]" />
            
            <xsl:call-template name="ItemGroupItemLink">
               <xsl:with-param name="ItemGroupOID" select="$ItemGroupLink" />
               <xsl:with-param name="ItemOID" select="$whereRefItemOID" />
               <xsl:with-param name="ItemName" select="$whereRefItemName" />
            </xsl:call-template> 
            
            <xsl:choose>
               <xsl:when test="$whereOP = 'IN' or $whereOP = 'NOTIN'">
                  <xsl:text> </xsl:text>
                  <xsl:variable name="Nvalues" select="count(./odm:CheckValue)" />
                  <xsl:choose>
                     <xsl:when test="$whereOP='IN'">
                        <xsl:text>IN</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>NOT IN</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text> (</xsl:text>
                  <xsl:if test="$decode='1'"><fo:block></fo:block></xsl:if>
                  <xsl:for-each select="./odm:CheckValue">
                     <xsl:variable name="CheckValueINNOTIN" select="." />
                     <fo:inline xsl:use-attribute-sets="linebreakcell">
                        <xsl:call-template name="displayValue">
                           <xsl:with-param name="Value" select="$CheckValueINNOTIN" />
                           <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                           <xsl:with-param name="decode" select="$decode" />
                           <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                        </xsl:call-template>
                        <xsl:if test="position() != $Nvalues">
                           <xsl:value-of select="', '" />
                        </xsl:if>
                     </fo:inline>
                     <xsl:if test="$decode='1'"><fo:block></fo:block></xsl:if>
                  </xsl:for-each>
                  <xsl:text>) </xsl:text>
               </xsl:when>
               <xsl:when test="$whereOP = 'EQ'">
                  <xsl:variable name="CheckValueEQ" select="./odm:CheckValue" />
                  <xsl:value-of select="$Comparator_EQ" />
                  <xsl:call-template name="displayValue">
                     <xsl:with-param name="Value" select="$CheckValueEQ" />
                     <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                     <xsl:with-param name="decode" select="$decode" />
                     <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                  </xsl:call-template>
               </xsl:when>
               <xsl:when test="$whereOP = 'NE'">
                  <xsl:variable name="CheckValueNE" select="./odm:CheckValue" />
                  <xsl:value-of select="$Comparator_NE" /> 
                  <xsl:call-template name="displayValue">
                     <xsl:with-param name="Value" select="$CheckValueNE" />
                     <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                     <xsl:with-param name="decode" select="$decode" />
                     <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="CheckValueOTH" select="./odm:CheckValue" />
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                     <xsl:when test="$whereOP='LT'">
                        <xsl:value-of select="$Comparator_LT" />
                     </xsl:when>
                     <xsl:when test="$whereOP='LE'">
                        <xsl:value-of select="$Comparator_LE" />
                     </xsl:when>
                     <xsl:when test="$whereOP='GT'">
                        <xsl:value-of select="$Comparator_GT" />
                     </xsl:when>
                     <xsl:when test="$whereOP='GE'">
                        <xsl:value-of select="$Comparator_GE" />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$whereOP" />
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:call-template name="displayValue">
                     <xsl:with-param name="Value" select="$CheckValueOTH" />
                     <xsl:with-param name="DataType" select="$g_seqItemDefs[@OID=$whereRefItemOID]/@DataType" />
                     <xsl:with-param name="decode" select="$decode" />
                     <xsl:with-param name="CodeList" select="$whereRefItemCodeList" />
                  </xsl:call-template>            
               </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="position() != last()">
               <xsl:text> and </xsl:text>
               <xsl:if test="$break='1'"><fo:block></fo:block></xsl:if>
            </xsl:if>
         </xsl:for-each>
         
         <xsl:if test="$Nwhereclauses &gt; 1"><xsl:text>)</xsl:text></xsl:if>
         <xsl:if test="position() != last()">
            <fo:block></fo:block> /><xsl:text> or </xsl:text><fo:block></fo:block>
            <!-- only if this is not the last WhereRef in the ItemRef  -->
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- displayValue                                                  -->
   <!-- ************************************************************* -->
   <xsl:template name="displayValue">
      <xsl:param name="Value" />
      <xsl:param name="DataType" />
      <xsl:param name="decode" />
      <xsl:param name="CodeList" />
      
      <xsl:if test="$DataType != 'integer' and $DataType != 'float'">
         <xsl:text>"</xsl:text><xsl:value-of select="$Value" /><xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="$DataType = 'integer' or $DataType = 'float'">
         <xsl:value-of select="$Value" />
      </xsl:if>
      <xsl:if test="$decode='1'">
         <xsl:if test="$CodeList/odm:CodeListItem[@CodedValue=$Value]">
            <xsl:text> (</xsl:text>  
            <xsl:value-of
               select="$CodeList/odm:CodeListItem[@CodedValue=$Value]/odm:Decode/odm:TranslatedText" />
            <xsl:text>)</xsl:text>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to ItemGroup Item                                        -->
   <!-- ************************************************************* -->
   <xsl:template name="ItemGroupItemLink">
      <xsl:param name="ItemGroupOID" />
      <xsl:param name="ItemOID" />
      <xsl:param name="ItemName" />
      <xsl:choose>
         <xsl:when test="$g_seqItemGroupDefs[@OID=$ItemGroupOID]/odm:ItemRef[@ItemOID=$ItemOID]">
            <xsl:variable name="ItemDescription" select="$g_seqItemDefs[@OID=$ItemOID]/odm:Description/odm:TranslatedText" />
            <fo:basic-link xsl:use-attribute-sets="link">
               <xsl:attribute name="internal-destination">
                  <xsl:value-of select="$ItemGroupOID" />.<xsl:value-of select="$ItemOID" />
               </xsl:attribute>
               <xsl:value-of select="$ItemName" />
            </fo:basic-link>
         </xsl:when>
         <xsl:otherwise>
            <!-- Item is not in current ItemGroup; only link when Item can be uniquely found in other ItemGroup -->
            <xsl:variable name="linkItems" select="count($g_seqItemGroupDefs/odm:ItemRef[@ItemOID=$ItemOID])" />
            <xsl:choose>
               <xsl:when test="$linkItems = 1">
                  <xsl:variable name="ItemDescription" select="$g_seqItemDefs[@OID=$ItemOID]/odm:Description/odm:TranslatedText" />
                  <fo:basic-link xsl:use-attribute-sets="link">
                     <xsl:attribute name="internal-destination">
                        <xsl:value-of select="$g_seqItemGroupDefs/odm:ItemRef[@ItemOID=$ItemOID]/../@OID" />.<xsl:value-of select="$ItemOID" />
                     </xsl:attribute>
                     <xsl:value-of select="$ItemName" />
                  </fo:basic-link>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$ItemName" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length(normalize-space($ItemName))=0">
         <fo:inline xsl:use-attribute-sets="unresolved">
            <xsl:text>[unresolved: </xsl:text>
            <xsl:value-of select="$ItemOID" />
            <xsl:text>]</xsl:text>
         </fo:inline>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display ItemDef DecodeList                                    -->
   <!-- ************************************************************* -->
   <xsl:template name="displayItemDefDecodeList">
      <xsl:param name="itemDef" />
      <xsl:variable name="CodeListOID" select="$itemDef/odm:CodeListRef/@CodeListOID" />
      <xsl:variable name="CodeListDef" select="$g_seqCodeLists[@OID=$CodeListOID]" />
      <xsl:variable name="n_items" select="count($CodeListDef/odm:CodeListItem|$CodeListDef/odm:EnumeratedItem)" />
      <xsl:variable name="CodeListDataType" select="$CodeListDef/@DataType" />
      
      <xsl:if test="$itemDef/odm:CodeListRef">
         
         <xsl:choose>
            <xsl:when test="$n_items &lt;= $nCodeListItemDisplay and $CodeListDef/odm:CodeListItem">
               <fo:inline xsl:use-attribute-sets="linebreakcell">
                  <fo:basic-link xsl:use-attribute-sets="link">
                     <xsl:attribute name="internal-destination">
                        <xsl:text>CL.</xsl:text>
                        <xsl:value-of select="$CodeListDef/@OID" />
                     </xsl:attribute>
                     <xsl:value-of select="$CodeListDef/@Name" />
                  </fo:basic-link>
               </fo:inline>
               <fo:list-block xsl:use-attribute-sets="codelist">
                  <xsl:for-each select="$CodeListDef/odm:CodeListItem">
                     <fo:list-item provisional-distance-between-starts="0mm"
                                   provisional-label-separation="2mm">
                        <fo:list-item-label start-indent="0mm" end-indent="label-end()">
                           <fo:block></fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                           <fo:block>
                              <xsl:if test="$CodeListDataType='text'">
                                 <xsl:text>&#8226;&#160;</xsl:text><xsl:value-of select="concat('&quot;', @CodedValue, '&quot;')" />
                              </xsl:if>
                              <xsl:if test="$CodeListDataType != 'text'">
                                 <xsl:text>&#8226;&#160;</xsl:text><xsl:value-of select="@CodedValue" />
                              </xsl:if>
                              <xsl:text> = </xsl:text>
                              <xsl:value-of select="concat('&quot;', odm:Decode/odm:TranslatedText, '&quot;')" />
                           </fo:block>
                        </fo:list-item-body>
                     </fo:list-item>
                  </xsl:for-each>
               </fo:list-block>
            </xsl:when>
            <xsl:when test="$n_items &lt;= $nCodeListItemDisplay and $CodeListDef/odm:EnumeratedItem">
               <fo:inline xsl:use-attribute-sets="linebreakcell">
                  <fo:basic-link xsl:use-attribute-sets="link">
                     <xsl:attribute name="internal-destination">
                        <xsl:text>CL.</xsl:text>
                        <xsl:value-of select="$CodeListDef/@OID" />
                     </xsl:attribute>
                     <xsl:value-of select="$CodeListDef/@Name" />
                  </fo:basic-link>
               </fo:inline>
               <fo:list-block xsl:use-attribute-sets="codelist">
                  <xsl:for-each select="$CodeListDef/odm:EnumeratedItem">
                     <fo:list-item provisional-distance-between-starts="0mm"
                                   provisional-label-separation="2mm">
                        <fo:list-item-label start-indent="0mm" end-indent="label-end()">
                           <fo:block></fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                           <fo:block>
                              <xsl:if test="$CodeListDataType='text'">
                                 <xsl:text>&#8226;&#160;</xsl:text><xsl:value-of select="concat('&quot;', @CodedValue, '&quot;')" />
                              </xsl:if>
                              <xsl:if test="$CodeListDataType != 'text'">
                                 <xsl:text>&#8226;&#160;</xsl:text><xsl:value-of select="@CodedValue" />
                              </xsl:if>
                           </fo:block>
                        </fo:list-item-body>
                     </fo:list-item>
                  </xsl:for-each>
               </fo:list-block>
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="$g_seqCodeLists[@OID=$CodeListOID]">
                     <fo:basic-link xsl:use-attribute-sets="link">
                        <xsl:attribute name="internal-destination">
                           <xsl:text>CL.</xsl:text>
                           <xsl:value-of select="$CodeListDef/@OID" />
                        </xsl:attribute>
                        <xsl:value-of select="$CodeListDef/@Name" />
                     </fo:basic-link>
                  </xsl:when>
                  <xsl:otherwise>
                     <fo:inline xsl:use-attribute-sets="unresolved">
                        <xsl:text>[unresolved: </xsl:text>
                        <xsl:value-of select="$itemDef/odm:CodeListRef/@CodeListOID" />
                        <xsl:text>]</xsl:text>
                     </fo:inline>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="$CodeListDef/odm:ExternalCodeList">
                  <fo:block xsl:use-attribute-sets="linebreakcell">
                     <xsl:value-of select="$CodeListDef/odm:ExternalCodeList/@Dictionary" />
                     <xsl:text> </xsl:text>
                     <xsl:value-of select="$CodeListDef/odm:ExternalCodeList/@Version" />
                  </fo:block>
               </xsl:if>
               <xsl:if test="$n_items &gt; $nCodeListItemDisplay">
                  <xsl:choose>
                     <xsl:when test="$n_items &gt; 1">
                        <fo:block xsl:use-attribute-sets="linebreakcell"> [<xsl:value-of select="$n_items" /> Terms] </fo:block>
                     </xsl:when>
                     <xsl:otherwise>
                        <fo:block xsl:use-attribute-sets="linebreakcell"> [<xsl:value-of select="$n_items" /> Term] </fo:block>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>  
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Template:    setRowClassOddeven                               -->
   <!-- Description: This template sets the table row class attribute -->
   <!--              based on the specified table row number          -->
   <!-- ************************************************************* -->
   <xsl:template name="setRowClassOddeven">
      <!-- rowNum: current table row number (1-based) -->
      <xsl:param name="rowNum" />
      <!-- set the class attribute to "tableroweven" for even rows, "tablerowodd" for odd rows -->
      <xsl:attribute name="background-color">
         <xsl:choose>
            <xsl:when test="$rowNum mod 2 = 0">
               <xsl:value-of select="$COLOR_TABLEROW_EVEN" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$COLOR_TABLEROW_ODD" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:attribute>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Template:    stringReplace                                    -->
   <!-- Description: Replace all occurences of the character(s)       -->
   <!--              'from' by 'to' in the string 'string'            -->
   <!-- ************************************************************* -->
   <xsl:template name="stringReplace">
      <xsl:param name="string" />
      <xsl:param name="from" />
      <xsl:param name="to" />
      <xsl:choose>
         <xsl:when test="contains($string,$from)">
            <xsl:value-of select="substring-before($string,$from)" />
            <xsl:copy-of select="$to" />
            <xsl:call-template name="stringReplace">
               <xsl:with-param name="string" select="substring-after($string,$from)" />
               <xsl:with-param name="from" select="$from" />
               <xsl:with-param name="to" select="$to" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- ***************************************** -->
   <!-- Display ISO8601                           -->
   <!-- ***************************************** -->
   <xsl:template name="displayItemDefISO8601">
      <xsl:param name="itemDef" />
      <!-- when the datatype is one of the date/time datatypes, display 'ISO8601' in this column -->
      <xsl:if
         test="$itemDef/@DataType='date' or 
            $itemDef/@DataType='time' or 
            $itemDef/@DataType='datetime' or 
            $itemDef/@DataType='partialDate' or 
            $itemDef/@DataType='partialTime' or 
            $itemDef/@DataType='partialDatetime' or 
            $itemDef/@DataType='incompleteDatetime' or 
            $itemDef/@DataType='durationDatetime'">
         <xsl:text>ISO 8601</xsl:text>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Template:    lineBreak                                        -->
   <!-- Description: This template adds a line break element          -->
   <!-- ************************************************************* -->
   <xsl:template name="lineBreak">
      <!-- <xsl:text>&#xa;</xsl:text> -->
      <fo:block line-height="150%"></fo:block>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Template:    noBreakSpace                                     -->
   <!-- Description: This template returns a no-break-space character -->
   <!-- ************************************************************* -->
   <xsl:template name="noBreakSpace">
      <!-- equivalent to &nbsp; -->
      <xsl:text />
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Link to Top                                                   -->
   <!-- ************************************************************* -->
   <xsl:template name="linkTop">
      <fo:inline>
         <xsl:text>Go to the </xsl:text>
         <fo:basic-link xsl:use-attribute-sets="link">
            <xsl:attribute name="internal-destination">main</xsl:attribute>
            <xsl:text>top </xsl:text>
         </fo:basic-link>
         <xsl:text>of the Define-XML document</xsl:text>
      </fo:inline>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display image                                                 -->
   <!-- ************************************************************* -->
   <xsl:template name="displayImage">
      <!-- <fo:external-graphic>
           <xsl:attribute name="src">
           <xsl:text>
           data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9gCGhErDWL4mOoAAAB6SURBVBjTbVCxDcAgDHNRP2KDY9gYO5YbWNno1mPY6E3pAJEIYCmCOCQOPogII6wNkug4d49KiXMz1EiUEg8uLBN3Ui7FVduYmxjG3JRru+facubVuIdLEV4Dzwe8V4BYg7t4Ap+d57qUnuWICBzi116v1ggfd3bM+AEZWXFvnym8EwAAAABJRU5ErkJggg==
           </xsl:text>
           </xsl:attribute>
           </fo:external-graphic> -->
      <!-- <fo:inline>
           <xsl:attribute name="font-size">0.8em</xsl:attribute>
           <xsl:attribute name="background-image"> 
           <xsl:text>
           data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9gCGhErDWL4mOoAAAB6SURBVBjTbVCxDcAgDHNRP2KDY9gYO5YbWNno1mPY6E3pAJEIYCmCOCQOPogII6wNkug4d49KiXMz1EiUEg8uLBN3Ui7FVduYmxjG3JRru+facubVuIdLEV4Dzwe8V4BYg7t4Ap+d57qUnuWICBzi116v1ggfd3bM+AEZWXFvnym8EwAAAABJRU5ErkJggg==
           </xsl:text>
           </xsl:attribute>
           <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
           <xsl:attribute name="background-position-horizontal">right</xsl:attribute>
           <xsl:attribute name="background-position-vertical">top</xsl:attribute>
           <xsl:attribute name="padding">5pt</xsl:attribute>
           <xsl:text>_</xsl:text>
           </fo:inline> -->
     </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display Document Generation Date                              -->
   <!-- ************************************************************* -->
   <xsl:template name="displayODMCreationDateTimeDate">
      <fo:block text-align-last="justify" xsl:use-attribute-sets="docinfo-line">  
         <fo:leader leader-pattern="space" /> Date/Time of Define-XML document generation: <xsl:value-of select="/odm:ODM/@CreationDateTime" />
      </fo:block>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display Document Context (Define-XML v2.1)                    -->
   <!-- ************************************************************* -->
   <xsl:template name="displayContext">
      <xsl:if test="/odm:ODM/@def:Context">
         <fo:block text-align-last="justify" xsl:use-attribute-sets="docinfo-line">  
            <fo:leader leader-pattern="space" /> Define-XML Context: <xsl:value-of select="/odm:ODM/@def:Context" />
         </fo:block>
      </xsl:if>  
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display Define-XML Version                                    -->
   <!-- ************************************************************* -->
   <xsl:template name="displayDefineXMLVersion">
      <xsl:if test="$g_DefineVersion">
         <fo:block text-align-last="justify" xsl:use-attribute-sets="docinfo-line">  
            <fo:leader leader-pattern="space" /> Define-XML version: <xsl:value-of select="$g_DefineVersion" />
         </fo:block>
      </xsl:if>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Display StyleSheet Date                                       -->
   <!-- ************************************************************* -->
   <xsl:template name="displayStylesheetDate">
      <fo:block text-align-last="justify" xsl:use-attribute-sets="docinfo-line">  
         <fo:leader leader-pattern="space" /> Stylesheet version: <xsl:value-of select="$STYLESHEET_VERSION" />
      </fo:block>
   </xsl:template>
   
   <!-- ************************************************************* -->
   <!-- Catch the rest                                                -->
   <!-- ************************************************************* -->
   <xsl:template match="/odm:ODM/odm:Study/odm:GlobalVariables" />
   <xsl:template match="/odm:ODM/odm:Study/odm:BasicDefinitions" />
   <xsl:template match="/odm:ODM/odm:Study/odm:MetaDataVersion" />
</xsl:stylesheet>