<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
   xmlns=""
   xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
   xmlns:da="https://ns.starbucks.com/creative/document-automation/1.0"
   xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-Instance"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform https://www.w3.org/2007/schema-for-xslt20.xsd">

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
   <xsl:param name="menuCode" select="//da:transformation/@id" />
   <xsl:param name="storeType" select="//da:transformation/da:context/da:variables/da:variable[@name='storeType']/text()" />
   <xsl:param name="versionName" select="//da:transformation/da:context/da:variables/da:variable[@name='versionName']/text()" />
   <xsl:param name="kitType" select="//da:transformation/da:context/da:variables/da:variable[@name='kitType']/text()" />

   <xsl:template match="/">
      <xsl:element name="Root">
         <xsl:call-template name="header">
            <xsl:with-param name="allocation">
               <xsl:value-of select="$market" />
               <xsl:text>-</xsl:text>
               <xsl:value-of select="$storeType" />
               <xsl:text>-</xsl:text>
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
            <xsl:with-param name="header" select="//da:transformation/da:templateData/da:sections/da:section[@name='Header']"/>
            <xsl:with-param name="insetListing" select="//da:transformation/da:templateData/da:sections/da:section[@name='PromoInset']"/>
            <xsl:with-param name="midHeader" select="//da:transformation/da:templateData/da:sections/da:section[@name='MidHeader']"/>
            <xsl:with-param name="midListing" select="//da:transformation/da:templateData/da:sections/da:section[@name='MidProducts']"/>
            <xsl:with-param name="lineListingCol1" select="//da:transformation/da:templateData/da:sections/da:section[@name='LineListingCol1']" />
            <xsl:with-param name="lineListingCol2" select="//da:transformation/da:templateData/da:sections/da:section[@name='LineListingCol2']" />
            <xsl:with-param name="lineListingCol3" select="//da:transformation/da:templateData/da:sections/da:section[@name='LineListingCol3']" />
            <xsl:with-param name="footer" select="//da:transformation/da:templateData/da:sections/da:section[@name='Footer']"/>
            <xsl:with-param name="backgroundImage" select="//da:transformation/da:templateData/da:sections/da:section[@name='BackgroundImage']" />
         </xsl:call-template>
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
      <xsl:param name="insetListing" />
      <xsl:param name="header" />
      <xsl:param name="midListing" />
      <xsl:param name="backgroundImage" />
      <xsl:param name="lineListingCol1" />
      <xsl:param name="lineListingCol2" />
      <xsl:param name="lineListingCol3" />

      <xsl:param name="excludeProteinCol1" select="translate($lineListingCol1/da:fields/da:field[@name='Exclude Protein']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>

      <xsl:param name="excludeProteinCol2" select="translate($lineListingCol2/da:fields/da:field[@name='Exclude Protein']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>

      <xsl:param name="excludeProteinCol3" select="translate($lineListingCol3/da:fields/da:field[@name='Exclude Protein']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'"/>

      <xsl:param name="altHeadline" select="translate($header/da:fields/da:field[@name='Alternate Headline Style']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'yes'"/>

      <xsl:param name="midHeader" />
      <xsl:param name="footer" />


      <xsl:element name="HeadlineLeft">
         <xsl:value-of select="$midHeader/da:fields/da:field[@name='Headline']/text()"/>
      </xsl:element>

      <xsl:call-template name="lowerProductItem">
         <xsl:with-param name="lineListingCol1" select="$lineListingCol1" />
         <xsl:with-param name="product" select="$lineListingCol1/da:products/da:product" />
         <xsl:with-param name="includeServingSizeHeader" select="false()" />
         <xsl:with-param name="includeProtein" select="$market = 'CA' and not($excludeProteinCol1)" />
      </xsl:call-template>

      <xsl:call-template name="lowerProductItem">
         <xsl:with-param name="lineListingCol2" select="$lineListingCol2" />
         <xsl:with-param name="product" select="$lineListingCol2/da:products/da:product" />
         <xsl:with-param name="includeServingSizeHeader" select="false()" />
         <xsl:with-param name="includeProtein" select="$market = 'CA' and not($excludeProteinCol2)" />
      </xsl:call-template>

      <xsl:call-template name="lowerProductItem">
         <xsl:with-param name="lineListingCol3" select="$lineListingCol3" />
         <xsl:with-param name="product" select="$lineListingCol3/da:products/da:product" />
         <xsl:with-param name="includeServingSizeHeader" select="false()" />
         <xsl:with-param name="includeProtein" select="$market = 'CA' and not($excludeProteinCol3)" />
      </xsl:call-template>

      <xsl:for-each select="$midListing/da:products/da:product">
         <xsl:call-template name="productItem">
            <xsl:with-param name="product" select="." />
            <xsl:with-param name="includeNewBug" select="true()" />
            <xsl:with-param name="includeServingSizeHeader" select="true()" />
            <xsl:with-param name="includeProtein" select="false()" />
         </xsl:call-template>
      </xsl:for-each>

      <xsl:variable name="HeadlineTag">
         <xsl:choose>
            <xsl:when test="$altHeadline">
               <xsl:text>HeadlineCenterWhite</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>HeadlineCenter</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="SubHeadlineTag">
         <xsl:choose>
            <xsl:when test="$altHeadline">
               <xsl:text>SubheadWhite</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Subhead</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:element name="HeadlineCenter">
         <xsl:element name="{$HeadlineTag}">
            <xsl:value-of select="$header/da:fields/da:field[@name='Headline']/text()"/>
            <xsl:if test="$header/da:fields/da:field[@name='Subheading1']/text()">
               <xsl:text>&#x2029;</xsl:text>
               <xsl:element name="{$SubHeadlineTag}">
                  <xsl:value-of select="$header/da:fields/da:field[@name='Subheading1']/text()" />
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:element>

      <xsl:for-each select="$insetListing/da:products/da:product">
         <xsl:call-template name="productItem">
            <xsl:with-param name="product" select="." />
            <xsl:with-param name="groupedPosition" select="number(substring-before(./da:altDescriptor/text(),'/'))" />
            <xsl:with-param name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />
            <xsl:with-param name="includeNewBug" select="true()" />
            <xsl:with-param name="includeServingSizeHeader" select="true()" />
            <xsl:with-param name="includeDescriptorBreak" select="translate(../../da:fields/da:field[@name='Descriptor Linebreak']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='yes'" />
            <!-- <xsl:with-param name="includeProtein" select="$market = 'CA'" /> -->

            <xsl:with-param name="includeProtein" select="false()" />
         </xsl:call-template>
      </xsl:for-each>

      <xsl:text>&#xA;</xsl:text>
      <xsl:element name="Legal">
         <xsl:value-of select="$footer/da:fields/da:field[@name='Regulatory']/text()" />
      </xsl:element>
      <xsl:element name="Copyright">
         <xsl:value-of select="$footer/da:fields/da:field[@name='Copyright']/text()" />
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
      <!-- Barcode image placement -->
      <xsl:if test="//da:transformation/da:templateData/da:references/da:reference[@id='barcode_block']/text()">
         <xsl:element name="barcode_block">
            <xsl:attribute name="href">
               <xsl:value-of select="//da:transformation/da:templateData/da:references/da:reference[@id='barcode_block']/text()" />
            </xsl:attribute>
         </xsl:element>
      </xsl:if>
   </xsl:template>

   <!-- product elements of the document structure -->
   <xsl:template name="productItem">
      <xsl:param name="product" />
      <xsl:param name="groupedPosition" />
      <xsl:param name="groupNumber" />
      <xsl:param name="productId" />
      <xsl:param name="includeNewBug" />
      <xsl:param name="includeServingSizeHeader" />
      <xsl:param name="includeProtein" />
      <xsl:param name="includeDescriptorBreak" />


      <xsl:if test="not($groupedPosition &gt; 1)">

         <xsl:call-template name="productHero">
            <xsl:with-param name="product" select="$product" />
            <xsl:with-param name="productId" select="$product/@referenceId" />
            <xsl:with-param name="includeNewBug" select="true()" />
         </xsl:call-template>

         <xsl:variable name="headlineElementName">
            <xsl:choose>
               <xsl:when test="$market = 'US'">PriceLine</xsl:when>
               <xsl:otherwise>PriceLineCAN</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:element name="ProductBox">
            <xsl:element name="ProductName">
               <xsl:value-of select="$product/da:name" />
            </xsl:element>
            <!-- Use Descriptor 1 and Descriptor 2 to set calorie range if both values are numbers -->
            <xsl:variable name="showCalRange" select="(number(da:descriptor/text()) = da:descriptor/text() and number(da:altDescriptor/text()) = da:altDescriptor/text()) or number($groupedPosition)" />
            <xsl:if test="string(number(da:descriptor/text())) = 'NaN' and da:descriptor/text() and not(da:altDescriptor/text())">
               <xsl:element name="MarkDescriptor">
                  <xsl:value-of select="da:descriptor/text()" />
               </xsl:element>
            </xsl:if>
            <xsl:if test="string(number($product/da:altDescriptor/text())) = 'NaN' and $product/da:altDescriptor/text()">
               <xsl:text>&#x2029;</xsl:text>
               <xsl:element name="ProductDescriptor">
                  <xsl:value-of select="$product/da:altDescriptor/text()" />
               </xsl:element>
            </xsl:if>
            <xsl:if test="$product/da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()">
               <xsl:text>&#x2029;</xsl:text>
               <xsl:element name="Regulatory">
                  <xsl:value-of select="$product/da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()"></xsl:value-of>
               </xsl:element>
            </xsl:if>
            <xsl:text>&#x2029;</xsl:text>
            <!-- populate PriceLine element with details from serving size Grande (for beverages) or Serving (for food) -->
            <xsl:element name="{$headlineElementName}">
               <xsl:if test="$showCalRange and number($groupedPosition)">
                  <xsl:text>1 FOR&#x20;</xsl:text>
               </xsl:if>
               <!-- populate PriceLine element with details from serving size Grande (for beverages) or Serving (for food) -->
               <!-- adding hard-coded fix for Venti-only beverages, like Energy drinks, to display correct pricing and nutrition data -->
               <xsl:choose>
                  <xsl:when test="$product[@id='25245' or @id='25246'] or contains($product/da:name,'Melon Burst') or contains($product/da:name,'Tropical Citrus')">
                     <xsl:call-template name="priceLineText">
                        <xsl:with-param name="isInset" select="true()" />
                        <xsl:with-param name="product" select="$product" />
                        <xsl:with-param name="groupedPosition" select="$groupedPosition" />
                        <xsl:with-param name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />
                        <xsl:with-param name="showCalRange" select="$showCalRange" />
                        <xsl:with-param name="minCalRange" select="da:descriptor/text()" />
                        <xsl:with-param name="maxCalRange" select="da:altDescriptor/text()" />
                        <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Venti']" />
                        <xsl:with-param name="includeServingSizeHeader" select="$includeServingSizeHeader" />
                     </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:call-template name="priceLineText">
                        <xsl:with-param name="isInset" select="true()" />
                        <xsl:with-param name="product" select="$product" />
                        <xsl:with-param name="groupedPosition" select="$groupedPosition" />
                        <xsl:with-param name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />
                        <xsl:with-param name="showCalRange" select="$showCalRange" />
                        <xsl:with-param name="minCalRange" select="da:descriptor/text()" />
                        <xsl:with-param name="maxCalRange" select="da:altDescriptor/text()" />
                        <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']" />
                        <xsl:with-param name="includeServingSizeHeader" select="$includeServingSizeHeader" />
                     </xsl:call-template>
                  </xsl:otherwise>
               </xsl:choose>
               <!-- include protein nutritional information if required -->
               <xsl:if test="$includeProtein">
                  <xsl:text>&#x2029;</xsl:text>
                  <xsl:call-template name="formattedNutrition">
                     <xsl:with-param name="nutrient" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']/da:nutrition[@displayName='Protein']" />
                     <xsl:with-param name="includeDisplayName" select="true()" />
                  </xsl:call-template>
               </xsl:if>
            </xsl:element>

         </xsl:element>
      </xsl:if>

   </xsl:template>

   <xsl:template name="productHero">
      <xsl:param name="product" />
      <xsl:param name="includeNewBug" />
      <xsl:param name="productId" />

      <!-- if Menu Content Builder indicates to show a product image, create a ProductImg element for the linked asset -->
      <xsl:if test="translate($product/da:annotations/da:annotation[@name='imageRequired']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
         <xsl:call-template name="linkedAsset">
            <xsl:with-param name="elementName">ProductImg</xsl:with-param>
            <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id=$productId]/text()" />
         </xsl:call-template>

         <xsl:if test="$includeNewBug">
            <xsl:call-template name="badges">
               <xsl:with-param name="product" select="$product" />
            </xsl:call-template>
            <!-- if Menu Content Builder indicates to show a new bug, create a NewBug element for the linked asset -->
            <!-- <xsl:choose>
               <xsl:when test="translate($product/da:annotations/da:annotation[@name='isNew']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
                  <xsl:call-template name="linkedAsset">
                     <xsl:with-param name="elementName">NewBug</xsl:with-param>
                     <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='new_bug']/text()" />
                  </xsl:call-template>
               </xsl:when> -->
               <!-- if Menu Content Builder indicates to show a it's back bug, create a BackBug element for the linked asset -->
               <!-- element is named NewBug, but loaded with back_bug.esp file -->
               <!-- <xsl:when test="translate($product/da:annotations/da:annotation[@name='isReturning']/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='true'">
                  <xsl:call-template name="linkedAsset">
                     <xsl:with-param name="elementName">NewBug</xsl:with-param>
                     <xsl:with-param name="reference" select="$product/ancestor::*/da:references/da:reference[@id='back_bug']/text()" />
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
         </xsl:if>
      </xsl:if>
   </xsl:template>

   <!-- LineListing Box -->
   <xsl:template name="lowerProductItem">
      <xsl:param name="product" />
      <xsl:param name="includeServingSizeHeader" />
      <xsl:param name="includeProtein" />
      <xsl:param name="includeNewBug" />
      <xsl:param name="productHeader" />
      <xsl:param name="lineListing" />

      <xsl:call-template name="productHero">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="productId" select="$product/@referenceId" />
         <xsl:with-param name="includeNewBug" select="true()" />
      </xsl:call-template>

      <xsl:variable name="headlineElementName">
         <xsl:choose>
            <xsl:when test="$market = 'US'">PriceLine</xsl:when>
            <xsl:otherwise>PriceLineCAN</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:element name="ProductBox">
         <xsl:for-each select="$product">
            <xsl:variable name="groupedPosition" select="number(substring-before(./da:altDescriptor/text(),'/'))" />
            <xsl:variable name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />

            <xsl:if test="not($groupedPosition &gt; 1)">
               <xsl:element name="ProductName">
                  <xsl:value-of select="da:name" />
               </xsl:element>
               <!-- Use Descriptor 1 and Descriptor 2 to set calorie range if both values are numbers -->
               <xsl:variable name="showCalRange" select="(number(da:descriptor/text()) = da:descriptor/text() and number(da:altDescriptor/text()) = da:altDescriptor/text()) or number($groupedPosition)" />
               <!-- Use as mark descriptor if text value -->
               <xsl:if test="string(number(da:descriptor/text())) = 'NaN' and da:descriptor/text() and not(da:altDescriptor/text())">
                  <xsl:element name="MarkDescriptor">
                     <xsl:value-of select="translate(./da:descriptor/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
                  </xsl:element>
               </xsl:if>
               <xsl:if test="da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()">
                  <xsl:text>&#x2029;</xsl:text>
                  <xsl:element name="Regulatory">
                     <xsl:value-of select="$product/da:regulatoryStatements/da:regulatoryStatement[@name='allergen']/text()"></xsl:value-of>
                  </xsl:element>
               </xsl:if>
               <!-- populate PriceLine element with details from serving size Grande (for beverages) or Serving (for food) -->
               <xsl:choose>
                  <xsl:when test="$includeProtein">
                     <xsl:text>&#x2029;</xsl:text>
                     <xsl:element name="{$headlineElementName}">
                        <xsl:if test="$showCalRange and number($groupedPosition)">
                           <xsl:text>1 FOR&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:call-template name="priceLineText">
                           <xsl:with-param name="showCalRange" select="$showCalRange" />
                           <xsl:with-param name="minCalRange" select="da:descriptor/text()" />
                           <xsl:with-param name="maxCalRange" select="da:altDescriptor/text()" />
                           <xsl:with-param name="product" select="$product" />
                           <xsl:with-param name="groupedPosition" select="$groupedPosition" />
                           <xsl:with-param name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />
                           <xsl:with-param name="servingSize" select="da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']" />
                           <xsl:with-param name="includeServingSizeHeader" select="$includeServingSizeHeader" />
                        </xsl:call-template>
                        <xsl:text>&#x2002;|&#x2002;</xsl:text>
                        <xsl:call-template name="formattedNutrition">
                           <xsl:with-param name="nutrient" select="da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']/da:nutrition[@displayName='Protein']" />
                           <xsl:with-param name="includeDisplayName" select="true()" />
                        </xsl:call-template>
                     </xsl:element>
                     <xsl:text>&#x2029;</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>&#x2029;</xsl:text>
                     <xsl:element name="{$headlineElementName}">
                        <xsl:if test="$showCalRange and number($groupedPosition)">
                           <xsl:text>1 FOR&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:call-template name="priceLineText">
                           <xsl:with-param name="showCalRange" select="$showCalRange" />
                           <xsl:with-param name="minCalRange" select="da:descriptor/text()" />
                           <xsl:with-param name="maxCalRange" select="da:altDescriptor/text()" />
                           <xsl:with-param name="product" select="$product" />
                           <xsl:with-param name="groupedPosition" select="$groupedPosition" />
                           <xsl:with-param name="groupNumber" select="number(substring-after(./da:altDescriptor/text(),'/'))" />
                           <xsl:with-param name="servingSize" select="da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']" />
                           <xsl:with-param name="includeServingSizeHeader" select="$includeServingSizeHeader" />
                        </xsl:call-template>
                     </xsl:element>
                     <xsl:text>&#x2029;</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:if>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>

   <xsl:template name="priceLineText">
      <xsl:param name="isInset" />
      <xsl:param name="product" />
      <xsl:param name="servingSize" />
      <xsl:param name="showCalRange" />
      <xsl:param name="minCalRange" />
      <xsl:param name="maxCalRange" />
      <xsl:param name="groupedPosition" />
      <xsl:param name="groupNumber" />
      <xsl:param name="includeServingSizeHeader" />

      <xsl:if test="$includeServingSizeHeader and ($servingSize/@code = 'Grande' or $servingSize/@code = 'Venti')">
         <xsl:value-of select="$servingSize/@code" />
         <xsl:text>&#x2002;</xsl:text>
      </xsl:if>

      <xsl:if test="$hasPricing">
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
      <xsl:choose>
         <!-- replace pipe with linebreak if merged cakepops -->
         <xsl:when test="$showCalRange and number($groupedPosition) and $isInset">
            <xsl:text>&#x2028;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#x2002;|&#x2002;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="formattedNutrition">
         <xsl:with-param name="showCalRange" select="$showCalRange" />
         <xsl:with-param name="minCalRange" select="$minCalRange" />
         <xsl:with-param name="maxCalRange" select="$maxCalRange" />
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="groupedPosition" select="$groupedPosition" />
         <xsl:with-param name="groupNumber" select="$groupNumber" />
         <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
         <xsl:with-param name="includeDisplayName" select="false()" />
         <xsl:with-param name="placeholderName">Cal</xsl:with-param>
      </xsl:call-template>

      <!-- test hard-coded product menuID for Energy-specific drinks to show caffeine data -->
      <!-- 25245/6 is MenuProdID -->
      <xsl:if test="$servingSize/parent::da:sellableItem/parent::da:sellableItems/parent::da:product[@id='25245' or @id='25246']">
         <xsl:call-template name="caffeineData">
            <xsl:with-param name="caffeine" select="$servingSize/da:nutrition[@displayName='Caffeine']" />
         </xsl:call-template>
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
      <xsl:param name="showCalRange" />
      <xsl:param name="minCalRange" />
      <xsl:param name="maxCalRange" />
      <xsl:param name="groupedPosition" />
      <xsl:param name="groupNumber" />
      <xsl:param name="nutrient" />
      <xsl:param name="product" />
      <xsl:param name="includeDisplayName" />
      <xsl:variable name="unit">
         <xsl:choose>
            <xsl:when test="$nutrient or $showCalRange">
               <xsl:choose>
                  <xsl:when test="(translate($nutrient/@unit, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='cal' and $market='CA') or (translate($nutrient/@unit, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='' and $market='CA')">Cals</xsl:when>
                  <xsl:when test="(translate($nutrient/@unit, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='cal' and $market='US') or (translate($nutrient/@unit, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='' and $market='US')">Cal</xsl:when>
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
            <xsl:choose>
               <xsl:when test="$showCalRange">
                  <xsl:choose>
                     <xsl:when test="$minCalRange = $maxCalRange and $groupedPosition != 1">
                        <xsl:value-of select="$minCalRange" />
                     </xsl:when>
                     <xsl:when test="$groupedPosition = 1">
                        <xsl:call-template name="groupedProductInfo">
                           <xsl:with-param name="servingSize" select="//da:transformation/da:templateData/da:sections/da:section/da:products/da:product/da:altDescriptor[substring-after(text(), '/') = $groupNumber]/../da:sellableItems/da:sellableItem/da:servingSize[@code ='Whole' or 'Serving' or 'Grande' or 'Venti']" />
                           <xsl:with-param name="groupNumber" select="substring-after(./da:altDescriptor/text(), '/')" />
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$minCalRange" />
                        <xsl:text>&#x2013;</xsl:text>
                        <xsl:value-of select="$maxCalRange" />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$nutrient/@value" />
               </xsl:otherwise>
            </xsl:choose>
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

   <!-- Grabs and sorts products using the grouping convention "X/Y" in Descriptor2 field -->
   <xsl:template name="groupedProductInfo">
      <xsl:param name="groupNumber" />
      <xsl:param name="servingSize" />

      <xsl:variable name="groupedServingMin">
         <xsl:for-each select="$servingSize/da:nutrition[@displayName='Calories']/@valueMin | $servingSize/da:nutrition[@displayName='Calories']/@valueMax">
            <xsl:sort select="." data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
               <xsl:value-of select="." />
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="groupedServingMax">
         <xsl:for-each select="$servingSize/da:nutrition[@displayName='Calories']/@valueMin | $servingSize/da:nutrition[@displayName='Calories']/@valueMax">
            <xsl:sort select="." data-type="number" order="ascending"/>
            <xsl:if test="position() = last()">
               <xsl:value-of select="." />
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <!-- Don't show range if min == max cals -->
      <xsl:variable name="servingSizeRange">
         <xsl:if test="$groupedServingMin = $groupedServingMax">
            <xsl:value-of select="$groupedServingMin" />
         </xsl:if>
         <xsl:if test="$groupedServingMin &lt; $groupedServingMax">
            <xsl:value-of select="concat($groupedServingMin,'&#x2013;',$groupedServingMax)" />
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="$servingSizeRange" />

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

   <!-- Linked asset elements (with element name as parameter) -->
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

      <xsl:text>&#x2028;Caffeine&#x2002;</xsl:text>
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
