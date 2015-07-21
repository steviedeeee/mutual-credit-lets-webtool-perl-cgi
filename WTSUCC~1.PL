# wtSuccessFailure.pl

##########################################################
##
##		FAILURE:  ADD / MODIFY / DELETE
##
##########################################################
sub htmlFailure {
# ----------------------------------------------------------------------------------------------
# Failure page returned for add / modify / delete. An error message is passed in explaining 
# what happened in $message and (in the case of add/modify) the form is reprinted out saving 
# the input (by passing in %in to html_record_form). In the case of a deletion failure, the
# record ID's that failed to be deleted are shown.

my ($failureType) = $_[0];	# Param passed in, identifying which kind of operation failed.
my ($message) = $_[1];		# Param passed in, explaining why it failed.
# my ($sysID) = $_[2];

&html_print_headers;
print qq|
<html><head><title>$systemName: Error! Unable to $failureType $html_title Record.</title></head>

<body BGCOLOR="#C0C0C0" LINK="#cccccc" VLINK="#cccccc" ALINK="#cccccc">
<form action="$db_script_url" method="POST">
    <input type=hidden name="db"  value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">	
    <input type=hidden name="sys" value="$sysID">

    <table align=center border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top>
		<tr>
			<td>|;
				if ($failureType eq 'Delete') {
					print qq|
					<$fontLarge>Error: <font color=red>Unable to Delete Records.</font></font>
					<$font><br>
    					There was a problem deleting records: 
						<FONT COLOR="red">$message.</FONT><br><br><br>
    				</font>|;
				} elsif ($failureType eq 'Modify') {
					print qq|
					<$fontLarge>Error: <font color=red>Unable to Modify Record</font></font>
					<$font><br>
						There were problems modifying the record: 
						<FONT COLOR="red">$message.</FONT><br>
					</font>|;

					# See if you should display the record user attempted to modify.
					if ($message =~ /no record specified/) {
						# Skip the display of the record to modify since none was chosen.
						print qq| <br><br> |;
					} else {
						# Display the record user attempted to modify.
						&html_record_form (%in); print qq|
						<p>
							<INPUT TYPE="SUBMIT" NAME="modify_record" VALUE="Modify Record"><INPUT TYPE="RESET" VALUE="Reset">
						</p>|;
					}
				} else {
					# Must have been an Add Record failure.
					print qq|
		    		<$fontLarge>Error: <font color=red>Unable to Add $html_title</font></FONT>
		    		<$font><BR>
    					There were problems adding the record: <br>
						<FONT COLOR="red">$message</FONT>
					</font>
					<br>
		    		|; &html_record_form (%in); print qq|
					<p>
						<INPUT TYPE="SUBMIT" NAME="add_record" VALUE="Add Record"><INPUT TYPE="RESET" VALUE="Reset">
			    	</p>|;
				}
			    &html_footer; print qq|
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
##		SUCCESSFULLY:  ADDED / MODIFIED / DELETED
##
##########################################################
sub html_success {
# ----------------------------------------------------------------------------------------------
# The page that is returned upon a successful add/delete/modify. 

my ($successType) = $_[0];	# Grab incoming param indicating which operation was successful.

&html_print_headers;
print qq|
<html><head><title>$systemName: Record $successType</title></head>
<body BGCOLOR="#C0C0C0" LINK="white" VLINK="white" ALINK="white">
<table align=center border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top>
	<tr>
		<td>
		    <$fontLarge>Record $successType</font><br>|;
			if ($successType eq "Added") {
				print qq|
			    <$font>The following record was successfully added to the database:<br><br></FONT>
		    	|; &html_record(&get_record($in{$db_key}));
			} elsif ($successType eq "Modified") {
				print qq|
			    <$font>The following record was successfully modified:<br><br></FONT>
		    	|; &html_record(&get_record($in{$db_key}));
			} else {
				# Must have been a deletion.
				print qq|
			    <$font>The record(s) were deleted from the database.</FONT>|;
			}
			print qq| <BR><BR>
		    |; &html_footer; print qq|
	    </td>
	</tr>
</table>
</body>
</html>
|;
}

####################################################################
##
##		SEARCH FAILURE: TO ADD, DELETE OR MODIFY A RECORD
##
####################################################################
# ----------------------------------------------------------------------------------------------
sub searchFailure {

my ($failureType) = $_[0]; 	# Grab the incoming param indicating the type of failure: view, 
							# modify, or deletion failure.
my ($errstr) = $_[1];		# Grab the incoming param that describes why the search failed.
# my ($sysID) = $_[2];

&html_print_headers;
print qq|
<html><head><title>$systemName: Search Failure</title></head>
<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<form action="$db_script_url" method="GET">
    <input type=hidden name="db" value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">
    <input type=hidden name="sys" value="$sysID">

    <table border=1 bgcolor="#FFFFFF" align=center cellpadding=0 cellspacing=0 width=640 valign=top>
		<tr><td>
			<table border=0 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top>
				<tr>
					<td>|;
						# The following three failure types are the same, except for the text
						# and the all-important Submit buttons, which re-route the action to
						# three different scripts for view, delete and modify.

						if ($failureType eq 'Delete') {
							print qq|
			    			<$fontLarge>Delete $html_title</FONT><BR>
						    <$font>
								There were problems finding records to delete: <FONT COLOR="red">
								<B>$errstr</B></FONT><br>Please try again.<BR><BR>
			    			</font>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="delete_form" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">|;
						} elsif ($failureType eq 'Modify') {
							print qq|
			    			<$fontLarge>Modify $html_title</FONT><BR>
						    <$font>
								There were problems finding records to modify: <FONT COLOR="red">
								<B>$errstr</B></FONT><br>Please try again.<BR><BR>
			    			</font>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="modify_form" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">|;
						} else {
							print qq|
				    		<$fontLarge>$html_title Search</FONT><BR>
							<$font>
								There were problems with the search: <FONT COLOR="red">
								<B>$errstr</B></FONT><br>Please try again.<BR><BR>
							</font>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="view_records" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">
							|;
						}
						&sortOptions;  # Display Sort By / Sort Order / MaxHits options.
						print qq|
					</td>
				</tr>
				<tr><td colspan=1>|; &html_footer; print qq| </td></tr>
    		</table>
		</td></tr>
	</table>
</form>
</body>
</html>
|;
}
1;
