#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;

BEGIN
{	
	$q = new CGI;
	print "Content-Type: text/html\n\n";
	
my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});

    my $sth = $dbh->prepare("SELECT `username` FROM `rosters` WHERE `api` = 'queue'");
    $sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbg_username) = $sth->fetchrow_array())
    {
		$api = `curl -s "http://teamconfed.com/api/roster.pl?username=$dbg_username"`;
		if($api =~ /https/) #f8
		{
			my $sth2 = $dbh->prepare("UPDATE `rosters` SET `api` = ? WHERE `username` = ?");
        		$sth2->execute($api, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		}
		else
		{
			my $sth2 = $dbh->prepare("UPDATE `rosters` SET `error` = ? WHERE `username` = ?");
        		$sth2->execute($api, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		}
    }
    $dbh->disconnect();
       
	open(STDERR, ">&STDOUT");
}