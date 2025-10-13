<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://hl7.org/fhir"
    xmlns:f="http://hl7.org/fhir"
    exclude-result-prefixes="xs math xd f fn"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 28, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> helma</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:variable name="projectsDir"
        >file:///Users/helma/Documents/_projects/vzvz/Koppeltaal-2.0-FHIR</xsl:variable>
    <xsl:variable name="resources" select="concat($projectsDir, '/resources/?select=*.xml')"/>
    <xsl:param name="files" select="uri-collection($resources)"/>
    <xsl:param name="version" select="'0.12.0-beta.1'"/>
    <xsl:param name="date" select="format-date(fn:current-date(), '[Y0001]-[M01]-[D01]')"/>

    <xsl:output indent="true"/>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="/f:ImplementationGuide">
        <xsl:result-document href="{$projectsDir}/KT2ImplementationGuide.xml" method="xml">
            <ImplementationGuide>
                <id value="koppeltaal-ig-{./f:packageId/@value}"/>
                <xsl:copy-of select="./f:url"/>
                <version value="{$version}"/>
                <xsl:copy-of select="./f:name"/>
                <status value="active"/>
                <xsl:copy-of select="./f:experimental"/>
                <date value="{$date}"/>
                <xsl:copy-of
                    select="./f:publisher | ./f:packageId | ./f:fhirVersion | ./f:dependsOn"/>
                <xsl:for-each select="$files ! doc(.)">
                    <xsl:variable name="pos" select="fn:position()"/>
                    <xsl:if test="not(fn:contains($files[$pos], 'ImplementationGuide'))">
                        <xsl:if test="exists(./f:StructureDefinition)">
                            <global>
                                <type>
                                    <xsl:attribute name="value">
                                    <xsl:choose>
                                        <xsl:when test="./f:StructureDefinition/f:type/@value = 'Extension'">
                                            <xsl:value-of select="'StructureDefinition'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="./f:StructureDefinition/f:type/@value"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    </xsl:attribute>
                                </type>
                                <profile>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="./f:*/f:url/@value"/>
                                    </xsl:attribute>
                                </profile>
                            </global>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </ImplementationGuide>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
