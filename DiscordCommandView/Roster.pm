package Command::Roster;

use v5.10;
#use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_roster);
our @PUBLIC_league = ("BRONZE", "SILVER", "GOLD", "PLATINUM", "DIAMOND", "MASTER", "GRANDMASTER");
our @PUBLIC_emojies = ("<:BRONZE3:278725418641522688>", "<:SILVER2:278725418813751297>", "<:GOLD1:278725419073536012>", "<:PLATINUM1:278725419056758784>", "<:DIAMOND1:278725418960551937>", "<:MASTER1:278725418679271425>", "<:GRANDMASTER:278725419186782208>");
our @PUBLIC_race = ("TERRAN", "ZERG", "PROTOSS", "RANDOM");
our @PUBLIC_raceEmojies = ("<:TERRAN:278762425552207883>", "<:ZERG:278762452265467907>", "<:PROTOSS:278762398347689984>", "<:RANDOM:278762354001444864>");

use Mojo::Discord;
use Bot::Goose;
use Mojo::JSON qw(decode_json);
use Data::Dumper;

use File::Slurp;
use Math::Round;

use MessageRequest;
use GetIDKey;

###########################################################################################
# Command Info
my $command = "Roster";
my $access = 0; # For everyone
my $description = "Make the bot list ConFed ranked SC2 Members";
my $pattern = '^(~roster)\s?([a-zA-Z]+)?\s?([a-zA-Z]+)?\s?([a-zA-Z]+)?';
my $function = \&cmd_roster;
my $usage = <<EOF;
Usage: ~roster
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

sub cmd_roster
{
    my ($self, $channel, $author, $msg, $text, $doit) = @_;
    my $args = $msg;
    my $discord = $self->{'discord'};
    PlzPrint($self, $channel, $author, $msg);
}

sub PlzPrint
{
    my ($self, $channel, $author, $msg) = @_;
    my $two = $2;
    my $three = $3;

    my $WH_ID;
    my $WH_Key;

    my @WH_Search = split(m/\|/, GetIDKeyFromC($channel));
    $WH_ID = $WH_Search[0];
    $WH_Key = $WH_Search[1];

    if($channel !~ /^258278694487982080$/ && $msg =~ /^~roster$/) {
        MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "Responses using ~roster tend to be large so it is posted in <#258278694487982080>"}', "1", "");
    }

    my $data = `curl -s "http://138.197.50.244/_jobs/teamconfed/JoinMembers.php"`;
    if($data =~ /^(\[\]|)$/) {
        #say "error no";
        #cmd_roster($self, $channel, $author, $msg, "returned brackets derp", 1);
        MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "got invalid data from list"}', "1", "");
        die "errorderp\n";
        exit;
    }
    $data = decode_json($data);

    if( !defined($two) ) {
        print ">>".scalar(@{$data})."\n";

        my @people = ();
        for(my $i = 0; $i < scalar(@{$data}); $i++) {
            #print "got a person\n";
            my $league = GetLeagueNumber(uc($data->[$i]{'league'}));
            push(@people, "" . $league . " [" . $data->[$i]{'clan_tag'} . "] ". $data->[$i]{'name'}." (mmr: " . $data->[$i]{'mmr'} . ")\n");
        }

        my $text = "";
        my $j = 0;
        for(my $i = 0; $i < scalar @people; $i++) {
            $text .= $people[$i];
            if(($j > 20) || (($i+1) =~ (scalar @people))) {
                $text =~ s/\n/\\n/g;

                #my @WH_channels = split(m/\n/, read_file("buffers/webhook_buffer.txt"));
                #my @words = split(m/\|/, $WH_channels[6]);

                my $bufferIDKey = GetIDKeyFromC('258278694487982080');
                my @words = split(m/\|/, $bufferIDKey);
                #say $words[1] . "\n" . $words[2] . "\n";
                MakeDiscordPostJson("/webhooks/$words[0]/$words[1]", '{"content" : "'.$text.'"}', "1", "");

                $text = "";
                $j = 0;
            }
            $j++;
        }
    }
    elsif ($two =~ /^export$/) {
        if ($three =~ /^([0-9a-zA-Z]+)$/i) {
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "Converting and exporting..."}', "1", "");

            system(`mysql -e "SELECT name, league, race, tier, mmr, wins, losses, game_count, DATE_FORMAT(FROM_UNIXTIME(last_played_time_stamp), '%b %e') AS 'date_formatted', battle_tag, path FROM everyone WHERE clan_tag = '$three' ORDER BY name ASC" -u root -pLegoApril181998! teamconfed > /var/www/html/DUMPS/${three}_A_DUMP.txt`);
            
            my $readFile = read_file("/var/www/html/DUMPS/${three}_A_DUMP.txt");

            $readFile =~ s/\/profile\//http\:\/\/us\.battle\.net\/sc2\/en\/profile\//g;
            $readFile =~ s/\\\\_Terran\\\\_us//g;
            $readFile =~ s/\\\\_Zerg\\\\_us//g;
            $readFile =~ s/\\\\_Protoss\\\\_us//g;
            $readFile =~ s/\\\\_Random\\\\_us//g;

            $readFile =~ s/\n/\/\n/g;

            write_file("/var/www/html/DUMPS/${three}_A_DUMP.txt", $readFile);

            system(`cd /var/www/html/DUMPS/ && ./tabtoexcel.pl ${three}_A_DUMP.txt ${three}_DUMP.xls`);

            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "Exports Complete: \\nText: http://138.197.50.244/DUMPS/'.$three.'_A_DUMP.txt\\nExcel: http://138.197.50.244/DUMPS/'.$three.'_DUMP.xls"}', "1", "");

        }
        else {
            MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "Only ~roster export clantag"}', "1", "");
        }
    }
    else {
        my @WH_channels = split(m/\n/, read_file("buffers/webhook_buffer.txt"));
        my @words = split(m/\|/, $WH_channels[6]);
        my $third = $three;
        my @people;
        say $third;
        if($two =~ /^count$/) {
            if ($third =~ /^league$/) {
                say $third . "YAS";
                my $bronze = 0, $silver = 0, $gold = 0, $platinum = 0, $diamond = 0, $master = 0, $grandmaster = 0;
                for(my $i = 0; $i < scalar(@{$data}); $i++) {                       
                    my $realL = uc($data->[$i]{'league'});

                    $bronze++ if($realL =~ /^BRONZE$/);
                    $silver++ if($realL =~ /^SILVER$/);
                    $gold++ if($realL =~ /^GOLD$/);
                    $platinum++ if($realL =~ /^PLATINUM$/);
                    $diamond++ if($realL =~ /^DIAMOND$/);
                    $master++ if($realL =~ /^MASTER$/);
                    $grandmaster++ if($realL =~ /^GRANDMASTER$/);
                }
                push(@people, "Here are some league stats for the clan:\\n");
                my $totalRanked = ($bronze+$silver+$gold+$platinum+$diamond+$master+$grandmaster);
                push(@people, GetLeagueNumber("GRANDMASTER") . " x " . $grandmaster . "  (" . nearest(.01, (($grandmaster/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("MASTER") . " x " . $master . "  (" . nearest(.01, (($master/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("DIAMOND") . " x " . $diamond . "  (" . nearest(.01, (($diamond/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("PLATINUM") . " x " . $platinum . "  (" . nearest(.01, (($platinum/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("GOLD") . " x " . $gold . "  (" . nearest(.01, (($gold/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("SILVER") . " x " . $silver . "  (" . nearest(.01, (($silver/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetLeagueNumber("BRONZE") . " x " . $bronze . "  (" . nearest(.01, (($bronze/$totalRanked)*100)) ."\%)\\n");
                push(@people, "Total Ranked: " . $totalRanked . "\\n");
                push(@people, "\\n");
            }
            elsif($third =~ /^race$/) {
                my $terran = 0, $zerg = 0, $protoss = 0, $random = 0;
                for(my $i = 0; $i < scalar(@{$data}); $i++) {                       
                    #actual league "DIAMOND"
                    my $realL = uc($data->[$i]{'race'});

                    $terran++ if($realL =~ /^TERRAN$/);
                    $zerg++ if($realL =~ /^ZERG$/);
                    $protoss++ if($realL =~ /^PROTOSS$/);
                    $random++ if($realL =~ /^RANDOM$/);                     
                }

                push(@people, "Here are some race stats for the clan:\\n");
                my $totalRanked = ($terran+$zerg+$protoss+$random);
                push(@people, GetRaceNumber("TERRAN") . " x " . $terran . "  (" . nearest(.01, (($terran/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetRaceNumber("ZERG") . " x " . $zerg . "  (" . nearest(.01, (($zerg/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetRaceNumber("PROTOSS") . " x " . $protoss . "  (" . nearest(.01, (($protoss/$totalRanked)*100)) . "\%)\\n");
                push(@people, GetRaceNumber("RANDOM") . " x " . $random . "  (" . nearest(.01, (($random/$totalRanked)*100)) . "\%)\\n");
                push(@people, "Total Ranked: " . $totalRanked . "\\n");
                push(@people, "\\n");
            }
            else {
                MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$third.'I could not find that filter, try: \\n~roster count league \\n or \\n~roster count race"}', "1", "");
                return;
            }
        }
        else {
            for(my $i = 0; $i < scalar(@{$data}); $i++) {
                my $league = GetLeagueNumber(uc($data->[$i]{'league'}));
                my $realL;

                $two = "GRANDMASTER" if ($two =~ /^(gm|grandmasters)$/i);
                $two = "PLATINUM" if ($two =~ /^(plat|platinums)$/i);
                $two = "MASTER" if ($two =~ /^(masters)$/i);

                if (uc($two) ~~ @PUBLIC_league) {
                    $realL = uc($data->[$i]{'league'});
                }
                elsif (uc($two) ~~ @PUBLIC_race) {
                    $realL = uc($data->[$i]{'race'});
                }
                elsif (uc($two) ~~ @PUBLIC_clanTags) {
                    $realL = uc($data->[$i]{'clan_tag'});
                }
                else {
                    MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "I couldnt find that filter, try: \\n~roster count league \\n or \\n~roster count race"}', "1", "");
                    last;
                }

                if (uc($two) =~ /^($realL)$/i) {
                    push(@people, "" . $league . " [" . $data->[$i]{'clan_tag'} . "] ". $data->[$i]{'name'}." (mmr: " . $data->[$i]{'mmr'} . ")\\n");
                }
            }
        }

        # split and send message

        $text = "";
        $j = 0;
        for(my $i = 0; $i < scalar @people; $i++) {
            $text .= $people[$i];
            if(($j > 20) || (($i+1) =~ (scalar @people))) {
                say "sending $text";
                MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$text.'"}', "1", "");
                $text = "";
                $j = 0;
            }
            $j++;
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

sub GetRaceNumber {
    my @parms = @_;
    my $racenum;
    for(my $i = 0; $i < 4; $i++) {
        if($parms[0] =~ /^$PUBLIC_race[$i]$/) {
            $racenum = $i;
            last;
        }
    }
    return $PUBLIC_raceEmojies[$racenum];
}

1;
