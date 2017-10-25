#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;
use File::Slurp;

BEGIN
{	
	$GLOBAL_PASSWORD = "PASSOWRD";
	$q = new CGI;
	$accessPW = $q->param("accessPW");
	$accessPWD = $q->param("accessPWD");
	$method = $q->param("method");
	$username = $q->param("username");
	$group = $q->param("group");
	$rank = $q->param("rank");
	$league = $q->param("league");
	$race = $q->param("race");
	$api = $q->param("api");
	$ucoz = $q->param("ucoz");
	$stream = $q->param("stream");
	$error = $q->param("error");

	$reason = $q->param("reason");
	$awardType = $q->param("awardType");

	if($method !~ /^(checkPW)$/)
	{
		print "Content-Type: text/html\n\n";
	}
	#print "Content-Type: text/html\n\n";

	$ourGroups = read_file("currentGroups.txt");
	$ourGamesData = read_file("currentGames.txt");
	$ourRanks = read_file("currentRanks.txt");
	$ourAwards = read_file("currentAwards.txt");
	
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
	$GLOBAL_HEADERS = qq
	{
		<meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width, height=device-height" minimal-ui/>
		<script type="text/javascript" src="../js/jQuery.js"></script>
		<script type="text/javascript" src="../js/multiFuncOthers.js"></script>
		<link rel="stylesheet" type="text/css" href="../css/multiFuncOthers.css">
	};
	if($method =~ /^(showGroup|countUsers|setAdmin|showGroups|checkPW)$/)
	{
		$accessPW = $GLOBAL_PASSWORD;
	}

	if(($method =~ /^(newUser|)$/) && (!defined $accessPW))
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					<title>ConFed - ...</title>
					<script>
						window.location.href="http://teamconfed.com/api/multiFuncOthers.pl?method=newUser&accessPW=" + localStorage.getItem("editPassword");
					</script>
				</head>
			</html>
		};
		exit;
	}

	if($accessPW !~ /^($GLOBAL_PASSWORD)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Error</title>
				</head>
				<body>
					<center>
						<p>Invalid Password, <a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login</a></p>
					</center>
				</body>
			</html>
		};
		exit;
	}

	if(!defined $method)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Error</title>
				</head>
				<body>
					<center>
						<p>No method defined</p>
					</center>
				</body>
			</html>
		};
		exit;
	}
	
	if($method =~ /^(checkPW)$/)
	{
		print "Content-Type: application/javascript\n\n";
		#application/javascript
		if($GLOBAL_PASSWORD =~ /^($accessPWD)$/)
		{
			print qq
			{
				localStorage.setItem("editPassword", "$accessPWD");
				alert("Successfully logged in");
				window.location.href = 'http://teamconfed.com/api/multiFunc.pl?method=showGroups';
			};
		}
		else
		{
			print qq
			{
				alert("Invalid password");
			};
		}
	}

	if($method =~ /^(setAdmin)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Login</title>
					<script>
						function loginTo()
						{
							\$.getScript( "multiFunc.pl?method=checkPW&accessPWD="+document.getElementById("password").value, function( data, textStatus, jqxhr ) {
								//localStorage.setItem("editPassword", );
								//window.location.href=window.location.href;
							});
						}
						function logoutTo()
						{
							localStorage.clear();
							window.location.href=window.location.href;
						}
					</script>
				</head>
				<body>
						<p>You&apos;ll remain logged in unless you logout below, or clear browser data/cookies.</p>
						<br/>
					<table>
						<tr>
							<td>
								Password:
							</td>
							<td>
								<input type='password' id='password'/>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<button type='button' onClick='loginTo()'>Login</button>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<br/>
								or
								<br/><br/>
								<button type='button' onClick='logoutTo()'>Logout</button>
							</td>
						</tr>
					</table>
				</body>
			</html>
		};
		exit;
	}

	if($method =~ /^(newUser)$/)
	{
		$ourRanksData = $ourRanks;
		$chooseThisRank = "\"Crew Member\"";
		$chooseThisRankPlus = $chooseThisRank." selected";
		$ourRanksData =~ s/$chooseThisRank/$chooseThisRankPlus/g;

		$ourGroupsData = $ourGroups;
		$chooseThisGroup = "\"CSB Vanguard\"";
		$chooseThisGroupPlus = $chooseThisGroup." selected";
		$ourGroupsData =~ s/$chooseThisGroup/$chooseThisGroupPlus/g;
		print qq 
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - New User</title>
				</head>
				<body>
					<div id="createUser">
						<h3><u>Create New User</u></h3><br/>
						<form method="post">
							<table>
								<tr>
									<td>Username:</td>
									<td><input type="text" id="username"/></td>
								</tr>
								<tr>
									<td>Game:</td>
									<td>
										<select id="group" class="select-style">
											$ourGamesData
										</select>
									</td>
								</tr>
								<tr>
									<td>Rank:</td>
									<td>
										<select id="rank" class="select-style">
											$ourRanksData
										</select>
									</td>
								</tr>
								<tr>
									<td colspan="2"><br/><center><button type="button" id="createUserSubmit">Create User</button></center></td>
								</tr>
							</table>
						</form>
					</div>
					<div style="display:none;" id="defaultCheckmark">&#10004;</div>
				</body>
			</html>
		};
		exit;
	}

	if($method =~ /^(newUserDo)$/)
	{
		my $sth1 = $dbh->prepare("INSERT INTO `rostersOthers` (`username`, `rank`, `game`) VALUES (?, ?, ?);");
		$sth1->execute($username, $rank, $group) or die "Couldn't execute statement: $DBI::errstr; stopped";
		
		print "success";

		exit;
	}

	if($method =~ /^(editUser)$/)
	{
	    my $sth2 = $dbh->prepare("SELECT `rank`, `url` FROM `rostersOthers` WHERE `username` = ? AND `game` = ?");
	    $sth2->execute($username, $group) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    while(my($dbgRank, $dbgUrl) = $sth2->fetchrow_array())
	    {
			$ourRanksData = $ourRanks;
			$chooseThisRank = "\"$dbgRank\"";
			$chooseThisRankPlus = $chooseThisRank." selected";
			$ourRanksData =~ s/$chooseThisRank/$chooseThisRankPlus/g;

			print qq 
			{
				<!DOCTYPE html>
				<html>
					<head>
						$GLOBAL_HEADERS
						<title>ConFed - Edit User</title>
					</head>
					<body>
						<div id="editUser">
							<h3><u>Edit User <font color="yellow">$username</font></u></h3><br/>
							<form method="post">
								<table>
									<tr>
										<td>Username:</td>
										<td><input type="text" class="nolabels" id="username" value="$username" readonly="readonly"/></td>
									</tr>
									<tr>
										<td>Group:</td>
										<td>
											<select id="group" class="select-style">
												$ourGroupsData
											</select>
										</td>
									</tr>
									<tr>
										<td>URL:</td>
										<td>
											<input type="text" value="$dbgUrl"/>
										</td>
									</tr>
									<tr>
										<td>Rank:</td>
										<td>
											<select id="rank" class="select-style">
												$ourRanksData
											</select>
										</td>
									</tr>
									<tr>
										<td colspan="2"><br/><center><button type="button" id="editUserSubmit">Save Edits</button></center></td>
									</tr>
								</table>
							</form>
						</div>
						<div style="display:none;" id="defaultCheckmark">&#10004;</div>
					</body>
				</html>
			};
			exit;
			$cash=1;
	    }
	    if($cash ne 1)
	    {
    		print qq
    		{
				<!DOCTYPE html>
				<html>
					<head>
						$GLOBAL_HEADERS
						<title>ConFed - Error</title>
					</head>
					<body>
						<center>
							<p>User not found</p>
						</center>
					</body>
				</html>
    		};
    		exit;
	    }

	}

	if($method =~ /^(editUserDo)$/)
	{
		my $sth3 = $dbh->prepare("UPDATE `rosters` SET `rank` = ?, `rgroup` = ?, `league` = ?, `race` = ?, `api` = ?, `ucoz` = ?, `stream` = ?, `error` = ? WHERE `username` = ?");
		$sth3->execute($rank, $group, $league, $race, $api, $ucoz, $stream, $error, $username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		print "successe";
		exit;
	}

	if($method =~ /^(showGroup)$/)
	{
		if((!defined $group) || ($group =~ /^()$/))
		{
    		print qq
    		{
				<!DOCTYPE html>
				<html>
					<head>
						$GLOBAL_HEADERS
						<title>ConFed - Error</title>
					</head>
					<body>
						<center>
							<p>Group not defined</p>
						</center>
					</body>
				</html>
    		};
			exit;
		}
	    my $sth4 = $dbh->prepare("SELECT `username`, `rank` FROM `rostersOthers` WHERE `game` = ? ORDER BY `rank` ASC");
	    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";

		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - $group</title>
				</head>
				<body>
					<style>
					*
					{
						padding: 0px 0px 0px 0px !important;
						margin: 0px 0px 0px 0px !important;
					}
					body
					{
						font-size: 10px;
						background-color: #000000 !important;
					}
					.squadNameButton
					{
						width: 95%;/*200px;*/
						height: 30px;
						border-width: 1px;
						border-bottom-width: 3px;
						border-top-color: rgba(255, 255, 255, 1.0);
						border-bottom-color: rgba(255, 255, 255, 1.0);
						border-left-color: rgba(255, 255, 255, 1.0);
						border-right-color: rgba(255, 255, 255, 1.0);
						border-radius: 0px;
						line-height: 1;
						font-size: 16px;
						background-color: rgba(20, 20, 20, 1.0);
						background: -webkit-linear-gradient(rgba(0, 0, 0, 1.0), rgba(15, 20, 60, 1.0));
						background: -o-linear-gradient(rgba(0, 0, 0, 1.0), rgba(15, 20, 60, 1.0));
						background: -moz-linear-gradient(rgba(0, 0, 0, 1.0), rgba(15, 20, 60, 1.0));
						background: linear-gradient(rgba(0, 0, 0, 1.0), rgba(15, 20, 60, 1.0));
						color: rgba(255, 255, 255, 1.0);
						font-family: 'Archivo Black', sans-serif;
						cursor: pointer !important;
					}
					table
					{
					    border-collapse: collapse;
					}
					</style>

					<center>
						<button type="button" class="squadNameButton gotoValue">$group</button>
						<br/><br/>
			<table>
		};
	    while(my($dbgUsername, $dbgRank) = $sth4->fetchrow_array())
	    {
		    my $sth5 = $dbh->prepare("SELECT DISTINCT `type`, COUNT(`type`) FROM `awards` WHERE `username` = '$dbgUsername' GROUP BY `type` ORDER BY `type` ASC");
		    $sth5->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

		    print "<tr><td><div style='display:none' id='viewInfo_$dbgUsername\_awards'>\n";
		    while(my($awardTypeG, $awardTypeGCount) = $sth5->fetchrow_array())
		    {
		    	$awardTypeG =~ s/^.//; 
				$awardTypeG =~ s/^.//; 
		    	print "<table width='70px'><tr><td><center><img style='height:22px;max-width:30px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/></center></td><td style='width:50%;vertical-align: middle;'>&nbsp;&nbsp;x " . $awardTypeGCount . "</td></tr></table>\n";
		    }
		    print "</div></td></tr>\n";
			$dbgRank =~ s/^.//; 
			$dbgRank =~ s/^.//; 

			$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
			$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
			print "<tr>";

	    	print qq
	    	{
	    				<td style="background-color:white;"><img src="../images/$dbgRank.png" title="$dbgRank" height="32px" width="32px"/></td>
	    				<td style="" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses">$dbgRank<br/>$dbgUsername</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
	    	};
			print "</tr>";
	    }
    	print qq
    	{	
    					</table>
    					<table id="bottomStuff" width="100%"><tr><td style="text-align:center;"><a href="http://teamconfed.com/api/multiFuncOthers.pl?method=setAdmin">Login/Logout</a></td><td style="text-align:center;"><a href="http://teamconfed.com/phpMyAdmin">phpMyAdmin</a></td><td style="text-align:center;"><a href="http://teamconfed.com/api/multiFuncOthers.pl?method=newUser">New User</a></td></tr></table>
    				</center>
					<div id="popup">
						<div id="popupBG"></div>
						<div id="closePopup">X</div>
						<br/><br/><br/>
						<div id="popupRank">
							test
						</div>
					</div>
				</body>
			</html>
		};
	}

	if($method =~ /^(addAward)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Add Awards - $username</title>
				</head>
				<body>
					<div id="editUser">
						<h3><u>Add Award <font color="yellow">$username</font></u></h3><br/>
						<form method="post">
							<table>
								<tr>
									<td>Username:</td>
									<td><input type='hidden' style='display:none' id='accessPWset' value="$accessPW"><input type="text" class="nolabels" id="username" value="$username" readonly="readonly"/></td>
								</tr>
								<tr>
									<td>Award Type:</td>
									<td><select class="select-style" id="awardType">$ourAwards</select></td>
								</tr>
								<tr>
									<td>Reason:</td>
									<td><input type="text" id="reason"/></td>
								</tr>
								<tr>
									<td colspan="2"><center><button type="button" id="giveAward">Give Award</button></center></td>
								</tr>
							</table>
						</form>
					</div>
				</body>
			</html>
		};
	}

	if($method =~ /^(addAwardDo)$/)
	{
		my $sth6 = $dbh->prepare("INSERT INTO `awards` (`username`, `type`, `reason`) VALUES (?, ?, ?);");
		$sth6->execute($username, $awardType, $reason) or die "Couldn't execute statement: $DBI::errstr; stopped";
		
		print "successe";

		exit;
	}
    $dbh->disconnect();
	open(STDERR, ">&STDOUT");
}