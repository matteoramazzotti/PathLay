use strict;
use warnings;

package KGML;
sub new {
    my $class = shift;
    my $self = {
        @_
    };
    bless($self,$class);
    return($self);
}
sub Loader {
    my $self = shift;
    my %args = (
        _file => "kegg_map_id",
        _ext => "kgml",
        @_
    );

    $self -> {_file} = $args{_file};
    open(IN,$self -> {_file}) or die "Error while opening ".$self -> {_file}."\n";
    chomp(my @lines = <IN>);
    close(IN);
    $self -> {_data} = join(";",@lines);
}
sub GetPathway {
    my $self = shift;
    my $pathway_tag;
    if ($self -> {_data} =~ /<(pathway.+?)>/) {
        $pathway_tag = $1;
        #print STDERR $pathway_tag."\n";
    }

    while ($pathway_tag =~ /([^ +]+?)=\"(.+?)\"/g) {
        my $tag = $1;
        my $info = $2;
        $tag =~ s/^ +//;
        #print STDERR $tag."\t".$info."\n";
        $self -> {_pathway_info} -> {$tag} = $info;
    }
}
sub GetEntries {
    my $self = shift;
    my $entry_tag;
    my %counter;
    my $i = 0;
    while ($self -> {_data} =~ /<entry(.+?)<\/entry>/g) {
        $entry_tag = $1;
        #print STDERR $entry_tag."\n";
        while ($entry_tag =~ /([^ +]+?)=\"(.+?)\"/g) {
            my $tag = $1;
            my $info = $2;
            $tag =~ s/^ +//;
            #print STDERR $tag."\t".$info."\n";
            if (!$self -> {_entry_info} -> {$i} -> {$tag}) {
                $self -> {_entry_info} -> {$i} -> {$tag} = $info;
                $counter{$tag} = 2;
            } else {
                $self -> {_entry_info} -> {$i} -> {$tag."_".$counter{$tag}} = $info;
                $counter{$tag}++;
            }
        }
        %counter = ();
        if ($self -> {_entry_info} -> {$i} -> {coords}) {
            my ($x1,$y1,$x2,$y2) = split(",",$self -> {_entry_info} -> {$i} -> {coords});
            $self -> {_entry_info} -> {$i} -> {x} = ($x1+$x2)/2;
            $self -> {_entry_info} -> {$i} -> {y} = ($y1+$y2)/2;
        }
        $i++;
    }
}
sub Printer {
    my $self = shift;
    my %args = (
        @_
    );
    print STDERR "_file -> ".$self -> {_file}."\n";
    #print STDERR "_data -> ".$self -> {_data}."\n";
    print STDERR "_pathway_info -> \n";
    foreach (sort keys %{$self -> {_pathway_info}}) {
        print STDERR "\t$_ -> ".$self -> {_pathway_info} -> {$_}."\n";
    }
    <STDIN>;
    print STDERR "_entry_info -> \n";
    foreach my $num (sort keys %{$self -> {_entry_info}}) {
        print STDERR " entry$num -> \n";
        foreach (sort keys %{$self -> {_entry_info}  -> {$num}}) {
            print STDERR "\t$_ -> ".$self -> {_entry_info} -> {$num} -> {$_}."\n";
        }
    }
}
sub NodesPrinter {
    my $self = shift;
    my %args = (
        @_
    );

    my $outdir = $args{_outDir};
    my $ncbiDB = $args{_ncbiDB};
    my $keggCompoundsDB = $args{_keggCompoundsDB};

    if ($self -> {_pathway_info} -> {name} =~ /^path:/) {
        $self -> {_pathway_info} -> {name} =~ s/^path://;
    }
    if (ref($self) eq "KGML") {
        $self -> {_pathway_info} -> {db} = "KEGG";
    }
    if (ref($self) eq "GPML") {
        $self -> {_pathway_info} -> {db} = "WikiPathways";
    }
    open(OUT,">",$outdir.$self -> {_pathway_info} -> {name}.".nodes");
    print OUT "TEXT	TYPE	DB	ID	X	Y\n";
    print OUT $self -> {_pathway_info} -> {title}."\t".
        $self -> {_pathway_info} -> {org}."\t".
        $self -> {_pathway_info} -> {db}."\t".
        $self -> {_pathway_info} -> {name}."\n";
    foreach my $num (sort keys %{$self -> {_entry_info}}) {
        next if ($self -> {_entry_info} -> {$num} -> {type} ne "gene" &&
            $self -> {_entry_info} -> {$num} -> {type} ne "compound"
        );

        if ($self -> {_entry_info} -> {$num} -> {type} eq "gene") {
            $self -> {_entry_info} -> {$num} -> {type} = "GeneProduct";
            $self -> {_entry_info} -> {$num} -> {db} = "Entrez Gene";
            my $org = $self -> {_pathway_info} -> {org};
            $self -> {_entry_info} -> {$num} -> {name} =~ s/$org://g;
        }
        if ($self -> {_entry_info} -> {$num} -> {type} eq "compound") {
            $self -> {_entry_info} -> {$num} -> {type} = "Metabolite";
            $self -> {_entry_info} -> {$num} -> {db} = "KEGG Compound";
            $self -> {_entry_info} -> {$num} -> {name} =~ s/cpd://g;
        }
        my @ids = split(" ",$self -> {_entry_info} -> {$num} -> {name});
        foreach my $id (@ids) {
            if ($self -> {_entry_info} -> {$num} -> {type} eq "Metabolite" &&
                $self -> {_entry_info} -> {$num} -> {db} eq "KEGG Compound"
            ) {
                next if (
                    $id =~ /^dr:/ ||  #drug
                    $id =~ /^gl:/ #glycan
                );
                print OUT ${$keggCompoundsDB -> {_kegg_compound_to_name} -> {"cpd:".$id}}[0]."\t";
            }
            if ($self -> {_entry_info} -> {$num} -> {type} eq "GeneProduct" &&
                $self -> {_entry_info} -> {$num} -> {db} eq "Entrez Gene"
            ) {
                print OUT $ncbiDB -> {_entrez_to_symbol} -> {$id}."\t";
            }

            print OUT $self -> {_entry_info} -> {$num} -> {type}."\t".
                $self -> {_entry_info} -> {$num} -> {db}."\t".
                $id."\t".
                $self -> {_entry_info} -> {$num} -> {x}.",".
                $self -> {_entry_info} -> {$num} -> {y}."\n";
        }
    }
    close(OUT);
}

package ncbiDB;
sub new {
    my $class = shift;
    my $self = {
        @_
    };
    bless($self,$class);
    return($self);
}
sub Loader {
    my $self = shift;
    my %args = (
        @_
    );
    open(IN,$args{_file}) or die "Error while opening ".$args{_file}."\n";
    while (<IN>) {
        chomp;
        next if ($_ =~ /^#/);
        my @tags = split("\t");
        my $entrez = $tags[1];
        my $symbol = $tags[2];
        my $alias  = $tags[5];
        $self -> {_entrez_to_symbol} -> {$entrez} = $symbol;
        $self -> {_symbol_to_entrez} -> {$symbol} = $entrez;
    }
    close(IN);
}

package keggCompoundsDB;
sub new {
    my $class = shift;
    my $self = {
        @_
    };
    bless($self,$class);
    return($self);
}
sub Loader {
    my $self = shift;
    my %args = (
        @_
    );
    open(IN,$args{_info}) or die "Error while opening ".$args{_info}."\n";
    while (<IN>) {
        chomp;
        my ($id,$nameString) = split("\t");
        my @names = split("; ",$nameString);
        foreach my $name (@names) {
            $self -> {_name_to_kegg_compound} -> {$name} = $id;
            push(@{$self -> {_kegg_compound_to_name} -> {$id}},$name);
        }
    }
    close(IN);
    open(IN,$args{_xref}) or die "Error while opening ".$args{_xref}."\n";
    while (<IN>) {
        chomp;
        my ($id,$chebi) = split("\t");

        $self -> {_kegg_compound_to_chebi} -> {$id} -> {$chebi} = 1;
        $self -> {_chebi_to_kegg_compound} -> {$chebi} -> {$id} = 1;
        foreach my $name (@{$self -> {_kegg_compound_to_name} -> {$id}}) {
            $self -> {_chebi_to_name} -> {$chebi} -> {$name} = 1;
            $self -> {_name_to_chebi} -> {$name} -> {$chebi} = 1;
        }
    }
    close(IN);
}

sub PrintOnFile {
    my $self = shift;
    my %args = (
        @_
    );

    my $out = $args{_out};


    open(OUT,">",$out);
    foreach my $keggId (sort keys %{$self -> {_kegg_compound_to_chebi}}) {
        my $prettyKeggId = $keggId;
        $prettyKeggId =~ s/^cpd://;
        print OUT $prettyKeggId."\t";
        foreach my $chebiId (sort keys %{$self -> {_kegg_compound_to_chebi} -> {$keggId}}) {
            print OUT $chebiId."; ";
        }
        print OUT "\t";
        foreach my $compoundName (sort @{$self -> {_kegg_compound_to_name} -> {$keggId}}) {
            print OUT $compoundName."; ";
        }
        print OUT "\n";
    }
    close(OUT);
}

1;
