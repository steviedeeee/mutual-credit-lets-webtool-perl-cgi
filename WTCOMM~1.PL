# wtCommonHTML.pl 
# ----------------------------------------------------------------------------------------------
# FONTS
# ----------------------------------------------------------------------------------------------
$font 			= "font face=verdana size=2";
$fontMid		= "font face=verdana size=3";
$fontSmall		= "font face=verdana size=1";
$fontSmallWhite	= "font face=verdana size=1 color=white";
$fontWhite  	= "font face=verdana size=2 color=white";
$font_title 	= "font face=verdana size=4";
$fontLarge 		= "font face=verdana SIZE=+2";
$fontLarge2		= "font face=Arial SIZE=5";
$fontLargeWhite = "font face=verdana SIZE=+2 color=white";
$fontBlue 		= "font face=verdana Size=2 Color='#003399'";
# ----------------------------------------------------------------------------------------------
# TABLE COLUMN STYLES
# ----------------------------------------------------------------------------------------------
# right-aligned column, green background, text aligned top, width=20%
$tdGreyRight    = "td bgcolor='#999999' align=right valign=center width='150'";
$tdGreyRightTop = "td bgcolor='#999999' align=right valign=top width='150'";
$tdGreyLeft     = "td bgcolor='#cccccc' valign=center";
$tdBeigeRight   = "td bgcolor='#ffffcc' align=right width=200";	# right-aligned, pale yellow
$tdBeigeLeft    = "td bgcolor='#ffffcc'";						# left-aligned, pale yellow
$tdWhiteLeft    = "td bgcolor=white";							# left-aligned, white
$tdBeigeLeftColspan2 = "td bgcolor='#ffffcc' colspan=2";		# left-aligned, pale yellow
$tdWhiteRight 		 = "td bgcolor=white align=right";			# right-aligned, white
$tdWhiteLeftColspan2 = "td bgcolor=white colspan=2";
# ----------------------------------------------------------------------------------------------
# TABLE STYLES
# ----------------------------------------------------------------------------------------------
$innerTable = 'TABLE WIDTH=585 CELLPADDING=3 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" ALIGN=CENTER';
$inner2Table = 'TABLE WIDTH=620 CELLPADDING=5 CELLSPACING=1 BORDER=0 BGCOLOR="#cccccc" ALIGN=CENTER';

##########################################################
##
##		UNAUTHORIZED ACTION
##
##########################################################
sub html_unauth {
# ----------------------------------------------------------------------------------------------
# A user tried to do something s/he was not authorized for.

&html_print_headers;
print qq|
<html><head><title>$systemName: Error! Unauthorized Action.</title></head>

<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<table border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 valign=top align=center>
	<tr>
		<td>
			<$fontLarge>Error: <font color=red>Unauthorized Action</font></font><br>
			<$font>The software received a command you are not authorized to perform.</font>
			<br><br><br>
			|; &html_footer; print qq|
		</td>
	</tr>
</table>
</body>
</html>
|;
}

##########################################################
##
##		UNKNOWN ACTION
##
##########################################################
sub html_unkown_action {
# ----------------------------------------------------------------------------------------------
# The program received a command it did not recognize.

&html_print_headers;
print qq|
<html><head><title>$html_title: Error! Unknown Action</title></head>
<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<table border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 align=center valign=top>
    <tr>
		<td>
			<$fontLarge>Error: <font color=red>Unknown Action</font></font><br>
			<$font>The software received a command that it did not understand.</font>
			<br><br><br>
			|; &html_footer; print qq|
		</td>
	</tr>
</table>
</body>
</html>
|;
}

##########################################################
##
##		PRINT HTML HEADERS
##
##########################################################
sub html_print_headers {
# ----------------------------------------------------------------------------------------------
	# Print out the headers if they haven't already been printed.
	if (!$html_headers_printed) {		
		print "Content-type: text/html\n\n";
		$html_headers_printed = 1;
	}
}
1;
