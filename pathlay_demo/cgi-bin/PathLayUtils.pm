use strict;
#use warnings;
use Data::Dumper qw(Dumper);
use lib '/var/www/html/pathlay_demo/cgi-bin/';
use HTMLObjects;
use CGI;
my $debug = 0;

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
    my $degs;
    my $nodegs;
    my $meths;

    if ($args{DEGs}) {
        $degs = $args{DEGs};
    }
    if($args{NoDEGs}) {
        $nodegs = $args{NoDEGs};
    }
    if ($args{Methyls}) {
        $meths = $args{Methyls};
    }

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
    foreach my $id (sort keys %{$meths -> {_data}}) {
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

sub LinkuRNAs {

    my %args = (
        ExpGenes => {},
        ExpuRNAs => {},
        ExpNoDEGs => {},
        uRNADB => {},
        @_
    );

    my $degs   = $args{ExpGenes};
    my $nodegs = $args{ExpNoDEGs};
    my $deus   = $args{ExpuRNAs};
    my $deps   = $args{ExpProteins};
    my $udb    = $args{uRNADB};
    my $parameters = $args{Parameters};

    foreach my $urna_id (sort keys %{$deus -> {_data}}){
        if ($udb -> {_links} -> {urna2deg} -> {$urna_id}) {
            foreach my $deg (sort keys %{$udb -> {_links} -> {urna2deg} -> {$urna_id}}) {
                $degs -> {_data} -> {$deg} -> {urnas} -> {$urna_id} -> {dev} = $deus -> {_data} -> {$urna_id} -> {dev};
                $degs -> {_data} -> {$deg} -> {urnas} -> {$urna_id} -> {mirt} = $udb -> {_links} -> {deg2mirt} -> {$deg} -> {$urna_id};
                #print STDERR $degs -> {_data} -> {$deg} -> {urnas} -> {$urna_id} -> {mirt}."\n";
            }
        }
        #if ($udb -> {_links} -> {urna2nodeg} -> {$urna_id} && ($parameters -> {_nodeg_select} eq "all" || $parameters -> {_nodeg_select} eq "urna_only")) {
        if ($udb -> {_links} -> {urna2prot} -> {$urna_id}) {
            foreach my $prot (sort keys %{$udb -> {_links} -> {urna2prot} -> {$urna_id}}) {
                $deps -> {_data} -> {$prot} -> {urnas} -> {$urna_id} -> {dev} = $deus -> {_data} -> {$urna_id} -> {dev};
                $deps -> {_data} -> {$prot} -> {urnas} -> {$urna_id} -> {mirt} = $udb -> {_links} -> {prot2mirt} -> {$prot} -> {$urna_id};
            }
        }
        if ($udb -> {_links} -> {urna2nodeg} -> {$urna_id} && ($parameters -> {_nodeg_select_urna} == 1)) {
            foreach my $nodeg (sort keys %{$udb -> {_links} -> {urna2nodeg} -> {$urna_id}}) {
                $nodegs -> {_data} -> {$nodeg} -> {urnas} -> {$urna_id} -> {dev} = $deus -> {_data} -> {$urna_id} -> {dev};
                $nodegs -> {_data} -> {$nodeg} -> {urnas} -> {$urna_id} -> {mirt} = $udb -> {_links} -> {nodeg2mirt} -> {$nodeg} -> {$urna_id};
                #print STDERR $nodegs -> {_data} -> {$nodeg} -> {urnas} -> {$urna_id} -> {mirt}."\n";
                #<STDIN>;
            }
        }

    }
}

sub LinkTFs {
    my %args = (
        ExpGenes => {},
        ExpNoDEGs => {},
        TFsDB => {},
        @_
    );

    my $degs   = $args{ExpGenes};
    my $nodegs = $args{ExpNoDEGs};
    my $proteins = $args{ExpProteins};
    my $tfdb    = $args{TFsDB};
    my $parameters = $args{Parameters};

    my $debug = 0;
    print STDERR "-- sub LinkTFs --\n" if ($debug);
    foreach my $tf_id (sort keys %{$tfdb -> {_ids}}) {
        if ($degs -> {_data} -> {$tf_id}) {
            print STDERR "TF FOUND: $tf_id\n" if ($debug);
            $tfdb -> {_devs} -> {$tf_id} = $degs -> {_data} -> {$tf_id} -> {dev};
            $tfdb -> {_pvals} -> {$tf_id} = $degs -> {_data} -> {$tf_id} -> {pvalue};
            #print STDERR $tfdb -> {_devs} -> {$tf_id}."\n";
            #print STDERR $tfdb -> {_pvals} -> {$tf_id}."\n";
            foreach my $gene_to_link (sort keys %{$tfdb -> {_tf_to_genes} -> {$tf_id} -> {genes}}) {
                #print STDERR "Linking: $gene_to_link\n";
                if ($degs -> {_data} -> {$gene_to_link}) {
                    $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} = {};
                    $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {name} = $tfdb -> {_names} -> {$tf_id};
                    $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {link} = $tfdb -> {_links} -> {$tf_id};
                    if ($tfdb -> {_devs} -> {$tf_id}) {
                        $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {dev} = $tfdb -> {_devs} -> {$tf_id};
                    }
                    if ($tfdb -> {_pvals} -> {$tf_id}) {
                        $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {pval} = $tfdb -> {_pvals} -> {$tf_id};
                        #print STDERR $degs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {pval}."\n";
                    }
                }
                if ($nodegs -> {_data} -> {$gene_to_link}) {
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} = {};
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {name} = $tfdb -> {_names} -> {$tf_id};
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {link} = $tfdb -> {_links} -> {$tf_id};
                    if ($tfdb -> {_devs} -> {$tf_id}) {
                        $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {dev} = $tfdb -> {_devs} -> {$tf_id};
                    }
                    if ($tfdb -> {_pvals} -> {$tf_id}) {
                        $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {pval} = $tfdb -> {_pvals} -> {$tf_id};
                    }
                }
                if ($proteins -> {_data} -> {$gene_to_link}) {
                    $proteins -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} = {};
                    $proteins -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {name} = $tfdb -> {_names} -> {$tf_id};
                    $proteins -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {link} = $tfdb -> {_links} -> {$tf_id};
                    if ($tfdb -> {_devs} -> {$tf_id}) {
                        $proteins -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {dev} = $tfdb -> {_devs} -> {$tf_id};
                    }
                    if ($tfdb -> {_pvals} -> {$tf_id}) {
                        $proteins -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {pval} = $tfdb -> {_pvals} -> {$tf_id};
                    }
                }
                if (!$degs -> {_data} -> {$gene_to_link} && !$nodegs -> {_data} -> {$gene_to_link} && !$proteins -> {_data} -> {$gene_to_link} && $parameters -> {_nodeg_select_tf} == 1) {
                    #delete($tfdb -> {_tf_to_genes} -> {$gene_to_link});
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} = {};
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {name} = $tfdb -> {_names} -> {$tf_id};
                    $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {link} = $tfdb -> {_links} -> {$tf_id};
                    if ($tfdb -> {_devs} -> {$tf_id}) {
                        $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {dev} = $tfdb -> {_devs} -> {$tf_id};
                    }
                    if ($tfdb -> {_pvals} -> {$tf_id}) {
                        $nodegs -> {_data} -> {$gene_to_link} -> {tfs} -> {$tf_id} -> {pval} = $tfdb -> {_pvals} -> {$tf_id};
                    }
                }

            }
        } else {
            delete($tfdb -> {_ids} -> {$tf_id});
            delete($tfdb -> {_names} -> {$tf_id});
            delete($tfdb -> {_links} -> {$tf_id});
            delete($tfdb -> {_tf_to_genes} -> {$tf_id});
            print STDERR "DELETED: $tf_id\n" if ($debug);
        }
    }

    $debug = 0;
}

sub Container6Packager {
        my %args = (
            @_
        );

        my $container = new HTMLDiv(
            _id => "container6",
            _class => "container6"
        );

        my $maps_container = new HTMLDiv(
            _id => "maps_div",
            _class => "maps_div"
        );

        my $info_container = new HTMLDiv(
            _id => "info_container",
            _class => "info_container"
        );
        my $info_header_div = new HTMLDiv(
            _id => "info_header_div",
            _class => "info_header_div",
        );
        my $info_display_div = new HTMLDiv(
            _id => "info_display_div",
            _class => "info_display_div",
            _contenteditable => "false",
        );
        my $complex_pool_div = new HTMLDiv(
            _id => "complex_pool_div",
            _class => "complex_pool_div",
            _contenteditable => "false"
        );


        foreach my $map_div (@{$args{MapDivs}}) {
            #print STDERR ref($map_div)."\n";
            $maps_container -> ContentLoader(
                Content => $map_div
            );
        }

        $info_header_div -> ContentLoader(
            Content => "<font size=\"+1\" color=\"white\">"
        );
        $info_header_div -> ContentLoader(
            Content => "<b>Complex Selections</b>"
        );
        $info_header_div -> ContentLoader(
            Content => "</font>"
        );

        #my $info_text_box = new HTMLInput(
        #    _id => "info_text_box",
        #    _type => "text",
        #    _readonly => "readonly"
        #);



        #$info_display_div -> ContentLoader(
        #    Content => $info_text_box
        #);
        my $add_icon_button = new HTMLInput(
            _id => "add_icon_button",
            _type => "button",
            _value => "Add",
            _onClick => "fill_complex_pool(active_complex_id)"
        );

        my $remove_icon_button = new HTMLInput(
            _id => "remove_icon_button",
            _type => "button",
            _value => "Remove",
            _onClick => "purge_complex_pool(active_complex_id)"
        );
        my $download_info_button = new HTMLInput(
            _id => "download_info_button",
            _type => "button",
            _value => "Download",
            _onClick => ""
        );
        my $select_maps_from_icon_button = new HTMLInput(
            _id => "select_maps_from_icon_button",
            _type => "button",
            _value => "Select",
            _onClick => ""
        );

        $info_container -> ContentLoader(
            Content => $info_header_div
        );
        $info_container -> ContentLoader(
            Content => $info_display_div
        );
        $info_container -> ContentLoader(
            Content => $add_icon_button
        );
        $info_container -> ContentLoader(
            Content => $remove_icon_button
        );
        $info_container -> ContentLoader(
            Content => $complex_pool_div
        );
        $info_container -> ContentLoader(
            Content => $select_maps_from_icon_button
        );
        $info_container -> ContentLoader(
            Content => $download_info_button
        );
        $container -> ContentLoader(
            Content => $maps_container
        );
        $container -> ContentLoader(
            Content => $info_container
        );

        return($container);
}


sub Container5Packager {

    my %args = (
        @_
    );

    my $container = new HTMLDiv(
        _id => "container5",
        _class => "container5"
        #_style => "border: 5px solid black;"
    );

    $container -> ContentLoader(
        Content => $args{Container4}
    );
    $container -> ContentLoader(
        Content => $args{Container2}
    );
    $container -> ContentLoader(
        Content => $args{Container3}
    );

    return($container);
}


sub Container3Packager {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    my $container = new HTMLDiv(
        _id => "container3",
        _class => "container3"
    );

    my $settings_div = new HTMLDiv(
        _id => "settings_div",
        _class => "settings_div"
    );
    my $logistics_div = new HTMLDiv(
        _id => "logistics_div",
        _class => "logistics_div"
    );

    my $transparency_up_button = new HTMLInput(
        _id => "transparency_up",
        _type => "button",
        _value => "Transparency Up",
        _onClick => "change(\'trasp\',\'u\')"
    );
    my $transparency_down_button = new HTMLInput(
        _id => "transparency_down",
        _type => "button",
        _value => "Transparency Down",
        _onClick => "change(\'trasp\',\'d\')"
    );
    my $size_up_button = new HTMLInput(
        _id => "size_up",
        _type => "button",
        _value => "Size Up",
        _onClick => "change(\'size\',\'u\')"
    );
    my $size_down_button = new HTMLInput(
        _id => "size_down",
        _type => "button",
        _value => "Size Down",
        _onClick => "change(\'size\',\'d\')"
    );
    my $shot_button = new HTMLInput(
        _id => "shot",
        _type => "button",
        _onClick => "screenshot()",
        _value => "Open as image (to save...)",
        _title => "Draw a shot of the current map in a new window"
    );
    $settings_div -> ContentLoader(
        Content => $transparency_up_button
    );
    $settings_div -> ContentLoader(
        Content => $transparency_down_button
    );
    $settings_div -> ContentLoader(
        Content => $size_up_button
    );
    $settings_div -> ContentLoader(
        Content => $size_down_button
    );
    $settings_div -> ContentLoader(
        Content => $shot_button
    );

    my $operator1_select = new HTMLSelect(
        _name => "operator1",
        _id => "operator1",
        _onchange => "logic(1)",
        _class => "op1"
    );
    my $operator2_select = new HTMLSelect(
        _name => "operator2",
        _id => "operator2",
        _onchange => "logic(2)",
        _class => "op2"
    );
    my @operator_options;
    $operator_options[0] = new HTMLSelectOption(
        _value => "none",
        _width => 5
    );
    $operator_options[1] = new HTMLSelectOption(
        _value => "or",
        _text => "OR",
        _width => 5
    );
    $operator_options[2] = new HTMLSelectOption(
        _value => "and",
        _text => "AND",
        _width => 5
    );
    $operator1_select -> LoadOption(
        HTMLSelectOption => \@operator_options
    );
    $operator2_select -> LoadOption(
        HTMLSelectOption => \@operator_options
    );

    my $type1_logical_select = new HTMLSelect(
        _name => "type1",
        _id => "type1",
        _onchange => "logic_handler(1)"
    );
    my $type2_logical_select = new HTMLSelect(
        _name => "type2",
        _id => "type2",
        _onchange => "logic_handler(2)"
    );
    my $type3_logical_select = new HTMLSelect(
        _name => "type3",
        _id => "type3",
        _onchange => "logic_handler(3)"
    );
    my @type_options;
    $type_options[0] = new HTMLSelectOption(
        _value => "none",
        _width => 10
    );
    if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth} || $parameters -> {_enableprot}) {
        $type_options[1] = new HTMLSelectOption(
            _value => "gene",
            _text => "Gene",
            _width => 10
        );
    }
    if ($parameters -> {_enableurna}) {
        $type_options[2] = new HTMLSelectOption(
            _value => "urna",
            _text => "miRNA",
            _width => 10
        );
    }
    if ($parameters -> {_enablemeta}) {
        $type_options[3] = new HTMLSelectOption(
            _value => "meta",
            _text => "Metabolite",
            _width => 10
        );
    }



    $type1_logical_select -> LoadOption(
        HTMLSelectOption => \@type_options
    );
    $type2_logical_select -> LoadOption(
        HTMLSelectOption => \@type_options
    );
    $type3_logical_select -> LoadOption(
        HTMLSelectOption => \@type_options
    );
    my $runlogic_button = new HTMLInput(
        _id => "runlogic",
        _type => "button",
        _value => "Select",
        _onClick => "logic(\'run\')"
    );
    my $resetlogic_button = new HTMLInput(
        _id => "resetlogic",
        _type => "button",
        _value => "Reset",
        _onClick => "logic(\'reset\')"
    );

    my $gene_selector_logical_html = new HTMLSelect(
        _id => "select1b",
        _name => "select1b",
        _onchange => "select_logic(1)",
        _title => "Select Gene for logical operators"
    );
    my $urna_selector_logical_html = new HTMLSelect(
        _id => "select2b",
        _name => "select2b",
        _onchange => "select_logic(2)",
        _title => "Select miRNA for logical operators"
    );
    my $meta_selector_logical_html = new HTMLSelect(
        _id => "select3b",
        _name => "select3b",
        _onchange => "select_logic(3)",
        _title => "Select Metabolite for logical operators"
    );
    $gene_selector_logical_html -> LoadOption(
        HTMLSelectOption => \%{$args{GeneIDSelector}}
    );
    $gene_selector_logical_html -> SortSelectByAlphabet();
    $urna_selector_logical_html -> LoadOption(
        HTMLSelectOption => \%{$args{miRNAIDSelector}}
    );
    $urna_selector_logical_html -> SortSelectByAlphabet();
    $meta_selector_logical_html -> LoadOption(
        HTMLSelectOption => \%{$args{MetaIDSelector}}
    );
    $meta_selector_logical_html -> SortSelectByAlphabet();


    my $first_gene_select = new HTMLSelectOption(
        _value => "all",
        _text => "Gene for Logical"
    );
    unshift(@{$gene_selector_logical_html -> {_options}},$first_gene_select);

    my $first_urna_select = new HTMLSelectOption(
        _value => "all",
        _text => "miRNA for Logical"
    );
    unshift(@{$urna_selector_logical_html -> {_options}},$first_urna_select);

    my $first_meta_select = new HTMLSelectOption(
        _value => "all",
        _text => "Metabolite for Logical"
    );
    unshift(@{$meta_selector_logical_html -> {_options}},$first_meta_select);


    if ($parameters -> {_selectors_to_enable} > 1) {
        $logistics_div -> ContentLoader(
            Content => $type1_logical_select
        );
        $logistics_div -> ContentLoader(
            Content => $operator1_select
        );
        $logistics_div -> ContentLoader(
            Content => $type2_logical_select
        );
        if ($parameters -> {_selectors_to_enable} > 2) {
            $logistics_div -> ContentLoader(
                Content => $operator2_select
            );
            $logistics_div -> ContentLoader(
                Content => $type3_logical_select
            );
        }

        if ($parameters -> {_enablegene} || $parameters -> {_enablemeth} || $parameters -> {_enableprot}) {
            $logistics_div -> ContentLoader(
                Content => $gene_selector_logical_html
            );
        }
        if ($parameters -> {_enableurna}) {
            $logistics_div -> ContentLoader(
                Content => $urna_selector_logical_html
            );
        }
        if ($parameters -> {_enablemeta}) {
            $logistics_div -> ContentLoader(
                Content => $meta_selector_logical_html
            );
        }
        $logistics_div -> ContentLoader(
            Content => $runlogic_button
        );
        $logistics_div -> ContentLoader(
            Content => $resetlogic_button
        );
    }
    $container -> ContentLoader(
        Content => $settings_div
    );
    $container -> ContentLoader(
        Content => $logistics_div
    );

    return($container);
}

sub Container4Packager {

    my $container = new HTMLDiv(
        _id => "container4",
        _class => "container4"
    );
    my $header_div = new HTMLDiv(
        _id => "header_div",
        _class => "header_div"
    );
    my $unifi_logo_div = new HTMLDiv(
        _id => "unifi_logo_div",
        _class => "unifi_logo_div"
    );
    my $unifi_logo_img = new HTMLImg(
        _id => "unifi",
        _src => "../src/sbsc-unifi-trasp-inv.png",
        _height => 100
    );

    $header_div -> ContentLoader(
        Content => "<font style=\"margin-top:35px; margin-left:60px; position:absolute;\" size=\"+2\" color=\"white\">"
    );
    $header_div -> ContentLoader(
        Content => "<b> Pathlay - Analysis Results</b>"
    );
    $header_div -> ContentLoader(
        Content => "</font>"
    );

    $unifi_logo_div -> ContentLoader(
        Content => $unifi_logo_img
    );

    $container -> ContentLoader(
        Content => $header_div
    );
    $container -> ContentLoader(
        Content => $unifi_logo_div
    );

    return($container);
}

sub Container2Packager {

    my %args = (
        #MapSelector => {},
        #GeneIDSelector => {},
        #miRNAIDSelector => {},
        #MetaIDSelector => {},
        @_
    );

    my $parameters = $args{Parameters};

    my $container = new HTMLDiv(
        _id => "container2",
        _class => "container2"
    );
    my $mainselectors_div = new HTMLDiv(
        _id => "main_selectors_div",
        _class => "main_selectors_div"
    );
    my $mapselectors_div = new HTMLDiv(
        _id => "mapselectors",
        _class => "mapselectors"
    );
    my $idselectors_div = new HTMLDiv(
        _id => "idselectors",
        _class => "idselectors"
    );
    my $buttons_div = new HTMLDiv(
        _id => "main_buttons_div",
        _class => "main_buttons_div"
    );

    my $settings_buttons_div = new HTMLDiv(
        _id => "settings_buttons_div",
        _class => "settings_buttons_div"
    );
    my $logistics_buttons_div = new HTMLDiv(
        _id => "logistics_buttons_div",
        _class => "logistics_buttons_div"
    );

    my $show_settings_button = new HTMLInput(
        _id => "showbutton",
        _type => "button",
        _value => "Show Settings",
        _onClick => "toggleSettings('show')",
        _title => "Show Settings"
    );
    my $hide_settings_button = new HTMLInput(
        _id => "hidebutton",
        _type => "button",
        _value => "Hide Settings",
        _onClick => "toggleSettings('hide')",
        _title => "Hide Settings"
    );
    if ($parameters -> {_selectors_to_enable} > 1) {
        my $show_logistics_button = new HTMLInput(
            _id => "showbutton2",
            _type => "button",
            _value => "Show Logistics",
            _onClick => "toggleLogistics('show')",
            _title => "Show Logistics"
        );
        my $hide_logistics_button = new HTMLInput(
            _id => "hidebutton2",
            _type => "button",
            _value => "Hide Logistics",
            _onClick => "toggleLogistics('hide')",
            _title => "Hide Logistics"
        );
        $logistics_buttons_div -> ContentLoader(
            Content => $show_logistics_button
        );
        $logistics_buttons_div -> ContentLoader(
            Content => $hide_logistics_button
        );

    }

    $settings_buttons_div -> ContentLoader(
        Content => $show_settings_button
    );
    $settings_buttons_div -> ContentLoader(
        Content => $hide_settings_button
    );


    $buttons_div -> ContentLoader(
        Content => $settings_buttons_div
    );
    $buttons_div -> ContentLoader(
        Content => $logistics_buttons_div
    );
    $mapselectors_div -> ContentLoader(
        Content => $args{MapSelector}
    );


    if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth} || $parameters -> {_enableprot}) {
        if ($args{GeneIDSelector}) {
            $idselectors_div -> ContentLoader(
                Content => $args{GeneIDSelector}
            );
        }
    }
    if ($parameters -> {_enableurna}) {
        if ($args{miRNAIDSelector}) {
            $idselectors_div -> ContentLoader(
            Content => $args{miRNAIDSelector}
        );
        }
    }
    if ($parameters -> {_enablemeta}) {
        if ($args{MetaIDSelector}){
            $idselectors_div -> ContentLoader(
            Content => $args{MetaIDSelector}
        );
        }
    }

    $mainselectors_div -> ContentLoader(
        Content => $mapselectors_div
    );
    $mainselectors_div -> ContentLoader(
        Content => $idselectors_div
    );

    $container -> ContentLoader(
        Content => $mainselectors_div
    );
    $container -> ContentLoader(
        Content => $buttons_div
    );

    return($container);
}



package Parameters;
sub new {

    my $class = shift;
    my $self = {
        _submit => "",
        _username => "",
        _password => "",
        _access => "",
        _home => "",
        _time => "",
        _styledir => "../css/",
        _jsdir => "../javascript/",
        _org => "hsa",
        _mapdir => "../pathlay_data/pathways/",
        _expname => "",
        _comments => "",
        _urna_db_filter => "strongonly",
        _enablegene => 0,
        _enableurna => 0,
        _enablemeta => 0,
        _enabledeg => 0,
        _enablenodeg => 0,
        _enablemeth => 0,
        _enableprot => 0,
        _enableonts => 0,
        _enabletfs => 0,
        _nodeg_select_urna => 0,
        _nodeg_select_meth => 0,
        _nodeg_select_tf => 0,
        _gene_data => "",
        _gene_id_column => "",
        _gene_dev_column => 5,
        _gene_dev_type => "logFC",
        _gene_dev_thr => 1, #integer
        _gene_dev_dir => "out", # out in min maj
        _gene_pvalue_column => 4,
        _gene_pvalue_thr => 0.05, #integer
        _gene_meth_column => 5,
        _gene_meth_thr => 1,
        _gene_meth_dir => "out",
        _map_association_file => "",
        _meta_data => "",
        _meta_id_column => 7,
        _meta_dev_column => 5,
        _meta_dev_type => "logFC",
        _meta_dev_thr => 1,
        _meta_dev_dir => "out",
        _meta_pvalue_column => 4,
        _meta_pvalue_thr => 0.05,
        _ont_db_file => "",
        _ont_db_location => "",
        _prot_db_file => "",
        _prot_db_location => "",
        _tf_db_file => "",
        _tf_db_location => "",
        _urna_db_file => "",
        _urna_db_location => "",
        _urna_data => "",
        _urna_id_column => 1,
        _urna_dev_column => 5,
        _urna_dev_type => "logFC",
        _urna_dev_thr => 1,
        _urna_dev_dir => "out",
        _urna_pvalue_column => 4,
        _urna_pvalue_thr => 0.05,
        _universe_file => "",
        @_
    };
    bless $self,$class;
    return($self);
}

sub CheckUserData {
    print STDERR "CheckUserData\n";
    my $self = shift;
    my %args = (
        UsersFile => "",
        Form => {},
        @_
    );
    my $users_file = $args{'UsersFile'};
    my %form = %{$args{'Form'}};
    #$form{username} = "lorenzo.casbarra\@stud.unifi.it";#!
    #$form{password} = "admin";#!
    open(IN,$users_file) or die "Cannot find users file!";
    foreach my $line (<IN>) {
        next if ($line !~ /\w/);
        chomp($line);
        my (
            $username,
            $password,
            $home,
            $time
        ) = split (/\t/,$line);
        if ($username eq $form{'username'}) {
            if ($password eq $form{'password'}) {
                $self -> {_username} = $username;
                $self -> {_password} = $password;
                $self -> {_time} = $time;
                $self -> {_home} = $home;
            } else {
                $self -> {_home} = 'nopwd';
            }
            last;
        } else {
            $self -> {_home} = 'unk';
        }
    }
    close(IN);
}

sub RegisterUser {
    print STDERR "RegisterUser\n";
    my $self = shift;
    my %args = (
        UsersFile => "",
        Form => {},
        @_
    );
    my $users_file = $args{'UsersFile'};
    my %form = %{$args{'Form'}};

    print STDERR $self -> {_username}."\n";
    print STDERR $self -> {_password}."\n";

    open(IN,$users_file) or die "Cannot find users file!";
    foreach my $line (<IN>) {
        next if ($line !~ /\w/);
        chomp($line);
        my (
            $username,
            $password,
            $home,
            $time
        ) = split (/\t/,$line);
        if ($username eq $form{'username'}) {
            if ($password eq $form{'password'}) {
                $self -> {_username} = $username;
                $self -> {_password} = $password;
                $self -> {_home} = $home;
                $self -> {_time} = $time;
            } else {
                $self -> {_home} = 'nopwd';
            }
            last;
        } else {
            $self -> {_home} = 'unk';
        }
    }
    print STDERR $self -> {_username}."\n";
    print STDERR $self -> {_password}."\n";
    print STDERR $self -> {_home}."\n";
    if ($self -> {_home} eq 'unk') {
        $self -> {_username} = $form{'username'};
        $self -> {_password} = $form{'password'};
        if ($self -> {_username} =~ "@") {
            if ($self -> {_password} ne "") {
                $self -> {_home} = "";
                foreach my $i (0..9){
                    $self -> {_home} .= int(rand(9));
                    $i++;
                }
                my $line = $self -> {_username}."\t".$self -> {_password}."\t".$self -> {_home}."\t1010101010\n";
                $self -> {_access} = "granted";
                system("echo \"$line\" >> /var/www/html/pathlay_demo/pathlay_users/users.list");
            }
            system("mkdir /var/www/html/pathlay_demo/pathlay_users/".$self -> {_home});
        } else {
            $self -> {_access} = "try_again";
        }

    }
    if ($self -> {_home} ne 'unk' && $self -> {_home} ne 'nopwd') {
        $self -> {_access} = "granted";
    }
    print STDERR $self -> {_access}."\n";
    return($self);
}

sub LoadAvailableExps {
    print STDERR "LoadAvailableExps\n";
    my $self = shift;
    my %args = (
        UsersDir => "",
        @_
    );

    opendir(DIR,$args{UsersDir});
    my $nexps = 0;
    foreach my $file (readdir(DIR)) {
        $nexps++ if ($file =~ /\.conf$/);
    }
    closedir(DIR);
    print STDERR "HERE:".$args{UsersDir}."\n";
    foreach my $e (1..$nexps) {
        $self -> {_exps_available} -> {"exp$e"} -> {conf_file} = "exp$e.conf";
        $self -> {_exps_available} -> {"exp$e"} -> {gene_file} = "exp$e.mrna";
        $self -> {_exps_available} -> {"exp$e"} -> {urna_file} = "exp$e.mirna";
        $self -> {_exps_available} -> {"exp$e"} -> {meta_file} = "exp$e.meta";
        $self -> {_exps_available} -> {"exp$e"} -> {prot_file} = "exp$e.prot";
        $self -> {_exps_available} -> {"exp$e"} -> {last_file} = "exp$e.last";
        #$self -> {_exps_available} -> {"exp$e"} -> {pathsel_file} = "exp$e.sel";
        #$self -> {_exps_available} -> {"exp$e"} -> {assoc_file} = "exp$e.assoc";
        print STDERR $self->{_exps_available}->{"exp$e"}->{conf_file}."\n";
        open(CONFIG,$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{conf_file}) or print "No".$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{conf_file}."<br>";
        while (<CONFIG>) {
            chomp;
            next if ($_ !~ /\w/);
            my ($field,$value) = split (/=/,$_);
            $self -> {_exps_available} -> {"exp$e"} -> {conf_data} -> {$field} = $value;
            print STDERR $field.":".$value."\n";
        }
        close(CONFIG);
        open(LAST,$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{last_file}) or print STDERR "No".$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{last_file}."<br>";
        while (<LAST>) {
            chomp;
            next if ($_ !~ /\w/);
            my ($field,$value) = split (/=/,$_);
            $self -> {_exps_available} -> {"exp$e"} -> {conf_data} -> {$field} = $value;
        }
        close(LAST);
    }



}

sub LoadAvailableONTs {
    print STDERR "LoadAvailableONTs\n";
    my $self = shift;
    my %args = (
        _ont_db_file => "ont_hsa.gmt",
        _ont_db_location => "../pathlay_data/hsa/db/",
        @_
    );
    my $debug = 1;


    foreach my $organism(sort keys %{$self -> {_organisms_available}}) {
        open(IN,"../pathlay_data/$organism/db/$organism"."_ont.gmt");
        while(<IN>) {
            chomp;
            my ($ont_id,$ont_name,$ont_link,$genes) = split(/\t/);
            #$ont_id =~ s/://;
            $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {link} = $ont_link;
            $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {name} = $ont_name;
            foreach my $gene (sort(split(/;/,$genes))) {
                $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {genes} -> {$gene} = 1;
            }
        }
        close(IN);
    }
    $debug = 0;

    %{$self -> {_onts_default} -> {hsa}} = (
        "GO:0005737" => "name" => "cytoplasm",
        "GO:0005737" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005737",
        "GO:0005739" => "name" => "mitochondrion",
        "GO:0005739" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005739",
        "GO:0005634" => "name" => "nucleus",
        "GO:0005634" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005634",
        "GO:0005764" => "name" => "lysosome",
        "GO:0005764" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005764",
        "GO:0005794" => "name" => "Golgi apparatus",
        "GO:0005794" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005794",
        "GO:0005783" => "name" => "endoplasmic reticulum",
        "GO:0005783" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005783",
        "GO:0016020" => "name" => "membrane",
        "GO:0016020" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0016020",
        "GO:0005856" => "name" => "cytoskeleton",
        "GO:0005856" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005856"
    );
    %{$self -> {_onts_default} -> {mmu}} = (
        "GO:0005737" => "name" => "cytoplasm",
        "GO:0005737" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005737",
        "GO:0005739" => "name" => "mitochondrion",
        "GO:0005739" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005739",
        "GO:0005634" => "name" => "nucleus",
        "GO:0005634" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005634",
        "GO:0005764" => "name" => "lysosome",
        "GO:0005764" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005764",
        "GO:0005794" => "name" => "Golgi apparatus",
        "GO:0005794" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005794",
        "GO:0005783" => "name" => "endoplasmic reticulum",
        "GO:0005783" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005783",
        "GO:0016020" => "name" => "membrane",
        "GO:0016020" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0016020",
        "GO:0005856" => "name" => "cytoskeleton",
        "GO:0005856" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005856"
    );

}

sub LoadAvailableOrganisms {
    print STDERR "LoadAvailableOrganisms\n";
    my $self = shift;
    my %args = (
        @_
    );
    my $scores = {};
    my $scores_for_db = {};
    my $dirchecks = {};
    opendir(DIR,"../pathlay_data/") or die "Cannot open ../pathlay_data/\n";
    foreach my $organism_dir (readdir(DIR)) {
        next if ($organism_dir eq ".." || $organism_dir eq ".");
        print STDERR $organism_dir;
    	$dirchecks -> {$organism_dir} = {
    		maps_dir_ok => 0,
    		maps_kegg_dir_ok => 0,
    		maps_wikipathways_dir_ok => 0,
    		db_dir_ok => 0,
    		db_kegg_dir_ok => 0,
    		db_wikipathways_dir_ok => 0,

    	};
    	$scores -> {$organism_dir} = 0;

        $dirchecks -> {$organism_dir} -> {maps_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps");
        $dirchecks -> {$organism_dir} -> {maps_kegg_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps/kegg");
        $dirchecks -> {$organism_dir} -> {maps_wikipathways_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps/wikipathways");
        $dirchecks -> {$organism_dir} -> {db_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db");
        $dirchecks -> {$organism_dir} -> {db_kegg_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db/kegg");
        $dirchecks -> {$organism_dir} -> {db_wikipathways_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db/wikipathways");

        #foreach my $key (sort keys %{$dirchecks -> {$organism_dir}}) {
        #   	print STDERR "\t".$key."\t".$dirchecks -> {$organism_dir} -> {$key};
        #   	$scores -> {$organism_dir}++ if ($dirchecks -> {$organism_dir} -> {$key} == 1);
        #}
        print STDERR "\n";
        #if ($scores -> {$organism_dir} == (scalar keys %{$dirchecks -> {$organism_dir}})) {
        #   	$self -> {_organisms_available} -> {$organism_dir} = 1;
        #}
        if ($dirchecks -> {$organism_dir} -> {maps_dir_ok} == 1 &&
            $dirchecks -> {$organism_dir} -> {maps_kegg_dir_ok} == 1 &&
            $dirchecks -> {$organism_dir} -> {db_kegg_dir_ok} == 1
        ) {
            $self -> {_organisms_available} -> {$organism_dir} -> {kegg} = 1;
        }
        if ($dirchecks -> {$organism_dir} -> {maps_dir_ok} == 1 &&
            $dirchecks -> {$organism_dir} -> {maps_wikipathways_dir_ok} == 1 &&
            $dirchecks -> {$organism_dir} -> {db_wikipathways_dir_ok} == 1
        ) {
            $self -> {_organisms_available} -> {$organism_dir} -> {wikipathways} = 1;
        }
    }
    closedir(DIR);
    print STDERR "Organisms available:";
    foreach my $key (sort keys %{$self -> {_organisms_available}}) {
      	print STDERR " $key";
    }
    print STDERR "\n";
}
sub LoadENV {
    print STDERR "LoadENV\n";
    my $self = shift;


    my $buffer;
    my $name;
    my $value;
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST") {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    } else {
        $buffer = $ENV{'QUERY_STRING'};
    }
    my @pairs = split(/&/,$buffer);
    foreach my $pair (@pairs) {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        #print STDERR "_$name\n";
        if ($value){
            #print STDERR $name."---".$value."\n";
            $self -> {"_$name"} = $value;
        }
        if (ref($value) eq "ARRAY") { #?
            foreach my $what (@$name) {
                    #print STDERR $what."\n";
            }
        }
    }

    $self -> {_gene_db_file} = $self -> {_exp_organism_input_text}.".gene_info";
    $self -> {_gene_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
    $self -> {_urna_db_file} = $self -> {_exp_organism_input_text}."_mirtarbase.tsv";
    $self -> {_urna_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_exp_organism_input_text}."_mirtarbase.tsv";
    $self -> {_prot_db_file} = $self -> {_exp_organism_input_text}."_uniprot.tsv";
    $self -> {_prot_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
    $self -> {_ont_db_file} = $self -> {_exp_organism_input_text}."_ont.gmt";
    $self -> {_ont_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
    $self -> {_tf_db_file} = $self -> {_exp_organism_input_text}."_tf.gmt";
    $self -> {_tf_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
    $self -> {_meta_db_file} = $self -> {_exp_organism_input_text}.".compound_info";
    $self -> {_meta_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";

    $self -> {_mapdir} .= $self -> {_maps_db_select}."/"; 
    $self -> {_nodesdir} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/maps/".$self -> {_maps_db_select}."/";
    $self -> {_universe_file} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_maps_db_select}."/".$self -> {_exp_organism_input_text}.".".$self -> {_maps_db_select}.".genes.universe";
    $self -> {_map_association_file} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_maps_db_select}."/".$self -> {_exp_organism_input_text}.".".$self -> {_maps_db_select}.".gmt";
}
sub updateLastSession {

    my $self = shift;
    
    open(LAST,">","../pathlay_users/".$self -> {_h3}."/".$self -> {_exp_select}.".last");

    print LAST "mode_select=".$self -> {_mode_select}."\n";

    print LAST "filter_select_pval=".$self -> {_filter_select_pval}."\n";
    print LAST "filter_select_es=".$self -> {_filter_select_es}."\n";

    print LAST "nodeg_select_urna=".$self -> {_nodeg_select_urna}."\n";
    print LAST "nodeg_select_meth=".$self -> {_nodeg_select_meth}."\n";
    print LAST "nodeg_select_tf=".$self -> {_nodeg_select_tf}."\n";

    print LAST "statistic_select=".$self -> {_statistic_select}."\n";

    print LAST "maps_db_select=".$self -> {_maps_db_select}."\n";

    print LAST "enabletfs=".$self -> {_enabletfs}."\n";

    print LAST "enablegene=".$self -> {_enablegene}."\n";
    print LAST "enableprot=".$self -> {_enableprot}."\n";
    print LAST "enableurna=".$self -> {_enableurna}."\n";
    print LAST "enablemeth=".$self -> {_enablemeth}."\n";
    print LAST "enablemeta=".$self -> {_enablemeta}."\n";

    print LAST "geneLeftThreshold=".$self -> {_geneLeftThreshold}."\n" if ($self -> {_geneLeftThreshold});
    print LAST "geneRightThreshold=".$self -> {_geneRightThreshold}."\n" if ($self -> {_geneRightThreshold});
    print LAST "genepValThreshold=".$self -> {_genepValThreshold}."\n" if ($self -> {_genepValThreshold});

    print LAST "protLeftThreshold=".$self -> {_protLeftThreshold}."\n" if ($self -> {_protLeftThreshold});
    print LAST "protRightThreshold=".$self -> {_protRightThreshold}."\n" if ($self -> {_protRightThreshold});
    print LAST "protpValThreshold=".$self -> {_protpValThreshold}."\n" if ($self -> {_protpValThreshold});

    print LAST "urnaLeftThreshold=".$self -> {_urnaLeftThreshold}."\n" if ($self -> {_urnaLeftThreshold});
    print LAST "urnaRightThreshold=".$self -> {_urnaRightThreshold}."\n" if ($self -> {_urnaRightThreshold});
    print LAST "urnapValThreshold=".$self -> {_urnapValThreshold}."\n" if ($self -> {_urnapValThreshold});

    print LAST "methLeftThreshold=".$self -> {_methLeftThreshold}."\n" if ($self -> {_methLeftThreshold});
    print LAST "methRightThreshold=".$self -> {_methRightThreshold}."\n" if ($self -> {_methRightThreshold});
    print LAST "methpValThreshold=".$self -> {_methpValThreshold}."\n" if ($self -> {_methpValThreshold});

    print LAST "metaLeftThreshold=".$self -> {_metaLeftThreshold}."\n" if ($self -> {_metaLeftThreshold});
    print LAST "metaRightThreshold=".$self -> {_metaRightThreshold}."\n" if ($self -> {_metaRightThreshold});
    print LAST "metapValThreshold=".$self -> {_metapValThreshold}."\n" if ($self -> {_metapValThreshold});

    close(LAST);
}
sub PrintParameters {
    my $self = shift;
    foreach my $parameter (sort keys %$self) {
        next if ($parameter =~ /data$/);
        print STDERR "$parameter => ". $self -> {$parameter}."\n";
    }
}
sub CheckParameters {
    print STDERR "CheckParameters\n";
    my $self = shift;

    my %bad_parameters;
    my @checks = (
        "_h1",
        "_h2",
        "_h3",
        "_exp_name_input_text"
    );
    $self -> {_selectors_to_enable} = 0;

    push(@checks,qw/_gene_data _gene_id_column _geneLeftThreshold _geneRightThreshold _gene_pvalue_column _genepValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enablegene});
    push(@checks,qw/_prot_data _prot_id_column _protLeftThreshold _protRightThreshold _prot_pvalue_column _protpValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enableprot});
    push(@checks,qw/_meth_data _meth_id_column _methLeftThreshold _methRightThreshold _meth_pvalue_column _methpValThreshold/) if ($self -> {_enablemeth});
    push(@checks,qw/_urna_data _urna_id_column _urnaLeftThreshold _urnaRightThreshold _urna_pvalue_column _urnapValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enableurna});
    push(@checks,qw/_meta_data _meta_id_column _metaLeftThreshold _metaRightThreshold _meta_pvalue_column _metapValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enablemeta});


    print STDERR "_selectors_to_enable:".$self -> {_selectors_to_enable}."\n";
    foreach my $parameter (@checks) {
        $bad_parameters{$parameter} = 1 if (!$self -> {$parameter});
        #print STDERR "$parameter OK: ".$self -> {$parameter}."\n" if ($self -> {$parameter});
        #print STDERR "$parameter NO\n" if (!$self -> {$parameter});
    }
    if (scalar keys %bad_parameters > 0) {
        print "Content-type: text/html\n\n";
        print "<table width=\"1900px\" border=0>\n";
        print "<tr bgcolor=\"#006699\" width=\"80%\"><td>\n";
        print "<font size=\"+2\" color=\"white\"><b>PathLay Interface</b></font></td><td align=\"right\"><img src=\"../src/sbsc-unifi-trasp-inv.png\" height=100 id=\"unifi\"></td>\n";
        print "</tr></table>\n";
        print "<table width=\"1900px\" border=0>\n";
        print "<tr><td>","<b>ERROR: The following filelds are missing with no default:</b><br>",(join '<br>',keys %bad_parameters),"\n";
        #output('stop');
        exit;
    }

    if ($self -> {_enableurna} == 1) {
        $self -> {_enablenodeg} = 1;
    }
    if ($self -> {_selectors_to_enable} == 1 && $self -> {_enableurna} == 1) {
        $self -> {_selectors_to_enable}++;
    }
    if ($self -> {_enablegene} == 0 && $self -> {_enableurna} == 1 && $self -> {_selectors_to_enable} >= 2) {
        $self -> {_selectors_to_enable} = 3;
    }
    if ($self -> {_enablegene} == 0  && $self -> {_enableurna} == 1) { #?
        $self -> {_selectors_to_enable}++;
    }
    if (($self -> {_enablegene} == 1 || $self -> {_enableprot} == 1) && $self -> {_enabletfs} == 1 ) {
        $self -> {_selectors_to_enable}++;
    }
}

package Report;
sub new {
    my $class = shift;
    my $self = {
        _degs_loaded => 0,
        _urnas_loaded => 0,
        _metas_loaded => 0,
        _nodegs_loaded => 0,
        _degs_collapsed => 0,
        _urnas_collapsed => 0,
        _metas_collapsed => 0,
        _degs_filtered => 0,
        _urnas_filtered => 0,
        _metas_filtered => 0,
        _urnas_linked_to_degs => 0,
        _urnas_linked_to_nodegs => 0,
        _degs_methylated => 0,
        _maps_processed => 0,
        _maps_plotted => 0,
        @_
    };
    bless $self, $class;
    return($self);
}
sub UpdateByKey {

    my $self = shift;
    my %args = (
        @_
    );

    foreach my $key (keys %args) {
        print STDERR "$key:".$args{$key}."\n";
        $self -> {$key} = $args{$key};
    }
}
sub PrintReport {

    my $self = shift;

    foreach my $key (sort keys %$self){
        print STDERR "$key:".$self -> {$key}."\n";
    }
}

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
        @_
    );
    my $parameters = $args{Parameters};
    my $degs = $args{ExpGenes};
    my $base = "../pathlay_users/";
    my $tf_db = $parameters -> {_tf_db_file};
    my $tf_db_location = $parameters -> {_tf_db_location};

    my $debug = 0;
    open(IN,$tf_db_location.$tf_db);
    while (<IN>) { #need to load only the strictly necessary
        chomp;
        print STDERR "$_\n" if ($debug);
        my ($tf_id,$tf_name,$null,$tf_link,@tf_genes) = split(/\t/);

        if ($degs -> {_data} -> {$tf_id}) {
            print STDERR "ID:$tf_id|LINK:$tf_link\n" if ($debug);
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

package ONTs;
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
sub ONTsLoader {
    my $self = shift;
    my %args = (
        Parameters => {},
        @_
    );
    my $parameters = $args{Parameters};
    my $base = "../pathlay_users/";
    my $user = $parameters -> {_h3};
    my $exp = $parameters -> {_exp_select};
    my $ont_db = $parameters -> {_ont_db_file};
    my $ont_db_location = $parameters -> {_ont_db_location};

    my $debug = 1;
    if ( -e $base.$user."/"."$exp.ont") {
        open(IN,$base.$user."/"."$exp.ont");
        while (<IN>) {
            chomp;
            next if ($_ eq "");
            $self -> {_ids} -> {$_} = 1;
        }
        close(IN);

        if (scalar keys %{$self -> {_ids}} == 0) {
            $parameters -> {_enableonts} = 0;
            return;
        } else {
            $parameters -> {_enableonts} = 1;
        }

        open(IN,$ont_db_location.$ont_db);
        while (<IN>) {
            chomp;
            print STDERR "$_\n" if ($debug);
            my ($ont_id,$ont_link,@ont_genes) = split(/\t/,$_);
            $ont_id =~ s/^GOCC_//;
            print STDERR "ID:$ont_id|LINK:$ont_link\n" if ($debug);
            if ($self -> {_ids} -> {$ont_id}) {
                $self -> {_links} -> {$ont_id} = $ont_link;
                foreach (sort @ont_genes) {
                    $self -> {_ont_to_genes} -> {$ont_id} -> {genes} -> {$_} = 1;
                    $self -> {_gene_to_onts} -> {$_} -> {onts} -> {$ont_id} = 1;
                }
            }
        }
        close(IN);
    } else {
        $parameters -> {_enableonts} = 0;
    }
    $debug = 0;
}
sub ONTsLoader2 {
    my $self = shift;
    my %args = (
        Parameters => {},
        @_
    );
    my $parameters = $args{Parameters};
    my $base = "../pathlay_users/";
    my $user = $parameters -> {_h3};
    my $exp = $parameters -> {_exp_select};
    my $ont_db = $parameters -> {_ont_db_file};
    my $ont_db_location = $parameters -> {_ont_db_location};

    my $debug = 0;
    if ( -e $base.$user."/"."$exp.ont") {
        open(IN,$base.$user."/"."$exp.ont");
        while (<IN>) {
            chomp;
            next if ($_ eq "");
            $self -> {_ids} -> {$_} = 1;
        }
        close(IN);

        if (scalar keys %{$self -> {_ids}} == 0) {
            $parameters -> {_enableonts} = 0;
            return;
        } else {
            $parameters -> {_enableonts} = 1;
        }
        open(IN,$ont_db_location.$ont_db);
        while (<IN>) {
            chomp;
            print STDERR "$_\n" if ($debug);
            my ($ont_id,$ont_name,$ont_link,$ont_genes) = split(/\t/);
            my @ont_genes = split(/;/,$ont_genes);
            print STDERR "ID:$ont_id|LINK:$ont_link\n" if ($debug);
            if ($self -> {_ids} -> {$ont_id}) {
                $self -> {_names} -> {$ont_id} = $ont_name;
                $self -> {_links} -> {$ont_id} = $ont_link;
                foreach (sort @ont_genes) {
                    $self -> {_ont_to_genes} -> {$ont_id} -> {genes} -> {$_} = 1;
                    $self -> {_gene_to_onts} -> {$_} -> {onts} -> {$ont_id} = 1;
                }
            }
        }
        close(IN);
    } else {
        $parameters -> {_enableonts} = 0;
    }
    $debug = 0;
}

sub ONTsPrinter {
    my $self = shift;

    foreach my $ont (sort keys %{$self -> {_ids}}) {
        print STDERR "> ".$ont."\n";
        print STDERR $self -> {_links} -> {$ont}."\n";
        foreach my $gene (sort keys %{$self -> {_ont_to_genes} -> {$ont} -> {genes}}) {
            print STDERR $gene."|";
        }
        print STDERR "\n";
    }
}
sub ONTsFilter {
    my $self = shift;
    my %args = (
        DEGs => {},
        NODEGs => {},
        @_
    );
    my %keep;
    my $degs = $args{DEGs};
    my $nodegs = $args{NODEGs};

    foreach my $deg (sort keys %{$degs -> {_data}}) {
        if ($self -> {_gene_to_onts} -> {$deg}) {
            foreach (sort keys %{$self -> {_gene_to_onts} -> {$deg} -> {onts}}) {
                $keep{$_} = 1;
            }
        }
    }

    foreach my $nodeg (sort keys %{$nodegs -> {_data}}) {
        if ($self -> {_gene_to_onts} -> {$nodeg}) {
            foreach (sort keys %{$self -> {_gene_to_onts} -> {$nodeg} -> {onts}}) {
                $keep{$_} = 1;
            }
        }
    }

    foreach my $ont (sort keys %{$self -> {_ids}}) {
        if (!$keep{$ont}) {
            delete($self -> {_ids} -> {$ont});
            delete($self -> {_links} -> {$ont});
            delete($self -> {_ont_to_genes} -> {$ont});
            foreach my $gene (sort keys %{$self -> {_gene_to_onts}}) {

                if ($self -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont}) {
                    delete($self -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont});
                    if (scalar keys %{$self -> {_gene_to_onts} -> {$gene} -> {onts}} == 0) {
                        delete($self -> {_gene_to_onts} -> {$gene});

                    }
                }
            }
        } else {
            foreach my $gene (sort keys %{$self -> {_ont_to_genes} -> {$ont} -> {genes}}) {

                if (!$degs -> {_data} -> {$gene} && !$nodegs -> {_data} -> {$gene}) {
                    delete($self -> {_ont_to_genes} -> {$ont} -> {genes} -> {$gene});

                }
            }
        }
    }
}

package ExpGenes;
sub new {

    my $class = shift;
    my $self = {
        #_source => "undef",
        _name => "exp",
        _loaded => 0,
        _collapsed => 0,
        _filtered => 0,
        _methylated => 0,
        @_
    };
    print STDERR $self -> {_name}."\n" if ($debug);
    bless $self, $class;
    return($self);
}
sub ExpLoader {

    my $self = shift;
    my %args = (
        _id_column => 0,
        _logfc_column => 1,
        _pvalue_column => 2,
        _methyl_column => "undef",
        @_
    );
    print STDERR "_source:".$args{_source}."\n" if ($debug);
    print STDERR "_id_column:".$args{_id_column}."\n" if ($debug);
    print STDERR "_logfc_column:".$args{_logfc_column}."\n" if ($debug);
    print STDERR "__pvalue_column:".$args{_pvalue_column}."\n" if ($debug);
    print STDERR "__methyl_column:".$args{_methyl_column}."\n" if ($debug);
    open(IN,$self -> {"_source"}) or die "Fatal: Cannot open ".$self -> {_source}."\n";
    while(<IN>) {
        chomp;
        $_ =~ s/\r//g;
        next if (
            $_ =~ /EntrezGeneID/ ||
            $_ =~ /MetaID/ ||
            $_ =~ /mirID/
        );
        my @data = split(/\t/,$_);
        my $id = $data[$args{"_id_column"}];
        my $logfc = $data[$args{"_logfc_column"}];
        my $pvalue = $data[$args{"_pvalue_column"}];
        next if ($id eq "NA");
        push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
        push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);
        if ($args{_methyl_column} ne "undef") {
            push(@{$self -> {_data} -> {$id} -> {methyls}} , $data[$args{"_methyl_column"}]);
        }
    }
    close(IN);
    return($self);
}
sub ExpLoaderFromBuffer {
    my $self = shift;
    my %args = (
        _id_column => 0,
        _logfc_column => 1,
        _pvalue_column => 2,
        _methyl_column => "undef",
        _mode_select => "id_only",
        @_
    );
    my $debug = 0;

    my @data = split(/\n/,$args{_buffer});

    shift @data;
    foreach (@data) {
        chomp;
        $_ =~ s/\r//g;
        my @entry = split(/\t/,$_);
        my $id = $entry[$args{"_id_column"} - 1];
        next if ($id eq "NA");
        $self -> {_data} -> {$id} = {};
        if ($args{_mode_select} eq "full") {
            my $logfc = $entry[$args{"_logfc_column"} - 1];
            $logfc = sprintf("%3.3f",$logfc);
            push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
        }
        if ($args{_mode_select} eq "full" || $args{_mode_select} eq "id_only") {
            my $pvalue = $entry[$args{"_pvalue_column"} - 1];
            push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);

        }

        $self -> {_loaded}++;
    }
    $debug = 0;
}
sub AppendHyperText {

    my $self = shift;

    foreach my $id (sort keys %{$self -> {_data}}) {
        $self -> {_data} -> {$id} -> {hypertext}= "https://www.ncbi.nlm.nih.gov/gene/$id";
        if ($self -> {_data} -> {$id} -> {urnas}) {
            foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                #print STDERR $id." ".$urna."\n";
                $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext} = "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt};
            }
        }
    }
}
sub ExpPrinter {

    my $self = shift;
    print STDERR "ExpPrinter Method\n";
    print STDERR $self -> {_source}."\n"  if ($debug);
    foreach my $id (sort keys %{$self -> {_data}}) {
        print STDERR $id."\n";

        if ($self -> {_data} -> {$id} -> {devs}) {
            print STDERR "logfcs:";
            foreach my $logfc (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                print STDERR " ".$logfc;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {dev}) {
            print STDERR "logfcs:";
            print STDERR " ".$self -> {_data} -> {$id} -> {dev}."\n";
        }
        if ($self -> {_data} -> {$id} -> {pvalues}) {
            print STDERR "pvalues:";
            foreach my $pvalue (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                print STDERR " ".$pvalue;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {pvalue}) {
            print STDERR "pvalues:";
            print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
        }
        if ($self -> {_data} -> {$id} -> {methyl}) {
            print STDERR "Methylation:";
            print STDERR " ".$self -> {_data} -> {$id} -> {methyl}."\n";

        }
        if ($self -> {_data} -> {$id} -> {methyls}) {
            print STDERR "Methylation:";
            foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyls}}) {
                print STDERR " ".$methyl;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {tfs}) {
            print STDERR "TFs:";
            foreach my $tf (sort keys %{$self -> {_data} -> {$id} -> {tfs}}) {
                print STDERR $tf;
                if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev}) {
                    print STDERR "\tdev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev};
                }
                if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval}) {
                    print STDERR "\tpval:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval};
                }
                print STDERR "\n";
            }
            print STDERR "\n";
        }

        print STDERR "\n";
    }

    sub pValuePrint {

        my $self = shift;

        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR "$id pvalues:";
            if ($self -> {_data} -> {$id} -> {pvalues}) {
                foreach my $pvalues (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                    print STDERR " ".$pvalues;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalue}) {
                print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
            }
        }
    }

    sub DEVPrint {

        my $self = shift;
        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR "$id logfc:";
            if ($self -> {_data} -> {$id} -> {devs}) {
                foreach my $dev (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                    print STDERR " ".$dev;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {dev}) {
                print STDERR $self -> {_data} -> {$id} -> {dev}."\n";
            }
        }
    }

    sub MethPrint {

        my $self = shift;
        foreach my $id (sort keys %{$self -> {_data}}) {

            if ($self -> {_data} -> {$id} -> {methyl}) {
                print STDERR "$id Methylation:";
                foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyl}}) {
                    print STDERR " ".$methyl;
                }
            }
            print STDERR "\n";
        }
    }

    sub LinksPrint{

        my $self = shift;

        foreach my $id (sort keys %{$self -> {_data}}) {
            if ($self -> {_data} -> {$id} -> {urnas}) {
                print STDERR $id."\n";
                foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                    print STDERR " $urna";
                }
                print STDERR "\n";
            }
        }
    }
}
sub Collapse {

    use Statistics::R;
    my $R = Statistics::R->new();
    $R->startR;
    my $self = shift;

    foreach my $id (sort keys %{$self -> {_data}}) {

    if ($self -> {_data} -> {$id} -> {pvalues}) {
        if (scalar @{$self -> {_data} -> {$id} -> {pvalues}} > 1) {
            $R->set( 'p', \@{$self -> {_data} -> {$id} -> {pvalues}});
            $R->run(q/newp<-pchisq((-2) * sum(log(p)), 2 * length(p), lower.tail = FALSE)/);
            my $newp = $R->get('newp');
            if ($newp =~ /NaN/){
                delete $self -> {_data} -> {$id};
                next;
            } else {
                delete $self -> {_data} -> {$id} -> {pvalues};
                $self -> {_data} -> {$id} -> {pvalue} = $newp;
            }
        } else {
            my $newp = shift @{$self -> {_data} -> {$id} -> {pvalues}};
            delete $self -> {_data} -> {$id} -> {pvalues};
            $self -> {_data} -> {$id} -> {pvalue} = $newp;
        }
    }

    if ($self -> {_data} -> {$id} -> {devs}) {
        if (scalar @{$self -> {_data} -> {$id} -> {devs}} > 1) {
            my $sd = 0;
            my $cd = 0;
            foreach my $v (@{$self -> {_data} -> {$id} -> {devs}}) {
                $cd++;
                $sd+= $v;
                #print STDERR "SD ".$sd." CD".$cd."\n";
            }
            my $newfc = $sd/$cd;
            delete $self -> {_data} -> {$id} -> {devs};
            $self -> {_data} -> {$id} -> {dev} = $newfc;
        } else {
            my $newfc = shift @{$self -> {_data} -> {$id} -> {devs}};
            delete $self -> {_data} -> {$id} -> {devs};
            $self -> {_data} -> {$id} -> {dev} = $newfc;
        }
    }

        if ($self -> {_data} -> {$id} -> {methyls}) {
            if (scalar @{$self -> {_data} -> {$id} -> {methyls}} > 1) {
                my $sd = 0;
                my $cd = 0;
                foreach my $v (@{$self -> {_data} -> {$id} -> {methyls}}) {
                    $cd++;
                    $sd+= $v;
                    #print STDERR "SD ".$sd." CD".$cd."\n";
                }
                my $newfc = $sd/$cd;
                delete $self -> {_data} -> {$id} -> {methyls};
                $self -> {_data} -> {$id} -> {methyl} = $newfc;
            } else {
                my $newfc = shift @{$self -> {_data} -> {$id} -> {methyls}};
                delete $self -> {_data} -> {$id} -> {methyls};
                $self -> {_data} -> {$id} -> {methyl} = $newfc;
            }
        }


        $self -> {_collapsed}++;
    }
    return($self);
}
sub Filter {

    my $self = shift;
    my %args = (

        @_
    );
    foreach my $id (sort keys %{$self -> {_data}}) {
        if ($args{_filter_select} eq "filter_full" || $args{_filter_select} eq "filter_dev") {
            #if ($args{_data_type} eq 'logFC') {
            #    if (
            #        (abs($self -> {_data} -> {$id} -> {dev}) < $args{_data_thr} && $args{_data_dir} eq 'out') ||
            #        (abs($self -> {_data} -> {$id} -> {dev}) > $args{_data_thr} && $args{_data_dir} eq 'in') ||
            #        ($self -> {_data} -> {$id} -> {dev} > $args{_data_thr} && $args{_data_dir} eq 'min') ||
            #        ($self -> {_data} -> {$id} -> {dev} < $args{_data_thr} && $args{_data_dir} eq 'maj')
            #    ) {
            #        delete $self -> {_data} -> {$id};
            #        next;
            #    }
            #}
            #if ($args{_data_type} eq 'FC') {
            #    if (
            #        (abs(log($self -> {_data} -> {$id} -> {dev})/log(2)) < log($args{_data_thr})/log(2) && $args{_data_dir} eq 'out') ||
            #        (abs(log($self -> {_data} -> {$id} -> {dev})/log(2)) > log($args{_data_thr})/log(2) && $args{_data_dir} eq 'in') ||
            #        (log($self -> {_data} -> {$id} -> {dev})/log(2) > log($args{_data_thr})/log(2) && $args{_data_dir} eq 'min') ||
            #        (log($self -> {_data} -> {$id} -> {dev})/log(2) < log($args{_data_thr})/log(2) && $args{_data_dir} eq 'maj')
            #    ) {
            #        delete $self -> {_data} -> {$id};
            #        next;
            #    }
            #}
            #if ($args{_data_type} eq 'raw') {
            #    if (
            #        (abs($self -> {_data} -> {$id} -> {dev}) < $args{_data_thr} && $args{_data_dir} eq 'out') ||
     		#		(abs($self -> {_data} -> {$id} -> {dev}) > $args{_data_thr} && $args{_data_dir} eq 'in') ||
     		#		($self -> {_data} -> {$id} -> {dev} > $args{_data_thr} && $args{_data_dir} eq 'min') ||
     		#		($self -> {_data} -> {$id} -> {dev} < $args{_data_thr} && $args{_data_dir} eq 'maj')
            #    ) {
            #        delete $self -> {_data} -> {$id};
            #        next;
            #    }
            #}
            if ($args{_LeftThreshold} && $args{_RightThreshold}) {
               if (
                    $self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold} && 
                    $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold} 
               ) {
                    delete $self -> {_data} -> {$id};
                    next;
               }
            }
            if ($args{_LeftThreshold} && !$args{_RightThreshold}) {
                if (
                    $self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold}    
                ) {
                    delete $self -> {_data} -> {$id};
                    next;
                }
            }
            if (!$args{_LeftThreshold} && $args{_RightThreshold}) {
                if (
                    $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}    
                ) {
                    delete $self -> {_data} -> {$id};
                    next;
                }
            }
        }
        if ($args{_filter_select} eq "filter_full" || $args{_filter_select} eq "filter_p") {
            if ($self -> {_data} -> {$id} -> {pvalue} > $args{_p_thr}) {
                delete $self -> {_data} -> {$id};
                next;
            }
        }
        $self -> {_filtered}++;
        
    }
    print STDERR "Filtered: ".$self -> {_filtered}."\n";
    return($self);
}
sub filterByEffectSize {
    my $self = shift;
    my %args = (
        @_
    );

    foreach my $id (sort keys %{$self -> {_data}}) {
        if ($args{_filter_select_es} eq "filter_both") {
            if ($self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold} && $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}) {
                #print STDERR "Deleted: ".$self -> {_data} -> {$id}."\n";
                delete $self -> {_data} -> {$id};
                
                next;
            }
        }
        if ($args{_filter_select_es} eq "filter_left") {
            if ($self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold}) {
                delete $self -> {_data} -> {$id};
                next;
            }
        }
        if ($args{_filter_select_es} eq "filter_right") {
            if ($self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}) {
                delete $self -> {_data} -> {$id};
                next;
            }
        }
        $self -> {_filtered}++;
    }
}
sub filterBypVal {
    my $self = shift;
    my %args = (
        @_
    );
    foreach my $id (sort keys %{$self -> {_data}}) {
        if ($self -> {_data} -> {$id} -> {pvalue} > $args{_pValThreshold}) {
            delete $self -> {_data} -> {$id};
            next;
        }
        $self -> {_filtered}++;
    }
}
sub MergeMethyls {

    my $self = shift;
    my %args = (
        Methyls => {},
        @_
    );

    my $meths = $args{Methyls};

    foreach (sort keys %{$meths -> {_data}}) {
        if ($self -> {_data} -> {$_}) {
            $self -> {_data} -> {$_} -> {methyl} = $meths -> {_data} -> {$_} -> {dev};
            delete($meths -> {_data} -> {$_});
        }
    }
}

sub checkIdForConversion {
    my $self = shift;
    my %args = (
        @_
    );
    my $db = $args{_geneDB};
    my $converted = {};

    foreach (sort keys %{$self -> {_data}}){
        #print STDERR "Found:".$_."\n";
        if ($_ =~ /^ENS/) {
            print STDERR $db -> {ensembl2entrez} -> {$_}."\n";
            if ($db -> {ensembl2entrez} -> {$_}) {
                
                my $entrez = $db -> {ensembl2entrez} -> {$_};
                #print STDERR "Converted:".$_."->"."$entrez\n";
                $converted -> {$entrez} = $self -> {_data} -> {$_};
                next;
            }
        }
        #$converted -> {$_} = $self -> {_data} -> {$_};
    }
    $self -> {_data} = $converted;
}

package ExpProteins;
our @ISA = qw(ExpGenes);
sub new {

    my $class = shift;
    my $self = {
        #_source => "undef",
        _name => "exp",
        _loaded => 0,
        _collapsed => 0,
        _filtered => 0,
        _methylated => 0,
        @_
    };
    print STDERR $self -> {_name}."\n" if ($debug);
    bless $self, $class;
    return($self);
}
sub ExpLoader {

    my $self = shift;
    my %args = (
        _id_column => 0,
        _logfc_column => 1,
        _pvalue_column => 2,
        _methyl_column => "undef",
        @_
    );
    print STDERR "_source:".$args{_source}."\n" if ($debug);
    print STDERR "_id_column:".$args{_id_column}."\n" if ($debug);
    print STDERR "_logfc_column:".$args{_logfc_column}."\n" if ($debug);
    print STDERR "__pvalue_column:".$args{_pvalue_column}."\n" if ($debug);
    print STDERR "__methyl_column:".$args{_methyl_column}."\n" if ($debug);
    open(IN,$self -> {"_source"}) or die "Fatal: Cannot open ".$self -> {_source}."\n";
    while(<IN>) {
        chomp;
        $_ =~ s/\r//g;
        next if (
            $_ =~ /EntrezGeneID/ ||
            $_ =~ /MetaID/ ||
            $_ =~ /mirID/
        );
        my @data = split(/\t/,$_);
        my $id = $data[$args{"_id_column"}];
        my $logfc = $data[$args{"_logfc_column"}];
        my $pvalue = $data[$args{"_pvalue_column"}];
        next if ($id eq "NA");
        push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
        push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);
        if ($args{_methyl_column} ne "undef") {
            push(@{$self -> {_data} -> {$id} -> {methyls}} , $data[$args{"_methyl_column"}]);
        }
    }
    close(IN);
    return($self);
}
sub ExpLoaderFromBuffer {
    my $self = shift;
    my %args = (
        _id_column => 0,
        _logfc_column => 1,
        _pvalue_column => 2,
        _methyl_column => "undef",
        _mode_select => "id_only",
        @_
    );
    my $debug = 0;
    
    my @data = split(/\n/,$args{_buffer});

    shift @data;
    foreach (@data) {
        chomp;
        $_ =~ s/\r//g;
        my @entry = split(/\t/,$_);
        my $id = $entry[$args{"_id_column"} - 1];
        next if ($id eq "NA");


        print STDERR $id."\n";
        if ($args{_mode_select} eq "full") {
            my $logfc = $entry[$args{"_logfc_column"} - 1];
            $logfc = sprintf("%3.3f",$logfc);
            push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
        }
        if ($args{_mode_select} eq "full" || $args{_mode_select} eq "id_only") {
            my $pvalue = $entry[$args{"_pvalue_column"} - 1];
            push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);

        }

        $self -> {_loaded}++;

    }
    $debug = 0;
}
sub ConvertToGenes {
    my $self = shift;
    my %args = (
        _db => "uniprot-compressed_true_download_true_fields_accession_2Cid_2Cgene_n-2022.09.05-14.07.25.80.tsv",
        @_
    );

    my $prot_db_file = $args{_db};
    print STDERR $prot_db_file."\n";

    open(IN,$prot_db_file) or die "Cannot open protein db\n";
    while(<IN>) {
        chomp;
        my ($prot_id,$entry_name,$gene_name,$prot_name,$gene_id,$organism) = split("\t",$_);
        if ($gene_id =~ /;/) {
            $gene_id =~ s/;//g; #need check for incomplete fields between proteins and genes
        } else {
            delete($self -> {_data} -> {$prot_id});
            next;
        }
        if ($self -> {_data} -> {$prot_id}) {
            print STDERR $prot_id."\t".$gene_id."\n";
            $self -> {_data} -> {$gene_id} = $self ->  {_data} -> {$prot_id};
            $self -> {_data} -> {$gene_id} -> {_prot_id} = $prot_id;
            $self -> {_data} -> {$gene_id} -> {_prot_name} = $prot_name;
            delete($self -> {_data} -> {$prot_id});
        }
    }
    close(IN);

}

sub checkIdForConversion {
    my $self = shift;
    my %args = (
        @_
    );

    my $idtype = $args{_idType};
    my $db = $args{_protDB};
    my $converted = {};
    foreach (sort keys %{$self -> {_data}}) {
        print STDERR $db -> {$idtype."2entrez"} -> {$_}."\n";
        if ($db -> {$idtype."2entrez"} -> {$_}) {
            my $entrez = $db -> {$idtype."2entrez"} -> {$_};
            $converted -> {$entrez} = $self -> {_data} -> {$_};
            $converted -> {$entrez} -> {_prot_id} = $_;
            #$converted -> {$entrez} -> {_prot_name} = $_;
            next;
        }
    }
    $self -> {_data} = $converted;
}


sub ExpPrinter {

    my $self = shift;
    print STDERR "ExpPrinter Method\n";
    print STDERR $self -> {_source}."\n"  if ($debug);
    foreach my $id (sort keys %{$self -> {_data}}) {
        print STDERR $id."\n";
        if ($self -> {_data} -> {$id} -> {_prot_id}) {
            print STDERR "protein_id: ".$self -> {_data} -> {$id} -> {_prot_id}."\n";
        }
        if ($self -> {_data} -> {$id} -> {devs}) {
            print STDERR "logfcs:";
            foreach my $logfc (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                print STDERR " ".$logfc;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {dev}) {
            print STDERR "logfcs:";
            print STDERR " ".$self -> {_data} -> {$id} -> {dev}."\n";
        }
        if ($self -> {_data} -> {$id} -> {pvalues}) {
            print STDERR "pvalues:";
            foreach my $pvalue (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                print STDERR " ".$pvalue;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {pvalue}) {
            print STDERR "pvalues:";
            print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
        }
        if ($self -> {_data} -> {$id} -> {methyl}) {
            print STDERR "Methylation:";
            print STDERR " ".$self -> {_data} -> {$id} -> {methyl}."\n";

        }
        if ($self -> {_data} -> {$id} -> {methyls}) {
            print STDERR "Methylation:";
            foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyls}}) {
                print STDERR " ".$methyl;
            }
            print STDERR "\n";
        }
        if ($self -> {_data} -> {$id} -> {tfs}) {
            print STDERR "TFs:";
            foreach my $tf (sort keys %{$self -> {_data} -> {$id} -> {tfs}}) {
                print STDERR $tf;
                if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev}) {
                    print STDERR "\tdev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev};
                }
                if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval}) {
                    print STDERR "\tpval:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval};
                }
                print STDERR "\n";
            }
            print STDERR "\n";
        }

        print STDERR "\n";
    }

    sub pValuePrint {

        my $self = shift;

        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR "$id pvalues:";
            if ($self -> {_data} -> {$id} -> {pvalues}) {
                foreach my $pvalues (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                    print STDERR " ".$pvalues;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalue}) {
                print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
            }
        }
    }

    sub DEVPrint {

        my $self = shift;
        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR "$id logfc:";
            if ($self -> {_data} -> {$id} -> {devs}) {
                foreach my $dev (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                    print STDERR " ".$dev;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {dev}) {
                print STDERR $self -> {_data} -> {$id} -> {dev}."\n";
            }
        }
    }

    sub MethPrint {

        my $self = shift;
        foreach my $id (sort keys %{$self -> {_data}}) {

            if ($self -> {_data} -> {$id} -> {methyl}) {
                print STDERR "$id Methylation:";
                foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyl}}) {
                    print STDERR " ".$methyl;
                }
            }
            print STDERR "\n";
        }
    }

    sub LinksPrint{

        my $self = shift;

        foreach my $id (sort keys %{$self -> {_data}}) {
            if ($self -> {_data} -> {$id} -> {urnas}) {
                print STDERR $id."\n";
                foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                    print STDERR " $urna";
                }
                print STDERR "\n";
            }
        }
    }
}
sub Collapse {

    use Statistics::R;
    my $R = Statistics::R->new();
    $R->startR;
    my $self = shift;

    foreach my $id (sort keys %{$self -> {_data}}) {

    if ($self -> {_data} -> {$id} -> {pvalues}) {
        if (scalar @{$self -> {_data} -> {$id} -> {pvalues}} > 1) {
            $R->set( 'p', \@{$self -> {_data} -> {$id} -> {pvalues}});
            $R->run(q/newp<-pchisq((-2) * sum(log(p)), 2 * length(p), lower.tail = FALSE)/);
            my $newp = $R->get('newp');
            if ($newp =~ /NaN/){
                delete $self -> {_data} -> {$id};
                next;
            } else {
                delete $self -> {_data} -> {$id} -> {pvalues};
                $self -> {_data} -> {$id} -> {pvalue} = $newp;
            }
        } else {
            my $newp = shift @{$self -> {_data} -> {$id} -> {pvalues}};
            delete $self -> {_data} -> {$id} -> {pvalues};
            $self -> {_data} -> {$id} -> {pvalue} = $newp;
        }
    }

    if ($self -> {_data} -> {$id} -> {devs}) {
        if (scalar @{$self -> {_data} -> {$id} -> {devs}} > 1) {
            my $sd = 0;
            my $cd = 0;
            foreach my $v (@{$self -> {_data} -> {$id} -> {devs}}) {
                $cd++;
                $sd+= $v;
                #print STDERR "SD ".$sd." CD".$cd."\n";
            }
            my $newfc = $sd/$cd;
            delete $self -> {_data} -> {$id} -> {devs};
            $self -> {_data} -> {$id} -> {dev} = $newfc;
        } else {
            my $newfc = shift @{$self -> {_data} -> {$id} -> {devs}};
            delete $self -> {_data} -> {$id} -> {devs};
            $self -> {_data} -> {$id} -> {dev} = $newfc;
        }
    }

        if ($self -> {_data} -> {$id} -> {methyls}) {
            if (scalar @{$self -> {_data} -> {$id} -> {methyls}} > 1) {
                my $sd = 0;
                my $cd = 0;
                foreach my $v (@{$self -> {_data} -> {$id} -> {methyls}}) {
                    $cd++;
                    $sd+= $v;
                    #print STDERR "SD ".$sd." CD".$cd."\n";
                }
                my $newfc = $sd/$cd;
                delete $self -> {_data} -> {$id} -> {methyls};
                $self -> {_data} -> {$id} -> {methyl} = $newfc;
            } else {
                my $newfc = shift @{$self -> {_data} -> {$id} -> {methyls}};
                delete $self -> {_data} -> {$id} -> {methyls};
                $self -> {_data} -> {$id} -> {methyl} = $newfc;
            }
        }


        $self -> {_collapsed}++;
    }
    return($self);
}
#sub Filter {

    #my $self = shift;
    #my %args = (
    #
    #    @_
    #);
    #print STDERR $args{_data_dir}."\n";
    #foreach my $id (sort keys %{$self -> {_data}}) {
    #    print STDERR $id."\n";
    #    if ($args{_filter_select} eq "filter_full" || $args{_filter_select} eq "filter_dev") {
    #        if ($args{_LeftThreshold} && $args{_RightThreshold}) {
    #           if (
    #                $self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold} && 
    #                $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold} 
    #           ) {
    #                delete $self -> {_data} -> {$id};
    #                next;
    #           }
    #        }
    #        if ($args{_LeftThreshold} && !$args{_RightThreshold}) {
    #            if (
    #                $self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold}    
    #            ) {
    #                delete $self -> {_data} -> {$id};
    #                next;
    #            }
    #        }
    #        if (!$args{_LeftThreshold} && $args{_RightThreshold}) {
    #            if (
    #                $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}    
    #            ) {
    #                delete $self -> {_data} -> {$id};
    #                next;
    #            }
    #        }
    #
    #    }
    #    if ($args{_filter_select} eq "filter_full" || $args{_filter_select} eq "filter_p") {
    #        if ($self -> {_data} -> {$id} -> {pvalue} > $args{_p_thr}) {
    #            print STDERR "Deleting $id\n";
    #            delete $self -> {_data} -> {$id};
    #            next;
    #        }
    #    }
    #    $self -> {_filtered}++;
    #}

    #return($self);
#}
sub AppendHyperText {

    my $self = shift;

    foreach my $id (sort keys %{$self -> {_data}}) {
        $self -> {_data} -> {$id} -> {hypertext}= "https://www.ncbi.nlm.nih.gov/gene/$id";
        if ($self -> {_data} -> {$id} -> {urnas}) {
            foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                #print STDERR $id." ".$urna."\n";
                $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext} = "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt};
            }
        }
    }
}
sub MergeMethyls {

    my $self = shift;
    my %args = (
        Methyls => {},
        @_
    );

    my $meths = $args{Methyls};

    foreach (sort keys %{$meths -> {_data}}) {
        if ($self -> {_data} -> {$_}) {
            $self -> {_data} -> {$_} -> {methyl} = $meths -> {_data} -> {$_} -> {dev};
            delete($meths -> {_data} -> {$_});
        }
    }
}



package ExpMetas;
our @ISA = qw(ExpGenes);
sub new {

    my $class = shift;
    my $self = {
        _source => "undef",
        _loaded => 0,
        _collapsed => 0,
        _filtered => 0,
        @_
    };
    print STDERR $self -> {_source}."\n" if ($debug);
    bless $self, $class;
    return($self);
}
sub checkIdForConversion {
    my $self = shift;
    my %args = (
        @_
    );

    my $idtype = $args{_idType};
    my $db = $args{_metaDB};
    my $converted = {};
    foreach (sort keys %{$self -> {_data}}) {
        print STDERR $db -> {$idtype."2keggcompound"} -> {$_}."\n";
        if ($db -> {$idtype."2keggcompound"} -> {$_}) {
            my $entrez = $db -> {$idtype."2keggcompound"} -> {$_};
            $converted -> {$entrez} = $self -> {_data} -> {$_};
            next;
        }
    }
    $self -> {_data} = $converted;
}
sub AppendHyperText {

    my $self = shift;
    foreach my $id (sort keys %{$self -> {_data}}) {
        $self -> {_data} -> {$id} -> {hypertext}= "https://www.kegg.jp/entry/$id";
    }
}

package ExpuRNAs;
our @ISA = qw(ExpGenes);
sub new {

    my $class = shift;
    my $self = {
        _source => "undef",
        _loaded => 0,
        _collapsed => 0,
        _filtered => 0,
        @_
    };
    print STDERR $self -> {_source}."\n" if ($debug);
    bless $self, $class;
    return($self);
}

package ExpNoDEGs;
our @ISA = qw(ExpGenes);
sub new {

    my $class = shift;
    my $self = {
        @_
    };
    print STDERR $self -> {_source}."\n" if ($debug);
    bless $self, $class;
    return($self);
}
sub NoDEGsLoader {

    my $self = shift;
    my %args = (
        uRNADB => {},
        Methyls => {},
        TFsDB => {},
        @_
    );
    my $udb = $args{uRNADB};
    my $methyls = $args{Methyls};
    my $tfsdb = $args{TFsDB};

    if (scalar keys %$udb != 0){
        foreach my $nodeg (sort keys %{$udb -> {_links} -> {nodeg2urna}}) {
            if (!$self -> {_data} -> {$nodeg}){
                $self -> {_data} -> {$nodeg} = {};
            }
        }
    }
    if (scalar keys %$methyls != 0){
        print STDERR "Checking for methylations\n";
        foreach my $nodeg (sort keys %{$methyls -> {_data}}) {
            print STDERR $nodeg."\n";
            if (!$self -> {_data} -> {$nodeg}){
                $self -> {_data} -> {$nodeg} = {};
            }
        }
    }
    if (scalar keys %$tfsdb != 0) {
        #??
    }

    return($self);
}

sub MergeMethyls {

    my $self = shift;
    my %args = (
        Methyls => {},
        @_
    );

    my $meths = $args{Methyls};

    foreach (sort keys %{$meths -> {_data}}) {
        print STDERR $_."\n";
        if ($self -> {_data} -> {$_}) {
            $self -> {_data} -> {$_} -> {methyl} = $meths -> {_data} -> {$_} -> {dev};
            delete($meths -> {_data} -> {$_});
        }
    }
}
sub CheckProteins {
    my $self = shift;
    my %args = (
        ExpProteins => {},
        @_
    );
    my $exp_prot = $args{ExpProteins};

    foreach my $gene_id (sort keys %{$exp_prot -> {_data}}) {
        #print STDERR $gene_id."\t".$exp_prot -> {_data} -> {$gene_id} -> {_prot_id}."\n";
        if ($self -> {_data} -> {$gene_id}) {
            print STDERR "FOUND SAME ID FOR: ".$gene_id."\n";
            my $prot_id = $exp_prot -> {_data} -> {$gene_id} -> {_prot_id};
            my $prot_name = $exp_prot -> {_data} -> {$gene_id} -> {_prot_name};
            my $prot_dev;
            if ($exp_prot -> {_data} -> {$gene_id} -> {dev}) {
                $prot_dev = $exp_prot -> {_data} -> {$gene_id} -> {dev};
            }
            my $prot_pval;
            if ($exp_prot -> {_data} -> {$gene_id} -> {pval}) {
                $prot_pval = $exp_prot -> {_data} -> {$gene_id} -> {pval};
            }
            $exp_prot -> {_data} -> {$gene_id} = $self -> {_data} -> {$gene_id};
            $exp_prot -> {_data} -> {$gene_id} -> {_prot_id} = $prot_id;
            $exp_prot -> {_data} -> {$gene_id} -> {_prot_name} = $prot_name;
            if ($prot_dev) {
                $exp_prot -> {_data} -> {$gene_id} -> {dev} = $prot_dev;
            }
            if ($prot_pval) {
                $exp_prot -> {_data} -> {$gene_id} -> {pvalue} = $prot_pval;
            }
            delete($self -> {_data} -> {$gene_id});
        }
    }

}
sub AppendHyperText {

    my $self = shift;

    foreach my $id (sort keys %{$self -> {_data}}) {
        $self -> {_data} -> {$id} -> {hypertext}= "https://www.ncbi.nlm.nih.gov/gene/$id";
        if ($self -> {_data} -> {$id} -> {urnas}) {
            foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext}= "https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt};
            }
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

    if ($self -> {_type} =~ /mirtarbase/) {
        print STDERR $self -> {_location}."\n";
        open(MIRTAR, $self -> {_location}) or die "miratrbase file not present\n";

        while (<MIRTAR>) {
            chomp;
            my ($mirt,$urna,$gene,$type) = split "\t", $_;
            next if (!$deus -> {_data} -> {$urna});
            next if ($self -> {_filter} eq "strongonly" && $type =~ "Weak");
            next if ($self -> {_filter} eq "weakonly" && $type =~ "Strong");
            print STDERR "$urna - $mirt\n" if ($debug);
            if ($degs -> {_data} -> {$gene}) {
                $self -> {_links} -> {urna2deg} -> {$urna} -> {$gene} = 1;
                #$self -> {_links} -> {mirt2deg} -> {$mirt} -> {$gene} = 1;
                $self -> {_links} -> {deg2urna} -> {$gene} -> {$urna} = 1;
                #$self -> {_links} -> {deg2mirt} -> {$gene} -> {$mirt} = 1;
                $self -> {_links} -> {mirt2deg} -> {$mirt}  = $gene;
                $self -> {_links} -> {deg2mirt} -> {$gene} -> {$urna} = $mirt;
                print STDERR " DEG $gene FOUND\n" if ($debug);
            }
            if ($deps -> {_data} -> {$gene}) {
                $self -> {_links} -> {urna2prot} -> {$urna} -> {$gene} = 1;
                #$self -> {_links} -> {mirt2deg} -> {$mirt} -> {$gene} = 1;
                $self -> {_links} -> {prot2urna} -> {$gene} -> {$urna} = 1;
                #$self -> {_links} -> {deg2mirt} -> {$gene} -> {$mirt} = 1;
                $self -> {_links} -> {mirt2prot} -> {$mirt}  = $gene;
                $self -> {_links} -> {prot2mirt} -> {$gene} -> {$urna} = $mirt;
                print STDERR " PROT ".($deps -> {_data} -> {$gene} -> {_prot_id})." ($gene) FOUND\n" if ($debug);
            }
            if (!$degs -> {_data} -> {$gene} && !$deps -> {_data} -> {$gene}) {
                $self -> {_links} -> {urna2nodeg} -> {$urna} -> {$gene} = 1;
                $self -> {_links} -> {nodeg2urna} -> {$gene} -> {$urna} = 1;
                $self -> {_links} -> {mirt2nodeg} -> {$mirt}  = $gene;
                $self -> {_links} -> {nodeg2mirt} -> {$gene} -> {$urna} = $mirt;

                print STDERR " NODEG $gene - FOUND\n" if ($debug);
            }
        }
        close MIRTAR;
    }
    return($self);
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
    
    my $self = shift;

    open(DB,$self -> {_source}) or die "Cannot open: ".$self -> {_source}."\n";
    while(<DB>) {
        chomp;
        next if ($_ =~ /^Entry/);
        my @data = split("\t",$_);
        my $entrez = $data[4];
        my $symbol = $data[3];
        my $entry = $data[0];


        my @entrezs = split(/;/,$entrez);
        next if(scalar @entrezs > 1);
        my @symbols = split(/ /,$symbol);

        $entrez =~ s/;$//;

        $self -> {entrez2entry} -> {$entrez} = $entry;
        $self -> {entry2entrez} -> {$entry} = $entrez;
        foreach (@symbols) {
            $self -> {symbol2entrez} -> {$_} = $entrez;
            $self -> {symbol2entry} -> {$_} = $entry;
            $self -> {entrez2symbol} -> {$entrez} -> {$symbol} = 1;
            $self -> {entry2symbol} -> {$entry} -> {$symbol} = 1;
        }
        
    }
    close(DB);
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


package Complex;
sub new {

    my $class = shift;
    my $self = {
        _id => "undef",
        _type => "undef",
        _coordinates => "undef",
        _legend_for_plot => "",
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
sub InitLegends {
    my $self = shift;
    my %args = (
        MapName => "",
        @_
    );
    my $map_name = $args{MapName};
    #$self -> {_legend_for_plot} = "pathlayplot.pl?source=$args{MapName} %0A";
    $self -> {_legend_for_plot} = "pathlayplot.pl?source=%0Amap_name:$map_name%0A";
}
sub ComplexLoader {

    my $self = shift;
    my %args = (
        _ids => {},
        _data => {},
        _mode => "id_only",
        @_
    );
    my $ids  = $args{_ids};
    my $data = $args{_data};
    my $nodes = $args{_nodes};
    my $multis = $args{_multi_available};
    my $mode = $args{_mode};
    #use Data::Dumper;
    #print STDERR Dumper $nodes;
    $self -> {_legend_for_plot} .= "mode:$mode%0A";

    #self -> {_type} contains type for the complex: deg nodeg prot meta multi
    #data -> {id} -> {type} contains type for element in the complex: deg nodeg prot meta


    foreach my $id (sort keys %$ids) {#coordinates db dev name type urnas
        #print STDERR  "$id \n";
            #print STDERR "$id -> ".$self -> {_type}." -> ".$multis -> {$id}."\n";
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
            print STDERR "$id -> ".$self -> {_coordinates} -> {x}.",".$self -> {_coordinates} -> {y}."\n";
            $self -> {_data} -> {$id} -> {name} = $data -> {$id} -> {name};
            #!# $self -> {_legend_for_plot} .= $id."(".$data -> {$id} -> {name}.")";
            #$self -> {_legend_for_plot} .= $data -> {$id} -> {type}.": ".$id." ".$data -> {$id} -> {name};

            if ($self -> {_type} eq "multi") {
                if ($data -> {$id} -> {type} eq "prot") {
                    $self -> {_legend_for_plot} .= "type:".$data -> {$id} -> {type}."|id:".$data -> {$id} -> {prot_id}."|name:".$id;
                    $self -> {_legend_for_title} .= $data -> {$id} -> {type}.":".$data -> {$id} -> {prot_id}."(".$id.")";
                }

                if ($data -> {$id} -> {type} eq "deg" || $data -> {$id} -> {type} eq "nodeg" || $data -> {$id} -> {type} eq "meta") {
                    $self -> {_legend_for_plot} .= "type:".$data -> {$id} -> {type}."|id:".$id."|name:".$data -> {$id} -> {name};
                    $self -> {_legend_for_title} .= $data -> {$id} -> {type}.": $id (".$self -> {_data} -> {$id} -> {name}.")"; #Gene: $id ($name) $data_type: $data_value\n
                    #$self -> {_legend_for_title} .= $self -> {_type}.": $id (".$self -> {_data} -> {$id} -> {name}.")"; #Gene: $id ($name) $data_type: $data_value\n
                }

                if ($data -> {$id} -> {type} eq "deg+prot") {
                    $self -> {_legend_for_plot} .= "type:deg"."|id:".$id."|name:".$data -> {$id} -> {name};
                    $self -> {_legend_for_title} .= "deg: $id (".$self -> {_data} -> {$id} -> {name}.")";
                    if ($data -> {$id} -> {dev_gene}) {
                        #print STDERR $data -> {$id} -> {dev}." ";
                        $self -> {_data} -> {$id} -> {dev_gene} = $data -> {$id} -> {dev_gene};
                        #$self -> {_legend_for_plot} .= " logFC:".$self -> {_data} -> {$id} -> {dev};
                        $self -> {_legend_for_plot} .= "|dev:".$self -> {_data} -> {$id} -> {dev_gene};
                        $self -> {_legend_for_title} .= " logFC:".$self -> {_data} -> {$id} -> {dev_gene};
                    }  else {
                        $self -> {_legend_for_plot} =~ s/ $/%0A/;
                    }
                    if ($data -> {$id} -> {methyl}) {
                        $self -> {_data} -> {$id} -> {methyl} = $data -> {$id} -> {methyl};
                        #$self -> {_legend_for_plot} .= " Methylation:".$self -> {_data} -> {$id} -> {methyl}."%0A";
                        $self -> {_legend_for_plot} .= "|meth:".$self -> {_data} -> {$id} -> {methyl}."%0A";
                        $self -> {_legend_for_title} .= " Methylation:".$self -> {_data} -> {$id} -> {methyl}."\n";
                    } else {
                        $self -> {_legend_for_title} .= "\n";
                        $self -> {_legend_for_plot} .= "%0A";
                    }

                    # continue here
                    $self -> {_legend_for_plot} .= "type:prot"."|id:".$data -> {$id} -> {prot_id}."|name:".$id;
                    $self -> {_legend_for_title} .= "prot:".$data -> {$id} -> {prot_id}."(".$id.")";
                    if ($data -> {$id} -> {dev_prot}) {
                        #print STDERR $data -> {$id} -> {dev}." ";
                        $self -> {_data} -> {$id} -> {dev_prot} = $data -> {$id} -> {dev_prot};
                        #$self -> {_legend_for_plot} .= " logFC:".$self -> {_data} -> {$id} -> {dev};
                        $self -> {_legend_for_plot} .= "|dev:".$self -> {_data} -> {$id} -> {dev_prot}."%0A";
                        $self -> {_legend_for_title} .= " logFC:".$self -> {_data} -> {$id} -> {dev_prot};
                    }
                    $self -> {_legend_for_plot} =~ s/ $/%0A/;
                    $self -> {_legend_for_title} .= "\n";

                    if ($data -> {$id} -> {tfs}) {
                        #print STDERR "TF Found\n";
                        foreach my $tf_id (sort keys %{$data -> {$id} -> {tfs}}){
                            #print STDERR "$tf_id";
                            $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev} = $data -> {$id} -> {tfs} -> {$tf_id} -> {dev};
                            $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name} =  $data -> {$id} -> {tfs} -> {$tf_id} -> {name};
                            #$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {link} =  $data -> {$id} -> {tfs} -> {$tf_id} -> {link};
                            $self -> {_legend_for_plot} .= "type:tf|id:".$tf_id."|name:".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name}."|dev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev}."%0A";
                            $self -> {_legend_for_title} .= "\tTranscriptional Factor: $tf_id(".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name}.") logFC: ".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev}."\n";
                            #print STDERR $self -> {_legend_for_plot}."\n";
                            #HERE#
                        }
                    }
                    if ($data -> {$id} -> {urnas}) {
                        foreach my $urna (sort keys %{$data -> {$id} -> {urnas}}) {
                            #print STDERR " ".$urna." ".$data -> {$id} -> {urnas} -> {$urna} -> {dev}."\n";
                            $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev} = $data -> {$id} -> {urnas} -> {$urna} -> {dev};
                            $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext} = $data -> {$id} -> {urnas} -> {$urna} -> {hypertext};
                            $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt} = $data -> {$id} -> {urnas} -> {$urna} -> {mirt};
                            #$self -> {_legend_for_plot} .= "\tmiRNA: $urna ".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}." logFC:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."%0A";
                            $self -> {_legend_for_plot} .= "type:urna|id:".$urna."|mirt:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}."|dev:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."%0A";
                            $self -> {_legend_for_title} .= "\tmiRNA: $urna(".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}.") logFC: ".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."\n";
                            #print STDERR $data -> {$id} -> {urnas} -> {$urna} -> {hypertext}."\n";
                        }
                    }
                    next;
                }

            }

            if ($self -> {_type} eq "prot") {
                $self -> {_legend_for_plot} .= "type:".$data -> {$id} -> {type}."|id:".$data -> {$id} -> {prot_id}."|name:".$id;
                $self -> {_legend_for_title} .= $data -> {$id} -> {type}.":".$data -> {$id} -> {prot_id}."(".$id.")";
            }

            if ($self -> {_type} eq "deg" || $self -> {_type} eq "nodeg" || $self -> {_type} eq "meta") {
                $self -> {_legend_for_plot} .= "type:".$data -> {$id} -> {type}."|id:".$id."|name:".$data -> {$id} -> {name};
                $self -> {_legend_for_title} .= $data -> {$id} -> {type}.": $id (".$self -> {_data} -> {$id} -> {name}.")"; #Gene: $id ($name) $data_type: $data_value\n
                #$self -> {_legend_for_title} .= $self -> {_type}.": $id (".$self -> {_data} -> {$id} -> {name}.")"; #Gene: $id ($name) $data_type: $data_value\n
            }


            # legend for title CHANGE HERE!#
            #$self -> {_legend_for_title} = ;
            #if ($data -> {$id} -> {type} eq "nodeg") {
            #    print STDERR "NODEG LEGEND: ".$self -> {_legend_for_plot}."\n";
            #}
            if ($data -> {$id} -> {dev}) {
                #print STDERR $data -> {$id} -> {dev}." ";
                $self -> {_data} -> {$id} -> {dev} = $data -> {$id} -> {dev};
                #$self -> {_legend_for_plot} .= " logFC:".$self -> {_data} -> {$id} -> {dev};
                $self -> {_legend_for_plot} .= "|dev:".$self -> {_data} -> {$id} -> {dev};
                $self -> {_legend_for_title} .= " logFC:".$self -> {_data} -> {$id} -> {dev};
            } else {
                $self -> {_legend_for_plot} =~ s/ $/%0A/;
            }
            if ($data -> {$id} -> {methyl}) {
                $self -> {_data} -> {$id} -> {methyl} = $data -> {$id} -> {methyl};
                #$self -> {_legend_for_plot} .= " Methylation:".$self -> {_data} -> {$id} -> {methyl}."%0A";
                $self -> {_legend_for_plot} .= "|meth:".$self -> {_data} -> {$id} -> {methyl}."%0A";
                $self -> {_legend_for_title} .= " Methylation:".$self -> {_data} -> {$id} -> {methyl}."\n";
            } else {
                $self -> {_legend_for_title} .= "\n";
                $self -> {_legend_for_plot} .= "%0A";
            }
            if ($data -> {$id} -> {prot_id}) {
                $self -> {_data} -> {$id} -> {prot_id} = $data -> {$id} -> {prot_id};
            }
            if ($data -> {$id} -> {prot_name}) {
                $self -> {_data} -> {$id} -> {prot_name} = $data -> {$id} -> {prot_name};
            }
            $self -> {_legend_for_plot} .= "%0A";
            if ($data -> {$id} -> {tfs}) {
                #print STDERR "TF Found\n";
                foreach my $tf_id (sort keys %{$data -> {$id} -> {tfs}}){
                    #print STDERR "$tf_id";
                    $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev} = $data -> {$id} -> {tfs} -> {$tf_id} -> {dev};
                    $self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name} =  $data -> {$id} -> {tfs} -> {$tf_id} -> {name};
                    #$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {link} =  $data -> {$id} -> {tfs} -> {$tf_id} -> {link};
                    $self -> {_legend_for_plot} .= "type:tf|id:".$tf_id."|name:".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name}."|dev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev}."%0A";
                    $self -> {_legend_for_title} .= "\tTranscriptional Factor: $tf_id(".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {name}.") logFC: ".$self -> {_data} -> {$id} -> {tfs} -> {$tf_id} -> {dev}."\n";
                    #print STDERR $self -> {_legend_for_plot}."\n";
                    #HERE#
                }
            }
            $self -> {_data} -> {$id} -> {hypertext} = $data -> {$id} -> {hypertext};
            #print STDERR $self -> {_data} -> {$id} -> {hypertext}."\n";
            #print STDERR "\n";
            if ($data -> {$id} -> {urnas}) {
                foreach my $urna (sort keys %{$data -> {$id} -> {urnas}}) {
                    #print STDERR " ".$urna." ".$data -> {$id} -> {urnas} -> {$urna} -> {dev}."\n";
                    $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev} = $data -> {$id} -> {urnas} -> {$urna} -> {dev};
                    $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext} = $data -> {$id} -> {urnas} -> {$urna} -> {hypertext};
                    $self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt} = $data -> {$id} -> {urnas} -> {$urna} -> {mirt};
                    #$self -> {_legend_for_plot} .= "\tmiRNA: $urna ".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}." logFC:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."%0A";
                    $self -> {_legend_for_plot} .= "type:urna|id:".$urna."|mirt:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}."|dev:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."%0A";
                    $self -> {_legend_for_title} .= "\tmiRNA: $urna(".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {mirt}.") logFC: ".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}."\n";
                    #print STDERR $data -> {$id} -> {urnas} -> {$urna} -> {hypertext}."\n";
                }
            }

    }
    if ($self -> {_type} eq "multi") {
        print STDERR "Legend for multi: ".$self -> {_legend_for_title}."\n";
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
        print STDERR $id." LINK:".$self -> {_data} -> {$id} -> {hypertext};
        if ($self -> {_data} -> {$id} -> {dev}) {
            print STDERR " DEV:".$self -> {_data} -> {$id} -> {dev};
        }
        if ($self -> {_data} -> {$id} -> {methyl}) {
            print STDERR " METH:".$self -> {_data} -> {$id} -> {methyl};
        }
        print STDERR "\n";
        if ($self -> {_data} -> {$id} -> {urnas}) {
            foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                print STDERR " ".$urna." DEV:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {dev}." LINK:".$self -> {_data} -> {$id} -> {urnas} -> {$urna} -> {hypertext}."\n";
            }
        }
    }
    print STDERR "#\n";
}

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
    print STDERR $self -> {_source}."\n" if ($debug);
    bless $self, $class;
    return($self);
}
sub PathwayLoader {

    my $self = shift;
    my %args = (
        ExpGenes  => {},
        ExpNoDEGs => {},
        ExpuRNAs  => {},
        ExpMetas  => {},
        Params => {},
        @_
    );

    my $parameters = $args{Params};
    my $degs    = {};
    my $nodegs  = {};
    my $deus    = {};
    my $dems    = {};
    my $meths   = {};
    my $proteins = {};
    my %seen_degs;
    my %seen_nodegs;
    my %seen_proteins;
    my %seen_methyls;
    my %seen_urnas;
    my %seen_metas;


    if ($parameters -> {_enablegene}) {
        $degs   = $args{ExpGenes};
    }
    if ($parameters -> {_enableprot}) {
        $proteins = $args{ExpProteins};
    }
    if ($parameters -> {_enableurna}) {
        $nodegs = $args{ExpNoDEGs};
        $deus   = $args{ExpuRNAs};
    }
    if ($parameters -> {_enabletfs}) {
        $nodegs = $args{ExpNoDEGs};
    }
    if ($parameters -> {_enablemeth}) {
        $nodegs = $args{ExpNoDEGs};
        $meths = $args{ExpMeths};
    }
    if ($parameters -> {_enablemeta}) {
        $dems   = $args{ExpMetas};
    }

    my $debug = 1;

    open(IN,$self -> {_source});
    chomp(my @nodes = <IN>);
    close(IN);
    shift @nodes;
    ($self -> {_name},$self -> {_organism},$self -> {_db},$self -> {_id}) = split(/\t/,shift(@nodes));
    foreach (sort @nodes) {
        my ($node_name,$node_type,$node_db,$node_id,@coords) = split(/\t/,$_);
        if (
            $degs -> {_data} -> {$node_id} ||
            $nodegs -> {_data} -> {$node_id} ||
            $deus -> {_data} -> {$node_id} ||
            $dems -> {_data} -> {$node_id} ||
            $proteins -> {_data} -> {$node_id}
        ) {
            $self -> {_data} -> {$node_id} -> {name} = $node_name;
            $self -> {_data} -> {$node_id} -> {db} = $node_db;
            if ($dems -> {_data} -> {$node_id}) {
                $self -> {_data} -> {$node_id} -> {type} = "meta";
                $self -> {_data} -> {$node_id} -> {dev} = $dems -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext} = $dems -> {_data} -> {$node_id} -> {hypertext};
                $seen_metas{$node_id} = 1;
            }
            if ($degs -> {_data} -> {$node_id}) {
                #print STDERR $node_id."\n";
                $self -> {_data} -> {$node_id} -> {type} = "deg";
                $self -> {_data} -> {$node_id} -> {dev} = $degs -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext} = $degs -> {_data} -> {$node_id} -> {hypertext};
                $seen_degs{$node_id} = 1;
                if ($degs -> {_data} -> {$node_id} -> {urnas}) {
                    %{$self -> {_data} -> {$node_id} -> {urnas}} = %{$degs -> {_data} -> {$node_id} -> {urnas}}; #this includes mirt
                    foreach (keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
                        $seen_urnas{$_} = 1;
                    }
                }
                if ($degs -> {_data} -> {$node_id} -> {methyl}) {
                    $self -> {_data} -> {$node_id} -> {methyl} = $degs -> {_data} -> {$node_id} -> {methyl};
                    $seen_methyls{$node_id} = 1;
                }
                if ($degs -> {_data} -> {$node_id} -> {tfs}) {
                    foreach my $tf_id (sort keys %{$degs -> {_data} -> {$node_id} -> {tfs}}) {
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} = {};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev} = $degs -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name} = $degs -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name};
                    }
                }

            }
            if ($nodegs -> {_data} -> {$node_id}) {
                $self -> {_data} -> {$node_id} -> {type} = "nodeg";
                $self -> {_data} -> {$node_id} -> {dev} = $nodegs -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext} = $nodegs -> {_data} -> {$node_id} -> {hypertext};
                $seen_nodegs{$node_id} = 1;
                if ($nodegs -> {_data} -> {$node_id} -> {urnas}) {
                    %{$self -> {_data} -> {$node_id} -> {urnas}} = %{$nodegs -> {_data} -> {$node_id} -> {urnas}};
                    foreach (keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
                        $seen_urnas{$_} = 1;
                    }
                }
                if ($nodegs -> {_data} -> {$node_id} -> {methyl}) {
                    $self -> {_data} -> {$node_id} -> {methyl} = $nodegs -> {_data} -> {$node_id} -> {methyl};
                    $seen_methyls{$node_id} = 1;
                }
                if ($nodegs -> {_data} -> {$node_id} -> {tfs}) {
                    $self -> {_data} -> {$node_id} -> {tfs} = $nodegs -> {_data} -> {$node_id} -> {tfs};
                }
            }
            if ($proteins -> {_data} -> {$node_id}) {
                $self -> {_data} -> {$node_id} -> {type} = "prot";
                $self -> {_data} -> {$node_id} -> {dev} = $proteins -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext} = $proteins -> {_data} -> {$node_id} -> {hypertext};
                $self -> {_data} -> {$node_id} -> {prot_id} =  $proteins -> {_data} -> {$node_id} -> {_prot_id};
                $self -> {_data} -> {$node_id} -> {prot_name} =  $proteins -> {_data} -> {$node_id} -> {_prot_name};
                $seen_proteins{$node_id} = 1;
                if ($proteins -> {_data} -> {$node_id} -> {urnas}){
                    %{$self -> {_data} -> {$node_id} -> {urnas}} = %{$proteins -> {_data} -> {$node_id} -> {urnas}}; #this includes mirt
                    foreach (keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
                        $seen_urnas{$_} = 1;
                    }
                }
                if ($proteins -> {_data} -> {$node_id} -> {methyl}){
                    $self -> {_data} -> {$node_id} -> {methyl} = $proteins -> {_data} -> {$node_id} -> {methyl};
                    $seen_methyls{$node_id} = 1;
                }
                if ($proteins -> {_data} -> {$node_id} -> {tfs}){
                    foreach my $tf_id (sort keys %{$proteins -> {_data} -> {$node_id} -> {tfs}}) {
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} = {};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev} = $proteins -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name} = $proteins -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name};
                    }
                }
            }
            if ($degs -> {_data} -> {$node_id} && $proteins -> {_data} -> {$node_id}) {
                $self -> {_data} -> {$node_id} -> {type} = "deg+prot";
                $self -> {_data} -> {$node_id} -> {dev_prot} = $proteins -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext_prot} = $proteins -> {_data} -> {$node_id} -> {hypertext};
                $self -> {_data} -> {$node_id} -> {prot_id} =  $proteins -> {_data} -> {$node_id} -> {_prot_id};
                $self -> {_data} -> {$node_id} -> {prot_name} =  $proteins -> {_data} -> {$node_id} -> {_prot_name};
                $self -> {_data} -> {$node_id} -> {dev_gene} = $degs -> {_data} -> {$node_id} -> {dev};
                $self -> {_data} -> {$node_id} -> {hypertext_gene} = $degs -> {_data} -> {$node_id} -> {hypertext};

                if ($degs -> {_data} -> {$node_id} -> {urnas}) {
                    %{$self -> {_data} -> {$node_id} -> {urnas}} = %{$degs -> {_data} -> {$node_id} -> {urnas}}; #this includes mirt
                    foreach (keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
                        $seen_urnas{$_} = 1;
                    }
                }
                if ($degs -> {_data} -> {$node_id} -> {methyl}) {
                    $self -> {_data} -> {$node_id} -> {methyl} = $degs -> {_data} -> {$node_id} -> {methyl};
                    $seen_methyls{$node_id} = 1;
                }
                if ($degs -> {_data} -> {$node_id} -> {tfs}) {
                    foreach my $tf_id (sort keys %{$degs -> {_data} -> {$node_id} -> {tfs}}) {
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} = {};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev} = $degs -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {dev};
                        $self -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name} = $degs -> {_data} -> {$node_id} -> {tfs} -> {$tf_id} -> {name};
                    }
                }

                $seen_degs{$node_id} = 1;
                $seen_proteins{$node_id} = 1;
            }

            @{$self -> {_data} -> {$node_id} -> {coordinates}} = @coords;
            print STDERR "FOUND $node_id id at ".$self -> {_id}."\n" if ($debug);
        }
    }
    $self -> {_degs_loaded} = scalar keys %seen_degs;
    $self -> {_nodegs_loaded} = scalar keys %seen_nodegs;
    $self -> {_urnas_loaded} = scalar keys %seen_urnas;
    $self -> {_metas_loaded} = scalar keys %seen_metas;
    $self -> {_methyls_loaded} = scalar keys %seen_methyls;
    $self -> {_proteins_loaded} = scalar keys %seen_proteins;
    $debug = 0;


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

                print STDERR "check for mix: mixing at $coord:\n";
                print STDERR "check for mix: deg:\n";
                foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
                    $self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
                    $self -> {_multi_available} -> {$deg} = 1;
                    print STDERR "\t$deg";
                }
                print STDERR "\n";
                print STDERR "check for mix: nodeg:\n";
                foreach my $nodeg (sort keys %{$self -> {_nodes} -> {nodeg} -> {$coord}}) {
                    $self -> {_nodes} -> {multi} -> {$coord} -> {$nodeg} = 1;
                    $self -> {_multi_available} -> {$nodeg} = 1;
                    print STDERR "\t$nodeg";
                }
                print STDERR "\n";
            }

            ##test
            if (${$check_for_mix{$coord}}{nodeg} && ${$check_for_mix{$coord}}{prot}) {

                print STDERR "check for mix: mixing at $coord:\n";
                print STDERR "check for mix: prot:\n";
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

                print STDERR "check for mix: mixing at $coord:\n";
                print STDERR "check for mix: prot:\n";
                foreach my $prot (sort keys %{$self -> {_nodes} -> {prot} -> {$coord}}) {
                    $self -> {_nodes} -> {multi} -> {$coord} -> {$prot} = 1;
                    $self -> {_multi_available} -> {$prot} = 1;
                    print STDERR "\t$prot";
                    print STDERR "\n";
                    print STDERR "check for mix: deg:\n";
                    foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
                        $self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
                        $self -> {_multi_available} -> {$deg} = 1;
                        print STDERR "\t$deg";
                    }
                    print STDERR "\n";
                }
            }

            ###
        }

        return($self);
    }
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
        if ($self -> {_data} -> {$node_id} -> {methyl}) {
            print STDERR " Meth:".$self -> {_data} -> {$node_id} -> {methyl};
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
    my @meta_complexes;

    my $count = 1;
    my $parameters = $args{Parameters};


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
                OffSetY => 25,
                Pathway => $self
            );
        } else {
            $complex -> CoordinatesTrimmer(
                OffSetX => 25,
                OffSetY => 25,
                Pathway => $self
            );
        }
        $complex -> InitLegends(
            MapName => $self -> {_name}
        );
        $complex -> (
            _ids => $self -> {_nodes} -> {deg} -> {$coord},
            _data => $self -> {_data},
            _mode => $parameters -> {_mode_select}
        );

        push (@deg_complexes,$complex);
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
                OffSetY => 25,
                Pathway => $self
            );
        } else {
            $complex -> CoordinatesTrimmer(
                OffSetX => 25,
                OffSetY => 25,
                Pathway => $self
            );
        }
        $complex -> InitLegends(
            MapName => $self -> {_name}
        );
        $complex -> (
            _ids => $self -> {_nodes} -> {nodeg} -> {$coord},
            _data => $self -> {_data},
            _mode => $parameters -> {_mode_select}
        );
        push (@nodeg_complexes,$complex);
        #push (@gene_complexes,$complex);
        $count++;
    }
    foreach my $coord (sort keys %{$self -> {_nodes} -> {meta}}) {
        #print STDERR "COMPLEX: ".$self -> {_id}."_$count"."\n";
        #print STDERR "TYPE: meta\n";
        #print STDERR "COORDINATES: ".$coord."\n";
        my $complex = new Complex(
            _id => $self -> {_id}."_$count",
            _coordinates => $coord,
            _type => "meta",
            _index => $self -> {_index}
        );
        $complex -> CoordinatesTrimmer(
            OffSetX => 25,
            OffSetY => 25,
            Pathway => $self
        );
        $complex -> InitLegends(
            MapName => $self -> {_name}
        );
        $complex -> (
            _ids => $self -> {_nodes} -> {meta} -> {$coord},
            _data => $self -> {_data},
            _mode => $parameters -> {_mode_select}
        );
        push (@meta_complexes,$complex);
        $count++;
    }
    #print STDERR "COMPLEXES ON ".$self -> {_id}.": ".(scalar @deg_complexes + scalar @nodeg_complexes + scalar @meta_complexes)."\n";
    #print STDERR " DEG: ".(scalar @deg_complexes)."\n"." NODEG: ".(scalar @nodeg_complexes)."\n"." META: ".(scalar @meta_complexes)."\n";

    @{$self -> {_complexes} -> {deg}}   = @deg_complexes;
    @{$self -> {_complexes} -> {nodeg}} = @nodeg_complexes;
    @{$self -> {_complexes} -> {meta}}  = @meta_complexes;

}

sub LoadComplexes_test {

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
                MapName => $self -> {_name}
            );
            $complex -> ComplexLoader(
                _ids => $self -> {_nodes} -> {multi} -> {$coord},
                _data => $self -> {_data},
                _nodes => $self -> {_nodes},
                _multi_available => $self -> {_multi_available},
                _mode => $parameters -> {_mode_select}
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
                MapName => $self -> {_name}
            );
            $complex -> ComplexLoader(
                _ids => $self -> {_nodes} -> {deg} -> {$coord},
                _data => $self -> {_data},
                _nodes => $self -> {_nodes},
                _multi_available => $self -> {_multi_available},
                _mode => $parameters -> {_mode_select}
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
                MapName => $self -> {_name}
            );
            $complex -> ComplexLoader(
                _ids => $self -> {_nodes} -> {prot} -> {$coord},
                _data => $self -> {_data},
                _nodes => $self -> {_nodes},
                _multi_available => $self -> {_multi_available},
                _mode => $parameters -> {_mode_select}
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
                MapName => $self -> {_name}
            );
            $complex -> ComplexLoader(
                _ids => $self -> {_nodes} -> {nodeg} -> {$coord},
                _data => $self -> {_data},
                _nodes => $self -> {_nodes},
                _multi_available => $self -> {_multi_available},
                _mode => $parameters -> {_mode_select}
            );
            next if ($complex -> {_purge});
            push (@nodeg_complexes,$complex);
            #push (@gene_complexes,$complex);
            $count++;
        }
        foreach my $coord (sort keys %{$self -> {_nodes} -> {meta}}) {
            #print STDERR "COMPLEX: ".$self -> {_id}."_$count"."\n";
            #print STDERR "TYPE: meta\n";
            #print STDERR "COORDINATES: ".$coord."\n";
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
                MapName => $self -> {_name}
            );
            $complex -> ComplexLoader(
                _ids => $self -> {_nodes} -> {meta} -> {$coord},
                _data => $self -> {_data},
                _nodes => $self -> {_nodes},
                _multi_available => $self -> {_multi_available},
                _mode => $parameters -> {_mode_select}
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

package PreSelector;
sub new {

    my $class = shift;
    my $self = {
        _id => "undefined",
        _content_type => "undefined",
        _data => {},
        @_
    };
    bless $self, $class;
    return($self);
}
sub UpdatePreSelector {

    my $self = shift;
    my %args = (
        Complexes => {},
        DEGs => 0,
        Proteins => 0,
        NoDEGs => 0,
        uRNAs => 0,
        Metas => 0,
        TFs => 0,
        @_
    );
    my $type;
    my $reverse_text = 1;
    if ($args{DEGs} == 1) {
        $type = "deg";
    }
    if ($args{NoDEGs} == 1) {
        $type = "nodeg";
    }
    if ($args{Metas} == 1) {
        $type = "meta";
    }
    if ($args{uRNAs} == 1) {
        $type = "urnas";
    }
    if ($args{TFs} == 1) {
        $type = "tfs";
    }
    if ($args{Proteins} == 1) {
        $type = "prot";
    }


    if ($type eq "deg" || $type eq "nodeg" || $type eq "meta") {
        foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
            #print STDERR $complex -> {_id}."\n";
            #print STDERR $complex -> {_type}."\n";
            foreach my $id (sort keys %{$complex -> {_data}}) {
                #$self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                #print STDERR $complex -> {_data} -> {$id} -> {name}."\n";
                if (!$reverse_text){
                    $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    $self -> {_data} -> {$id} -> {text} = "$id (".$self -> {_data} -> {$id} -> {name}.")";
                    my $option = new HTMLSelectOption (
                        _value => $id,
                        _text => $self -> {_data} -> {$id} -> {text}
                    );
                    $self -> {_data} -> {$id} -> {option} = $option;
                } else {
                    $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    $self -> {_data} -> {$id} -> {text} = $self -> {_data} -> {$id} -> {name}." ($id)";
                    my $option = new HTMLSelectOption (
                        _value => $id,
                        _text => $self -> {_data} -> {$id} -> {text}
                    );
                    $self -> {_data} -> {$id} -> {option} = $option;
                }
            }
        }
        if ($type eq "nodeg") {
            foreach my $complex (sort @{$args{Complexes} -> {multi}}) {
                foreach my $id (sort keys %{$complex -> {_data}}) {
                    #$self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    #print STDERR $complex -> {_data} -> {$id} -> {name}."\n";
                    if (!$reverse_text){
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        $self -> {_data} -> {$id} -> {text} = "$id (".$self -> {_data} -> {$id} -> {name}.")";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    } else {
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        $self -> {_data} -> {$id} -> {text} = $self -> {_data} -> {$id} -> {name}." ($id)";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
    }
    if ($type eq "prot") {
        foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
            foreach my $id (sort keys %{$complex -> {_data}}) {
                if (!$reverse_text){
                    $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {prot_id}." (".$complex -> {_data} -> {$id} -> {name}.")";
                    my $option = new HTMLSelectOption (
                        _value => $id,
                        _text => $self -> {_data} -> {$id} -> {text}
                    );
                    $self -> {_data} -> {$id} -> {option} = $option;
                } else {
                    $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    #$self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {name}." (".$complex -> {_data} -> {$id} -> {prot_id}.")";
                    $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {name}." (".$id.")";
                    my $option = new HTMLSelectOption (
                        _value => $id,
                        _text => $self -> {_data} -> {$id} -> {text}
                    );
                    $self -> {_data} -> {$id} -> {option} = $option;
                }
            }
        }
    }
    if ($type eq "urnas") {
        foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
            #print STDERR $complex -> {_id}."\n";
            #print STDERR $complex -> {_type}."\n";
            foreach my $gene (sort keys %{$complex -> {_data}}) {
                if ($complex -> {_data} -> {$gene} -> {urnas}) {
                    foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                        $self -> {_data} -> {$id} -> {text} = "$id";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
        foreach my $complex (sort @{$args{Complexes} -> {nodeg}}) {
            #print STDERR $complex -> {_id}."\n";
            #print STDERR $complex -> {_type}."\n";
            foreach my $gene (sort keys %{$complex -> {_data}}) {
                if ($complex -> {_data} -> {$gene} -> {urnas}) {
                    foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                        $self -> {_data} -> {$id} -> {text} = "$id";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
        foreach my $complex (sort @{$args{Complexes} -> {prot}}) {
            foreach my $prot (sort keys %{$complex -> {_data}}) {
                if ($complex -> {_data} -> {$prot} -> {urnas}) {
                    foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                        $self -> {_data} -> {$id} -> {text} = "$id";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
    }
    if ($type eq "tfs") {
        foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
            #print STDERR $complex -> {_id}."\n";
            #print STDERR $complex -> {_type}."\n";
            foreach my $gene (sort keys %{$complex -> {_data}}) {
                if ($complex -> {_data} -> {$gene} -> {tfs}) {
                    foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                        $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$gene} -> {tfs} -> {$id} -> {name}." ($id)";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
    }

}

package PreJSVariable;
sub new {

    my $class = shift;
    my $self = {
        _id => "undefined",
        _data => {},
        @_
    };
    bless $self, $class;
    return($self);
}
sub UpdatePreJSVariable {

    my $self = shift;
    my %args = (

        DEGs => 0,
        NoDEGs => 0,
        uRNAs => 0,
        Metas => 0,
        Proteins => 0,
        TFs => 0,
        Complexes => {},
        Maps => {},
        @_
    );

    my $type;
    if ($args{DEGs} == 1) {
        $type = "deg";
    }
    if ($args{NoDEGs} == 1) {
        $type = "nodeg";
    }
    if ($args{Proteins} == 1) {
        $type = "prot";
    }
    if ($args{Metas} == 1) {
        $type = "meta";
    }
    if ($args{uRNAs} == 1) {
        $type = "urnas";
    }
    if ($args{TFs} == 1) {
        $type = "tf"
    }
    if ($args{ONTs}) {
        $type = "onts";
    }


    if (scalar keys %{$args{Complexes}} > 1) {
        if ($type ne "urnas" && $type ne "tf") {
            foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
                foreach my $id (sort keys %{$complex -> {_data}}) {
                    $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1; #warnings
                }
            }
            if ($type eq "nodeg") {
                foreach my $complex (sort @{$args{Complexes} -> {multi}}) {
                    foreach my $id (sort keys %{$complex -> {_data}}) {
                        $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1; #warnings
                    }
                }
            }
        }
        if ($type eq "urnas") {
            foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Complexes} -> {prot}}) {
                foreach my $prot (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$prot} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Complexes} -> {nodeg}}) {
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                        }
                    }
                }
            }

        }

        if ($type eq "tf") {
            foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {tfs}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                            $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                        }
                    }
                }
            }
        }
    }
    if (scalar keys %{$args{Maps}} > 1) {
        if ($type ne "urnas" && $type ne "tf") {
            foreach my $complex (sort @{$args{Maps} -> {$type}}) {
                my $index = $complex -> {_index};
                foreach my $id (sort keys %{$complex -> {_data}}) {
                    $self -> {_data} -> {$id} -> {$index} = 1;
                }
            }

            if ($type eq "nodeg") {
                foreach my $complex (sort @{$args{Maps} -> {multi}}) {
                    my $index = $complex -> {_index};
                    foreach my $id (sort keys %{$complex -> {_data}}) {
                        $self -> {_data} -> {$id} -> {$index} = 1;
                    }
                }
            }
        }
        if ($type eq "urnas") {
            foreach my $complex (sort @{$args{Maps} -> {deg}}) {
                my $index = $complex -> {_index};
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$index} = 1;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Maps} -> {nodeg}}) {
                my $index = $complex -> {_index};
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$index} = 1;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Maps} -> {prot}}) {
                my $index = $complex -> {_index};
                foreach my $prot (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$prot} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {$index} = 1;
                        }
                    }
                }
            }
        }

        if ($type eq "tf") {
            foreach my $complex (sort @{$args{Maps} -> {deg}}) {
                my $index = $complex -> {_index};
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {tfs}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                            $self -> {_data} -> {$id} -> {$index} = 1;
                        }
                    }
                }
            }
        }
    }
    if (scalar keys %{$args{ONTs}}) {
        foreach my $ont (sort keys %{$args{ONTs} -> {_ont_to_genes}}) {
            foreach my $gene (sort keys %{$args{ONTs} -> {_ont_to_genes} -> {$ont} -> {genes}}) {
                $self -> {_data} -> {$ont} -> {$gene} = 1;
            }
        }
    }
    #if (scalar keys %{$args{TFs}} > 0) {

    #}
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
    #$self -> {_data} -> {_begin} = "<div id=\"".$self -> {_id}."\" style=\"position:absolute;z-index:1;visibility:hidden\">";
    #$self -> {_data} -> {_img} = "<img id=\"".$self -> {_id}."_path\" src=\"../pathlay_data/KEGG/hsa/maps/".$self -> {_id}.".png\" border=\"0\" usemap=\"#".$self -> {_id}."_map\">";
    foreach my $complex_type (sort keys %{$pathway -> {_complexes}}) {
        foreach my $complex (sort @{$pathway -> {_complexes} -> {$complex_type}}) {
            my $compid = $complex -> {_id};
            my ($map_id,$complex_number) = split(/_/,$compid);
            #print STDERR $compid."\n";
            my $div_name = "";
            my $div_title = $complex -> {_legend_for_title};
            my $plot_source = $complex -> {_legend_for_plot};
            my $top_coord = $complex -> {_coordinates} -> {y};
            my $left_coord = $complex -> {_coordinates} -> {x};
            foreach my $content_id (sort keys %{$complex -> {_data}}) {

                my $content_name = $complex -> {_data} -> {$content_id} -> {name};
                #print STDERR $content_id." - ".$content_name."\n";
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
                #_onClick => "preTip(this,'mirtarbase');",
                _onClick => "complex_selector($compid)",
                _ondblclick => "spawnBoomBox(this)"
                #_onmouseover => "activate($compid)",
                #_onmouseout => "deactivate($compid)"
            );
            $self -> ContentLoader(
                Content => $complex_img
            );
        }
    }
    #"<img id=\"$compid\" name=\"$div_name\" alt=\"complex\" class=\"complex\" style=\"position:absolute; top:$top_coord; left:$left_coord; visibility:hidden; opacity:0.7;\" src=\"pathlayplot.pl?source=$plot_source\" width=50 height=50 title=\"$div_title\" onClick=\"preTip(this,'mirtarbase');\" onmouseover=\"activate('$compid');\" onmouseout=\"deactivate('$compid');\">";
}
