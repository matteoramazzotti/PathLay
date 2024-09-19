#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use JSON;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
use lib "$FindBin::Bin/modules/";
use PathLayUtils;
use lib "$FindBin::Bin/modules/home/";
use PathLayHomeUtils;
use lib "$FindBin::Bin/modules/frontend/home/";
use PathLayHomeFrontEnd;
use lib "$FindBin::Bin/modules/structures/";
use PathLayJSObjects;


print STDERR "WE ARE HOME\n";
my $cgi = CGI->new;
our $base = "$FindBin::Bin/..";
our $server = "localserver";
our $localhost;
$localhost = `hostname -I` if ($server eq 'localserver');
chomp $localhost;
$localhost =~ s/ .+//g;
$localhost =~ s/ //g;
my $parameters = new Parameters();
my $session_id = $cgi->param('sid');
my $session = CGI::Session->new($session_id);
my $username = $session->param('username');
my $home = $session->param('home');
my $mode = $cgi->param('mode');
my $expId = $cgi->param('exp');

$parameters -> {_host} = $localhost;
$parameters -> {_base} = $base;
$parameters->{_userdir} = $home ne "6135251850" ? "$base/pathlay_users/".$home."/" : "$base/demo_exps/6135251850/";
$parameters -> {_home} = $home;
$parameters -> {_username} = $username;

print STDERR "$0: $session_id\n";
print STDERR "$0: $username\n";
print STDERR "$0: $home\n";
print STDERR "$0: $parameters->{_userdir}\n";
$parameters -> LoadAvailableOrganisms();
 #maybe redundant
# my ($home_script,$form) = HomeBuilder(
# 	Parameters => $parameters
# );
if ($mode eq 'list') {
	$parameters -> LoadAvailableExps(
		UsersDir => $parameters->{_userdir}
	);
	my ($home_script,$form) = HomeBuilderNew(
		Parameters => $parameters
	);
	HomePrinterNew(
		script => $home_script,
		form => $form
	);
}

if ($mode eq 'edit') {
	$parameters -> LoadAvailableOrganisms(); #maybe redundant
	$parameters -> LoadAvailableONTs();
	my ($home_script,$parentDiv) = HomeEditBuilder(
		Parameters => $parameters
	);
	HomePrinterNew(
		script => $home_script,
		form => $parentDiv
	);
}

# print STDERR Dumper $form;

