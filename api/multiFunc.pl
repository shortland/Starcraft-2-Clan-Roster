#!/usr/bin/perlml

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;
use File::Slurp;

BEGIN
{	
	$GLOBAL_PASSWORD = "potatoes";
	$q = new CGI;
	$accessPW = $q->param("accessPW");
	$method = $q->param("method");
	# showGroup
	# http://YOURHOST.com/api/multiFunc.pl?accessPW=potatoes&method=showGroup&group=CSBVanguard
	
	# editUser
	# http://YOURHOST.com/api/multiFunc.pl?accessPW=potatoes&method=editUser&username=shortland
	
	# newUser
	# http://YOURHOST.com/api/multiFunc.pl?accessPW=potatoes&method=newUser

	# addAward
	# http://YOURHOST.com/api/multiFunc.pl?accessPW=potatoes&method=addAward&username=shortland
	$username = $q->param("username");
	$group = $q->param("group");
	$rank = $q->param("rank");
	$league = $q->param("league");
	$race = $q->param("race");
	$api = $q->param("api");
	$ucoz = $q->param("ucoz");
	$stream = $q->param("stream");
	$active = $q->param("active");
	$error = $q->param("error");

	$reason = $q->param("reason");
	$awardType = $q->param("awardType");

	print "Content-Type: text/html\n\n";

	$ourGroups = read_file("currentGroups.txt");
	$ourRanks = read_file("currentRanks.txt");
	$ourAwards = read_file("currentAwards.txt");
	
	my $dbh = DBI->connect("DBI:mysql:database=database;host=localhost", "USERNAME", "PASSWORD", {'RaiseError' => 1});

	$GLOBAL_HEADERS = qq
	{
		<meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width, height=device-height" minimal-ui/>
		<script type="text/javascript" src="../js/jQuery.js"></script>
		<script type="text/javascript" src="../js/multiFunc.js"></script>
		<link rel="stylesheet" type="text/css" href="../css/multiFunc.css">
		
	};
	if($method =~ /^(showGroup|countUsers|setAdmin)$/)
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
						window.location.href="http://YOURHOST.com/api/multiFunc.pl?method=newUser&accessPW=" + localStorage.getItem("editPassword");
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
						<p>Invalid Password, <a href="http://YOURHOST.com/api/multiFunc.pl?method=setAdmin">Login</a></p>
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
							localStorage.setItem("editPassword", document.getElementById("password").value);
							//alert("Password saved in browser");
							//document.getElementById("password").value = "";
							window.location.href=window.location.href;
						}
						function logoutTo()
						{
							localStorage.clear();
							window.location.href=window.location.href;
						}
						function checkStatus()
						{
							if(localStorage.getItem("editPassword"))
							{
 								document.getElementById("status").innerHTML = "<span style='color:green'>A Password is saved <br/>(Not necessarily correct password...)</span>";
							}
							else
							{
								document.getElementById("status").innerHTML = "<span style='color:red'>A Password is not saved</span>";
							}
						}
					</script>
				</head>
				<body onLoad="checkStatus()">
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
								
									If you&apos;re already logged in and want to logout/clear saved password:
								
							</td>
						</tr>
						<tr>
							<td colspan="2">
								
									<button type='button' onClick='logoutTo()'>Logout</button>
								
							</td>
						</tr>
						<tr>
							<br/>
							<td>Status:</td>
							<td><p id="status"></p></td>
						</tr>
					</table>
				</body>
			</html>
		};
		exit;
	}

	if($method =~ /^(countUsers)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Count</title>
					<style>
						body
						{
							background-color: #000000 !important;
						}
					</style>
				</head>
				<body>
					<center>
		};
		#SELECT active, COUNT(*) AS `num` FROM rosters WHERE `active` = 'Yes' GROUP BY active
		my $sth01 = $dbh->prepare("SELECT active, COUNT(*) AS `num` FROM rosters WHERE `active` = 'Yes' GROUP BY active");
	    $sth01->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($yesiknow, $dbgTotalCount) = $sth01->fetchrow_array())
	    {
	    	print "[$dbgTotalCount]&nbsp;&nbsp;"
	    }
		my $sth0 = $dbh->prepare("SELECT league, COUNT(*) AS `num` FROM rosters WHERE `active` = 'Yes' GROUP BY league");
	    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgLeague, $dbgCount) = $sth0->fetchrow_array())
	    {
	    	$dbgLeague =~ s/^.//; 
	    	print "<img src='../images/$dbgLeague\.png'/ width='28px' height='28px' style='position:relative;top:9px;'> x $dbgCount &nbsp;&nbsp;";
	    }
	    print qq
	    {
					</center>
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
									<td>Group:</td>
									<td>
										<select id="group" class="select-style">
											$ourGroupsData
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
								<!--<tr>
									<td>Edit Password:</td>
									<td><input type="password" id="editPassword"/></td>
								</tr>
								<tr>
									<td>Save Password?</td>
									<td><input id="savePW" type="checkbox" value="true" checked="true"></td>
								</tr>-->
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
		my $sth1 = $dbh->prepare("INSERT INTO `rosters` (`username`, `rank`, `rgroup`, `league`, `race`) VALUES (?, ?, ?, 'Update', 'Update');");
		$sth1->execute($username, $rank, $group) or die "Couldn't execute statement: $DBI::errstr; stopped";
		
		print "success";

		exit;
	}

	if($method =~ /^(editUser)$/)
	{
	    my $sth2 = $dbh->prepare("SELECT `rank`, `rgroup`, `league`, `race`, `api`, `ucoz`, `stream`, `active`, `error` FROM `rosters` WHERE `username` = ?");
	    $sth2->execute($username) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    while(my($dbgRank, $dbgGroup, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgActive, $dbgError) = $sth2->fetchrow_array())
	    {
			$ourRanksData = $ourRanks;
			$chooseThisRank = "\"$dbgRank\"";
			$chooseThisRankPlus = $chooseThisRank." selected";
			$ourRanksData =~ s/$chooseThisRank/$chooseThisRankPlus/g;

			$ourGroupsData = $ourGroups;
			$chooseThisGroup = "\"$dbgGroup\"";
			$chooseThisGroupPlus = $chooseThisGroup." selected";
			$ourGroupsData =~ s/$chooseThisGroup/$chooseThisGroupPlus/g;

			$ourLeagueData = qq
			{
				<option value=""></option>
				<option value="8UNRANKED">Unranked</option>
				<option value="7BRONZE">Bronze</option>
				<option value="6SILVER">Silver</option>
				<option value="5GOLD">Gold</option>
				<option value="4PLATINUM">Platinum</option>
				<option value="3DIAMOND">Diamond</option>
				<option value="2MASTER">Master</option>
				<option value="1GRANDMASTER">GM</option>
			};
			$ourLeagueData =~ s/\"$dbgLeague\"/\"$dbgLeague\"\ selected/g;

			$ourRaceData = qq
			{
				<option value=""></option>
				<option value="RANDOM">Random</option>
				<option value="TERRAN">Terran</option>
				<option value="ZERG">Zerg</option>
				<option value="PROTOSS">Protoss</option>
			};
			$ourRaceData =~ s/\"$dbgRace\"/\"$dbgRace\"\ selected/g;

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
										<td>Rank:</td>
										<td>
											<select id="rank" class="select-style">
												$ourRanksData
											</select>
										</td>
									</tr>
									<tr>
										<td>League:</td>
										<td>
											<select id="league" class="select-style">
												$ourLeagueData
											</select>
										</td>
									</tr>
									<tr>
										<td>Race:</td>
										<td>
											<select id="race" class="select-style">
												$ourRaceData
											</select>
										</td>
									</tr>
									<tr>
										<td>B.NET API:</td>
										<td>
											<input type="text" value="$dbgApi" id="api">
										</td>
									</tr>
									<tr>
										<td>uCoz Profile:</td>
										<td>
											<input type="text" value="$dbgUcoz" id="ucoz">
										</td>
									</tr>
									<tr>
										<td>Twitch Stream:</td>
										<td>
											<input type="text" value="$dbgStream" id="stream">
										</td>
									</tr>
									<tr>
										<td>Active:</td>
										<td>
											<input type="text" value="$dbgActive" id="active" placeholder="Yes/No">
										</td>
									</tr>
									<tr>
										<td>API Error:</td>
										<td>
											<input type="text" value="$dbgError" id="error">
										</td>
									</tr>
									<!--<tr>
										<td>Edit Password:</td>
										<td><input type="password" id="editPassword"/></td>
									</tr>
									<tr>
										<td>Save Password?</td>
										<td><input id="savePW" type="checkbox" value="true" checked="true"></td>
									</tr>-->
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
		my $sth3 = $dbh->prepare("UPDATE `rosters` SET `rank` = ?, `rgroup` = ?, `league` = ?, `race` = ?, `api` = ?, `ucoz` = ?, `stream` = ?, `active` = ?, `error` = ? WHERE `username` = ?");
		$sth3->execute($rank, $group, $league, $race, $api, $ucoz, $stream, $active, $error, $username) or die "Couldn't execute statement: $DBI::errstr; stopped";
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
	    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `ucozpic` FROM `rosters` WHERE `rgroup` = ? ORDER BY `rank` ASC, `league` ASC");
	    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    if($group =~ /^(Admirals)$/)
	    {
	    	$group = "UMC";
	    }
	    if($group =~ /^(CSBVanguard)$/)
	    {
	    	$group = "CSB Vanguard";
	    }
	    if($group =~ /^(HighCommand)$/)
	    {
	    	$group = "High Command";
	    }
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
					<script>
					\$(window).ready(function()
					{
						\$("#gotoValue").click(function()
						{
							if(\$(this).html() == "High Command")
							{
								window.top.location.href="http://the-confederation.net/index/command/0-19";
							}
							if(\$(this).html() == "UMC")
							{
								window.top.location.href="http://the-confederation.net/index/united_military_command/0-38";
							}
							if(\$(this).html() == "CRA")
							{
								window.top.location.href="http://the-confederation.net/index/confederation_recruitment_administration/0-39";
							}
							if(\$(this).html() == "Keepers")
							{
								window.top.location.href="http://the-confederation.net/index/keepers/0-41";
							}
							if(\$(this).html() == "Alpha")
							{
								window.top.location.href="http://the-confederation.net/index/alpha/0-124";
							}
							if(\$(this).html() == "Bravo")
							{
								window.top.location.href="http://the-confederation.net/index/bravo/0-125";
							}
							if(\$(this).html() == "Charlie")
							{
								window.top.location.href="http://the-confederation.net/index/charlie/0-126";
							}
							if(\$(this).html() == "CSB Vanguard")
							{
								//window.top.location.href="";
							}
						});
					});
					</script>
					<div style="display:none;" id="thisGroup">$group</div>
					<center>
						<button type="button" id="gotoValue" class="squadNameButton">$group</button>
						<br/><br/>
						
		};
		if($group =~ /^(High Command|CRA|Keepers|UMC)$/)
		{
			print qq{<table width="180px" style="width:180px;overflow:hidden;">};
		}
		if($group =~ /^(CSB Vanguard)$/)
		{
			print qq{<table width="760px" style="width:180px;overflow:hidden;">};
		}
		if($group !~ /^(High Command|CRA|Keepers|UMC|CSB Vanguard)$/)
		{
			print qq{<table width="200px" style="width:200px;overflow:hidden;">};
		}
		$count = 0;
	    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbg_ucoz_pic) = $sth4->fetchrow_array())
	    {
		    my $sth5 = $dbh->prepare("SELECT DISTINCT `type`, COUNT(`type`) FROM `awards` WHERE `username` = '$dbgUsername' GROUP BY `type` ORDER BY `type` ASC");
		    $sth5->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
		    #print "testing123 $dbgUsername";
		    #print $sth5->{Statement};
		    print "<div style='display:none' id='viewInfo_$dbgUsername\_awards'>\n";
		    while(my($awardTypeG, $awardTypeGCount) = $sth5->fetchrow_array())
		    {
		    	$awardTypeG =~ s/^.//; 
				$awardTypeG =~ s/^.//; 
		    	print "&nbsp; - <img style='height:22px;max-width:30px;position:relative;top:7px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/> x " . $awardTypeGCount . "<br/>\n";
		    }
		    print "</div>\n";
			$dbgRank =~ s/^.//; 
			$dbgRank =~ s/^.//; 

			$dbgLeague =~ s/^.//; 

			# turn api into profile
			# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
			($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
			$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
			if($group =~ "CSB Vanguard")
			{
				if($count =~ 0)
				{
					print "<tr>";
				}
			}
			else
			{
				print "<tr>";
			}
	    	print qq
	    	{
	    				<!--<td><img src="$dbg_ucoz_pic" height="32px" class="usersRank"/></td>-->
	    				<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>
	    				<td style="" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses">$dbgRank<br/>[ConFed]$dbgUsername</td>
	    				<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
	    				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
	    	};
			if($group =~ "CSB Vanguard")
			{
				if($count =~ 3)
				{
					print "</tr>";
				}
				else
				{
					print '<td style="border-right:1px solid white;">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
				}

			}
			else
			{
				print "</tr>";
			}

			$count = $count + 1;
			if($count =~ 4)
			{
				$count = 0;
			}
	    }
    	print qq
    	{	
    					</table>
    				</center>
					<div id="popup">
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
					<title>ConFed - Add Awards</title>
				</head>
				<body>
					<div id="editUser">
						<h3><u>Add Award <font color="yellow">$username</font></u></h3><br/>
						<form method="post">
							<table>
								<tr>
									<td>Username:</td>
									<td><input type="text" class="nolabels" id="username" value="$username" readonly="readonly"/></td>
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