# wtAdmin.pl

##########################################################
##
##		NEW LOGIN TEST - REJECT DUPLICATE USERNAMES				
##
##########################################################
sub newLoginTest {
	my ($proposedUserName) = @_;

	open (PASS, "<$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
	if ($db_use_flock) { flock(PASS,1); }
	my ($found) = 0;
	$message = "ok";
	LINE: while (<PASS>) {
		next if /^#/; 		# ignore comment lines
		next if /^\s*$/;	# ignore blank lines
		$line = $_;	chomp ($line);		
		@fields = &split_decode ($line);	# Build an array of fields.
		if ($fields[0] =~ /^$proposedUserName/) { $found = 1; }
	}
	close PASS;
	if ($found) { $message = "ERROR: Username already exists."; }
	return $message;
}

##########################################################
##
##		MEMBER SETUP / ADMIN OPTIONS				
##
##########################################################

sub admin_display {
# Routine to create new member logins, view or change their passwords, permissions, and email
# address associated with each member.

$sysID = $in{'sys'};				# Get the system ID passed in.
$sysName = getSystemName($sysID);	# Get the system name for the system ID passed in.

my ($message, @lines, $line);
my (@optionData, @optionLines, $optionLine);

# Do we have anything to do?
CASE: {

	# If we've been passed in new_username, then we're adding a new user. 
    # Do some basic error checking and then add them to the password file.
	######################################################################
    ##
	##   CREATE MEMBER
    ##
	######################################################################
	$in{'new_username'}	and do {
		# Test if the username is unique: it must be.
		$uniqueLogin = &newLoginTest($in{'new_username'});
		if ($uniqueLogin ne 'ok' ) {
			# That login username already exists: return error message.
			$message = "That username already exists! Please try again.";
			last CASE;
		} else {
			# New login has a unique username: fall through to create the new user.
		}

		# If you got here, the username was unique: now test for invalid character length.
		unless ((length($in{'new_username'}) >= 3) and (length($in{'new_username'}) <= 60) and ($in{'new_username'} =~ /^[a-zA-Z0-9]+$/)) {
			$message = "Invalid username: $in{'new_username'}. Must contain only letters and numbers, and between 3 and 12 characters in length.";
			last CASE;
		}
		unless ((length($in{'password'}) >= 3) and (length($in{'password'}) <= 12)) {
			$message = "Invalid password: $in{'password'} must be less than 12 and greater than 2 characters in length.";
			last CASE;
		}

		# The proposed new login passed all tests: now write this new user to the password / 
		# permission file.

		open (PASS, ">>$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
		if ($db_use_flock) {
			flock(PASS, 2)  or &cgierr("Unable to get exclusive lock on password file.\nReason: $!");
		}
		#  Write to the password file permissions.def
		print PASS "$in{'new_username'}:$in{'password'}:$in{'per_view'}:$in{'per_add'}:$in{'per_del'}:$in{'per_mod'}:$in{'per_admin'}:$in{'email'}:$sysID\n";
		close PASS;
		$message = "Member login $in{'new_username'} created.";
		last CASE;
	};	# end CREATE MEMBER

	# If we've been passed in delete, then we're removing a user. Check to make sure a user was
	# selected then try and remove him/her.

	######################################################################
    ##
	##   DELETE MEMBER
    ##
	######################################################################
	$in{'delete'} and do {
		#  Don't allow user to delete superadmin access!
		if ($in{'username'} eq 'superadmin') {
			$message = "Superadmin cannot be deleted!";
			last CASE;
		}
		unless ($in{'username'}) {
			$message = "No username selected to delete.";
			last CASE;
		}
		open (PASS, "<$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
			if ($db_use_flock) { flock(PASS, 1)	}				
			@lines = <PASS>;
			close PASS;
				
		open (PASS, ">$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
		if ($db_use_flock) {
			flock(PASS, 2)  or &cgierr("Unable to get exclusive lock on password file.\nReason: $!");
		}
		my $found = 0;
		foreach $line (@lines) {
			($line =~ /^$in{'username'}:/) ?
			($found = 1) :	print PASS $line;
		}
		close PASS;
		$found ?
			($message = "User: $in{'username'} deleted.") :
			($message = "Unable to find userid: $in{'username'} in password file.");
		last CASE;
	};

	######################################################################
    ##
	##   EDIT MEMBER
    ##
	######################################################################
	# If we have a username, and the admin didn't press either Inquire or Delete, then we're
	# updating a member's file. 

	($in{'username'} && !$in{'inquire'} && !$in{'admin_update'}) and do {
		open (PASS, "<$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
		if ($db_use_flock) { flock(PASS, 1); }				
		@lines = <PASS>;
		close PASS;
				
		open (PASS, ">$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
		if ($db_use_flock) {
			flock(PASS, 2)  or &cgierr("Unable to get exclusive lock on password file.\nReason: $!");
		}
		my $found = 0;
		foreach $line (@lines) {
			if ($line =~ /^$in{'username'}:/) {
				my $password = (split (/:/, $line))[1];
				my $email = (split (/:/, $line))[7];
				unless ($password eq $in{'password'}) {
					$password = ($in{'password'});
				}
				$email = ($in{'email'});
				print PASS "$in{'username'}:$password:$in{'per_view'}:$in{'per_add'}:$in{'per_del'}:$in{'per_mod'}:$in{'per_admin'}:$in{'email'}:$sysID\n";
				$found = 1;
			}
			else {
				print PASS $line;
			}
		}
		$in{'inquire'} = $in{'username'};
		$found ?
			($message = "User: $in{'username'} updated.") :
			($message = "Unable to find user: '$in{'username'}' in the password file.");
		last CASE;
	};
};	# end CASE

######################################################################
##
##   INQUIRE / LOAD PERMISSIONS
##
######################################################################
open (PASS, "<$auth_pw_file") or &cgierr ("Unable to open password file.\nReason: $!");
if ($db_use_flock) { flock(PASS, 1); }	
@lines = <PASS>;
close PASS;

# If we are inquiring, let's look for the specified user.
my (@data, $user_list, $perm, $password, $email);

$user_list = qq~<select name="username"><option> </option>~;
LINE: foreach $line (@lines) {
	$line =~ /^#/    and next LINE;		# skip comment lines
	$line =~ /^\s*$/ and next LINE;		# skip blank lines

	chomp $line;
	@data = split (/:/, $line);
	my ($thisSystem) = getSystemName($data[8]);
		
	if ($in{'inquire'} and ($in{'username'} eq $data[0])) {
		$user_list .= qq~<option value="$data[0]" SELECTED>$data[0] --- $thisSystem</option>\n~;
		$perm = qq|
			<input type="hidden" name="per_view" value="1"> 
	      	Add <input type=checkbox name="per_add" value="1"       |; ($data[3] and $perm .= "CHECKED"); $perm .= qq|> 
		  	Delete <input type=checkbox name="per_del" value="1"    |; ($data[4] and $perm .= "CHECKED"); $perm .= qq|> 
		  	Modify <input type=checkbox name="per_mod" value="1"    |; ($data[5] and $perm .= "CHECKED"); $perm .= qq|>
		  	Admin <input type=checkbox name="per_admin" value="1"   |; ($data[6] and $perm .= "CHECKED"); $perm .= qq|>|;
		$password = $data[1];
		$email = $data[7];
	}
	else {
		$user_list .= qq~<option value="$data[0]">$data[0] --- $thisSystem</option>\n~;	
	}
}
$user_list .= "</select>";
# Build the permissions list if we haven't inquired about someone.

if (!$perm) {
	$perm = qq|
	<input type="hidden" name="per_view" value="1"> 
    Add <input type=checkbox name="per_add" value="1"       |; ($auth_default_perm[1] and $perm .= "CHECKED"); $perm .= qq|> 
	Delete <input type=checkbox name="per_del" value="1"    |; ($auth_default_perm[2] and $perm .= "CHECKED"); $perm .= qq|> 
	Modify <input type=checkbox name="per_mod" value="1" 	|; ($auth_default_perm[3] and $perm .= "CHECKED"); $perm .= qq|>
	Admin <input type=checkbox name="per_admin" value="1"   |; ($auth_default_perm[4] and $perm .= "CHECKED"); $perm .= qq|>
	|;
}			  

######################################################################
##
##   ADMIN SCREEN HTML
##
######################################################################

# The routines above figure out what's contained in $user_list, a variable that stores the HTML
# of the drop-down listbox of valid users that appears on the admin screen, which is populated 
# by array elements of the form:
#
#       $in{'username'} eq $data[0] 
#
#  ... where $data[n] holds the user ID, password, 5 permission types for operations on the 
# Ad Directory database, email address, and system ID. 

# ----------------------------------------------------------------------------------------------

&html_print_headers;
print qq|
<html><head><title>Member Logins</title></head>
<body BGCOLOR="#C0C0C0" text="#000000" LINK="white" VLINK="white" ALINK="white">

<form action="$db_script_url" method="post">
    <input type=hidden name="db" value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">	
    <input type=hidden name="admin_display" value="1">
    <input type=hidden name="sys" value="$sysID">

    <table border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 align=center valign=top>
	    <tr>
			<td>
			<table width=620 border=0 cellpadding=2 cellspacing=0>
				<tr>
					<td><$fontLarge>$sysName: Member Logins</font></td>
					<td bgcolor="#009900" align=right width="9%"><$font><b><a href="$helpURL#login">Help</a></b>&nbsp;&nbsp;</font></td>
				</tr>
				<tr>
					<td colspan=2>
						<$font>|;
							if ($message ne '') {
								print qq| <font color=red><b>$message</b></font><br> |;
							}
							print qq|
							This is where you setup password access for your members. 
						</font>
					</td>
				</tr>
			</table>|;
			print qq|
			<p>
			<center>
				<table width=620 bgcolor="#cccccc" border=0 cellspacing=1 cellpadding=5>
   					<tr>|; 
						print qq|
   	    				<$tdGreyRight><$fontWhite>Members </font></td>
		    			<td bgcolor="#ffffcc" width="85%">$user_list <input type=submit name=inquire value="Inquire"><input type=submit name=delete value="Delete"><input type=submit value="Update/Create User"></td>
    				</tr>
    				<tr>
  	    				<$tdGreyRight><$fontWhite>Create New <br>Username </font></td>
	    				<$tdBeigeLeft><input type="text" name="new_username" size="25"></td>
	   				</tr>
					<tr>
	    				<$tdGreyRight><$fontWhite>Password </font></td>
	    				<$tdBeigeLeft><input type="text" name="password" value="$password" size="25"></td>
    				</tr>
					<tr>
		    			<$tdGreyRight><$fontWhite>Email </font></td>
	    				<$tdBeigeLeft><input type="text" name="email" value="$email" size="52"></td>
    				</tr>
  					<tr>
		    			<$tdGreyRight><$fontWhite>Permissions </font></td>
						<td bgcolor="#ffffcc" align=left><$font>$perm</font></td>
					</tr>
    			</table>
				<br>
			</center>
    		</td>
    	</tr>
		<tr><td>|; &html_footer; print qq|</td>
    	</tr>
    </table>
    </center>
</form>
</body>
</html>
|;
}
1;
