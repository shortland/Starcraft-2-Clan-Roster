#!/usr/bin/perlml

use CGI;
use utf8;

my $offset;
my $totalRequests;
$totalRequests = 0;

$apiKey = "XXXXXXXX";

BEGIN
{
    $q = new CGI;
    {   
        print $q->header(-type =>'text/html', -charset => 'UTF-8');
        $username = $q->param("username");
        $offset = $q->param("offset"); # can leave blank... just for manual tinkering
        #$league = $q->param("league"); # current league. or highest achieved league if unranked
    }
    open(STDERR, ">&STDOUT");
}
if(!defined $username)
{
    print "no user defined";
    exit;
}
$userAgent = "https://github.com/shortland/Starcraft-2-Clan-Roster"; # set this to your own email, so he can contact you if he doesn't want you scraping anymore

# Will require updating when/if rankedftw.com changes html, 
# This is in no way using an api

# scrapes only the crucial html
sub getData
{
    my ($username, $offset) = @_;
    if($offset =~ /^()$/)
    {
        $offset = 0;
    }
    $totalRequests = $totalRequests + 1;
    $rankedRq = `curl -A $userAgent -s "http://www.rankedftw.com/search/?name=$username&offset=$offset"`;
    if($rankedRq =~ m/Nothing\ found\./)
    {
        print "User not found, check spelling?";
        exit;
    }
    $rankedRq =~ s/\<\/ul\>/\Ω/g;
    ($rankedRq) = ($rankedRq =~ /result[^>]*>([^Ω]+)/);
    
    #checkForName($rankedRq, $username, $offset);
    screenForName($rankedRq, $username, $offset);
}

# check offset in batches of 31/32 rather than 1 at a time for m/[ConFed]/
sub screenForName
{
    my ($rankedRq, $username, $offset) = @_;
    if($rankedRq =~ /(ConFed)|(xCFx)/)
    {
        #print "This offset has ConFed member: offset ( $offset )";
        checkForName($rankedRq, $username, $offset);
        exit;
    }
    else
    {
        $newOffset = $offset + 30;
        getData($username, $newOffset);
    }
}

# we know it's here, now we just try and single it out...
sub checkForName
{
    my ($rankedRq, $username, $offset) = @_;
    # start point
    $rankedRq =~ s/tabindex/Ω/;
    $rankedRq =~ s/\<\/a\>/∆/;
    ($rankedField) = ($rankedRq =~ /[^Ω]*Ω([^∆]+)/);
    # remove a field
    $rankedRq =~ s/$rankedField//g;
    ($theirTag) = ($rankedField =~ /tag[^>]*>([^<]+)/);
    if($theirTag =~ /^(\[ConFed\]|\[xCFx\])$/)
    {
        ($ourGuyFTWLink) = ($rankedField =~ /href[^']*'([^']+)/);#'
        $totalRequests = $totalRequests + 1;
        $FTWHasBnet = `curl -A $userAgent -s "http://www.rankedftw.com$ourGuyFTWLink"`;
        ($bNetRawLink) = ($FTWHasBnet =~ /bnet-link[^=]*=([^=]+)/);#'
        $bNetRawLink =~ s/ title//g;
        $bNetRawLink =~ s/"//g;#"
        $bNetRawLink =~ s/http\:\/\/us\.battle\.net\/sc2\/en\/profile\///g;
        $bNetAPILink = "https://us.api.battle.net/sc2/profile/" . $bNetRawLink . "?locale=en_US&apikey=$apiKey";
        print $bNetAPILink;
    }
    else
    {
        $newoffset = $offset + 1;
        if($newoffset >= 1001)
        {
            # this is a bit far fetched... but some (a lot) of people have duplicate names... 378 results for "Orion"
            print "exceeded 1k offset searches";
            exit;
        }
        #print "not found $username :::: $offset :::: $newoffset";
        getData($username, $newoffset);
        exit;
    }
}

getData($username, $offset);