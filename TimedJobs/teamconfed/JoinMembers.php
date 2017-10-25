<?php

$allMembers = array();

class User_data {
	public $mmr, $wins, $losses, $ties, $points, $longest_win_streak, $current_win_streak, $current_rank, $highest_rank, $previous_rank, $join_time_stamp, $last_played_time_stamp, $id, $name, $path, $race, $game_count, $battle_tag, $clan_id, $clan_tag, $clan_name, $clan_icon_url, $clan_decal_url, $league, $tier, $win_rate = "";
}

// get data from each league file, parse into one huge array of json objs
for($leagueNum = 0; $leagueNum <= 6; $leagueNum++) {
	$members = json_decode(file_get_contents("ladders/sc2_data_" . $leagueNum . ".json"));

	foreach($members->members as $row) {
		$Obj = new User_data();
		$win_rate = round(($row->wins)/($row->wins + $row->losses + $row->ties), 2);
	    foreach($row as $key => $val) {
			$Obj->$key = $val;
			$Obj->win_rate = $win_rate;
	    }
	    array_push($allMembers, json_encode($Obj));
	}
}

// Sort everyone by highest MMR, 
usort($allMembers, function($a, $b) {
	return json_decode($b)->mmr < json_decode($a)->mmr ? -1 : 1;
});

// Remove duplicate users, using their 'path' as a unique key. Only their Highest MMR race is saved
$userPoints = array();
foreach($allMembers as $mmr => $player) {
	$isFound = 0;
	for($i = 0; $i < count($userPoints); $i++) {
		if(json_decode($userPoints[$i])->path == json_decode($player)->path) {
			$isFound = 1;
		}
	}
	if($isFound == 0) {
		array_push($userPoints, $player);
	}
}

// Resort again by highest MMR, removing duplicates reversed the sort
usort($userPoints, function($a, $b) {
	return json_decode($b)->mmr > json_decode($a)->mmr ? -1 : 1;
});

$leagues = ["bronze", "silver", "gold", "platinum", "diamond", "master", "grandmaster"];

/*

	Below begins custom sorting.
	
*/
if(!isset($_GET["major_sort"]) || !isset($_GET["minor_sort"]) || !isset($_GET["sort_order"]) || $_GET["major_sort"] == "null" || $_GET["minor_sort"] == "null") {
	$sort_order = "desc";
	$major_sort = "league";
	$minor_sort = "mmr";
}

if($major_sort == "league") {
	// 2d array, rows = leagues, columns = minor_sort
	$multiArray = array(array());
	for($l = 0; $l <= 6; $l++) {
		$counter = 0;
		for($i = 0; $i < count($userPoints); $i++) {
			if(array_search(json_decode($userPoints[$i])->league, $leagues) == $l) {
				$multiArray[$l][$counter] = $userPoints[$i];
				$counter++;
			}
		}
	}
	// putting data into the array in proper order. (highest league to lowest)
	$userPoints = array();
	for($row = 6; $row >= 0; $row--) {
		for($col = count($multiArray[$row])-1; $col >= 0; $col--) {
			array_push($userPoints, $multiArray[$row][$col]);
		}
	}
}

/*
		usort($userPoints, function($a, $b) {
			if(property_exists(json_decode($b), $_GET["sort"])) {
				return json_decode($b)->$_GET["sort"] < json_decode($a)->$_GET["sort"] ? -1 : 1;
			}
			else {
				return json_decode($b)->mmr < json_decode($a)->mmr ? -1 : 1;
			}
		});
	
*/

$file = fopen("ladders/sc2_data.json", "w");
fwrite($file, '[');
for($member = 0; $member < count($userPoints); $member++) {
	fwrite($file, $userPoints[$member]);
	if(($member+1) !== count($userPoints)) {
		fwrite($file, ",");
	}
}
fwrite($file, ']');
fclose($file);

echo file_get_contents("ladders/sc2_data.json");
?>