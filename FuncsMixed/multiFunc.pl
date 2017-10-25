#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;
use File::Slurp;

BEGIN
{	
	$GLOBAL_PASSWORD = "PASSWORD";
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
	$ourRanks = read_file("currentRanks.txt");
	$ourAwards = read_file("currentAwards.txt");
	
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
	
	$GLOBAL_HEADERS = qq
	{
		<meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width, height=device-height" minimal-ui/>
		<script type="text/javascript" src="../js/jQuery.js"></script>
		<script type="text/javascript" src="../js/multiFunc.js"></script>
		<link rel="stylesheet" type="text/css" href="../css/multiFunc.css">
	};
	if($method =~ /^(showGroup|countUsers|setAdmin|showGroups|checkPW|showGroupsW|showGroupsOW)$/)
	{
		$accessPW = $GLOBAL_PASSWORD;
	}

	sub logEventRosterNewUser 
	{
    	my ($titlePost, $titleContent) = @_;

    	my @chars = ("A".."Z", "a".."z", "0".."9");
		my $randomString;
		$randomString .= $chars[rand @chars] for 1..4;

		$compiledTitlePost = "[NEW USER] ".$titlePost." (".$randomString.")";

    	my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
		my $sthl0 = $dbhl->prepare("INSERT INTO `bb_topics` (`forum_id`, `icon_id`, `topic_attachment`, `topic_reported`, `topic_title`, `topic_poster`, `topic_time`, `topic_time_limit`, `topic_views`, `topic_status`, `topic_type`, `topic_first_post_id`, `topic_first_poster_name`, `topic_first_poster_colour`, `topic_last_post_id`, `topic_last_poster_id`, `topic_last_poster_name`, `topic_last_poster_colour`, `topic_last_post_subject`, `topic_last_post_time`, `topic_last_view_time`, `topic_moved_id`, `topic_bumped`, `topic_bumper`, `poll_title`, `poll_start`, `poll_length`, `poll_max_options`, `poll_last_vote`, `poll_vote_change`, `topic_visibility`, `topic_delete_time`, `topic_delete_reason`, `topic_delete_user`, `topic_posts_approved`, `topic_posts_unapproved`, `topic_posts_softdeleted`) VALUES ('96', '0', '0', '0', ?, '2', ?, '0', '1', '0', '0', '36', 'ROSTER_BOT', 'AA0000', '36', '2', 'ROSTER_BOT', 'AA0000', ?, ?, ?, '0', '0', '0', '', '0', '0', '1', '0', '0', '1', '0', '', '0', '1', '0', '0');");
	    $sthl0->execute($compiledTitlePost, time(), $compiledTitlePost, time(), time()) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    my $sthl1 = $dbhl->prepare("SELECT `topic_id` FROM `bb_topics` WHERE `topic_title` = ?");
	    $sthl1->execute($compiledTitlePost) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTopicIDN) = $sthl1->fetchrow_array())
	    {
		    my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
			my $sthl1 = $dbhl->prepare("INSERT INTO `bb_posts` (`topic_id`, `forum_id`, `poster_id`, `icon_id`, `poster_ip`, `post_time`, `post_reported`, `enable_bbcode`, `enable_smilies`, `enable_magic_url`, `enable_sig`, `post_username`, `post_subject`, `post_text`, `post_checksum`, `post_attachment`, `bbcode_bitfield`, `bbcode_uid`, `post_postcount`, `post_edit_time`, `post_edit_reason`, `post_edit_user`, `post_edit_count`, `post_edit_locked`, `post_visibility`, `post_delete_time`, `post_delete_reason`, `post_delete_user`) VALUES (?, '96', '36', '0', '1.1.1.1.1', ?, '0', '1', '1', '1', '0', '', ?, ?, '1fa599d688e39698859d2f1f562f6dea', '0', '', '17qvn3k7', '1', '0', '', '0', '0', '0', '1', '0', '', '0');");
		    $sthl1->execute($dbgTopicIDN, time(), $compiledTitlePost, $titleContent) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    }
    }

    sub logEventRosterEditUser
    {
    	my($titlePost, $titleContent) = @_;

    	my @chars = ("A".."Z", "a".."z", "0".."9");
		my $randomString;
		$randomString .= $chars[rand @chars] for 1..4;

		$compiledTitlePost = "[EDIT USER] ".$titlePost." (".$randomString.")";

    	my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
		my $sthl01 = $dbhl->prepare("INSERT INTO `bb_topics` (`forum_id`, `icon_id`, `topic_attachment`, `topic_reported`, `topic_title`, `topic_poster`, `topic_time`, `topic_time_limit`, `topic_views`, `topic_status`, `topic_type`, `topic_first_post_id`, `topic_first_poster_name`, `topic_first_poster_colour`, `topic_last_post_id`, `topic_last_poster_id`, `topic_last_poster_name`, `topic_last_poster_colour`, `topic_last_post_subject`, `topic_last_post_time`, `topic_last_view_time`, `topic_moved_id`, `topic_bumped`, `topic_bumper`, `poll_title`, `poll_start`, `poll_length`, `poll_max_options`, `poll_last_vote`, `poll_vote_change`, `topic_visibility`, `topic_delete_time`, `topic_delete_reason`, `topic_delete_user`, `topic_posts_approved`, `topic_posts_unapproved`, `topic_posts_softdeleted`) VALUES ('96', '0', '0', '0', ?, '2', ?, '0', '1', '0', '0', '36', 'ROSTER_BOT', 'AA0000', '36', '2', 'ROSTER_BOT', 'AA0000', ?, ?, ?, '0', '0', '0', '', '0', '0', '1', '0', '0', '1', '0', '', '0', '1', '0', '0');");
	    $sthl01->execute($compiledTitlePost, time(), $compiledTitlePost, time(), time()) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    my $sthl11 = $dbhl->prepare("SELECT `topic_id` FROM `bb_topics` WHERE `topic_title` = ?");
	    $sthl11->execute($compiledTitlePost) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTopicIDN) = $sthl11->fetchrow_array())
	    {
		    my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
			my $sthl11 = $dbhl->prepare("INSERT INTO `bb_posts` (`topic_id`, `forum_id`, `poster_id`, `icon_id`, `poster_ip`, `post_time`, `post_reported`, `enable_bbcode`, `enable_smilies`, `enable_magic_url`, `enable_sig`, `post_username`, `post_subject`, `post_text`, `post_checksum`, `post_attachment`, `bbcode_bitfield`, `bbcode_uid`, `post_postcount`, `post_edit_time`, `post_edit_reason`, `post_edit_user`, `post_edit_count`, `post_edit_locked`, `post_visibility`, `post_delete_time`, `post_delete_reason`, `post_delete_user`) VALUES (?, '96', '36', '0', '1.1.1.1.1', ?, '0', '1', '1', '1', '0', '', ?, ?, '1fa599d688e39698859d2f1f562f6dea', '0', '', '17qvn3k7', '1', '0', '', '0', '0', '0', '1', '0', '', '0');");
		    $sthl11->execute($dbgTopicIDN, time(), $compiledTitlePost, $titleContent) or die "Couldn't execute statement: $DBI::errstr; stopped";
	    }
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
						window.location.href="http://teamconfed.com/api/multiFunc.pl?method=newUser&accessPW=" + localStorage.getItem("editPassword");
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
				window.location.href = 'http://teamconfed.com/api/multiFunc.pl?method=showGroupsW';
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
		my $sth01 = $dbh->prepare("SELECT COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive'");
	    $sth01->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTotalCount) = $sth01->fetchrow_array())
	    {
	    	print "[$dbgTotalCount]&nbsp;&nbsp;"
	    }
		my $sth0 = $dbh->prepare("SELECT league, COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive' GROUP BY league");
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
		
		logEventRosterNewUser($username." - ".$group, "Action: New User<br/>"."Username: ".$username."<br/>Group: ".$group);

		print "success";

		exit;
	}

	if($method =~ /^(editUser)$/)
	{
	    my $sth2 = $dbh->prepare("SELECT `rank`, `rgroup`, `league`, `race`, `api`, `ucoz`, `stream`, `error` FROM `rosters` WHERE `username` = ?");
	    $sth2->execute($username) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    while(my($dbgRank, $dbgGroup, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError) = $sth2->fetchrow_array())
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
				<option value="NONE">Unranked</option>
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
							<h3><u>Edit User <font color="black">$username</font></u></h3><br/>
							<form method="post">
								<table>
									<tr>
										<td>Username:</td>
										<td><input type="text" style="color:black;" class="nolabels" id="username" value="$username" readonly="readonly"/></td>
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
										<td>API Error:</td>
										<td>
											<input type="text" value="$dbgError" id="error">
										</td>
									</tr>
									<!--<tr>-->
										<!--<td>Edit Password:</td>-->
										<!--<td>--><input type="hidden" id="editPassword" style="display:none;" value="$accessPW"/><!--</td>-->
									<!--</tr>-->
									<!--<tr>
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
		my $sth21 = $dbh->prepare("SELECT `rank`, `rgroup`, `league`, `race`, `api`, `ucoz`, `stream`, `error` FROM `rosters` WHERE `username` = ?");
	    $sth21->execute($username) or die "Couldn't execute statement: $DBI::errstr; stopped";

	    while(my($dbgRank, $dbgGroup, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError) = $sth21->fetchrow_array())
	    {
			my $sth3 = $dbh->prepare("UPDATE `rosters` SET `rank` = ?, `rgroup` = ?, `league` = ?, `race` = ?, `api` = ?, `ucoz` = ?, `stream` = ?, `error` = ? WHERE `username` = ?");
			$sth3->execute($rank, $group, $league, $race, $api, $ucoz, $stream, $error, $username) or die "Couldn't execute statement: $DBI::errstr; stopped";
			
			if($dbgRank !~ /^($rank)$/)#
	    	{
	    		$rank = "<span style='text-decoration:line-through;'>$dbgRank</span> $rank";
	    	}
	    	if($dbgGroup !~ /^($group)$/)
	    	{
	    		$group = "<span style='text-decoration:line-through;'>$dbgGroup</span> $group";
	    	}
	    	if($dbgLeague !~ /^($league)$/)
	    	{
	    		$league = "<span style='text-decoration:line-through;'>$dbgLeague</span> $league";
	    	}
	    	if($dbgRace !~ /^($race)$/)
	    	{
	    		$race = "<span style='text-decoration:line-through;'>$dbgRace</span> $race";
	    	}
	    	if($dbgApi !~ /$api/)
	    	{
	    		$api = "<span style='text-decoration:line-through;'>$dbgApi</span> $api";
	    	}
	    	if($dbgStream !~ /^($stream)$/)
	    	{
	    		$stream = "<span style='text-decoration:line-through;'>$dbgStream</span> $stream";
	    	}
	    	if($dbgError !~ /^($error)$/)
	    	{
	    		$error = "<span style='text-decoration:line-through;'>$dbgError</span> $error";
	    	}

			logEventRosterEditUser($username." - ".$group, "Action: Edit User<br/>"."Username: ".$username."<br/>Group: ".$group."<br/>League: ".$league."<br/>Race: ".$race."<br/>API: ".$api."<br/>Stream: ".$stream."<br/>RankedFTW Error: ".$error);
		}
		print "successe";
		exit;
	}

	if($method =~ /^(showGroup)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Group</title>
				</head>
				<body>
					<style>
					*
					{
						padding: 0px 0px 0px 0px !important;
						margin: 0px 0px 0px 0px !important;
						color: rgba(87, 118, 160, 1.0);
						/font-weight: bold;
						font-family: 'Archivo Black', sans-serif;
					}
					body
					{
						font-size: 10px;
						background-color: rgb(245, 245, 245);
					}
					.squadNameButton
					{
						width: 100%;
						height: 30px;
						border-width: 0px;
						/*border-bottom-width: 3px;
						border-top-color: rgba(255, 255, 255, 1.0);
						border-bottom-color: rgba(255, 255, 255, 1.0);
						border-left-color: rgba(255, 255, 255, 1.0);
						border-right-color: rgba(255, 255, 255, 1.0);*/
						border-radius: 0px;
						line-height: 1;
						font-size: 16px;
						background-color: rgba(20, 20, 20, 1.0);
						background: -webkit-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: -o-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: -moz-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						color: rgba(255, 255, 255, 1.0) !important;
						font-family: 'Archivo Black', sans-serif;
						cursor: pointer !important;
					}
					table, tr, td
					{
					    border-collapse: collapse;
					    vertical-align: top;
					}
					</style>
		};

		print "<center>";
		#$group = "HighCommand";
		
# new groups, alpha bravo charlie

		print "<table><tr>";
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `rank` ASC, `league` ASC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
			#$group = "High Command";

				print qq{<td><table style='height:100%' width="100%" style="width:180px;display:inline-block;">};

			print qq
			{
				<tr>
				<td colspan="100">
				<div style="display:none;" id="thisGroup">$group</div>
				<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
				</td>
				</tr>
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
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
			    	print "<tableZ width='70px'><trZ><tdZ><center><img style='height:22px;max-width:30px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/></center></tdZ><tdZ style='width:50%;vertical-align: middle;'>&nbsp;&nbsp;x " . $awardTypeGCount . "</tdZ></trZ></tableZ>\n";
			    }
			    print "</div>\n";
				$dbgRank =~ s/^.//; 
				$dbgRank =~ s/^.//; 

				$dbgLeague =~ s/^.//; 

				# turn api into profile
				# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
				($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
				$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
					if($count =~ 0)
					{
						print "<tr>";
					}
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgbnetXoff = ($dbgbnetXoff / 90) * 50;
				$dbgbnetYoff = ($dbgbnetYoff / 90) * 50;

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
		    	print qq
		    	{
		    				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		    				<td><div style="max-height:70px !important;zoom:0.5;width:70px !important;-moz-transform:scale(0.5);-moz-transform-origin: 0 0;"><img style="border-radius:6px;" class="leagueBorderImage" src="../images/blizzard/$dbgLeague\-et.png" width="62px" height="62px" /><div style="position:relative;top:-60px;left:6px;z-index:6;width:50px;height:50px;background: url(../images/blizzard/$dbgbnetPic\-90.jpg) $dbgbnetXoff\px $dbgbnetYoff\px;" ></div></div></td>
		    				<!--<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>-->
		    				<td style="width:120px !important;margin-right:0px;padding-right:0px;" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses">$dbgRank<br/>[$dbgTag]$dbgUsername</td>
		    				<!--<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>-->
		    				<td style="display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		    				<td><img src="../images/$dbgRace.png" title="$dbgRace" height="26px" width="26px"/></td>
		    	};

					if($count =~ 3)
					{
						print "</tr>";
					}
					else
					{
						print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
					}

				$count = $count + 1;
				if($count =~ 4)
				{
					$count = 0;
				}
		    }
		    print "</table></td>"
		}
		print "</tr></table><br/><br/>";

    	print qq
    	{
    		</center>
					<div id="popup">
						<div id="popupBG"></div>
						<div id="closePopup">X</div>
						<!--<br/><br/><br/>-->
						<div id="popupRank">
							test
						</div>
					</div>
					<br/><br/>
					<style>
					a:visited, a
					{
						color: rgba(87, 118, 160, 1.0);
						text-decoration: none;
					}
					a:hover
					{
						text-decoration: underline;
					}
					</style>
					<center>
						<table id='rainbowColorTable' style='display:none;max-width:265px;'>
							<tr>
								<td><p style='text-decoration:underline;'>Active within:</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style='text-decoration:underline;'>Color</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>Count (%share)</td>
							</tr>
							<tr>
								<td>Less than 1 Day</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#14a014;">Green</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count1'></td>
							</tr>
							<tr>
								<td>2-3 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#b8b800;">Yellow</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count3'></td>
							</tr>
							<tr>
								<td>4-5 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#ff9628;">Orange</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count5'></td>
							</tr>
							<tr>
								<td>6-7 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#18a0c8;">Light Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count7'></td>
							</tr>
							<tr>
								<td>8-10 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#281e96;">Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count10'></td>
							</tr>
							<tr>
								<td>11-12 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#ff6496;">Pink</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count12'></td>
							</tr>
							<tr>
								<td>13-14 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#e31c2d;">Red</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count14'></td>
							</tr>
							<tr>
								<td>14+ Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#981498;">Purple</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count15'></td>
							</tr>
						</table>
						<br/>
						<div id="altExplain" style="display:none;font-size:10px"><span style='color:orange;'>**</span> indicates that the Blizzard API failed to return match history data... <br/>As a fallback; last ranked/unranked game will be used to determine user activity.<br/>Normally any type of game (including arcade) will determine activity. <br/>But for these marked (**) users, only ranked/unranked can determine activity. </div>
						<div id='spcLog'>
							<center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center>
							<br/><br/>
							<center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login</a></center>
						</div>
						<table style="width:100%;display:none;" id='onlyIfLogged'>
							<tr>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login/Logout</a></center></td>
								<td><center><a href="http://teamconfed.com/phpMyAdmin" target='_blank'>phpMyAdmin</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=newUser">New User</a></center></td>
								<td><center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Inactive">Inactive</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Banned">Banned</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=countUsers">Member Count</a></center></td>
							</tr>
						</table>
					</center>
					<br/><br/>
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

	if($method =~ /^(showGroups)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>ConFed - Groups</title>
				</head>
				<body>
					<style>
					*
					{
						padding: 0px 0px 0px 0px !important;
						margin: 0px 0px 0px 0px !important;
						color: rgba(255, 255, 255, 1.0);
						/*font-family: 'Lato', sans-serif;
               	 		font-weight: 900;*/
					}
					body
					{
						font-size: 10px;
						background-color: rgb(0, 0, 0) !important;
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
					table, tr, td
					{
					    border-collapse: collapse;
					    vertical-align: top;
					}
					</style>
		};

		print "<center>";
		my $sth01 = $dbh->prepare("SELECT COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive'");
	    $sth01->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTotalCount) = $sth01->fetchrow_array())
	    {
	    	print "<span class='totalMemberCount'>[<span id='totalMemberCount'>$dbgTotalCount</span>]</span>&nbsp;&nbsp;"
	    }
		my $sth0 = $dbh->prepare("SELECT league, COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive' GROUP BY league");
	    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgLeague, $dbgCount) = $sth0->fetchrow_array())
	    {
	    	$dbgLeague =~ s/^.//; 
	    	print "<img src='../images/$dbgLeague\.png'/ width='28px' height='28px'><span class='totalMemberCount'> x $dbgCount </span>&nbsp;&nbsp;";
	    }
	    print "<br/><br/>";
		#$group = "HighCommand";
		print "<table><tr>";
		@allGroups = ("HighCouncil", "Officers", "Keepers");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `league` ASC, `mmr` DESC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
		    if($group =~ "Admirals")
		    {
		    	$group = "UMC";
		    }
		    if($group =~ "HighCouncil")
		    {
		    	$group = "High Council"
		    }
			#$group = "High Command";
			if($group =~ /^(High Council|Low Council|CRA|UMC|Keepers|Officers)$/)
			{
				print qq{<td width="215px"><table style='height:100%' width="200px" style="width:180px;display:inline-block;">};
			}
			print qq
			{
				<tr>
				<td colspan="100">
				<div style="display:none;" id="thisGroup">$group</div>
				<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
				</td>
				</tr>
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
		    {
			    my $sth5 = $dbh->prepare("SELECT DISTINCT `type`, COUNT(`type`) FROM `awards` WHERE `username` = '$dbgUsername' GROUP BY `type` ORDER BY `type` ASC");
			    $sth5->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
			    #print "testing123 $dbgUsername";
			    #print $sth5->{Statement};
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
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
		    	print qq
		    	{
		    				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		    				<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>
		    				<td style="" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses"><!--$dbgRank<br/>-->[$dbgTag]$dbgUsername</td>
		    				<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		    	};
				if($group =~ "CSB Vanguard")
				{
					if($count =~ 3)
					{
						print "</tr>";
					}
					else
					{
						print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
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
		    print "</table></td>"
		}
		print "</tr></table><br/><br/>";

# new groups, alpha bravo charlie

		print "<table><tr>";
		@allGroups = ("Members");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `league` ASC, `mmr` DESC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
			#$group = "High Command";
			if($group =~ "Members")
			{
				$group = "Members";
			}
			if($group =~ /^(Members)$/)
			{
				print qq{<td><table style='height:100%' width="760px" style="width:180px;display:inline-block;">};
			}
			print qq
			{
				<tr>
				<td colspan="100">
				<div style="display:none;" id="thisGroup">$group</div>
				<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
				</td>
				</tr>
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
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
			    	print "<tableZ width='70px'><trZ><tdZ><center><img style='height:22px;max-width:30px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/></center></tdZ><tdZ style='width:50%;vertical-align: middle;'>&nbsp;&nbsp;x " . $awardTypeGCount . "</tdZ></trZ></tableZ>\n";
			    }
			    print "</div>\n";
				$dbgRank =~ s/^.//; 
				$dbgRank =~ s/^.//; 

				$dbgLeague =~ s/^.//; 

				# turn api into profile
				# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
				($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
				$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
				if($group =~ "Members")
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
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
		    	print qq
		    	{
		    				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		    				<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>
		    				<td style="width:178px;" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses"><!--$dbgRank<br/>-->[$dbgTag]$dbgUsername</td>
		    				<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		    				<td style="display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		    	};
				if($group =~ "Members")
				{
					if($count =~ 2)
					{
						print "</tr>";
					}
					else
					{
						print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
					}
				}
				else
				{
					print "</tr>";
				}
				$count = $count + 1;
				if($count =~ 3)
				{
					$count = 0;
				}
		    }
		    print "</table></td>"
		}
		print "</tr></table><br/><br/>";

# new groups, csb vanguard

		# print "<table><tr>";
		# @allGroups = ("CSBVanguard");
		# foreach my $group (@allGroups)
		# {
		#     my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `rank` ASC, `league` ASC");
		#     $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
		# 	#$group = "High Command";
		# 	if($group =~ "CSBVanguard")
		# 	{
		# 		$group = "CSB Vanguard";
		# 	}
		# 	if($group =~ /^(CSB Vanguard)$/)
		# 	{
		# 		print qq{<td><table style='height:100%' width="760px" style="width:180px;display:inline-block;">};
		# 	}
		# 	print qq
		# 	{
		# 		<tr>
		# 		<td colspan="100">
		# 		<div style="display:none;" id="thisGroup">$group</div>
		# 		<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
		# 		</td>
		# 		</tr>
		# 	};
		# 	$count = 0;
		#     while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
		#     {
		# 		my $sth5 = $dbh->prepare("SELECT DISTINCT `type`, COUNT(`type`) FROM `awards` WHERE `username` = '$dbgUsername' GROUP BY `type` ORDER BY `type` ASC");
		# 	    $sth5->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
		# 	    #print "testing123 $dbgUsername";
		# 	    #print $sth5->{Statement};
		# 	    print "<div style='display:none' id='viewInfo_$dbgUsername\_awards'>\n";
		# 	    while(my($awardTypeG, $awardTypeGCount) = $sth5->fetchrow_array())
		# 	    {
		# 	    	$awardTypeG =~ s/^.//; 
		# 			$awardTypeG =~ s/^.//; 
		# 	    	print "<tableZ width='70px'><trZ><tdZ><center><img style='height:22px;max-width:30px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/></center></tdZ><tdZ style='width:50%;vertical-align: middle;'>&nbsp;&nbsp;x " . $awardTypeGCount . "</tdZ></trZ></tableZ>\n";
		# 	    }
		# 	    print "</div>\n";
		# 		$dbgRank =~ s/^.//; 
		# 		$dbgRank =~ s/^.//; 

		# 		$dbgLeague =~ s/^.//; 

		# 		# turn api into profile
		# 		# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
		# 		($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
		# 		$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
		# 		if($group =~ "CSB Vanguard")
		# 		{
		# 			if($count =~ 0)
		# 			{
		# 				print "<tr>";
		# 			}
		# 		}
		# 		else
		# 		{
		# 			print "<tr>";
		# 		}
		# 		$currentEpoch = time;
		# 		$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
		# 		$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
		# 		$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
		# 		$timeSinceLast = ($timeSinceLast / 24); # returns days ago

		# 		$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
		# 		$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
		# 		$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
		# 		$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

		# 		$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
		# 		$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
		#     	print qq
		#     	{
		#     				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		#     				<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>
		#     				<td style="width:178px;" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses">$dbgRank<br/>[$dbgTag]$dbgUsername</td>
		#     				<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		#     				<td style="display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		#     	};
		# 		if($group =~ "CSB Vanguard")
		# 		{
		# 			if($count =~ 3)
		# 			{
		# 				print "</tr>";
		# 			}
		# 			else
		# 			{
		# 				print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
		# 			}
		# 		}
		# 		else
		# 		{
		# 			print "</tr>";
		# 		}
		# 		$count = $count + 1;
		# 		if($count =~ 4)
		# 		{
		# 			$count = 0;
		# 		}
		#     }
		#     print "</table></td>"
		# }
		# print "</tr></table>";

    	print qq
    	{
    		</center>
					<div id="popup">
						<div id="popupBG"></div>
						<div id="closePopup">X</div>
						<!--<br/><br/><br/>-->
						<div id="popupRank">
							test
						</div>
					</div>
					<br/><br/>
					<style>
					a:visited, a
					{
						color: rgba(87, 118, 160, 1.0);
						text-decoration: none;
					}
					a:hover
					{
						text-decoration: underline;
					}
					</style>
					<center>
						<table id='rainbowColorTable' style='display:none;max-width:265px;'>
							<tr>
								<td><p style='text-decoration:underline;'>Active within:</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style='text-decoration:underline;'>Color</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>Count (%share)</td>
							</tr>
							<tr>
								<td>1 Day</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#33FF8D;">Green</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count1'></td>
							</tr>
							<tr>
								<td>3 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#33FFF3;">Green-Teal</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count3'></td>
							</tr>
							<tr>
								<td>5 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#33A5FF;">Light Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count5'></td>
							</tr>
							<tr>
								<td>7 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#333FFF;">Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count7'></td>
							</tr>
							<tr>
								<td>10 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#8D33FF;">Purple-Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count10'></td>
							</tr>
							<tr>
								<td>12 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#F333FF;">Pink-Purple</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count12'></td>
							</tr>
							<tr>
								<td>14 Days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#FF3333;">Red</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count14'></td>
							</tr>
							<tr>
								<td>More than 14 days</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#FFFFFF;">White</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count15'></td>
							</tr>
						</table>
						<br/>
						<div id="altExplain" style="display:none;font-size:10px"><span style='color:orange;'>**</span> indicates that the Blizzard API failed to return match history data... <br/>As a fallback; last ranked/unranked game will be used to determine user activity.<br/>Normally any type of game (including arcade) will determine activity. <br/>But for these marked (**) users, only ranked/unranked can determine activity. </div>
						<div id='spcLog'>
							<center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center>
							<br/><br/>
							<center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login</a></center>
						</div>
						<table style="width:100%;display:none;" id='onlyIfLogged'>
							<tr>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login/Logout</a></center></td>
								<td><center><a href="http://teamconfed.com/phpMyAdmin" target='_blank'>phpMyAdmin</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=newUser">New User</a></center></td>
								<td><center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Inactive">Inactive</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Banned">Banned</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=countUsers">Member Count</a></center></td>
							</tr>
						</table>
					</center>
					<br/><br/>
				</body>
			</html>
		};
	}

	if($method =~ /^(showGroupsW)$/)
	{
		print qq
		{
			<!DOCTYPE html>
			<html>
				<head>
					$GLOBAL_HEADERS
					<title>Clan Groups</title>
				</head>
				<body>
					<style>
					*
					{
						padding: 0px 0px 0px 0px !important;
						margin: 0px 0px 0px 0px !important;
						color: rgba(87, 118, 160, 1.0);
						/font-weight: bold;
						font-family: 'Archivo Black', sans-serif;
					}
					body
					{
						font-size: 10px;
						background-color: rgb(245, 245, 245);
					}
					.squadNameButton
					{
						width: 100%;
						height: 30px;
						border-width: 0px;
						/*border-bottom-width: 3px;
						border-top-color: rgba(255, 255, 255, 1.0);
						border-bottom-color: rgba(255, 255, 255, 1.0);
						border-left-color: rgba(255, 255, 255, 1.0);
						border-right-color: rgba(255, 255, 255, 1.0);*/
						border-radius: 0px;
						line-height: 1;
						font-size: 16px;
						background-color: rgba(20, 20, 20, 1.0);
						background: -webkit-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: -o-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: -moz-linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						background: linear-gradient(rgba(130, 150, 190, 1.0), rgba(90, 120, 165, 1.0));
						color: rgba(255, 255, 255, 1.0) !important;
						font-family: 'Archivo Black', sans-serif;
						cursor: pointer !important;
					}
					table, tr, td
					{
					    border-collapse: collapse;
					    vertical-align: top;
					}
					</style>
		};

		print "<center>";
		my $sth01 = $dbh->prepare("SELECT COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive'");
	    $sth01->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTotalCount) = $sth01->fetchrow_array())
	    {
	    	print "<span class='totalMemberCount'>[<span id='totalMemberCount'>$dbgTotalCount</span>]</span>&nbsp;&nbsp;"
	    }
		my $sth0 = $dbh->prepare("SELECT league, COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive' GROUP BY league");
	    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgLeague, $dbgCount) = $sth0->fetchrow_array())
	    {
	    	$dbgLeague =~ s/^.//; 
	    	print "<img src='../images/$dbgLeague\.png'/ width='28px' height='28px'><span class='totalMemberCount'> x $dbgCount </span>&nbsp;&nbsp;";
	    }
	    print "<br/><br/>";
		#$group = "HighCommand";
		print "<table><tr>";
		@allGroups = ("HighCouncil", "Officers", "Keepers");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `league` ASC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
		    if($group =~ "Admirals")
		    {
		    	$group = "UMC";
		    }
		    if($group =~ "HighCouncil")
		    {
		    	$group = "High Council"
		    }
			#$group = "High Command";
			if($group =~ /^(High Council|Low Council|CRA|UMC|Keepers|Officers)$/)
			{
				print qq{<td width="215px"><table style='height:100%' width="180px" style="width:200px;display:inline-block;">};
			}
			print qq
			{
				<tr>
				<td colspan="100">
				<div style="display:none;" id="thisGroup">$group</div>
				<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
				</td>
				</tr>
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
		    {
			    my $sth5 = $dbh->prepare("SELECT DISTINCT `type`, COUNT(`type`) FROM `awards` WHERE `username` = '$dbgUsername' GROUP BY `type` ORDER BY `type` ASC");
			    $sth5->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
			    #print "testing123 $dbgUsername";
			    #print $sth5->{Statement};
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
					print "<tr style='width:180px !important;max-width:180px !important;'>";
				}
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgbnetXoff = ($dbgbnetXoff / 1.8);
				$dbgbnetYoff = ($dbgbnetYoff / 1.8);

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
		    	print qq
		    	{
		    				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		    				<td style="display: inline-block;max-width:32px;height:32px;max-height:32px !important;margin:0px;"><div style="max-height:70px !important;zoom:0.5;width:70px !important;-moz-transform:scale(0.5);-moz-transform-origin: 0 0;"><img style="border-radius:6px;" class="leagueBorderImage" src="../images/blizzard/$dbgLeague\-et.png" width="62px" height="62px" /><div style="position:relative;top:-60px;left:6px;z-index:6;width:50px;height:51px;background: url(../images/blizzard/$dbgbnetPic\-90.jpg) $dbgbnetXoff\px $dbgbnetYoff\px;" ></div></div></td>
		    				<!--<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>-->
		    				<td style="display: inline-block;height:32px;max-height:32px !important;position:relative;top:1px;width:100px;" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses"><!--$dbgRank<br/>-->&nbsp;[$dbgTag]$dbgUsername</td>
		    				<!--<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>-->
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		    				<td><div style="height:36px !important;"><img style="float:right;" src="../images/$dbgRace.png" title="$dbgRace" height="26px" width="26px"/></div></td>
		    				
		    	};
				if($group =~ "CSB Vanguard")
				{
					if($count =~ 3)
					{
						print "</tr>";
					}
					else
					{
						print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
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
		    print "</table></td>"
		}
		print "</tr></table><br/><br/>";

# new groups, alpha bravo charlie

		print "<table><tr>";
		@allGroups = ("Members");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate` FROM `rosters` WHERE `rgroup` = ? ORDER BY `rank` ASC, `league` ASC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";
			#$group = "High Command";
			if($group =~ "Members")
			{
				$group = "Members";
			}
			if($group =~ /^(Members)$/)
			{
				print qq{<td><table style='height:100%' width="760px" style="width:180px;display:inline-block;">};
			}
			print qq
			{
				<tr>
				<td colspan="100">
				<div style="display:none;" id="thisGroup">$group</div>
				<center><button type="button" class="squadNameButton gotoValue">$group</button><br/><br/>\</center>
				</td>
				</tr>
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame) = $sth4->fetchrow_array())
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
			    	print "<tableZ width='70px'><trZ><tdZ><center><img style='height:22px;max-width:30px;' src='../images/".$awardTypeG. ".jpg' title='".$awardTypeG."'/></center></tdZ><tdZ style='width:50%;vertical-align: middle;'>&nbsp;&nbsp;x " . $awardTypeGCount . "</tdZ></trZ></tableZ>\n";
			    }
			    print "</div>\n";
				$dbgRank =~ s/^.//; 
				$dbgRank =~ s/^.//; 

				$dbgLeague =~ s/^.//; 

				# turn api into profile
				# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
				($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
				$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
				if($group =~ "Members")
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
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgbnetXoff = ($dbgbnetXoff / 1.8);
				$dbgbnetYoff = ($dbgbnetYoff / 1.8);

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z
				#
		    	print qq
		    	{
		    				<!--<td><img src="$dbgbnetPic" height="32px" class="usersRank"/></td>-->
		    				<td style="display: inline-block;max-width:32px;height:32px;max-height:32px !important;margin:0px;"><div style="max-height:70px !important;zoom:0.5;width:70px !important;-moz-transform:scale(0.5);-moz-transform-origin: 0 0;"><img style="border-radius:6px;" class="leagueBorderImage" src="../images/blizzard/$dbgLeague\-et.png" width="62px" height="62px" /><div style="position:relative;top:-60px;left:6px;z-index:6;width:50px;height:51px;background: url(../images/blizzard/$dbgbnetPic\-90.jpg) $dbgbnetXoff\px $dbgbnetYoff\px;" ></div></div></td>
		    				<!--<td><img src="../images/$dbgRace.png" title="$dbgRace" height="32px" width="32px"/></td>-->
		    				<td style="display: inline-block;height:32px;max-height:32px !important;position:relative;top:1px;width:100px;" class="viewInfo" id="viewInfo_$dbgUsername" title="W:$wins &nbsp; L:$losses"><!--$dbgRank<br/>-->&nbsp;[$dbgTag]$dbgUsername</td>
		    				<!--<td><img src="../images/$dbgLeague.png" title="$dbgLeague" height="26px" width="26px"/></td>-->
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_wins">$wins</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_losses">$losses</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnet">$bnetprofile</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_ucoz">$dbgUcoz</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_stream">$dbgStream</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_error">$dbgError</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_rank">$dbgRank</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetLeague">$dbgLeague</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetPic">$dbgbnetPic</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetXoff">$dbgbnetXoff</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_bnetYoff">$dbgbnetYoff</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_group">$group</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_tag">$dbgTag</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_lastGame" class="epochTimes">$timeSinceLast</td>
		    				<td style="display: inline-block;display:none" id="viewInfo_$dbgUsername\_lastRealGame" class="epochTimesZ">$timeSinceRealLast</td>
		    				<td><div style="height:36px !important;"><img style="float:right;" src="../images/$dbgRace.png" title="$dbgRace" height="26px" width="26px"/></div></td>
		    				
		    	};
				if($group =~ "Members")
				{
					if($count =~ 3)
					{
						print "</tr>";
					}
					else
					{
						print '<td style="border-right:1px solid rgba(87, 118, 160, 1.0);">&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>';
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
		    print "</table></td>"
		}
		print "</tr></table><br/><br/>";

    	print qq
    	{
    		</center>
					<div id="popup">
						<div id="popupBG"></div>
						<div id="closePopup">X</div>
						<!--<br/><br/><br/>-->
						<div id="popupRank">
							test
						</div>
					</div>
					<br/><br/>
					<style>
					a:visited, a
					{
						color: rgba(87, 118, 160, 1.0);
						text-decoration: none;
					}
					a:hover
					{
						text-decoration: underline;
					}
					</style>
					<center>
						<table id='rainbowColorTable' style='display:none;max-width:265px;'>
							<tr>
								<td><p style='text-decoration:underline;'>Active within:</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style='text-decoration:underline;'>Color</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>Count (%share)</td>
							</tr>
							<tr>
								<td>Less than 1 Day</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#14a014;">Green</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count1'></td>
							</tr>
							<tr>
								<td>2-3 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#b8b800;">Yellow</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count3'></td>
							</tr>
							<tr>
								<td>4-5 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#ff9628;">Orange</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count5'></td>
							</tr>
							<tr>
								<td>6-7 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#18a0c8;">Light Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count7'></td>
							</tr>
							<tr>
								<td>8-10 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#281e96;">Blue</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count10'></td>
							</tr>
							<tr>
								<td>11-12 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#ff6496;">Pink</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count12'></td>
							</tr>
							<tr>
								<td>13-14 Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#e31c2d;">Red</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count14'></td>
							</tr>
							<tr>
								<td>14+ Days Ago</td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td><p style="color:#981498;">Purple</p></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class='count15'></td>
							</tr>
						</table>
						<br/>
						<div id="altExplain" style="display:none;font-size:10px"><span style='color:orange;'>**</span> indicates that the Blizzard API failed to return match history data... <br/>As a fallback; last ranked/unranked game will be used to determine user activity.<br/>Normally any type of game (including arcade) will determine activity. <br/>But for these marked (**) users, only ranked/unranked can determine activity. </div>
						<div id='spcLog'>
							<center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center>
							<br/><br/>
							<center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login</a></center>
						</div>
						<table style="width:100%;display:none;" id='onlyIfLogged'>
							<tr>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=setAdmin">Login/Logout</a></center></td>
								<td><center><a href="http://teamconfed.com/phpMyAdmin" target='_blank'>phpMyAdmin</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=newUser">New User</a></center></td>
								<td><center><a class='rainbow2' style="cursor:pointer;" onclick='return false;'>Rainbow!</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Inactive">Inactive</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=showGroup&group=Banned">Banned</a></center></td>
								<td><center><a href="http://teamconfed.com/api/multiFunc.pl?method=countUsers">Member Count</a></center></td>
							</tr>
						</table>
					</center>
					<br/><br/>
				</body>
			</html>
		};
	}
	
	if($method =~ /^(showGroupsOW)$/) {
		print qq
		{
			<!DOCTYPE html>
			<html>
			<head>
				<title>Fresh Clean Redo</title>
			</head>
			<body>
				<style>
				\@font-face {
					font-family: "Overwatch";
					src: url("../css/bignoodletoo.woff") format('woff');
				}
				* {
					border-collapse: collapse;
					-webkit-box-sizing: border-box;
					-moz-box-sizing: border-box;
					box-sizing: border-box;
					font-family: Overwatch;
					margin: 0px 0px 0px 0px;
					padding: 0px 0px 0px 0px;
					line-box-contain: font replaced;
				}
				.imaprofile {
					zoom: 1;
					-ms-zoom: 1;
					-webkit-zoom: 1;
					-moz-transform:  scale(1, 1);
					-moz-transform-origin: left center;
				}
				table {
					
					border-collapse: collapse;
				    vertical-align: top;
				    background-color: red;
				}
				tr, td {
				    border-collapse: collapse;
				    vertical-align: top;
				    width: 0px !important;
					overflow: hidden !important;
				}
				td {
					margin: -10px;
					padding: -10px;
				}

				.spctable {
					zoom: 0.5;
					-ms-zoom: 0.5;
					-webkit-zoom: 0.5;
					-moz-transform:  scale(0.5, 0.5);
					-moz-transform-origin: left center;
				}
				</style>
		};

		print "<center>\n";
		my $sth01 = $dbh->prepare("SELECT COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive'");
	    $sth01->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTotalCount) = $sth01->fetchrow_array())
	    {
	    	print "<span class='totalMemberCount'>[<span id='totalMemberCount'>$dbgTotalCount</span>]</span>&nbsp;&nbsp;\n";
	    }

		my $sth0 = $dbh->prepare("SELECT league, COUNT(*) AS `num` FROM rosters WHERE `rgroup` != 'Inactive' GROUP BY league");
	    $sth0->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgLeague, $dbgCount) = $sth0->fetchrow_array())
	    {
	    	$dbgLeague =~ s/^.//; 
	    	print "<img src='../images/$dbgLeague\.png'/ width='28px' height='28px'><span class='totalMemberCount'> x $dbgCount </span>&nbsp;&nbsp;\n";
	    }

	    print "<br/><br/>\n";

		print "<table class='spctable' cellspacing='0' cellpadding='0' ><tr>\n";

		@allGroups = ("HighCouncil", "Officers", "Keepers");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate`, `bnetPicSource` FROM `rosters` WHERE `rgroup` = ? ORDER BY `league` ASC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";

			if($group =~ /^(HighCouncil|Keepers|Officers)$/)
			{
				print qq{<td width="20px"><table cellspacing='0' cellpadding='0' style='height:100%' width="20px" style="width:20px;display:inline-block;overflow:hidden;">\n};
			}
			print qq
			{
				<tr>
					<td colspan="100">
						<center><h2 style="text-decoration:underline;">$group</h2><br/>\</center>
					</td>
				</tr>\n
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame, $realPicURL) = $sth4->fetchrow_array())
		    {
				if($count =~ 1)
				{
					print "<td><div style='width:0px;'></div></td>\n";
				}

				$dbgRank =~ s/^.//; 
				$dbgRank =~ s/^.//; 

				$dbgLeague =~ s/^.//; 

				# turn api into profile
				# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
				($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
				$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
				if($group =~ /^(HighCouncil|Keepers|Officers)$/)
				{
					if($count =~ 0)
					{
						print "<tr>\n";
					}
				}
				else
				{
					print "<tr style='width:10px !important;max-width:10px !important;'>\n";
				}
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago


				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z

				#get proper league border formatting
				$leagueLoL = ucfirst(lc($dbgLeague));
				if($leagueLoL =~ /^(Grandmaster)$/){$leagueLoL="GM";}
				$correctLeague = read_file("static/$leagueLoL.txt");
				#print $correctLeague;
				$correctPortraitLink = "http://media.blizzard.com/sc2/portraits/7-0.jpg";
				$correctLeague =~ s/PORTRAIT_LINK/$realPicURL/g;

		    	print qq
		    	{
					<td>
						$correctLeague
						<span style="display: inline-block;padding-left:6px;max-width:62px;overflow:hidden;text-overflow:ellipsis; " title="$dbgUsername"><h1>$dbgUsername&nbsp;</h1></span>
					</td>\n
		    	};
				if($group =~ /^(HighCouncil|Keepers|Officers)$/)
				{
					if($count =~ 0)
					{
						#print "<td><div style='width:20px;'></div></td>\n";
					}
					if($count =~ 1)
					{
						print "</tr>\n";
					}
				}
				else
				{
					print "</tr>\n";
				}
				$count++;
				if($count =~ 2)
				{
					$count = 0;
				}
		    }
		    print "</table></td>\n";
		}
		print "</tr></table><br/><br/>\n";

		print "<br/><br/>\n";

		@allGroups = ("Members");
		foreach my $group (@allGroups)
		{
		    my $sth4 = $dbh->prepare("SELECT `username`, `rank`, `league`, `race`, `api`, `ucoz`, `stream`, `error`, `1win`, `1loss`, `bnetPic`, `lastGame`, `clantag`, `bnetXoff`, `bnetYoff`, `seasonGamesUpdate`, `bnetPicSource` FROM `rosters` WHERE `rgroup` = ? ORDER BY `league` ASC");
		    $sth4->execute($group) or die "Couldn't execute statement: $DBI::errstr; stopped";

			if($group =~ /^(Members)$/)
			{
				print qq{<table class='spctable' cellspacing='0' cellpadding='0' style='height:100%' style="display:inline-block;">\n};
				#$group = "Members";
			}

			print qq
			{
				<tr>
					<td colspan="100">
						<center><h3 style="text-decoration:underline;">$group</h3><br/>\</center>
					</td>
				</tr>\n
			};
			$count = 0;
		    while(my($dbgUsername, $dbgRank, $dbgLeague, $dbgRace, $dbgApi, $dbgUcoz, $dbgStream, $dbgError, $wins, $losses, $dbgbnetPic, $dbgLastGame, $dbgTag, $dbgbnetXoff, $dbgbnetYoff, $dbgLastRealGame, $realPicURL) = $sth4->fetchrow_array())
		    {
				#if($count =~ 5)
				#{
				#	print "<td><div style='width:20px;'></div></td>\n";
				#}

				$dbgRank =~ s/^.//; 
				$dbgRank =~ s/^.//; 

				$dbgLeague =~ s/^.//; 

				# turn api into profile
				# https://us.api.battle.net/sc2/profile/7561824/1/SunGodEffect/?locale=en_US&apikey=93gu3nyp757ybrg224z8qjs23cj8en4d
				($bnetprofile) = ($dbgApi =~ /profile[^\/]*\/([^\?]+)/);
				$bnetprofile = "http://us.battle.net/sc2/en/profile/$bnetprofile";
				if($group =~ /^(Members)$/)
				{
					if($count =~ 0)
					{
						print "<tr>\n";
					}
				}
				else
				{
					print "<tr style='width:180px !important;max-width:180px !important;'>\n";
				}
				$currentEpoch = time;
				$timeSinceLast = $currentEpoch - $dbgLastGame; # returns seconds ago
				$timeSinceLast = ($timeSinceLast / 60); # returns minutes ago
				$timeSinceLast = ($timeSinceLast / 60); # returns hours ago
				$timeSinceLast = ($timeSinceLast / 24); # returns days ago

				$timeSinceRealLast = $currentEpoch - $dbgLastRealGame; # returns seconds ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns minutes ago
				$timeSinceRealLast = ($timeSinceRealLast / 60); # returns hours ago
				$timeSinceRealLast = ($timeSinceRealLast / 24); # returns days ago

				$dbgRank =~ s/(?<! )([A-Z])/ $1/g; # Search for "(?<!pattern)" in perldoc perlre 
				$dbgRank =~ s/^ (?=[A-Z])//; # Strip out extra starting whitespace followed by A-Z

				#get proper league border formatting
				$leagueLoL = ucfirst(lc($dbgLeague));
				if($leagueLoL =~ /^(Grandmaster)$/){$leagueLoL="GM";}
				$correctLeague = read_file("static/$leagueLoL.txt");
				#print $correctLeague;
				$correctPortraitLink = "http://media.blizzard.com/sc2/portraits/7-0.jpg";
				$correctLeague =~ s/PORTRAIT_LINK/$realPicURL/g;



				#if($leagueLoL =~ /^()$/) {
				#
				#}

		    	print qq
		    	{
					<td>
						$correctLeague
						<span style="display: inline-block;padding-left:6px;max-width:62px;overflow:hidden;text-overflow:ellipsis; " title="$dbgUsername">$dbgUsername&nbsp;</span>
					</td>\n
		    	};
				if($group =~ /^(Members)$/)
				{
					if($count =~ 0)
					{
						#print "<td><div style='width:20px;'></div></td>\n";
					}
					if($count =~ 5)
					{
						print "</tr>\n";
					}
				}
				else
				{
					print "</tr>\n";
				}
				$count++;
				if($count =~ 6)
				{
					$count = 0;
				}
				else
				{
					print "<td><div style='width:20px;'></div><td/>";
				}
		    }
		    print "</table></td>\n";
		}

	}





  #   while(my($dbg_username) = $sth->fetchrow_array())
  #   {
		# $api = `curl -s "http://teamconfed.com/api/roster.pl?username=$dbg_username"`;
		# if($api =~ /https/) #f8
		# {
		# 	my $sth2 = $dbh->prepare("UPDATE `rosters` SET `api` = ? WHERE `username` = ?");
  #       		$sth2->execute($api, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		# }
		# else
		# {
		# 	my $sth2 = $dbh->prepare("UPDATE `rosters` SET `error` = ? WHERE `username` = ?");
  #       		$sth2->execute($api, $dbg_username) or die "Couldn't execute statement: $DBI::errstr; stopped";
		# }
  #   }
  #   $dbh->disconnect();
    $dbh->disconnect();
	open(STDERR, ">&STDOUT");
}