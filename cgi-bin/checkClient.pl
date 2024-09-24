#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use JSON;

my $cgi = CGI->new;
my $client = $ENV{'REMOTE_ADDR'};
my $host = "127.0.0.1";
if ($client eq "::1") { #handling ipv6
	$client = "127.0.0.1";
}
my $response = {
	accessGranted => $client ne $host ? "false" : "true"
};
$response = to_json($response);
print $cgi->header('application/json');
print $response;
