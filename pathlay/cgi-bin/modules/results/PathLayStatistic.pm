use strict;
use warnings;

sub FET {

    my %args = (
        DEGs => {},
        NoDEGS => {},
        Parameters => {},
        #UniverseFile => "../pathlay_data/hsa/db/kegg/hsa.kegg.genes.universe",
        #MapAssociationFile => "../pathlay_data/hsa/db/kegg/hsa.kegg.gmt",
        @_
    );

    my $parameters = $args{Parameters};
    my $degs = $args{DEGs};
    my $deps = $args{Proteins};
    my $nodegs = $args{NoDEGs};

    use Statistics::R;
    my $R = Statistics::R->new();
    $R->startR;
    my $debug = 1;
    print STDERR "--- statistic sub ---\n" if ($debug);
    my %ids_for_FET;
    my %uni;
    my %deg;
    foreach my $id (sort keys %{$degs -> {_data}}) {
        $ids_for_FET{$id} = 1;
    }
    foreach my $id (sort keys %{$nodegs -> {_data}}) {
        $ids_for_FET{$id} = 1;
    }
    foreach my $id (sort keys %{$deps -> {_data}}) {
        $ids_for_FET{$id} = 1;
    }
    print STDERR "IDs Loaded:".scalar(keys %ids_for_FET)."\n" if ($debug);

    open(IN,$parameters -> {_universe_file});
    while (<IN>) {
        chomp;
        next if ($_ =~ /a-z/i);
        $uni{$_} = 1 if (!$ids_for_FET{$_});
        print STDERR "No: ".$_."\n" if (!$ids_for_FET{$_} && $debug);
        $deg{$_} = 1 if ($ids_for_FET{$_});
        print STDERR "Yes: ".$_."\n" if ($ids_for_FET{$_} && $debug);
    }
    close IN;

    my %pat;
    my @map_names;
    my @map_ids;
    my @p;
    open(IN,$parameters -> {_map_association_file});
    while (<IN>) {

        chomp;
        my ($map_id,$map_name,@ids) = split(/\t/,$_);
        push(@map_ids,$map_id);
        push(@map_names,$map_name);
        my %in_map_ids = map {$_ => 1} @ids;
        my $a=0; my $b=0; my $c=0; my $d=0;
        foreach (keys %in_map_ids) {
            $a++ if ($deg{$_});
            $c++ if ($uni{$_});
        }
        $b = (scalar (keys %deg)) - $a;
        $d = (scalar (keys %uni)) - $c;
        $R->set( 'a', $a );
        $R->set( 'b', $b );
        $R->set( 'c', $c );
        $R->set( 'd', $d );
        $R->run(q/p<-1-phyper(a-1,a+c,b+d,a+b)/);
        my $p = $R->get('p');
        push(@p,$p);
    }
    close(IN);
    $R->set('pvals', \@p);
    $R->run(q/padj<-p.adjust(pvals,method="BH")/);
    my $adj = $R->get('padj');
    my @adj = @$adj;

    my %needed_maps;
    foreach my $i (0..$#map_ids) {
        $needed_maps{$map_ids[$i]} = $adj[$i] if ($adj[$i] < 0.05);
        print STDERR $map_ids[$i]." ".$needed_maps{$map_ids[$i]}."\n" if ($debug);
    }
    $R->stopR();
    $debug = 0;
    return(%needed_maps);
}

1;