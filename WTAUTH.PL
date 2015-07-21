# wtAuth.pl

##########################################################
##
##		CHECK PASSWORD			
##
##########################################################
sub auth_check_password {
# ----------------------------------------------------------------------------------------------
# This routine checks to see if the password and userid found in %in (must be 'pw' and 'userid')
# match a valid one in the password file. It returns a status message and a userid which is 
# built by a "user name" + "random number" which gets stored in the query string.

my ($pass, @passwd, $userid, $pw, @permissions, $file, $uid);
my ($server_auth) = $ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'};
	 
# Return default permissions if no authentication.
if ($auth_no_authentication || (($db_uid eq 'default') && $auth_allow_default)) {		
    return ('ok', 'default', @auth_default_permissions);
}
elsif ($server_auth) {   # The user has logged in via server authentication.
    return ('ok', $server_auth, &auth_check_permissions($server_auth));
}
elsif ($in{'login'}) {		# The user is trying to login.
    open (PASSWD, "<$auth_pw_file") || &cgierr("Unable to open file. Reason: $!\n");
    @passwds = <PASSWD>;	# get all user id's and passwords.
    close PASSWD;
    my ($view, $add, $mod, $del, $admin, $email, $sysID);
        PASS: foreach $pass (@passwds) {	# Go through each pass and see if we match.
	    next PASS if ($pass =~ /^$/);		# Skip blank lines.
	    next PASS if ($pass =~ /^#/);		# Skip Comment lines.
	    chomp ($pass);
	    ($userid, $pw, $view, $add, $del, $mod, $admin, $email, $sysID) = split (/:/, $pass);

	    if (($in{'userid'} eq $userid) && ($in{'pw'} eq $pw) && ($in{'sys'} eq $sysID)) {

			srand( time() ^ ($$ + ($$ << 15)) );	# Seed Random Number
			$db_uid = "$in{'userid'}." . time() . (int(rand(100000)) + 1);   # Build User Id

			open(AUTH, ">$auth_dir/$db_uid") or &cgierr("Unable to open session file. Reason: $!\n");
            print AUTH "$uid: $ENV{'REMOTE_HOST'}\n";

			close AUTH;
			foreach (0 .. 3) { $permissions[$_] = int($permissions[$_]); }
		    &auth_logging('logged on', $userid) if ($auth_logging);
	    	return ('ok', $db_uid, $view, $add, $del, $mod, $admin, $email, $sysID);
    	}
	}
    return ("invalid username/password");
}
elsif ($db_uid) { # The user already has a user id given by the program.
    (-e "$auth_dir/$db_uid") ?
	return ('ok', $db_uid, &auth_check_permissions($db_uid)) :
	return ('invalid/expired user session');	
}
else {	# User has not logged on yet.
	return 'no login';
}
}

########################################################
##
##		CHECK AND RETURN PERMISSIONS
##
########################################################
sub auth_check_permissions {
# ----------------------------------------------------------------------------------------------	
# This routine checks the permissions file and returns the users permissions. It takes as input 
# a valid user id and returns a set of permissions.

my ($userid) = shift;
my ($username, @permissions, $permission, $name, $pw, $view, $add, $del, $mod, $admin, $sysID);

# Use default permissions if there's no authentication or if this is a default user.
if ($auth_no_authentication || (($userid eq 'default') && $auth_allow_default)) {
	return (@auth_default_permissions);
}

# Otherwise, check if we've been passed in a userID or we have one from server authentication.
if ($ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'}) {
	$username = $ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'};
} else {
	($userid =~ /^([A-Za-z0-9]+)\.\d+$/) ? ($username = $1) : return (0,0,0,0,0,0);
}

# Load permissions into an array.
open (PER, "<$auth_pw_file") or &cgierr("unable to open password file. Reason: $!");
@permissions = <PER>;
close PER;

# Skip through the array.
PER: foreach $permission (@permissions) {
	($permission =~ /^$/) and next PER;	# Skip blank lines.
	($permission =~ /^#/) and next PER;	# Skip Comment lines.	
	($name, $pw, $view, $add, $del, $mod, $admin) = split (/:/, $permission);			
	if ($username eq $name) {
		$view  = int($view); 	$add   = int($add); 	# We int everything just in case
		$del   = int($del); 	$mod   = int($mod); 	# of spaces after the permssions.
		$admin = int($admin); 	$sysID = int($sysID);
		return ($view, $add, $del, $mod, $admin, $sysID);
	}
}
return (0,0,0,0,0,0);		# Can't find this user?
}

########################################################
##
##		LOG AN ACTION TO THE DATABASE
##
########################################################
sub auth_logging {
# ----------------------------------------------------------------------------------------------
# Logs an action to the database. Takes as input an action, and optionally a user id. If no user
# id is passed in, it gets one from the global $db_userid.

my ($action, $uid) = @_;
my ($time) = &get_time;		# Change time/date format globally
my ($date) = &get_date;		# in get_time and get_date.
if (!$uid) {
	$db_userid ?
		($uid = $db_userid) :
		($uid = "UNKNOWN");	# Hopefully we shouldn't see this.
}	
open (LOG, ">>$auth_log_file") || &cgierr("Unable to open log file. Reason: $!\n");
flock (LOG, 2) unless (!$db_use_flock);
print LOG "$uid $action at $time on $date from $ENV{'REMOTE_HOST'}\n";		
close LOG;		# releases file lock.
}

########################################################
##
##		CLEANUP USER SESSIONS
##
########################################################
sub auth_cleanup {
# ----------------------------------------------------------------------------------------------
# This routine cleans up the userSession directory, removing old user files.

my (@files);
opendir (AUTHDIR, "$auth_dir") || &cgierr("Unable to open directory in auth_cleanup. Reason: $!");
@files = readdir(AUTHDIR);		  # Read in list of files in directory.
closedir (AUTHDIR);
FILE: foreach $file (@files) {
	next if ($file =~ /^\./);			# Skip "." and ".." entries
	next if ($file =~ /^index/);		# Skip index.htm type files
	if ((stat("$auth_dir/$file"))[9] + $auth_time < time) {
		unlink ("$auth_dir/$file");		# Delete the file if it is too old.
	}
}
}
1;
