#!/usr/bin/perlml

use CGI;
use utf8;
use File::Slurp;
use DBI;

BEGIN
{
	$q = new CGI;
	{   
		print $q->header(-type =>'text/html', -charset => 'UTF-8');
		$password = $q->param("password");
	}
	open(STDERR, ">&STDOUT");
}

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

sub scrapInfo
{
    my ($username) = @_;
    
    # get data, set to var
    $exportedData = read_file("export.ldif");

    # set chunks header to ΩΩ
    $exportedData =~ s/\#\ Entry/Ω/g;

    # set chunks tail to ππ
    $exportedData =~ s/objectclass/π/g;
    $exportedData =~ s/\[/\</g;
    $exportedData =~ s/\]/\>/g;
    $exportedData =~ s/\(/\</g;
    $exportedData =~ s/\)/\>/g;

ANOTHER_ENTRY:
    # grab an entry 
    ($userData) = ($exportedData =~ /uid[^Ω]*Ω([^π]+)/);
    if($userData =~ /^()$/)
    {
        die "end\n";
    }
    # remove that data from data
    $exportedData =~ s/$userData//g;
    $exportedData =~ s/Ωπ//g;

    # get standard info
    ($userName) = ($userData =~ /uid[^=]*=([^,]+)/);
    ($userRank) = ($userData =~ /cfrank[^:]*:([^\n]+)/);
    ($userRace) = ($userData =~ /cfrace[^:]*:([^\n]+)/);
    ($userUcoz) = ($userData =~ /cfucozprofileurl[^:]*:([^\n]+)/);
    ($userApi) = ($userData =~ /cfbnetapiurl[^:]*:([^\n]+)/);
    ($userGroup) = ($userData =~ /cfgroup[^:]*:([^\n]+)/);
    ($userStream) = ($userData =~ /cfstreamname[^:]*:([^\n]+)/);

	$newAward = "";
	$awardList = "";

AWARDS:
    # get awards
    ($newAward) = ($userData =~ /cfaward[^\{]*\{([^\}]+)/);
    $removeAward = "cfaward: {".$newAward."}";
    $userData =~ s/$removeAward//g;
    $awardList = $awardList.$removeAward;
    $garbage = "cfaward: {}";
    if($removeAward =~ /^($garbage)$/)
    {
        goto NOMOREAWARDS;
    }
    else
    {
        goto AWARDS;
    }
NOMOREAWARDS:
    insertData($userName, $userRank, $userRace, $userUcoz, $userApi, $userGroup, $userStream, $awardList);

    if($exportedData =~ m/Ω/)
    {
        goto ANOTHER_ENTRY;
    }
    else
    {
        die "done\n";
    }
}

sub insertData
{
    my ($userName, $userRank, $userRace, $userUcoz, $userApi, $userGroup, $userStream, $awardList) = @_;
    $userStream = $userStream."¥";
    my $dbh = DBI->connect("DBI:mysql:database=database;host=localhost", "Username", "Password", 
        {'RaiseError' => 1});

    my $sth = $dbh->prepare("INSERT INTO `oldroster` (`name`, `rank`, `race`, `ucoz`, `api`, `cfgroup`, `cfstreamname`, `awards`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $sth->execute($userName, $userRank, $userRace, $userUcoz, $userApi, $userGroup, $userStream, $awardList) or die "Couldn't execute statement: $DBI::errstr; stopped";
}
scrapInfo($username);