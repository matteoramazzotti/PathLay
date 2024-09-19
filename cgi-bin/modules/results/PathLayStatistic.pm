use strict;
use warnings;

# sub FET {

#     my %args = (
#         DEGs => {},
#         NoDEGS => {},
#         Parameters => {},
#         #UniverseFile => "../pathlay_data/hsa/db/kegg/hsa.kegg.genes.universe",
#         #MapAssociationFile => "../pathlay_data/hsa/db/kegg/hsa.kegg.gmt",
#         @_
#     );

#     my $parameters = $args{Parameters};
#     my $degs = $args{DEGs};
#     my $deps = $args{Proteins};
#     my $nodegs = $args{NoDEGs};

#     use Statistics::R;
#     my $R = Statistics::R->new();
#     $R->startR;
#     my $debug = 1;
#     print STDERR "--- statistic sub ---\n" if ($debug);
#     my %ids_for_FET;
#     my %uni;
#     my %deg;
#     foreach my $id (sort keys %{$degs -> {_data}}) {
#         $ids_for_FET{$id} = 1;
#     }
#     foreach my $id (sort keys %{$nodegs -> {_data}}) {
#         $ids_for_FET{$id} = 1;
#     }
#     foreach my $id (sort keys %{$deps -> {_data}}) {
#         $ids_for_FET{$id} = 1;
#     }
#     print STDERR "IDs Loaded:".scalar(keys %ids_for_FET)."\n" if ($debug);

#     open(IN,$parameters -> {_universe_file});
#     while (<IN>) {
#         chomp;
#         next if ($_ =~ /a-z/i);
#         $uni{$_} = 1 if (!$ids_for_FET{$_});
#         print STDERR "No: ".$_."\n" if (!$ids_for_FET{$_} && $debug);
#         $deg{$_} = 1 if ($ids_for_FET{$_});
#         print STDERR "Yes: ".$_."\n" if ($ids_for_FET{$_} && $debug);
#     }
#     close IN;

#     my %pat;
#     my @map_names;
#     my @map_ids;
#     my @p;
#     open(IN,$parameters -> {_map_association_file});
#     while (<IN>) {

#         chomp;
#         my ($map_id,$map_name,@ids) = split(/\t/,$_);
#         push(@map_ids,$map_id);
#         push(@map_names,$map_name);
#         my %in_map_ids = map {$_ => 1} @ids;
#         my $a=0; my $b=0; my $c=0; my $d=0;
#         foreach (keys %in_map_ids) {
#             $a++ if ($deg{$_});
#             $c++ if ($uni{$_});
#         }
#         $b = (scalar (keys %deg)) - $a;
#         $d = (scalar (keys %uni)) - $c;
#         $R->set( 'a', $a );
#         $R->set( 'b', $b );
#         $R->set( 'c', $c );
#         $R->set( 'd', $d );
#         $R->run(q/p<-1-phyper(a-1,a+c,b+d,a+b)/);
#         my $p = $R->get('p');
#         push(@p,$p);
#     }
#     close(IN);
#     $R->set('pvals', \@p);
#     $R->run(q/padj<-p.adjust(pvals,method="BH")/);
#     my $adj = $R->get('padj');
#     my @adj = @$adj;

#     my %needed_maps;
#     foreach my $i (0..$#map_ids) {
#         $needed_maps{$map_ids[$i]} = $adj[$i] if ($adj[$i] < 0.05);
#         print STDERR $map_ids[$i]." ".$needed_maps{$map_ids[$i]}."\n" if ($debug);
#     }
#     $R->stopR();
#     $debug = 0;
#     return(%needed_maps);
# }


# sub FETrevised {
#     my %args = (
#         DePack => {},
#         Parameters => {},
#         @_
#     );
#     my $dePacks = $args{DePacks};
#     my $parameters = $args{Parameters};
#     my $dataType = $args{DataType};

#     my $dePack = {};

#     if ($dataType ne "pool") {
#         $dePack = $dePacks -> {$dataType};
#     } else {
#         foreach my $type (("gene","prot")) {
#             while (my ($id,$value) = each %{$dePacks -> {$type} -> {_data}}) {
#                 $dePack -> {_data} -> {$id} = 1;
#             }
#         }
#         while (my ($id,$value) = each %{$dePacks -> {nodeg} -> {_data}}) {
#             my $keep = 0;
#             if ($dePacks -> {nodeg} -> {_data} -> {$id} -> {urnas} && $parameters -> {_urnaFETEnabled}) {
#                 $keep = 1;
#             }
#             if ($dePacks -> {nodeg} -> {_data} -> {$id} -> {meth} && $parameters -> {_methFETEnabled}) {
#                 $keep = 1;
#             }
            
#             if ($dePacks -> {nodeg} -> {_data} -> {$id} -> {chroma} && $parameters -> {_chromaFETEnabled}) {
#                 $keep = 1;
#             }
#             if ($keep) {
#                 $dePack -> {_data} -> {$id} = 1;
#             }
#         }
#     }
#     use Statistics::R;
#     my $R = Statistics::R->new();
#     $R->startR;

#     my $debug = 0;
#     print STDERR "--- statistic sub ---\n" if ($debug);
#     my %ids_for_FET;
#     my %uni;
#     my %de;
#     foreach my $id (sort keys %{$dePack -> {_data}}) {
#         $ids_for_FET{$id} = 1;
#     }
    
#     print STDERR "IDs Loaded:".scalar(keys %ids_for_FET)."\n" if ($debug);

#     open(IN,$parameters -> {_universe_file});
#     while (<IN>) {
#         chomp;
#         next if ($_ =~ /a-z/i);
#         $uni{$_} = 1 if (!$ids_for_FET{$_});
#         print STDERR "No: ".$_."\n" if (!$ids_for_FET{$_} && $debug);
#         $de{$_} = 1 if ($ids_for_FET{$_});
#         print STDERR "Yes: ".$_."\n" if ($ids_for_FET{$_} && $debug);
#     }
#     close IN;
#     my %pat;
#     my @map_names;
#     my @map_ids;
#     my @p;
#     open(IN,$parameters -> {_map_association_file});
#     while (<IN>) {

#         chomp;
#         my ($map_id,$map_name,@ids) = split(/\t/,$_);
#         push(@map_ids,$map_id);
#         push(@map_names,$map_name);
#         my %in_map_ids = map {$_ => 1} @ids;
#         my $a=0; my $b=0; my $c=0; my $d=0;
#         foreach (keys %in_map_ids) {
#             $a++ if ($de{$_});
#             $c++ if ($uni{$_});
#         }
#         $b = (scalar (keys %de)) - $a;
#         $d = (scalar (keys %uni)) - $c;
#         $R->set( 'a', $a );
#         $R->set( 'b', $b );
#         $R->set( 'c', $c );
#         $R->set( 'd', $d );
#         $R->run(q/p<-1-phyper(a-1,a+c,b+d,a+b)/);
#         my $p = $R->get('p');
#         push(@p,$p);
#     }
#     close(IN);
#     $R->set('pvals', \@p);
#     $R->run(q/padj<-p.adjust(pvals,method="BH")/);
#     my $adj = $R->get('padj');
#     my @adj = @$adj;

#     my %needed_maps;
#     foreach my $i (0..$#map_ids) {
#         $needed_maps{$map_ids[$i]} = $adj[$i] if ($adj[$i] < 0.05);
#         print STDERR $map_ids[$i]." ".$needed_maps{$map_ids[$i]}."\n" if ($debug && $needed_maps{$map_ids[$i]});
#     }
#     $R->stopR();
#     $debug = 0;

#     return(%needed_maps);
# }

sub makeListMain {
  my %args = (
    dePacks => {},
    dataType => {},
    @_
  );
  my $dePacks = $args{dePacks};
  my $dataType = $args{dataType};
  my $dePack = $dePacks->{$dataType};
  return($dePack);
}
sub makeListmiRNA {
  my %args = (
    dePacks => {},
    Parameters => {},
    @_
  );
  my $dePacks = $args{dePacks};
  my $parameters = $args{Parameters};
  my $dePack = {};
  my @mains = ();
  push(@mains,"gene") if ($parameters -> {_enablegene});
  push(@mains,"prot") if ($parameters -> {_enableprot});
  push(@mains,"nodeg") if ($parameters -> {_nodeg_select_urna});

  foreach my $main (@mains) {
    while (my ($id,$value) = each %{$dePacks -> {$main} -> {_data}}) {
      my $keep = 0;
      my $pval = 0;
      if ($dePacks -> {$main} -> {_data} -> {$id} -> {urnas}) {
        $keep = 1;
        my $cP = 900;
        foreach my $urnaId (keys %{$dePacks -> {$main} -> {_data} -> {$id} -> {urnas}}) {
          my $cC = $dePacks -> {$main} -> {_data} -> {$id} -> {urnas} -> {$urnaId} -> {pvalue};
          $cP = $cC < $cP ? $cC : $cP;
        }
        if ($cP != 900) {
          $pval = $cP;
        }
      }
      if ($keep) {
        $dePack -> {_data} -> {$id} = $value;
        if ($pval) {
          $dePack -> {_data} -> {$id} -> {pvalue} = $pval;
        }
      }
    }
  }
  return($dePack);
}
sub makeListMethChroma {
  my %args = (
    dePacks => {},
    dataType => "",
    Parameters => {},
    @_
  );
  my $dePacks = $args{dePacks};
  my $dataType = $args{dataType};
  my $parameters = $args{Parameters};

  my @mains = ();
  push(@mains,"gene") if ($parameters -> {_enablegene});
  push(@mains,"prot") if ($parameters -> {_enableprot});
  push(@mains,"nodeg") if ($parameters -> {"_nodeg_select_${dataType}"});

  my $dePack = {};
  foreach my $main (@mains) {
    while (my ($id,$value) = each %{$dePacks -> {$main} -> {_data}}) {

      if ($dePacks -> {$main} -> {_data} -> {$id} -> {$dataType}) {
        $dePack -> {_data} -> {$id} -> {pvalue} = $dePacks -> {$dataType} -> {_data} -> {$id} -> {pvalue};
      }
    }
  }
  return($dePack);
}

sub FETp {
  use Bio::FdrFet;
  my %args = (
    DePacks => {},
    Parameters => {},
    DataType => "",
    gmtFile => "",
    @_
  );
  my $dePacks = $args{DePacks};
  my $parameters = $args{Parameters};
  my $dataType = $args{DataType};
  my $gmtFile = $args{gmtFile};

  my $fdrcutoff = 35; # False Discovery Rate cutoff in units of percent
  my $FETobj = new Bio::FdrFet($fdrcutoff);
  $FETobj -> verbose(0); 
  $FETobj->universe("union");

  # Load pathway genes association from gmt
  open(IN,$gmtFile);
  while (<IN>) {
    chomp;
    my ($map_id,$map_name,@ids) = split(/\t/,$_);
    map { 
      $FETobj -> add_to_pathway(
        gene => $_,
        dbacc => $map_id,
        desc => $map_name
      ); 
    } @ids;
  }
  close(IN);
  my $dePack = $args{DePack};
  
  foreach my $id (sort keys %{$dePack -> {_data}}) {
    next if (
      !$FETobj -> {GENES}
    );
    $FETobj->add_to_genes(
      gene => $id,
      pval => $dePack -> {_data} -> {$id} -> {pvalue}
    );
  }
  $FETobj->calculate();

  my %needed_maps;
  foreach my $pathway ($FETobj->pathways('sorted')) {
    my $logpval = $FETobj->pathway_result($pathway, 'LOGPVAL');
    # printf STDERR "Pathway $pathway %s has - log(pval) = %6.4f",
    # $FETobj->pathway_desc($pathway),
    # $logpval;
    # print STDERR "\n";
    $needed_maps{$pathway} = $logpval if ($logpval > 1);
  }
  return(%needed_maps);
}

sub IntersectMaps {
    my %args = (
        @_
    );

    my $mapsREF = $args{Maps};
    my %mapsIDs = %$mapsREF;
    my $validScore = (scalar(keys(%mapsIDs)) - 1);
    print STDERR $validScore."\n";
    #print STDERR Dumper \%mapsIDs;

    foreach my $mapID (keys %{$mapsIDs{'ready'}}) {
        if (${$mapsIDs{'ready'}}{$mapID} < $validScore) {
            print STDERR "Deleting ".$mapID."\n";
            delete(${$mapsIDs{'ready'}}{$mapID});
        }
    }
    #print STDERR Dumper \%mapsIDs;
    print STDERR (scalar keys %{$mapsIDs{'ready'}})."\n";
    return(%{$mapsIDs{'ready'}});
}

sub JoinMaps {

    my %args = (
        @_
    );
    my $mapsREF = $args{Maps};
    my %maps = %$mapsREF;
    #print STDERR Dumper $mapsREF;

    my %mapsIDs;

    foreach my $type (keys %maps) {
        while (my ($mapID,$value) = each %{$maps{$type}}) {
            $mapsIDs{$mapID}++;
        }
    }
    #print STDERR Dumper \%mapsIDs;
    return(%mapsIDs);
}

1;