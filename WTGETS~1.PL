# wtGetSystemName.pl

##########################################################
##
##    GET SYSTEM NAME
##
##########################################################
# Returns the current system name associated with a system ID. Since only system ID's are stored
# when ads and trades are created, you'll have to call this routine whenever they're displayed,
# and you want to tell the user which system they were submitted within.

sub getSystemName {
	my ($sysID) = @_;	# grab the incoming system ID.

	# Open systems.db and find the matching name for the system ID passed in.
	open (SYSTEMS, "<systems.db") or &cgierr ("Unable to open systems file.\nReason: $!");
	if ($db_use_flock) { flock(SYSTEMS,1); }
	my ($found) = 0;
    my ($sysName) = "";
	LINE: while (<SYSTEMS>) {		
		next if /^#/; 		# ignore comment lines
		next if /^\s*$/;	# ignore blank lines
		$line = $_;	chomp ($line);		
		@fields = &split_decode ($line);	# Build an array of fields.
		if ($line =~ /$sysID/) { $sysName = $fields[2]; $found = 1;	}
	}
	close SYSTEMS;
	if (!$found) { $sysName = "Demo" };
	return $sysName;
}
1;
