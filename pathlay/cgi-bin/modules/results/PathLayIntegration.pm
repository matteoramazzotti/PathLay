use strict;
use warnings;
package ONTInterface;
    sub new {
        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        bless $self, $class;
        return($self);
    }
    sub integrateAll {
        my $self = shift;
        my %args = (
            DEGs => {},
            NODEGs => {},
            Prots => {},
            @_
        );
        my %keep;

        my $degs = $args{DEGs};
        my $nodegs = $args{NODEGs};
        my $deps = $args{Prots};
        my $onts = $args{ONTs};

        foreach my $deg (sort keys %{$degs -> {_data}}) {
            if ($onts -> {_gene_to_onts} -> {$deg}) {
                foreach (sort keys %{$onts -> {_gene_to_onts} -> {$deg} -> {onts}}) {
                    $keep{$_} = 1;
                }
            }
        }

        foreach my $dep (sort keys %{$deps -> {_data}}) {
            if ($onts -> {_gene_to_onts} -> {$dep}) {
                foreach (sort keys %{$onts -> {_gene_to_onts} -> {$dep} -> {onts}}) {
                    $keep{$_} = 1;
                }
            }
        }

        foreach my $nodeg (sort keys %{$nodegs -> {_data}}) {
            if ($onts -> {_gene_to_onts} -> {$nodeg}) {
                foreach (sort keys %{$onts -> {_gene_to_onts} -> {$nodeg} -> {onts}}) {
                    $keep{$_} = 1;
                }
            }
        }

        foreach my $ont (sort keys %{$onts -> {_ids}}) {
            if (!$keep{$ont}) {
                delete($onts -> {_ids} -> {$ont});
                delete($onts -> {_links} -> {$ont});
                delete($onts -> {_ont_to_genes} -> {$ont});
                foreach my $gene (sort keys %{$onts -> {_gene_to_onts}}) {

                    if ($onts -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont}) {
                        delete($onts -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont});
                        if (scalar keys %{$onts -> {_gene_to_onts} -> {$gene} -> {onts}} == 0) {
                            delete($onts -> {_gene_to_onts} -> {$gene});

                        }
                    }
                }
            } else {
                foreach my $gene (sort keys %{$onts -> {_ont_to_genes} -> {$ont} -> {genes}}) {

                    if (!$degs -> {_data} -> {$gene} && !$nodegs -> {_data} -> {$gene}) {
                        delete($onts -> {_ont_to_genes} -> {$ont} -> {genes} -> {$gene});

                    }
                }
            }
        }
    }


package miRNAInterface;
    sub new {
        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        bless $self, $class;
        return($self);
    }
    sub integrateWithDEs {
        my $self = shift;
        my %args = (
            @_
        );
        my $udb = $args{DB};
        my $deus = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};

        foreach my $urnaId (sort keys %{$udb -> {_links} -> {urna2entrez}}) {
            foreach my $entrezId (sort keys %{$udb -> {_links} -> {urna2entrez} -> {$urnaId}}) {
                if ($degs -> {_data} -> {$entrezId}) {
                    if ($deus -> {_data} -> {$urnaId} -> {dev}) {
                        $degs -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {dev} = $deus -> {_data} -> {$urnaId} -> {dev};
                    }
                    if ($deus -> {_data} -> {$urnaId} -> {pvalue}) {
                        $degs -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {pvalue} = $deus -> {_data} -> {$urnaId} -> {dev};
                    }
                    $degs -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {mirt} = $udb -> {_links} -> {entrez2mirt} -> {$entrezId} -> {$urnaId};
                }
                if ($deps -> {_data} -> {$entrezId}) {
                    if ($deus -> {_data} -> {$urnaId} -> {dev}) {
                        $deps -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {dev} = $deus -> {_data} -> {$urnaId} -> {dev};
                    }
                    if ($deus -> {_data} -> {$urnaId} -> {pvalue}) {
                        $deps -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {pvalue} = $deus -> {_data} -> {$urnaId} -> {dev};
                    }
                    $deps -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {mirt} = $udb -> {_links} -> {entrez2mirt} -> {$entrezId} -> {$urnaId};
                }
            }
        }
    }
    sub integrateWithNoDEs {
        my $self = shift;
        my %args = (
            @_
        );
    
        my $udb = $args{DB};
        my $nodegs = $args{ExpNoDegs};
        my $deus = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $noDeFromIdOnly = $args{NoDeFromIdOnly};


        foreach my $urnaId (sort keys %{$udb -> {_links} -> {urna2entrez}}) {
            
            foreach my $entrezId (sort keys %{$udb -> {_links} -> {urna2entrez} -> {$urnaId}}) {
                if (!$degs -> {_data} -> {$entrezId} && !$deps -> {_data} -> {$entrezId}) {
                    #print STDERR $noDeFromIdOnly."\n";
                    next if (!$deus -> {_data} -> {$urnaId} -> {dev} && !$noDeFromIdOnly);
                    
                    if ($deus -> {_data} -> {$urnaId} -> {dev}) {
                        $nodegs -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {dev} = $deus -> {_data} -> {$urnaId} -> {dev};

                    }
                    $nodegs -> {_data} -> {$entrezId} -> {urnas} -> {$urnaId} -> {mirt} = $udb -> {_links} -> {entrez2mirt} -> {$entrezId} -> {$urnaId};
                }
            }
        }
    }
package MethInterface;
    sub new {
        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        bless $self, $class;
        return($self);
    }
    sub integrateWithDEs {
        my $self = shift;
        my %args = (
            @_
        );
        my $meths = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        print STDERR ref($degs)."\n";
        foreach (sort keys %{$meths -> {_data}}) {
            if ($degs -> {_data} -> {$_}) {
                if ($meths -> {_data} -> {$_} -> {dev}) {
                    $degs -> {_data} -> {$_} -> {meth} = $meths -> {_data} -> {$_} -> {dev};
                } else {
                    $degs -> {_data} -> {$_} -> {meth} = "on";
                }
            }
            if ($deps -> {_data} -> {$_}) {
                if ($meths -> {_data} -> {$_} -> {dev}) {
                    $deps -> {_data} -> {$_} -> {meth} = $meths -> {_data} -> {$_} -> {dev};
                } else {
                    $deps -> {_data} -> {$_} -> {meth} = "on";
                }
            }
        }
    }
    sub integrateWithNoDEs {
        my $self = shift;
        my %args = (
            @_
        );
        my $nodegs = $args{ExpNoDegs};
        my $meths = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $noDeFromIdOnly = $args{NoDeFromIdOnly};
        foreach (sort keys %{$meths -> {_data}}) {
            if (!$degs -> {_data} -> {$_} && !$deps -> {_data} -> {$_}) {
                
                next if (!$meths -> {_data} -> {$_} -> {dev} && !$noDeFromIdOnly);
                
                if ($meths -> {_data} -> {$_} -> {dev}) {
                    $nodegs -> {_data} -> {$_} -> {meth} = $meths -> {_data} -> {$_} -> {dev};
                } else {
                    $nodegs -> {_data} -> {$_} -> {meth} = "on";
                }
            }
        }
    }
package ChromaInterface;
    sub new {
        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        bless $self, $class;
        return($self);
    }
    sub integrateWithDEs {
        my $self = shift;
        my %args = (
            @_
        );
        my $nodegs = $args{ExpNoDegs};
        my $chromas = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        foreach (sort keys %{$chromas -> {_data}}) {
            if ($degs -> {_data} -> {$_}) {
                if ($chromas -> {_data} -> {$_} -> {dev}) {
                    $degs -> {_data} -> {$_} -> {chroma} = $chromas -> {_data} -> {$_} -> {dev};
                } else {
                    $degs -> {_data} -> {$_} -> {chroma} = "on";
                }
            }
            if ($deps -> {_data} -> {$_}) {
                if ($chromas -> {_data} -> {$_} -> {dev}) {
                    $deps -> {_data} -> {$_} -> {chroma} = $chromas -> {_data} -> {$_} -> {dev};
                } else {
                    $deps -> {_data} -> {$_} -> {chroma} = "on";
                }
            }
        }
    }
    sub integrateWithNoDEs {
        my $self = shift;
        my %args = (
            @_
        );
        my $nodegs = $args{ExpNoDegs};
        my $chromas = $args{IntegrationExp};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $noDeFromIdOnly = $args{NoDeFromIdOnly};

        foreach (sort keys %{$chromas -> {_data}}) {
            if (!$degs -> {_data} -> {$_} && !$deps -> {_data} -> {$_}) {
                next if (!$chromas -> {_data} -> {$_} -> {dev} && !$noDeFromIdOnly);
                if ($chromas -> {_data} -> {$_} -> {dev}) {
                    $nodegs -> {_data} -> {$_} -> {chroma} = $chromas -> {_data} -> {$_} -> {dev};
                } else {
                    $nodegs -> {_data} -> {$_} -> {chroma} = "on";
                }
            }
        }
    }

package TFInterface;
    use Data::Dumper;
    sub new {
        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        bless $self, $class;
        return($self);
    }
    sub integrateWithDEs {
        
        my $self = shift;
        my %args = (
            @_
        );
        my $tfDB = $args{DB};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $idOnlyFromGene = $args{idOnlyFromGene};
        my $idOnlyFromProt = $args{idOnlyFromProt};
        
        foreach my $tfId (sort keys %{$tfDB -> {_tf_to_genes}}) {
            
            if ($degs -> {_data} -> {$tfId}) {
                next if (!$degs -> {_data} -> {$tfId} -> {dev} && !$idOnlyFromGene);
                foreach my $entrezToLink (keys %{$tfDB -> {_tf_to_genes} -> {$tfId} -> {genes}}) {
                
                    if ($degs -> {_data} -> {$entrezToLink}) {
                        $degs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($degs -> {_data} -> {$tfId} -> {dev}) {
                            $degs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $degs -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                    # print STDERR Dumper $deps -> {_data} -> {$entrezToLink} if ($entrezToLink eq "148327");
                    if ($deps -> {_data} -> {$entrezToLink}) {
                        $deps -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($degs -> {_data} -> {$tfId} -> {dev}) {
                            $deps -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $degs -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                    #die if ($entrezToLink eq "148327");
                }
            }

            if ($deps -> {_data} -> {$tfId}) {
                next if (!$deps -> {_data} -> {$tfId} -> {dev} && !$idOnlyFromProt);
                foreach my $entrezToLink (keys %{$tfDB -> {_tf_to_genes}  -> {$tfId} -> {genes}}) {

                    if ($deps -> {_data} -> {$entrezToLink}) {

                        $deps -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($deps -> {_data} -> {$tfId} -> {dev}) {
                            $deps -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $deps -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                    if ($degs -> {_data} -> {$entrezToLink}) {
                        $degs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($deps -> {_data} -> {$tfId} -> {dev}) {
                            $degs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $deps -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                }
            }
        }
    }
    sub integrateWithNoDEs {
        
        

        my $self = shift;
        my %args = (
            @_
        );
        my $tfDB = $args{DB};
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProteins};
        my $nodegs = $args{ExpNoDEGs};
        my $enableNoDeGene = $args{noDegeneEnabler}; 
        my $enableNoDeProt = $args{noDeprotEnabler};
        my $noDeFromIdOnlyGene = $args{noDeFromIdOnlyGene};
        my $noDeFromIdOnlyProt = $args{noDeFromIdOnlyProt};
        my $nodegsFromProt = {};
        my $nodegsFromGene = {};
        my %seenEntrezs;
        
        foreach my $tfId (sort keys %{$tfDB -> {_tf_to_genes}}) {
            if ($degs -> {_data} -> {$tfId} && $enableNoDeGene) {
                if (!$degs -> {_data} -> {$tfId} -> {dev} && !$noDeFromIdOnlyGene) {
                    next;
                }
                foreach my $entrezToLink (%{$tfDB -> {_tf_to_genes}  -> {$tfId} -> {genes}}) {

                    if (!$degs -> {_data} -> {$entrezToLink} && !$deps -> {_data} -> {$entrezToLink}) {
                        $seenEntrezs{$entrezToLink} = 1;
                        $nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($degs -> {_data} -> {$tfId} -> {dev}) {
                            $nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $degs -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                }
            }
            if ($deps -> {_data} -> {$tfId} && $enableNoDeProt) {
                if (!$deps -> {_data} -> {$tfId} -> {dev} && !$noDeFromIdOnlyProt) {
                    next;
                }
                foreach my $entrezToLink (%{$tfDB -> {_tf_to_genes} -> {$tfId} -> {genes}}) {
                    if (!$deps -> {_data} -> {$entrezToLink} && !$degs -> {_data} -> {$entrezToLink}) {
                        $seenEntrezs{$entrezToLink} = 1;
                        $nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $tfDB -> {_names} -> {$tfId};
                        if ($deps -> {_data} -> {$tfId} -> {dev}) {
                            $nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $deps -> {_data} -> {$tfId} -> {dev};
                        }
                    }
                }
            }
        }
        
        foreach my $entrezToLink (keys %seenEntrezs) {
                if ($nodegsFromGene -> {_data} -> {$entrezToLink}) {
                    foreach my $tfId (keys %{$nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs}}) {
                        #$nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} = {};
                        $nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name};
                        if (!$nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} && $nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev}) {
                            $nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $nodegsFromGene -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev};
                        }
                    }
                }
            
                if ($nodegsFromProt -> {_data} -> {$entrezToLink}) {
                    foreach my $tfId (keys %{$nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs}}) {
                        #$nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} = {};
                        $nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name} = $nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {name};
                        if (!$nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} && $nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev}) {
                            $nodegs -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev} = $nodegsFromProt -> {_data} -> {$entrezToLink} -> {tfs} -> {$tfId} -> {dev};
                        }
                    }
                }
            }
        #print STDERR Dumper $nodegs -> {_data};
        
    }

1;