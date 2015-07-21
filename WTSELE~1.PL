# wtSelectRecord.pl

##########################################################
##
##		SELECT RECORD TO MODIFY / DELETE
##
##########################################################
sub htmlSelectRecord {
# ----------------------------------------------------------------------------------------------
# The user has searched the database and is ready to modify/delete one from the records re-
# turned. This page should produce a radio button with name=modify value=ID for each record, if
# we're modifying, and checkboxes if deleting (deletion allows multiple records to be selected.
# Other than that the script is the same for both operations, except for the Submit buttons,
# which redirect the script to two different subs, and for the screen text. We have to do a 
# little work to convert the array @hits that contains the search results to a hash for printing.

my (%tmp);
my ($status, @hits) = &query("mod");
my ($numhits) = ($#hits+1) / ($#db_cols+1);
my ($maxhits); $in{'mh'} ? ($maxhits = $in{'mh'}) : ($maxhits = $db_max_hits);

if ($in{'modify_form'}) {
	# We're selecting a record to modify.
	$operation   = "Modify";
	$submitName  = "modify_form_record";
	$submitValue = "Modify Record";

	if (($numhits == 1) and !$in{'nh'}) { 
		$in{'modify'} = $hits[$db_key_pos];
		&htmlModify();
		return;
	}
} else {
	# We're selecting record(s) to delete.
	$operation   = "Delete";
	$submitName  = "delete_records";
	$submitValue = "Delete Checked Record(s)";
}

&html_print_headers;
print qq|
<html><head><title>$systemName: $operation $html_title</title></head>

<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
|;
if ($status ne "ok") {	# Error searching database!
	# There was a problem: bypass display of matching records and return them to the search 
	# screen, with an error message.
	&searchFailure($operation, $status);
	return;
} else {
	print qq|
	<form action="$db_script_url" METHOD="POST">
    	<input type=hidden name="db" value="$db_setup">
    	<input type=hidden name="uid" value="$db_uid">
	    <input type=hidden name="sys" value="$sysID">

		|;
	    # Go through each hit and convert the array to hash and send to html_record for 
		# printing. Also add a radio button with name=modify and value=key.

		print "<P>";
		$recShown = 0;	# Used to check for 1st/last records, in which case we insert menu.

		for (0 .. $numhits - 1) {
			$recShown++;
	    	%tmp = &array_to_hash($_, @hits);
		    print qq|
		    <TABLE BORDER=0 align=center>|;
			if ($recShown == 1) {
				# Insert page top and menu before first record.
				print qq|
				<tr><td>&nbsp;</td><td><$fontLarge>$operation $html_title</font></td></tr>
				<tr>
					<td>&nbsp;</td>
					<td>						
				    	<$font>
						    Check which record you wish to $operation and press <b>$submitValue.</b>
							<br>Your search returned <b>$db_total_hits</b> matches.<br>&nbsp;
						</font>
					</td>
				</tr>|;
				# Check for multiple pages of matching records, and show page links.
		    	if ($db_next_hits) {
					print qq|
					<tr><td>&nbsp;</td><td><$font>Pages: $db_next_hits</font></td></tr>|;
				}
				if ($numhits > 1) {
					print qq|
					<tr><td>&nbsp;</td><td>|; &html_footer; print qq|</td></tr>
					<tr>
						<td>&nbsp;</td>
						<td><input type="SUBMIT" name="$submitName" value="$submitValue"><INPUT TYPE="RESET" VALUE="Reset"></td>
					</tr>|;
				}
			} # Endif check for 1st record, and printing page title and header.
			# Now print the radio buttons / checkboxes, paired with matching records.
			print qq|
			<TR>|;
				if ($operation eq "Modify") {
					# Provide radio buttons: user can modify one record only.
					print qq|
					<TD><INPUT TYPE=RADIO NAME="modify" VALUE="$tmp{$db_key}"></TD>|;
				} else {
					# Provide checkboxes: user can delete multiple records.
					print qq|
					<TD><INPUT TYPE=CHECKBOX NAME="$tmp{$db_key}" VALUE="delete"></TD>|;
				}
				# Now print the actual record, in the next column.
				print qq|
		    	<TD>|; &html_record (%tmp);	print qq|</TD>
			</TR>|;
		}
		# Repeat the multiple page links at this page bottom.
		if ($db_next_hits) {
			print qq|
			<tr><td>&nbsp;</td><td><br><$font>Pages: $db_next_hits</font></td></tr>|;
		}
	    print qq|
		<tr>
			<td>&nbsp;</td>
			<td>
				<INPUT TYPE="SUBMIT" name="$submitName" value="$submitValue"><INPUT TYPE="RESET" VALUE="Reset">
			</td>
		</tr>
		<tr><td>&nbsp;</td><td>|; &html_footer; print qq|</td></tr>
	    </table>
	</form>
</body>
</html>
|;
}
}
1;
