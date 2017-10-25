#!/usr/bin/perl

use CGI::Carp qw( fatalsToBrowser );
use CGI;

BEGIN {	
	$cgi = new CGI;
	$method = $cgi->param("method");
	print $cgi->header(-Location => '../TimedJobs/teamconfed/streaming.pl?method='.$method);
    
	open(STDERR, ">&STDOUT");
}

