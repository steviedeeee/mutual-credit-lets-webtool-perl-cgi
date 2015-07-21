# catsHTML.pl

##########################################################
##
##		CATEGORY MENU
##
##########################################################
sub html_footer {
# ----------------------------------------------------------------------------------------------
# Print the menu: We only print options that the user has permissions for.

print qq! <$inner2Table> !;
print qq! <TR>!;
print qq! <TD BGCOLOR="#ffffcc" align=left><$font><b>Ad Categories:</b></font></TD>!; 
print qq! <TD BGCOLOR="#000000"><$font><FONT COLOR="#FFFFFF">&nbsp;<A HREF="$db_script_link_url&view_search=1">Search</A> !  if ($per_view);
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
			<A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid">Ad Directory</A> |
			<A HREF="$db_script_url?db=trades&sys=$sysID&uid=$db_uid">Transactions</A> !;
			if ($per_admin) {
				print qq! 
				| <A HREF="$db_script_url?db=cats&sys=$sysID&uid=$db_uid&admin_display=1">Members</A>
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
##  	CATEGORY KEYWORD SEARCH LAYOUT
## 
######################################################################
sub html_search_options {
# ----------------------------------------------------------------------------------------------
# Arrangement of keyword fields / how the category search appears.

my (%rec) = @_;

print qq|
<TABLE WIDTH="620" CELLPADDING=0 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" align=center>
	<!-- ******************************************************************************-->
	<!-- CURRENCY SYSTEM                                                               -->
	<!-- ******************************************************************************-->
	<TR>
    	<$tdGreyRight><$fontWhite>Category Name&nbsp;</FONT></td>
    	<$tdBeigeLeftColspan2>
        	<INPUT TYPE="TEXT" NAME="CatName" VALUE="$rec{'CatName'}" SIZE="40" MAXLENGTH="40">
    	</td>
	</TR>
</table>
|;
}

##########################################################
##
##		ADD / MODIFY CATEGORY LAYOUT 
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

print qq|
<br>
<TABLE WIDTH="620" CELLPADDING=0 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" align=center>
<INPUT TYPE="HIDDEN" NAME="ID" VALUE="$rec{'ID'}" SIZE="3" MAXLENGTH="3">

<!-- ******************************************************************************-->
<!-- CATEGORY NAME                  											   -->
<!-- ******************************************************************************-->
<TR>
   	<$tdGreyRight><$fontWhite>Category Name&nbsp;</FONT></td>
   	<$tdBeigeLeftColspan2>
       	<INPUT TYPE="TEXT" NAME="CatName" VALUE="$rec{'CatName'}" SIZE="40" MAXLENGTH="40">
   	</td>
</TR>
</TABLE>
|;
}

##########################################################
##
##    DISPLAY RECORD TEMPLATE FOR CATEGORIES
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
	<TR>
    	<$tdGreyRight><$fontWhite>Category</FONT></TD>
	    <$tdBeigeLeft><B><$font>$rec{'CatName'}</FONT></B></TD>
	</TR>
</TABLE>
|;
}
1;
