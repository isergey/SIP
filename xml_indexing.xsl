<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!--<xsl:template match="/">
    <add>
        <xsl:for-each select="record">
            <xsl:apply-templates select="record"/>
        </xsl:for-each>
    </add>
</xsl:template>-->


<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

<!-- disable all default text node output -->
<xsl:template match="text()"/>

<xsl:template match="/">
    <xsl:if test="record">
        <xsl:variable name="leader7" select="leader/leader07"/>

        <xsl:apply-templates select="record"/>
    </xsl:if>
</xsl:template>

<!-- match on marcxml record -->
<xsl:template match="record">
    <doc>
    	<!-- идннтификатор записи -->
        <xsl:call-template name="local_number"/>
        <!-- Заглавие -->
        <xsl:call-template name="title"/>
        <!-- Автор -->
        <xsl:call-template name="author"/>
        <!-- <xsl:call-template name="subject_heading"/>-->
        <!-- <xsl:call-template name="subject_subheading"/>-->
        <xsl:call-template name="subject_keywords"/>
        <xsl:call-template name="date_of_publication"/>
        <xsl:call-template name="code_language"/>
        <xsl:call-template name="publisher"/>
        <xsl:call-template name="content_type"/>
        <xsl:call-template name="bib_level"/>
        <xsl:call-template name="issn"/>
        <xsl:call-template name="isbn"/>
        <!--  количественная характеристика (количество страниц, томов итп) -->
        <xsl:call-template name="quantitative"/> 
        <xsl:call-template name="owner"/> 
        <xsl:call-template name="has_e_version"/>
        <xsl:call-template name="e_version_url"/>
        <xsl:call-template name="bbk"/>
        <xsl:call-template name="udk"/>
        <xsl:call-template name="classification"/>
        <xsl:call-template name="previous_local_number"/>
        <!-- <xsl:call-template name="Holders"/>
        <xsl:call-template name="Fond"/>
        <xsl:call-template name="Cover"/>-->

    </doc>
</xsl:template>
<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="local_number">
    <xsl:for-each select="field[@id='001']">
        <field name="local_number">
            <xsl:value-of select="."/>
        </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="title">
    <field name="title">
    <xsl:choose>
        <!--
        Если аналитический уровень, то не индексируем 46* поля
        -->
        <xsl:when test="leader/leader07 ='a'">
            <xsl:for-each
                    select="field[(@id &gt; '399' and @id &lt; '460') or (@id &gt; '469' and @id &lt; '500')]/subfield[@id=1]">
                <xsl:call-template name="title"/>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="field[@id &gt; '399' and @id &lt; '500']/subfield[@id=1]">
                <xsl:call-template name="Title-former"/>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:call-template name="Title-former"/>
    </field>
</xsl:template>
<xsl:template name="Title-former">
    <xsl:for-each select="field[@id='200']">
        <!--
        2001#$a{. $h, $i}
        2001#$i
        -->
        <xsl:if test="(subfield[@id='a'] or subfield[@id='i'])">
            <xsl:value-of select="subfield[@id='a']"/>
                <xsl:for-each select="subfield">
                    <xsl:choose>
                        <xsl:when test="@id='e'">
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="@id='h'">
                            <xsl:text>. </xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="@id='i'">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <!--<xsl:when test="@id='v'">
                            <xsl:text>. </xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>-->
                    </xsl:choose>
                </xsl:for-each>
                <xsl:if test="not(subfield[@id='v'])">
                    <xsl:text>. </xsl:text>
                </xsl:if>


        </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="field[@id='225']">
        <!--
        2250#$a{. $h, $i}
        2251#$a{. $h, $i}
        2251#$i
        -->
        <xsl:if test="subfield[@id='a'] and indicator[@id='1'][1] = '1' or indicator[@id='0'][1]">
        <!--<field name="title">-->
                <xsl:value-of select="subfield[@id='a']"/>
                <xsl:for-each select="subfield[@id='h']">
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:if test="@id='i'">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="subfield[@id='i']"/>
                    </xsl:if>

                </xsl:for-each>
        <!--</field>-->
        </xsl:if>
        <!--
        2252#$i
        -->
        <xsl:if test="indicator[@id='1'][1] = '2'">
            <xsl:for-each select="subfield[@id='i']">
                <!--<field name="title">-->
                    <xsl:value-of select="."/>
                    <xsl:text> </xsl:text>
                <!--</field>-->
          </xsl:for-each>
      </xsl:if>
  </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="author">
    <xsl:for-each select="field[@id &gt; '699' and @id &lt; '702']">
        <xsl:variable name="sf_a" select="subfield[@id='a'][1]"/>
        <xsl:choose>
            <!--
                70-#1$a, $g ($c)
                70-#1$a, $b ($c)
            -->
            <xsl:when test="$sf_a and indicator[@id='1']=' ' and indicator[@id='2']='1'">
                <xsl:choose>
                    <xsl:when test="subfield[@id='g'][1] and not(subfield[@id='b'][1])">
                        <xsl:for-each select="subfield[@id='g'][1]">
                            <field name="author">
                                <xsl:value-of select="$sf_a"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:if test="subfield[@id='c'][1]">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="subfield[@id='c'][1]"/>
                                    <xsl:text>) </xsl:text>
                                </xsl:if>
                            </field>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="subfield[@id='b'][1]">
                        <xsl:for-each select="subfield[@id='b'][1]">
                            <field name="author">
                                <xsl:value-of select="$sf_a"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:if test="subfield[@id='c'][1]">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="subfield[@id='c'][1]"/>
                                    <xsl:text>) </xsl:text>
                                </xsl:if>
                            </field>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <field name="author">
                            <xsl:value-of select="$sf_a"/>
                        </field>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <!--
                70-#0$a $d ($c)
            -->
            <xsl:when test="$sf_a and indicator[@id='1']=' ' and indicator[@id='2']='0'">
                <field name="author">
                    <xsl:for-each select="subfield[@id='d'][1]">
                        <xsl:value-of select="$sf_a"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:if test="subfield[@id='c'][1]">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="subfield[@id='c'][1]"/>
                            <xsl:text>) </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </field>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
    <!--<xsl:for-each select="field[@id &gt; '399' and @id &lt; '500']/subfield[@id=1]">
        <xsl:call-template name="Author"/>
    </xsl:for-each>-->
</xsl:template>


<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="subject_heading">
     <xsl:for-each select="field[@id='606']">
        <xsl:if test="indicator[@id ='2'][1]= ' '">
            <xsl:for-each select="subfield[@id='a']">
                <field name="subject_heading">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="subject_subheading">
    <xsl:for-each select="field[@id='606']">
        <xsl:if test="indicator[@id ='2'][1]= ' '">
            <xsl:for-each select="subfield[@id='x']">
                <field name="subject_subheading">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="subject_keywords">
    <xsl:for-each select="field[@id='610']">
        <xsl:if test="indicator[@id ='2'][1]= ' '">
            <xsl:for-each select="subfield[@id='a']">
                <field name="subject_keywords">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="date_of_publication">
    <!-- Если в записе присутвует 463 поле с вложенным подполе 210_d, то дату создания забираем оттуда-->
    <xsl:choose>
        <xsl:when test="field[@id='463']/subfield[@id='1']/field[@id='210']/subfield[@id='d']">
            <xsl:for-each select="field[@id='463']/subfield[@id='1']/field[@id='210']/subfield[@id='d'][1]">
                <field name="date_of_publication">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>
        </xsl:when>
        <!-- Иначе, извлекаем из основного подполя-->
        <xsl:otherwise>
            <xsl:for-each select="field[@id='210']/subfield[@id='d'][1]">
                <field name="date_of_publication">
                    <xsl:value-of select="."/>
                </field>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="code_language">
    <!--
        101-#$a
    -->
    <xsl:for-each select="field[@id='101']/subfield[@id='a']">
        <xsl:if test="../indicator[@id='2'] = ' '">
            <field name="code_language">
                <xsl:value-of select="."/>
            </field>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="publisher">
    <!--
        210##$с
    -->
    <xsl:for-each select="field[@id='210']/subfield[@id='c']">
        <xsl:if test="../indicator[@id='1'][1] = ' ' and ../indicator[@id='2'][1] = ' '">
            <field name="publisher">
                <xsl:value-of select="."/>
            </field>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="issn">
    <xsl:for-each select="field[@id='011']/subfield[@id='a']">
            <field name="issn">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="isbn">
    <xsl:for-each select="field[@id='010']/subfield[@id='a']">
            <field name="isbn">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="quantitative">
    <xsl:for-each select="field[@id='215']/subfield[@id='a']">
            <field name="quantitative">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="owner">
    <xsl:for-each select="field[@id='850']/subfield[@id='a']">
            <field name="owner">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="has_e_version">
    <xsl:choose>
          <xsl:when test="field[@id='856']/subfield[@id='u']">
            <field name="has_e_version">
                <xsl:text>true</xsl:text>
            </field>
          </xsl:when>
        </xsl:choose>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="e_version_url">
    <xsl:for-each select="field[@id='856']/subfield[@id='u']">
            <field name="e_version_url">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="bbk">
    <xsl:for-each select="field[@id='689']/subfield[@id='a']">
            <field name="bbk">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="classification">
    <xsl:for-each select="field[@id='686']">
    	<xsl:variable name="sf_a" select="subfield[@id='a'][1]"/>
    	<xsl:variable name="sf_2" select="subfield[@id='2'][1]"/>
	    <xsl:if test="$sf_2 and $sf_a">
			<xsl:choose>
	          <xsl:when test="$sf_2='rubbk'">
		            <field name="bbk">
		                <xsl:value-of select="$sf_a"/>
		            </field>
	          </xsl:when>
	          <xsl:when test="$sf_2='udc'">
		            <field name="udk">
		                <xsl:value-of select="$sf_a"/>
		            </field>
	          </xsl:when>
	          <xsl:when test="$sf_2='rugasnti'">
		            <field name="grnti">
		                <xsl:value-of select="$sf_a"/>
		            </field>
	          </xsl:when>
	        </xsl:choose>
	    </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="udk">
    <xsl:for-each select="field[@id='675']/subfield[@id='a']">
            <field name="udk">
                <xsl:value-of select="."/>
            </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="content_type">
    <xsl:variable name="f105_a" select="field[@id='105']/subfield[@id='a']"/>
    <xsl:variable name="f105_a_pos_4" select="substring($f105_a, 5, 1)"/>
    <xsl:variable name="f105_a_pos_5" select="substring($f105_a, 6, 1)"/>
    <xsl:variable name="f105_a_pos_6" select="substring($f105_a, 7, 1)"/>
    <xsl:variable name="f105_a_pos_7" select="substring($f105_a, 8, 1)"/>
    <xsl:if test="$f105_a_pos_4 and $f105_a_pos_4 !=' ' and $f105_a_pos_4 !='|'">
        <field name="content_type">
            <xsl:value-of select="$f105_a_pos_4"/>
        </field>
    </xsl:if>
    <xsl:if test="$f105_a_pos_5 and $f105_a_pos_5 !=' ' and $f105_a_pos_5 !='|'">
        <field name="content-type">
            <xsl:value-of select="$f105_a_pos_5"/>
        </field>
    </xsl:if>
    <xsl:if test="$f105_a_pos_6 and $f105_a_pos_6 !=' ' and $f105_a_pos_6 !='|'">
        <field name="content-type">
            <xsl:value-of select="$f105_a_pos_6"/>
        </field>
    </xsl:if>
    <xsl:if test="$f105_a_pos_7 and $f105_a_pos_7 !=' ' and $f105_a_pos_7 !='|'">
        <field name="content-type">
            <xsl:value-of select="$f105_a_pos_7"/>
        </field>
    </xsl:if>

    <xsl:variable name="f110_a" select="field[@id='110']/subfield[@id='a']"/>
    <xsl:variable name="f110_a_pos_3" select="substring($f110_a, 4, 1)"/>
    <xsl:variable name="f110_a_pos_4" select="substring($f110_a, 5, 1)"/>
    <xsl:variable name="f110_a_pos_5" select="substring($f110_a, 6, 1)"/>
    <xsl:variable name="f110_a_pos_6" select="substring($f110_a, 7, 1)"/>

    <xsl:if test="f110_a_pos_3 and f110_a_pos_3 !=' ' and f110_a_pos_3 !='|'">
        <field name="content_type">
            <xsl:value-of select="f110_a_pos_3"/>
        </field>
    </xsl:if>
    <xsl:if test="f110_a_pos_4 and f110_a_pos_4 !=' ' and f110_a_pos_4 !='|'">
        <field name="content_type">
            <xsl:value-of select="f110_a_pos_4"/>
        </field>
    </xsl:if>
    <xsl:if test="f110_a_pos_5 and f110_a_pos_5 !=' ' and f110_a_pos_5 !='|'">
        <field name="content_type">
            <xsl:value-of select="f110_a_pos_5"/>
        </field>
    </xsl:if>
    <xsl:if test="f110_a_pos_6 and f110_a_pos_6 !=' ' and f110_a_pos_6 !='|'">
        <field name="content_type">
            <xsl:value-of select="f110_a_pos_6"/>
        </field>
    </xsl:if>

</xsl:template>



<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="bib_level">
    <xsl:for-each select="leader/leader07">
        <field name="bib_level">
            <xsl:value-of select="."/>
        </field>
    </xsl:for-each>
</xsl:template>



<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->

<xsl:template name="linked_record_number">
    <xsl:for-each select="field[@id='461']/subfield[@id='1']/field[@id='001']">
        <field name="linked_record_number">
            <xsl:value-of select="."/>
        </field>
    </xsl:for-each>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
<xsl:template name="previous_local_number">
    <xsl:for-each select="field[@id='035']/subfield[@id='a']">
        <field name="previose_local_number">
            <xsl:value-of select="."/>
        </field>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>


