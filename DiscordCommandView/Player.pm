package Command::Player;

use v5.10;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_player);

our @PUBLIC_league = ("BRONZE", "SILVER", "GOLD", "PLATINUM", "DIAMOND", "MASTER", "GRANDMASTER");
our @PUBLIC_emojies = ("<:BRONZE3:278725418641522688>", "<:SILVER2:278725418813751297>", "<:GOLD1:278725419073536012>", "<:PLATINUM1:278725419056758784>", "<:DIAMOND1:278725418960551937>", "<:MASTER1:278725418679271425>", "<:GRANDMASTER:278725419186782208>");

use Mojo::Discord;
use Bot::Goose;
use DBI;
use File::Slurp;

use utf8;

use MessageRequest;
use GetIDKey;

###########################################################################################
# Command Info
my $command = "player";
my $access = 0; # Public
my $description = "This is a player command for building new actual commands";
my $pattern = '^(~player)\s?([a-zA-Z0-9#]+)?\s?([a-zA-Z0-9]+)?';
my $function = \&cmd_player;
my $usage = <<EOF;
~player
EOF
###########################################################################################

sub new
{
    my ($class, %params) = @_;
    my $self = {};
    bless $self, $class;
     
    # Setting up this command module requires the Discord connection 
    $self->{'bot'} = $params{'bot'};
    $self->{'discord'} = $self->{'bot'}->discord;
    $self->{'pattern'} = $pattern;

    # Register our command with the bot
    $self->{'bot'}->add_command(
        'command'       => $command,
        'access'        => $access,
        'description'   => $description,
        'usage'         => $usage,
        'pattern'       => $pattern,
        'function'      => $function,
        'object'        => $self,
    );
    
    return $self;
}

sub cmd_player
{
    my ($self, $channel, $author, $msg) = @_;

    my $args = $msg;
    my $pattern = $self->{'pattern'};
    $args =~ s/$pattern/$2/i;
    #$args = "" if ($args eq "");

    my $discord = $self->{'discord'};
    my $replyto = '<@' . $author->{'id'} . '>';

    my $ripped = $msg;
    $ripped =~ s/~player //g;


    my $WH_ID;
    my $WH_Key;

    my @WH_Search = split(m/\|/, GetIDKeyFromC($channel));
    $WH_ID = $WH_Search[0];
    $WH_Key = $WH_Search[1];

    #mine copypasta
    my $search = $ripped;
    my $text = "";
    my $race;

    my @members;

    my $dbh = DBI->connect("DBI:mysql:database=teamconfed;host=localhost", "root", "password!", {'RaiseError' => 1});
    my $sth;
    my ($racial) = $search =~ m/^.+\s(.+)/;
    $racial =~ s/ //g;

    if(index($search, "#") != -1) { 
        my ($racial) = $search =~ m/^.+\s(.+)/;
        if(defined($racial)) {
        	$racial =~ s/ //g;
        }
        else {
        	$racial = "";
        }
        if($racial =~ /^$/) {
            ## just player no race
            $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` = '".$search."' ORDER BY `mmr` DESC");
        }
        else {
            $search =~ s/$racial//g;
            $search =~ s/ //g;
            if($racial =~ /^(terran|zerg|protoss|random)$/i) {
                $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` = '".$search."' AND `race` = '".$racial."' ORDER BY `mmr` DESC");
            }
            elsif($racial =~ /^(kr|na|us|eu|NA|KR|US|EU)$/i) {
                if($racial =~ /^na$/i) {
                    $racial = "us";
                }
                $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` = '".$search."' AND `server` = '".$racial."' ORDER BY `mmr` DESC");
            }
            else {
                MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "please use a race or server: ~player shortland#56600 **NA**"}', "1", "");
                return;
            }
        }

        $sth->execute();
        while (my $row = $sth->fetchrow_hashref()) {
            my $league = GetLeagueNumber(uc($row->{league}));

            if ($row->{race} =~ /^Protoss$/i) {
                $race = "<:PROTOSS:278762398347689984>";
            }
            elsif ($row->{race} =~ /^Terran$/i) {
                $race = "<:TERRAN:278762425552207883>";
            }
            elsif ($row->{race} =~ /^Zerg$/i) {
                $race = "<:ZERG:278762452265467907>";
            }
            else {
                $race = "<:RANDOM:278762354001444864>";
            }

            my $BT = $row->{battle_tag};
            ($BT) = ($BT =~ m/(^[a-zA-Z]+#\d+)/);

            my $lastupdate = read_file("lastupdate.txt");

            $text = '{"content": "", "embeds": [{"footer": {"text": "Last Server Update: '.(scalar localtime $lastupdate).'"}, "author": {"icon_url": "http://138.197.50.244/images/'.uc($row->{race}).'.png", "name": "<'.$row->{clan_tag}.'> '.$search.'", "url": "http://'.$row->{server}.'.battle.net/sc2/en'.$row->{path}.'/"}, "thumbnail": {"url": "http://138.197.50.244/images/'.uc($row->{league}).'.png", "height": 60, "width": 60}, "type": "rich", "color": 4343284, "fields": [{"name": "Profile:", "value": "*http://'.$row->{server}.'.battle.net/sc2/en'.$row->{path}.'/*", "inline": 0}, {"name": "RankedFTW:", "value": "*http://www.rankedftw.com/search/?name=http://'.$row->{server}.'.battle.net/sc2/en'.$row->{path}.'/*", "inline": 0}, {"name": "Tier:", "value": "*'.$row->{tier}.'*", "inline": 1}, {"name": "MMR:", "value": "*'.$row->{mmr}.'*", "inline": 1}, {"name": "Wins:", "value": "*'.$row->{wins}.'*", "inline": 1}, {"name": "Losses:", "value": "*'.$row->{losses}.'*", "inline": 1}, {"name": "Longest Win Streak:", "value": "*'.$row->{longest_win_streak}.'*", "inline": 1}, {"name": "Current Win Streak:", "value": "*'.$row->{current_win_streak}.'*", "inline": 1}, {"name": "Last 1v1:", "value": "*'. (scalar localtime $row->{last_played_time_stamp}) .'*", "inline": 1}, {"name": "BattleNet Tag:", "value": "*'.$BT.'*", "inline": 1}]}]}';

            use MIME::Base64;
            $text = encode_base64($text, "");
            last;
        }

        MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", $text, "1", "", "", "base64");

        if(!defined $text || length $text < 2 || $text =~ /^$/) {
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "unable to find that person, \\nYou may want to this instead: ~bnet NameHere"}', "1", "");
        }
    }
    elsif(defined($racial) && length($racial) > 0 && $racial !~ /^$/) {
        $search =~ s/$racial//g;
        $search =~ s/ //g;
        if($racial =~ /^(terran|zerg|protoss|random)$/i) {
            $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` LIKE '%".$search."%' AND `race` = '".$racial."' ORDER BY `mmr` DESC");
        }
        elsif($racial =~ /^(kr|na|us|eu|KR|NA|US|EU)$/i) {
            if($racial =~ /^na$/i) {
                $racial = "us";
            }
            $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` LIKE '%".$search."%' AND `server` = '".$racial."' ORDER BY `mmr` DESC");
        }
        else {
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "please use a race or server: ~player shortland#56600 **NA/Terran**"}', "1", "");
            return;
        }
        goto HERO;
    }
    else {
        $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `name` LIKE '%".$search."%' ORDER BY `mmr` DESC");#
        
        HERO:
        $sth->execute();
        
        my $lastName = "";
        my $amt = 0;

        my $g_clantag;
        my $g_tier;
        my $g_mmr;
        my $g_wins;
        my $g_losses;
        my $g_ties;
        my $g_ws;
        my $g_cs;
        my $g_cr;
        my $g_pts;
        my $g_lps;
        my $g_btg;
        my $g_path;
        my $g_league;
        my $g_race;
        my $g_server;
        while (my $row = $sth->fetchrow_hashref()) {
            $amt++;
            my $league = GetLeagueNumber(uc($row->{league}));

            if ($row->{race} =~ /^Protoss$/i) {
                $race = "<:PROTOSS:278762398347689984>";
            }
            elsif ($row->{race} =~ /^Terran$/i) {
                $race = "<:TERRAN:278762425552207883>";
            }
            elsif ($row->{race} =~ /^Zerg$/i) {
                $race = "<:ZERG:278762452265467907>";
            }
            else {
                $race = "<:RANDOM:278762354001444864>";
            }
            my $clanTag = "";
            $clanTag = "[".$row->{clan_tag}."]" if (length($row->{clan_tag}) > 0);
            if($row->{name} =~ /^($lastName)$/) {
                $clanTag = "[".$row->{clan_tag}."]" if (length($row->{clan_tag}) > 0);
            }
            my $lastTag = $row->{clan_tag};
            $lastName = $row->{name};
            

            #MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$text.'"}', "1", "", 0.2);

            my $flag = substr($row->{name}, -2, length($row->{name}));
            if($flag =~ /^00$/) {
                $flag = "<:NA:297912161064452096>";
            }
            elsif($flag =~ /^01$/) {
                $flag = "<:KR:297912218438074368>";
            }
            elsif($flag =~ /^02$/) {
                $flag = "<:EU:297912193729560577>";
            }

            $text .= $race."".$league."".$clanTag." ".$row->{name}." ".$flag." (mmr: ".$row->{mmr}.")\\n";

            push(@members, $text);
            $text = "";

            $g_clantag = $row->{clan_tag};
            $g_tier = $row->{tier};
            $g_mmr = $row->{mmr};
            $g_wins = $row->{wins};
            $g_losses = $row->{losses};
            $g_ties = $row->{ties};
            $g_ws = $row->{longest_win_streak};
            $g_cs = $row->{current_win_streak};
            $g_cr = $row->{current_rank};
            $g_pts = $row->{points};
            $g_lps = $row->{last_played_time_stamp};
            $g_btg = $row->{battle_tag};
            $g_path = $row->{path};
            $g_league = $row->{league};
            $g_race = $row->{race};
            $g_server = $row->{server};
        }
        # $text = "There may be multiple people (ranked in multiple races) with a similar name found, \\nPlease be more specific by using their SC2 tag. \\nie: ~player Shortland**#952**\\n" if ($amt > 1);
        if ($amt > 1) {
            # print in chunks
            my $mess = "";
            my $j = 0;
            for(my $i = 0; $i < scalar @members; $i++) {
                $mess .= $members[$i];
                if(($j > 14) || (($i+1) =~ (scalar @members))) {
                    say "sending $text";
                    MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$mess.'"}', "1", "", 0.2);
                    $mess = "";
                    $j = 0;
                }
                $j++;
            }
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "There are multiple people (ranked in multiple races) with a similar name found, \\nPlease be more specific by using their SC2 tag and race. \\nie: ~player Shortland**#952** **terran**\\n"}', "1", "");
            #MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$text.'"}', "1", "");
        }
        elsif($amt =~ /^1$/) {
            $text = "";
            my $league = GetLeagueNumber(uc($g_league));

            if ($g_race =~ /^Protoss$/i) {
                $race = "<:PROTOSS:278762398347689984>";
            }
            elsif ($g_race =~ /^Terran$/i) {
                $race = "<:TERRAN:278762425552207883>";
            }
            elsif ($g_race =~ /^Zerg$/i) {
                $race = "<:ZERG:278762452265467907>";
            }
            else {
                $race = "<:RANDOM:278762354001444864>";
            }

            my $BT = $g_btg;
            ($BT) = ($BT =~ m/(^[a-zA-Z]+#\d+)/);

            my $lastupdate = read_file("lastupdate.txt");

            $text = '{"content": "", "embeds": [{"footer": {"text": "Last Server Update: '.(scalar localtime $lastupdate).'"}, "author": {"icon_url": "http://138.197.50.244/images/'.uc($g_race).'.png", "name": "<'.$g_clantag.'> '.$search.'", "url": "http://'.$g_server.'.battle.net/sc2/en'.$g_path.'/"}, "thumbnail": {"url": "http://138.197.50.244/images/'.uc($g_league).'.png", "height": 60, "width": 60}, "type": "rich", "color": 4343284, "fields": [{"name": "Profile:", "value": "*http://'.$g_server.'.battle.net/sc2/en'.$g_path.'/*", "inline": 0}, {"name": "RankedFTW:", "value": "*http://www.rankedftw.com/search/?name=http://'.$g_server.'.battle.net/sc2/en'.$g_path.'/*", "inline": 0}, {"name": "Tier:", "value": "*'.$g_tier.'*", "inline": 1}, {"name": "MMR:", "value": "*'.$g_mmr.'*", "inline": 1}, {"name": "Wins:", "value": "*'.$g_wins.'*", "inline": 1}, {"name": "Losses:", "value": "*'.$g_losses.'*", "inline": 1}, {"name": "Longest Win Streak:", "value": "*'.$g_ws.'*", "inline": 1}, {"name": "Current Win Streak:", "value": "*'.$g_cs.'*", "inline": 1}, {"name": "Last 1v1:", "value": "*'. (scalar localtime $g_lps) .'*", "inline": 1}, {"name": "BattleNet Tag:", "value": "*'.$BT.'*", "inline": 1}]}]}';

            use MIME::Base64;
            $text = encode_base64($text, "");

            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", "$text", "1", "", "", "base64");
        }
        else {
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "unable to find that person, \\nYou may want to this instead: ~bnet NameHere"}', "1", "");

        }
    }
}

sub GetLeagueNumber {
    my @parms = @_;
    my $leagueNum;
    for(my $i = 0; $i < 7; $i++) {
        if($parms[0] =~ /^$PUBLIC_league[$i]$/) {
            $leagueNum = $i;
            last;
        }
    }
    return $PUBLIC_emojies[$leagueNum];
}

1;
