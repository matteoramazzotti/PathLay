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


# Create CGI object
my $cgi = CGI->new;

my $organismCodes = {
	homo_sapiens => "hsa",
	mus_musculus => "mmu"
};
my $organismNames = {
	homo_sapiens => "Homo sapiens",
	mus_musculus => "Mus musculus"
};

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
			"hsa_uniprot.tsv" => "https://rest.uniprot.org/uniprotkb/stream?compressed=true&download=true&fields=accession%2Creviewed%2Cid%2Cgene_names%2Cprotein_name%2Cxref_geneid%2Corganism_name&format=tsv&query=%28%28taxonomy_id%3A9606%29%29",
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
			"hsa_uniprot.tsv" => {},
			"hsa_mirtarbase.tsv" => {},
		},
		useFork => {
			"hsa_mirtarbase.tsv" => {},
			"hsa_uniprot.tsv" => {}
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
			"mmu_uniprot.tsv" => "https://rest.uniprot.org/uniprotkb/stream?compressed=true&download=true&fields=accession%2Creviewed%2Cid%2Cgene_names%2Cprotein_name%2Cxref_geneid%2Corganism_name&format=tsv&query=%28%28taxonomy_id%3A10090%29%29",
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
			"mmu_uniprot.tsv" => {},
			"mmu_mirtarbase.tsv" => {},
		},
		useFork => {
			"mmu_mirtarbase.tsv" => {}
		}
	}
};

my $mapDBs = {
	homo_sapiens => ["kegg","wikipathways"],
	mus_musculus => ["kegg","wikipathways"]
};
my $confsInteractions = {
	homo_sapiens => [
		"../../pathlay_data/hsa/db/hsa_mirtarbase.tsv",
		"../../pathlay_data/hsa/db/hsa_ont.gmt",
		"../../pathlay_data/hsa/db/hsa_tf.gmt",
		"../../pathlay_data/hsa/db/hsa_uniprot.tsv",
		"../../pathlay_data/hsa/db/hsa.compound_info",
		"../../pathlay_data/hsa/db/hsa.gene_info"
	],
	mus_musculus => [
		"../../pathlay_data/mmu/db/mmu_mirtarbase.tsv",
		"../../pathlay_data/mmu/db/mmu_ont.gmt",
		"../../pathlay_data/mmu/db/mmu_tf.gmt",
		"../../pathlay_data/mmu/db/mmu_uniprot.tsv",
		"../../pathlay_data/mmu/db/mmu.compound_info",
		"../../pathlay_data/mmu/db/mmu.gene_info"
	]
};
my $confsMapsDB = {
	homo_sapiens => {
		kegg => [
			"../../pathlay_data/hsa/db/kegg/hsa.kegg.genes.universe",
			"../../pathlay_data/hsa/db/kegg/hsa.kegg.gmt"
		],
		wikipathways => [
			"../../pathlay_data/hsa/db/wikipathways/hsa.wikipathways.genes.universe",
			"../../pathlay_data/hsa/db/wikipathways/hsa.wikipathways.gmt"
		]
	},
	mus_musculus => {
		kegg => [
			"../../pathlay_data/mmu/db/kegg/mmu.kegg.genes.universe",
			"../../pathlay_data/mmu/db/kegg/mmu.kegg.gmt"
		],
		wikipathways => [
			"../../pathlay_data/mmu/db/wikipathways/mmu.wikipathways.genes.universe",
			"../../pathlay_data/mmu/db/wikipathways/mmu.wikipathways.gmt"
		]
	}
};

my $xmlExtensions = {
	kegg => "kgml",
	wikipathways => "gpml"
};

my $pathways = {
	homo_sapiens => {},
	mus_musculus => {}
};

my $organism = $cgi->param('organism');

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

# Check for pathlay_data folder and assign correct permissions
my @mandatoryFolders = (
	"$FindBin::Bin/../../pathlay_users/",
	"$FindBin::Bin/../../pathlay_data/",
	"$FindBin::Bin/../../pathlay_data/pathways/",
	"$FindBin::Bin/../../pathlay_data/$organismCodes->{$organism}/",
	"$FindBin::Bin/../../pathlay_data/$organismCodes->{$organism}/db/",
	"$FindBin::Bin/../../pathlay_data/$organismCodes->{$organism}/maps/"
);

foreach my $folder (@mandatoryFolders) {
	if (!-e $folder) {
		mkdir($folder);
	}
	my $chgrp_command = "chgrp -R www-data $folder";
	system($chgrp_command) == 0 or exit "Failed to execute $chgrp_command: $!";
	my $chmod_command = "chmod -R 774 $folder";
	system($chmod_command) == 0 or die "Failed to execute $chmod_command: $!";
	my $chmod_gs_command = "chmod g+s $folder";
	system($chmod_gs_command) == 0 or die "Failed to execute $chmod_gs_command: $!";
}


foreach my $interactionFile (@{$confsInteractions -> {$organism}}) {
	my $jsObj = {
		id => $interactionFile,
		fileName => basename($interactionFile),
		imgSrc => $sources->{$organism}->{img}->{basename($interactionFile)},
		fileSrc => $sources->{$organism}->{file}->{basename($interactionFile)},
		required => "true",
		infoType => $sources->{$organism}->{type}->{basename($interactionFile)},
		useProxy => $sources->{$organism}->{useProxy}->{basename($interactionFile)} ? "true" : "false",
		useFork =>   $sources->{$organism}->{useFork}->{basename($interactionFile)} ? "true" : "false"

	};

	if (-e $interactionFile) {
		push(@{$response -> {interactionFiles} -> {present}},$jsObj);
	} else {
		push(@{$response -> {interactionFiles} -> {missing}},$jsObj);
	}
}


$response = to_json($response);
print $cgi->header('application/json');
print $response;
