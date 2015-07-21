# wtDownload.pl

################################
##
##  	COMPILE ADS
##
################################
sub compileAds {
	# Open ads.db and write all of them, line by line, to the browser. Instruct the admin user
	# to save the display as a textfile on their local drive.

	open (ADS, "<ads.db") or &cgierr ("Unable to open ads database.\nReason: $!");
	if ($db_use_flock) { flock(ADS,1); }

	&html_print_headers;

	print "Raw Data Download\n";
	print "===================================================================================\n";
	print "Below is the raw data for all Directory Listings for all trading systems managed\n";
	print "through this software installation. You need to save this data to your local hard\n";
	print "drive. Choose 'File / Save As' from your browser window, give the file a name, and\n";
	print "set 'Save As Type' to 'Text File'. You can then load the data into external\n";
	print "software such as MS Access, Word, Quattro Pro, Wordperfect, etc. (after deleting\n";
	print "these comments). It's helpful to design and re-use a template or report using your\n";
	print "external software, so that the data can be easily printed in a newsletter format.\n";
	print "The data fields are:\n";
	print "===================================================================================\n";
	print "Record Number | Listing Author's User ID | Unused Field | Trading system Name | Ad Category | Text of the Listing | Permanent Listing? | Offered / Wanted |	Entry Date | Email | URL | Phone Number | Unused Field | System ID\n";
	print "===================================================================================\n";
	print "The actual data follows below:\n";
	print "===================================================================================\n";
			
	LINE: while (<ADS>) {
		next if /^#/; next if /^\s*$/;		# ignore comment and blank lines
		$line = $_;	chomp ($line);		
		print "$line\n";
	}
	close ADS;
}

##########################################################
## 
##		DOWNLOAD
##
##########################################################
sub download {

&html_print_headers;
$sysName = &getSystemName($sysID);

print  qq|
<html><head><title></title></head>
<body BGCOLOR="#C0C0C0" LINK="white" VLINK="white" ALINK="white">
<table border=0 bgcolor="#FFFFFF" cellpadding=0 cellspacing=3 width=620 align=center valign=top>
    <tr>
		<td width="91%"><$fontLarge2>Download $sysName Data</FONT></td>
		<td bgcolor="#009900" align=center><$font><b><a href="$helpURL#download">Help</a></b></font></td>
	</tr>
	<tr>
		<td colspan=2>
			<$font><br>
				Use this screen to download current directory listings, for loading into 
				external software.
			</font>
		</td>
	</tr>
	<tr>
		<td bgcolor="#999999" colspan=2><br>
			<ul>
			<li><a href="$db_script_link_url&compileAds=1"><$font><b>Download Ad Directory</b></font></a></li>
			<!--
			<li><a href="trades"><$font><b>Download Transactions</b></font></a></li>
			-->
			</ul>
		</td>
	</tr>
	<tr><td colspan=2>|; &html_footer; print qq| </td></tr>
</table> 
</body>
</html>
|;
}
1;
