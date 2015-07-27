<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 

tbldoc.xsl

This file is a part of tbldoc v0.1

Copyright (c) 2004 Nick Ivanov / nick@datori.org
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




This XSL stylesheet generates an HTML file that lists database tables and 
views. Source data must reside in an XML file that complies with the XML 
schema specified in tbldoc.xsd. 

The generated HTML file refers to ./tbldoc.css (CSS stylesheet) to obtain
output formatting information. A sample tbldoc.css is provided with the tool.
If you replace it with your own stylesheet make sure that you define the 
following styles:
	tr.hdr		- table header
	tr.altbg	- table row with an alternative background
	td.ralign	- table cell with right-aligned text
	.smalltxt	- smaller text pitch


                                                 
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
  <xsl:element name="head">
  <!-- create a reference to a CSS stylesheet -->
  <xsl:element name="link">
	<xsl:attribute name="rel">stylesheet</xsl:attribute>
	<xsl:attribute name="href">tbldoc.css</xsl:attribute>
	<xsl:attribute name="type">text/css</xsl:attribute>
  </xsl:element>
  </xsl:element>
  
  <body>
  <xsl:apply-templates />
  </body>
  </html>
</xsl:template>

<xsl:template match="catalog">
  <a id="theverytop" />
  <h2>Tables and views
	<xsl:if test="server"> in database <xsl:value-of select="server/text()" /></xsl:if>
  </h2>
	<xsl:if test="version"><p>DB software version  <xsl:value-of select="version/text()" /></p></xsl:if>
    <p class="smalltxt">
	This document is generated 
    <xsl:if test="tstamp">at <xsl:value-of select="tstamp/text()" /></xsl:if>
	by <a href="#copyright">tbldoc.xsl</a>
	</p>
    <a id="toc"><h3>Contents:</h3></a>

	<ol><!-- table of contents with hyperlinks -->

    <xsl:for-each select="table">
		<li>
		<xsl:element name="a">
			<!-- hyperlink to the table description -->
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text><xsl:value-of select="normalize-space(@schema)" /><xsl:text>.</xsl:text><xsl:value-of select="normalize-space(@name)" />
			</xsl:attribute>
			<xsl:value-of select="normalize-space(@schema)" /><xsl:text>.</xsl:text><xsl:value-of select="normalize-space(@name)" /> 
			(<xsl:value-of select="@type" />)
		</xsl:element>
		</li>
	</xsl:for-each>
	</ol>

	<xsl:for-each select="table">
		<xsl:element name="a"><!-- create an anchor -->
			<xsl:attribute name="id">
				<xsl:value-of select="normalize-space(@schema)" /><xsl:text>.</xsl:text><xsl:value-of select="normalize-space(@name)" />
			</xsl:attribute>
			<!-- table name -->
			<h3><xsl:value-of select="normalize-space(@typedesc)" />: 
			<xsl:value-of select="normalize-space(@schema)" /><xsl:text>.</xsl:text><xsl:value-of select="normalize-space(@name)" />
			</h3>
		</xsl:element>

		<!-- an html table containing column descriptions -->
        <table>

		<!-- header row -->
		<thead>
        <tr class="hdr">
		<xsl:for-each select="column[position()=1]/@*">
			<td><xsl:value-of select="translate(name(),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" /></td>
		</xsl:for-each>
		</tr>
		</thead>

		<xsl:for-each select="column">
			<xsl:element name="tr">
				<!-- shade every other row -->
				<xsl:if test="position() mod 2 = 0">
					<xsl:attribute name="class"><xsl:text>altbg</xsl:text></xsl:attribute>
				</xsl:if>

				<xsl:for-each select="@*">
					<!-- describe each database column -->
					<xsl:element name="td">
						<!-- make sure numbers are right-aligned -->
						<xsl:if test="string(number(.)) != 'NaN'">
							<xsl:attribute name="class">
								<xsl:text>ralign</xsl:text>
							</xsl:attribute>
						</xsl:if>
					   <xsl:value-of select="translate(.,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
					</xsl:element>
				</xsl:for-each>

			</xsl:element>
		</xsl:for-each>
		</table>

		<!-- hyperlink back to TOC -->
		<a href="#toc" class="smalltxt">Back to the table of contents</a>
		<hr />
	</xsl:for-each>

	<p id="copyright" class="smalltxt">Generated by tbldoc tool, which is Copyright (c) 2004-2006 Nick Ivanov / <a href="http://www.datori.org">www.datori.org</a></p>
	<a href="#theverytop" class="smalltxt">Back to the beginning</a>
</xsl:template>
</xsl:stylesheet>