<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
   xmlns=""
   xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
   xmlns:da="https://ns.starbucks.com/creative/document-automation/1.0"
   xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-Instance"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform https://www.w3.org/2007/schema-for-xslt20.xsd">

   <xsl:output method="xml" version="1.0" encoding="utf-8" standalone="yes" indent="no" />
   <xsl:decimal-format name="default" grouping-separator="," decimal-separator="." NaN="X.XX" />
   <xsl:decimal-format name="fr-CA" grouping-separator="&#x20;" decimal-separator="," NaN="X,XX" />
   <xsl:param name="hasPricing" select="translate(//da:transformation/da:templateData/da:sections/da:section/da:fields/da:field[@name='Exclude Price']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') != 'yes'" />
   <xsl:param name="chalkPrice" select="translate(//da:transformation/da:templateData/da:sections/da:section[@name='Hero']/da:fields/da:field[@name='Chalk Price']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>
   <xsl:param name="hasFootnote" select="translate(//da:transformation/da:templateData/da:sections/da:section[@name='Hero']/da:fields/da:field[@name='Include Footnote']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>
   <xsl:param name="includeLineBreak" select="translate(//da:transformation/da:templateData/da:sections/da:section[@name='Hero']/da:fields/da:field[@name='Include Linebreak']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'yes'" />
   <xsl:param name="hasLSPricing" select="translate(//da:transformation/da:output/da:metadata/da:meta[@id='http://ns.starbucks.com/en/menu_information/1.0/ has_ls_pricing']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'true'" />
   <xsl:param name="locale">
      <xsl:choose>
         <xsl:when test="//da:transformation/da:context/da:variables/da:variable[@name='locale']">
            <xsl:value-of select="//da:transformation/da:context/da:variables/da:variable[@name='locale']" />
         </xsl:when>
         <xsl:otherwise>en</xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <xsl:param name="market" select="//da:transformation/da:context/da:variables/da:variable[@name='market']/text()" />
   <xsl:param name="maxNumberOfLineListings">4</xsl:param>
   <xsl:param name="maxNumberOfProductImages">3</xsl:param>
   <xsl:param name="menuCode" select="//da:transformation/@id" />
   <xsl:param name="priceLineElementName">
      <xsl:choose>
         <xsl:when test="$market = 'CA'">
            <xsl:choose>
               <xsl:when test="$hasPricing">PriceLine-CAN</xsl:when>
               <xsl:otherwise>PriceLine-CAN_NoPrice</xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$market = 'US'">PriceLine-US</xsl:when>
         <xsl:otherwise>PriceLine</xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <xsl:param name="priceLineElementNameELL">
      <xsl:choose>
         <xsl:when test="$market = 'CA'">ELL_CAN-Priced</xsl:when>
         <xsl:otherwise>ELL_US</xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <xsl:param name="storeType" select="//da:transformation/da:context/da:variables/da:variable[@name='storeType']/text()" />
   <xsl:param name="versionName" select="//da:transformation/da:context/da:variables/da:variable[@name='versionName']/text()" />

   <xsl:key name="protein" match="//da:transformation/da:templateData/da:sections/da:section[@name='Hero']/da:products/da:product/da:sellableItems/da:sellableItem/da:servingSize[@code='Serving']/da:nutrition" use="@displayName" />

   <xsl:template match="/">
      <xsl:variable name="footerSection" select="//da:transformation/da:templateData/da:sections/da:section[@name='Footer']" />
      <xsl:variable name="CTA" select="$footerSection/da:fields/da:field[@name='CallToAction']/text()" />
      <xsl:variable name="CupCharge" select="$footerSection/da:fields/da:field[@name='CupCharge']/text()" />
      <xsl:variable name="backgroundImage" select="//da:transformation/da:templateData/da:sections/da:section[@name='BackgroundImage']" />

      <xsl:element name="Root">

         <xsl:call-template name="header">
            <xsl:with-param name="allocation">
               <xsl:value-of select="$market" />
               <xsl:text>&#xa0;</xsl:text>
               <xsl:value-of select="$storeType" />
               <xsl:text>&#xa0;&#x2011;&#xa0;</xsl:text>
               <xsl:value-of select="$versionName" />
            </xsl:with-param>
            <xsl:with-param name="menucode" select="$menuCode" />
         </xsl:call-template>

         <xsl:call-template name="documentStructure">
            <xsl:with-param name="section" select="//da:transformation/da:templateData/da:sections/da:section[@name='Hero']" />
            <xsl:with-param name="listings" select="//da:transformation/da:templateData/da:sections/da:section[@name='LineListings']" />
         </xsl:call-template>

         <xsl:if test="$CTA or $CupCharge">
            <xsl:element name="BottomBox">
               <xsl:element name="CTA">
                  <xsl:value-of select="$CTA" />
               </xsl:element>
               <xsl:text>&#x2029;</xsl:text>
               <xsl:element name="CupCharge">
                  <xsl:value-of select="$CupCharge" />
               </xsl:element>
            </xsl:element>
         </xsl:if>
         <xsl:if test="$footerSection/da:fields/da:field[@name='CupCharge']/text() != ''">
            <xsl:element name="CupCharge">
               <xsl:value-of select="$footerSection/da:fields/da:field[@name='CupCharge']/text()" />
            </xsl:element>
         </xsl:if>
         <xsl:element name="CopyrightLine">
            <xsl:value-of select="$footerSection/da:fields/da:field[@name='Copyright']/text()" />
         </xsl:element>
         <xsl:if test="$backgroundImage/da:products/da:product">
            <xsl:variable name="product" select="$backgroundImage/da:products/da:product" />
            <xsl:if test="translate($product/da:annotations/da:annotation[@name='imageRequired']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">BackgroundImage</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id=$product/@referenceId]/text()" />
               </xsl:call-template>
            </xsl:if>
         </xsl:if>
      </xsl:element>
   </xsl:template>

   <xsl:template name="header">
      <xsl:param name="allocation" />
      <xsl:param name="menucode" />
      <xsl:element name="MenuCode">
         <xsl:value-of select="$menucode" />
      </xsl:element>
      <xsl:element name="Allocation">
         <xsl:value-of select="$allocation" />
      </xsl:element>
   </xsl:template>

   <xsl:template name="documentStructure">
      <xsl:param name="section" />
      <xsl:param name="listings" />
      <xsl:param name="excludeCal" select="translate($section/da:fields/da:field[@name='Exclude Calorie']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'" />
      <xsl:param name="excludeProtein" select="translate($section/da:fields/da:field[@name='Exclude Protein']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>
      <xsl:param name="chalkPrice" select="translate($section/da:fields/da:field[@name='Chalk Price']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>
      <xsl:param name="altHeadline" select="translate($section/da:fields/da:field[@name='Alternate Headline Color' or @name='Alternate Headline Style']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'yes'"/>

      <xsl:variable name="HeadlineTag">
         <xsl:choose>
            <xsl:when test="$altHeadline">
               <xsl:text>HeadlineExp</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Headline</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:if test="$section/da:fields/da:field[@name='Introducing']/text()">
         <xsl:element name="Introducing">
            <xsl:value-of select="$section/da:fields/da:field[@name='Introducing']/text()" />
         </xsl:element>
         <xsl:text>&#x2029;</xsl:text>
      </xsl:if>
      <xsl:element name="HeadlineBox">
         <xsl:element name="{$HeadlineTag}">
            <xsl:value-of select="$section/da:fields/da:field[@name='Headline']" />
         </xsl:element>
         <xsl:text>&#x2029;</xsl:text>
         <xsl:element name="Subhead">
            <xsl:value-of select="$section/da:fields/da:field[@name='Subheading1']" />
            <xsl:if test="$section/da:fields/da:field[@name='Subheading2']/text()">
               <xsl:text>&#x2028;</xsl:text>
               <xsl:value-of select="$section/da:fields/da:field[@name='Subheading2']" />
            </xsl:if>
         </xsl:element>
      </xsl:element>

      <!-- allow for max 2 products -->
      <xsl:for-each select="$section/da:products/da:product[position() &lt;= $maxNumberOfProductImages]">
         <xsl:call-template name="productItem">
            <xsl:with-param name="product" select="." />
            <xsl:with-param name="excludeCal" select="$excludeCal"/>
            <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
            <xsl:with-param name="excludeProtein" select="$excludeProtein"/>
         </xsl:call-template>
      </xsl:for-each>

      <xsl:if test="$listings">
         <xsl:element name="ELL_HeadlineBox">
            <xsl:element name="ELLHeadline">
               <xsl:value-of select="$listings/da:fields/da:field[@name='Headline']/text()" />
            </xsl:element>
            <xsl:if test="$listings/da:fields/da:field[@name='Descriptor']/text()">
               <xsl:text>&#x2029;</xsl:text>
               <xsl:element name="DescriptorLockup">
                  <xsl:value-of select="$listings/da:fields/da:field[@name='Descriptor']/text()" />
               </xsl:element>
            </xsl:if>
         </xsl:element>
         <xsl:element name="ELL_BOX">
            <!-- allow for max 4 line listings -->
            <xsl:for-each select="$listings/da:products/da:product[position() &lt; $maxNumberOfLineListings]">
               <xsl:call-template name="linelisting">
                  <xsl:with-param name="product" select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>

      <xsl:if test="(($hasFootnote) and $section/da:fields/da:field[@name='Footnote']/text())">
         <xsl:text>&#x2028;</xsl:text>
         <xsl:element name="Footnote">
            <xsl:text>&#x20;&#x20;</xsl:text>
            <xsl:value-of select="$section/da:fields/da:field[@name='Footnote']/text()" />
         </xsl:element>
      </xsl:if>

   </xsl:template>

   <xsl:template name="productItem">
      <xsl:param name="product" />
      <xsl:param name="excludeCal" />
      <xsl:param name="excludeProtein" />
      <xsl:param name="chalkPrice" />

      <!-- if Menu Content Builder indicates to show a product image, create a ProductImg element for the linked asset -->
      <xsl:if test="translate($product/da:annotations/da:annotation[@name='imageRequired']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
         <xsl:call-template name="linkedAsset">
            <xsl:with-param name="elementName">ProductImg</xsl:with-param>
            <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id=$product/@referenceId]/text()" />
         </xsl:call-template>
      </xsl:if>

      <xsl:call-template name="badges">
         <xsl:with-param name="product" select="$product" />
      </xsl:call-template>

      <!-- <xsl:choose>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isNew']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='new_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isNewOutline']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='new_food_topper_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isReturning']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='back_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isReturningOutline']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='back_outline_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isFreshlyBaked']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='freshly_baked_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isVegetarian']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">Bug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='vegetarian_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isTheyreReturning']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='theyre_back_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isTheyreReturningSolid']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='theyre_back_solid_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="translate($product/da:annotations/da:annotation[@name='isNewRibbonSolid']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
            <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='new_ribbon_solid_bug']/text()" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise> -->
            <!-- create an empty NewBug element; without it, InDesign skips the flavor listing  -->
            <!-- <xsl:call-template name="linkedAsset">
               <xsl:with-param name="elementName">NewBug</xsl:with-param>
               <xsl:with-param name="reference" />
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose> -->

      <!-- populate Product element with Menu Content Builder data -->
      <xsl:element name="ProductBox">
         <xsl:element name="ProductName">
            <xsl:value-of select="$product/da:name" />
         </xsl:element>
         <xsl:if test="$includeLineBreak">
            <xsl:text>&#x2029;</xsl:text>
         </xsl:if>
         <xsl:if test="$product/da:descriptor/text()">
            <xsl:element name="MarkDescriptor">
               <xsl:value-of select="$product/da:descriptor/text()" />
            </xsl:element>
         </xsl:if>
         <xsl:if test="$product/da:altDescriptor/text()">
            <xsl:text>&#x2029;</xsl:text>
            <xsl:element name="ProductDescriptor">
               <xsl:value-of select="$product/da:altDescriptor/text()" />
            </xsl:element>
         </xsl:if>
         <xsl:if test="$product/da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()">
            <xsl:text>&#x2029;</xsl:text>
            <xsl:element name="ProductRegulatoryStmt">
               <xsl:value-of select="$product/da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()"></xsl:value-of>
            </xsl:element>
         </xsl:if>
         <xsl:text>&#x2029;</xsl:text>
         <!-- populate PriceLine element with details from serving size Grande (for beverages) or Serving (for food) -->
         <!-- adding hard-coded fix for Venti-only beverages, like Energy drinks, to display correct pricing and nutrition data -->
         <xsl:choose>
            <xsl:when test="$product[@id='25245' or @id='25246'] or contains($product/da:name,'Melon Burst') or contains($product/da:name,'Tropical Citrus')">
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Venti']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:when>
            <xsl:when test="$market = 'CA' and $storeType = 'LS' and $product[@id='7266']">
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="excludePrice" select="true()"/>
                     <xsl:with-param name="excludeCal" select="$excludeCal"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="excludeProtein" select="true()"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Serving']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:when>
            <xsl:when test="$market = 'CA' and $storeType = 'LS' and $product[@id='7784']">
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="excludePrice" select="true()"/>
                     <xsl:with-param name="excludeCal" select="$excludeCal"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="excludeProtein" select="false()"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Serving']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:when>
            <xsl:when test="$market = 'CA' and $product[@id='7307']">
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="excludePrice" select="true()"/>
                     <xsl:with-param name="excludeCal" select="$excludeCal"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="excludeProtein" select="true()"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Serving']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:when>
            <xsl:when test="$market = 'CA' and $product[@id='7466']">
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="excludePrice" select="true()"/>
                     <xsl:with-param name="excludeCal" select="$excludeCal"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="excludeProtein" select="true()"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Serving']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:element name="{$priceLineElementName}">
                  <xsl:call-template name="priceLineText">
                     <xsl:with-param name="product" select="$product"/>
                     <xsl:with-param name="excludeCal" select="$excludeCal"/>
                     <xsl:with-param name="chalkPrice" select="$chalkPrice"/>
                     <xsl:with-param name="excludeProtein" select="$excludeProtein"/>
                     <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving']" />
                  </xsl:call-template>
               </xsl:element>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>

   </xsl:template>

   <xsl:template name="priceLineText">
      <xsl:param name="product" />
      <xsl:param name="excludePrice" />
      <xsl:param name="servingSize" />
      <xsl:param name="excludeCal" />
      <xsl:param name="chalkPrice" />
      <xsl:param name="excludeProtein" />
      <!-- Include Serving Size for Beverages -->
      <!-- allow flexibility for Food item-->
      <xsl:call-template name="formattedServingProtein">
         <xsl:with-param name="servingSize" select="$servingSize" />
         <xsl:with-param name="excludeProtein" select="$excludeProtein" />
         <xsl:with-param name="excludeCalorie" select="$excludeCal" />
      </xsl:call-template>
      <xsl:if test="$hasPricing and $product/@includePrice != 'False'">
         <xsl:choose>
            <xsl:when test="$hasLSPricing">
               <xsl:value-of select="$servingSize/parent::da:sellableItem/@sku" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="$chalkPrice">
                     <xsl:text>$&#x2002;&#x2002;&#x2002;&#x2002;&#x2002;</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:call-template name="formattedPrice">
                        <xsl:with-param name="price" select="$servingSize/da:price" />
                     </xsl:call-template>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="not($excludeCal)">
            <xsl:text>&#8197;|&#8197;</xsl:text>
         </xsl:if>
      </xsl:if>
      <!-- <xsl:if test="not($excludeCal) and not($hasPricing)">
         <xsl:text>&#8197;|&#8197;</xsl:text>
      </xsl:if> -->
      <xsl:if test="not($excludeCal)">
         <xsl:call-template name="formattedNutrition">
            <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
            <xsl:with-param name="includeDisplayName" select="false()" />
         </xsl:call-template>
      </xsl:if>

      <!-- test hard-coded product menuID for Energy-specific drinks to show caffeine data -->
      <!-- 25245/6 is MenuProdID -->
      <xsl:if test="$servingSize/parent::da:sellableItem/parent::da:sellableItems/parent::da:product[@id='25245' or @id='25246']">
         <xsl:call-template name="caffeineData">
            <xsl:with-param name="caffeine" select="$servingSize/da:nutrition[@displayName='Caffeine']" />
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <xsl:template name="linelisting">
      <xsl:param name="product" />
      <xsl:variable name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande']" />

      <xsl:element name="ELL">
         <xsl:value-of select="$product/da:name" />
         <xsl:text>&#x9;</xsl:text>
      </xsl:element>
      <xsl:element name="{$priceLineElementNameELL}">
         <xsl:value-of select="$servingSize/@code" />
         <xsl:if test="$hasPricing">
            <xsl:text>&#8197;</xsl:text>
            <xsl:choose>
               <xsl:when test="$hasLSPricing">
                  <xsl:value-of select="$servingSize/parent::da:sellableItem/@sku" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="formattedPrice">
                     <xsl:with-param name="price" select="$servingSize/da:price" />
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <xsl:text>&#8197;|&#x9;</xsl:text>
         <xsl:call-template name="formattedNutrition">
            <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
            <xsl:with-param name="includeDisplayName" select="false()" />
         </xsl:call-template>
      </xsl:element>
      <xsl:if test="position()!=last()">
         <xsl:text>&#x2029;</xsl:text>
      </xsl:if>

   </xsl:template>

   <xsl:template name="formattedServingProtein">
      <xsl:param name="servingSize" />
      <xsl:param name="excludeProtein" />
      <xsl:param name="excludeCalorie" />
      <xsl:choose>
         <!-- test what should be displayed before pricing -->
         <!-- if food item, potentially show protein info -->
         <xsl:when test="$servingSize/@code = 'Serving'">
            <xsl:if test="not($excludeProtein)">
               <xsl:for-each select="key('protein', 'Protein')">
                  <!-- only output protein of the Food item -->
                  <xsl:value-of select="@value"/>
                  <xsl:text>&#x0020;</xsl:text>
                  <xsl:value-of select="@unit"/>
                  <xsl:text>&#x2002;</xsl:text>
                  <xsl:value-of select="@displayName"/>
               </xsl:for-each>
               <!-- hide show proceeding delimiters if not hiding subsequent info -->
               <xsl:if test="$hasPricing or not($excludeCalorie)">
                  <xsl:text>&#8197;|&#8197;</xsl:text>
               </xsl:if>
            </xsl:if>
         </xsl:when>
         <!-- if not food item i.e. a beverage show drink size but only if not hiding pricing -->
         <xsl:otherwise>
            <xsl:value-of select="$servingSize/@code" />
            <xsl:choose>
               <xsl:when test="not($hasPricing)">
                  <xsl:choose>
                     <xsl:when test="$excludeCalorie">
                        <xsl:text></xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>&#8197;|&#8197;</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>&#8197;</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="formattedPrice">
      <xsl:param name="price" />
      <xsl:choose>
         <!-- when price is below $1 (but not 0), show price in cents -->
         <xsl:when test="($price &gt; 0) and ($price &lt; 1)">
            <xsl:number value="number($price) * 100" />
            <xsl:text>¢</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- else show price in 0.00 format (0,00 format for fr-CA)  -->
            <xsl:choose>
               <xsl:when test="$locale='fr-CA'">
                  <xsl:value-of select="format-number(number($price), '#&#x20;##0,00', $locale)" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="format-number(number($price), '#,##0.00', 'default')" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="formattedNutrition">
      <xsl:param name="nutrient" />
      <xsl:param name="includeDisplayName" />

      <xsl:variable name="unit">
         <xsl:choose>
            <xsl:when test="$nutrient">
               <xsl:choose>
                  <xsl:when test="translate($nutrient/@unit, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='cal' and $market='CA'">Cals</xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$nutrient/@unit" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>XXXX</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="$nutrient">
            <xsl:value-of select="$nutrient/@value" />
            <xsl:text>&#xA0;</xsl:text>
            <xsl:value-of select="$unit" />
            <xsl:if test="$includeDisplayName">
               <xsl:text>&#8197;</xsl:text>
               <xsl:value-of select="$nutrient/@displayName" />
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>XXX</xsl:text>
            <xsl:text>&#xA0;</xsl:text>
            <xsl:value-of select="$unit" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="badges">
      <xsl:param name="product" />

      <xsl:for-each select="$product/da:annotations/da:annotation">
         <xsl:choose>
            <xsl:when test=".//@name = 'isNew' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="./ancestor::*/da:references/da:reference[@id='new_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isNewOutline' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="./ancestor::*/da:references/da:reference[@id='new_food_topper_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isReturning' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='back_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isReturningOutline' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='back_outline_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isFreshlyBaked' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='freshly_baked_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isVegetarian' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">Bug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='vegetarian_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isTheyreReturning' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='theyre_back_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isTheyreReturningSolid' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='theyre_back_solid_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test=".//@name = 'isNewRibbonSolid' and .//text() = 'True'">
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='new_ribbon_solid_bug']/text()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains(.//@name,'is') and .//text() = 'True'">
               <xsl:variable name="selfServeBadge" select=".//@name" />
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" select="./ancestor::*/da:references/da:reference[@id=$selfServeBadge]/text()" />
               </xsl:call-template>
            </xsl:when>
            <!-- <xsl:otherwise>
               <xsl:call-template name="linkedAsset">
                  <xsl:with-param name="elementName">NewBug</xsl:with-param>
                  <xsl:with-param name="reference" />
               </xsl:call-template>
            </xsl:otherwise> -->
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="linkedAsset">
      <xsl:param name="elementName" />
      <xsl:param name="reference" />
      <xsl:element name="{$elementName}">
         <xsl:attribute name="href">
            <xsl:value-of select="$reference" />
         </xsl:attribute>
      </xsl:element>
   </xsl:template>

   <!-- template to display caffeine info for Energy drinks -->
   <xsl:template name="caffeineData">
      <xsl:param name="caffeine" />

      <xsl:text>&#x2028;Caffeine&#8197;</xsl:text>
      <!-- dynamically add caffeeine value -->
      <xsl:choose>
         <xsl:when test="$caffeine/@value">
            <xsl:value-of select="$caffeine/@value" />
         </xsl:when>
         <!-- insert fallback value in case caffeine value is missing -->
         <xsl:otherwise>
            <xsl:text>XXX</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#xA0;</xsl:text>
      <xsl:value-of select="$caffeine/@unit" />
   </xsl:template>

</xsl:stylesheet>
