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
use lib "$FindBin::Bin/modules/structures/";
use PathLayJSObjects;
use File::Basename;
use File::Slurp;
use File::Temp qw(tempfile);
use File::MimeInfo::Simple;
use lib "$FindBin::Bin";
use DBMaintainer;


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
my $action = $cgi->param('action');
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
print STDERR "$0: $action\n";


if ($action eq "checkConf") {
	my $conf = {};
	my $response = {
		status => '',
		message => ''
	};
	my @omics = ('gene','prot','urna','meth','chroma','meta');
	my $alias = {
		gene => 'mrna',
		urna => 'mirna',
		_id_column => 'idColumn',
		_dev_column => 'devColumn',
		_pvalue_column => 'pValColumn'
	};
	my @cols = ('_id_column','_dev_column','_pvalue_column');

	if (-z "$parameters->{_userdir}/$expId/$expId.conf") {
		$response->{status} = 'error';
		$response->{message} = 'Experiment Package not configured: check it in Home section';
		$response = to_json($response);
		print $cgi->header('application/json');
		print $response;
		exit;
	}
	open(IN,"$parameters->{_userdir}/$expId/$expId.conf") or die "Error opening conf file!\n";
	while(<IN>) {
		chomp;
		my ($tag,$val) = split("=");
		$conf->{$tag} = $val;
	}
	close(IN);
	foreach my $omic (@omics) {
		#check if columns are configured in the home section
		foreach my $col (@cols) {
			if ($conf->{"$omic$col"} =~ /^\d+$/) {
				$response->{checks}->{$omic}->{$alias->{$col}} = 1;
			}
		}
		#check if data is available
		my $ext = $alias->{$omic} ? $alias->{$omic} : $omic;
		$response->{checks}->{$omic}->{dataAvailable} = -z "$parameters->{_userdir}/${expId}/$expId.$ext" ? 0 : 1;
	}
	print STDERR Dumper $response;
	$response->{status} = 'ok';
	$response->{message} = 'Experiment Package configured';
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
	exit;
}

if ($action eq "loadLastConf") {
	my $conf = {};
	my $response = {
		status => '',
		message => ''
	};
	my @omics = ('gene','prot','urna','meth','chroma','meta');
	if (-z "$parameters->{_userdir}/$expId/$expId.last") {
		$response->{status} = 'error';
		$response->{message} = 'There is no previous configuration';
		$response = to_json($response);
		print $cgi->header('application/json');
		print $response;
		exit;
	}
	open(IN,"$parameters->{_userdir}/$expId/$expId.last") or die "Error opening last file!\n";
	while(<IN>) {
		chomp;
		my ($tag,$val) = split("=");
		$conf->{$tag} = $val;
	}
	close(IN);

	my @booleanTags = ("LeftEffectSizeCheck","RightEffectSizeCheck","pValCheck","IdOnlyCheck");
	my @thresholds = ("pValThreshold","LeftThreshold","RightThreshold");
	my @tfs = ("enabletfs","enabletfsIdOnly","nodeg_select_tf","tfsNoDEFromIdOnlyCheck");
	my @nodegs = ("nodeg_select","NoDEFromIdOnlyCheck");
	
	foreach my $omic (@omics) {
		$response -> {conf} -> {$omic} -> {enabled} = $conf->{"enable$omic"} ? "1" : "0";
		$response -> {conf} -> {$omic} -> {enabledFET} = $conf->{"${omic}FETEnabled"} ? "1" : "0";
		
		foreach my $tag (@booleanTags) {
			$response -> {conf} -> {$omic} -> {$tag} = $conf->{"$omic$tag"};
		}
		foreach my $thr (@thresholds) {
			$response -> {conf} -> {$omic} -> {$thr} = $conf->{"$omic$thr"};
		}
		if ($omic eq "gene" || $omic eq "prot") {
			foreach my $tf (@tfs) {
				$response -> {conf} -> {$omic} -> {$tf} = $conf->{"${tf}_$omic"};
			}
		}
		if ($omic ne "gene" && $omic ne "prot" && $omic ne "meta") {
			$response -> {conf} -> {$omic} -> {nodeg_select} = $conf->{"nodeg_select_${omic}"};
			$response -> {conf} -> {$omic} -> {NoDEFromIdOnlyCheck} = $conf->{"${omic}NoDEFromIdOnlyCheck"};
		}
	}
	$response -> {conf} -> {mapsDB} = $conf -> {maps_db_select}; 
	$response -> {conf} -> {FETIntersect} = $conf -> {FETIntersect}; 
	$response -> {conf} -> {FETPooling} = $conf -> {FETPooling}; 


	$response->{status} = 'ok';
	$response->{message} = 'Last Conf Retrieved';
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
	exit;
}

if ($action eq "loadExpData") {
	my $expId = $cgi->param('exp');
	my $response = {
		status => '',
		message => ''
	};
	my $data = {};
	my @onts = [];

	if (-z "$parameters->{_userdir}/$expId/$expId.conf") {
		$response->{status} = 'error';
		$response->{message} = 'Experiment Package not configured: check it in Home section';
		$response = to_json($response);
		print $cgi->header('application/json');
		print $response;
		exit;
	}
	my $expConf = loadConf(
		confFile => "$parameters->{_userdir}/$expId/$expId.conf"
	);

	
	foreach my $ext (("mrna","prot","mirna","meth","chroma","meta")) {
		my $omic = $ext eq "mrna" ? "gene" : $ext eq "mirna" ? "urna" : $ext;
		if (-e "$parameters->{_userdir}/$expId/$expId.$ext") {
			$data->{$omic}->{textData} = read_file("$parameters->{_userdir}/$expId/$expId.$ext", chomp => 0);
			@{$data->{$omic}->{objData}} = parseTextData(
				textData => $data->{$omic}->{textData},
				expConf => $expConf->{$omic}
			);
		} else {
			$data->{$omic}->{textData} = '';
		}
	}
	if (-e "$parameters->{_userdir}/$expId/$expId.ont") {
		@onts = read_file("$parameters->{_userdir}/$expId/$expId.ont", chomp => 1);
	}


	$response = {
		status => "ok",
		data => $data,
		onts => [@onts]
	};
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
}

if ($action eq "updateLastConf") {
	my $expId = $cgi->param('exp');
	my $userDir = $home ne "6135251850" ? "$base/pathlay_users/".$home."/" : "$base/demo_exps/6135251850/";
	my $response = {
		status => '',
		message => 'Update Complete'
	};
	if ($home eq '6135251850') {
		$response = to_json($response);
		print $cgi->header('application/json');
		print $response;
		exit;
	}

	print STDERR "Updating\n";
	my $conf = from_json($cgi->param('conf'));
	my $lastFile = {
		maps_db_select => $conf->{mapDBSelected},
		FETPooling => $conf->{enabledFETPooling} ? 1 : 0,
		FETIntersect => $conf->{enabledFETIntersect} ? 1 : 0
	};
	foreach my $omic (("gene","prot","urna","meth","chroma","meta")) {
		$lastFile->{$omic}->{"enable${omic}"} = $conf->{enabledOmics}->{$omic} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}FETEnabled"} = $conf->{enabledFETs}->{$omic} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}LeftEffectSizeCheck"} = $conf->{omicConfs}->{$omic}->{esLeftEnabled} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}RightEffectSizeCheck"} = $conf->{omicConfs}->{$omic}->{esRightEnabled} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}pValCheck"} = $conf->{omicConfs}->{$omic}->{pValEnabled} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}IdOnlyCheck"} = $conf->{omicConfs}->{$omic}->{idOnlyEnabled} ? 1 : 0;
		$lastFile->{$omic}->{"${omic}LeftThreshold"} = $conf->{omicConfs}->{$omic}->{esLeftThr};
		$lastFile->{$omic}->{"${omic}RightThreshold"} = $conf->{omicConfs}->{$omic}->{esRightThr};
		$lastFile->{$omic}->{"${omic}pValThreshold"} = $conf->{omicConfs}->{$omic}->{pValThr};
		if ($omic eq "gene" || $omic eq "prot") {
			$lastFile->{$omic}->{"enabletfs_${omic}"} = $conf->{omicConfs}->{$omic}->{tfEnabled} ? 1 : 0;
			$lastFile->{$omic}->{"nodeg_select_tf_${omic}"} = $conf->{omicConfs}->{$omic}->{tfNoDeEnabled} ? 1 : 0;
			$lastFile->{$omic}->{"enabletfsIdOnly_${omic}"} = $conf->{omicConfs}->{$omic}->{tfIdOnlyEnabled} ? 1 : 0;
			$lastFile->{$omic}->{"tfsNoDEFromIdOnlyCheck_${omic}"} = $conf->{omicConfs}->{$omic}->{tfNoDeIdOnlyEnabled} ? 1 : 0;
		}
		if ($omic eq "urna" || $omic eq "meth"|| $omic eq "chroma") {
			$lastFile->{$omic}->{"nodeg_select_${omic}"} = $conf->{omicConfs}->{$omic}->{noDeLoadEnabled} ? 1 : 0;
			$lastFile->{$omic}->{"${omic}NoDEFromIdOnlyCheck"} = $conf->{omicConfs}->{$omic}->{noDeLoadIdOnlyEnabled} ? 1 : 0;
		}
	}
	print STDERR "${userDir}/${expId}/${expId}.last\n";
	print STDERR Dumper $conf;
	print STDERR Dumper $lastFile;
	open(LAST,">","${userDir}/${expId}/${expId}.last");
	print LAST "maps_db_select=$lastFile->{maps_db_select}\n";
	print LAST "FETPooling=$lastFile->{FETPooling}\n";
	print LAST "FETIntersect=$lastFile->{FETIntersect}\n";
	foreach my $omic (("gene","prot","urna","meth","chroma","meta")) {
		foreach my $tag (keys %{$lastFile->{$omic}}) {
			print LAST "$tag=$lastFile->{$omic}->{$tag}\n";
		}
	}
	close(LAST);

	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;

}

sub loadConf {
	my %args = (
		@_
	);
	my $confFile = $args{confFile}; 

	my $conf = {};
	open(IN,$confFile) or die "Error opening conf file!\n";
	while(<IN>) {
		chomp;
		my ($tag,$val) = split("=");
		if ($tag =~ /(.+?)_(.+?)_column/) {
			$conf->{$1}->{$2."_column"} = $val;
		} elsif ($tag =~ /(.+?)IdType/) { 
			$conf->{$1}->{"idType"} = $val;
		} else {
			$conf->{$tag} = $val;
		}
	}
	close(IN);

	return($conf);
}
sub parseTextData {
	my %args = (
		@_
	);
	my $textData = $args{textData};
	my $expConf = $args{expConf};
	my @data = split("\n",$textData);
	my @dataObjs;
	return if (!$expConf->{id_column});
	foreach my $dataEntry (@data) {
		chomp($dataEntry);
		$dataEntry =~ s/\r//g;
		my $obj = {};
		my @cols = split("\t",$dataEntry);


		$obj = {
			id => $expConf->{id_column} ? $cols[$expConf->{id_column}-1] : undef,
			esVal => $expConf->{dev_column} ? $cols[$expConf->{dev_column}-1] : undef,
			pVal => $expConf->{pvalue_column} ? $cols[$expConf->{pvalue_column}-1] : undef,
			hasEs => $expConf->{dev_column} && $cols[$expConf->{dev_column}-1] ? "1" : "0",
			haspVal => $expConf->{pvalue_column} && $cols[$expConf->{pvalue_column}-1] ? "1" : "0",
			isIdOnly => !$cols[$expConf->{dev_column}-1] ? "1" : "0",
		};
		push(@dataObjs,$obj);

	}
	return(@dataObjs);
}