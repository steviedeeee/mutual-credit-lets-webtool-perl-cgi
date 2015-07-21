#  tradesHTML.pl

$html_title  = 'Transaction';
##########################################################
##
##		TRANSACTION MENU
##
##########################################################
sub html_footer {
# ----------------------------------------------------------------------------------------------
# Print the menu: We only print options that the user has permissions for.

print qq! <$inner2Table> !;
print qq! <TR>!;
print qq! <TD BGCOLOR="#ffffcc" align=left><$font><b>Transactions:</b></font></TD>!; 
print qq! <TD BGCOLOR="#000000"><$font><FONT COLOR="#FFFFFF">&nbsp;<A HREF="$db_script_link_url&view_search=1">Search</A> !  if ($per_view);
print qq!| <A HREF="$db_script_link_url&add_form=1">Add</A> !	        if ($per_add);

# Only allow Delete and Modify if the user is admin.
print qq!| <A HREF="$db_script_link_url&delete_search=1">Delete</A> !	if ($per_admin);
print qq!| <A HREF="$db_script_link_url&modify_search=1">Modify</A> !	if ($per_admin);
print qq!| <A HREF="$db_script_link_url&view_records=1&$db_key=*">List All</A> ! if ($per_view);
print qq!| <A HREF="$db_script_link_url&logoff=1">Log Off</A> !;
print qq!| <A HREF="$helpURL">Help</A>&nbsp;</font></font></TD></TR> !;

# Options to switch to other database tables. Some are available only to admins.
print qq!
<TR>
	<TD colspan=2 BGCOLOR="#009900">
		<$fontWhite>
			<A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid">Ad Directory</A> !;
			if ($per_admin) {
				print qq! 
				| <A HREF="$db_script_url?db=cats&sys=$sysID&uid=$db_uid">Categories</A>
				| <A HREF="$db_script_url?db=trades&sys=$sysID&admin_display=1&uid=$db_uid">Members</A>
				| <A HREF="$db_script_url?db=systems&sys=$sysID&uid=$db_uid">Trading Systems</A>&nbsp;
				| <A HREF="$db_script_url?db=ads&sys=$sysID&uid=$db_uid&download=1">Download System Data</A>&nbsp;
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
##		TRANSACTION DISPLAY RECORD TEMPLATE
##
##########################################################
sub html_record {
# ----------------------------------------------------------------------------------------------
# How a record will be displayed when returned in search results. The record will be in the 
# %rec hash.

my (%rec) = @_;		# Load any defaults to put in the VALUE fields.
	
print qq|
<TABLE WIDTH="620" CELLPADDING=3 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc">
	<TR><TD COLSPAN="3" bgcolor=white><$font>$rec{'Entry_Date'}</font></TD></TR>
	<TR>
		<td bgcolor="#999999" align=right width="30%"><$fontWhite>Member</font></td>
		<td bgcolor="#ffffcc" width="50%">
			<$font>$rec{'Member_ID'} pays $rec{'Member2_ID'}</font>
		</td>
		<td bgcolor="#ffffcc" align=right width="20%">
			|; $rec{'Amount'} = sprintf ("%.2f", $rec{'Amount'}); print qq|
			<$font><b>$rec{'Amount'}</b></font>
		</td>
	</TR>|;
	if ($rec{'Descrip'} ne '') {
		print qq|
		<TR>
			<td bgcolor="#999999" align=right width="30%"><$fontWhite>For</font></TD>
			<$tdBeigeLeftColspan2><$font>$rec{'Descrip'}&nbsp;</font></TD>
		</TR>|;
	}
	print qq|
	<TR>
		<td bgcolor="#999999" align=right width="30%"><$fontWhite>Submitted From</font></TD>
		<$tdBeigeLeftColspan2><$font>$rec{'Remote_Host'} $rec{'Remote_Addr'}&nbsp;</font></TD>
	</TR>
</TABLE>
</BODY></HTML>
|;
}

##########################################################
##
##	TRANSACTION ADD / MODIFY LAYOUT
##
##########################################################
sub html_record_form {
# ----------------------------------------------------------------------------------------------
# The form fields that will be displayed each time a record is edited or created. You don't 
# want to put the <FORM> and </FORM tags, merely the <INPUT> tags for each field. The values
# to be displayed are in %rec and should be incorporated into your form. You can use 
# &build_select_field, &build_checkbox_field and &build_radio_field to generate the 
# respective input boxes. Text and Textarea inputs can be inserted as is. 

my (%rec) = @_;
$rec{'Remote_Host'} = $ENV{'REMOTE_HOST'};
$rec{'Remote_Addr'} = $ENV{'REMOTE_ADDR'};

$sysName = &getSystemName($sysID);

if ($per_admin) {
	print qq|
	<$font>
	Enter the usernames (ie. login names) of the trading members, their LETS, the amount and 
	description of the trade.<br>&nbsp;
	</font>|;
} else {
	print qq|
	<$font>
	Enter the username (ie. login name) of the member you'd like to pay for goods or services, 
	the name of a LETS they belong to, and the amount and description of the trade.<br>&nbsp;
	</font>|;
}
print qq|
<br>
<TABLE WIDTH="620" align=center CELLPADDING=3 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc">
<INPUT TYPE="HIDDEN" NAME="Transact_ID" VALUE="$rec{'Transact_ID'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="Entry_Date" VALUE="$rec{'Entry_Date'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="Remote_Host" VALUE="$rec{'Remote_Host'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="Remote_Addr" VALUE="$rec{'Remote_Addr'}" SIZE="3" MAXLENGTH="3">
<INPUT TYPE="HIDDEN" NAME="enteredBy" VALUE="$db_userid" SIZE="3" MAXLENGTH="3">

<TR><TD COLSPAN="3" bgcolor=white><$font>$rec{'Entry_Date'}</font></TD></TR>
<TR>
	<td bgcolor="#999999" align=right width="12%"><$fontWhite>Member</font></td>
	<td bgcolor="#ffffcc">
		<$font>|;
		if ($per_admin) {
			# This is an Admin, so they can specify any two parties to a transaction, and enter
			# them on both parties' behalf.
			$userList = &buildUsernameList("Member_ID");
			print qq| $userList |;
		} else {
			# Don't let a normal member transfer funds out of someone else's account: they can
			# only pay someone, out of their own account. Later you may want to make this an
			# admin-settable option (ie. trust members to submit a trade paying themselves).
			print qq|
			<INPUT TYPE="HIDDEN" NAME="Member_ID" VALUE="$db_userid" SIZE="3" MAXLENGTH="60">
			<b>$db_userid</b> of $sysName|;
		}
		print qq|
		</font>
	</td>
</tr>
<tr>
	<td bgcolor="#999999" align=right width="12%"><$fontWhite><b>Pays</b> Member</font></td>
	<td bgcolor="#ffffcc">
		<$font>|;
			$userList2 = &buildUsernameList("Member2_ID");
			print qq| $userList2
		</font>
	</td>
</tr>
<tr>
	<td bgcolor="#999999" align=right width="12%"><$fontWhite>Amount</font></td>
	<$tdBeigeLeft>
		<INPUT TYPE="TEXT" NAME="Amount" VALUE="$rec{'Amount'}" SIZE="12" MAXLENGTH="30">
	</td>
</TR>
<TR>
	<td bgcolor="#999999" align=right width="20%"><$fontWhite>For</font></TD>
	<$tdBeigeLeft>
		<INPUT TYPE="TEXT" NAME="Descrip" VALUE="$rec{'Descrip'}" SIZE="60" MAXLENGTH="500">
	</td>
</TR>
<tr>
	<td bgcolor="#999999" align=right><$fontWhite>Submitted Via</font></td>
	<$tdBeigeLeft><$font>$rec{'Remote_Host'} $rec{'Remote_Addr'}</font></td>
</tr>
</TABLE>
<br>
</BODY>
</HTML>
|;
}

############################################################################## 
##
##  	TRANSACTION SEARCH LAYOUT
## 
##############################################################################
sub html_search_options {
# ----------------------------------------------------------------------------------------------
my (%rec) = @_;

print qq|
<TABLE WIDTH=620 CELLPADDING=3 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc">
	<INPUT TYPE="HIDDEN" NAME="Transact_ID" VALUE="$rec{'Transact_ID'}" SIZE="3" MAXLENGTH="3">
	<INPUT TYPE="HIDDEN" NAME="Remote_Host" VALUE="$rec{'Remote_Host'}" SIZE="3" MAXLENGTH="3">
	<INPUT TYPE="HIDDEN" NAME="Remote_Addr" VALUE="$rec{'Remote_Addr'}" SIZE="3" MAXLENGTH="3">
	<TR>
		<td bgcolor="#999999" width="22%" align=right><$fontWhite>Date</font></TD>
    	<$tdBeigeLeftColspan2>
			<$font>
				<INPUT TYPE="TEXT" NAME="Entry_Date" VALUE="$rec{'Entry_Date'}" SIZE="10" MAXLENGTH="30">
				ie. '02-Jun-2000'
			</font>
		</TD>
	</TR>
	<TR>
		<$tdGreyRight><$fontWhite>Buyer's Member ID</font></TD>
		<$tdBeigeLeft>|;
			$userList = &buildUsernameList("Member_ID");
			print qq| $userList
		</td>
	</tr>
	<TR>
		<$tdGreyRight><$fontWhite>Seller's Member ID</font></TD>
		<$tdBeigeLeft>|;
			$userList2 = &buildUsernameList("Member2_ID");
			print qq| $userList2
		</td>
	</tr>
	<tr>
		<$tdGreyRight><$fontWhite>Amount</font></td>
		<$tdBeigeLeft>
			<$font>
			<INPUT TYPE="TEXT" NAME="Amount" VALUE="$rec{'Amount'}" SIZE="10" MAXLENGTH="30">
			&nbsp;For: <INPUT TYPE="TEXT" NAME="Descrip" VALUE="$rec{'Descrip'}" SIZE="48" MAXLENGTH="30">
			</font>
		</TD>
	</TR>
</TABLE>
</BODY>
</HTML>
|;
}
1;
