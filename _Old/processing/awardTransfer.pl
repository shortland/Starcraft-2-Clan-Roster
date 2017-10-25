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
		<head>
			<title>Award Transfer</title>
		</head>
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
		my $sth2 = $dbh->prepare("SELECT `awards` FROM `oldroster` WHERE name = ?");
		$sth2->execute($dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		while(my($dbg_awards) = $sth2->fetchrow_array())
    	{
    		$allUserAwards = $dbg_awards;
    		$allUserAwards =~ s/cfaward\:\ \{\}//g;
    		#$awardType = "test"; $awardReason = "testreason"; $awardDate = "tesDate";
STARTSEARCH:
			($anAward) = ($allUserAwards =~ /cfaward[^{]*{([^}]+)/);
			#print ">>".$anAward;
			if(($anAward =~ "")||(!defined $anAward))
			{
				print "No more awards for user";
				#exit; #"No more awards\n";
			}
			else
			{
				($awardType) = ($anAward =~ /\"type\"\:[^\"]*\"([^\"]+)/);
				($awardDate) = ($anAward =~ /\"date\"\:[^\"]*\"([^\"]+)/);
				($awardReason) = ($anAward =~ /\"reason\"\:[^\"]*\"([^\"]+)/);

				if(!defined $awardReason)
				{
					$awardReason = "undefined reason";
				}
				if(!defined $awardType)
				{
					$awardReason = "undefined type";
				}
				if(!defined $awardDate)
				{
					$awardReason = "undefined date";
				}

	    		my $sth3 = $dbh->prepare("INSERT INTO `awards` (`username`, `type`, `reason`, `date`, `TData`) VALUES (?, ?, ?, ?, ?)");
	    		$sth3->execute($dbg_username, $awardType, $awardReason, $awardDate, $dbg_awards) or die "Couldn't execute statement: $DBI::errstr; stopped";
		    	$allUserAwards =~ s/$anAward//g;
				goto STARTSEARCH;
	    	}
	    }
	    print ">Updated".$dbg_username."<br/>\n";
    }
    $dbh->disconnect();
       
	open(STDERR, ">&STDOUT");
}