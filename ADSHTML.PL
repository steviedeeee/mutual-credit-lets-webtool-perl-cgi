# adsHTML.pl

##########################################################
##
##		AD DIRECTORY MENU
##
##########################################################
sub html_footer {
# ----------------------------------------------------------------------------------------------
# Print the menu: We only print options that the user has permissions for.

print qq! <$inner2Table> !;
print qq! <TR>!;
print qq! <TD BGCOLOR="#ffffcc" align=left><$font><b>Ad Directory Listings:</b></font></TD>!; 
print qq! <TD BGCOLOR="#000000"><$font><font color=white>&nbsp;<A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid&view_search=1">Search</A> !  if ($per_view);
print qq!| <A HREF="$db_script_link_url&add_form=1">Add</A> !	        if ($per_add);
print qq!| <A HREF="$db_script_link_url&delete_search=1">Delete</A> !	if ($per_del);
print qq!| <A HREF="$db_script_link_url&modify_search=1">Modify</A> !	if ($per_mod);
print qq!| <A HREF="$db_script_link_url&view_records=1&$db_key=*">List All</A> ! if ($per_view);
print qq!| <A HREF="$db_script_link_url&logoff=1">Log Off</A> !;
print qq!| <A HREF="$helpURL">Help</A>&nbsp;</font></font></TD></TR> !;

# Options to switch to other database tables.
print qq!
<TR>
	<TD colspan=2 BGCOLOR="#009900">
		<$fontWhite>
			<A HREF="$db_script_url?db=trades&sys=$sysID&uid=$db_uid">Transactions</A> !;
			if ($per_admin) {
				print qq! 
				| <A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid&admin_display=1">Members</A>
				| <A HREF="$db_script_url?db=cats&sys=$sysID&uid=$db_uid">Categories</A>
				| <A HREF="$db_script_url?db=systems&sys=$sysID&uid=$db_uid">Trading Systems</A>
				| <A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid&download=1">Download System Data</A>&nbsp;
				!;
			}
		print qq!
		</font>
	</TD>
</TR>
</table>!;
}	

###################################################################### 
##
##  	KEYWORD SEARCH
## 
######################################################################
sub html_search_options {
# ----------------------------------------------------------------------------------------------
# Arrangement of keyword fields / how the Directory Search appears.

my (%rec) = @_;

print qq|
<TABLE WIDTH="585" CELLPADDING=0 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" align=center>
	<!-- ******************************************************************************-->
	<!-- CURRENCY SYSTEM                                                               -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>System&nbsp;</FONT></td>
    	<$tdBeigeLeftColspan2>|;
			# Build the drop-down list of systems. Table name passed first, then field name,
			# then value selected, finally the name of the form element itself.
			print &build_select_field_from_db ("systems", "CCSystem", "$rec{'CC_System'}", "CC_System");
			print qq|
    	</td>
	</TR>
	<!-- ******************************************************************************-->
	<!-- AD CATEGORY                                                                   -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>Ad Category&nbsp;</FONT></td>
    	<$tdBeigeLeftColspan2>|; 
			print &build_select_field_from_db ("cats", "CatName", "$rec{'Ad_Category'}", "Ad_Category");
			print qq|
	    </td>
	</TR>
	<!-- ******************************************************************************-->
	<!-- AD TYPE                                                                       -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>Ad Type&nbsp;</FONT></td>
    	<$tdBeigeLeftColspan2>
			<SELECT NAME="Ad_Type">
				<OPTION VALUE="---">--- all ---
				<OPTION SELECTED>Offered
				<OPTION>Wanted
			</SELECT>
	    </td>
	</TR>
	<!-- ******************************************************************************-->
	<!-- SPACER LINE                                                                   -->
	<!-- ******************************************************************************-->
	<tr><td bgcolor=white colspan=3 align=right>&nbsp;</td></tr>

	<!-- ******************************************************************************-->
	<!-- TEXT KEYWORD, PHONE                                                           -->
	<!-- ******************************************************************************-->
	<TR>
	    <$tdGreyRight><$fontWhite>Text Keyword&nbsp;</FONT></TD>
    	<$tdBeigeLeft>
        	<INPUT TYPE="TEXT" NAME="Ad_Text" VALUE="$rec{'Ad_Text'}" SIZE="20" MAXLENGTH="20">
    	</TD>
    	<td bgcolor="#ffffcc" align=LEFT>
			<$font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phone </FONT>
			<INPUT TYPE="TEXT" NAME="H_phone" VALUE="$rec{'H_phone'}" SIZE="21" MAXLENGTH="30">
    	</TD>
	</TR>
	<!-- ******************************************************************************-->
	<!-- EMAIL 																		   -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>Email&nbsp;</FONT></TD>
	    <td colspan=2 bgcolor="#ffffcc" align=LEFT><INPUT TYPE="TEXT" NAME="Email" VALUE="$rec{'Email'}" SIZE="57" MAXLENGTH="255"></TD>
	</TR>
	<!-- ******************************************************************************-->
	<!-- URL																		   -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>Website/URL&nbsp;</FONT></TD>
	    <td colspan=2 bgcolor="#ffffcc" align=LEFT>
    	    <INPUT TYPE="TEXT" NAME="URL" VALUE="$rec{'URL'}" SIZE="57" MAXLENGTH="255">
	    </TD>
	</TR>
	<!-- ******************************************************************************-->
	<!-- LISTINGS ENTERED BY MEMBER ID												   -->
	<!-- ******************************************************************************-->
	<tr>
    	<td colspan=2 align=right bgcolor="#999999">
			<$fontWhite>Listing(s) entered by member ID&nbsp;</FONT>
		</td>
    	<$tdBeigeRight>
        	<INPUT TYPE="TEXT" NAME="User_ID" VALUE="$rec{'User_ID'}" SIZE="33" MAXLENGTH="20">
	    </td>
	</tr>
</table>
|;
}

##########################################################
##
##		ADD / MODIFY
##
##########################################################
sub html_record_form {
# ----------------------------------------------------------------------------------------------
# The form fields that will be displayed each time a record is edited or created. Don't put the
# <FORM> and </FORM tags, merely the <INPUT> tags; values to be displayed are in %rec.

my (%rec) = @_;		# Pass in record to edit. If you're creating a new one, defaults are used.

# Get the system name for the $sysID recorded when this ad was created.
$sysName = &getSystemName($sysID);

$currentDate = &get_date;	# Used to update the modified record with today's date.

print qq|
<br>
<$innerTable>
<!--TABLE WIDTH=620 CELLPADDING=3 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc"-->
<INPUT TYPE="HIDDEN" NAME="ID" VALUE="$rec{'ID'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="Entry_Date" VALUE="$currentDate" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="sysID" VALUE="$sysID" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="CC_System" VALUE="$sysName" SIZE="3" MAXLENGTH="3">

<!-- ******************************************************************************-->
<!-- AD CATEGORY, AD TYPE, LAST EDITED 											   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Category</FONT></TD>
    <$tdBeigeLeft>|;
		print &build_select_field_from_db ("cats", "CatName", "$rec{'Ad_Category'}", "Ad_Category"); 
        print qq|
    </TD>    
    <$tdBeigeRight><$font>Type&nbsp;</FONT>|;
        print &build_select_field ("Ad_Type", "$rec{'Ad_Type'}"); 
        print qq|
    </TD>
    <$tdBeigeRight><$font>Last Edited $rec{'Entry_Date'}</FONT></td>
</TR>
<!-- ******************************************************************************-->
<!-- AD TEXT 																	   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Text of<br>Listing</FONT></TD>
    <TD COLSPAN="3" bgcolor="#ffffcc">
        <TEXTAREA NAME="Ad_Text" ROWS="4" COLS="58" WRAP="VIRTUAL" MAXLENGTH="900">$rec{'Ad_Text'}</TEXTAREA>
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- EMAIL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Email</FONT></TD>
    <TD COLSPAN="3" bgcolor="#ffffcc">
        <INPUT TYPE="TEXT" NAME="Email" VALUE="$rec{'Email'}" SIZE="63" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- URL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Website/URL</FONT></TD>
    <TD COLSPAN="3" bgcolor="#ffffcc">
        <INPUT TYPE="TEXT" NAME="URL" VALUE="$rec{'URL'}" SIZE="63" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- PHONE, PERMANENT LISTING?													   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Phone</FONT></td>
	<$tdBeigeLeft>
		<INPUT TYPE="TEXT" NAME="H_phone" VALUE="$rec{'H_phone'}" SIZE="15" MAXLENGTH="30">
	</TD>
    <td colspan=2 align=right bgcolor="#ffffcc"><$font>&nbsp;Permanent Listing?&nbsp;</FONT>
    	|; print &build_select_field ("Permanent", "$rec{'Permanent'}"); print qq|
    </TD>
</tr>
<!-- ******************************************************************************-->
<!-- ENTERED BY, CURRENCY SYSTEM                                                   -->
<!-- ******************************************************************************-->
<TR>
    <TD ALIGN=right bgcolor="white" colspan=4>
		<$font>Entered by <b>$db_userid</b> in $sysName</FONT>
	</TD>
</TR>
</TABLE>
|;
}

##########################################################
##
##    DISPLAY RECORD
##
##########################################################
sub html_record {
# ----------------------------------------------------------------------------------------------
# The format of how a record will be displayed. This is used in returning search results, and
# to display a successfully modified or added record.

my (%rec) = @_;		# Load any defaults to put in the VALUE field.
($db_auto_generate and print &build_html_record(%rec) and return);

# Get the system name for the $sysID that was associated with this ad when it was created.
$storedSystemName = &getSystemName($rec{'sysID'});
	
print qq|
<center>
<TABLE WIDTH="620" CELLPADDING=5 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc">
	<tr>
		<td colspan=2 bgcolor=white><B><$font>$rec{'Ad_Type'}</FONT></B></td>
		<td bgcolor=white align=right><$font><b>$storedSystemName</b></font></td>
	</tr>
	<TR>
    	<td bgcolor="#999999" width="25%" align=right><$fontWhite>Category</FONT></TD>
	    <td bgcolor="#ffffcc" width="25%"><B><$font>$rec{'Ad_Category'}</FONT></B></TD>
    	<td bgcolor="#ffffcc" align=right><$font>Last Edited: $rec{'Entry_Date'}</FONT></TD>
	</TR>
	<TR>
    	<$tdGreyRight><$fontWhite>Text of Listing</FONT></TD>
    	<TD colspan=2 bgcolor="#ffffcc" width="75%"><$font>$rec{'Ad_Text'}</TD>
	</TR>
	|; 	# print email and URL lines only if they're not empty
	if ($rec{'Email'} ne "") {
		print qq|
		<TR>
    		<$tdGreyRight><$fontWhite>Email</FONT></TD>
    		<TD colspan=2 bgcolor="#ffffcc"><$font>$rec{'Email'}</TD>
		</TR>|;
	}
	print qq|
	<tr>
   		<$tdGreyRight><$fontWhite>Phone</FONT></td>
		<$tdBeigeLeft><$font>$rec{'H_phone'}&nbsp;</FONT></td>
		<td bgcolor="#ffffcc" align=right><$font>Permanent Listing? $rec{'Permanent'}</FONT></TD>
	</tr>
	|;
	if ($rec{'URL'} ne "") {
		print qq|
		<TR>
    		<$tdGreyRight><$fontWhite>Website/URL</FONT></TD>
    		<TD colspan=2 bgcolor="#999999">
				<$font><A HREF="$rec{'URL'}">$rec{'URL'}</A></font>
			</TD>
		</TR>|;
	}
	print qq|
	<tr>
		<td bgcolor=white align=right colspan=3>
			<$font>Entered by <b>$rec{'User_ID'}</b></font>
		</td>
	</tr>
</TABLE>
|;
}
1;
