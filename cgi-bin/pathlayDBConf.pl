#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use JSON;
use Digest::SHA qw(sha256_hex);
use File::Slurp;
use Data::Dumper;

my $cgi = CGI->new;

my $session_id = $cgi->param('sid');
my $session = CGI::Session->new($session_id);

print STDERR "$0: $session_id\n";

my $html_content = read_file('../db_conf.html');

print $cgi->header;
print $html_content;