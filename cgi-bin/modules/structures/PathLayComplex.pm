use strict;
use warnings;

package Complex;

    sub new {

        my $class = shift;
        my $self = {
            _id => "undef",
            _type => "undef",
            _coordinates => "undef",
            _queryForPlot => "",
            _legend_for_title => "",
            _data => {},
            @_
        };
        bless $self, $class;
        return($self);
    }
    sub CoordinatesTrimmer {
        my $self = shift;
        my %args = (
            OffSetX => 0,
            OffSetY => 0,
            Pathway => {},
            @_
        );
        my $pathway = $args{Pathway};

        my ($x_old,$y_old) = split(/,/,$self -> {_coordinates});
        my $x_new = $x_old - $args{OffSetX};
        my $y_new = $y_old - $args{OffSetY};
        $self -> {_coordinates} = {};
        $self -> {_coordinates} -> {x} = $x_new;
        $self -> {_coordinates} -> {y} = $y_new;

        #$pathway -> {_nodes} -> {deg} -> {$coord}
    }
    sub InitLegendsOLDThr {
        my $self = shift;
        my %args = (
            MapName => "",
            @_
        );
        my $map_name = $args{MapName};
        my $parameters = $args{Parameters};
        my $thresholds;

        $self -> {_queryForPlot} = "pathlayplot.pl";
        if ($parameters -> {_mode_select} eq "full") {
            $self -> {_queryForPlot} .= "?thr=%0A";

            my @types = ("gene","prot","urna","meta","chroma","meth");

            foreach my $type (sort @types) {
                if ($parameters -> {"_enable".$type}) {
                    
                    if ($parameters -> {"_".$type."LeftThreshold"} && !$parameters -> {"_".$type."RightThreshold"}) {
                        $self -> {_queryForPlot} .= $type.":";
                        $self -> {_queryForPlot} .= "l".$parameters -> {"_".$type."LeftThreshold"}."|";
                    }
                    if (!$parameters -> {"_".$type."LeftThreshold"} && $parameters -> {"_".$type."RightThreshold"}) {
                        $self -> {_queryForPlot} .= $type.":";
                        $self -> {_queryForPlot} .= "r".$parameters -> {"_".$type."RightThreshold"}."|";
                    }
                    if ($parameters -> {"_".$type."LeftThreshold"} && $parameters -> {"_".$type."RightThreshold"}) {
                        $self -> {_queryForPlot} .= $type.":";
                        $self -> {_queryForPlot} .= "l".$parameters -> {"_".$type."LeftThreshold"}.":";
                        $self -> {_queryForPlot} .= "r".$parameters -> {"_".$type."RightThreshold"}."|";

                    }
                }
            }
            $self -> {_queryForPlot} .= "&";
        }
        if ($parameters -> {_mode_select} eq "id_only") {
            $self -> {_queryForPlot} .= "?";
        }
        
        #$self -> {_queryForPlot} = "pathlayplot.pl?source=$args{MapName} %0A";
        $self -> {_queryForPlot} .= "source=%0Amap_name:$map_name%0A";
    }

    sub InitLegends {
        my $self = shift;
        my %args = (
            MapName => "",
            @_
        );
        my $map_name = $args{MapName};
        my $parameters = $args{Parameters};
        my $thresholds;

        $self -> {_queryForPlot} = "pathlayplot.pl?";
        $self -> {_queryForPlot} .= "source=%0Amap_name:$map_name%0A";
        
    }

    sub monoComplexLoader {
        my $self = shift;
        my %args = (
            @_
        );
        my $data = $args{data};
        my $id = $args{id};

        $self -> mainLegendHandler(
            ID => $id,
            data => $data,
            mainType => $self -> {_type}
        );

        if ($data -> {$id} -> {dev}) {
            $self -> {_data} -> {$id} -> {dev} = $data -> {$id} -> {dev}; #?useful?
            $self -> effectSizeLegendHandler(
                data => $data,
                ID => $id,
                effectSize => $self -> {_data} -> {$id} -> {dev}
            );
        } else {
            $self -> {_queryForPlot} =~ s/$/%0A/;
            $self -> {_legend_for_title} =~ s/$/\n/;
        }

        if ($data -> {$id} -> {meth}) {
            
            $self -> methHandler(
                methylID => $id,
                data => $data
            );
        }
        if ($data -> {$id} -> {chroma}) {
            
            $self -> chromaHandler(
                chromaID => $id,
                data => $data
            );
        }
        if ($data -> {$id} -> {tfs}) {
            $self -> tfHandler(
                data => $data,
                mainID => $id
            ); 
        }
        if ($data -> {$id} -> {urnas}) {
            $self -> urnaHandler(
                data => $data,
                mainID => $id
            );
        }
    }
    sub multiComplexLoader {
        my $self = shift;
        my %args = (
            @_
        );

        my $id = $args{id};
        my $data = $args{data};
        my $mainID = $id;
        my $mainName = $self -> {_data} -> {$id} -> {name};
        my $typeForPlot;
        my $typeForTitle;

        if ($data -> {$id} -> {type} eq "deg+prot") {
            $self -> mainLegendHandler(
                ID => $id,
                data => $data,
                mainType => "deg"
            );
            if ($data -> {$id} -> {dev_gene}) {
                $self -> {_data} -> {$id} -> {dev_gene} = $data -> {$id} -> {dev_gene}; #?useful?
                $self -> effectSizeLegendHandler(
                    data => $data,
                    ID => $id,
                    effectSize => $self -> {_data} -> {$id} -> {dev_gene}
                );
            } else {
                $self -> {_queryForPlot} =~ s/$/%0A/;
                $self -> {_legend_for_title} =~ s/$/\n/;
            }


            if ($data -> {$id} -> {meth}) {
                $self -> methHandler(
                    methylID => $id,
                    data => $data
                );
            }
            if ($data -> {$id} -> {chroma}) {
                $self -> chromaHandler(
                    chromaID => $id,
                    data => $data
                );
            }
            $self -> mainLegendHandler(
                ID => $id,
                data => $data,
                mainType => "prot"
            );

            if ($data -> {$id} -> {dev_prot}) {
                $self -> {_data} -> {$id} -> {dev_prot} = $data -> {$id} -> {dev_prot}; #?useful?
                $self -> effectSizeLegendHandler(
                    data => $data,
                    ID => $id,
                    effectSize => $self -> {_data} -> {$id} -> {dev_prot}
                );
            } else {
                $self -> {_queryForPlot} =~ s/$/%0A/;
                $self -> {_legend_for_title} =~ s/$/\n/;
            }
            if ($data -> {$id} -> {tfs}) {
                $self -> tfHandler(
                    data => $data,
                    mainID => $id
                );
            }
            if ($data -> {$id} -> {urnas}) {
                $self -> urnaHandler(
                    data => $data,
                    mainID => $id
                );
            }
            return;
        }
        if ($data -> {$id} ->{type} ne "deg+prot") {

            $self -> mainLegendHandler(
                ID => $id,
                data => $data,
                mainType => $data -> {$id} -> {type}
            );

            if ($data -> {$id} -> {dev}) {
                $self -> {_data} -> {$id} -> {dev} = $data -> {$id} -> {dev}; #?useful?
                $self -> effectSizeLegendHandler(
                    data => $data,
                    ID => $id,
                    effectSize => $data -> {$id} -> {dev}
                );
            } else {
                $self -> {_queryForPlot} =~ s/$/%0A/;
                $self -> {_legend_for_title} =~ s/$/\n/;
            }

            if ($data -> {$id} -> {meth}) {
                
                $self -> methHandler(
                    methylID => $id,
                    data => $data
                );
            }
            if ($data -> {$id} -> {chroma}) {
                $self -> chromaHandler(
                    chromaID => $id,
                    data => $data
                );
            }
            if ($data -> {$id} -> {tfs}) {
                $self -> tfHandler(
                    data => $data,
                    mainID => $id
                );
            }
            if ($data -> {$id} -> {urnas}) {
                $self -> urnaHandler(
                    data => $data,
                    mainID => $id
                );
            }
            return;
        }
    }
    sub mainLegendHandler {
        use Data::Dumper;
        local *updateLegend = sub {
            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                mainName => "",
                mainID => "",
                mainType => "",
                @_
            );
            my $mainID         = $args{mainID};
            my $mainName       = $args{mainName};
            my $fullName       = $args{fullName};
            my $typeForPlot    = $args{typeForPlot};
            my $legendForPlot  = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $typeForTitle   = $args{typeForTitle};

            $legendForPlot .= "type:$typeForPlot|id:$mainID|name:$mainName";
            $legendForTitle .= "$typeForTitle: $mainID ($mainName)";
            if ($fullName) {
                $legendForTitle .= " ($fullName)";
            }

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );

        my $data = $args{data};
        my $id = $args{ID};

        my $mainID = $id;
        my $mainName = $self -> {_data} -> {$id} -> {name};
        my $fullName;
        my $mainType = $args{mainType};
        my $typeForPlot;
        my $typeForTitle;

        if ($mainType eq "deg") {
            $typeForPlot = "deg";
            $typeForTitle = "mRNA";
        }
        if ($mainType eq "prot") {
            $typeForPlot = "prot";
            $typeForTitle = "Protein";
            $mainID = $data -> {$id} -> {prot_id};
            # print STDERR Dumper $data -> {$id};
            $mainName = $id;
            $fullName = $data -> {$id} -> {prot_name};
        }
        if ($mainType eq "meta") {
            $typeForPlot = "meta";
            $typeForTitle = "Metabolite";
        }
        if ($mainType eq "nodeg") {
            $typeForPlot = "nodeg";
            $typeForTitle = "Not Expressed mRNA";
        }
        
        ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegend(
            legendForPlot => $self -> {_queryForPlot},
            legendForTitle => $self -> {_legend_for_title},
            mainID => $mainID,
            mainName => , $mainName,
            fullName => $fullName,
            typeForPlot => $typeForPlot,
            typeForTitle => $typeForTitle
        );
    }
    sub effectSizeLegendHandler {
        local *updateLegendEffectSize = sub {

            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                effectSize => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $effectSize = $args{effectSize};

            $legendForPlot .= "|dev:$effectSize%0A";
            $legendForTitle .= " Effect Size:$effectSize\n";

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $id = $args{ID};
        my $data = $args{data};
        my $effectSize = $args{effectSize};

        ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendEffectSize(
            legendForPlot => $self -> {_queryForPlot},
            legendForTitle => $self -> {_legend_for_title},
            effectSize => $effectSize
        );

    }
    sub methHandler {

        local *updateLegendMethylation = sub {

            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                methylID => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $methylID = $args{methylID};

            $legendForPlot .= "type:meth|id:$methylID";
            $legendForTitle .= "\tMethylated";
            return($legendForPlot,$legendForTitle);
        };
        local *updateLegendMethylationEs = sub {
            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                methylEffectSize => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $methylEffectSize = $args{methylEffectSize};

            $legendForPlot .= "|dev:$methylEffectSize%0A";
            $legendForTitle .= ": $methylEffectSize\n";

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $id = $args{methylID};
        my $data = $args{data};


        $self -> {_data} -> {$id} -> {meth} = $data -> {$id} -> {meth};
        ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendMethylation(
            legendForPlot => $self -> {_queryForPlot},
            legendForTitle => $self -> {_legend_for_title},
            methylID => $id
        );
        if ($self -> {_data} -> {$id} -> {meth} ne "on") {
            
            ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendMethylationEs(
                legendForPlot => $self -> {_queryForPlot},
                legendForTitle => $self -> {_legend_for_title},
                methylEffectSize => $self -> {_data} -> {$id} -> {meth}
            );
        } else {
            print STDERR $self -> {_queryForPlot}."\n";
            print STDERR $self -> {_legend_for_title}."\n";
            $self -> {_queryForPlot} =~ s/$/%0A/;
            $self -> {_legend_for_title} =~ s/$/\n/;
            #$self -> {_queryForPlot} .= "type:meth|id:$id%0A";
            #$self -> {_legend_for_title} .= "type:meth|id:$id\n";
            #print STDERR $self -> {_queryForPlot}."\n";
            #print STDERR $self -> {_legend_for_title}."\n";
        }
    }
    sub chromaHandler {

        local *updateLegendChromatin = sub {

            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                chromaID => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $chromaID = $args{chromaID};

            $legendForPlot .= "type:chroma|id:$chromaID";
            $legendForTitle .= "\tChromatin: ";

            return($legendForPlot,$legendForTitle);
        };
        local *updateLegendChromatinEs = sub {
            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                chromaEffectSize => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $chromaEffectSize = $args{chromaEffectSize};

            $legendForPlot .= "|dev:$chromaEffectSize%0A";
            $legendForTitle .= ": $chromaEffectSize\n";

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $id = $args{chromaID};
        my $data = $args{data};


        $self -> {_data} -> {$id} -> {chroma} = $data -> {$id} -> {chroma};
        ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendChromatin(
            legendForPlot => $self -> {_queryForPlot},
            legendForTitle => $self -> {_legend_for_title},
            chromaID => $id
        );
        if ($self -> {_data} -> {$id} -> {chroma} ne "on") {
            ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendChromatinEs(
                legendForPlot => $self -> {_queryForPlot},
                legendForTitle => $self -> {_legend_for_title},
                chromaEffectSize => $self -> {_data} -> {$id} -> {chroma}
            );    
        } else {
            $self -> {_queryForPlot} =~ s/$/%0A/;
            $self -> {_legend_for_title} =~ s/$/\n/;
        }
    }
    sub urnaHandler {
        local *updateLegendUrnas = sub {

            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                urnaID => "",
                urnaMIRT => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $urnaID = $args{urnaID};
            my $urnaMIRT = $args{urnaMIRT};

            $legendForPlot .= "type:urna|id:$urnaID|mirt:$urnaMIRT";
            $legendForTitle .= "\tmiRNA: $urnaID($urnaMIRT)";


            return($legendForPlot,$legendForTitle);    
        };
        local *updateLegendUrnasEs = sub {

            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                urnaEffectSize => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $urnaEffectSize = $args{urnaEffectSize};

            $legendForPlot .= "|dev:$urnaEffectSize%0A";
            $legendForTitle .= " Effect Size: $urnaEffectSize\n";

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $data = $args{data};
        my $id = $args{mainID};


        foreach my $urna (sort keys %{$data -> {$id} -> {urnas}}) {
            $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev} = $data -> {$id} -> {urnas} -> {$urna} -> {dev};
            $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt} = $data -> {$id} -> {urnas} -> {$urna} -> {mirt};

            ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendUrnas(
                legendForPlot => $self -> {_queryForPlot},
                legendForTitle => $self -> {_legend_for_title},
                urnaID => $urna,
                urnaMIRT => $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}
            );


            if ($data -> {$id} -> {urnas} -> {$urna} -> {dev}) {
                ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendUrnasEs(
                    legendForPlot => $self -> {_queryForPlot},
                    legendForTitle => $self -> {_legend_for_title},
                    urnaEffectSize => $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}
                );
            } else {
                $self -> {_queryForPlot} =~ s/$/%0A/;
                $self -> {_legend_for_title} =~ s/$/\n/;
            }
        }

    }
    sub tfHandler {
        local *updateLegendTf = sub {
            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                tfName => "",
                tfID => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $tfID = $args{tfID};
            my $tfName = $args{tfName};

            $legendForPlot .= "type:tf|id:$tfID|name:$tfName";
            $legendForTitle .= "\tTranscription Factor: $tfID ($tfName)";

            return($legendForPlot,$legendForTitle);
        };
        local *updateLegendTfEs = sub {
            my %args = (
                legendForPlot => "",
                legendForTitle => "",
                tfEffectSize => "",
                @_
            );

            my $legendForPlot = $args{legendForPlot};
            my $legendForTitle = $args{legendForTitle};
            my $tfEffecSize = $args{tfEffectSize};

            $legendForPlot .= "|dev:$tfEffecSize%0A";
            $legendForTitle .= " Effect Size: $tfEffecSize\n";

            return($legendForPlot,$legendForTitle);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $data = $args{data};
        my $id = $args{mainID};

        foreach my $tf_id (sort keys %{$data -> {$id} -> {tfs}}){
            $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev} = $data -> {$id} -> {tfs} -> {$tf_id} -> {dev};
            $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name} =  $data -> {$id} -> {tfs} -> {$tf_id} -> {name};

            ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendTf(
                legendForPlot => $self -> {_queryForPlot},
                legendForTitle => $self -> {_legend_for_title},
                tfID => $tf_id,
                tfName => $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name}
            );

            if ($data -> {$id} -> {tfs} -> {$tf_id} -> {dev}) {
                ($self -> {_queryForPlot},$self -> {_legend_for_title}) = updateLegendTfEs(
                    legendForPlot => $self -> {_queryForPlot},
                    legendForTitle => $self -> {_legend_for_title},
                    tfEffectSize => $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev}
                );
            } else {
                $self -> {_queryForPlot} =~ s/$/%0A/;
                $self -> {_legend_for_title} =~ s/$/\n/;
            }
        }
    }
    sub ComplexLoader {

        my $self = shift;
        my %args = (
            _ids => {},
            _data => {},
            #_mode => "id_only",
            @_
        );
        my $ids  = $args{_ids};
        my $data = $args{_data};
        my $nodes = $args{_nodes};
        my $multis = $args{_multi_available};
        #my $mode = $args{_mode};

        #$self -> {_queryForPlot} .= "mode:$mode%0A";

        #self -> {_type} contains type for the complex: deg nodeg prot meta multi
        #data -> {id} -> {type} contains type for element in the complex: deg nodeg prot meta

        foreach my $id (sort keys %$ids) {#coordinates db dev name type urnas
            if ($self -> {_type} eq "deg" && $multis -> {$id}) {
                $self -> {_purge} = 1;
                return;
            }
            if ($self -> {_type} eq "nodeg" && $multis -> {$id}) {
                $self -> {_purge} = 1;
                return;
            }
            if ($self -> {_type} eq "prot" && $multis -> {$id}) {
                $self -> {_purge} = 1;
                return;
            }
            
            $self -> {_data} -> {$id} -> {name} = $data -> {$id} -> {name};

            if ($self -> {_type} eq "multi") {
                $self -> multiComplexLoader(
                    data => $data,
                    id => $id
                );
            }
            if ($self -> {_type} ne "multi") {
                $self -> monoComplexLoader(
                    data => $data, 
                    id => $id
                );
                #$self -> ComplexPrinter();
            }
        }
    }
    sub ComplexPrinter {

        my $self = shift;

        print STDERR "COMPLEX ID: ".$self -> {_id}."\n";
        if (ref($self -> {_coordinates}) eq "HASH") {
            print STDERR "COORDINATES: x:".$self -> {_coordinates} -> {x}." y:".$self -> {_coordinates} -> {y}."\n";
        } else {
            print STDERR "COORDINATES: ".$self -> {_coordinates}."\n";
        }
        print STDERR "TYPE: ".$self -> {_type}."\n";
        print STDERR "CONTENT:\n";
        foreach my $id (sort keys (%{$self -> {_data}})) {
            print STDERR $id." ";
            if ($self -> {_data} -> {$id} -> {dev}) {
                print STDERR " DEV:".$self -> {_data} -> {$id} -> {dev};
            }
            if ($self -> {_data} -> {$id} -> {meth}) {
                print STDERR " METH:".$self -> {_data} -> {$id} -> {meth};
            }
            print STDERR "\n";
            if ($self -> {_data} -> {$id} -> {chroma}) {
                print STDERR " CHROMA:".$self -> {_data} -> {$id} -> {chroma};
            }
            if ($self -> {_data} -> {$id} -> {urnas}) {
                foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                    print STDERR " ".$urna." DEV:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."\n";
                }
            }
        }
        print STDERR "#\n";
    }

1;