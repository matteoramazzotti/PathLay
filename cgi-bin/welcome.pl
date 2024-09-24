#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use File::Slurp;

my $cgi = CGI->new;
my $client = $ENV{'REMOTE_ADDR'};
my $host = "127.0.0.1";
if ($client eq "::1") { #handling ipv6
	$client = "127.0.0.1";
}

# Retrieve the session ID from the query parameter
my $session_id = $cgi->param('sid');

# Load the session using the session ID
my $session = CGI::Session->new($session_id);

# Retrieve the username from the session
my $username = $session->param('username');
my $home = $session->param('home');
print STDERR "$0: session: $session_id\n";
# Check if the username is present in the session
if (defined $username) {
	print STDERR "$0: username: $username\n";
	print STDERR "$0: home: $home\n";
	my $html_content = read_file('../welcome.html');
	
	$html_content =~ s/_USER/$username/g;

	if ($client ne $host) {
		$html_content =~ s/redirect("dbconf")/""/g;
		$html_content =~ s/settings/lock/;
	}

	print $cgi->header;
	print $html_content;
} else {
	# Handle the case where the session is invalid or has expired
	print $cgi->header;
	print $cgi->start_html('Session Error');
	print "<h2>Session Error</h2>";
	print "<p>Your session has expired or is invalid. Please log in again.</p>";
	print $cgi->end_html;
}

exit;
