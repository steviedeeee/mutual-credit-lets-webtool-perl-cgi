# wtModify.pl

##########################################################
##
##		UPDATE DATABASE WITH MODIFIED RECORD
##
##########################################################
sub updateRecord {
# ----------------------------------------------------------------------------------------------
# This routine does the actual modification of a record. It expects to find in %in a record that
# is already in the database, and will rewrite the database with the new entry. First it checks 
# to make sure that the modified record is ok with validate record. It then goes through the 
# database looking for the right record to modify, if found, it prints out the modified record, 
# and returns the user to a success page. Otherwise the user is returned to an error page with a
# reason why.

my ($status, $line, @lines, @data, $output, $found, $restricted);
	
$status = &validate_record;		# Check to make sure the modifications are ok!

if ($status eq "ok") {
	open (DB, "<$db_file_name") or &cgierr("Error in modify_records: Unable to open DB file.\nReason: $!");
		if ($db_use_flock) { flock(DB, 1); }
		@lines = <DB>;	# Slurp the database into @lines..
	close DB;

	($restricted = 1) if ($auth_modify_own and !$per_admin);

	$found = 0;		# Make sure the record is in here!
	LINE: foreach $line (@lines) {
		if ($line =~ /^$/) { next LINE; }					# Skip and Remove blank lines
		if ($line =~ /^#/) { $output .= $line; next LINE; }	# Comment Line
		chomp ($line);			
		@data     = &split_decode($line);
		($output .= "$line\n" and next LINE) if ($restricted and ($db_userid ne $data[$auth_user_field]));
			
		if ($data[$db_key_pos] eq $in{$db_key}) {
			# If we have userid's and this is not admin, we force the record to keep its own.
			if ($auth_user_field >= 0 and (!$per_admin or !$in{$db_cols[$auth_user_field]})) {
				$in{$db_cols[$auth_user_field]} = $data[$auth_user_field];  
			}
			$output .= &join_encode(%in);			
			$found = 1;								
		} else { 
			$output .= $line . "\n";	# else print regular line. 
		}
	}
	if ($found) {
		open (DB, ">$db_file_name") or &cgierr("Error in modify_records. Unable to open db file.\nReason: $!");
			if ($db_use_flock) {
				flock(DB, 2) or &cgierr("unable to get exclusive lock on 
                $db_file_name.\nReason: $!");
			}
			print DB $output;				
		close DB;		# automatically removes file lock

		# Write log entry: which record was modified (timestamp will be added by the sub)
		&auth_logging("modified record: $in{$db_key}") if ($auth_logging);
		&html_success("Modified");
	} else { 
		&htmlFailure("Modify", "$in{$db_key} (can't find requested record)"); 
	}
} else { 
	&htmlFailure("Modify", $status);	# Validation error: probably required fields missing.
}
}

##########################################################
##
##		MODIFY SELECTED RECORD 
##
##########################################################
sub htmlModify {
# ----------------------------------------------------------------------------------------------
# The user has picked a record to modify and it should appear filled in here stored in %rec. If 
# we can't find the record, the user is sent to the failure sub, html_failure.

my (%rec) = &get_record($in{'modify'});

if (!$in{'modify'}) {
	&htmlFailure("Modify", "unable to find record/no record specified");
	return; 
}

&html_print_headers;
print qq|
<html><head><title>$systemName: Modify a Record.</title></head>

<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<form action="$db_script_url" method="POST">
    <input type=hidden name="db" value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">
    <input type=hidden name="sys" value="$sysID">

    <table align=center border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top>
		<tr>
			<td><$fontLarge>Modify Record</font><br>
				|; &html_record_form (%rec); print qq|
				<br>
				<INPUT TYPE="SUBMIT" NAME="modify_record" VALUE="Modify Record"><INPUT TYPE="RESET" VALUE="Reset Form">
				<br><br>
				|; &html_footer; print qq|
			</td>
		</tr>
	</table>
</form>
</body>
</html>	
|;
}
1;

