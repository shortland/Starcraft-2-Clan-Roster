<?php
ini_set('display_errors', 'On');
// begin cofigurable
/*
	visit this page: this_page.php?league=0
	
	This'll write the player data of people that have your clan tag, (and in the league) in the text file sc2_data_0.txt
	
	You'll have to edit this file to make it write other data such as MMR or whatever. Feel free to ask me (somehow) if you're having trouble parsing that data.

	0 = bronze
	1 = silver
	2 = gold
	3 = platinum
	4 = diamond
	5 = master
	6 = grandmaster


	I made it so the script only gets a certain league at a time since my webhost ends file execution after some time.
	Splitting up the leagues cuts down on execution time.
*/

#https://us.battle.net/oauth/authorize?client_id=clientIDHERE&scope=sc2.profile&state=iamrandom&redirect_uri=https://localhost/&response_type=code

#cmb6wjwcdj8r2kd4kzfscaef
#https://us.battle.net/oauth/token?client_id=clientIDHERE&client_secret=clientsecrethere&redirect_uri=https://localhost/&scope=sc2.profile&grant_type=authorization_code&code=cmb6wjwcdj8r2kd4kzfscaef

# smarturl https
	# https://us.battle.net/oauth/authorize?client_id=clientIDHERE&scope=sc2.profile&state=iamrandom&redirect_uri=https://hyperurl.co/thz9bm&response_type=code
	# >85hjnuutrze4xyeawvex7ty7
	#
	#https://us.battle.net/oauth/token?client_id=clientIDHERE&client_secret=clientsecretHERE&redirect_uri=https://localhost/&scope=sc2.profile&grant_type=authorization_code&code=39bprm22c2s75pt8bfgzdpzg
	#
#	

$TOKEN = file_get_contents("token.txt");
/*
	readme.txt file has instructions on how to get TOKEN from blizz oauth
	It's sorta a lengthy process 
*/

$clans = ['ConFed', 'ConFD', 'xCFx']; //put one or however many clan tags your clan has
// end cofigurable

$league = $_GET['league'];
$leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'master', 'grandmaster'];

if(!isset($league)) {
	echo "Please provide league param ?league=[0-6] or [bronze-grandmaster]";
	exit();
}
elseif(in_array(strtolower($league), $leagues)) {
	$league = array_search($league, $leagues);
}
elseif(($league >= 0) && ($league <= 6)) {
	// don't need to do anything
}
else {
	echo "invalid league param";
	exit();
}

function curl_get_content($URL) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_URL, $URL);
	$data = curl_exec($ch);
	curl_close($ch);
	return $data;
}

$season = curl_get_content("https://us.api.battle.net/data/sc2/season/current?access_token=" . $TOKEN);
//echo $season."<---";
echo $season = (json_decode($season, TRUE))["id"];
echo $league;
$leagueLink = curl_get_content("https://us.api.battle.net/data/sc2/league/" . $season . "/201/0/" . $league . "?access_token=" . $TOKEN);
$cd = json_decode(utf8_encode($leagueLink), TRUE);

class User_data {
	public $mmr, $wins, $losses, $ties, $points, $longest_win_streak, $current_win_streak, $current_rank, $highest_rank, $previous_rank, $join_time_stamp, $last_played_time_stamp, $id, $name, $path, $race, $game_count, $battle_tag, $clan_id, $clan_tag, $clan_name, $clan_icon_url, $clan_decal_url, $league, $tier = "";
}
$members = array();

if($league == 6) {
	$tiers = 0;
}
else {
	$tiers = 2;
}

for($q = 0; $q <= $tiers; $q++) {
	for($k = 0; $k < count($cd['tier'][$q]['division']); $k++) {
		$ladderContents = json_decode(curl_get_content("https://us.api.battle.net/data/sc2/ladder/" . $cd['tier'][$q]['division'][$k]['ladder_id'] . "?access_token=" . $TOKEN), TRUE);
		//echo $ladderContents;
		for($eachPerson = 0; $eachPerson < count($ladderContents['team']); $eachPerson++) {
			if(isset($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_tag'])) {
				$clanTag = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_tag'];
				if(in_array($clanTag, $clans)) {
					$Obj = new User_data();
					$Obj->mmr = $ladderContents['team'][$eachPerson]['rating'];
					$Obj->wins = $ladderContents['team'][$eachPerson]['wins'];
					$Obj->losses = $ladderContents['team'][$eachPerson]['losses'];
					$Obj->ties = $ladderContents['team'][$eachPerson]['ties'];
					$Obj->points = $ladderContents['team'][$eachPerson]['points'];
					$Obj->longest_win_streak = $ladderContents['team'][$eachPerson]['longest_win_streak'];
					$Obj->current_win_streak = $ladderContents['team'][$eachPerson]['current_win_streak'];
					$Obj->current_rank = $ladderContents['team'][$eachPerson]['current_rank'];
					$Obj->highest_rank = $ladderContents['team'][$eachPerson]['highest_rank'];
					$Obj->previous_rank = $ladderContents['team'][$eachPerson]['previous_rank'];
					$Obj->join_time_stamp = $ladderContents['team'][$eachPerson]['join_time_stamp'];
					$Obj->last_played_time_stamp = $ladderContents['team'][$eachPerson]['last_played_time_stamp'];
					$Obj->id = $ladderContents['team'][$eachPerson]['member'][0]['legacy_link']['id'];
					echo $Obj->name = $ladderContents['team'][$eachPerson]['member'][0]['legacy_link']['name'] . " ";
					$Obj->path = $ladderContents['team'][$eachPerson]['member'][0]['legacy_link']['path'];
					$Obj->race = $ladderContents['team'][$eachPerson]['member'][0]['played_race_count'][0]['race']['en_US'];
					$Obj->game_count = $ladderContents['team'][$eachPerson]['member'][0]['played_race_count'][0]['count'];
					$Obj->battle_tag = $ladderContents['team'][$eachPerson]['member'][0]['character_link']['battle_tag'];
					// obtained by path
					$Obj->league = $leagues[$league];
					$Obj->tier = $q+1;
					// can only be collected if clan tag exists, under assumption clan tag exists since we matched by tag
					$Obj->clan_id = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['id'];
					$Obj->clan_tag = $clanTag;
					$Obj->clan_name = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_name'];
					$Obj->clan_icon_url = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['icon_url'];
					$Obj->clan_decal_url = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['decal_url'];

					array_push($members, json_encode($Obj));
				}
			}
			else {
				//echo "no clan</br>";
			}
		}
	}
}
$myfile = fopen("ladders/sc2_data_" . $league . ".json", "w");
fwrite($myfile, '{"members":[');
for($member = 0; $member < count($members); $member++) {
	fwrite($myfile, $members[$member]);
	if(($member+1) !== count($members)) {
		fwrite($myfile, ",");
	}
}
fwrite($myfile, ']}');
fclose($myfile);

echo "done";
?>