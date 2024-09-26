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
      <xsl:variable name="backgroundImage" select="//da:transformation/da:templateData/da:sections/da:section[@name='BackgroundImage']" />

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
            <xsl:with-param name="topLineListing" select="//da:transformation/da:templateData/da:sections/da:section[@name='TopLineListings']" />
            <xsl:with-param name="bottomLeftLineListing" select="//da:transformation/da:templateData/da:sections/da:section[@name='BottomLeftLineListings']" />
            <xsl:with-param name="bottomRightLineListing" select="//da:transformation/da:templateData/da:sections/da:section[@name='BottomRightLineListings']" />
            <xsl:with-param name="footer" select="//da:transformation/da:templateData/da:sections/da:section[@name='Footer']"/>
         </xsl:call-template>

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
      <xsl:param name="header" />
      <xsl:param name="topLineListing" />
      <xsl:param name="bottomLeftLineListing" />
      <xsl:param name="bottomRightLineListing" />
      <xsl:param name="footer" />

      <xsl:element name="HeadlineLeft">
         <xsl:value-of select="$topLineListing/da:fields/da:field[@name='Headline']" />
      </xsl:element>

      <xsl:for-each select="$topLineListing/da:products/da:product">
         <xsl:call-template name="topLineListing">
            <xsl:with-param name="product" select="." />
         </xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>

      <xsl:element name="HeaderSection">
         <xsl:value-of select="$bottomLeftLineListing/da:fields/da:field[@name='Headline']" />
      </xsl:element>

      <xsl:for-each select="$bottomLeftLineListing/da:products/da:product">
         <xsl:call-template name="bottomLeftLineListing">
            <xsl:with-param name="product" select="." />
         </xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>

      <xsl:element name="HeaderSection">
         <xsl:value-of select="$bottomRightLineListing/da:fields/da:field[@name='Headline']" />
      </xsl:element>

      <xsl:for-each select="$bottomRightLineListing/da:products/da:product">
         <xsl:call-template name="bottomRightLineListing">
            <xsl:with-param name="product" select="." />
         </xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>

      <xsl:element name="Legal">
         <xsl:value-of select="$footer/da:fields/da:field[@name='Regulatory']/text()" />
      </xsl:element>
      <xsl:element name="Copyright">
         <xsl:value-of select="$footer/da:fields/da:field[@name='Copyright']/text()" />
      </xsl:element>
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
   <xsl:template name="topLineListing">
      <xsl:param name="product" />
      <xsl:param name="productId" />

      <xsl:call-template name="productHero">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="productId" select="$product/@id" />
         <xsl:with-param name="includeNewBug" select="true()" />
      </xsl:call-template>

      <xsl:call-template name="productBox">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="includeServingSizeHeader" select="false()" />
         <xsl:with-param name="includePriceLine" select="$market = 'CA'" />
         <xsl:with-param name="includeProtein" select="$market = 'CA'" />
      </xsl:call-template>

   </xsl:template>

   <xsl:template name="bottomLeftLineListing">
      <xsl:param name="product" />
      <xsl:param name="productId" />

      <xsl:call-template name="productHero">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="productId" select="$product/@id" />
         <xsl:with-param name="includeNewBug" select="true()" />
      </xsl:call-template>

      <xsl:call-template name="productBox">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="includeServingSizeHeader" select="$market = 'CA'" />
         <xsl:with-param name="includePriceLine" select="$market = 'CA'" />
         <xsl:with-param name="includeProtein" select="false()" />
      </xsl:call-template>

   </xsl:template>

   <xsl:template name="bottomRightLineListing">
      <xsl:param name="product" />
      <xsl:param name="productId" />

      <xsl:call-template name="productHero">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="productId" select="$product/@id" />
         <xsl:with-param name="includeNewBug" select="true()" />
      </xsl:call-template>

      <xsl:call-template name="productBox">
         <xsl:with-param name="product" select="$product" />
         <xsl:with-param name="includeServingSizeHeader" select="$market = 'CA'" />
         <xsl:with-param name="includePriceLine" select="$market = 'CA'" />
         <xsl:with-param name="includeProtein" select="false()" />
      </xsl:call-template>

   </xsl:template>

   <xsl:template name="productBox">
      <xsl:param name="product" />
      <xsl:param name="includeServingSizeHeader" />
      <xsl:param name="includeProtein" />
      <xsl:param name="includePriceLine" />

      <xsl:element name="ProductBox">
         <xsl:element name="ProductName">
            <xsl:value-of select="$product/da:name" />
         </xsl:element>

         <!-- Use Descriptor 1 and Descriptor 2 to set calorie range if both values are numbers -->
         <xsl:variable name="showCalRange" select="number(da:descriptor/text()) = da:descriptor/text()  and number(da:descriptor2/text()) = da:descriptor2/text()" />
         <!-- Use as mark descriptor if text value -->
         <xsl:if test="string(number($product/da:descriptor/text())) = 'NaN' and $product/da:descriptor/text()">
            <xsl:element name="MarkDescriptor">
               <xsl:value-of select="$product/da:descriptor/text()" />
            </xsl:element>
         </xsl:if>
         <xsl:if test="string(number(da:altDescriptor/text())) = 'NaN' and da:altDescriptor/text()">
            <xsl:text>&#x2029;</xsl:text>
            <xsl:element name="ProductDescriptor">
               <xsl:value-of select="da:altDescriptor/text()" />
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
         <xsl:if test="$includePriceLine">
            <xsl:element name="PriceLine">
               <xsl:if test="$includeProtein">
                  <xsl:call-template name="formattedNutrition">
                     <xsl:with-param name="nutrient" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']/da:nutrition[@displayName='Protein']" />
                     <xsl:with-param name="includeDisplayName" select="true()" />
                  </xsl:call-template>
                  <xsl:text>&#x2002;|&#x2002;</xsl:text>
               </xsl:if>
               <xsl:call-template name="priceLineText">
                  <xsl:with-param name="showCalRange" select="$showCalRange" />
                  <xsl:with-param name="minCalRange" select="$product/da:descriptor/text()" />
                  <xsl:with-param name="maxCalRange" select="$product/da:descriptor2/text()" />
                  <xsl:with-param name="servingSize" select="$product/da:sellableItems/da:sellableItem/da:servingSize[@code='Grande' or @code='Serving' or @code='Whole']" />
                  <xsl:with-param name="includeServingSizeHeader" select="$includeServingSizeHeader" />
               </xsl:call-template>
            </xsl:element>
         </xsl:if>
         <!-- include protein nutritional information if required -->
      </xsl:element>
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

   <xsl:template name="priceLineText">
      <xsl:param name="servingSize" />
      <xsl:param name="includeServingSizeHeader" />
      <xsl:param name="showCalRange" />
      <xsl:param name="minCalRange" />
      <xsl:param name="maxCalRange" />


      <xsl:if test="$includeServingSizeHeader">
         <xsl:value-of select="$servingSize/@code" />
         <xsl:text>&#x2002;</xsl:text>
      </xsl:if>

      <!-- <xsl:if test="$hasPricing">
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
      </xsl:if> -->
      <!-- <xsl:text>&#x2002;</xsl:text> -->
      <xsl:call-template name="formattedNutrition">
         <xsl:with-param name="showCalRange" select="$showCalRange" />
         <xsl:with-param name="minCalRange" select="$minCalRange" />
         <xsl:with-param name="maxCalRange" select="$maxCalRange" />
         <xsl:with-param name="nutrient" select="$servingSize/da:nutrition[@displayName='Calories']" />
         <xsl:with-param name="includeDisplayName" select="false()" />
         <xsl:with-param name="placeholderName">Cal</xsl:with-param>
      </xsl:call-template>
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
      <xsl:param name="nutrient" />
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
                  <xsl:value-of select="$minCalRange" />
                  <xsl:text>&#x2013;</xsl:text>
                  <xsl:value-of select="$maxCalRange" />
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

</xsl:stylesheet>
