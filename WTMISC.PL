# webtoolMisc.pl  - miscellaneous routines that do not need to be modified, or may not be used 
# (but we'll keep them around, just in case)

#*******************************************
#**
#**  AUTO-SIGNUP 
#**
#*******************************************
sub signup {
# ----------------------------------------------------------------------------------------------
# Note: auto-signup is not used by the webtool. We're assuming LETS admins want to explicitly 
# grant password access to their members. This routine allows a user to sign up without admin 
# approval. Must have $auth_signup = 1 set. The user gets @default_permissions. 

my $message;

# Check to make sure userid is ok, pw ok, and userid is unique.	
	unless ((length($in{'userid'}) >= 3) and (length($in{'userid'}) <= 12) and ($in{'userid'} =~ /^[a-zA-Z0-9]+$/)) {
		$message = "Invalid userid: $in{'userid'}. Must only contain only letters and be less then 12 and greater then 3 characters.";
	}
	unless ((length($in{'pw'}) >= 3) and (length($in{'pw'}) <= 12)) {
		$message = "Invalid pw: '$in{'pw'}'. Must be less then 12 and greater then 3 characters.";
	}
	open (PASS, "<$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
	if ($db_use_flock) { flock(PASS, 1); }
	while (<PASS>) {
		/^\Q$in{'userid'}\E:/ and ($message = "userid already exists. Please try another.");
	}
	close PASS;	
	if ($message) {
		&html_signup_form ($message);
		return;
	}

# Add the userid into the file with default permissions.	
	open (PASS, ">>$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
	if ($db_use_flock) {
		flock(PASS, 2)  or &cgierr("unable to get exclusive lock on $auth_pw_file.\nReason: $!");
	}
	srand( time() ^ ($$ + ($$ << 15)) );	# Seed Random Number
    my @salt_chars  = ('A' .. 'Z', 0 .. 9, 'a' .. 'z', '.', '/');
	my $salt        = join '', @salt_chars[rand 64, rand 64];
	my $encrypted   = crypt($in{'pw'}, $salt);			
	my $permissions = join (":", @auth_signup_permissions);
	
	print PASS "$in{'userid'}:$encrypted:$permissions\n";
	close PASS;
	
	&html_signup_success;
}


#*******************************************
#**
#**  BUILD GENERIC "MATCHING RECORD" HTML
#**
#*******************************************
sub build_html_record {
# --------------------------------------------------------------------------
# Not used by webtool, where all HTML output is custom.

# Builds a record based on the config information. These records get stacked
# on top of each other in a single generic search results page.

	my (%rec) = @_;
	my ($output, $field);
	
	$output = "<p><table border=0 width=500>";
	foreach $field (@db_cols) {
		next if ($db_form_len{$field} == -1);
		$output .= qq~<tr><td align=right valign=top width=20%>
                   <$font>$field:</font></td>
		           <td width=80%><$font>$rec{$field}</font></td></tr>
					~;
	}
	$output .= "</table></p>\n";
	return $output;
}

#*******************************************
#**
#**  BUILD GENERIC HTML FORM
#**
#*******************************************
sub build_html_record_form {
# --------------------------------------------------------------------------
# Not used by webtool, where all HTML output is custom.

# Builds a record form based on the config information. This form is used
# to display a single record for editing or adding to the database.

	my (%rec) = @_;
	my ($output, $field);
	
	$output = "<p><table border=0>";
	foreach $field (@db_cols) {
		if ($db_select_fields{$field}) {      $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_select_field($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_radio_fields{$field}) {    $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_radio_field($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_checkbox_fields{$field}) { $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_checkbox_field ($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_form_len{$field} =~ /(\d+)x(\d+)/) { 
											  $output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><textarea name="$field" cols="$1" rows="$2">$rec{$field}</textarea></td></tr>~; }
		elsif ($db_form_len{$field} == -1) {  $output  = qq~<input type=hidden name="$field" value="$rec{$field}">$output~; }
		elsif ($db_form_len{$field} == -2) {  $per_admin ? ($output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><input type=text name="$field" value="$rec{$field}" maxlength="$db_lengths{$field}"></td></tr>~) :
														   ($output  = qq~<input type=hidden name="$field" value="$rec{$field}">$output~); }
		else  { 							  $output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><input type=text name="$field" value="$rec{$field}" size="$db_form_len{$field}" maxlength="$db_lengths{$field}"></td></tr>~; }
	}
	$output .= "</table></p>\n";
	return $output;
}		

#*******************************************
#**
#**  GET TIME
#**
#*******************************************
sub get_time {
# --------------------------------------------------------------------------
# Returns the time in the format "hh-mm-ss".
#
	my ($sec, $min, $hour, $day, $mon, $year, $dweek, $dyear, $daylight) = localtime(time());
	($sec < 10)  and ($sec = "0$sec");
	($min < 10)  and ($min = "0$min");
	($hour < 10) and ($hour = "0$hour");
	
	return "$hour:$min:$sec";
}

#*******************************************
#**
#**  DATE-TO-UNIX
#**
#*******************************************
sub date_to_unix {
# --------------------------------------------------------------------------
# This routine must take your date format and return the time a la UNIX 
# time(). Some things to be careful about: int your values just in case to 
# remove spaces, etc; catch the fatal error timelocal will generate if you 
# have a bad datE; don't forget that the month is indexed from 0!

    my ($date)   = $_[0]; 
    my (%months) = ("Jan" => 0, "Feb" => 1, "Mar" => 2, "Apr" => 3, "May" => 4, "Jun" => 5, 
                    "Jul" => 6, "Aug" => 7, "Sep" => 8, "Oct" => 9, "Nov" => 10,"Dec" => 11);
	my ($time);
    my ($day, $mon, $year) = split(/-/, $_[0]);
    unless ($day and $mon and $year)  { return undef; }
    unless (defined($months{$mon}))   { return undef; }    

	use Time::Local;
    eval {		
		$day = int($day); $year = int($year) - 1900; 
        $time = timelocal(0,0,0,$day, $months{$mon}, $year);
    };
    if ($@) { return undef; } # Could return 0 if you want.
    return ($time); 
}
1;

