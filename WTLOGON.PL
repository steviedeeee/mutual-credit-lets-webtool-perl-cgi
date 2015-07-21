# wtLogon.pl

##########################################################
##
##		LOGON   				
##
##########################################################
# ----------------------------------------------------------------------------------------------
sub html_login_form {

&html_print_headers;
print qq|
<html>
<head>
<title>iLETS Home</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}

function MM_findObj(n, d) { //v3.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document); return x;
}

function MM_jumpMenuGo(selName,targ,restore){ //v3.0
  var selObj = MM_findObj(selName); if (selObj) MM_jumpMenu(targ,selObj,restore);
}
//-->
</script>
</head>

<body bgcolor="#008800" text="#000000" link="#33CC00" vlink="#6666FF" alink="#FF0000" onLoad="document.form1.userid.focus()">

<form action="$db_script_url" method="post" name="form1">
	<input type=hidden name="db" value="$db_setup">
	<input type=hidden name="uid" value="$db_uid">

<table align=center bgcolor="white" border=1 cellspacing=1 cellpadding=4 width=600 height="639">
    <tr> 
      <td bgcolor="#000000" colspan="3" height="14"> <font face=verdana size=1 color=white>Version 
        2.11.24.2000. &nbsp;Program designed by <a href="mailto:cheesemelt@yahoo.com">Chris 
        Hohner</a>. &nbsp; Updated by our <a href="contributors.html">contributors</a>.&nbsp;</font></td>
    </tr>
    <tr> 
      <td align=left bgcolor="white" height="59" colspan="3"><img src="longlets.gif" width="301" height="43" align="left"> 
      </td>
    </tr>
    <tr> 
      <td align=left bgcolor="white" height="47" width="234"><font face="verdana" size="+1" color="black">1. 
        Select your Country. </font> 
      <td align=right bgcolor="white" height="47" colspan="2" width="339"> 
        <select name="select" onChange="MM_jumpMenu('parent',this,0)">
          <option value="country.html" selected>Australia</option>
          <option value="country.html">Canada</option>
          <option value="country.html">Ireland</option>
          <option value="country.html">Scotland</option>
			<option value="country.html">France</option>
			<option value="country.html">Germany</option>
<option value="country.html">Holland</option>
<option value="country.html">America</option>
        </select>
        <input type="button" name="Button1" value="Go" onClick="MM_jumpMenuGo('select','parent',0)">
    </tr>
<tr> 
      <td align=left bgcolor="white" width="234" height="128"> 
        <div align="left"> 
          <p><font face="verdana" size="+1" color="#00E100">Not up yet?</font></p>
          <p><font face="verdana" size="+1" color="black"><br>
            2. See the Demo.</font> </p>
        </div>
</td>
<td align="right" "bgcolor="white" width="339" height="128"> <font face="verdana" size="2" color="black"><b>Select 
        System:</b></font> 
        |; print &buildSystemList("sys"); print qq|
          </select><br>

<font face="verdana" size="2" color="black"> <b>Name:&nbsp;</b> 
          <b>(admin)</b> </font>
          <input type="TEXT" name="userid" size=14><br>
        
        <font face="verdana" size="2" color="black"><b>Password:</b> <b>(admin)&nbsp;</b></font>
          <input type="PASSWORD" name="pw" size=14><br>
        
          <input type="SUBMIT" name="login" value="  Log in  ">
          <font face="verdana" size="2" color="black">&nbsp;</font>
        </td>
    </tr>


<tr> 
      <td bgcolor="white" colspan="3" height="353"> <font face="verdana" size="+1" color="black">3. 
        Open <font color="#00BB00">I</font>-LETS</font><font face=verdana size=2> 
        in your country, and add your system.<br>
          <br>
          iLETS is a free, open-source, internet-based program which allows LETS 
          and other Mutual Credit trading groups to use the internet to enhance 
          and simplify their operations. The program allows for each user to have 
          multiple accounts, thus opening up the possibility for inter-local trade 
          using LETS credits.</font><br><br>
        <font face=verdana size=2>A single LETS may also use the software on 
          their own, to allow their members to post offers and requests to the 
          online Bulletin Board and place transactions between other members, 
          which can be downloaded into LETS software.<br><br>
        Each country will have its own iLETS program on its own server.<br>
To add your country and system to the iLETS network, <a href="mailto:iccs@indosat.net.id, stephen@lets.net">contact 
          us</a>.<br>
        </font> 
        <p><font face=verdana size=2>For more information, see: </font></p>
        <font face=verdana size=2> 
        <ul>
<li><a href="http://www.lets.net/ilets/about.html"><b>About iLETS</b></a></li>
          <li><a href="$downloadURL/download.html"><b>Installing 
           iLETS on Your Server</b></a></li>
          <li><a href="$downloadURL/LETSwebtool.zip"><b>Download 
            Source Code</b></a> 162 kb</li>
          <li><a href="http://www.lets.net/ilets/help.html"><b>iLETS User 
            Manual</b></a></li>
          <li><a href="http://www.skyport.com/cheesemelt/lets/webtool.cgi"><b>Home 
            of LETS webtool</b></a> (the mother program)</li>
        </ul>
        </font> </td>
    </tr>
  </table>
</form>
<font size="1">
<script language="JavaScript" type="text/javascript">
<!--		
	document.write("This site was last updated on " + document.lastModified)
// -->
</script>
</font>
</form>
</BODY>
</HTML>
|;
}

sub demoBlurb {
print qq|
|;
}

##########################################################
## 
##		MAIN MENU AFTER LOGON
##
##########################################################
sub html_home {

&html_print_headers;
print  qq|
<html><head><title></title></head>
<body BGCOLOR="#C0C0C0" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF">
<table border=1 bgcolor="#FFFFFF" cellpadding=5 cellspacing=3 width=640 align=center valign=top>
    <tr>
		<td>|;
			# We know we have the system ID at this point: $in{'sys'}. Get the system name.

			open (SYSTEMS, "<systems.db") or &cgierr ("Unable to open systems file.\nReason: $!");
			if ($db_use_flock) { flock(SYSTEMS, 1); }
			$found = 0;
			LINE: while (<SYSTEMS>) {		
				next if /^#/; 		# ignore comment lines
				next if /^\s*$/;	# ignore blank lines
				$line = $_;	chomp ($line);		
				@fields = &split_decode ($line);		# Build an array of fields.
				if ($fields[0] eq "$in{'sys'}") { 
					# Found the system record that matches system ID from Login.
					$sysName = $fields[2]; 
					$sysID = $in{'sys'};
					$found = 1; 
				}
			}
			close SYSTEMS;

			# Revert to the Demo if the system was not found.
			if (!$found) { 
				$sysID = -1; 
				$sysName = "Demo"; 
			}
			print qq|
		    <$fontLarge2>$sysName</FONT>
			<BR><$fontBlue>LETS webtool $version: <b>$db_userid</B> logged on.
			<BR><BR><BR><BR><BR>
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
##		LOGON FAILURE
##
##########################################################
sub html_login_failure {
# ----------------------------------------------------------------------------------------------
# There was an error logging in. The error message is stored in $message.

my ($message) = $_[0];
	
&html_print_headers;
print qq|
<html><head><title>$systemName: Logon Error.</title></head>
<body BGCOLOR="#C0C0C0" text="#000000" LINK="#FFFFFF" VLINK="#FFFFFF" ALINK="#FFFFFF" onLoad="document.form1.userid.focus()">

<form action="$db_script_url" method="post" name="form1">
	<input type=hidden name="db" value="$db_setup">
	<input type=hidden name="uid" value="$db_uid">	
	<table border=1 bgcolor="#FFFFFF" align=center cellpadding=5 cellspacing=3 width=640 valign=top>
		<tr>
			<td>
				<p><$fontLarge>Logon Error</font><br>
				<$font>
					Oops, there was a problem logging into the system: 
					<font color=red><b>$message</b>.</font>
					<br>Please try logging in again.
				</font>
				<p>
				<table border=0 align=right width=388 cellspacing=1 cellpadding=4>
					<tr>
						<td bgcolor="white" align=left>
							<$fontLarge>Logon to</font>
							|; print &buildSystemList("sys"); print qq|
						</td>
					</tr>
					<tr>
						<td align=right bgcolor="#cccccc">
							<$fontBlue><b>User ID </b></FONT>
							<input type="TEXT" name="userid" value="$in{'userid'}">
						</td>
					</tr>
					<tr>
						<td align=right bgcolor="#cccccc">
							<$fontBlue><b>Password </b></FONT>
							<input type="PASSWORD" name="pw" value="$in{'pw'}">
						</td>
					</tr>
					<tr>
						<td align=right bgcolor="#009900">
							<input type="SUBMIT" name="login" value="Logon">
							<INPUT TYPE="SUBMIT" NAME="logoff" VALUE="Cancel">
						</td>
					</tr>
				</table>		
			</td>
		</tr>
	</table>
</form>
</body>
</html>
|;
}
1;
