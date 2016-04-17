#!/usr/bin/perlml

#grabs API from every user

use CGI::Carp qw( fatalsToBrowser );
use utf8;
#no utf8;
use CGI;
use DBI;


BEGIN
{	
	$q = new CGI;
	print "Content-Type: text/html\n\n";
	
	my $dbh = DBI->connect("DBI:mysql:database=database;host=localhost", "USERNAME", "PASSWORD", 
            {'RaiseError' => 1});

    my $sth1 = $dbh->prepare("SELECT `api` FROM `rosters` WHERE race = 'Update'");
    $sth1->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbgApi) = $sth1->fetchrow_array())
    {
		$apiData = `curl -s "$dbgApi"`;
		($userRace) = ($apiData =~ /primaryRace[^:]*:([^,]+)/);
		$userRace =~ s/ "//g;
		$userRace =~ s/"//g;

		my $sth2 = $dbh->prepare("UPDATE `rosters` SET `race` = ?, `active` = 'Yes' WHERE `api` = ?");
		$sth2->execute($userRace, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
		#print $apiData;
    }

    my $sth2 = $dbh->prepare("SELECT `api` FROM `rosters` WHERE active = 'Yes'");
    $sth2->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbgApi) = $sth2->fetchrow_array())
    {
    	$dbgApi2 = $dbgApi;
    	$rand = rand();
    	$dbgApi2 =~ s/\?locale\=en\_US/ladders\?locale\=en\_US/g;
		$apiData = `curl -s "$dbgApi2&rand=$rand"`;
		$apiData =~ s/currentSeason/Ω/g;
		$apiData =~ s/previousSeason/≈/g;
		($apiDatatree) = ($apiData =~ /[^Ω]*Ω([^≈]+)/);
		print $apiDatatree;

		$apiDatatree =~ s/\[/\</g;
		$apiDatatree =~ s/\]/\>/g;
		# shoot me plz
		$alpha = 0;
	SEQAN:
		($userChunk) = ($apiDatatree =~ /[^\{]*\{([^\}]+)/);
		if($userChunk =~ /^()$/)
		{
			$usersLeague = "UNRANKED";
		}
		$userChunk = "{".$userChunk."}";
		if($userChunk =~ m/LOTV_SOLO/)
		{
			#print "use this chunk!".$userChunk;
			($usersLeague) = ($userChunk =~ /league[^:]*:([^,]+)/);
			$usersLeague =~ s/(\ \")//g;
			$usersLeague =~ s/\"//g;
			print $usersLeague;

			#print $userChunk;
			($usersWins) = ($userChunk =~ /wins[^:]*:([^,]+)/);
			$usersWins =~ s/( )//g;
			print $usersWins;

			($usersLosses) = ($userChunk =~ /losses[^:]*:([^,]+)/);
			$usersLosses =~ s/( )//g;
			print $usersLosses;
		}
		else
		{
			$apiDatatree =~ s/$userChunk//g;
			$alpha = $alpha + 1;
			if($alpha =~ /^(2000)$/)
			{
				$usersLeague = "UNRANKED";
			}
			else
			{
				goto SEQAN;
			}
		}
NOTRANKED:
		if($usersLeague =~ /^(|UNRANKED)$/)
		{
			$usersLeague = "8UNRANKED";
			$usersWins = 0;
			$usersLosses = 0;
		}

		if($usersLeague =~ /^(BRONZE)$/)
		{
			$usersLeague = "7".$usersLeague;
		}
		if($usersLeague =~ /^(SILVER)$/)
		{
			$usersLeague = "6".$usersLeague;
		}
		if($usersLeague =~ /^(GOLD)$/)
		{
			$usersLeague = "5".$usersLeague;
		}
		if($usersLeague =~ /^(PLATINUM)$/)
		{
			$usersLeague = "4".$usersLeague;
		}
		if($usersLeague =~ /^(DIAMOND)$/)
		{
			$usersLeague = "3".$usersLeague;
		}
		if($usersLeague =~ /^(MASTER)$/)
		{
			$usersLeague = "2".$usersLeague;
		}
		if($usersLeague =~ /^(GRANDMASTER)$/)
		{
			$usersLeague = "1".$usersLeague;
		}


		my $sth2 = $dbh->prepare("UPDATE `rosters` SET `league` = ?, `1win` = ?, `1loss` = ? WHERE `api` = ?");
		$sth2->execute($usersLeague, $usersWins, $usersLosses, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
    }

    $dbh->disconnect();
       
	open(STDERR, ">&STDOUT");
}