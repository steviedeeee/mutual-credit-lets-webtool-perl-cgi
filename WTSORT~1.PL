# wtSortOptions.pl

##########################################################
##
##		SORT OPTIONS
##
##########################################################
# The standard sort options that appear in every search screen (add/delete/modify/search).
# There are some others we could add, like the global keyword search, which matches against
# all fields.

sub sortOptions {
	print qq|
	<$font>&nbsp;&nbsp;&nbsp;Hits Per Page&nbsp;</font>
	<INPUT TYPE="TEXT" NAME="mh" VALUE="$db_max_hits" SIZE=5 MAXLENGTH=5>
	<$font>&nbsp;Sort By&nbsp;</font>
	<SELECT NAME="sb">
		<OPTION>--- |;
		for (my $i =0; $i <= $#db_cols; $i++) { 
			print qq| <OPTION VALUE="$i">$db_cols[$i]</OPTION>\n |; 
		} 
		print qq|
	</SELECT>
	<$font>&nbsp;Order&nbsp;</font>
	<SELECT NAME="so">
		<OPTION VALUE="ascend">Ascending
		<OPTION VALUE="descend">Descending
	</SELECT>|;
}

sub ORIGINAL_html_search_options {
# --------------------------------------------------------
# Search options to be displayed at the bottom of search forms.

	print qq~
	<P>
	<STRONG>Search Options:</STRONG> <br>
	<INPUT TYPE="CHECKBOX" NAME="ma"> Match Any 
	<INPUT TYPE="CHECKBOX" NAME="cs"> Match Case 
	<INPUT TYPE="CHECKBOX" NAME="ww"> Whole Words 
	<INPUT TYPE="CHECKBOX" NAME="re"> Reg. Expression<BR>
	<INPUT TYPE="TEXT" NAME="keyword" SIZE=15 MAXLENGTH=255> Keyword Search 
        <FONT SIZE=-1> (will match against all fields)</FONT><BR>
	<INPUT TYPE="TEXT" NAME="mh" VALUE="$db_max_hits" SIZE=3 MAXLENGTH=3> Max. Returned Hits<BR>
	Sort By:
	<SELECT NAME="sb">
		<OPTION>---	~; 
        for (my $i =0; $i <= $#db_cols; $i++) { 
			print qq~<OPTION VALUE="$i">$db_cols[$i]</OPTION>\n~ if ($db_form_len{$db_cols[$i]} >= 0);
		} 
		print qq~
	</SELECT>
	Sort Order:
	<SELECT NAME="so">
		<OPTION VALUE="ascend">Ascending
		<OPTION VALUE="descend">Descending
	</SELECT><br><br>
	<strong>Search Tips:</strong><br>
	&nbsp;&nbsp;&nbsp;&nbsp;- use '*' to match everything in a field)<BR>
	&nbsp;&nbsp;&nbsp;&nbsp;- put a '&gt;' or '&lt;' at the beginning to to do range searches.<BR>	
	~;
}
1;
