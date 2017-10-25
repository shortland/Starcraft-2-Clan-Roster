#!/usr/bin/perl

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
	
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});

#     my $sth1 = $dbh->prepare("SELECT `api` FROM `rosters` WHERE `race` = 'Update' OR `race` = ''");
#     $sth1->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

# # this updates played race
#     while(my($dbgApi) = $sth1->fetchrow_array())
#     {
# 		$apiData = `curl -s "$dbgApi"`;
# 		($userRace) = ($apiData =~ /primaryRace[^:]*:([^,]+)/);
# 		$userRace =~ s/ "//g;
# 		$userRace =~ s/"//g;

# 		my $sth2 = $dbh->prepare("UPDATE `rosters` SET `race` = ? WHERE `api` = ?");
# 		$sth2->execute($userRace, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
#     }

    my $sth0 = $dbh->prepare("SELECT `api` FROM `rosters` WHERE `username` != 'Meatshield'");
    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

# this updates clantag, bnetpic, and the offsets of the pic
    while(my($dbgApiG) = $sth0->fetchrow_array())
    {
    ## this whole chunk gets commented if blizzard API gets fucked for a long time. use "non-official api" kappa
		# $apiDataG = `curl -s "$dbgApiG"`;
		# ($dbgResponseTag) = ($apiDataG =~ /clanTag[^:]*:([^,]+)/);
		# $dbgResponseTag =~ s/ "//g;
		# $dbgResponseTag =~ s/"//g;

		# ($bnetPic) = ($apiDataG =~ /url[^:]*:([^,]+)/);

		# $bnetPic =~ s/http:\/\/media\.blizzard\.com\/sc2\/portraits//g;
		# ($bnetPic) = ($bnetPic =~ /[^\/]*\/([^-]+)/);

		# ($bnetXoff) = ($apiDataG =~ /"x"[^:]*:([^,]+)/);
		# $bnetXoff =~ s/ //g;

		# ($bnetYoff) = ($apiDataG =~ /"y"[^:]*:([^,]+)/);
		# $bnetYoff =~ s/ //g;

	## begin the non-official api
		#https://us.api.battle.net/sc2/profile/3801254/1/Shortland/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
		#https://us.battle.net/sc2/profile/3801254/1/Shortland/

# get current clantag
		$rawAPI = $dbgApiG;
		$rawAPI =~ s/\.api//g;
		$rawAPI =~ s/\?locale\=en\_US&apikey\=93gu3nyp757ybrg224z8qjs23cj8en4d//g;
		$rawOutput = `curl -L "$rawAPI"`;

		$crapml = "clan-tag";
		($dbgResponseTag) = ($rawOutput =~ /$crapml[^>]*>([^<]+)/);
		$dbgResponseTag =~ s/\[//g;
		$dbgResponseTag =~ s/\]//g;

		($bnetPic) = ($rawOutput =~ /http\:\/\/media\.blizzard\.com\/sc2\/portraits[^\/]*\/([^\.]+)/);
		$bnetPicN = substr($bnetPic, 0, 1);

		($bnetXYData) = ($rawOutput =~ /http\:\/\/media\.blizzard\.com\/sc2\/portraits[^\)]*\)([^\;]+)/);
		#print $bnetXYData."< xy off\n";

		$bnetXYData =~ s/px//g;
		$bnetXYData =~ s/no-repeat//g;
		$bnetXYData =~ s/ /#/g;
		$bnetXYData =~ s/#//;

		# find the x value
		for($i = 0; $i < length($bnetXYData); $i++)
		{
			$charAt = substr($bnetXYData, $i, 1);
			if($charAt =~ '#')
			{
				#print $i."at this position";
				$bnetXoffz = substr($bnetXYData, 0, $i);
				$bnetXYData =~ s/$bnetXoffz//g;
				last;
			}
		}
		$bnetXYData =~ s/#//g;

		# x off
		$bnetXoffz =~ s/-//g;
		# y off
		$bnetXYData =~ s/-//g;
		

		# actual image src
		$xdiff = ($bnetXoffz / 90);

		$ydiff = ($bnetXYData / 90) * 6;

		$combinedDiff = $xdiff + $ydiff;

		$bnetPicSrc = "http://media.blizzard.com/sc2/portraits/".$bnetPicN."-".$combinedDiff.".jpg";

		my $sth01 = $dbh->prepare("UPDATE `rosters` SET `clantag` = ?, `bnetPic` = ?, `bnetXoff` = ?, `bnetYoff` = ?, `bnetPicSource` = ? WHERE `api` = ?");
		$sth01->execute($dbgResponseTag, $bnetPicN, $bnetXoffz, $bnetXYData, $bnetPicSrc, $dbgApiG) or die "Couldn't execute statement: $DBI::errstr; stopped";
    }

    my $sth2 = $dbh->prepare("SELECT `api`, `username` FROM `rosters` WHERE `username` != 'Meatshield'"); # instead of `active` = 'Yes'
    $sth2->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($dbgApi, $dbgName) = $sth2->fetchrow_array())
    {
    	$rawAPI = $dbgApi;
		#$apiUgh = "";
		$rawAPI =~ s/\.api//g;
		$rawAPI =~ s/\?locale\=en\_US&apikey\=93gu3nyp757ybrg224z8qjs23cj8en4d//g;

		$rawOutput = `curl -s -L '$rawAPI'`;
		# badge badge-
		$badgeBadge = "badge badge";
		($usersLeague) = ($rawOutput =~ /$badgeBadge[^-]*-([^ ]+)/);
		#print $usersLeague."<<\n";
		$usersLeague = uc($usersLeague);
		#print $usersLeague."<<\n";

#     	$dbgApi2 =~ s/\?locale\=en\_US/ladders\?locale\=en\_US/g;
# 		$apiData = `curl -s "$dbgApi2"`;
# 		$apiData =~ s/currentSeason/Ω/g;
# 		$apiData =~ s/previousSeason/≈/g;
# 		($apiDatatree) = ($apiData =~ /[^Ω]*Ω([^≈]+)/);
# 		#print $apiDatatree;
# 		$apiDatatree =~ s/\[/\</g;
# 		$apiDatatree =~ s/\]/\>/g;
# 		# shoot me plz
# 		$alpha = 0;
# 	SEQAN:
# 		($userChunk) = ($apiDatatree =~ /[^\{]*\{([^\}]+)/);
# 		if($userChunk =~ /^()$/)
# 		{
# 			$usersLeague = "UNRANKED";
# 		}
# 		$userChunk = "{".$userChunk."}";
# 		if($userChunk =~ m/LOTV_SOLO/)
# 		{
# 			#print "use this chunk!".$userChunk;
# 			($usersLeague) = ($userChunk =~ /league[^:]*:([^,]+)/);
# 			$usersLeague =~ s/(\ \")//g;
# 			$usersLeague =~ s/\"//g;
# 			print $usersLeague;

# 			#print $userChunk;
# 			($usersWins) = ($userChunk =~ /wins[^:]*:([^,]+)/);
# 			$usersWins =~ s/( )//g;
# 			print $usersWins;

# 			($usersLosses) = ($userChunk =~ /losses[^:]*:([^,]+)/);
# 			$usersLosses =~ s/( )//g;
# 			print $usersLosses;
# 		}
# 		else
# 		{
# 			$apiDatatree =~ s/$userChunk//g;
# 			$alpha = $alpha + 1;
# 			if($alpha =~ /^(2000)$/)
# 			{
# 				$usersLeague = "UNRANKED";
# 			}
# 			else
# 			{
# 				goto SEQAN;
# 			}
# 		}
# NOTRANKED:
		if($usersLeague =~ /^(UNRANKED)$/)
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

		my $sth2 = $dbh->prepare("UPDATE `rosters` SET `league` = ?, `1win` = ?, `1loss` = ?  WHERE `api` = ?");
		$sth2->execute($usersLeague, $usersWins, $usersLosses, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
    
# 		$searchUcoz = `curl -s 'http://the-confederation.net/forum' --data 'user=$dbgName&w=0&gender=0&group=0&sort=1&res=0&a=35&s=1'`;
#     	($ucozProfileLink) = ($searchUcoz =~ /http\:\/\/the\-confederation\.net\/index\/8[^-]*-([^']+)/);
#     	$ucozProfileLinkDMG = "http://the-confederation.net/index/8-".$ucozProfileLink;

#     	my $sth3 = $dbh->prepare("UPDATE `rosters` SET `ucoz` = ? WHERE `api` = ? AND `ucoz` = ''");
# 		$sth3->execute($ucozProfileLinkDMG, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";		
    }

#     my $sth4 = $dbh->prepare("SELECT `api` FROM `rosters`"); # instead of `active` = 'Yes'
#     $sth4->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

#     while(my($dbgApi, $dbgName) = $sth4->fetchrow_array())
#     {
#     	$dbgApiA = $dbgApi;
#     	$dbgApiA =~ s/\?/matches\?/g;
#     	$userMatchHistory = `curl -s "$dbgApiA"`;
#     	($recentGame) = ($userMatchHistory =~ /date[^:]*:([^}]+)/);
#     	my $sth5 = $dbh->prepare("UPDATE `rosters` SET `lastGame` = ? WHERE `api` = ?"); # instead of `active` = 'Yes'
#     	$sth5->execute($recentGame, $dbgApi) or die "Couldn't execute statement: $DBI::errstr; stopped";
#     }

    $dbh->disconnect();
	open(STDERR, ">&STDOUT");
}