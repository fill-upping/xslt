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
   <xsl:param name="hasPricing" select="true()" />
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
   <xsl:param name="kitType" select="//da:transformation/da:context/da:variables/da:variable[@name='kitType']/text()" />

   <xsl:template match="/">
      <xsl:variable name="footerSection" select="//da:transformation/da:templateData/da:sections/da:section[@name='Footer']" />
      <xsl:variable name="backgroundImage" select="//da:transformation/da:templateData/da:sections/da:section[@name='BackgroundImage']" />

      <xsl:element name="Root">

         <xsl:call-template name="header">
            <xsl:with-param name="allocation">
               <xsl:value-of select="$market" />
               <xsl:text>&#xa0;</xsl:text>
               <xsl:value-of select="$storeType" />
               <xsl:text>&#xa0;&#x2011;&#xa0;</xsl:text>
               <xsl:value-of select="$versionName" />
               <!-- Print kitType and truncate if > 11 characters -->
               <xsl:if test="$kitType">
                  <xsl:text>-</xsl:text>
                  <xsl:choose>
                  <xsl:when test="string-length($kitType) &gt; 11">
                     <xsl:value-of select="substring($kitType, 1, 11)" />
                     <xsl:text>...</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$kitType" />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="menucode" select="$menuCode" />
         </xsl:call-template>

         <xsl:call-template name="documentStructure">
            <xsl:with-param name="section" select="//da:transformation/da:templateData/da:sections/da:section[@name='Hero']" />
            <xsl:with-param name="listings" select="//da:transformation/da:templateData/da:sections/da:section[@name='LineListings']" />
         </xsl:call-template>

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

      <xsl:param name="altHeadline" select="translate($section/da:fields/da:field[@name='Alternate Headline Color']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'yes'"/>
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

      <xsl:for-each select="$section/da:products/da:product[position() &lt;= $maxNumberOfProductImages]">
         <xsl:call-template name="productImage">
            <xsl:with-param name="product" select="." />
         </xsl:call-template>
      </xsl:for-each>

      <xsl:element name="ProductBox">
         <xsl:element name="Table">
            <xsl:for-each select="$section/da:products/da:product[position() &lt;= $maxNumberOfProductImages]">
               <xsl:element name="Cell">
                  <xsl:call-template name="productInfo">
                     <xsl:with-param name="product" select="." />
                  </xsl:call-template>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
         <xsl:text>&#x2029;</xsl:text>

         <xsl:if test="$listings">
            <xsl:element name="ELLHeadline">
               <xsl:value-of select="$listings/da:fields/da:field[@name='Headline']/text()" />
            </xsl:element>
            <xsl:text>&#x2029;</xsl:text>
            <xsl:if test="$listings/da:fields/da:field[@name='Descriptor']/text()">
               <xsl:element name="DescriptorLockup">
                  <xsl:value-of select="$listings/da:fields/da:field[@name='Descriptor']/text()" />
               </xsl:element>
               <xsl:text>&#x2029;</xsl:text>
            </xsl:if>
            <!-- allow for max 4 line listings -->
            <xsl:for-each select="$listings/da:products/da:product[position() &lt; $maxNumberOfLineListings]">
               <xsl:call-template name="linelisting">
                  <xsl:with-param name="product" select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:if>
         <xsl:if test="$listings/da:fields/da:field[@name='Subheading1']/text()">
            <xsl:element name="RefreshersLine">
               <xsl:value-of select="$listings/da:fields/da:field[@name='Subheading1']/text()" />
            </xsl:element>
         </xsl:if>

      </xsl:element>


   </xsl:template>

   <xsl:template name="productImage">

      <xsl:param name="product" />
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
   </xsl:template>

   <xsl:template name="productInfo">
      <xsl:param name="product" />

      <!-- populate Product element with Menu Content Builder data -->
      <xsl:element name="ProductName">
         <xsl:value-of select="$product/da:name" />
      </xsl:element>
      <xsl:if test="$product/da:descriptor/text()">
         <xsl:element name="MarkDescriptor">
            <xsl:value-of select="translate($product/da:descriptor/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
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
      <xsl:element name="{$priceLineElementName}">
         <xsl:call-template name="priceLineText">
            <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving']" />
         </xsl:call-template>
      </xsl:element>

   </xsl:template>

   <xsl:template name="priceLineText">
      <xsl:param name="servingSize" />

      <xsl:choose>
         <xsl:when test="$servingSize/@code = 'Serving'">
            <!-- <xsl:call-template name="formattedNutrition">
               <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Protein']" />
               <xsl:with-param name="includeDisplayName" select="true()" />
            </xsl:call-template>
            <xsl:text>&#x2002;|&#x2002;</xsl:text> -->
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$servingSize/@code" />
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$hasPricing">
         <xsl:text>&#x2002;</xsl:text>
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
      <xsl:text>&#x2002;|&#x2002;</xsl:text>
      <xsl:call-template name="formattedNutrition">
         <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
         <xsl:with-param name="includeDisplayName" select="false()" />
      </xsl:call-template>
   </xsl:template>

   <xsl:template name="linelisting">
      <xsl:param name="product" />
      <xsl:variable name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande']" />

      <xsl:element name="ELL">
         <xsl:value-of select="$product/da:name" />
         <xsl:if test="$product/da:descriptor/text()">
            <xsl:text>&#xA0;</xsl:text>
            <xsl:value-of select="translate($product/da:descriptor/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
         </xsl:if>
         <xsl:text>&#x9;</xsl:text>
      </xsl:element>
      <xsl:element name="{$priceLineElementNameELL}">
         <xsl:value-of select="$servingSize/@code" />
         <xsl:if test="$hasPricing">
            <xsl:text>&#x9;</xsl:text>
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
         <xsl:text>&#x9;|&#x9;</xsl:text>
         <xsl:call-template name="formattedNutrition">
            <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
            <xsl:with-param name="includeDisplayName" select="false()" />
         </xsl:call-template>
      </xsl:element>
      <xsl:if test="position()!=last()">
         <xsl:text>&#x2029;</xsl:text>
      </xsl:if>

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
               <xsl:text>&#x2002;</xsl:text>
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

</xsl:stylesheet>
