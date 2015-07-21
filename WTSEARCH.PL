# wtSearch.pl

##########################################################
##
##		SEARCH RESULTS
##
##########################################################
sub html_view_success {
# ----------------------------------------------------------------------------------------------
# This page displays the results of a successful search. You can use the following variables 
# when displaying your results:
#
#        $numhits - the number of hits in this batch of results.
#        $maxhits - the max number of hits displayed.
#        $db_total_hits - the total number of hits.
#        $db_next_hits  - html for displaying the next set of results.
	
my (@hits) = @_;
my ($numhits) = ($#hits+1) / ($#db_cols+1);
my ($maxhits); $in{'mh'} ? ($maxhits = $in{'mh'}) : ($maxhits = $db_max_hits);	
	
&html_print_headers;	
print qq|
<html><head><title>$systemName: $html_title Search Results.</title></head>

<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<table border=0 align=center>
	<tr><td>
		<$fontLarge>Search Results</font>
		<br><$font>Your search returned <b>$db_total_hits</b> matches.</font><br>&nbsp;|;
		if ($db_next_hits) { print "<br><$font>Pages: $db_next_hits</font><br>&nbsp;"; }
		&html_footer;

		# Go through each hit, converting the array to a hash and send to html_record 
		# for printing.
		for (0 .. $numhits - 1) {
    		print "<P>";
		    &html_record (&array_to_hash($_, @hits));
		}
		print qq| <br> |;
		if ($db_next_hits) { print "<$font>Pages: $db_next_hits</font><br>&nbsp;"; }

		# Only print bottom menu if there's more than one matching record returned.
		if ($numhits > 1) {	&html_footer; }
		print qq|
	</td></tr>
</table>
</body>
</html>
|;
}

##########################################################
##
##		SEARCH SCREEN
##
##########################################################
sub html_search {
# ----------------------------------------------------------------------------------------------
# This page is displayed when a user requests to search the database, either for adding, modi-
# fying or deleting a record.
#
# Note: all searches must use GET method, and for the Transaction database this is a potential
# security hazard. You want to prevent a user from modifying transaction records; only Admin 
# should have that ability. Conceivably a user could study the undecoded URL from watching how 
# the ads database works, then submit a similar URL to unlock record modifying for transactions.
# Be sure you disable Modify / Delete for transactions at the code level, unless they're logged 
# in as Admin.

&html_print_headers;
print qq|
<html><head><title>$html_title: Search the Database.</title></head>

<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<form action="$db_script_url" method="GET">
    <input type=hidden name="db" value="$db_setup">
    <input type=hidden name="uid" value="$db_uid">
    <input type=hidden name="sys" value="$sysID">

    <table align=center border=1 bgcolor="#FFFFFF" cellpadding=0 cellspacing=0 width=585 valign=top>
		<tr><td>
			<table border=0 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=585 valign=top>
				<tr>
					<td>|;
						if ($in{'delete_search'}) {
							print qq|
			    			<$fontLarge>Delete $html_title</FONT><BR>
						    <$font>
								Search the database for the records you wish to delete. 
								<B>Note: </B>unless you're logged in as admin, this search will 
								return only records you	created. Consult <b>Help</b> for more 
								information.<BR><BR>
			    			</font>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="delete_form" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">
							|; &sortOptions;
						} elsif ($in{'modify_search'}) {
							print qq|
			    			<$fontLarge>Modify $html_title</FONT><BR>
						    <$font>
								Search the database for the record you wish to modify. <B>Note: 
								</B>unless you're logged in as admin, this search will return 
								only records you created. Consult <b>Help</b> for more 
								information.<BR><BR>
			    			</font>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="modify_form" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">
							|; &sortOptions;
						} else {
							print qq|
				    		<$fontLarge>$html_title Search</FONT><BR>
							<$fontBlue>
								Enter keywords to narrow your search. For search tips, consult 
								the <b>Help</b> menu.
							</font><br><br>
							|; &html_search_options; print qq|
							<br><INPUT TYPE="SUBMIT" NAME="view_records" VALUE="Search"><INPUT TYPE="RESET" VALUE="Reset">
							|; 
							####################################################################
							## RESTRICT SEARCH ON TRANSACTION DATABASE  
							## -----------------------------------------------------------------
							## If trades.db is the database in use, we need the global keyword
							## search to restrict a normal user to viewing their own trades. We
							## can't use the normal option to view only trades they create,
							## since an admin or other user may have recorded the trade. Submit
							## the keyword search as a hidden field containing their own userID,
							## and it will pick up all trades they've been party to, even if
							## they didn't enter the record themselves.
							##
							####################################################################
							if ($db_setup = 'trades') {

							} else {
								&sortOptions;
							}
						}
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

##########################################################
##
##		VIEW RECORDS
##
##########################################################
sub view_records {
# ----------------------------------------------------------------------------------------------
# This is called when a user is searching the database for viewing. All the work is done in 
# query() and this routine just checks to see if the search was successful or not and returns 
# the user to the appropriate page.

	my ($status, @hits) = &query("view");
	if ($status eq "ok") {
		&html_view_success(@hits);
	} else {
		&searchFailure('search', $status);
	}
}
1;
