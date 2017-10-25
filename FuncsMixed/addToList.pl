#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;
use DBI;

BEGIN
{	
	$q = new CGI;
	print "Content-Type: text/html\n\n";

	sub logEventRosterNewUser 
	{
    	my ($titlePost, $titleContent) = @_;

    	my @chars = ("A".."Z", "a".."z", "0".."9");
		my $randomString;
		$randomString .= $chars[rand @chars] for 1..4;

		$compiledTitlePost = "[AUTO NEW USER] ".$titlePost." (".$randomString.")";

    	my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
		my $sthl0 = $dbhl->prepare("INSERT INTO `bb_topics` (`forum_id`, `icon_id`, `topic_attachment`, `topic_reported`, `topic_title`, `topic_poster`, `topic_time`, `topic_time_limit`, `topic_views`, `topic_status`, `topic_type`, `topic_first_post_id`, `topic_first_poster_name`, `topic_first_poster_colour`, `topic_last_post_id`, `topic_last_poster_id`, `topic_last_poster_name`, `topic_last_poster_colour`, `topic_last_post_subject`, `topic_last_post_time`, `topic_last_view_time`, `topic_moved_id`, `topic_bumped`, `topic_bumper`, `poll_title`, `poll_start`, `poll_length`, `poll_max_options`, `poll_last_vote`, `poll_vote_change`, `topic_visibility`, `topic_delete_time`, `topic_delete_reason`, `topic_delete_user`, `topic_posts_approved`, `topic_posts_unapproved`, `topic_posts_softdeleted`) VALUES ('14', '0', '0', '0', ?, '2', ?, '0', '1', '0', '0', '36', 'ROSTER_BOT', 'AA0000', '36', '2', 'ROSTER_BOT', 'AA0000', ?, ?, ?, '0', '0', '0', '', '0', '0', '1', '0', '0', '1', '0', '', '0', '1', '0', '0');");
	    $sthl0->execute($compiledTitlePost, time(), $compiledTitlePost, time(), time()) or print "Couldn't execute statement: $DBI::errstr; stopped";

	    my $sthl1 = $dbhl->prepare("SELECT `topic_id` FROM `bb_topics` WHERE `topic_title` = ?");
	    $sthl1->execute($compiledTitlePost) or print "Couldn't execute statement: $DBI::errstr; stopped";
	    while(my($dbgTopicIDN) = $sthl1->fetchrow_array())
	    {
		    my $dbhl = DBI->connect("DBI:mysql:database=i2345240_bb1;host=localhost", "TeamConfed", "password?", {'RaiseError' => 1});
			my $sthl1 = $dbhl->prepare("INSERT INTO `bb_posts` (`topic_id`, `forum_id`, `poster_id`, `icon_id`, `poster_ip`, `post_time`, `post_reported`, `enable_bbcode`, `enable_smilies`, `enable_magic_url`, `enable_sig`, `post_username`, `post_subject`, `post_text`, `post_checksum`, `post_attachment`, `bbcode_bitfield`, `bbcode_uid`, `post_postcount`, `post_edit_time`, `post_edit_reason`, `post_edit_user`, `post_edit_count`, `post_edit_locked`, `post_visibility`, `post_delete_time`, `post_delete_reason`, `post_delete_user`) VALUES (?, '14', '53', '0', '1.1.1.1.1', ?, '0', '1', '1', '1', '0', '', ?, ?, '1fa599d688e39698859d2f1f562f6dea', '0', '', '17qvn3k7', '1', '0', '', '0', '0', '0', '1', '0', '', '0');");
		    $sthl1->execute($dbgTopicIDN, time(), $compiledTitlePost, $titleContent) or print "Couldn't execute statement: $DBI::errstr; stopped";
	    }
    }

	$response = `curl -s "http://www.rankedftw.com/clan/ConFD/ladder-rank/"`;

	#first and only useless <tr></tr> field. after this one is user's <tr>s which is what we're trying to fetch
	$removeThis = qq
	{<tr>
    <th class="number">Rank</th>
    <th class="img">Region</th>
    <th class="img">League</th>
    <th class="team-header" colspan=1>Team</th>
    <th class="number">Points</th>
    <th class="number">Wins</th>
    <th class="number">Losses</th>
    <th class="number">Played</th>
    <th class="number">Win rate</th>
    <th class="number">Age</th>
  </tr>};

	$response =~ s/$removeThis//g;
	$trStart = "<tr";
	$response =~ s/<\/tr>/Ω/g;

## repeat the process of getting a <tr></tr> field of a user
GETMOREUSER:
	($aUser) = ($response =~ /$trStart[^>]*>([^Ω]+)/);
	($theirName) = ($aUser =~ /name[^>]*>([^<]+)/);
	#print $theirName;

	# attempt to "register" the user
	my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "password", "password!", {'RaiseError' => 1});
	
	my $sth = $dbh->prepare("SELECT `username` FROM `rosters` WHERE `username` = ?");
    $sth->execute($theirName) or die "Couldn't execute statement: $DBI::errstr; stopped";
$doit = "yes";
    while(my($dbg_username) = $sth->fetchrow_array())
    {
    	$doit = "no";
    }
    

    if($doit =~ /^(no)$/)
    {
    	# no	
    	print "!";

    }
    else
    {
    	# yes
    	print "k";
		my $sth1 = $dbh->prepare("INSERT INTO `rosters` (`username`, `rank`, `rgroup`, `league`, `race`) VALUES (?, ?, ?, 'Update', 'Update');");
		$sth1->execute($theirName, "22CrewMember", "Members");
		
		logEventRosterNewUser($theirName." - "."Members", "Action: New User<br/>"."Username: ".$theirName."<br/>Group: "."Members");
    }
    $dbh->disconnect();

	$response =~ s/$aUser//g;
	$response =~ s/Ω//;

	#print $response;
	if(index($response, "Ω") != -1)
	{
    	# still more users to fetch
    	goto GETMOREUSER;
	}
	else
	{
		# no more users in clan to check
		#print "END OF DATA";
	}
       
	open(STDERR, ">&STDOUT");
}