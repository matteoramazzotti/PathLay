use strict;
use warnings;

package Pathway;

    our @ISA = qw(Complex);
    sub new {
        my $class = shift;
        my $self = {
            _source => "undef",
            _organism => "undef",
            _name => "undef",
            _id => "undef",
            _db => "undef",
            _data => {},
            @_
        };
        my $debug = 0;
        print STDERR $self -> {_source}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub NodesInit { #this should be in parallel in PathwayLoader since _nodes is created here

        my $self = shift;
        #my %check_for_mix;

        ($self,my $check_for_mix) = CreateSingleNodes(
            Self => $self
        );

        ($self) = CreateMultiNodes (
            Self => $self,
            Mix => $check_for_mix
        );

        sub CreateSingleNodes {

            my %args = (
                @_
            );

            my $self = $args{Self};
            my %check_for_mix;
            foreach my $id (sort keys %{$self -> {_data}}) {

                if ($self -> {_data} -> {$id} -> {type} eq "deg+prot") {
                    foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
                        $self -> {_nodes} -> {deg} -> {$_} -> {$id} = 1;
                        $self -> {_nodes} -> {prot} -> {$_} -> {$id} = 1;
                        ${$check_for_mix{$_}}{deg} = 1;
                        ${$check_for_mix{$_}}{prot} = 1;
                    }
                }

                if ($self -> {_data} -> {$id} -> {type} eq "deg") {
                    foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
                        $self -> {_nodes} -> {deg} -> {$_} -> {$id} = 1;
                        ${$check_for_mix{$_}}{deg} = 1;
                    }
                }
                if ($self -> {_data} -> {$id} -> {type} eq "nodeg") {
                    foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
                        $self -> {_nodes} -> {nodeg} -> {$_} -> {$id} = 1;
                        ${$check_for_mix{$_}}{nodeg} = 1;
                    }
                }
                if ($self -> {_data} -> {$id} -> {type} eq "meta") {
                    foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
                        $self -> {_nodes} -> {meta} -> {$_} -> {$id} = 1;
                    }
                }
                if ($self -> {_data} -> {$id} -> {type} eq "prot") {
                    foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
                        $self -> {_nodes} -> {prot} -> {$_} -> {$id} = 1;
                        ${$check_for_mix{$_}}{prot} = 1;
                    }
                }
            }
            return($self,\%check_for_mix);
        }

        sub CreateMultiNodes {

            my %args = (
                @_
            );

            my $self = $args{Self};
            my $hash_ref = $args{Mix};
            my %check_for_mix = %$hash_ref;

            foreach my $coord (sort keys %check_for_mix) {
                if (${$check_for_mix{$coord}}{nodeg} && ${$check_for_mix{$coord}}{deg}) { #this should also handle proteins

                    #print STDERR "check for mix: mixing at $coord:\n";
                    #print STDERR "check for mix: deg:\n";
                    foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
                        $self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
                        $self -> {_multi_available} -> {$deg} = 1;
                        #print STDERR "\t$deg";
                    }
                    #print STDERR "\n";
                    #print STDERR "check for mix: nodeg:\n";
                    foreach my $nodeg (sort keys %{$self -> {_nodes} -> {nodeg} -> {$coord}}) {
                        $self -> {_nodes} -> {multi} -> {$coord} -> {$nodeg} = 1;
                        $self -> {_multi_available} -> {$nodeg} = 1;
                        #print STDERR "\t$nodeg";
                    }
                    #print STDERR "\n";
                }

                ##test
                if (${$check_for_mix{$coord}}{nodeg} && ${$check_for_mix{$coord}}{prot}) {

                    #print STDERR "check for mix: mixing at $coord:\n";
                    #print STDERR "check for mix: prot:\n";
                    foreach my $prot (sort keys %{$self -> {_nodes} -> {prot} -> {$coord}}) {
                        $self -> {_nodes} -> {multi} -> {$coord} -> {$prot} = 1;
                        $self -> {_multi_available} -> {$prot} = 1;
                        print STDERR "\t$prot";
                        print STDERR "\n";
                        print STDERR "check for mix: nodeg:\n";
                        foreach my $nodeg (sort keys %{$self -> {_nodes} -> {nodeg} -> {$coord}}) {
                            $self -> {_nodes} -> {multi} -> {$coord} -> {$nodeg} = 1;
                            $self -> {_multi_available} -> {$nodeg} = 1;
                            print STDERR "\t$nodeg";
                        }
                        print STDERR "\n";
                    }
                }

                if (${$check_for_mix{$coord}}{deg} && ${$check_for_mix{$coord}}{prot}) {

                    #print STDERR "check for mix: mixing at $coord:\n";
                    #print STDERR "check for mix: prot:\n";
                    foreach my $prot (sort keys %{$self -> {_nodes} -> {prot} -> {$coord}}) {
                        $self -> {_nodes} -> {multi} -> {$coord} -> {$prot} = 1;
                        $self -> {_multi_available} -> {$prot} = 1;
                        #print STDERR "\t$prot";
                        #print STDERR "\n";
                        #print STDERR "check for mix: deg:\n";
                        foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
                            $self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
                            $self -> {_multi_available} -> {$deg} = 1;
                            print STDERR "\t$deg";
                        }
                        #print STDERR "\n";
                    }
                }

                ###
            }

            return($self);
        }
    }
    sub PrintComplexes {

        my $self = shift;

        my %args = (
            Type => "all",
            @_
        );
        my $type_to_print = $args{Type};
        foreach my $type ( keys %{$self -> {_complexes}}) {
            #print STDERR "$type\n";
            next if ($type ne "all" && $type ne $type_to_print);
            foreach my $complex (sort @{$self -> {_complexes} -> {$type}}) {
                $complex -> ComplexPrinter();
            }
        }
    }
    sub LoadComplexes {

            my $self = shift;
            my %args = (
                @_
            );


            my @deg_complexes;
            my @nodeg_complexes;
            my @prot_complexes;
            my @meta_complexes;
            my @multi_complexes;
            my $count = 1;
            my $parameters = $args{Parameters};

            #multi must be handled first due to not generate indicator duplicates
            foreach my $coord (sort keys %{$self -> {_nodes} -> {multi}}) {
                my $complex = new Complex(
                    _id => $self -> {_id}."_$count",
                    _coordinates => $coord,
                    _type => "multi",
                    _index => $self -> {_index}
                );
                $complex -> CoordinatesTrimmer(
                    OffSetX => 25,
                    OffSetY => 25
                );
                $complex -> InitLegends(
                    MapName => $self -> {_name},
                    Parameters => $parameters
                );
                $complex -> ComplexLoader(
                    _ids => $self -> {_nodes} -> {multi} -> {$coord},
                    _data => $self -> {_data},
                    _nodes => $self -> {_nodes},
                    _multi_available => $self -> {_multi_available},
                    #_mode => $parameters -> {_mode_select}
                );
                push (@multi_complexes,$complex);
                $count++;
            }

            foreach my $coord (sort keys %{$self -> {_nodes} -> {deg}}) {
                #print STDERR "COMPLEX: ".$self -> {_id}."_$count"."\n";
                #print STDERR "TYPE: deg\n";
                #print STDERR "COORDINATES: ".$coord."\n";
                my $complex = new Complex(
                    _id => $self -> {_id}."_$count",
                    _coordinates => $coord,
                    _type => "deg",
                    _index => $self -> {_index}
                );
                if ($self -> {_nodes} -> {deg} -> {$coord} && $self -> {_nodes} -> {nodeg} -> {$coord}) {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => (25-10),
                        OffSetY => 25
                    );
                } else {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => 25,
                        OffSetY => 25
                    );
                }
                $complex -> InitLegends(
                    MapName => $self -> {_name},
                    Parameters => $parameters
                );
                $complex -> ComplexLoader(
                    _ids => $self -> {_nodes} -> {deg} -> {$coord},
                    _data => $self -> {_data},
                    _nodes => $self -> {_nodes},
                    _multi_available => $self -> {_multi_available},
                    #_mode => $parameters -> {_mode_select}
                );
                next if ($complex -> {_purge});
                push (@deg_complexes,$complex);
                #push (@gene_complexes,$complex);
                $count++;
            }
            foreach my $coord (sort keys %{$self -> {_nodes} -> {prot}}) {
                my $complex = new Complex(
                    _id => $self -> {_id}."_$count",
                    _coordinates => $coord,
                    _type => "prot",
                    _index => $self -> {_index}
                );
                if ($self -> {_nodes} -> {deg} -> {$coord} && $self -> {_nodes} -> {nodeg} -> {$coord}) {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => (25-10),
                        OffSetY => 25
                    );
                } else {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => 25,
                        OffSetY => 25
                    );
                }
                $complex -> InitLegends(
                    MapName => $self -> {_name},
                    Parameters => $parameters
                );
                $complex -> ComplexLoader(
                    _ids => $self -> {_nodes} -> {prot} -> {$coord},
                    _data => $self -> {_data},
                    _nodes => $self -> {_nodes},
                    _multi_available => $self -> {_multi_available},
                    #_mode => $parameters -> {_mode_select}
                );
                next if ($complex -> {_purge});
                push (@prot_complexes,$complex);
                #push (@gene_complexes,$complex);
                $count++;
            }
            foreach my $coord (sort keys %{$self -> {_nodes} -> {nodeg}}) {
                #print STDERR "COMPLEX: ".$self -> {_id}."_$count"."\n";
                #print STDERR "TYPE: nodeg\n";
                #print STDERR "COORDINATES: ".$coord."\n";
                my $complex = new Complex(
                    _id => $self -> {_id}."_$count",
                    _coordinates => $coord,
                    _type => "nodeg",
                    _index => $self -> {_index}
                );
                if ($self -> {_nodes} -> {deg} -> {$coord} && $self -> {_nodes} -> {nodeg} -> {$coord}) {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => (25+10),
                        OffSetY => 25
                    );
                } else {
                    $complex -> CoordinatesTrimmer(
                        OffSetX => 25,
                        OffSetY => 25
                    );
                }
                $complex -> InitLegends(
                    MapName => $self -> {_name},
                    Parameters => $parameters
                );
                $complex -> ComplexLoader(
                    _ids => $self -> {_nodes} -> {nodeg} -> {$coord},
                    _data => $self -> {_data},
                    _nodes => $self -> {_nodes},
                    _multi_available => $self -> {_multi_available},
                    #_mode => $parameters -> {_mode_select}
                );
                next if ($complex -> {_purge});
                push (@nodeg_complexes,$complex);
                #push (@gene_complexes,$complex);
                $count++;
            }
            foreach my $coord (sort keys %{$self -> {_nodes} -> {meta}}) {
                print STDERR "COMPLEX: ".$self -> {_id}."_$count"."\n";
                print STDERR "TYPE: meta\n";
                print STDERR "COORDINATES: ".$coord."\n";
                my $complex = new Complex(
                    _id => $self -> {_id}."_$count",
                    _coordinates => $coord,
                    _type => "meta",
                    _index => $self -> {_index}
                );
                $complex -> CoordinatesTrimmer(
                    OffSetX => 25,
                    OffSetY => 25
                );
                $complex -> InitLegends(
                    MapName => $self -> {_name},
                    Parameters => $parameters
                );
                $complex -> ComplexLoader(
                    _ids => $self -> {_nodes} -> {meta} -> {$coord},
                    _data => $self -> {_data},
                    _nodes => $self -> {_nodes},
                    _multi_available => $self -> {_multi_available},
                    #_mode => $parameters -> {_mode_select}
                );
                push (@meta_complexes,$complex);
                $count++;
            }
            #print STDERR "COMPLEXES ON ".$self -> {_id}.": ".(scalar @deg_complexes + scalar @nodeg_complexes + scalar @meta_complexes)."\n";
            #print STDERR " DEG: ".(scalar @deg_complexes)."\n"." NODEG: ".(scalar @nodeg_complexes)."\n"." META: ".(scalar @meta_complexes)."\n";


            @{$self -> {_complexes} -> {deg}}   = @deg_complexes;
            @{$self -> {_complexes} -> {nodeg}} = @nodeg_complexes;
            @{$self -> {_complexes} -> {prot}} = @prot_complexes;
            @{$self -> {_complexes} -> {meta}}  = @meta_complexes;
            @{$self -> {_complexes} -> {multi}}  = @multi_complexes;
    }
    sub PathwayPrinter {
        my $self = shift;

        print STDERR $self -> {_id}."|".$self -> {_name}."|".$self -> {_organism}."|".$self -> {_db}."\n";
        foreach my $node_id (sort keys %{$self -> {_data}}) {
            print STDERR " ".$node_id." ".
            $self -> {_data} -> {$node_id} -> {name}." ".
            $self -> {_data} -> {$node_id} -> {type};
            if ($self -> {_data} -> {$node_id} -> {dev}) {
                print STDERR " DEV:".$self -> {_data} -> {$node_id} -> {dev};
            }
            if ($self -> {_data} -> {$node_id} -> {meth}) {
                print STDERR " Meth:".$self -> {_data} -> {$node_id} -> {meth};
            }
            foreach (sort @{$self -> {_data} -> {$node_id} -> {coordinates}}) {
                print STDERR " ".$_;
            }
            print STDERR "\n";
            if ($self -> {_data} -> {$node_id} -> {urnas}) {
                foreach my $urna (sort keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
                    print STDERR "\t".$urna;
                }
                print STDERR "\n";
            }
        }
        print STDERR "\n";
    }
    sub PathwayLoader {
        use Data::Dumper;
        my $seen = {
            deg => {},
            nodeg => {},
            prot => {},
            urna => {},
            meth => {},
            meta => {},
            chroma => {},
            tf => {}
        };

        local *checkByType = sub {
            my %args = (
                NodeId  => {},
                Pathway  => {},
                ExpToCheck => {},
                DataType => "",
                @_
            );
            my $nodeId = $args{NodeId};
            my $pathway = $args{Pathway};
            my $expPack = $args{ExpToCheck};
            my $dataType = $args{DataType};
            
            $pathway -> {_data} -> {$nodeId} -> {type} = $dataType;
            $seen -> {$dataType} -> {$nodeId}++;
            print STDERR "Checking by type $nodeId\n";
            if ($expPack -> {_data} -> {$nodeId} -> {_prot_id}) {
                
                $pathway -> {_data} -> {$nodeId} -> {prot_id} = $expPack -> {_data} -> {$nodeId} -> {_prot_id};
                $pathway -> {_data} -> {$nodeId} -> {prot_name} =  $expPack -> {_data} -> {$nodeId} -> {_prot_name};
            }
            if ($expPack -> {_data} -> {$nodeId} -> {dev}) {
                $pathway -> {_data} -> {$nodeId} -> {dev} = $expPack -> {_data} -> {$nodeId} -> {dev};
            }
            if ($expPack -> {_data} -> {$nodeId} -> {urnas}) {
                %{$pathway -> {_data} -> {$nodeId} -> {urnas}} = %{$expPack -> {_data} -> {$nodeId} -> {urnas}}; #this includes mirt
                foreach (keys %{$pathway -> {_data} -> {$nodeId} -> {urnas}}) {
                    $seen -> {urna} -> {$nodeId}++;
                }
            }
            if ($expPack -> {_data} -> {$nodeId} -> {meth}) {
                $pathway -> {_data} -> {$nodeId} -> {meth} = $expPack -> {_data} -> {$nodeId} -> {meth};
                $seen -> {meth} -> {$nodeId}++;
            }
            if ($expPack -> {_data} -> {$nodeId} -> {chroma}) {
                $pathway -> {_data} -> {$nodeId} -> {chroma} = $expPack -> {_data} -> {$nodeId} -> {chroma};
                $seen -> {chroma} -> {$nodeId}++;
            }
            if ($expPack -> {_data} -> {$nodeId} -> {tfs}) {
                foreach my $tf_id (sort keys %{$expPack -> {_data} -> {$nodeId} -> {tfs}}) {
                    $pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev} = $expPack -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev};
                    $pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name} = $expPack -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name};
                    $seen -> {tf} -> {$nodeId}++;
                }
            }
        };
        local *checkDegProt = sub {
            my %args = (
                NodeId  => {},
                Pathway  => {},
                ExpToCheckGene => {},
                ExpToCheckProt => {},
                @_
            );
            my $nodeId = $args{NodeId};
            my $pathway = $args{Pathway};
            my $expPackProt = $args{ExpToCheckProt};
            my $expPackGene = $args{ExpToCheckGene};
            my $dataType = $args{DataType};

            $seen -> {deg} -> {$nodeId}++;
            $seen -> {prot} -> {$nodeId}++;
            $pathway -> {_data} -> {$nodeId} -> {type} = "deg+prot";
            $pathway -> {_data} -> {$nodeId} -> {dev_prot} = $expPackProt -> {_data} -> {$nodeId} -> {dev};
            $pathway -> {_data} -> {$nodeId} -> {prot_id} =  $expPackProt -> {_data} -> {$nodeId} -> {_prot_id};
            $pathway -> {_data} -> {$nodeId} -> {prot_name} =  $expPackProt -> {_data} -> {$nodeId} -> {_prot_name};
            $pathway -> {_data} -> {$nodeId} -> {dev_gene} = $expPackGene -> {_data} -> {$nodeId} -> {dev};
            if ($expPackGene -> {_data} -> {$nodeId} -> {urnas}) {
                %{$pathway -> {_data} -> {$nodeId} -> {urnas}} = %{$expPackGene -> {_data} -> {$nodeId} -> {urnas}}; #this includes mirt
                foreach (keys %{$pathway -> {_data} -> {$nodeId} -> {urnas}}) {
                    $seen -> {urna} -> {$nodeId}++;
                }
            }
            if ($expPackGene -> {_data} -> {$nodeId} -> {meth}) {
                $pathway -> {_data} -> {$nodeId} -> {meth} = $expPackGene -> {_data} -> {$nodeId} -> {meth};
                $seen -> {meth} -> {$nodeId}++;
            }
            if ($expPackGene -> {_data} -> {$nodeId} -> {chroma}) {
                $pathway -> {_data} -> {$nodeId} -> {chroma} = $expPackGene -> {_data} -> {$nodeId} -> {chroma};
                $seen -> {chroma} -> {$nodeId}++;
            }
            if ($expPackGene -> {_data} -> {$nodeId} -> {tfs}) {
                foreach my $tf_id (sort keys %{$expPackGene -> {_data} -> {$nodeId} -> {tfs}}) {
                    $pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev} = $expPackGene -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev};
                    $pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name} = $expPackGene -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name};
                    $seen -> {tf} -> {$nodeId}++;

                }
            }
        };

        my $self = shift;
        my %args = (
            ExpGenes  => {},
            ExpProts  => {},
            ExpNoDEGs => {},
            ExpMetas  => {},
            Params => {},
            @_
        );

        my $parameters = $args{Params};
        my $debug = 0;
        my $degs = $args{ExpGenes};
        my $deps = $args{ExpProts};
        my $dems = $args{ExpMetas};
        my $nodegs = $args{ExpNoDEGs};

        print STDERR Dumper $dems;

        open(IN,$self -> {_source});
        chomp(my @nodes = <IN>);
        close(IN);
        shift @nodes;
        ($self -> {_name},$self -> {_organism},$self -> {_db},$self -> {_id}) = split(/\t/,shift(@nodes));


        foreach (sort @nodes) {
            my ($node_name,$node_type,$node_db,$node_id,@coords) = split(/\t/,$_);
            print STDERR "Checking $node_id\n";
            next if (
                !$degs -> {_data} -> {$node_id} &&
                !$nodegs -> {_data} -> {$node_id} &&
                !$dems -> {_data} -> {$node_id} &&
                !$deps -> {_data} -> {$node_id}
            );
            print STDERR "$node_id Passed\n";


            $self -> {_data} -> {$node_id} -> {name} = $node_name;
            $self -> {_data} -> {$node_id} -> {db} = $node_db; #useless

            if ($degs -> {_data} -> {$node_id} && !$deps -> {_data} -> {$node_id}) {
                checkByType(
                    ExpToCheck => $degs,
                    DataType => "deg",
                    NodeId => $node_id,
                    Pathway => $self
                );
            }
            if ($deps -> {_data} -> {$node_id} && !$degs -> {_data} -> {$node_id}) {
                checkByType(
                    ExpToCheck => $deps,
                    DataType => "prot",
                    NodeId => $node_id,
                    Pathway => $self
                );
            }
            if ($degs -> {_data} -> {$node_id} && $deps -> {_data} -> {$node_id}) {
                checkDegProt(
                    ExpToCheckGene => $degs,
                    ExpToCheckProt => $deps,
                    Pathway => $self,
                    NodeId => $node_id
                );
            }
            if ($dems -> {_data} -> {$node_id}) {
                checkByType(
                    ExpToCheck => $dems,
                    DataType => "meta",
                    NodeId => $node_id,
                    Pathway => $self
                );
            }
            if ($nodegs -> {_data} -> {$node_id}) {
                checkByType(
                    ExpToCheck => $nodegs,
                    DataType => "nodeg",
                    NodeId => $node_id,
                    Pathway => $self
                );
            }
            @{$self -> {_data} -> {$node_id} -> {coordinates}} = @coords;
            print STDERR "FOUND $node_id id at ".$self -> {_id}."\n" if ($debug);
        }
        $self -> {_degs_loaded} = scalar keys %{$seen -> {deg}};
        $self -> {_nodegs_loaded} = scalar keys %{$seen -> {nodeg}};
        $self -> {_urnas_loaded} = scalar keys %{$seen -> {urna}};
        $self -> {_metas_loaded} = scalar keys %{$seen -> {meta}};
        $self -> {_methyls_loaded} = scalar keys %{$seen -> {meth}};
        $self -> {_proteins_loaded} = scalar keys %{$seen -> {prot}};
        $self -> {_chroma_loaded} = scalar keys %{$seen -> {chroma}};

    }

package MapDiv;
    our @ISA = qw(HTMLDiv);
    sub LoadComplexesOnDiv {
        my $self = shift;
        my %args = (
            Pathway => {},
            @_
        );
        my $pathway = $args{Pathway};
        foreach my $complex_type (sort keys %{$pathway -> {_complexes}}) {
            foreach my $complex (sort @{$pathway -> {_complexes} -> {$complex_type}}) {
                my $compid = $complex -> {_id};
                my ($map_id,$complex_number) = split(/_/,$compid);
                my $div_name = "";
                my $div_title = $complex -> {_legend_for_title};
                my $plot_source = $complex -> {_queryForPlot};
                my $top_coord = $complex -> {_coordinates} -> {y};
                my $left_coord = $complex -> {_coordinates} -> {x};
                foreach my $content_id (sort keys %{$complex -> {_data}}) {

                    my $content_name = $complex -> {_data} -> {$content_id} -> {name};
                    $div_name .= "\_$content_id($content_name)";
                }
                $div_name =~ s/^\_//;
                my $complex_img = new HTMLImg(
                    _id => $compid,
                    _name => $div_name,
                    _alt => "complex",
                    _class => "complex animate-right",
                    _style => "position:absolute; top:$top_coord"."px; left:$left_coord"."px; visibility:visible; opacity:0.6;z-index:+1;",
                    _src => "$plot_source",
                    _width => 50,
                    _height => 50,
                    _title => $complex -> {_legend_for_title},
                    _onClick => "complex_selector($compid)",
                    _ondblclick => "spawnBoomBox(this)"
                );
                $self -> ContentLoader(
                    Content => $complex_img
                );
            }
        }
    }
1;