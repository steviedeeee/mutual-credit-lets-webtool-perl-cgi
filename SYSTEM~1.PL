#  systemsHTML.pl

###################################################################### 
##
##  	SYSTEMS SEARCH LAYOUT
## 
######################################################################
sub html_search_options {
# ----------------------------------------------------------------------------------------------
my (%rec) = @_;

print qq|
<$innerTable>
<!--TABLE WIDTH="620" CELLPADDING=0 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" align=center-->
<!-- ******************************************************************************-->
<!-- CCSYSTEM                          											   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Currency System</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="CCSystem" VALUE="$rec{'CCSystem'}" SIZE="58" MAXLENGTH="255">
    </TD>    
</TR>
<!-- ******************************************************************************-->
<!-- EMAIL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Email Address</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="Email" VALUE="$rec{'Email'}" SIZE="58" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- URL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Website/URL</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="URL" VALUE="$rec{'URL'}" SIZE="58" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- ADDRESS 																	   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRightTop><$fontWhite>Address</FONT></TD>
    <$tdBeigeLeftColspan2>
        <TEXTAREA NAME="Address" ROWS="4" COLS="50" WRAP="VIRTUAL" MAXLENGTH="900">$rec{'Address'}</TEXTAREA>
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- PHONE, CONTACT NAME      													   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Phone</FONT></td>
	<td bgcolor="#ffffcc" width=183>
        <INPUT TYPE="TEXT" NAME="Phone" VALUE="$rec{'Phone'}" SIZE="15" MAXLENGTH="255">
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Contact&nbsp;</FONT><INPUT TYPE="TEXT" NAME="ContactName" VALUE="$rec{'ContactName'}" SIZE="21" MAXLENGTH="30"></TD>
</tr>
<!-- ******************************************************************************-->
<!-- FAX, CURRENCY NAME      													   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Fax</FONT></td>
	<td bgcolor="#ffffcc" width=183>
        <INPUT TYPE="TEXT" NAME="Fax" VALUE="$rec{'Fax'}" SIZE="15" MAXLENGTH="255">
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Currency&nbsp;</FONT><INPUT TYPE="TEXT" NAME="CurrencyName" VALUE="$rec{'CurrencyName'}" SIZE="21" MAXLENGTH="30"></TD>
</tr>
<!-- ******************************************************************************-->
<!-- MAXHITS                                                                       -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Hits Per Page</FONT></td>
	<td bgcolor="#ffffcc" colspan=2>
		<INPUT TYPE="TEXT" NAME="MaxHits" VALUE="$rec{'MaxHits'}" SIZE="2" MAXLENGTH="30">
	</td>
</TD>
</tr>
<!-- ******************************************************************************-->
<!-- COMMENTS                                                                      -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRightTop><$fontWhite>Comments</FONT></TD>
    <$tdBeigeLeftColspan2>
        <TEXTAREA NAME="Comments" ROWS="4" COLS="50" WRAP="VIRTUAL" MAXLENGTH="900">$rec{'Comments'}</TEXTAREA>
    </TD>
</TR>
<TR>
	<TD ALIGN=right bgcolor="white" colspan=3><$font>&nbsp;</font></TD>
</TR>
</table>
|;
}

##########################################################
##
##		SYSTEM MENU
##
##########################################################
sub html_footer {
# ----------------------------------------------------------------------------------------------
# Print the menu: We only print options that the user has permissions for.

print qq! <$inner2Table> !;
#table border=0 bgcolor="#cccccc" cellpadding=5 cellspacing=1 width=620 align=center valign=top>!;

print qq! <TR>!;
print qq! <TD BGCOLOR="#ffffcc" align=left><$font><b>&nbsp;Trading Systems:</b></font></TD>!; 
print qq! <TD BGCOLOR="#000000"><$font><FONT COLOR="#FFFFFF">&nbsp;<A HREF="$db_script_link_url&view_search=1">Search</A> !  if ($per_view);
print qq!| <A HREF="$db_script_link_url&add_form=1">Add</A> !   if ($per_add);

print qq!| <A HREF="$db_script_link_url&delete_search=1">Delete</A> !	if ($per_del);
print qq!| <A HREF="$db_script_link_url&modify_search=1">Modify</A> !	if ($per_mod);
print qq!| <A HREF="$db_script_link_url&view_records=1&$db_key=*">List All</A> ! if ($per_view);
print qq!| <A HREF="$db_script_link_url&logoff=1">Log Off</A> !;
print qq!| <A HREF="$helpURL">Help</A>&nbsp;</font></font></TD></TR> !;

# options to switch to other tables, depending on permissions.
print qq!
<TR>
	<TD colspan=2 BGCOLOR="#009900">
		<$fontWhite>
			&nbsp;<A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid">Ad Directory</A>&nbsp;|
			<A HREF="$db_script_url?db=trades&sys=$sysID&uid=$db_uid">Transactions</A> !;
			if ($per_admin) {
				print qq! 
				| <A HREF="$db_script_url?db=systems&sys=$sysID&uid=$db_uid&admin_display=1">Members</A>
				| <A HREF="$db_script_url?db=cats&sys=$sysID&uid=$db_uid">Categories</A>
				| <A HREF="$db_script_url?db=systems&sys=$sysID&uid=$db_uid&download=1">Download System Data</A>&nbsp;
				!;
			}
			print qq!
		</font>
	</TD>
</TR>
</table>!;
}	

##########################################################
##
##		ADD / MODIFY DIRECTORY LAYOUT 
##
##########################################################
sub html_record_form {
# ----------------------------------------------------------------------------------------------
# The form fields that will be displayed each time a record is edited or created. You don't want
# to put the <FORM> and </FORM tags, merely the <INPUT> tags for each field. The values to be 
# displayed are in %rec and should be incorporated into your form. You use &build_select_field,
# &build_checkbox_field and &build_radio_field to generate the respective input boxes. Text and
# Textarea inputs can be inserted as is. 

my (%rec) = @_;

# Build a short random number and append it to some letters from the system name, to define a 
# data directory for this new system.

srand( time() ^ ($$ + ($$ << 15)) );	# Seed Random Number
$r = int(rand(100))+1;
$systemPath = (int(rand($r)) * int(rand($r)));

print qq|
<br>
<$innerTable>
<INPUT TYPE="HIDDEN" NAME="ID" VALUE="$rec{'ID'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="EntryDate" VALUE="$rec{'EntryDate'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="PathID" VALUE="$systemPath" SIZE="3" MAXLENGTH="3">
|;

print qq|
<!-- ******************************************************************************-->
<!-- CCSYSTEM                          											   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Currency System</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="CCSystem" VALUE="$rec{'CCSystem'}" SIZE="58" MAXLENGTH="255">
    </TD>    
</TR>
<!-- ******************************************************************************-->
<!-- EMAIL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Email Address</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="Email" VALUE="$rec{'Email'}" SIZE="58" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- URL 																		   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Website/URL</FONT></TD>
    <$tdBeigeLeftColspan2>
        <INPUT TYPE="TEXT" NAME="URL" VALUE="$rec{'URL'}" SIZE="58" MAXLENGTH="255">
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- ADDRESS 																	   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRightTop><$fontWhite>Address</FONT></TD>
    <$tdBeigeLeftColspan2>
        <TEXTAREA NAME="Address" ROWS="4" COLS="50" WRAP="VIRTUAL" MAXLENGTH="900">$rec{'Address'}</TEXTAREA>
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- LOGIN NAME, PHONE      													   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Admin User ID</FONT></td>
	<td bgcolor="#ffffcc" width=183>
        <INPUT TYPE="TEXT" NAME="LoginName" VALUE="$rec{'LoginName'}" SIZE="15" MAXLENGTH="255">
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Phone&nbsp;</FONT><INPUT TYPE="TEXT" NAME="Phone" VALUE="$rec{'Phone'}" SIZE="21" MAXLENGTH="255"></TD>
</tr>
<!-- ******************************************************************************-->
<!-- PASSWORD, FAX          													   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Password</FONT></td>
	<td bgcolor="#ffffcc" width=183>
        <INPUT TYPE="TEXT" NAME="Password" VALUE="$rec{'Password'}" SIZE="15" MAXLENGTH="255">
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Fax&nbsp;</FONT><INPUT TYPE="TEXT" NAME="Fax" VALUE="$rec{'Fax'}" SIZE="21" MAXLENGTH="30"></TD>
</tr>
<!-- ******************************************************************************-->
<!-- CONTACT NAME, CURRENCY NAME												   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Contact Name</FONT></td>
	<td bgcolor="#ffffcc" width=183>
        <INPUT TYPE="TEXT" NAME="ContactName" VALUE="$rec{'ContactName'}" SIZE="15" MAXLENGTH="255">
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Currency&nbsp;</FONT><INPUT TYPE="TEXT" NAME="CurrencyName" VALUE="$rec{'CurrencyName'}" SIZE="21" MAXLENGTH="30"></TD>
</tr>
<!-- ******************************************************************************-->
<!-- INTERTRADING, MAXHITS                                                         -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Hits Per Page</FONT></td>
	<td bgcolor="#ffffcc" colspan=2>
		<INPUT TYPE="TEXT" NAME="MaxHits" VALUE="$rec{'MaxHits'}" SIZE="2" MAXLENGTH="30">
	</td>
	<!--
	<td bgcolor="#ffffcc" width=183>
		|; print &build_select_field ("Intertrading", "$rec{'Intertrading'}"); print qq|
	</TD>
	<td align=right bgcolor="#ffffcc" width=230><$font>Hits Per Page&nbsp;</FONT><INPUT TYPE="TEXT" NAME="MaxHits" VALUE="$rec{'MaxHits'}" SIZE="2" MAXLENGTH="30">
	-->
</TD>
</tr>
<!-- ******************************************************************************-->
<!-- COMMENTS                                                                      -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRightTop><$fontWhite>Comments</FONT></TD>
    <$tdBeigeLeftColspan2>
        <TEXTAREA NAME="Comments" ROWS="4" COLS="50" WRAP="VIRTUAL" MAXLENGTH="900">$rec{'Comments'}</TEXTAREA>
    </TD>
</TR>
<!-- ******************************************************************************-->
<!-- ENTRY DATE                                                                    -->
<!-- ******************************************************************************-->
<TR><TD ALIGN=right bgcolor="white" colspan=3><$font>$rec{'EntryDate'}</FONT></TD></TR>
</TABLE>
|;
}

##########################################################
##
##    DISPLAY RECORD TEMPLATE FOR DIRECTORY LISTINGS
##
##########################################################
sub html_record {
# ----------------------------------------------------------------------------------------------
# The format of how a record will be displayed. This is used in returning search results, and
# to display a successfully modified or added record.

my (%rec) = @_;		# Load any defaults to put in the VALUE field.
($db_auto_generate and print &build_html_record(%rec) and return);
	
print qq|
<center>
<TABLE WIDTH="620" CELLPADDING=5 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc">
<!-- ******************************************************************************-->
<!-- CCSYSTEM                          											   -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Currency System</FONT></TD>
    <$tdBeigeLeftColspan2><$font>$rec{'CCSystem'}</font></TD>    
</TR>
<!-- ******************************************************************************-->
<!-- EMAIL 																		   -->
<!-- ******************************************************************************-->|;
if ($rec{'Email'} ne "") {
	print qq|
	<TR>
   		<$tdGreyRight><$fontWhite>Email</FONT></TD>
   		<TD colspan=2 bgcolor="#ffffcc"><$font>$rec{'Email'}</TD>
	</TR>|;
}
print qq|
<!-- ******************************************************************************-->
<!-- URL 																		   -->
<!-- ******************************************************************************-->|;
if ($rec{'URL'} ne "") {
	print qq|
	<TR>
   		<$tdGreyRight><$fontWhite>Website/URL</FONT></TD>
   		<TD colspan=2 bgcolor="ffffcc"><$font>$rec{'URL'}</TD>
	</TR>|;
}
print qq|
<!-- ******************************************************************************-->
<!-- ADDRESS 																	   -->
<!-- ******************************************************************************-->|;
if ($rec{'Address'} ne "") {
	print qq|
	<TR>
   		<$tdGreyRight><$fontWhite>Address</FONT></TD>
	    <$tdBeigeLeftColspan2><$font>$rec{'Address'}</font></TD>
	</TR>|;
}
print qq|
<!-- ******************************************************************************-->
<!-- ADMIN LOGIN NAME, PASSWORD													   -->
<!-- ******************************************************************************-->
<TR>
	<$tdGreyRight><$fontWhite>Admin User ID</FONT></TD>|;
    print qq| <$tdBeigeLeft><$font>$rec{'LoginName'}</font></TD> |;
	print qq| <$tdBeigeLeft><$font>Password:&nbsp; $rec{'Password'}</font></TD> |;
print qq|
</TR>
<!-- ******************************************************************************-->
<!-- PHONE, CONTACT NAME      													   -->
<!-- ******************************************************************************-->|;
if ($rec{'ContactName'} ne "") {
	# Check if phone is blank, and if so make contact span 2 columns.
	if ($rec{'Phone'} ne "") {
		# both phone and contact were non-empty, print normally.
		print qq|
		<TR>
   			<$tdGreyRight><$fontWhite>Phone</FONT></TD>
		    <$tdBeigeLeft><$font>$rec{'Phone'}</font></TD>
			<$tdBeigeLeft><$font>Contact:&nbsp; $rec{'ContactName'}</font></TD>
		</TR>|;
	} else {
		# phone was blank; make contact span 2 columns
		print qq|
		<tr>
			<$tdGreyRight><$fontWhite>Contact</FONT></TD>
		    <$tdBeigeLeftColspan2><$font>$rec{'ContactName'}</font></TD>
		</tr>|;
	}
} else {
	# contact was blank; check if phone was too and if so skip the line.
	if ($rec{'Phone'} ne "") {
		# print phone only, 2 columns
		print qq|
		<tr>
			<$tdGreyRight><$fontWhite>Phone</FONT></TD>
		    <$tdBeigeLeftColspan2><$font>$rec{'Phone'}</font></TD>
		</tr>|;
	} else {
		# skip the line
	}
}
print qq|
<!-- ******************************************************************************-->
<!-- FAX, CURRENCY NAME      													   -->
<!-- ******************************************************************************-->|;
if ($rec{'Fax'} ne "") {
	# Check if currency is blank, and if so make fax span 2 columns.
	if ($rec{'CurrencyName'} ne "") {
		# both were non-empty so print normally.
		print qq|
		<TR>
   			<$tdGreyRight><$fontWhite>Fax</FONT></TD>
		    <$tdBeigeLeft><$font>$rec{'Fax'}</font></TD>
			<$tdBeigeLeft><$font>Currency:&nbsp; $rec{'CurrencyName'}</font></TD>
		</TR>|;
	} else {
		# currency was blank; make fax span 2 columns
		print qq|
		<tr>
			<$tdGreyRight><$fontWhite>Fax</FONT></TD>
		    <$tdBeigeLeftColspan2><$font>$rec{'Fax'}</font></TD>
		</tr>|;
	}
} else {
	# fax was blank; check if currency was too and if so skip the whole line.
	if ($rec{'CurrencyName'} ne "") {
		# print currency only, 2 columns
		print qq|
		<tr>
			<$tdGreyRight><$fontWhite>Currency</FONT></TD>
		    <$tdBeigeLeftColspan2><$font>$rec{'CurrencyName'}</font></TD>
		</tr>|;
	} else {
		# skip the line
	}
}
print qq|
<!-- ******************************************************************************-->
<!-- MAXHITS                                                                       -->
<!-- ******************************************************************************-->
<TR>
    <$tdGreyRight><$fontWhite>Hits Per Page</FONT></td>
	<td bgcolor="#ffffcc" colspan=2><$font>$rec{'MaxHits'}</font></TD>
</tr>
<!-- ******************************************************************************-->
<!-- COMMENTS                                                                      -->
<!-- ******************************************************************************-->|;
if ($rec{'Comments'} ne "") {
	print qq|
	<TR>
   		<$tdGreyRight><$fontWhite>Comments</FONT></TD>
   		<TD colspan=2 bgcolor="ffffcc"><$font>$rec{'Comments'}</TD>
	</TR>|;
}
print qq|
<!-- ******************************************************************************-->
<!-- ENTRY DATE                                                                    -->
<!-- ******************************************************************************-->
<TR><TD ALIGN=right bgcolor="white" colspan=3><$font>Inception Date: $rec{'EntryDate'}</FONT></TD></TR>
</TABLE>
|;
}
1;
