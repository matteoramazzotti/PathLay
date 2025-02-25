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
use lib "$FindBin::Bin/modules/frontend/access/";
use PathLayAccessFrontEnd;
use lib "$FindBin::Bin/modules/structures/";
use PathLayJSObjects;

print STDERR "WE ARE IN ACCESS\n";
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
my $session = CGI::Session->load($session_id);
my $username = $session->param('username');
my $home = $session->param('home');
my $mode = $cgi->param('mode');
my $exp = $cgi->param('exp');

$parameters -> {_host} = $localhost;
$parameters -> {_base} = $base;
$parameters->{_userdir} = $home ne "6135251850" ? "$base/pathlay_users/".$home."/" : "$base/demo_exps/6135251850/";
$parameters -> {_home} = $home;

print STDERR "$0: $session_id\n";
print STDERR "$0: $username\n";
print STDERR "$0: $home\n";
print STDERR "$0: $parameters->{_userdir}\n";


if ($mode eq 'list') {
	print STDERR "list\n";
	$parameters -> LoadAvailableExps(
		UsersDir => $parameters->{_userdir}
	);
	my ($access_script,$parentDiv) = AccessBuilderNew(
		Parameters => $parameters
	);
	AccessPrinterNew(
		script => $access_script,
		form => $parentDiv,
		action => "list"
	);
}

if ($mode eq 'conf') {
	$parameters -> LoadAvailableExps(
		UsersDir => $parameters->{_userdir}
	);
	my ($access_script,$parentDiv) = AccessBuilderEditNew(
		Parameters => $parameters
	);

	AccessPrinterNew(
		script => $access_script,
		form => $parentDiv,
		action => "conf"
	);
}
