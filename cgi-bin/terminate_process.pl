#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use POSIX ":sys_wait_h";
use Data::Dumper;

my $cgi = CGI->new;
print $cgi->header('application/json');
print STDERR "Termination\n";


my $postData = decode_json($cgi->param('POSTDATA'));

if ($postData->{action} eq 'terminate') {
	print STDERR "Here we go\n";

	my @pids = @{$postData->{pids}};
	foreach my $pid (@pids) {
		if ($pid =~ /^\d+$/) { 
			print STDERR "Terminating ongoing process\n";
			kill 'TERM', $pid;
			waitpid($pid, 0);
		}
	}
	print '{"status":"success", "message":"Processes terminated successfully."}';
} else {
	print '{"status":"error", "message":"Invalid action."}';
}
