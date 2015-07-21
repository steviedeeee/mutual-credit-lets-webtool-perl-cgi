# wtAdd.pl

##########################################################
##
##		ADD RECORD INPUT SCREEN
##
##########################################################
sub html_add_form {
# ----------------------------------------------------------------------------------------------
# The add form page where the user fills out all the details on the new record he/she would like
# to add. 

&html_print_headers;
print qq|

<html><head><title>$systemName: Add a $html_title</title></head>
<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<form action="$db_script_url" method="POST">
    <input type=hidden name="db" value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">
    <input type=hidden name="sys" value="$sysID">
    <table border=1 align=center bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top>
    	<tr>
        	<td align=left>
	        	<$fontLarge>Add a $html_title</FONT><br>|;
				if ($html_title eq 'Trading System') {
					# Add a blurb clarifying what we're doing here: adding a new LETS
					print qq|
					<$font>
					Add a new LETS or trading system to the group. Any of their members will be 
					able to search the Ad Directory Listings in other LETS that are already 
					in the database.<br>
					</font>|;
				}
				print qq|
	    	    <$font>|; &html_record_form (&get_defaults); print qq| </font>
				<br>
   	    	    	<center><INPUT TYPE="SUBMIT" NAME="add_record" VALUE="Add Record"><INPUT TYPE="RESET" VALUE="Reset"></center>
				<br>
				|; &html_footer; print qq|
			</td>
    	</tr>
	</table>
</form>
</body>
</html>	
|;
}

##########################################################
##
##		UPDATE DATABASE WITH RECORD ADDED
##
##########################################################
sub add_record {
# ----------------------------------------------------------------------------------------------
# Adds a record to the database. First, validate_record is called to make sure the record is ok
# to add. If it is, then the record is encoded and added to the database and the user is sent to
# html_add_success, otherwise the user is sent to html_add_failure with an error message 
# explaining why. The counter file is also updated to the next number. If the database table in 
# use is systems.db, the user is adding a LETS to the intertrading group: check that username 
# chosen is unique.

	my ($output, $status, $counter);

	# Set the userid to the logged in user.
	($auth_user_field >= 0) and ($in{$db_cols[$auth_user_field]} = $db_userid);
	
	# First we validate the record to make sure the addition is ok.	
	$status = &validate_record;

	# We keep checking for the next available key, or until we've tried 50 times
	# after which we give up.
	while ($status eq "duplicate key error" and $db_key_track) {
		return "duplicate key error" if ($counter++ > 50);
		$in{$db_key}++;
		$status = &validate_record;
	}
	if ($status eq "ok") {
		open (DB, ">>$db_file_name") or &cgierr("Error in add_record: unable to open database.\nReason: $!");
		if ($db_use_flock) { flock(DB, 2)  or &cgierr("Unable to get exclusive lock.\nReason: $!"); }
		print DB &join_encode(%in);	
		close DB;						# automatically removes file lock
		if ($db_key_track) {
			open (ID, ">$db_id_file_name") or &cgierr("Error in get_defaults. Unable to open id file.\nReason: $!");
			if ($db_use_flock) { flock(ID, 2)  or &cgierr("Unable to get exclusive lock.\nReason: $!");	}
			print ID $in{$db_key};		# update counter.
 			close ID;					# automatically removes file lock
		}
		my $duplicateLogin = 0;			# In case we're adding a new trading system, flag any
										# duplicate login and don't add the new system record.

		# Check if this is a trading system being added, and create their admin login.
		if ($html_title eq 'Trading System') {
			open (PASS, "<$auth_pw_file") or &cgierr("wtAdd: unable to open database.\nReason: $!");
			if ($db_use_flock) { flock(PASS, 1); }				
			@lines = <PASS>;
			close PASS;
			open (PASS, ">>$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
			if ($db_use_flock) {
				flock(PASS, 2)  or &cgierr("Unable to get exclusive lock on password file.\nReason: $!");
			}
			foreach $line (@lines) {
				if ($line =~ /^$in{'LoginName'}:/) {
					# That login is already taken!
					$message = "User ID $in{'LoginName'} already exists: please try again.";
					$duplicateLogin = 1;
				}
			}
			if ($duplicateLogin) {
				&htmlFailure("Add", $message);		# Send back 'add record failed' page.
			} else {
				# New admin login is OK: write it to the password file.
				print PASS "$in{'LoginName'}:$in{'Password'}:1:1:1:1:1:$in{'Email'}:$in{$db_key}\n";
				&auth_logging("added record: $in{$db_key}") if ($auth_logging);
				&html_success("Added");
			}
			close PASS;
		} else {
			# We're not adding a new trading system so there's no need to check for duplicate
			# login. Since everything looked OK we just add the record.
			&auth_logging("added record: $in{$db_key}") if ($auth_logging);
			&html_success("Added");
		}
	} else {
		&htmlFailure("Add", $status);
	}
}
1;
