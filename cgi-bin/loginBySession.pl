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

my $cgi = CGI->new;
our $base = "$FindBin::Bin/..";
our $form = $cgi->Vars;
my $parameters = new Parameters();

$form->{password} = sha256_hex($form->{password});

print STDERR "$0: $form->{username}\n";
print STDERR "$0: $form->{password}\n";
print STDERR "$0: $form->{action}\n";

$parameters -> CheckUserData(
	UsersFile => "$base/pathlay_users/users.list",
	Form => $form
);
print STDERR $parameters->{_home}."\n";
if ($form->{action} eq "login") {

	if ($parameters->{_home} ne "unk" && $parameters->{_home} ne "nopwd") {
		my $session = CGI::Session->new;
		$session->param('username', $form->{username});
		$session->param('home',$parameters->{_home});
		print $cgi->redirect(-uri => "welcome.pl?sid=" . $session->id);
		exit(0);
	} else {
		print $cgi->header('application/json');
		print to_json(
			{
				access => $parameters->{_home},
				message => "Login failed, please try again."
			}
		);
		exit(0);
	}
}

if ($form->{action} eq "register") {
	if ($parameters->{_home} eq "nopwd" || ($parameters->{_home} ne "unk" && $parameters->{_home} ne "nopwd")) {
		print $cgi->header('application/json');
		print to_json(
			{
				access => $parameters->{_home},
				message => "Registration failed: the e-mail provided is already registered."
			}
		);
	} else {
		$parameters -> RegisterUser(
			UsersFile => "$base/pathlay_users/users.list",
			Form => $form
    );
		print $cgi->header('application/json');
		print to_json(
			{
				access => $parameters->{_home},
				message => "Registration complete: please login."
			}
		);
	}
}



