#!/usr/bin/perl

use CGI;
use DBI;

BEGIN {	
	$q = new CGI;
	print "Content-Type: text\n\n";
       
	open(STDERR, ">&STDOUT");
}

my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
#my $sth1 = $dbh->prepare("UPDATE rosters SET league = ?");
#$sth1->execute("NONE");

@clans = ("ConFD", "ConFed"); #"ConFed", 

for(my $i = 0; $i < scalar @clans; $i++) {
	#print @clans[$i];
	
	$request = `curl -s -A "email me if issues: ilankleiman@gmail.com" http://www.rankedftw.com/clan/@clans[$i]/mmr/`;
	
	#clean $request
	# remove the first two tr tags which contain data we don't want to deal with
	$request =~ s/\<tr\>//;
	$request =~ s/\<\/tr\>//;
	
	# now the rest of the page has the useful data in <tr *></tr> tags, we'll pass the data into a function which'll recursively execute until no more <tr> tags exist
	processChunks($request, 0, @clans[$i]);
	#($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
}

# will get the data once for every tr tag (user)
# after handling data, will remove <tr *>*</tr> once, then call itself recursively.
sub processChunks {
	my ($data, $calls, $clan) = @_;
	
	#top single user data
	($singleUser) = ($data =~ /onclick[^"]*"([^\%]+)/);
	
	#get corresponding BNET link
	($link) = ($singleUser =~ /location[^\']*\'([^\;]+)/); #'
	$link =~ s/\'//; #'
	$teamView = `curl -A 'email me if issues: ilankleiman@gmail.com' -s 'http://rankedftw.com${link}#td=region&ty=r&ra=best&tyz=0&tx=a&tl=1' -L`;
	$teamView =~ s/Player page/Playerpage/;
	($RFTWprofile) = ($teamView =~ /Playerpage[^\"]*\"([^>]+)/); #"
	($RFTWprofile) = ($RFTWprofile=~ /href[^\/]*\/([^"]+)/); #"
	$actualRFTW = `curl -A 'email me if issues: ilankleiman@gmail.com' -s "http://rankedftw.com/$RFTWprofile" -L`;
	($profileBnet) = ($actualRFTW =~ /bnet-link[^\"]*\"([^"]+)/); #"

	#get race
	($race) = ($singleUser =~ /race[^\=]*\=([^\>]+)/);
	$race =~ s/\"\/static\/375c5b1\/img\/races\///;#"
	$race =~ s/\-16x16\.png\" \///; #"
	$race = uc($race);
	
	#get league
	($league) = ($singleUser =~ /league[^\/]*\/([^\>]+)/);
	$league =~ s/static\/375c5b1\/img\/leagues\///g;
	$league =~ s/\-16x16\.png\" \///g; #"
	$league = uc($league);
	
	#get league tier
	$singleUser =~ s/\<td class\=\"img\"\>//; #"
	$singleUser =~ s/\<td class\=\"img\"\>//; #"
	($leagueTier) = ($singleUser =~ /img[^>]*>([^<]+)/);
	
	#quick jump
	$singleUser =~ s/\<td class\=\"number\"\>//;#"
	
	#get MMR
	($userMMR) = ($singleUser =~ /number[^>]*>([^<]+)/);
	
	#quick jump
	$singleUser =~ s/\<td class\=\"number\"\>//;#"
	$singleUser =~ s/\<td class\=\"number\"\>//;#"
	
	#get wins
	($userWins) = ($singleUser =~ /number[^>]*>([^<]+)/);
	
	#quick jump
	$singleUser =~ s/\<td class\=\"number\"\>//;#"
	
	#get losses
	($userLosses) = ($singleUser =~ /number[^>]*>([^<]+)/);
	
	#get losses
	($userName) = ($singleUser =~ /name[^>]*>([^<]+)/);
	
	# bnet of user 
	# league
	# league tier
	# MMR
	# wins
	# losses
	# username
	
	# http://us.battle.net/sc2/en/profile/3801254/1/Shortland/
	# https://us.api.battle.net/sc2/profile/3801254/1/Shortland/?locale=en_US&apikey=p
	$profileBnet =~ s/http:\/\/us/https:\/\/us\.api/;
	$profileBnet = $profileBnet."?locale=en_US&apikey=p";
	
	if($league =~ /^(GRANDMASTER)$/) {
		$league = "1".$league;
	}
	if($league =~ /^(MASTER)$/) {
		$league = "2".$league;
	}
	if($league =~ /^(DIAMOND)$/) {
		$league = "3".$league;
	}
	if($league =~ /^(PLATINUM)$/) {
		$league = "4".$league;
	}
	if($league =~ /^(GOLD)$/) {
		$league = "5".$league;
	}
	if($league =~ /^(SILVER)$/) {
		$league = "6".$league;
	}
	if($league =~ /^(BRONZE)$/) {
		$league = "7".$league;
	}
	if($league =~ /^(UNRANKED)$/) {
		$league = "8".$league;
	}
	
	updateUser($profileBnet, $league, $leagueTier, $userMMR, $userWins, $userLosses, $userName, $clan, $race);
	
	if($calls <= 100) {
		$data =~ s/onclick//;
		print $calls;
		
		if (index($data, "onclick") != -1) {
			return processChunks($data, ($calls+1), $clan);
		}
	}
}

sub updateUser {
	my ($bnet, $league, $tier, $mmr, $wins, $losses, $name, $clan, $race) = @_;
	
	#my $sth0 = $dbh->prepare("SELECT `seasonGamesUpdate` FROM `rosters` WHERE `api` = ?");
	#$sth0->execute($bnet) or die "Couldn't execute statement: $DBI::errstr; stopped";
	#while(my($lastUpdate) = $sth0->fetchrow_array()) {
		#if((time() - $lastUpdate) >= 30) {
		#	print "yes update";
			my $sth = $dbh->prepare("INSERT INTO rosters (race, api, username, clantag, rank, rgroup, league, tier, mmr, 1win, 1loss, seasonGames, seasonGamesUpdate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE clantag = ?, league = ?, tier = ?, mmr = ?, 1win = ?, 1loss = ?, seasonGames = ?, seasonGamesUpdate = ?");
	
			$sth->execute($race, $bnet, $name, $clan, "22CrewMember", "Members", $league, $tier, $mmr, $wins, $losses, ($wins + $losses), time(), $clan, $league, $tier, $mmr, $wins, $losses, ($wins + $losses), time()) or die "Couldn't execute statement: $DBI::errstr; stopped";	
		#}
		#else {
		#	print "no update";
		#}
	#}
	
	
	
}

#print "Hello world" . $request;