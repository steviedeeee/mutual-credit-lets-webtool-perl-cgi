#  wtQuery.pl - search engine

##########################################################
##
##		QUERY		
##
##########################################################
sub query {
# --------------------------------------------------------
# First let's get a list of database fields we want to search on and 
# store it in @search_fields

my ($i, $column, @search_fields, $maxhits, $numhits, $nh, $field, @regexp, $line, @values,
   $key_match, @hits, @sortedhits, $next_url, $next_hit, $prev_hit, $first, $last, $upper,
   $lower, $left, $right, $restricted);	

local (%sortby);
	
# First thing we do is find out what we are searching for. We build a list of fields
# we want to search on in @search_fields.

if ($in{'keyword'}) {		# If this is a keyword search, we are searching the same
    $i = 0; 			# thing in all fields. Make sure "match any" option is 
    $in{'ma'} = "on";		# on, otherwise this will almost always fail.

    foreach $column (@db_cols) {		
	if (($db_sort{$column} eq 'date') or &date_to_unix($in{'keyword'})) { $i++; next; }
	if ($i == $auth_user_field) { $i++; next; }

	# ignore blank lines:  /^\s*$/
	if ($in{$column} !~ /^\s*$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($in{$column}) or return "Invalid date format: '$in{$column}'");
            push(@search_fields, $i); $i++; next; 
	}
	else {
	    push (@search_fields, $i);		# Search every column			
   	    $in{$column} = $in{'keyword'};	# Fill %in with keyword we are looking for.
	}
	$i++;
    }
}
else {			# Otherwise this is a regular search, and we only want records
    $i = 0;		# that match everything the user specified for.

    foreach $column (@db_cols) {
	# ignore blank lines:  /^\s*$/
	if ($in{$column} !~ /^\s*$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($in{$column}) or return "Invalid date format: '$in{$column}'");
            push(@search_fields, $i); $i++; next; 
	}
        $i++;
    }
}

# If we don't have anything to search on, let's complain.

    if (!@search_fields) {
	return "no search terms specified";
    }
	
# Define the maximum number of hits we will allow, and the next hit counter.	

    $in{'mh'} ?	($maxhits = $in{'mh'}) : ($maxhits = $db_max_hits);
    $in{'nh'} ? ($nh      = $in{'nh'}) : ($nh      = 1);
    $numhits = 0;

# Let's set restricted to 1 if the user can only view/mod their own and
# this isn't an admin.

    ($restricted = 1) if ($_[0] eq "view" and $auth_view_own and !$per_admin);
    ($restricted = 1) if ($_[0] eq "mod"  and $auth_modify_own and !$per_admin);

# Now let's build up all the regexpressions we will use. This saves the program
# from having to recompile the same regular expression every time.

    foreach $field (@search_fields) {
	my $tmpreg = "$in{$db_cols[$field]}";
	(!$in{'re'}) and ($tmpreg = "\Q$tmpreg\E");
	($in{'ww'})  and ($tmpreg = "\\b$tmpreg\\b");
	(!$in{'cs'}) and ($tmpreg = "(?i)$tmpreg");
	($in{$db_cols[$field]} eq "*") and ($tmpreg = ".*");	# A "*" matches anything.
		
	$regexp_func[$field] = eval "sub { m/$tmpreg/o }";
	$regexp_bold[$field] = $tmpreg;
    }

# Now we go through the database and do the actual searching.	
# First figure out which records we want:

    $first = ($maxhits * ($nh - 1));
    $last  =  $first + $maxhits - 1;
	
    open (DB, "<$db_file_name") or &cgierr("error in search. unable to open database: $db_file_name.\nReason: $!");
    if ($db_use_flock) { flock(DB, 1); }	
    LINE: while (<DB>) {
	(/^#/)      and next LINE;		# Skip comment Lines.
	(/^\s*$/)   and next LINE;		# Skip blank lines.
	$line = $_;	chomp ($line);		# Remove trailing new line.
	@values = &split_decode($line);

# If we are only allowed to view/mod our own record, then let's check here.
	next LINE if ($restricted and ($db_userid ne $values[$auth_user_field]));
		
# Normal searches.		
    $key_match = 0;
    foreach $field (@search_fields) {
        $_ = $values[$field];	# Reg function works on $_.
        $in{'ma'} ?	($key_match = ($key_match or &{$regexp_func[$field]})) :
	    (&{$regexp_func[$field]} or next LINE);
    }

# Did we find a match? We only add the hit to the @hits array if we need it. We can
# skip it if we are not sorting and it's not in our first < > last range.

    if ($key_match || (!($in{'keyword'}) && !($in{'ma'}))) {			
	if (exists $in{'sb'}) {
   	    $sortby{(($#hits+1) / ($#db_cols+1))} = $values[$in{'sb'}];				
	    push (@hits, @values); 
	}
    else {
	(($numhits >= $first) and ($numhits <= $last)) and push (@hits, @values);
    }
    $numhits++;		# But we always count it!
    }
}
close DB;
	
# Now we've stored all our hits in @hits, and we've got a sorting values stored
# in %sortby indexed by their position in @hits.

    $numhits ? ($db_total_hits = $numhits) : ($db_total_hits = 0);
    ($db_total_hits == 0) and return ("no matching records.");

# Sort the array @hits in order if we are meant to sort.

    if (exists $in{'sb'}) {	# Sort hits on $in{'sb'} field.
	my ($sort_order, $sort_func);
	$in{'so'} ? ($sort_order = $in{'so'}) : ($sort_order = "ascend");
	$sort_func = "$db_sort{$db_cols[$in{'sb'}]}_$sort_order";		
		
	foreach $hit (sort $sort_func (keys %sortby)) {
	    $first = ($hit * $#db_cols) + $hit; $last = ($hit * $#db_cols) + $#db_cols + $hit;			
	    push (@sortedhits, @hits[$first .. $last]);
	}
	@hits = @sortedhits;
    }	

# If we have too many hits, let's build the next toolbar, and return only the hits we want.

    if ($numhits > $maxhits) {	
	# Remove the nh= from the query string.		
	$next_url = $ENV{'QUERY_STRING'};
	$next_url =~ s/\&nh=\d+//;
	$next_hit = $nh + 1; $prev_hit = $nh - 1;

	# Build the next hits toolbar. It seems really complicated as we have to do
	# some number crunching to keep track of where we are on the toolbar, and so
	# that the toolbar stays centred.		

	# First, set how many pages we have on the left and the right.
	$left  = $nh; $right = int($numhits/$maxhits) - $nh;		

	# Then work out what page number we can go above and below.		
	($left > 7)  ? ($lower = $left - 7) : ($lower = 1);
	($right > 7) ? ($upper = $nh + 7)   : ($upper = int($numhits/$maxhits) + 1);

	# Finally, adjust those page numbers if we are near an endpoint.		
	(7 - $nh >= 0) and ($upper = $upper + (8 - $nh));
	($nh > ($numhits/$maxhits - 7)) and ($lower = $lower - ($nh - int($numhits/$maxhits - 7) - 1));
	$db_next_hits = "";

	# Then let's go through the pages and build the HTML.		
	($nh > 1) and ($db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$prev_hit">[<<]</a> ~);
	for ($i = 1; $i <= int($numhits/$maxhits) + 1; $i++) {
	    if ($i < $lower) { $db_next_hits .= " ... "; $i = ($lower-1); next; }			
	    if ($i > $upper) { $db_next_hits .= " ... "; last; }
	    ($i == $nh) ?
		($db_next_hits .= qq~$i ~) :
		($db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$i">$i</a> ~);
		if (($i * $maxhits) >= $numhits) { last; }  # Special case if we hit exact.
	}
	$db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$next_hit">[>>]</a> ~ unless ($nh == $i);
		
	# Slice the @hits to only return the ones we want, only have to do this if the results are sorted.
	if (exists $in{'sb'}) {			
	    $first = ($maxhits * ($nh - 1)) * ($#db_cols+1);
	    $last  =  $first + (($#db_cols+1) * $maxhits) - 1;		
	    $last = $#hits if ($last > $#hits);
	    @hits = @hits[$first .. $last];
	}
    }
	
    # Bold the results 
    if ($db_bold and $in{'view_records'}) {
	for $i (0 .. (($#hits+1) / ($#db_cols+1)) - 1) {
	    $offset = $i * ($#db_cols+1);
	    foreach $field (@search_fields) {				
		$hits[$field + $offset] =~ s,(<[^>]+>)|($regexp_bold[$field]),defined($1) ? $1 : "<B>$2</B>",ge;
	    }
	}
    }
    return ("ok", @hits);
}

#*******************************************
#**
#**  SORTING FUNCTIONS
#**
#*******************************************
# These are the sorting functions used in &query.
# --------------------------------------------------------------------------
sub alpha_ascend  { lc($sortby{$a}) cmp lc ($sortby{$b}) }
sub alpha_descend { lc($sortby{$b}) cmp lc ($sortby{$a}) }
sub numer_ascend  { $sortby{$a} <=> $sortby{$b} }
sub numer_descend { $sortby{$b} <=> $sortby{$a} }
sub date_ascend   { &date_to_unix($sortby{$a}) <=> &date_to_unix($sortby{$b}) }
sub date_descend  { &date_to_unix($sortby{$b}) <=> &date_to_unix($sortby{$a}) }

1;
