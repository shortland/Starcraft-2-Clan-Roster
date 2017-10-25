#!/usr/bin/perl -

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;

BEGIN
{	
	$q = new CGI;
	print "Content-Type: text/html\n\n";
	
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});

    my $sth = $dbh->prepare("SELECT username FROM rosters");
    $sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbg_username) = $sth->fetchrow_array())
    {
    	my $sth3 = $dbh->prepare("SELECT name, league FROM everyone where name like '%$dbg_username%' and clan_tag = 'confed' or 'xcfx'");
	    $sth3->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    my $true=0;
	    my $mainLeague;
	    while(my($dbg_username2, $league) = $sth3->fetchrow_array()) {
	    	$true = 1;
	    	$mainLeague =$league;
	    }
	    if($true) {
	    	# yyay we found remo, update roster to his league
	    	if($mainLeague =~ /^bronze$/) {
	    		$mainLeague = "7BRONZE";
	    	}
	    	elsif($mainLeague =~ /^silver$/) {
	    		$mainLeague = "6SILVER";
	    	}
	    	elsif($mainLeague =~ /^gold$/) {
	    		$mainLeague = "5GOLD";
	    	}
	    	elsif($mainLeague =~ /^platinum$/) {
	    		$mainLeague = "4PLATINUM";
	    	}
	    	elsif($mainLeague =~ /^diamond$/) {
	    		$mainLeague = "3DIAMOND";
	    	}
	    	elsif($mainLeague =~ /^master$/) {
	    		$mainLeague = "2MASTER";
	    	}
	    	elsif($mainLeague =~ /^grandmaster$/) {
	    		$mainLeague = "1GRANDMASTER";
	    	}
	    	my $sth4 = $dbh->prepare("UPDATE `rosters` SET `league` = ? WHERE `username` = ?");
       		$sth4->execute($mainLeague, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    }
	    else {
	    	my $sth2 = $dbh->prepare("UPDATE `rosters` SET `league` = ?, `rgroup` = ? WHERE `username` = ?");
        	$sth2->execute("NONE", "Inactive", $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    }
    }
    $dbh->disconnect();
       
	open(STDERR, ">&STDOUT");
}