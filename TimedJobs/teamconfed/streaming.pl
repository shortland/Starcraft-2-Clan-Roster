#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;
use JSON qw( decode_json );

BEGIN {	
	$cgi = new CGI;
	$method = $cgi->param("method");
	print $cgi->header;
    
	open(STDERR, ">&STDOUT");
}

my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
print '<!DOCTYPE html>
<html>
<head>
	<title>Streaming</title>
</head>
<body>';
if (( !defined $method) || ($method eq "")){
	print '
		<style>
		@import url(https://fonts.googleapis.com/css?family=Lato:300);
		* {
			color: rgba(255, 255, 255, 1.0);
			font-family: "Lato", sans-serif;
			font-weight: 300;
		}

		#addOwn {
			cursor: pointer;
			text-decoration: underline;
		}

		a {
			color: rgba(100, 255, 0, 1.0);
		}
		</style>
		<center>
	';
        
    $streamLink = "none";

    my $sth0 = $dbh->prepare("SELECT `stream`, `username` FROM `rosters` WHERE `streamActive` = 'active'");
    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    while(my($streamName, $usernameG) = $sth0->fetchrow_array()) {
		$streamLink = "http://twitch.tv/" . $streamName;
		
		$gamePlaying = getGamePlaying(getUserID($streamName));
		if($gamePlaying =~ /^()$/) {
			$gamePlaying = "unnamed game";
		}
		print "<a href='$streamLink' target='_blank'>" . $usernameG . "</a> playing " . $gamePlaying . "\n<br/>\n"; #":
    }

    if($streamLink =~ /^(none)$/) {
		print "No live streams<br/>\n";
    }
        
	sub getUserID {
		my ($username) = @_;

		my $res = `curl -s -H 'Accept: application/vnd.twitchtv.v5+json' -H 'Client-ID: clientIDHERE' -X GET https://api.twitch.tv/kraken/users?login=$username`;
		my $decoded = decode_json($res);
		my $userID = $decoded->{'users'}[0]{'_id'} . "\n";
		return $userID;
	}
	
	sub getGamePlaying {
		my ($userID) = @_;

		my $res = `curl -s -H 'Accept: application/vnd.twitchtv.v5+json' -H 'Client-ID: clientIDHERE' -X GET https://api.twitch.tv/kraken/streams/$userID`; 
		$res =~ s/null/"null"/g;
		my $decoded = decode_json($res);
		my $isLive = $decoded->{'stream'};
		my $game = $decoded->{'stream'}{'game'};
		
		if($isLive =~ /^(null)$/) {
			return -1;
		}
		else {
			return $game;
		}
	}

        print "<br/><div id='addOwn' onClick='gotoForum()'>Add Yours</div>";
        print qq {
            </center>
            <script>
            function gotoForum() {
                top.window.location.href = 'http://the-confederation.net/forum/2-3878-1';
            }
            </script>
        };
        $dbh->disconnect();
	}
	
if($method =~ /^(update)$/) {
	my $sth1 = $dbh->prepare("SELECT `stream`, `username` FROM `rosters` WHERE `rgroup` != 'Inactive' AND `stream` != ''");
	$sth1->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	
	while(my($streamName, $usernameG) = $sth1->fetchrow_array()) {
		$gamePlaying = getGamePlaying(getUserID($streamName));
		
		if($gamePlaying =~ /^(-1)$/) {
			my $sth2 = $dbh->prepare("UPDATE `rosters` SET `streamActive` = 'inactive' WHERE `username` = ? AND `stream` = ?");
			$sth2->execute($usernameG, $streamName) or die "Couldn't execute statement: $DBI::errstr; stopped";
		}
		else {
			my $sth2 = $dbh->prepare("UPDATE `rosters` SET `streamActive` = 'active' WHERE `username` = ? AND `stream` = ?");
			$sth2->execute($usernameG, $streamName) or die "Couldn't execute statement: $DBI::errstr; stopped";
			
			print "$usernameG is streaming $gamePlaying as $streamName";
		}
	}
	$dbh->disconnect();
}

print "\n".'</body>
</html>';