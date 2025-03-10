#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON;
use FindBin;
use File::Basename;
use LWP::Simple;
use Encode;
use Encode::Guess;

# Include the custom library
use lib "$FindBin::Bin/../modules/dbconf/";
use DBMaintainer "qw( HomoSapiensDB MusMusculusDB KGML GPML Node GMTFile)";




# Create a new CGI object
my $query = CGI->new;

# Retrieve parameters with validation
my $organism = $query->param('organism') // '';
my $mapDB = $query->param('mapDB') // '';
my $mapID = $query->param('mapID') // '';
my $imgAvailable = defined $query->param('imgAvailable') ? ($query->param('imgAvailable') eq "true" ? 1 : 0) : 0;
my $fileAvailable = defined $query->param('fileAvailable') ? ($query->param('fileAvailable') eq "true" ? 1 : 0) : 0;
my $fileUrl = $query->param('fileUrl') // '';
my $imgUrl = $query->param('imgUrl') // '';
print STDERR "$imgUrl\n";

my $organismCodes = {
	homo_sapiens => "hsa",
	mus_musculus => "mmu"
};

# Load DB

my $db = {
  homo_sapiens => new HomoSapiensDB(),
	mus_musculus => new MusMusculusDB()
};



$db->{$organism}->parseGeneDB(
	inputFile => "$organismCodes->{$organism}.gene_info"
);
$db->{$organism}->parseMetaDB(
	inputFile => "$organismCodes->{$organism}.compound_info"
);
$db->{$organism}->parseProtDB();



# Initialize response
my $response = {};

# Error handling for missing parameters
unless ($organism && $mapDB && $mapID) {
	print STDERR "Missing mandatory parameters: organism, mapDB, mapID\n";
	print $query->header('application/json');
	print to_json({ error => "Missing mandatory parameters: organism, mapDB, mapID" });
	exit;
}

# Check availability and log issues
if (!$imgAvailable) {
	print STDERR "Missing PNG for $mapID from $mapDB\n";
	my $imgID = $mapID;
	$imgID =~ s/$organismCodes->{$organism}//;
	# Download the PNG file
	my $img_content = get($imgUrl);
	
	if (defined $img_content) {
		# Define the local path to save the image
		my $img_path = "$FindBin::Bin/../pathlay_data/pathways/$mapDB/$imgID.png"; # Adjust the path as necessary
		if ($mapDB ne "wikipathways") {
			open my $fh, '>', $img_path or die "Could not open file '$img_path' $!";
			binmode $fh; # Set to binary mode
			print $fh $img_content;
			close $fh;
		} else {
			# fix resolution
			my $enc = guess_encoding($img_content, qw/utf-8 iso-8859-1/);
			# If guessing fails, default to ISO-8859-1
			if (ref($enc)) {
				$img_content = $enc->decode($img_content);
			} else {
				$img_content = Encode::decode('iso-8859-1', $img_content);
			}
			$img_content =~ s/<svg\b(?=[^>]*\bwidth\b)(?=[^>]*\bheight\b)([^>]*)\bwidth\s*=\s*["'][^"']*["']\s*([^>]*)\bheight\s*=\s*["'][^"']*["']\s*([^>]*)>/"<svg$1$2$3>"/ge;
			open my $rsvg, '|-', "rsvg-convert -o $img_path" or print STDERR "Error running rsvg-convert: $!\n";
			print $rsvg $img_content;
			close $rsvg or print STDERR "Error closing rsvg-convert: $!\n";

		}
		
		
		$imgAvailable = -e $img_path ? 1 : 0;
	} else {
		print STDERR "Failed to download PNG from $imgUrl\n";
	}
}

if (!$fileAvailable) {
	print STDERR "Missing XML for $mapID from $mapDB\n";
	# Download the XML file
	my $file_content = get($fileUrl);
	my $enc = guess_encoding($file_content, qw/utf-8 iso-8859-1/);

	# If guessing fails, default to ISO-8859-1
	if (ref($enc)) {
		$file_content = $enc->decode($file_content);
	} else {
		$file_content = Encode::decode('iso-8859-1', $file_content);
	}



	my $ext = $mapDB eq "kegg" ? "kgml" : $mapDB eq "wikipathways" ? "gpml" : "xml";
	if (defined $file_content) {
		# Define the local path to save the image
		my $file_path = "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/maps/$mapDB/$mapID.$ext"; # Adjust the path as necessary
		open my $fh, '>', $file_path or die "Could not open file '$file_path' $!";
		binmode $fh; # Set to binary mode
		print $fh $file_content;
		close $fh;

		#Print Nodes
		my $xml = $mapDB eq "kegg" ? new KGML(
			fileName => $mapID,
			organismCode => $organismCodes->{$organism}
		) : new GPML (
			fileName => $mapID,
			organismCode => $organismCodes->{$organism}
		);
		$xml->xmlLoader();
		$xml->nodesPrinter(
			conversionTables => $db->{$organism}->{conversionTables}
		);
		if (-e "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/maps/$mapDB/$mapID.nodes") {
			$fileAvailable = 1;
		}
	} else {
		print STDERR "Failed to download XML from $fileUrl\n";
	}
}

# update universe gmts for genes and meta, useful for FETs
my $nodeFile = new Node (
	organismCode => $organismCodes->{$organism},
	fileName => $mapID,
	mapsDB => $mapDB
);
if ($fileAvailable) {
	$nodeFile -> loadContent();
}
foreach my $dataType (('gene','meta')) {
	
	next if (!$nodeFile->{data} || !$fileAvailable);
	my $gmtFile = new GMTFile(
		fileName => $db->{$organism}->{universeFiles}->{$dataType}->{$mapDB},
		organismCode => $organismCodes->{$organism},
		filePath => "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$mapDB/"
	);
	$gmtFile -> loadContent();

	$gmtFile = $nodeFile -> updateMapAssociationFile(
		gmtFile => $gmtFile,
		dataType => $dataType
	);
	$gmtFile -> printContent(
		outFile => "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$mapDB/$db->{$organism}->{universeFiles}->{$dataType}->{$mapDB}"
	);

}



# Build the response
$response = {
    organism => $organism,
    mapDB => $mapDB,
    mapID => $mapID,
    imgAvailable => $imgAvailable ? "true" : "false",
    fileAvailable => $fileAvailable ? "true" : "false"
};

# Send response as JSON
my $json_response = to_json($response);

# Print the HTTP header and the JSON response
print $query->header('application/json');
print $json_response;
