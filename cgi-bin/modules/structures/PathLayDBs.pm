use strict;
#use warnings;
use lib '/var/www/html/pathlay/cgi-bin/';
use strict;
use warnings;
package TFs;
    sub new {
        my $class = shift;
        my $self = {
            _loaded => 0,
            _ids => {},
            _links => {},
            @_
        };
        bless $self,$class;
        return($self);
    }
    sub TFsLoader {
        my $self = shift;
        my %args = (
            Parameters => {},
            ExpGenes => {},
            ExpProteins => {},
            geneCheck => 0,
            protCheck => 0,
            @_
        );
        my $parameters = $args{Parameters};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $geneCheck = $args{geneCheck};
        my $protCheck = $args{protCheck};
        my $geneIdOnly = $args{geneIdOnly};
        my $protIdOnly = $args{protIdOnly};
        my $base = "../pathlay_users/";
        my $tf_db = $parameters -> {_tf_db_file};
        my $tf_db_location = $parameters -> {_tf_db_location};

        my $debug = 0;
        open(IN,$tf_db_location.$tf_db) or print STDERR "Warning: TFDB NOT FOUND at ".$tf_db_location.$tf_db."\n";
        while (<IN>) { #need to load only the strictly necessary
            chomp;
            #print STDERR "$_\n" if ($debug);
            my ($tf_id,$tf_name,$null,$tf_link,$tf_genes1) = split(/\t/);
            my @tf_genes = split(" ",$tf_genes1);
            if ($degs -> {_data} -> {$tf_id} && $geneCheck) {

                if (!$degs -> {_data} -> {$tf_id} -> {dev} && !$geneIdOnly) {
                    next;
                } 
                print STDERR "ID:$tf_id|LINK:$tf_link\n" if ($debug);
                $self -> {_ids} -> {$tf_id} = 1;
                $self -> {_names} -> {$tf_id} = $tf_name;
                $self -> {_links} -> {$tf_id} = $tf_link;
                foreach (sort @tf_genes) {
                    $self -> {_tf_to_genes} -> {$tf_id} -> {genes} -> {$_} = 1;
                    $self -> {_gene_to_tfs} -> {$_} -> {tfs} -> {$tf_id} = 1;
                }
            }
            if ($deps -> {_data} -> {$tf_id} && $protCheck) {
                if (!$deps -> {_data} -> {$tf_id} -> {dev} && !$protIdOnly) {
                    next;
                }
                $self -> {_ids} -> {$tf_id} = 1;
                $self -> {_names} -> {$tf_id} = $tf_name;
                $self -> {_links} -> {$tf_id} = $tf_link;
                foreach (sort @tf_genes) {
                    $self -> {_tf_to_genes} -> {$tf_id} -> {genes} -> {$_} = 1;
                    $self -> {_gene_to_tfs} -> {$_} -> {tfs} -> {$tf_id} = 1;
                }
            }
        }
        close(IN);

        $debug = 0;
    }
package geneDB;
    sub new {
        my $class = shift;
        my $self = {
            _file => "undef",
            _location => "undef",
            _source => "undef",
            @_
        };
        bless $self, $class;
        $self -> {_source} = $self -> {_location}.$self -> {_file};
        return($self);
    }
    sub geneDBLoader {
        my $self = shift;

        open(DB,$self -> {_source}) or die "Cannot open: ".$self -> {_source}."\n";
        while(<DB>) {
            chomp;
            next if ($_ =~ /^#/);
            ##tax_id	GeneID	Symbol	LocusTag	Synonyms	dbXrefs	chromosome	map_location	description	type_of_gene	Symbol_from_nomenclature_authority	Full_name_from_nomenclature_authority	Nomenclature_status	Other_designations	Modification_date	Feature_type
            #10090	11287	Pzp	-	A1m|A2m|MAM	MGI:MGI:87854|Ensembl:ENSMUSG00000030359|AllianceGenome:MGI:87854	6	6 F3|6 63.02 cM	PZP, alpha-2-macroglobulin like	protein-coding	Pzp	PZP, alpha-2-macroglobulin like	O	pregnancy zone protein|alpha 1 macroglobulin|alpha-2-M|alpha-2-macroglobulin	20220926	-
            my @data = split("\t",$_);
            my $entrez = $data[1];
            my $symbol = $data[2];
            my $dbxrefs = $data[5];


            $self -> {entrez2symbol} -> {$entrez} = $symbol;
            $self -> {symbol2entrez} -> {$symbol} = $entrez;

            my @xrefs = (); 
            if ($dbxrefs =~ /\|/) {
                @xrefs = split(/\|/,$dbxrefs);
            } else {
                push(@xrefs,$dbxrefs);
            }
            foreach my $xref (@xrefs) {
                
                if ($xref =~ /Ensembl:/) {
                    
                    my $ensembl = $xref;
                    $ensembl =~ s/Ensembl://;
                    $self -> {entrez2ensembl} -> {$entrez} = $ensembl;
                    $self -> {symbol2ensembl} -> {$symbol} = $ensembl;
                    $self -> {ensembl2entrez} -> {$ensembl} = $entrez;
                    $self -> {ensembl2symbol} -> {$ensembl} = $symbol;
                    #print STDERR $ensembl."\t".$self -> {ensembl2entrez} -> {$ensembl}."\t".$self -> {ensembl2symbol} -> {$ensembl}."\n";

                }
            }
        }
        close(DB);
    }
    sub geneDBPrinter {
        my $self = shift;

        foreach my $section (keys %$self) {
            next if ($section eq "_location" || $section eq "_file" || $section eq "_source");
            print STDERR "Printing: ".$section."\n";
            foreach my $id (keys %{$self -> {$section}}) {
                print STDERR $id."->".$self -> {$section} -> {$id}."\n";
            }
        }
    }

package protDB;
    sub new {
        my $class = shift;
        my $self = {
            _file => "undef",
            _location => "undef",
            _source => "undef",
            @_
        };
        bless $self, $class;
        $self -> {_source} = $self -> {_location}.$self -> {_file};
        return($self);
    }
    sub protDBLoader {
        use Data::Dumper;
        my $self = shift;

        open(DB,$self -> {_source}) or die "Cannot open: ".$self -> {_source}."\n";
        while(<DB>) {
            chomp;
            next if ($_ =~ /^Entry/);
            my @data = split("\t",$_);
            # print STDERR Dumper \@data;
            
            my $entrezL = $data[5];
            my $symbol = $data[3];
            my $entry = $data[0];
            my $fullName = $data[4];
            $fullName =~ s/ \(.+?$//;

            my @entrezs = split(/;/,$entrezL);
            # next if(scalar @entrezs > 1); #???
            foreach my $entrez (@entrezs) {
                my @symbols = split(/ /,$symbol);

                $entrez =~ s/;$//;

                $self -> {entrez2entry} -> {$entrez} = $entry;
                # $self -> {entry2entrez} -> {$entry} = $entrez;
                push(@{$self->{entry2entrez}->{$entry}},$entrez);

                $self -> {entrez2fullName} -> {$entrez} = $fullName;
                $self -> {entry2fullName} -> {$entry} = $fullName;
                foreach (@symbols) {
                    #$self -> {symbol2entrez} -> {$_} = $entrez;
                    push(@{$self->{symbol2entrez}->{$_}},$entrez);
                    $self -> {symbol2fullName} -> {$_} = $fullName;
                    $self -> {symbol2entry} -> {$_} = $entry;
                    $self -> {entrez2symbol} -> {$entrez} -> {$symbol} = 1;
                    $self -> {entry2symbol} -> {$entry} -> {$symbol} = 1;
                }
            }
            
        }
        close(DB);
        #print STDERR Dumper $self -> {entry2entrez};
        #die;
    }
    sub protDBPrinter {
        my $self = shift;

        foreach my $section (keys %$self) {
            next if ($section eq "_location" || $section eq "_file" || $section eq "_source");
            print STDERR "Printing: ".$section."\n";
            foreach my $id (keys %{$self -> {$section}}) {
                print STDERR $id."->".$self -> {$section} -> {$id}."\n";
            }
        }
    }

package uRNADB;
    sub new {

        my $class = shift;
        my $self = {
            _source => "undef",
            _type => "undef",
            _filter => "undef",
            @_
        };
        my $debug = 0; 
        print STDERR $self -> {_source}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub uDBLoader {
        my $self = shift;
        my %args = (
            ExpGenes => {},
            ExpuRNAs => {},
            @_
        );

        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $deus = $args{ExpuRNAs};
        my $idOnly = $args{NoDEFromIdOnly};
        $self -> {_filter} = "all";
        if ($self -> {_type} =~ /mirtarbase/) {
            print STDERR $self -> {_location}."\n";
            open(MIRTAR, $self -> {_location}) or die "miratrbase file not present\n";

            while (<MIRTAR>) {
                chomp;
                my ($mirt,$urna,$gene,$type) = split "\t", $_;
                next if (!$deus -> {_data} -> {$urna});
                next if ($self -> {_filter} eq "strongonly" && $type =~ "Weak");
                next if ($self -> {_filter} eq "weakonly" && $type =~ "Strong");
                #print STDERR "$urna - $mirt\n" if ($debug);
                if ($degs -> {_data} -> {$gene}) {
                    $self -> {_links} -> {urna2deg} -> {$urna} -> {$gene} = 1;
                    #$self -> {_links} -> {mirt2deg} -> {$mirt} -> {$gene} = 1;
                    $self -> {_links} -> {deg2urna} -> {$gene} -> {$urna} = 1;
                    #$self -> {_links} -> {deg2mirt} -> {$gene} -> {$mirt} = 1;
                    $self -> {_links} -> {mirt2deg} -> {$mirt}  = $gene;
                    $self -> {_links} -> {deg2mirt} -> {$gene} -> {$urna} = $mirt;
                    #print STDERR " DEG $gene FOUND\n" if ($debug);
                }
                if ($deps -> {_data} -> {$gene}) {
                    $self -> {_links} -> {urna2prot} -> {$urna} -> {$gene} = 1;
                    #$self -> {_links} -> {mirt2deg} -> {$mirt} -> {$gene} = 1;
                    $self -> {_links} -> {prot2urna} -> {$gene} -> {$urna} = 1;
                    #$self -> {_links} -> {deg2mirt} -> {$gene} -> {$mirt} = 1;
                    $self -> {_links} -> {mirt2prot} -> {$mirt}  = $gene;
                    $self -> {_links} -> {prot2mirt} -> {$gene} -> {$urna} = $mirt;
                    #print STDERR " PROT ".($deps -> {_data} -> {$gene} -> {_prot_id})." ($gene) FOUND\n" if ($debug);
                }
                if (!$degs -> {_data} -> {$gene} && !$deps -> {_data} -> {$gene}) {

                    if ($deus -> {_data} -> {$urna} -> {dev}) { #useless
                        $self -> {_links} -> {urna2nodeg} -> {$urna} -> {$gene} = 1;
                        $self -> {_links} -> {nodeg2urna} -> {$gene} -> {$urna} = 1;
                        $self -> {_links} -> {mirt2nodeg} -> {$mirt}  = $gene;
                        $self -> {_links} -> {nodeg2mirt} -> {$gene} -> {$urna} = $mirt;
                    } elsif ($idOnly) {
                        $self -> {_links} -> {urna2nodeg} -> {$urna} -> {$gene} = 1;
                        $self -> {_links} -> {nodeg2urna} -> {$gene} -> {$urna} = 1;
                        $self -> {_links} -> {mirt2nodeg} -> {$mirt}  = $gene;
                        $self -> {_links} -> {nodeg2mirt} -> {$gene} -> {$urna} = $mirt;
                    }
                    
                    #print STDERR " NODEG $gene - FOUND\n" if ($debug);
                }
            }
            close MIRTAR;
        }
        return($self);
    }
    sub DBLoader {
        my $self = shift;
        my %args = (
            ExpuRNAs => {},
            @_
        );
        my $deus = $args{ExpuRNAs};

        open(MIRTAR, $self -> {_location}) or die "miratrbase file not present\n";
        while(<MIRTAR>) {
            chomp;
            my ($mirt,$urna,$gene,$type) = split "\t", $_;
            next if (!$deus -> {_data} -> {$urna});
            #next if ($type =~ "Weak");
            $self -> {_links} -> {urna2entrez} -> {$urna} -> {$gene} = 1;
            $self -> {_links} -> {entrez2urna} -> {$gene} -> {$urna} = 1;
            $self -> {_links} -> {mirt2entrez} -> {$mirt}  = $gene;
            $self -> {_links} -> {entrez2mirt} -> {$gene} -> {$urna} = $mirt;
        }
        close(MIRTAR);
    }

package metaDB;
    sub new {
        my $class = shift;
        my $self = {
            _file => "undef",
            _location => "undef",
            _source => "undef",
            @_
        };
        bless $self, $class;
        $self -> {_source} = $self -> {_location}.$self -> {_file};
        return($self);
    }
    sub metaDBLoader {
            
        my $self = shift;

        open(DB,$self -> {_source}) or die "Cannot open: ".$self -> {_source}."\n";
        while(<DB>) {
            chomp;
            next if ($_ =~ /^Entry/);
            my @data = split("\t",$_);
            my $keggId = $data[0];
            my $compoundNameF = $data[2];
            my $chebiIDF = $data[1];

            my @compoundNames = split(/; /,$compoundNameF);
            my @chebiIDs = split(/; /,$chebiIDF);

            
            foreach (@compoundNames) {
                $self -> {name2keggcompound} -> {$_} = $keggId;
                $self -> {keggcompound2name} -> {$keggId} -> {$_} = 1;
            }

            foreach (@chebiIDs) {
                $self -> {chebi2keggcompound} -> {$_} = $keggId;
                $self -> {keggcompound2chebi} -> {$keggId} -> {$_} = 1;
            }        
        }
        close(DB);
    }

1;
