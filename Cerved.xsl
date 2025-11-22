<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Root Template -->
    <xsl:template match="/">
        <html>
            <head>
                <title>Cerved Report</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f9; }
                    h1, h2, h3, h4 { color: #333; }
                    table { border-collapse: collapse; width: 100%; margin-bottom: 20px; background-color: #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
                    th, td { border: 1px solid #ddd; padding: 10px; text-align: left; vertical-align: top; }
                    th { background-color: #0056b3; color: white; width: 30%; }
                    tr:nth-child(even) { background-color: #f9f9f9; }
                    .nested-table { margin: 0; box-shadow: none; width: 100%; }
                    .section-title { background-color: #e9ecef; padding: 10px; font-weight: bold; border: 1px solid #ddd; margin-top: 10px; }
                </style>
            </head>
            <body>
                <h1>Cerved Financial Report</h1>
                <xsl:apply-templates select="*"/>
            </body>
        </html>
    </xsl:template>

    <!-- Template for Subsidiaries to handle Othersubsidiaries as a table -->
    <xsl:template match="Subsidiaries">
        <div class="section-title"><xsl:value-of select="name()"/></div>
        <table>
            <!-- Render non-Othersubsidiaries children as key-value pairs -->
            <xsl:for-each select="*[not(self::Othersubsidiaries)]">
                <tr>
                    <th><xsl:value-of select="name()"/></th>
                    <td><xsl:value-of select="."/></td>
                </tr>
            </xsl:for-each>

            <!-- Render Othersubsidiaries as a nested table if they exist -->
            <xsl:if test="Othersubsidiaries">
                <tr>
                    <td colspan="2" style="padding: 0;">
                        <div class="section-title">Othersubsidiaries List</div>
                        <table class="nested-table">
                            <!-- Header Row from the first Othersubsidiaries element -->
                            <thead>
                                <tr>
                                    <xsl:for-each select="Othersubsidiaries[1]/*">
                                        <th style="background-color: #004494; font-size: 0.9em;"><xsl:value-of select="name()"/></th>
                                    </xsl:for-each>
                                </tr>
                            </thead>
                            <!-- Data Rows -->
                            <tbody>
                                <xsl:for-each select="Othersubsidiaries">
                                    <tr>
                                        <xsl:for-each select="*">
                                            <td><xsl:value-of select="."/></td>
                                        </xsl:for-each>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>

    <!-- Template for SpecialSectionList -->
    <xsl:template match="SpecialSectionList">
        <div class="section-title"><xsl:value-of select="name()"/></div>
        <table>
            <xsl:if test="SpecialSection">
                <thead>
                    <tr>
                        <xsl:for-each select="SpecialSection[1]/*">
                            <th style="background-color: #004494; font-size: 0.9em;"><xsl:value-of select="name()"/></th>
                        </xsl:for-each>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="SpecialSection">
                        <tr>
                            <xsl:for-each select="*">
                                <td><xsl:value-of select="."/></td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </xsl:if>
        </table>
    </xsl:template>

    <!-- Template for OfficialDirectors -->
    <xsl:template match="OfficialDirectors">
        <div class="section-title"><xsl:value-of select="name()"/></div>
        <table>
            <xsl:if test="Director">
                <thead>
                    <tr>
                        <xsl:for-each select="Director[1]/*">
                            <th style="background-color: #004494; font-size: 0.9em;"><xsl:value-of select="name()"/></th>
                        </xsl:for-each>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="Director">
                        <tr>
                            <xsl:for-each select="*">
                                <td><xsl:value-of select="."/></td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </xsl:if>
        </table>
    </xsl:template>

    <!-- Template for Offices to handle BusinessUnit/OfficeAddress -->
    <xsl:template match="Offices">
        <div class="section-title"><xsl:value-of select="name()"/></div>

        <!-- Render RegisteredOffice normally -->
        <xsl:apply-templates select="RegisteredOffice"/>

        <!-- Render BusinessUnit Office Addresses as a table -->
        <xsl:if test="BusinessUnit/OfficeAddress">
            <div class="section-title">Business Unit Office Addresses</div>
            <table>
                <thead>
                    <tr>
                        <xsl:for-each select="BusinessUnit[1]/OfficeAddress/*">
                            <th style="background-color: #004494; font-size: 0.9em;"><xsl:value-of select="name()"/></th>
                        </xsl:for-each>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="BusinessUnit">
                        <tr>
                            <xsl:for-each select="OfficeAddress/*">
                                <td><xsl:value-of select="."/></td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>

    <!-- Hide BusinessUnit (handled in Offices) -->
    <xsl:template match="BusinessUnit"/>
    <xsl:template match="*">
        <!-- Check if the element has child elements (complex structure) -->
        <xsl:choose>
            <xsl:when test="*">
                <div class="section-title"><xsl:value-of select="name()"/></div>
                <table>
                    <!-- Handle Attributes -->
                    <xsl:for-each select="@*">
                        <tr>
                            <th>@<xsl:value-of select="name()"/></th>
                            <td><xsl:value-of select="."/></td>
                        </tr>
                    </xsl:for-each>

                    <!-- Handle Child Elements -->
                    <xsl:for-each select="*">
                        <tr>
                            <!-- If the child is simple (text only), render as key-value -->
                            <xsl:if test="not(*)">
                                <th><xsl:value-of select="name()"/></th>
                                <td>
                                    <xsl:value-of select="."/>
                                    <!-- Also show attributes of simple elements if any -->
                                    <xsl:if test="@*">
                                        <div style="font-size: 0.8em; color: #666;">
                                            <xsl:for-each select="@*">
                                                [@<xsl:value-of select="name()"/>: <xsl:value-of select="."/>]
                                            </xsl:for-each>
                                        </div>
                                    </xsl:if>
                                </td>
                            </xsl:if>

                            <!-- If the child is complex, render recursively -->
                            <xsl:if test="*">
                                <td colspan="2" style="padding: 0;">
                                    <xsl:apply-templates select="."/>
                                </td>
                            </xsl:if>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:when>

            <!-- Simple Element (Text Only) - usually handled by parent, but catch-all here -->
            <xsl:otherwise>
                <!-- This case is mostly reached if the root itself is simple or for mixed content,
                     but our logic above handles children in the loop.
                     However, if we call apply-templates on a simple node directly: -->
                <div class="simple-node">
                    <strong><xsl:value-of select="name()"/>: </strong> <xsl:value-of select="."/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
