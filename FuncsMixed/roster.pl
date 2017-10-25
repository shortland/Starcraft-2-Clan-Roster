#!/usr/bin/perl

use CGI;
use utf8;

my $offset;
my $totalRequests;
$totalRequests = 0;

$apiKey = "x";

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
$userAgent = "If you have a problem with me scraping, let me know: ilankleiman@gmail.com thank you!!!";

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
    if($rankedRq =~ /(ConFed)|(xCFx)|(ConFD)/)
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
    if($theirTag =~ /^(\[ConFD\])$/)
    #if($theirTag =~ /^(\[ConFed\]|\[xCFx\]|\[ConFD\])$/) #multiple tags if we expand to more clans
    {
        #print "This is our guy!";
        ($ourGuyFTWLink) = ($rankedField =~ /href[^']*'([^']+)/);#'
        #print $ourGuyFTWLink;
        $totalRequests = $totalRequests + 1;
        $FTWHasBnet = `curl -A $userAgent -s "http://www.rankedftw.com$ourGuyFTWLink"`;
        ($bNetRawLink) = ($FTWHasBnet =~ /bnet-link[^=]*=([^=]+)/);#'
        $bNetRawLink =~ s/ title//g;
        $bNetRawLink =~ s/"//g;#"
        #http://us.battle.net/sc2/en/profile/3801254/1/Shortland/
        $bNetRawLink =~ s/http\:\/\/us\.battle\.net\/sc2\/en\/profile\///g;
        # 3801254/1/Shortland/
        $bNetAPILink = "https://us.api.battle.net/sc2/profile/" . $bNetRawLink . "?locale=en_US&apikey=$apiKey";
        print $bNetAPILink;#."<br/><br/>\n"; 
        #print $totalRequests." server requests";
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