#!/usr/bin/perl

#grabs API from every user

use CGI::Carp qw( fatalsToBrowser );
use utf8;
use CGI;
use DBI;


BEGIN
{	
	$q = new CGI;
	print "Content-Type: text/html\n\n";
	
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
		
    my $sth2 = $dbh->prepare("SELECT `clantag`, `api` FROM `rosters`");
    $sth2->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($clantag, $dbgApi) = $sth2->fetchrow_array())
    {
    	if($clantag !~ /^(ConFD|ConFed|xCFx)$/)
    	{
    		#my $sth3 = $dbh->prepare("UPDATE `rosters` SET `rgroup` = 'Inactive' WHERE `api` = ?");
		#$sth3->execute($dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
    	}
    }

    my $sth1 = $dbh->prepare("SELECT `api` FROM `rosters`");
    $sth1->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbgApi) = $sth1->fetchrow_array())
    {
		$apiData = `curl -s "$dbgApi"`;
		($seasonGames) = ($apiData =~ /careerTotalGames[^:]*:([^,]+)/);
		$seasonGames =~ s/ "//g;
		$seasonGames =~ s/"//g;
		$seasonGames =~ s/ //g;
		print $seasonGames;

		my $sth2 = $dbh->prepare("SELECT `seasonGames` FROM `rosters` WHERE `api` = ?");
		$sth2->execute($dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";

		while(my($prevSeasonGames) = $sth2->fetchrow_array())
	    {
	    	if($seasonGames =~ /^($prevSeasonGames)$/)
	    	{
	    		# don't update the db w/ a new date
	    	}
	    	else
	    	{
				# update the db
	    		my $sth3 = $dbh->prepare("UPDATE `rosters` SET `seasonGames` = ?, `seasonGamesUpdate` = ? WHERE `api` = ?");
				$sth3->execute($seasonGames, time, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
				if($prevSeasonGames =~ /^(0)$/)
				{
					my $sth3 = $dbh->prepare("UPDATE `rosters` SET `seasonGames` = ?, `seasonGamesUpdate` = ? WHERE `api` = ?");
					$sth3->execute($seasonGames, "1464573273", $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
				}
	    	}
	    }
    }
    


    $dbh->disconnect();
	open(STDERR, ">&STDOUT");
}