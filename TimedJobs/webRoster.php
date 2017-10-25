<?php

	{
		$myLeague = "grandmaster";
		$leagues = ['grandmaster', 'master', 'diamond', 'platinum', 'gold', 'silver', 'bronze', 'unranked'];
		echo array_search(strtolower($myLeague), $leagues) + 1;
	}
	//echo $myLeague;

?>