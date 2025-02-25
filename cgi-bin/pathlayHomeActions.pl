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
my $session_id = $cgi->param('sid') ? $cgi->param('sid') : "no active session";
my $session = CGI::Session->load($session_id);
my $username = $session->param('username') ? $session->param('username') : "";
my $home = $session->param('home') ? $session->param('home') : "";
my $action = $cgi->param('action') ? $cgi->param('action') : ""; 
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

if ($action eq "uploadPack") {
	my $filename = $cgi->param('file');
	my $upload_filehandle = $cgi->upload('file');
	my $basename = basename($filename);
	#my ($tempfile,$tempfilename) = tempfile();
	open (my $out, '>', "$filename.tmp") or die "Could not open temporary file for writing: $!";
	binmode $out;
	my $bytes_written = 0;
	while (my $buffer = <$upload_filehandle>) {
    print $out $buffer;
	}
  close $out;
  my $mime_type = mimetype("$filename.tmp");	
	chomp($mime_type);
	print STDERR "$0: file type: $mime_type\n";
	if ($mime_type eq 'application/zip') {
		my $target = "$parameters->{_userdir}/$basename";
		rename "$filename.tmp", $target or die "Could not move temporary file to '$target': $!";


		ExtractZip(
			File => $parameters->{_userdir}."/$filename",
			Parameters => $parameters
		);
		unlink $parameters->{_userdir}."/$filename";

		print $cgi->header('application/json');
		print to_json(
			{
				message => "File uploaded successfully."
			}
		);
	} else {
		unlink "$filename.tmp";
		print $cgi->header('application/json');
		print to_json(
			{
				message => "Uploaded file is not a zip file."
			}
		);
	}
}
if ($action eq "uploadOmicPack") {
	my $upload_filehandle = $cgi->upload('file');
	if ($upload_filehandle) {
		my $file_content = do {
			local $/; # Enable 'slurp' mode
			<$upload_filehandle>;
		};
    my $is_text = is_text_file(\$file_content);
		my $has_tab = has_tab_separator(\$file_content);
		if ($is_text && $has_tab) {
			my $response = {
				status => "ok",
				content => $file_content
			};
			$response = to_json($response);
			print $cgi->header('application/json');
			print $response;
		} else {
			my $response = {
				status => "error",
				message => !$is_text ? "Not a text file" : $is_text && !$has_tab ? "Not a tab separated text file" : "Not a tab separated text file"
			};
			$response = to_json($response);
			print $cgi->header('application/json');
			print $response;
		}

	} else {
		# Handle the case where no file was uploaded
		my $response = {
				status => "error",
				message => "No file uploaded"
		};
		
		my $json_response = to_json($response);
		
		print $cgi->header('application/json');
		print $json_response;
	}

}

if ($action eq "downloadHome") {
	DownloadZip(
		Parameters => $parameters,
		Target => "home"
	);
}

if ($action eq "addNewExp") {
	$parameters -> {_expname} = getExpToAdd(
		userDir => $parameters->{_userdir}
	);
	mkdir("$parameters->{_userdir}/exp$parameters->{_expname}");
	write_file("$parameters->{_userdir}/exp$parameters->{_expname}/exp$parameters->{_expname}.conf", '');
	changePermissions(
		Input => "$parameters->{_userdir}/exp$parameters->{_expname}"
	);
	print $cgi->header('application/json');
	print to_json(
		{
			message => "New Package created."
		}
	);
}

if ($action eq "saveExp") {
	my $data = decode_json($cgi->param('data'));
	my $expId = $data->{id};
	mkdir("$parameters->{_userdir}/$expId");

	open(OUT,'>',"$parameters->{_userdir}/${expId}/$expId.conf");
	print OUT "expname=$data->{title}\n";
	print OUT "comments=$data->{comments}\n";
	print OUT "organism=$data->{organism}\n";
	foreach my $omic (("gene","prot","urna","meth","meta","chroma")) {
		print OUT "${omic}IdType=$data->{omics}->{$omic}->{idType}\n";
		print OUT "${omic}_id_column=$data->{omics}->{$omic}->{idColumn}\n";
		print OUT "${omic}_dev_column=$data->{omics}->{$omic}->{devColumn}\n";
		print OUT "${omic}_pvalue_column=$data->{omics}->{$omic}->{pValColumn}\n";
	}
	close(OUT);

	foreach my $omic (("gene","prot","urna","meth","meta","chroma")) {
		my $ext = $omic eq "gene" ? "mrna" : $omic eq "urna" ? "mirna" : $omic;
		open(OUT,'>',"$parameters->{_userdir}/${expId}/${expId}.${ext}");
		print OUT $data->{omics}->{$omic}->{textData};
		close(OUT);
	}

	print STDERR Dumper $data->{onts};
	open(OUT,'>',"$parameters->{_userdir}/${expId}/${expId}.ont");
	foreach my $ontId (sort @{$data->{onts}}) {
		print OUT "$ontId\n";
	}
	close(OUT);

	changePermissions(
		Input => "$parameters->{_userdir}/$expId"
	);

	print $cgi->header('application/json');
	print to_json(
		{
			message => "Exp Package Saved."
		}
	);
}


if ($action eq "deleteExp") {
	DeleteExp(
		userHome => $parameters -> {_userdir},
		expId => $cgi -> param('exp')
	);
	print $cgi->header('application/json');
	print to_json(
		{
			message => "Exp Package Deleted."
		}
	);
}
if ($action eq "downloadExp") {
	my $exp = $cgi->param('exp');
	DownloadZip(
		Parameters => $parameters,
		Target => "experiment",
		Exp => $exp
	);
}

if ($action eq "loadExpConf") {
	my $expId = $cgi->param('exp');
	#load conf for selected exp
	my $conf = {};
	my $status;
	if (-f "$parameters->{_userdir}/$expId/$expId.conf") {
		open (IN,"$parameters->{_userdir}/$expId/$expId.conf");
		while(<IN>) {
			chomp;
			my ($tag,$value) = split("=");
			if ($tag eq "expname" || $tag eq "comments" || $tag eq "organism") {
				$conf->{$tag} = $value;
			}
			if ($tag =~ /(^.+?)IdType/) {
				$conf->{$1}->{IdType} = $value; 
			}
			if ($tag =~ /(^.+?)_(.+?)_column$/) {
				$conf->{$1}->{$2."Column"} = $value;
			}

		}
		close(IN);
		$status = "ok";
	} else {
		$status = "missing";
	}

	my $response = {
		status => $status,
		conf => $conf
	};
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
}

if ($action eq "loadExpData") {
	my $expId = $cgi->param('exp');
	my $data = {};
	my @onts = [];

	foreach my $ext (("mrna","prot","mirna","meth","chroma","meta")) {
		my $omic = $ext eq "mrna" ? "gene" : $ext eq "mirna" ? "urna" : $ext;
		if (-e "$parameters->{_userdir}/$expId/$expId.$ext") {
			$data->{$omic} = read_file("$parameters->{_userdir}/$expId/$expId.$ext", chomp => 0);
		} else {
			$data->{$omic} = '';
		}
	}

	if (-e "$parameters->{_userdir}/$expId/$expId.ont") {
		@onts = read_file("$parameters->{_userdir}/$expId/$expId.ont", chomp => 1);
	}


	my $response = {
		status => "ok",
		data => $data,
		onts => [@onts]
	};
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
}

if ($action eq "getOmics") {
	#get available omics by organism available in the server

	my $db = {
  	homo_sapiens => new HomoSapiensDB(),
  	mus_musculus => new MusMusculusDB()
	};
	my $omics = {};
	my $idTypes = {};
	foreach my $org (keys %$db) {
		$omics -> {$db->{$org}->{code}} = $db->{$org}->{omicsValid};
		$idTypes -> {$db->{$org}->{code}} = $db->{$org}->{idTypesValid};
	}

	my $response = {
		status => "ok",
		omicsValid => $omics,
		idTypesValid => $idTypes
	};
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
}
if ($action eq "loadOnts") {
	my $db = {
  	homo_sapiens => new HomoSapiensDB(),
  	mus_musculus => new MusMusculusDB()
	};
	my $orgCodes = {
		homo_sapiens => 'hsa',
		mus_musculus => 'mmu'
	};
	my $ontsList = {};
	foreach my $org (keys %$db) {
		my %defaultOnts = map {$_ => 1} @{$db->{$org}->{defaultOnts}};
		my $ontFile = "$base/pathlay_data/$orgCodes->{$org}/db/$db->{$org}->{fileNames}->{ont}";

		open(IN,$ontFile);
		while(<IN>) {
			chomp;
			my ($ontId,$ontName,$ontLink,$genes) = split(/\t/);
			push (@{$ontsList -> {$orgCodes->{$org}}} ,  {
				id => $ontId,
				link => $ontLink,
				name => $ontName,
				default => $defaultOnts{$ontId} ? 1 : 0,
				genes => [sort(split(/;/,$genes))]
			});
		}
		close(IN);
	}
	my $response = {
		status => "ok",
		onts => $ontsList
	};
	$response = to_json($response);
	print $cgi->header('application/json');
	print $response;
}


# Function to check if file content is text
sub is_text_file {
	my ($content_ref) = @_;
	
	# Simple heuristic: Check for non-printable characters
	# Return false if any character is not printable or a common control character
	for my $char (split //, $$content_ref) {
		return 0 unless $char =~ /^[\x20-\x7E\x09\x0A\x0D]$/; # Printable ASCII characters and common control chars
	}
	
	return 1;
}
# Function to check if file content uses tab as separator
sub has_tab_separator {
	my ($content_ref) = @_;
	
	# Check if there's at least one tab character in the file content
	return $$content_ref =~ /\t/;
}