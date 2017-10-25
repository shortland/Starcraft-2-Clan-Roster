<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// THIS IS THE GLOBAL EVERYONE VERSION

$TOKEN = file_get_contents("teamconfed/token.txt");
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

$server = strtolower($_GET['server']);

if(!isset($server)) {
	echo "Please provide a server [US, KR, EU...]";
	exit();
}

if ($server == "kr") {
	$serverCode = "01";
}
elseif($server == "us") {
	$serverCode = "00";
}
elseif($server == "eu") {
	$serverCode = "02";
}
else {
	echo "KR or US or EU server";
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

$season = curl_get_content("https://".$server.".api.battle.net/data/sc2/season/current?access_token=" . $TOKEN);
//echo $season."<---";
$season = (json_decode($season, TRUE))["id"];
#echo $league;
$leagueLink = curl_get_content("https://".$server.".api.battle.net/data/sc2/league/" . $season . "/201/0/" . $league . "?access_token=" . $TOKEN);
$cd = json_decode(utf8_encode($leagueLink), TRUE);

class User_data {
	public $mmr, $wins, $losses, $ties, $points, $longest_win_streak, $current_win_streak, $current_rank, $highest_rank, $previous_rank, $join_time_stamp, $last_played_time_stamp, $id, $name, $path, $race, $game_count, $battle_tag, $clan_id, $clan_tag, $clan_name, $clan_icon_url, $clan_decal_url, $league, $tier = "";
}
$members = array();

if($league == 6) {
	// gm has no tiers
	$tiers = 0;
}
else {
	// all leagues other than gm have this league
	$tiers = 2;

	// get the min-max mmr of each tier
	// writing the code here, because only non-gm league should be able to access this block already

	$tiera = $cd['tier'][0]['min_rating'] . " - " . $cd['tier'][0]['max_rating'];
	$tierb = $cd['tier'][1]['min_rating'] . " - " . $cd['tier'][1]['max_rating'];
	$tierc = $cd['tier'][2]['min_rating'] . " - " . $cd['tier'][2]['max_rating'];

	$leagueD = strtoupper($leagues[$league]);

	$read_datas = file_get_contents("../GOOSE/bounds_".$server.".txt");

	$matches = '/(<:'.$leagueD.'\d:\d+>\[1\])\s\d{4}\s-\s\d{4}\s*\n(<:'.$leagueD.'\d:\d+>\[2\])\s\d{4}\s-\s\d{4}\s*\n(<:'.$leagueD.'\d:\d+>\[3\])\s\d{4}\s-\s\d{4}\s*\n/i';
	$matching = '\1 '.$tiera."\n".'\2 '.$tierb."\n".'\3 '.$tierc."\n";
	$text = preg_replace($matches, $matching, $read_datas);

	$myfile = fopen("../GOOSE/bounds_".$server.".txt", "w") or die("Unable to open file!");
	fwrite($myfile, $text);
	fclose($myfile);

}

for($q = 0; $q <= $tiers; $q++) {
	for($k = 0; $k < count($cd['tier'][$q]['division']); $k++) {
		$ladderContents = json_decode(curl_get_content("https://".$server.".api.battle.net/data/sc2/ladder/" . $cd['tier'][$q]['division'][$k]['ladder_id'] . "?access_token=" . $TOKEN), TRUE);
		//echo $ladderContents;
		for($eachPerson = 0; $eachPerson < count($ladderContents['team']); $eachPerson++) {
			//if(isset($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_tag'])) {
			$clanTag = $ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_tag'];
			// they are a confed member, lets put their shit into the file
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
			$Obj->name = addslashes($ladderContents['team'][$eachPerson]['member'][0]['legacy_link']['name']);
			$Obj->path = addslashes($ladderContents['team'][$eachPerson]['member'][0]['legacy_link']['path']);
			$Obj->race = $ladderContents['team'][$eachPerson]['member'][0]['played_race_count'][0]['race']['en_US'];
			$Obj->game_count = $ladderContents['team'][$eachPerson]['member'][0]['played_race_count'][0]['count'];
			$Obj->battle_tag = addslashes($ladderContents['team'][$eachPerson]['member'][0]['character_link']['battle_tag']);
			// obtained by path
			$Obj->league = $leagues[$league];
			$Obj->tier = $q+1;
			// can only be collected if clan tag exists, under assumption clan tag exists since we matched by tag
			$Obj->clan_id = addslashes($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['id']);
			$Obj->clan_tag = addslashes($clanTag);
			$Obj->clan_name = addslashes($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['clan_name']);
			$Obj->clan_icon_url = "_"; //. addslashes($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['icon_url']);
			$Obj->clan_decal_url = "_"; //. addslashes($ladderContents['team'][$eachPerson]['member'][0]['clan_link']['decal_url']);
			
			if(in_array($clanTag, $clans)) {
				array_push($members, json_encode($Obj));
			}
			
			$link = mysqli_connect("localhost", "root", "LegoApril181998!", "teamconfed");
			mysqli_set_charset($link, 'UTF-8');
			/* check connection */
			if (mysqli_connect_errno()) {
			    printf("Connect failed: %s\n", mysqli_connect_error());
			    exit();
			}

			// inserting into everyone table
			if (!mysqli_query($link, "INSERT INTO `everyone` (`mmr`, `wins`, `losses`, `ties`, `points`, `longest_win_streak`, `current_win_streak`, `current_rank`, `highest_rank`, `previous_rank`, `join_time_stamp`, `last_played_time_stamp`, `id`, `name`, `path`, `race`, `game_count`, `battle_tag`, `league`, `tier`, `clan_id`, `clan_tag`, `clan_name`, `clan_icon_url`, `clan_decal_url`, `server`) VALUES ('$Obj->mmr', '$Obj->wins', '$Obj->losses', '$Obj->ties', '$Obj->points', '$Obj->longest_win_streak', '$Obj->current_win_streak', '$Obj->current_rank', '$Obj->highest_rank', '$Obj->previous_rank', '$Obj->join_time_stamp', '$Obj->last_played_time_stamp', '$Obj->id', '$Obj->name$serverCode', '$Obj->path', '$Obj->race', '$Obj->game_count', '$Obj->battle_tag\_$Obj->race\_$server', '$Obj->league', '$Obj->tier', '$Obj->clan_id', '$Obj->clan_tag', '$Obj->clan_name', '$Obj->clan_icon_url', '$Obj->clan_decal_url', '$server') ON DUPLICATE KEY UPDATE mmr = '$Obj->mmr', wins = '$Obj->wins', losses = '$Obj->losses', ties = '$Obj->ties', points = '$Obj->points', longest_win_streak = '$Obj->longest_win_streak', current_win_streak = '$Obj->current_win_streak', current_rank = '$Obj->current_rank', highest_rank = '$Obj->highest_rank', previous_rank = '$Obj->previous_rank', join_time_stamp = '$Obj->join_time_stamp', last_played_time_stamp = '$Obj->last_played_time_stamp', id = '$Obj->id', `name` = '$Obj->name$serverCode', `path` = '$Obj->path', race = '$Obj->race', game_count = '$Obj->game_count', league = '$Obj->league', tier = '$Obj->tier', clan_id = '$Obj->clan_id', clan_tag = '$Obj->clan_tag', clan_name = '$Obj->clan_name', clan_icon_url = '$Obj->clan_icon_url', clan_decal_url = '$Obj->clan_decal_url'")) {
			    printf("Errormessage: %s\n", mysqli_error($link));
			}
			mysqli_close($link);	
		}
	}
}
if($serverCode == "00") {
	$myfile = fopen("teamconfed/ladders/sc2_data_" . $league . ".json", "w");
	fwrite($myfile, '{"members":[');
	for($member = 0; $member < count($members); $member++) {
		fwrite($myfile, $members[$member]);
		if(($member+1) !== count($members)) {
			fwrite($myfile, ",");
		}
	}
	fwrite($myfile, ']}');
	fclose($myfile);
}

$myfile2 = fopen("../GOOSE/lastupdate.txt", "w");
fwrite($myfile2, time()."");
fclose($myfile2);

echo "done";
?>