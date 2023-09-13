use strict;
use warnings;

my $idir = "/var/www/html/pathlay_2/cgi-bin/src/";
my $file = "uniprot-proteome UP000005640.tab";
my $odir = "/var/www/html/pathlay_2/pathlay_data/KEGG/hsa/";
my $out = "ont_hsa.gmt";

my %ont2genes;
my %ont2names;


open(IN,$idir.$file);
while(<IN>) {
#Entry	Entry name	Status	Protein names	Gene names	Organism	Gene ontology IDs	Cross-reference (GeneID)	Gene ontology (cellular component)
    next if (/^Entry/);
    chomp;
    my ($entry,$entry_name,$status,$protein_names,$gene_names,$organism,$go_ids,$gene_id,$go_component) = split(/\t/);
    next if ($gene_id eq "" | $go_component eq "" | $go_ids eq "");

    foreach my $go (sort(split(/;/,$go_component))) {

        if ($go =~ /^(.+?) \[(.+?)\]/) {

            my $go_name = $1;
            my $go_id = $2;

            $go_name  =~ s/^ //;

            $ont2names{$go_id} = $go_name;

            ${$ont2genes{$go_id}}{$gene_id} = 1;
        }
    }
}
close(IN);
foreach my $go (sort keys %ont2names) {
    print STDOUT $go."\t".$ont2names{$go}."\t"."http://amigo.geneontology.org/amigo/term/$go"."\t";
    foreach my $gene_id (sort keys %{$ont2genes{$go}}) {
        print STDOUT $gene_id;
    }
    print STDOUT "\n";
}
