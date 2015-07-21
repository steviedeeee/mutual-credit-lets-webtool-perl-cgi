# wtBuildFields.pl - routines to build drop-down boxes in HTML and checkbox fields

##########################################################
##
##	BUILD LIST OF VALID USERNAMES
##
##########################################################
sub buildUsernameList {
	# Compile drop-down list of valid usernames.
	my ($listName) = $_[0];	 # The name of this drop-down box of valid users, passed in.

	open (PASS, "<$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
	if ($db_use_flock) { flock(PASS, 1); }	
	@lines = <PASS>; close PASS;
	my (@data);
	$user_list = qq~<select name="$listName"><option> </option>~;
	LINE: foreach $line (@lines) {
		$line =~ /^#/ and next LINE; $line =~ /^\s*$/ and next LINE;
		chomp $line;
		@data = split (/:/, $line);
		$thisSys = &getSystemName($data[8]); # Get system name from ID, to write into the list.
		$user_list .= qq~<option value="$data[0]">$data[0] --- $thisSys</option>\n~;	
	}
	$user_list .= "</select>";
	return ($user_list);
}

###############################################
###
###		BUILD SYSTEM LIST
###
###############################################
sub buildSystemList {
# ----------------------------------------------------------------------------------------------
# Builds a drop-down SELECT box of system names and ID's. Called like:
# &buildSystemList("form field name")

	my ($name) = @_;
	my (@fields, $field, @lines, $line, $output);

	open (DB, "<systems.db") or &cgierr("Unable to open systems. Reason: $!");
	if ($db_use_flock) { flock(DB, 1); }

	$output = qq|<SELECT NAME="$name">|;
	LINE: while (<DB>) {		
		next if /^#/; 		# ignore comment lines
		next if /^\s*$/;	# ignore blank lines
		$line = $_;	chomp ($line);
		@fields = &split_decode ($line);	# Build an array of fields.
		$output .= "<OPTION VALUE=$fields[0]>$fields[2]";
	}
	close DB;
	$output .= "</SELECT>";
	return $output;
}

###############################################
###
###    BUILD SELECT FIELD FROM THE DATABASE
###
###############################################
sub build_select_field_from_db {
# ----------------------------------------------------------------------------------------------
# Builds a SELECT field from the database. 

	my ($table, $column, $value, $name) = @_;
	my (@fields, $field, @selectfields, @lines, $line, $output);
	my ($fieldnum, $found, $i) = 0;

	# require "$table.cfg";
	# Default to column name as the SELECT box name, if none was specified. 

	#$name || ($name = $column);	

	open (DB, "<$table.db") or &cgierr("unable to open $table.db. Reason: $!");
	if ($db_use_flock) { flock(DB, 1); }

	$output = qq|<SELECT NAME="$name"><OPTION VALUE="---">--- all ---|;
	LINE: while (<DB>) {		
		next if /^#/; 		# ignore comment lines
		next if /^\s*$/;	# ignore blank lines
		$line = $_;
		chomp ($line);		
		@fields = &split_decode ($line);		# Build an array of fields.

		# Set the text for each drop-down item: different DB tables use different fields
		if ($table eq "systems") {
			$output .= "<OPTION VALUE='$fields[2]'>$fields[2]";
		} elsif ($table eq "cats") {
			$output .= "<OPTION VALUE=$fields[1]>$fields[1]";
		}
	}
	close DB;
	$output .= "</SELECT>";
	return $output;
}

#*******************************************
#**
#**  BUILD SELECT FIELD
#**
#*******************************************
sub build_select_field {
# ----------------------------------------------------------------------------------------------
# Builds a SELECT field based on information found in the database definition. Parameters are 
# the column to build and a default value (optional).

	my ($column, $value) = @_;	
	my (@fields, $output);

	@fields = split (/\,/, $db_select_fields{$column});
	if ($#fields == -1) {
		$output = "No select fields specified in config for field '$column'";
	} else {
		$output = qq|<SELECT NAME="$column"><OPTION>---|;
		foreach $field (@fields) {
			$field eq $value ?
				($output .= "<OPTION SELECTED>$field\n") :
				($output .= "<OPTION>$field");
		}
		$output .= "</SELECT>";
	}
	return $output;
}

#*******************************************
#**
#**  BUILD CHECKBOX FIELD
#**
#*******************************************
sub build_checkbox_field {
# ----------------------------------------------------------------------------------------------
# Builds a CHECKBOX field based on information found in the database definition. Parameters are 
# the column to build whether it should be checked or not and a default value (optional).

	my ($column, $values) = @_;

	if (!$db_checkbox_fields{$column}) {
		return "error building checkboxes: no checkboxes specified in config for field '$column'";
	}	
	
	my @names  = split (/,/, $db_checkbox_fields{$column});
	my @values = split (/\Q$db_delim\E/, $values);
	my ($name, $output);	

	foreach $name (@names) {
		(grep $_ eq $name, @values) ?
			($output .= qq!<INPUT TYPE="CHECKBOX" NAME="$column" VALUE="$name" CHECKED> $name\n!) :
			($output .= qq!<INPUT TYPE="CHECKBOX" NAME="$column" VALUE="$name"> $name\n!);
	}
	return $output;
}

#*******************************************
#**
#**  BUILD RADIO FIELD
#**
#*******************************************
sub build_radio_field {
# ----------------------------------------------------------------------------------------------
# Builds a RADIO Button field based on information found in the database definition. Parameters 
# are the column to build and a default value (optional).

	my ($column, $value) = @_;
	my (@buttons, $button, $output);

	@buttons = split (/,/, $db_radio_fields{$column});
	if ($#buttons == -1) {
		$output = "error building radio buttons: no radio fields specified in config for field '$column'!";
	}
	else {
		foreach $button (@buttons) {
			$value =~ /^\Q$button\E$/ ?
				($output .= qq|<INPUT TYPE="RADIO" NAME="$column" VALUE="$button" CHECKED> $button \n|) :
				($output .= qq|<INPUT TYPE="RADIO" NAME="$column" VALUE="$button"> $button \n|);
		}
	}	
	return $output;
}
1;
