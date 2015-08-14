<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 

ldmdoc.xsl

This file is a part of tbldoc v0.2

This XSL stylesheet generates an HTML file that lists entities and attributes 
from an InfoSphere Data Architect logical model file (LDM). 

The generated HTML file refers to ./tbldoc.css (CSS stylesheet) to obtain
output formatting information. A sample tbldoc.css is provided with the tool.
If you replace it with your own stylesheet make sure that you define the 
following styles:
	tr.hdr		- table header
	tr.altbg	- table row with an alternative background
	td.ralign	- table cell with right-aligned text
	.smalltxt	- smaller text pitch



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
	>
<xsl:template match="/">
  <html>
  <xsl:element name="head">
  <!-- some default styles -->
  <style>
h2 {font-size: 18pt; color: blue}
h3 { font-size: 14pt}

table { border: medium solid black; border-collapse: collapse; font-size: 8pt}
thead { background-color: powderblue; font-family: sans-serif; font-weight: bold }
tr.hdr { font-size: 9pt; border: thin solid black }
tr.altbg { background-color: aliceblue }
td {
	padding: 3px 5px;
    vertical-align: top;
}
td.ralign { text-align: right }
.smalltxt {font-size: 8pt}
.with-linebreaks {white-space: pre-line;}
  </style>
	  <!-- create a reference to a custom CSS stylesheet -->
	  <xsl:element name="link">
		<xsl:attribute name="rel">stylesheet</xsl:attribute>
		<xsl:attribute name="href">tbldoc.css</xsl:attribute>
		<xsl:attribute name="type">text/css</xsl:attribute>
	  </xsl:element>
  </xsl:element>
  
  <body>
    <p class="smalltxt" id="theverytop" >
	This logical model documentation is generated 
	by <a href="#copyright">ldmdoc.xsl</a>
	</p>
    <xsl:apply-templates select="//LogicalDataModel:Package"/>

    <hr/>

    <!-- tables -->
   	<xsl:apply-templates select="//LogicalDataModel:Entity" mode="entity">
   		<xsl:sort select="@name"/>
   	</xsl:apply-templates>

	<p id="copyright" class="smalltxt">Generated by ldmdoc tool</p>
	<a href="#theverytop" class="smalltxt">Back to the beginning</a>
  </body>
  </html>
</xsl:template>

<xsl:template match="LogicalDataModel:Package">
  <xsl:variable name="pkgname" select="@name"/>
  <xsl:variable name="pkgid" select="@xmi:id"/>
  <xsl:variable name="parentid" select="@parent"/>
  <xsl:variable name="parentname" select="//LogicalDataModel:Package[@xmi:id=$parentid]/@name" />
  <xsl:element name="h2">
  	<xsl:attribute name="id">toc-<xsl:value-of select="$pkgid"/></xsl:attribute>
    <xsl:text>Package </xsl:text>
	<xsl:value-of select="$parentname" />/<xsl:value-of select="$pkgname" />
  </xsl:element>
  	<xsl:if test="not(@parent)">
	  	<p>Documentation for logical model <strong><xsl:value-of select="@targetNamespace" /></strong></p>
	</xsl:if>
  <div>
  	Desciption: <xsl:value-of select="@description"/>
  </div>
    <h3>Contents:</h3>
	<ol><!-- table of contents with hyperlinks -->
    	<xsl:apply-templates select="//LogicalDataModel:Entity[@package=$pkgid]" mode="toc">
    		<xsl:sort select="@name"/>
    	</xsl:apply-templates>
	</ol>


</xsl:template>

<xsl:template match="LogicalDataModel:Entity" mode="toc">
	<li>
	<xsl:element name="a">
		<!-- hyperlink to the table description -->
		<xsl:attribute name="href">
			<xsl:text>#ent-</xsl:text><xsl:value-of select="@xmi:id" />
		</xsl:attribute>
		<xsl:value-of select="normalize-space(@name)" /> 
	</xsl:element>
	</li>
</xsl:template>

<xsl:template match="LogicalDataModel:Entity" mode="entity">
	<xsl:variable name="this-id" select="@xmi:id"/>

	<xsl:element name="a"><!-- create an anchor -->
		<xsl:attribute name="id">
			<xsl:text>ent-</xsl:text><xsl:value-of select="$this-id" />
		</xsl:attribute>
			<!-- table name -->
			<h3><xsl:value-of select="normalize-space(@name)" />
			</h3>
	</xsl:element>
	<p class="with-linebreaks"><!-- table description -->
		<xsl:value-of select="@description" />
	</p>

	<!-- an html table containing column descriptions -->
    <table>

	<!-- header row -->
	<thead>
    <tr class="hdr">
    	<td>Column name</td>
    	<td>Data type</td>
    	<td>Key</td>
    	<td>Required</td>
    	<td>Default</td>
    	<td>Description</td>
	</tr>
	</thead>

	<xsl:apply-templates select="attributes" mode="table"/>
	</table>

	<xsl:if test="//LogicalDataModel:Relationship[@owningEntity = $this-id]" >
		<xsl:element name="div">
			<xsl:attribute name="id">
				<xsl:text>fk-</xsl:text><xsl:value-of select="$this-id" />
			</xsl:attribute>
				<!-- table name -->
				<h4>Foreign key relationships:</h4>
				<ul>
					<xsl:apply-templates select="//LogicalDataModel:Relationship[@owningEntity = $this-id]" /><!-- add relationships for this entity -->
				</ul>
		</xsl:element>
	</xsl:if>

	<!-- hyperlink back to TOC -->
    <xsl:element name="a">
    	<xsl:attribute name="href">#toc-<xsl:value-of select="@package"/></xsl:attribute>
    	<xsl:attribute name="class">smalltxt</xsl:attribute>
		Back to the table of contents
	</xsl:element>
	<hr />
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
		<span class="smalltxt">[<xsl:value-of select="@name"/>]</span>
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
	<xsl:element name="tr">
		<!-- shade every other row -->
		<xsl:if test="position() mod 2 = 0">
			<xsl:attribute name="class"><xsl:text>altbg</xsl:text></xsl:attribute>
		</xsl:if>

		<td><xsl:value-of select="@name" /></td>
		<td><xsl:value-of select="@dataType" /></td>
		<td><!-- key indicator: P and/or F -->
			<!--  ../keys[@xsi:type='LogicalDataModel:PrimaryKey'] and contains(@attributes,$attr_id) --> 
			<xsl:apply-templates select="../keys" mode="key_ind">
				<xsl:with-param name="attr_id" select="@xmi:id" /> 
			</xsl:apply-templates>
		</td>
		<td><xsl:value-of select="@required" /></td>
		<td><xsl:value-of select="@defaultValue" /></td>
		<td class="with-linebreaks"><xsl:value-of select="@description" /></td>

	</xsl:element><!-- tr -->
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