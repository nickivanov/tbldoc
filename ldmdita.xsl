<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 

ldmdita.xsl

This file is a part of tbldoc v0.2

This XSL stylesheet generates a DITA topic that lists entities and attributes 
from an InfoSphere Data Architect logical model file (LDM). 

Copyright (c) 2015 Nick Ivanov / nick@datori.org
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://www.omg.org/XMI"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:LogicalDataModel="http:///com/ibm/db/models/logical/logical.ecore"
	exclude-result-prefixes="xmi xsi LogicalDataModel"
	>
<xsl:output method="topic" doctype-public="-//OASIS//DTD DITA Task//EN" doctype-system="../../dtd/technicalContent/dtd/topic.dtd" />
<xsl:template match="/">
  <xsl:element name="topic">
  	<xsl:attribute name="id">ldm</xsl:attribute>
  	<title>Logical model documentation</title>
  	<body>
	  	<!-- Packages -->
	    <xsl:apply-templates select="//LogicalDataModel:Package"/>

	    <section>

	    <!-- entities -->
	    <title>Entities</title>
	   	<xsl:apply-templates select="//LogicalDataModel:Entity" mode="entity">
	   		<xsl:sort select="@name"/>
	   	</xsl:apply-templates>
	    </section>

  	</body>
  </xsl:element>
</xsl:template>

<xsl:template match="LogicalDataModel:Package">
  <xsl:variable name="pkgname" select="@name"/>
  <xsl:variable name="pkgid" select="@xmi:id"/>
  <xsl:variable name="parentid" select="@parent"/>
  <xsl:variable name="parentname" select="//LogicalDataModel:Package[@xmi:id=$parentid]/@name" />
  <xsl:element name="section">
  	<xsl:attribute name="id">toc-<xsl:value-of select="$pkgid"/></xsl:attribute>
    <title>Package <xsl:value-of select="$parentname" />/<xsl:value-of select="$pkgname" /></title>

  	<xsl:if test="not(@parent)">
	  	<p>Documentation for logical model <b><xsl:value-of select="@targetNamespace" /></b></p>
	</xsl:if>
	    <p>
	  	   Desciption: <xsl:value-of select="@description"/>
	  	</p>
  	    <xsl:if test="//LogicalDataModel:Entity[@package=$pkgid]"><!-- if we have any entities -->
		    <p><b>Contents:</b></p>
			<ol><!-- table of contents with hyperlinks -->
		    	<xsl:apply-templates select="//LogicalDataModel:Entity[@package=$pkgid]" mode="toc">
		    		<xsl:sort select="@name"/>
		    	</xsl:apply-templates>
			</ol>
		</xsl:if>

  </xsl:element><!-- section -->
</xsl:template>

<xsl:template match="LogicalDataModel:Entity" mode="toc">
	<li>
		<xsl:element name="xref">
			<!-- hyperlink to the table description -->
			<xsl:attribute name="href">
				<!-- DITA XREF target IDs must contain the parent topic ID. "ldm" in our case -->
				<xsl:text>#ldm/ent-</xsl:text><xsl:value-of select="@xmi:id" />
			</xsl:attribute>
			<xsl:value-of select="normalize-space(@name)" /> 
		</xsl:element>
	</li>
</xsl:template>

<xsl:template match="LogicalDataModel:Entity" mode="entity">
	<xsl:variable name="this-id" select="@xmi:id"/>

	<xsl:element name="p"><!-- create an anchor -->
		<xsl:attribute name="id">
			<xsl:text>ent-</xsl:text><xsl:value-of select="$this-id" />
		</xsl:attribute>
			<!-- table name -->
			<b><xsl:value-of select="normalize-space(@name)" /></b>
	</xsl:element>
	<p><lines><!-- table description -->
		<xsl:value-of select="@description" />
	</lines></p>

	<!-- an html table containing column descriptions -->
    <table>
    	<tgroup cols="6" colsep="1" rowsep="1">
    		<colspec colnum="1" colwidth="20%"/>
    		<colspec colnum="2" colwidth="20%"/>
    		<colspec colnum="3" colwidth="10%"/>
    		<colspec colnum="4" colwidth="10%"/>
    		<colspec colnum="5" colwidth="10%"/>
    		<colspec colnum="6" colwidth="30%"/>
			<!-- header row -->
			<thead>
			    <row>
			    	<entry>Column name</entry>
			    	<entry>Data type</entry>
			    	<entry>Key</entry>
			    	<entry>Required</entry>
			    	<entry>Default</entry>
			    	<entry>Description</entry>
				</row>
			</thead>
			<tbody>
				<xsl:apply-templates select="attributes" mode="table"/>
			</tbody>
		</tgroup>
	</table>

	<xsl:if test="//LogicalDataModel:Relationship[@owningEntity = $this-id]" ><!-- if this entity owns any relationships -->
		<xsl:element name="p">
			<xsl:attribute name="id">
				<xsl:text>fk-</xsl:text><xsl:value-of select="$this-id" />
			</xsl:attribute>
			<!-- table name -->
			<b>Foreign key relationships:</b>
		</xsl:element>
		<p>
		<ul>
			<xsl:apply-templates select="//LogicalDataModel:Relationship[@owningEntity = $this-id]" /><!-- add relationships for this entity -->
		</ul>
		</p>
	</xsl:if>

	<p>
		<!-- hyperlink back to TOC -->

	    <xsl:element name="xref">
	    	<xsl:attribute name="href">#ldm/toc-<xsl:value-of select="@package"/></xsl:attribute>
			Back to the table of contents
		</xsl:element>
	</p>
</xsl:template>

<xsl:template match="LogicalDataModel:Relationship">
	<xsl:variable name="own-ent" select="@owningEntity" />
	<xsl:variable name="this-end-id" select="relationshipEnds[@entity = $own-ent][1]/@xmi:id" /><!-- if the table is related to itself, one of the two ends will be selected randomly -->
	<xsl:variable name="child-key" select="relationshipEnds[@xmi:id = $this-end-id]/@key" />
	<xsl:variable name="parent-ent" select="relationshipEnds[not ( @xmi:id = $this-end-id ) ]/@entity" />
	<xsl:variable name="parent-key" select="relationshipEnds[not ( @xmi:id = $this-end-id ) ]/@key" />
	<xsl:variable name="primary-key" select="//LogicalDataModel:Entity[@xmi:id = $own-ent]/keys[ @xsi:type = 'LogicalDataModel:PrimaryKey' ]/@xmi:id" />

	<li>
		<!-- child attributes -->
		<xsl:choose>
			<xsl:when test="$child-key">
				<xsl:apply-templates select="//LogicalDataModel:Entity[@xmi:id = $own-ent]" mode="child-key" >
					<xsl:with-param name="key-id" select="$child-key"/>
				</xsl:apply-templates> 
				====> 
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//LogicalDataModel:Entity[@xmi:id = $own-ent]" mode="child-key" >
					<xsl:with-param name="key-id" select="$primary-key"/>
				</xsl:apply-templates> 
				&lt;====> 
			</xsl:otherwise>
		</xsl:choose>
		<!-- parent entity name and attributes --> 
		<xsl:apply-templates select="//LogicalDataModel:Entity[@xmi:id = $parent-ent]" mode="parent-key" >
			<xsl:with-param name="key-id" select="$parent-key"/>
		</xsl:apply-templates> 
		<!-- FK name -->
		[<xsl:value-of select="@name"/>]
	</li>
</xsl:template>

<xsl:template match="LogicalDataModel:Entity" mode="child-key" >
	<xsl:param name="key-id" />
	<xsl:variable name="key-attrs" select="keys[ @xmi:id = $key-id ]/@attributes" />
	<xsl:apply-templates select="attributes[contains( $key-attrs, @xmi:id)]" mode="fk"/>
</xsl:template>


<xsl:template match="LogicalDataModel:Entity" mode="parent-key" >
	<xsl:param name="key-id" />
	<xsl:variable name="key-attrs" select="keys[ @xmi:id = $key-id ]/@attributes" />
	<xsl:value-of select="@name"/> ( <xsl:apply-templates select="attributes[contains( $key-attrs, @xmi:id)]" mode="fk"/> )
</xsl:template>

<xsl:template match="keys" mode="fk" >
	<xsl:variable name="thiskey" select="."/>
	<xsl:variable name="att-ref" select="@attributes" />
	<li>
		<xsl:apply-templates select="../attributes[contains($att-ref,@xmi:id)]" mode="fk" /> --> 
	</li>
</xsl:template>

<xsl:template match="attributes" mode="fk" >
	<xsl:value-of select="@name"/>,
</xsl:template>

<xsl:template match="attributes" mode="table" >
	<xsl:variable name="attr_id" select="@xmi:id" /> 
	<xsl:element name="row">
		<!-- shade every other row -->
		<xsl:if test="position() mod 2 = 0">
			<xsl:attribute name="outputclass"><xsl:text>altbg</xsl:text></xsl:attribute>
		</xsl:if>

		<entry><xsl:value-of select="@name" /></entry>
		<entry><xsl:value-of select="@dataType" /></entry>
		<entry><!-- key indicator: P and/or F -->
			<!--  ../keys[@xsi:type='LogicalDataModel:PrimaryKey'] and contains(@attributes,$attr_id) --> 
			<xsl:apply-templates select="../keys" mode="key_ind">
				<xsl:with-param name="attr_id" select="@xmi:id" /> 
			</xsl:apply-templates>
		</entry>
		<entry><xsl:value-of select="@required" /></entry>
		<entry><xsl:value-of select="@defaultValue" /></entry>
		<entry><lines><xsl:value-of select="@description" /></lines></entry>

	</xsl:element><!-- table row -->
</xsl:template>

<xsl:template match="keys" mode="key_ind">
	<xsl:param name="attr_id" />
	<xsl:if test="@xsi:type='LogicalDataModel:PrimaryKey' and contains(@attributes,$attr_id)">
		(P)
	</xsl:if>
	<xsl:if test="@xsi:type='LogicalDataModel:ForeignKey' and contains(@attributes,$attr_id)">
		(F)
	</xsl:if>
	<xsl:if test="@xsi:type='LogicalDataModel:AlternateKey' and contains(@attributes,$attr_id)">
		(A)
	</xsl:if>

</xsl:template>

</xsl:stylesheet>