package Command::Clan;

use v5.10;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_clan);

our @PUBLIC_league = ("BRONZE", "SILVER", "GOLD", "PLATINUM", "DIAMOND", "MASTER", "GRANDMASTER");
our @PUBLIC_emojies = ("<:BRONZE3:278725418641522688>", "<:SILVER2:278725418813751297>", "<:GOLD1:278725419073536012>", "<:PLATINUM1:278725419056758784>", "<:DIAMOND1:278725418960551937>", "<:MASTER1:278725418679271425>", "<:GRANDMASTER:278725419186782208>");

use Mojo::Discord;
use Bot::Goose;
use DBI;

use utf8;

use MessageRequest;
use GetIDKey;

###########################################################################################
# Command Info
my $command = "clan";
my $access = 0; # Public
my $description = "This is a clan command for building new actual commands";
my $pattern = '^(~clan)\s(.+)';
my $function = \&cmd_clan;
my $usage = <<EOF;
~clan confed
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

sub cmd_clan
{
    my ($self, $channel, $author, $msg) = @_;

    my $args = $msg;
    my $pattern = $self->{'pattern'};
    $args =~ s/$pattern/$2/i;
    #$args = "" if ($args eq "");

    my $discord = $self->{'discord'};
    my $replyto = '<@' . $author->{'id'} . '>';

    my $ripped = $msg;
    $ripped =~ s/~clan //g;


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

    if(length($search) > 1) { 
        #SELECT DISTINCT name from everyone where clan_tag = 'xcfx'
        my $sth = $dbh->prepare("SELECT * FROM `everyone` WHERE `clan_tag` = '".$search."' ORDER BY `mmr` DESC");
        $sth->execute();
        my $found = "0";
        while (my $row = $sth->fetchrow_hashref()) {
            $found = "1";
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
            $text = $race . "" . $league . "[".$row->{tier}."] " . $row->{name} . " ".$flag." (mmr:" . $row->{mmr} . ")\\n";
            push (@members, $text);
            #MakeDiscordPostJson("/webhooks/$WH_ID/$WH_Key", '{"content" : "'.$text.'"}', "1", "", 0.2);
        }
        if ($found eq "0") {
            $discord->send_message($channel, "unable to find any members of that clan");
        }
    }

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
