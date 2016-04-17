#!/usr/bin/perlml

# we have old roster data in current DB. (thanks to parseAndInsert.pl)
# This script will update our new rosters will old roster data.
# old roster have ucoz profile link, it'll insert that link into new roster

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;

BEGIN
{	
	$q = new CGI;
	$password = $q->param("password");
	print "Content-Type: text/html\n\n";
	
if($password !~ /^(yes)$/)
{
	print qq
	{
		<!DOCTYPE html>
		<html>
		<body>
			<p>Process has been previously completed, are you sure you want to run again?</p>
			<form method="post">
				<input type="text" name="password" placeholder="yes"/>
				<input type="submit" value="submit"/>
			</form>
		</body>
		</html

	};
	exit;
}
	my $dbh = DBI->connect("DBI:mysql:database=database;host=localhost", "Username", "Password", 
    	{'RaiseError' => 1});

    my $sth = $dbh->prepare("SELECT `username` FROM `rosters`");
    $sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbg_username) = $sth->fetchrow_array())
    {
		my $sth2 = $dbh->prepare("SELECT `ucoz`, `rank`, `cfstreamname`, `cfgroup` FROM `oldroster` WHERE name = ?");
		$sth2->execute($dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		while(my($dbg_ucoz, $dbg_rank, $dbg_cfstreamname, $dbg_cfgroup) = $sth2->fetchrow_array())
    	{
    		$dbg_cfgroup =~ s/ //g;
    		$dbg_rank =~ s/ //g;
    		$dbg_cfstreamname =~ s/ //g;
    		$dbg_ucoz =~ s/ //g;
	    	my $sth3 = $dbh->prepare("UPDATE `rosters` SET `ucoz` = ?, `rank` = ?, `stream` = ?, rgroup = ? WHERE `username` = ?");
	    	$sth3->execute($dbg_ucoz, $dbg_rank, $dbg_cfstreamname, $dbg_cfgroup, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    }
	    print ">Updated".$dbg_username."<br/>\n";
    }
    $dbh->disconnect();
       
	open(STDERR, ">&STDOUT");
}