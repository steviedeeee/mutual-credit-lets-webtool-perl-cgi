#!c:\Perl\bin\perl.exe

$version = "2.11.23.2000";
$db_debug = 0;				# debug info on (1) or off (0)

# ----------------------------------------------------------------------------------------------
# WINDOWS SETTINGS
# ----------------------------------------------------------------------------------------------
$db_use_flock = 0;	# Win95/98 doesn't support file-locking.
$db_dir_url = "http://localhost/cgi-bin/newWebtool";
#!c:\Perl\bin\perl.exe	# path to Perl; must be first line in this script.
# ----------------------------------------------------------------------------------------------
# UNIX 
# ----------------------------------------------------------------------------------------------
# $db_use_flock = 1;
# $db_dir_url = "http://skyport.com/cheesemelt/lets";
#!/usr/bin/perl 
# ----------------------------------------------------------------------------------------------
# SOME IMPORTANT VARIABLES
# ----------------------------------------------------------------------------------------------
# $db_userid   	 = The login name; ie. 'admin' or 'VicLETS305'
# $db_file_name  = Current filename of database in use, with relative path & extension.

$db_script_url 	 = $db_dir_url . "/webtool.cgi";			# URL of the main CGI script.
$db_script_path  = ".";					# Set to full directory path if you have problems.
$db_data_path 	 = $db_script_path; 	# Now deprecated but leave it in, just in case.

# The following paths refer to the password file, counter file, and the directory where valid
# user session ID's are stored. For the default installation, the names of these files are 
# listed below. For better security, however, you may want to rename these files (also change 
# the filenames listed below).

$db_id_file_name = $db_script_path . "/default.count"; 		# path to the counter file.
$auth_dir 		 = $db_script_path . "/userSession";		# path to the valid session ID's.
$auth_pw_file 	 = $db_script_path . "/permissions.def"; 	# path to the password file.


# ----------------------------------------------------------------------------------------------
#
# WEBTOOL.CGI: the main script.
#
# This script parses all form data submitted by the user from any screen, loads the appropriate
# database table, and sets some global GET params and user permissions to be passed from script
# to script in an unbroken chain. Every screen link calls this script, which performs authenti-
# cation at each click by matching the sessionID passed into this script with the valid one 
# created when the user first logged in. SessionID's are stored in the userSession directory, 
# and expire after the interval defined below:

$auth_time = 21600;		# 6 hours (in seconds) before userSession expires and file deleted.

################################################################################################
# ----------------------------------------------------------------------------------------------
local(%in) = &parse_form; 	# Load form data: extracts the last data submitted by the user, from
							# the various screens in the software. If the user's logging on, the
							# system ID will be one of the inputs, passed forward as a GET param 
							# with every link. If the data string is missing at Logon, the 
							# software reverts to the demo data for the rest of the session.

################################################################################################
# ----------------------------------------------------------------------------------------------
# DIRECTORIES AND PATHS
# ----------------------------------------------------------------------------------------------
# Pass the session ID in, otherwise the user's logging in.
$in{'uid'} ? ($db_uid = $in{'uid'}) : ($db_uid = '');

# Pass the current working DB in, or open ads.db if none.
$in{'db'} ? ($db_setup = $in{'db'}) : ($db_setup = 'ads');

# Pass the current system in, otherwise default to Demo.
$in{'sys'} ? ($sysID = $in{'sys'}) : ($sysID = '-1');		# Pass the system code on.

&constants;				# Hard-wired settings that won't change for a production setting.
$auth_logoff = "";		# URL to send user if they chose log off. Leave blank and the 
						# script will return to the logon prompt.
# ----------------------------------------------------------------------------------------------
# REQUIRED LIBRARIES
# ----------------------------------------------------------------------------------------------
# Make sure we're using perl 5, and load the DB config file and various task libraries.
eval {
	# line below puts $db_script_path as the first directory to search for Perl scripts
	unshift (@INC, $db_script_path);
	require 5.003;					# We need at least Perl 5.003

	# =~ is used to test left side against the  right. ^means match from beginning of the line,
	# [] matches a set of characters; $ in this case means end of line:

	unless ($db_setup =~ /^[A-Za-z0-9]+$/) { die "Invalid config file name: $db_setup"; }

	require "wtCommonHTML.pl";	 	# look-and-feel constants: fonts, colors, table rows, etc.
	require "wtAdmin.pl";			# admin routines for managing logins and permissions
	require "wtDownload.pl";		# routine for preparing data for Admin download
	require "wtQuery.pl";			# the search engine
	require "wtDelete.pl";			# delete search HTML
	require "wtModify.pl";			# modify search HTML
	require "wtSearch.pl";			# regular search HTML
	require "wtMisc.pl";			# miscellaneous routines not used much 
    require "wtAdd.pl";   			# routine for adding records to one of the DB files
	require "wtBuildFields.pl"; 	# routines to build select fields and checkbox fields
	require "wtSortOptions.pl";		# standard drop-down options for sorting search ouput
	require "$db_setup.cfg";		# whichever DB definition file is currently being used
	require "wtAuth.pl";			# routines for setting up a user session and logging on
	require "wtSuccessFailure.pl";  # HTML output: success or failure of search/add/delete/mod
	require "wtSelectRecord.pl";   	# HTML output: select for modify/delete from search results
	require "wtGetSystemName.pl";	# brief function to return system name when given its ID
	require "wtLogon.pl";			# Logon screens, before and after. Note that most installs
									# will come in from a static index.htm page that simply
									# contains the login form, rather than from the script-
									# generated form provided here.
};

if ($@) { &cgierr ("Error loading required libraries.\nCheck that they exist, permissions are set correctly and that they compile.\nReason: $@"); }

eval { &main; };	#  Trap any fatal errors so we never produce that nasty 500 server error.
if ($@) { &cgierr("fatal error: $@"); }

&cgierr("Debug Information") if ($db_debug); #  Display debugging information if requested.
exit; 	# There are only two exit calls in the script, here and in &cgierr. 

############################################
##
##	  SUB MAIN
##
############################################
sub main {
# ----------------------------------------------------------------------------------------------
my ($status, $uid);
local($per_add, $per_view, $per_mod, $per_del, $per_admin);

# Later, include MaxHits as a GET param, drawn from the system's record in systems.db.
$db_max_hits = 20;		# default maximum number of hits returned in a search.

$|++;		# Flush Output Right Away
&auth_cleanup unless ($auth_no_authentication);	 # Remove old session files.

# Authenticate User, get permissions and userid.
($status, $uid, $per_view, $per_add, $per_del, $per_mod, $per_admin) = &auth_check_password;

if ($status eq "ok") {

    $db_script_link_url = "$db_script_url?db=$db_setup&sys=$sysID&uid=$db_uid";

    if ($uid eq "default") { $db_userid = $uid; }
    else { ($db_userid) = $db_uid =~ /([A-Za-z0-9]+)\.\d+/; }		
					
    # Main Menu. Check to see what the user requested, and if they have permission for that 
	# request, do it. Otherwise send the user off to an unauthorized request page.

    if    ($in{'add_form'}) 		  { if ($per_add)   { &html_add_form; }	   else { &html_unauth; } }
    elsif ($in{'add_record'})      	  { if ($per_add)   { &add_record; } 	   else { &html_unauth; } }
    elsif ($in{'view_search'})     	  { if ($per_view)  { &html_search; }      else { &html_unauth; } }
    elsif ($in{'view_records'})    	  { if ($per_view)  { &view_records; } 	   else { &html_unauth; } }
    elsif ($in{'delete_search'})   	  { if ($per_del)   { &html_search; } 	   else { &html_unauth; } }
    elsif ($in{'delete_form'})     	  { if ($per_del)   { &htmlSelectRecord; } else { &html_unauth; } }
    elsif ($in{'delete_records'})  	  { if ($per_del)   { &delete_records; }   else { &html_unauth; } }
    elsif ($in{'modify_search'})   	  { if ($per_mod)   { &html_search; } 	   else { &html_unauth; } }
    elsif ($in{'modify_form'})     	  { if ($per_mod)   { &htmlSelectRecord; } else { &html_unauth; } }
    elsif ($in{'modify_form_record'}) { if ($per_mod)   { &htmlModify; } 	   else { &html_unauth; } }
    elsif ($in{'modify_record'})   	  { if ($per_mod)   { &updateRecord;  }    else { &html_unauth; } }
    elsif ($in{'admin_display'})   	  { if ($per_admin) { &admin_display; }    else { &html_unauth; } }
    elsif ($in{'download'})		   	  { if ($per_admin) { &download; }		   else { &html_unauth; } }
    elsif ($in{'compileAds'})		  { if ($per_admin) { &compileAds; }	   else { &html_unauth; } }
    elsif ($in{'logoff'}) { &auth_logging('logged off') if ($auth_logging);
	    $auth_logoff ? (print "Location: $auth_logoff\n\n") : (print "Location: $db_script_url\n\n"); 
	}
    elsif ((keys(%in) <= 3) || ($in{'login'})) { &html_home; }
    else  { &html_unkown_action; }		
}
    # If we allow users to signup, and they want to, go to the signup form.	
    elsif ($auth_signup and $in{'signup_form'}) 	{ &html_signup_form; }
    elsif ($auth_signup and $in{'signup'})	 		{ &signup; }

    # Auth Check Password has determined that the user has not logged in, so let's send
    # them to the login screen.

    elsif ($status eq "no login") { &html_login_form; }

    # Error trying to authenticate the user. Probably there was an invalid user/password or the
	# user file has expired. Let's go to an error page and ask the user to re-log on.
	else { &html_login_failure($status); }
}

############################################
##
##		CONSTANTS
##
############################################
sub constants {
	#  The following constants don't change for a production environment.
	#  -----------------------------------------------------------------------------------------
	$auth_signup = 0;							# no auto-signup: admin must assign password
	@auth_signup_permissions = (1,1,1,1,0);		# default permissions a self-signup would get
	$db_key_track = 1;			# use counter/key file for next available key
	$db_delim = '|'; 			# database delimiter.
	$db_auto_generate = 0; 		# don't auto-generate the HTML.
	# use Benchmark;       		# uncomment this line if benchmarking is used.
	$db_benchmark = 0;			# don't benchmark
	$auth_logging = 1;			# enable logging
	$db_bold = 1;				# bold search results
	# I maintain and update a central User Manual at the following URL. 
	$helpURL = "http://lentils.imagineis.com/webtool/help.htm";
	$auth_no_authentication = 0;	# Here zero means "there is authentication"
	$auth_allow_default = 0;		# no default user (everyone must logon)
	@auth_default_permissions = (1,1,1,1,0); 	# permissions a default user would get
}

############################################
##
##		GET RECORD
##
############################################
sub get_record {
# ----------------------------------------------------------------------------------------------
# Given an ID as input, returns a hash of the requested record or undefined if not found.

	my ($key, $found, $line, @data, $field, $restricted);
	$key = $_[0];	
	$found = 0;
	($restricted = 1) if ($auth_modify_own and !$per_admin);

	open (DB, "<$db_file_name") or &cgierr("Error in get_records: unable to open database.\nReason: $!");
	if ($db_use_flock) { flock(DB, 1); }	
	LINE: while (<DB>) {
		(/^#/)      and next LINE;
		(/^\s*$/)   and next LINE;
		$line = $_;	chomp ($line);		
		@data = &split_decode($line);
		next LINE if ($restricted and ($db_userid ne $data[$auth_user_field]));
		if ($data[$db_key_pos] eq $key) {
			$found = 1;
			for ($i = 0; $i <= $#db_cols; $i++) {  # Map the array columns to a hash.
				$rec{$db_cols[$i]} = $data[$i];
			}
			last LINE;
		}
	}
	close DB;	
	$found ? (return %rec) : (return undef);
}

############################################
##
##	GET DEFAULT VALUES, FOR A NEW RECORD
##
############################################
sub get_defaults {
# ----------------------------------------------------------------------------------------------
# Returns a hash of the defaults used for a new record.

	my (%default);

	foreach $field (keys %db_defaults) {
		$default{$field} =  $db_defaults{$field};
	}
	if ($db_key_track) {
		open (ID, "<$db_id_file_name") or &cgierr("Error in get_defaults: unable to open counter file.\nReason: $!");
		if ($db_use_flock) { flock(ID, 1);	}	
		$default{$db_key} = <ID> + 1;	# Get next ID number
		close ID;
	}
	return %default;
}

############################################
##
##		VALIDATE RECORD
##
############################################

sub validate_record {
# ----------------------------------------------------------------------------------------------
# Verifies that the information passed through the form and stored in %in matches a valid 
# record. It checks first to see that if we are adding, that a duplicate ID key does not exist.
# It then checks to see that fields specified as not null are indeed not null, finally it checks
# against the reg expression given in the database definition.

my ($col, @input_err, $errstr, $err, $line, @lines, @data);	

if ($in{'add_record'}) 	{		# don't need to worry about duplicate key if modifying	
	open (DB, "<$db_file_name") or &cgierr("Error in validate_records. Unable to open db file.\nReason: $!");
	if ($db_use_flock) { flock(DB, 1); }		
	LINE: while (<DB>) {
		(/^#/)      and next LINE;
		(/^\s*$/)   and next LINE;
		$line = $_;	chomp ($line);
		@data = &split_decode($line);	
		if ($data[$db_key_pos] eq $in{$db_key}) {
			return "duplicate key error";
		}
	}
	close DB;
}	
foreach $col (@db_cols) {
	if ($in{$col} =~ /^\s*$/) {	   # entry is null or only whitespace
		($db_not_null{$col}) and   # entry is not allowed to be null.
			push(@input_err, "$col (cannot be left blank)");  # so let's add it as an error
	} else {						   # else entry is not null.
		($db_valid_types{$col} && !($in{$col} =~ /$db_valid_types{$col}/)) and
			push(@input_err, "$col (Invalid format)");	# but has failed validation.
	}
	(length($in{$col}) > $db_lengths{$col}) and
		push (@input_err, "$col (Too long. Max length: $db_lengths{$col})");
	if ($db_sort{$col} eq "date") {		
		push (@input_err, "$col (Invalid date format)") unless &date_to_unix($in{$col});
	}
}
if ($#input_err+1 > 0) {			# since there are errors, let's build
	foreach $err (@input_err) {		# a string listing the errors
		$errstr .= "$err";			# and return it.
	}
	return "$errstr";
} else {
	return "ok";					# no errors, return ok.
}
}

#*******************************************
#**
#**  ENCODE RECORD
#**
#*******************************************
sub join_encode {
# ----------------------------------------------------------------------------------------------
# Takes a hash (ususally from the form input) and builds one line to output into the database.
# It changes all occurrences of the database delimiter to '~~' and all newline chars to '``'.

	my (%hash) = @_;
	my ($tmp, $col, $output);	

	foreach $col (@db_cols) {				
		$tmp = $hash{$col};
		$tmp =~ s/^\s+//g;				# Trim leading blanks.
		$tmp =~ s/\s+$//g;				# Trim trailing blanks.
		$tmp =~ s/\Q$db_delim\E/~~/og;	# Change delimiter to ~~ symbol.
		$tmp =~ s/\n/``/g;				# Change newline to `` symbol.
		$tmp =~ s/\r//g;				# Remove Windows linefeed character.
		$output .= $tmp . $db_delim;	# Build Output.
	}
	chop $output;		# remove extra delimiter.
	$output .= "\n";	# add linefeed char.
	return $output;
}

#*******************************************
#**
#**  UNENCODE RECORD
#**
#*******************************************
sub split_decode {
# ----------------------------------------------------------------------------------------------
# Takes one line of the database as input and returns an array of all the values. It replaces 
# special mark up that join_encode makes such as replacing the '``' symbol with a newline and 
# the '~~' symbol with a database delimiter.

	my ($input) = shift;
	$input =~ s/\Q$db_delim\E$/$db_delim /o; # Add a space if we have delimiter new line.
	my (@array) = split (/\Q$db_delim\E/o, $input);
	for ($i = 0; $i <= $#array; $i++) {
		$array[$i] =~ s/~~/$db_delim/og;	# Retrieve Delimiter.
		$array[$i] =~ s/``/\n/g;			# Change '' back to newlines.
	}	
	return @array;
}

#*******************************************
#**
#**  CONVERT ARRAY TO HASH
#**
#*******************************************
sub array_to_hash {
# ----------------------------------------------------------------------------------------------
# Converts an array to a hash using db_cols as the field names.

	my($hit, @array) = @_;
	my(%hash);
	 
	for ($j = 0; $j <= $#db_cols; $j++) {
		$hash{$db_cols[$j]} = $array[$hit * ($#db_cols+1) + $j];
	}	
	return %hash;
}

#*******************************************
#**
#**  PARSE FORM
#**
#*******************************************
sub parse_form {
# ----------------------------------------------------------------------------------------------
# Parses the form input and returns a hash with all the name value pairs. Removes SSI and any 
# field with "---" as a value (as this denotes an empty SELECT field).

	my (@pairs, %in);
	my ($buffer, $pair, $name, $value);	

	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	}
	elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 		@pairs = split(/&/, $buffer);
	}
	else {
		&cgierr ("This script must be called from the Web\nusing either GET or POST requests\n\n");
	}
	PAIR: foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		 
		# convert plus signs to spaces
		$name =~ tr/+/ /;
		# unencode hex values for special characters
		$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$value =~ s/<!--(.|\n)*-->//g;	 	# Remove server-side includes.

		# Next is used as a default choice for select lists and is ignored.
		if ($value eq "---") { next PAIR; }	
		(exists $in{$name}) ?
			($in{$name} .= "~~$value") :  # If we have multiple select, then 
			($in{$name}  = $value);		  # we tack on using the ~~ as a 
										  # seperator.
	}
	return %in;
}

#*******************************************
#**
#**  ERROR / ENVIRONMENT OUTPUT
#**
#*******************************************
sub cgierr {
# ----------------------------------------------------------------------------------------------
# Displays any errors and prints out FORM and ENVIRONMENT information. Useful for debugging.

	if (!$html_headers_printed) {
		print "Content-type: text/html\n\n";
		$html_headers_printed = 1;
	}
	print "<PRE>\n\nCGI ERROR\n==========================================\n";
	$_[0]      and print "Error Message       : $_[0]\n";	
	$0         and print "Script Location     : $0\n";
	$]         and print "Perl Version        : $]\n";	
	$db_setup  and print "Setup File          : $db_setup.cfg\n";
	$db_userid and print "User ID             : $db_userid\n";
	$db_uid    and print "Session ID          : $db_uid\n";
	
	print "\nForm Variables\n-------------------------------------------\n";
	foreach $key (sort keys %in) {
		my $space = " " x (20 - length($key));
		print "$key$space: $in{$key}\n";
	}
	print "\nEnvironment Variables\n-------------------------------------------\n";
	foreach $env (sort keys %ENV) {
		my $space = " " x (20 - length($env));
		print "$env$space: $ENV{$env}\n";
	}
	print "\n</PRE>";
	exit -1;
}
		
#*******************************************
#**
#**  GET DATE
#**
#*******************************************
# Note: you must leave this sub in the main webtool.cgi file or the script will die, since this
# routine is called from config files that load early.

sub get_date {
# ----------------------------------------------------------------------------------------------
# Returns the date in the format "dd-mmm-yy". Warning: If you change the default format, you 
# must also modify the &date_to_unix subroutine which converts your date format into a unix 
# time in seconds for sorting purposes.

    my ($sec, $min, $hour, $day, $mon, $year, $dweek, $dyear, $daylight) = localtime(time());
    my (@months) = qw!Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec!;
	($day < 10) and ($day = "0$day");
	$year = $year + 1900;
    
    return "$day-$months[$mon]-$year";
}


