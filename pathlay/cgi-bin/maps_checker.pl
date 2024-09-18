#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use JSON;
use XML::Simple;
use File::Spec;
use File::Basename;
use LWP::Simple;
use Data::Dumper;
use FindBin;
# Include the custom library
use lib "$FindBin::Bin";
use DBMaintainer;

my $sources = {
	homo_sapiens => {
		img => {
			"hsa_mirtarbase.tsv" => "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/images/index_img.png",
			"hsa_uniprot.tsv" => "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-cW23RSijmVik8jJLBbGoattN3yrhdL6mWx5m1_Lvow&s",
			"hsa_ont.gmt" => "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-cW23RSijmVik8jJLBbGoattN3yrhdL6mWx5m1_Lvow&s",
			"hsa_tf.gmt" => "https://avatars.githubusercontent.com/u/22833346?s=280&v=4",
			"hsa.compound_info" => "https://upload.wikimedia.org/wikipedia/en/8/80/KEGG_database_logo.gif",
			"hsa.gene_info" => "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/US-NLM-NCBI-Logo.svg/1658px-US-NLM-NCBI-Logo.svg.png"
		},
		file => {
			"hsa_mirtarbase.tsv" => "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/cache/download/9.0/hsa_MTI.xlsx",
			"hsa_uniprot.tsv" => "https://rest.uniprot.org/uniprotkb/search?compressed=true&download=true&fields=accession%2Cid%2Cgene_names%2Cprotein_name%2Cxref_geneid%2Corganism_name&format=tsv&query=%28%28organism_id%3A9606%29%29+AND+%28reviewed%3Atrue%29",
			#"hsa_ont.gmt" => "https://data.broadinstitute.org/gsea-msigdb/msigdb/release/2023.2.Hs/c5.all.v2023.2.Hs.json",
			"hsa_ont.gmt" => "https://rest.uniprot.org/uniprotkb/stream?compressed=true&download=true&fields=accession%2Cid%2Cgene_names%2Cprotein_name%2Cxref_geneid%2Corganism_name%2Cgo%2Cgo_id%2Cgo_f%2Cgo_c%2Cgo_p&format=tsv&query=%28*%29+AND+%28model_organism%3A9606%29",
			"hsa_tf.gmt" => "https://data.broadinstitute.org/gsea-msigdb/msigdb/release/2023.2.Hs/c3.tft.gtrd.v2023.2.Hs.entrez.gmt",
			"hsa.compound_info" => "https://rest.kegg.jp/list/compound",
			"hsa.gene_info" => 'https://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz'
		},
		type => {
			"hsa_mirtarbase.tsv" => "urna",
			"hsa_uniprot.tsv" => "prot",
			"hsa_ont.gmt" => "ont",
			"hsa_tf.gmt" => "tf",
			"hsa.compound_info" => "meta",
			"hsa.gene_info" => "gene"
		},
		useProxy => {
			"hsa.compound_info" => {},
			"hsa_ont.gmt" => {},
			"hsa_mirtarbase.tsv" => {},
		},
		useFork => {
			"hsa_mirtarbase.tsv" => {}
		}
	},
	mus_musculus => {
		img => {
			"mmu_mirtarbase.tsv" => "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/images/index_img.png",
			"mmu_uniprot.tsv" => "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-cW23RSijmVik8jJLBbGoattN3yrhdL6mWx5m1_Lvow&s",
			"mmu_ont.gmt" => "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-cW23RSijmVik8jJLBbGoattN3yrhdL6mWx5m1_Lvow&s",
			"mmu_tf.gmt" => "https://avatars.githubusercontent.com/u/22833346?s=280&v=4",
			"mmu.compound_info" => "https://upload.wikimedia.org/wikipedia/en/8/80/KEGG_database_logo.gif",
			"mmu.gene_info" => "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/US-NLM-NCBI-Logo.svg/1658px-US-NLM-NCBI-Logo.svg.png"
		},
		file => {
			"mmu_mirtarbase.tsv" => "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/cache/download/9.0/mmu_MTI.xlsx",
			"mmu_uniprot.tsv" => "https://rest.uniprot.org/uniprotkb/stream?compressed=true&download=true&format=fasta&query=%28%28taxonomy_id%3A10090%29%29",
			"mmu_ont.gmt" => "https://rest.uniprot.org/uniprotkb/stream?compressed=true&download=true&fields=accession%2Cid%2Cgene_names%2Cprotein_name%2Cxref_geneid%2Corganism_name%2Cgo%2Cgo_id%2Cgo_f%2Cgo_c%2Cgo_p&format=tsv&query=%28*%29+AND+%28model_organism%3A10090%29",
			"mmu_tf.gmt" => "https://data.broadinstitute.org/gsea-msigdb/msigdb/release/2023.2.Mm/m3.gtrd.v2023.2.Mm.entrez.gmt",
			"mmu.compound_info" => "https://rest.kegg.jp/list/compound",
			"mmu.gene_info" => "https://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Mus_musculus.gene_info.gz"	
		},
		type => {
			"mmu_mirtarbase.tsv" => "urna",
			"mmu_uniprot.tsv" => "prot",
			"mmu_ont.gmt" => "ont",
			"mmu_tf.gmt" => "tf",
			"mmu.compound_info" => "meta",
			"mmu.gene_info" => "gene"
		},
		useProxy => {
			"mmu.compound_info" => {},
			"mmu_ont.gmt" => {},
			"mmu_mirtarbase.tsv" => {},
		},
		useFork => {
			"mmu_mirtarbase.tsv" => {}
		}
	}
};
my $confsMapsDB = {
	homo_sapiens => {
		kegg => [
			"../pathlay_data/hsa/db/kegg/hsa.kegg.genes.universe",
			"../pathlay_data/hsa/db/kegg/hsa.kegg.gene.gmt",
			"../pathlay_data/hsa/db/kegg/hsa.kegg.meta.gmt"
		],
		wikipathways => [
			"../pathlay_data/hsa/db/wikipathways/hsa.wikipathways.genes.universe",
			"../pathlay_data/hsa/db/wikipathways/hsa.wikipathways.gmt"
		]
	},
	mus_musculus => {
		kegg => [
			"../pathlay_data/mmu/db/kegg/mmu.kegg.genes.universe",
			"../pathlay_data/mmu/db/kegg/mmu.kegg.gmt"
		],
		wikipathways => [
			"../pathlay_data/mmu/db/wikipathways/mmu.wikipathways.genes.universe",
			"../pathlay_data/mmu/db/wikipathways/mmu.wikipathways.gmt"
		]
	}
};

my $organismCodes = {
	homo_sapiens => "hsa",
	mus_musculus => "mmu"
};
my $organismNames = {
	homo_sapiens => "Homo sapiens",
	mus_musculus => "Mus musculus"
};
my $mapDBs = {
	homo_sapiens => ["kegg","wikipathways"],
	mus_musculus => ["kegg","wikipathways"]
};
my $xmlExtensions = {
	kegg => "kgml",
	wikipathways => "gpml"
};
my $pathways = {
	homo_sapiens => {},
	mus_musculus => {}
};

my $cgi = CGI->new;
my $organism = $cgi->param('organism');
my $dbSelected = $cgi->param('db');

my $response = {
	interactionFiles => {
		present => [],
		missing => []
	},
	mapDBFiles => {
		present => [],
		missing => []
	}
};
@{$mapDBs -> {$organism}} = ($dbSelected);


foreach my $mapDB (@{$mapDBs -> {$organism}}) {

	#get pathway list from online db
	my $url = 
		$mapDB eq "kegg" ? "https://rest.kegg.jp/list/pathway/$organismCodes->{$organism}" 
		# : "https://webservice.wikipathways.org/listPathways?organism=$organismNames->{$organism}&format=xml";
			: "https://webservice.wikipathways.org/getCurationTagsByName?tagName=Curation%3AAnalysisCollection&format=xml";
			 
	$url =~ s/\s/%20/;
# https://webservice.wikipathways.org/getCurationTagsByName?tagName=Curation%3AAnalysisCollection&format=xml
	my $pathwayList = get($url);
	if (defined $pathwayList) {
    print STDERR "Retrieved data from $url\n"; 
	} else {
		print STDERR "Failed to retrieve data from $url"; #handle response error here
		next;
	}
	if ($mapDB eq "wikipathways") {
		my $xml = XML::Simple->new();
		$pathwayList = $xml->XMLin($pathwayList);
		#print STDERR Dumper $pathwayList;
		# foreach my $pathway (@{$pathwayList->{"ns1:pathways"}}) {
		# 	my $id = $pathway->{"ns2:id"};
		# 	my $name = $pathway->{"ns2:name"};
		# 	my $revision = $pathway->{"ns2:revision"};
		# 	$pathways->{$organism}->{$mapDB}->{$id}->{name} = $name;
		# 	$pathways->{$organism}->{$mapDB}->{$id}->{revision} = $revision;
		# }
		foreach my $tag (@{$pathwayList->{"ns1:tags"}}) {

			my $id = $tag->{"ns2:pathway"}->{"ns2:id"};
			my $name = $tag->{"ns2:pathway"}->{"ns2:name"};
			my $revision = $tag->{"ns2:pathway"}->{"ns2:revision"};
			my $species = $tag->{"ns2:pathway"}->{"ns2:species"};
			next if ($species ne $organismNames->{$organism});
			
			$pathways->{$organism}->{$mapDB}->{$id}->{id} = $id;
			$pathways->{$organism}->{$mapDB}->{$id}->{name} = $name;
			$pathways->{$organism}->{$mapDB}->{$id}->{revision} = $revision;
			$pathways->{$organism}->{$mapDB}->{$id}->{organism} = $organism;
		}
	}
	if ($mapDB eq "kegg") {
		my @lines = split(/\n/,$pathwayList);
		foreach (@lines) {
			my ($id,$nameTmp) = split(/\t/,$_);
			my @tmp = split(/ - /,$nameTmp);
			pop @tmp;
			$pathways->{$organism}->{$mapDB}->{$id}->{name} = join(" - ",@tmp);
		}
	}
	foreach my $mapDBFile (@{$confsMapsDB -> {$organism} -> {$mapDB}}) {
		my $jsObj = {
			id => $mapDBFile, 
			imgSrc => $sources->{$organism}->{img}->{basename($mapDBFile)},
			fileSrc => $sources->{$organism}->{file}->{basename($mapDBFile)},
			required => "true",
			infoType => $sources->{$organism}->{type}->{basename($mapDBFile)},
			useProxy => $sources->{$organism}->{useProxy}->{basename($mapDBFile)} ? "true" : "false"
		};
		if (-e $mapDBFile) {
			push(@{$response -> {mapDBFiles} -> {present}},$jsObj);
		} else {
			push(@{$response -> {mapDBFiles} -> {missing}},$jsObj);
		}
	}

	my $dirToCheck = "../pathlay_data/$organismCodes->{$organism}/maps/$mapDB/";
	if (!-d $dirToCheck) {
		mkdir($dirToCheck);
	}

	my $foundFiles = {};
	if (-d $dirToCheck) {
		opendir(DIR, $dirToCheck) or die "Cannot open directory $dirToCheck: $!\n";
		my @nodeFiles = grep { /\.nodes$/ && -f File::Spec->catfile($dirToCheck, $_) } readdir(DIR);
		closedir(DIR);

		foreach my $nodeFile (sort @nodeFiles) {
			my $id = $nodeFile;
			$id =~ s/\.nodes$//;
			$foundFiles->{$id}={};
		}
	}

	$dirToCheck = "../pathlay_data/pathways/$mapDB";

	my $foundImgs = {};
	if (-d $dirToCheck) {
		opendir(DIR, $dirToCheck) or die "Cannot open directory $dirToCheck: $!\n";
		my @pngFiles = grep { /\.png$/ && -f File::Spec->catfile($dirToCheck, $_) } readdir(DIR);
		closedir(DIR);
		foreach my $pngFile (sort @pngFiles) {
			my $id = $pngFile;
			$id =~ s/\.png$//;
			$foundImgs->{$id}={};
		}
	}

	foreach my $pathway (sort keys %{$pathways->{$organism}->{$mapDB}}) {
		my $fileUrl = $mapDB eq "kegg" ? "https://rest.kegg.jp/get/$pathway/kgml"
			#: "https://classic.wikipathways.org//wpi/wpi.php?action=downloadFile&type=gpml&pwTitle=Pathway:$pathway";
			: "https://www.wikipathways.org/wikipathways-assets/pathways/$pathway/$pathway.gpml";
		my $imgCode = $pathway; 
		if ($mapDB eq "kegg") {
			$imgCode =~ s/^$organismCodes->{$organism}//;
			#print STDERR $imgCode."\n";
		}
		my $imgUrl = $mapDB eq "kegg" ? "https://rest.kegg.jp/get/map$imgCode/image" : "https://www.wikipathways.org/wikipathways-assets/pathways/$pathway/$pathway.svg";
		#my $imgUrl = $mapDB eq "kegg" ? "https://rest.kegg.jp/get/map$imgCode/image" : "https://www.wikipathways.org/wikipathways-assets/pathways/$pathway/$pathway.png";
		
		my $jsObj = {
			id => $pathway,
			name => $pathways->{$organism}->{$mapDB}->{$pathway}->{name},
			fileUrl => $fileUrl,
			imgUrl => $imgUrl,
			db => $mapDB,
			required => $mapDB eq "wikipathways" ? "true" : "false",
			fileAvailable => $foundFiles->{$pathway} ? "true" :"false",
			imgAvailable => $foundImgs->{$imgCode} ? "true" :"false"
		};
		push(@{$response -> {pathwayFiles}},$jsObj);
	}

}

# Load DB

my $db = {
  homo_sapiens => new HomoSapiensDB(),
	mus_musculus => new MusMusculusDB()
};

foreach my $dataType (('gene','meta')) {
	if (!-e "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$dbSelected/$db->{$organism}->{universeFiles}->{$dataType}->{$dbSelected}") {
		my $gmtFile = new GMTFile(
			mapsDB => $dbSelected,
			fileName => $db->{$organism}->{universeFiles}->{$dataType}->{$dbSelected},
			organismCode => $organismCodes->{$organism},
			filePath => "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$dbSelected/"
		);
		$gmtFile->createFromNodes(
			nodesFolder => "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/maps/$dbSelected/",
			dataType => $dataType,
			mapDB => $dbSelected,
			organismCode => $organismCodes->{$organism}
		);
		$gmtFile->printContent(
			outFile => "$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$dbSelected/$db->{$organism}->{universeFiles}->{$dataType}->{$dbSelected}"
		);
		# open(OUT,">","$FindBin::Bin/../pathlay_data/$organismCodes->{$organism}/db/$mapDB/$gmtFile");
		# foreach my $mapId (keys %{$gmtContent->{$dataType}}) {
		# 	print OUT "$mapId\t$gmtContent->{$dataType}->{$mapId}->{name}\t".(join("\t",keys(%{$gmtContent->{$dataType}->{$mapId}->{name}->{content}})))."\n";
		# }
		# close(OUT);
	}
}


$response = to_json($response);

print $cgi->header('application/json');
print $response;