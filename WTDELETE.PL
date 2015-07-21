# wtDelete.pl

##########################################################
##
##		DELETE RECORDS
##
##########################################################
sub delete_records {
# ----------------------------------------------------------------------------------------------
# Deletes a single or multiple records. First the routine goes through the form input and makes
# sure there are some records to delete. It then goes through the database deleting each entry 
# and marking it deleted. If there are keys not deleted, an error will be returned saying which
# keys were not found and not deleted, otherwise the user will go to the success page.

my ($key, %delete_list, $rec_to_delete, @lines, $line, @data, $errstr, $succstr, $output, $restricted);
$rec_to_delete = 0;
foreach $key (keys %in) {				# Build a hash of keys to delete.
	if ($in{$key} eq "delete") {
		$delete_list{$key} = 1;
		$rec_to_delete = 1;
	}
}
if (!$rec_to_delete) {
	&htmlFailure("Delete", "no records specified");
	return;
}
open (DB, "<$db_file_name") or &cgierr("Error in delete_records. Unable to open db file.");
	if ($db_use_flock) { flock(DB, 1); }
	@lines = <DB>;
close DB;

($restricted = 1) if ($auth_modify_own and !$per_admin);
	
LINE: foreach $line (@lines) {
	if ($line =~ /^$/) { next LINE; }
	if ($line =~ /^#/) { $output .= $line; next LINE; }
	chomp ($line);			
	@data = &split_decode($line);
	($output .= "$line\n" and next LINE) if ($restricted and ($db_userid ne $data[$auth_user_field]));
		
	$delete_list{$data[$db_key_pos]} ? 			    # if this id is one we want to delete then
		($delete_list{$data[$db_key_pos]} = 0) : 	# mark it deleted and don't print it to the
		($output .= $line . "\n");					# new database, otherwise print it.
}
foreach $key (keys %delete_list) {
	$delete_list{$key} ?				# Check to see if any items weren't deleted that should
		($errstr .= "$key,") :			# have been.
		($succstr .= "$key,"); 			# For logging, we'll remember the one's we deleted.
}
chop($succstr);		# Remove trailing delimiter
chop($errstr);		# Remove trailing delimiter

open (DB, ">$db_file_name") or &cgierr("error in delete_records. unable to open db file: $db_file_name.\nReason: $!");
	if ($db_use_flock) {
		flock(DB, 2) or &cgierr("unable to get exclusive lock on $db_file_name.\nReason: $!");
	}
	print DB $output;
close DB;		# automatically removes file lock			

# Write to log, with key(s) deleted.
&auth_logging("deleted records: $succstr") if ($auth_logging);
$errstr ?								# Do we have an error?
	&htmlFailure("Delete", $errstr) :	# If so go to the failure page, otherwise success page.
	&html_success("Deleted");			# Used to pass $succstr, the record ID's deleted.
}	
1;

