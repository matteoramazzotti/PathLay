use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use HTMLObjects;
use GeneralFrontEnd;


our $resultsTitles = {
    "highlight_clicker" => "Display Highlight Selectors",
    "shot_clicker" => "Screenshot Current Map",
    "button1" => "Display Clipboard",
    "settings_clicker" => "Display Settings",
    "selectors_clicker" => "Display Query Selectors",
    "legend_clicker" => "Display Help",
    "transparency_up" => "Increase Indicators Transparency",
    "transparency_down" => "Reduce Indicators Transparency",
    "size_up" => "Increase Indicators Size",
    "size_down" => "Reduce Indicators Size",
    "add_icon_button" => "Add Selected Indicator to Clipboard",
    "remove_icon_button" => "Remove Selected Indicator to Clipboard",
    "select_maps_from_icon_button" => "Select Maps containing selected Indicator from Clipboard",
    "download_info_button" => "Download tsv file with Information on Indicators Selected",
    "runlogic" => "Run Query",
    "resetlogic" => "Restore Map Selector and Reset Queries"
};


sub ResultsBuilder {
    my %args = (
        @_
    );
    my $parameters = $args{Parameters};
    
    my @map_divs = @{$args{MapDivs}};
    my @map_ids = @{$args{MapIDs}};
    my @map_names = @{$args{MapNames}};
    my %nums_for_selector = %{$args{Nums}};
    my @ont_select_options = @{$args{ont_select_options}};
    my $ont2gene_js_var = $args{ont2gene_js_var};

    my $debug = 0;

    my $script_section = results_script_Packager(
        Parameters => $parameters
    );
    my $style_section = results_style_Packager(
        Parameters => $parameters
    );
    my $main_type_selector_html = results_main_type_selector_Packager(
        Parameters => $parameters
    );
    ($script_section,my $ont_selector_main_html) = results_ont_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        ont2gene_js_var => $ont2gene_js_var,
        ont_select_options => \@ont_select_options
    );
    
    my $container4 = results_container4_Packager();
    my $settings_div = results_settings_div_Packager();
    my $logistics_div = results_logistics_div_Packager(
        Parameters => $parameters,
        ONTIDSelectorMain => $ont_selector_main_html,
    );
    my $legend_div = results_legend_div_Packager(
        Mode => $parameters -> {_mode_select}
    );
    my $highlighters_div = results_highlighters_div_Packager(
        Parameters => $parameters,
        Type => $main_type_selector_html
    );
    my $container3 = results_container3_Packager(
        highlightersDiv => $highlighters_div,
        settingsDiv => $settings_div,
        logisticsDiv => $logistics_div,
        legendDiv => $legend_div
    );
    my $map_selector = results_map_selector_Packager(
        MapIDs => \@map_ids,
        MapNames => \@map_names,
        Nums => \%nums_for_selector
    );
    my $clickers_div = results_clickers_div_Packager();

    my $container2 = results_container2_Packager(
        MapSelector => $map_selector,
        ClickersDiv => $clickers_div,
        Parameters => $parameters
    );
    my $container5 = results_container5_Packager(
        Container4 => $container4
    );
    my $container6 = results_container6_Packager(
        MapDivs => \@map_divs
    );
    my $window_engine = results_window_engine_Packager();

    unshift(@{$script_section -> {_variables}},"var ont2gene = {};\n");
    unshift(@{$script_section -> {_variables}},"var active = \'null\';\n");

    return($style_section,$script_section,$container5,$container2,$container3,$container6,$window_engine);

    #Results Container5 and Container 4 (Header and Logo)
    sub results_container5_Packager { #Header

        my %args = (
            @_
        );

        my $container = new HTMLDiv(
            _id => "container5",
            _class => "container5"
        );

        $container -> ContentLoader(
            Content => $args{Container4}
        );

        return($container);
    }
    sub results_container4_Packager {
            
        my $container = new HTMLDiv(
            _id => "container4",
            _class => "container4"
        );
        my $header_div = new HTMLDiv(
            _id => "header_div",
            _class => "header_div"
        );

        $header_div -> ContentLoader(
            Content => "<h1>"
        );
        $header_div -> ContentLoader(
            Content => "<b> PathLay - MAPS</b>"
        );
        $header_div -> ContentLoader(
            Content => "</h1>"
        );

        $container -> ContentLoader(
            Content => $header_div
        );

        return($container);
    }

    #Results Container2 (mapselector and clickers)
    sub results_map_selector_Packager {

        my %args = (
            @_
        );

        my @map_ids = @{$args{MapIDs}};
        my @map_names = @{$args{MapNames}};
        my %nums_for_selector = %{$args{Nums}};

        my $map_selector = new HTMLSelect(
            _id => "mapselectDefault",
            _name => "mapselect",
            _class => "defaultSelect",
            _onchange => "changemap(this)",
            _title => "Select Map to Display.\n(Genes,Proteins,miRNAs,Methylations,Metabolites,noDEGs)"
        );
        for my $i (0..$#map_names) {
            my $map_select_option = new HTMLSelectOption (
                _value => $map_ids[$i],
                _text => $map_names[$i]." - ".$map_ids[$i]." (".${$nums_for_selector{$map_ids[$i]}}{degs}.",".${$nums_for_selector{$map_ids[$i]}}{proteins}.",".${$nums_for_selector{$map_ids[$i]}}{urnas}.",".${$nums_for_selector{$map_ids[$i]}}{methyls}.",".${$nums_for_selector{$map_ids[$i]}}{metas}.",".${$nums_for_selector{$map_ids[$i]}}{nodegs}.")",
                _width => 20
            );
            $map_selector -> LoadOption(
                HTMLSelectOption => $map_select_option
            );
        }
        return($map_selector);
    }
    sub results_clickers_div_Packager {

        my $debug = 0;
        print STDERR "--results_clickers_div_packager--\n" if ($debug);
        my $clickersDiv = new HTMLDiv(
            _id =>"clickers_div",
            _class =>"clickers_div"
        );
        my $legendClickerFont = new HTMLFont(
            _id => "legend_clicker",
            _name => "legend_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "?",
            _onclick => "toggleOverDiv('legendDiv')",
            _title => $resultsTitles -> {legend_clicker}
        );
        my $selectorsClickerFont = new HTMLFont(
            _id => "selectors_clicker",
            _name => "selectors_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "Selectors",
            _onclick => "toggleOverDiv('logistics_div')",
            _title => $resultsTitles -> {selectors_clicker}
        );
        my $settingsClickerFont = new HTMLFont(
            _id => "settings_clicker",
            _name => "settings_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "Settings",
            _onclick => "toggleOverDiv('settings_div')",
            _title => $resultsTitles -> {settings_clicker}
        );
        my $clipboardClickerFont = new HTMLFont(
            _id => "button1",
            _name => "clipboard_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "Clipboard",
            _title => $resultsTitles -> {button1}
        );
        my $shotClickerFont = new HTMLFont(
            _id => "shot_clicker",
            _name => "shot_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "Screenshot",
            _onclick => "screenshot()",
            _title => $resultsTitles -> {shot_clicker}
        );
        my $highlightClickerFont = new HTMLFont(
            _id => "highlight_clicker",
            _name => "highlight_clicker",
            _class => "clicker",
            _size => "+1",
            _color => "white",
            _text => "Highlight",
            _onclick => "toggleOverDiv('idselectors')",
            _title => $resultsTitles -> {highlight_clicker}
        );
        $clickersDiv -> ContentLoader(
            Content => $legendClickerFont
        );
        $clickersDiv -> ContentLoader(
            Content => $selectorsClickerFont
        );
        $clickersDiv -> ContentLoader(
            Content => $settingsClickerFont
        );
        $clickersDiv -> ContentLoader(
            Content => $clipboardClickerFont
        );
        $clickersDiv -> ContentLoader(
            Content => $shotClickerFont
        );
        $clickersDiv -> ContentLoader(
            Content => $highlightClickerFont
        );
        $debug = 0;
        return($clickersDiv);
    }
    sub results_container2_Packager {

        my %args = (
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

        
        $mapselectors_div -> ContentLoader(
            Content => $args{MapSelector}
        );
        
        $mainselectors_div -> ContentLoader(
            Content => $mapselectors_div
        );


        $container -> ContentLoader(
            Content => $mainselectors_div
        );
        $container -> ContentLoader(
            Content => $args{ClickersDiv}
        );

        return($container);
    }
    
    
    #Results Container3 (overDiv)
    sub results_settings_div_Packager {

        my $debug = 0;
        print STDERR "--results_settings_div_packager--\n" if ($debug);

        my $settingsDiv = new HTMLDiv(
            _id => "settings_div",
            _class => "overDivSection"
        );

        my $transparencyUpButton = new HTMLInput(
            _id => "transparency_up",
            _type => "button",
            _value => "Transparency Up",
            _onClick => "change(\'trasp\',\'u\')",
            _title => $resultsTitles -> {transparency_up}
        );
        my $transparencyDownButton = new HTMLInput(
            _id => "transparency_down",
            _type => "button",
            _value => "Transparency Down",
            _onClick => "change(\'trasp\',\'d\')",
            _title => $resultsTitles -> {transparency_down}

        );
        my $sizeUpButton = new HTMLInput(
            _id => "size_up",
            _type => "button",
            _value => "Size Up",
            _onClick => "change(\'size\',\'u\')",
            _title => $resultsTitles -> {size_up}
        );
        my $sizeDownButton = new HTMLInput(
            _id => "size_down",
            _type => "button",
            _value => "Size Down",
            _onClick => "change(\'size\',\'d\')",
            _title => $resultsTitles -> {size_down}
        );
        my $sizeFont = new HTMLFont(
            _color => "white",
            _text => "Indicators Size",
            _class => "highlightFont overDivFont"
        );
        my $transparencyFont = new HTMLFont(
            _color => "white",
            _text => "Indicators Transparency",
            _class => "highlightFont overDivFont"
        );

        $settingsDiv -> ContentLoader(
            Content => $transparencyFont
        );
        
        $settingsDiv -> ContentLoader(
            Content => $transparencyUpButton
        );
        $settingsDiv -> ContentLoader(
            Content => $transparencyDownButton
        );
        $settingsDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $settingsDiv -> ContentLoader(
            Content => $sizeFont
        );
        $settingsDiv -> ContentLoader(
            Content => $sizeUpButton
        );
        $settingsDiv -> ContentLoader(
            Content => $sizeDownButton
        );
        $settingsDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $debug = 0;
        return($settingsDiv);
    }
    sub results_logistics_div_Packager {

        my %args = (
            @_
        );
        my $debug = 0;
        print STDERR "--results_logistics_div_packager--\n" if ($debug);
        my $parameters = $args{Parameters};

        my $logisticsDiv = new HTMLDiv(
            _id => "logistics_div",
            _class => "overDivSection"
        );

        my $type_logical_select = new HTMLSelect(
            _name => "type_for_logical",
            _id => "type_for_logical",
            _onchange => "logic_list_handler(this.selectedOptions[0].value)",
            _style => "float:left;margin-right:5px;"
        );

        my @type_options;
        my @html_selectors;

        push @type_options,new HTMLSelectOption(
            _value => "none",
            _width => 10
        );
        my $agreementSelectionFont = new HTMLFont(
            _text => "Agreement Selection",
            _class => "overDivFont logisticsFont"
        );
        my $logisticsDiv_agreement_selectors = new HTMLDiv(
            _id => "logistics_div_agreement_selectors",
            _class => "logistics_div_selectors",
            #_style => "float:left;width:60%;height:45%;"
        );
        $logisticsDiv_agreement_selectors -> ContentLoader(
            Content => $agreementSelectionFont
        );
        

        my $ontSelectorDiv;
        if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth}) {
            
            push @type_options,new HTMLSelectOption(
                _value => "gene",
                _text => "Gene",
                _width => 10
            );
            my $gene_selector_logical_html = new HTMLSelect(
                _id => "select1b",
                _name => "select1b",
                _class => "logistics_selector",
                #_onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
                _title => "Select Gene for logical operators",
                _style => "display:none;"
            );
            $gene_selector_logical_html -> LoadOption(
                HTMLSelectOption => \%{$args{GeneIDSelector}}
            );
            $gene_selector_logical_html -> SortSelectByAlphabet();
            my $first_gene_select = new HTMLSelectOption(
                _value => "all",
                _text => "Gene for Logical"
            );
            unshift(@{$gene_selector_logical_html -> {_options}},$first_gene_select);

            push(@html_selectors,$gene_selector_logical_html);


            $ontSelectorDiv = new HTMLDiv(
                _id => "ontSelectorDiv",
                _class => "logistics_div_selectors"
            );
            my $ontFont = new HTMLFont(
                _text => "Cellular Compartment Selection",
                _class => "overDivFont logisticsFont"
            );
            my $ontSelector = $args{ONTIDSelectorMain};

            my $ontUlAddButton = new HTMLInput(
                _id => "ontUlAddButton",
                _type => "button",
                _value => "Add",
                #_style => "float:left;margin-right:5px;",
                _onClick => ""
            );

            $ontSelectorDiv -> ContentLoader(
                Content => $ontFont
            );
            $ontSelectorDiv -> ContentLoader(
                Content => $ontSelector
            );

            $ontSelectorDiv -> ContentLoader(
                Content => $ontUlAddButton
            );

        }

        if ($parameters -> {_enableprot}) {
            push @type_options,new HTMLSelectOption(
                _value => "prot",
                _text => "Protein",
                _width => 10
            );
            my $prot_selector_logical_html = new HTMLSelect(
                _id => "select6b",
                _name => "select6b",
                _class => "logistics_selector",
                #_onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
                _title => "Select Protein for logical operators",
                _style => "display:none;"
            );
            $prot_selector_logical_html -> LoadOption(
                HTMLSelectOption => \%{$args{ProtIDSelector}}
            );
            $prot_selector_logical_html -> SortSelectByAlphabet();
            my $first_prot_select = new HTMLSelectOption(
                _value => "all",
                _text => "Protein for Logical"
            );
            unshift(@{$prot_selector_logical_html -> {_options}},$first_prot_select);
            push(@html_selectors,$prot_selector_logical_html);
        }

        if ($parameters -> {_enableurna}) {
            push @type_options,new HTMLSelectOption(
                _value => "urna",
                _text => "miRNA",
                _width => 10
            );
            my $urna_selector_logical_html = new HTMLSelect(
                _id => "select2b",
                _name => "select2b",
                _class => "logistics_selector",
                #_onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
                _title => "Select miRNA for logical operators",
                _style => "display:none;"
            );
            $urna_selector_logical_html -> LoadOption(
                HTMLSelectOption => \%{$args{miRNAIDSelector}}
            );
            $urna_selector_logical_html -> SortSelectByAlphabet();
            my $first_urna_select = new HTMLSelectOption(
                _value => "all",
                _text => "miRNA for Logical"
            );
            unshift(@{$urna_selector_logical_html -> {_options}},$first_urna_select);
            push(@html_selectors,$urna_selector_logical_html);
        }

        if ($parameters -> {_enablemeta}) {
            push @type_options,new HTMLSelectOption(
                _value => "meta",
                _text => "Metabolite",
                _width => 10
            );
            my $meta_selector_logical_html = new HTMLSelect(
                _id => "select3b",
                _name => "select3b",
                _class => "logistics_selector",
                #_onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
                _title => "Select Metabolite for logical operators",
                _style => "display:none;"
            );
            $meta_selector_logical_html -> LoadOption(
                HTMLSelectOption => \%{$args{MetaIDSelector}}
            );
            $meta_selector_logical_html -> SortSelectByAlphabet();

            my $first_meta_select = new HTMLSelectOption(
                _value => "all",
                _text => "Metabolite for Logical"
            );
            unshift(@{$meta_selector_logical_html -> {_options}},$first_meta_select);
            push(@html_selectors,$meta_selector_logical_html);
        }

        #agreement selector
        my $agreement_selector1_html;
        my $agreement_selector2_html;
        my $agreement_selector3_html;
        my @first_party_options;
        my $first_party_option0;
        my $first_party_option1;
        my $first_party_option2;
        my @second_party_options;
        my @nature_options;


        if ($parameters -> {_enableurna} ||
            $parameters -> {_enablemeth} ||
            $parameters -> {_enabletfs_gene} ||
            $parameters -> {_enabletfs_prot} ||
            ($parameters -> {_enablegene} && $parameters -> {_enableprot})
        ) {
            if ($parameters -> {_enablegene} && $parameters -> {_enableprot}) {
                $first_party_option1 = new HTMLSelectOption(
                    _value => "gene",
                    _text => "Gene"
                );
                $first_party_option2 = new HTMLSelectOption(
                    _value => "prot",
                    _text => "Protein"
                );
                push(@first_party_options,$first_party_option1);
                push(@first_party_options,$first_party_option2);
            } else {
                if ($parameters -> {_enablegene}) {
                    $first_party_option1 = new HTMLSelectOption(
                        _value => "gene",
                        _text => "Gene"
                    );
                    push(@first_party_options,$first_party_option1);
                }
                if ($parameters -> {_enableprot}) {
                    $first_party_option1 = new HTMLSelectOption(
                        _value => "prot",
                        _text => "Protein"
                    );
                    push(@first_party_options,$first_party_option1);
                }
            }
            $first_party_option0 = new HTMLSelectOption(
                _value => "none",
                _text => ""
            );
            my $agreement_selector1_html = new HTMLSelect(
                _id => "agreement_selector1",
                _name => "agreement_selector1",
                _onchange => "showSecondParty(this.selectedOptions[0].value)",
                _title => "Select first party",
                _style => "display:block;float:left;",
                _class => "agreementSelector"
            );
            foreach my $party_option (@first_party_options) {
                $agreement_selector1_html -> LoadOption(
                    HTMLSelectOption => $party_option
                );
            }
            unshift(@{$agreement_selector1_html -> {_options}},$first_party_option0);

            $logisticsDiv_agreement_selectors -> ContentLoader(
                Content => $agreement_selector1_html
            );
        }

        $type_logical_select -> LoadOption(
            HTMLSelectOption => \@type_options
        );

        my $add_element_button = new HTMLInput(
            _id => "add_element_to_logic_button",
            _type => "button",
            _value => "Add",
            #_onClick => "add_element_to_logic(active_logical_selected_element)"
            _onClick => ""
        );
        my $runlogic_button = new HTMLInput(
            _id => "runlogic",
            _type => "button",
            _value => "Select",
            #_onClick => "pathfilter_logic(logical_pool_content,\'run\')"
            _title => $resultsTitles -> {runlogic}
        );
        my $resetlogic_button = new HTMLInput(
            _id => "resetlogic",
            _type => "button",
            _value => "Reset",
            #_onClick => "pathfilter_logic(logical_pool_content,\'reset\')"
            _title => $resultsTitles -> {resetlogic}
        );

        ${$html_selectors[0]}{_style} = "display:none;";

        my $logisticsDiv_selectors = new HTMLDiv(
            _id => "logistics_div_selectors",
            _class => "logistics_div_selectors",
            #_style => "float:left;width:60%;height:45%;"
        );

        my $multipleIdsSelectionFont = new HTMLFont(
            _text => "Multiple IDs Selection",
            _class => "overDivFont logisticsFont"
        );
        $logisticsDiv_selectors -> ContentLoader(
            Content => $multipleIdsSelectionFont
        );
        $logisticsDiv_selectors -> ContentLoader(
            Content => $type_logical_select
        );
        my $logisticsDiv_pool_wrapper = new HTMLDiv(
            _id => "logistics_div_pool_wrapper",
            _class => "logistics_div_pool_wrapper2"
        );
        my $logisticsDiv_selectors_wrapper = new HTMLDiv(
            _id => "logistics_div_pool_wrapper_1",
            _class => "logistics_div_pool_wrapper1"
        );

        my $logisticsDiv_pool_header1 = new HTMLDiv(
            _id => "logistics_div_pool_header1",
            _class => "logistics_div_pool_header",
            _style => "border:0px solid yellow;min-width:100%;overflow:hidden;background-color:#006699;text-align:center;opacity:0.9;border-radius: 8px 8px 0 0;"
        );
        #my $logisticsDiv_pool_header2 = new HTMLDiv(
        #    _id => "logistics_div_pool_header2",
        #    _class => "logistics_div_pool_header",
        #    _style => "border:0px solid yellow;min-width:100%;overflow:hidden;background-color:#006699;text-align:center;opacity:0.9;border-radius: 0px 0px 0 0;"
        #);
        my $logisticsDiv_pool = new HTMLDiv(
            _id => "logistics_div_pool",
            _class => "logistics_div_pool",
            _style => "float:right;border:1px #006699;min-width:100%;min-height:50px;max-height:100px;overflow: scroll;background-color:white;"
        );

        #my $logisticsDiv_pool_agreement = new HTMLDiv(
        #    _id => "logistics_div_pool_agreement",
        #    _class => "logistics_div_pool_agreement",
        #    _style => "float:right;border:1px #006699;min-width:100%;min-height:50px;max-height:100px;overflow: scroll;background-color:white;" ##f2f2f2
        #);


        foreach my $html_selector (@html_selectors) {
            $html_selector -> {_style} .= "margin-right:5px;float:left;";
            $logisticsDiv_selectors -> ContentLoader(
                Content => $html_selector
            );
        }
        $logisticsDiv_selectors -> ContentLoader(
            Content => $add_element_button
        );
        $logisticsDiv_selectors -> ContentLoader(
            Content => $runlogic_button
        );
        $logisticsDiv_selectors -> ContentLoader(
            Content => $resetlogic_button
        );
        my $logistics_ul_pool = new HTMLul(
            _id => "queryUlPool",
            _class => "logistics_ul_pool"
        );
        #my $logistics_ul_pool_agreement = new HTMLul(
        #    _id => "logistics_ul_pool_agreement",
        #    _class => "logistics_ul_pool"
        #);


        $logisticsDiv_pool -> ContentLoader(
            Content => $logistics_ul_pool
        );
        $logisticsDiv_pool_header1 -> ContentLoader(
            Content => "<p class=\"windowTitle\" style=\"margin-left:10px;\"><font size=\"+0\" color=\"white\">Queries</font></p>"
        );
        #$logisticsDiv_pool_header2 -> ContentLoader(
        #    Content => "<p class=\"windowTitle\" style=\"margin-left:10px;\"><font size=\"+0\" color=\"white\">Agreements Selected</font></p>"
        #);

        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool_header1
        );
        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool
        );
        #$logisticsDiv_pool_wrapper -> ContentLoader(
        #    Content => $logisticsDiv_pool_header2
        #);

        #if ($parameters -> {_mode_select} ne "id_only") {
        #    $logisticsDiv_pool_agreement -> ContentLoader(
        #        Content => $logistics_ul_pool_agreement
        #    );
        #}
        

        #$logisticsDiv_pool_wrapper -> ContentLoader(
        #    Content => $logisticsDiv_pool_agreement
        #);

        $logisticsDiv_selectors_wrapper -> ContentLoader(
            Content => $logisticsDiv_selectors
        );
        $logisticsDiv_selectors_wrapper -> ContentLoader(
            Content => "<br><br>"
        );
        #if ($parameters -> {_mode_select} ne "id_only") {
            $logisticsDiv_selectors_wrapper -> ContentLoader(
                Content => $logisticsDiv_agreement_selectors
            );
            $logisticsDiv_selectors_wrapper -> ContentLoader(
                Content => "<br><br>"
            );
        #}
        if ($parameters -> {_enablegene} || $parameters -> {_enablemeth} || $parameters -> {_enablechroma} || $parameters -> {_enablenodeg}) {
            $logisticsDiv_selectors_wrapper -> ContentLoader(
                Content => $ontSelectorDiv
            );
        }
        $logisticsDiv -> ContentLoader(
            Content => $logisticsDiv_selectors_wrapper
        );
        $logisticsDiv -> ContentLoader(
            Content => $logisticsDiv_pool_wrapper
        );

        $debug = 0;
        return($logisticsDiv);
    }
    sub results_legend_div_Packager {

        my %args = (
            @_
        );
        my $debug = 0;
        my $mode = $args{Mode};
        print STDERR "--results_legend_div_packager--\n" if ($debug);
        my $legendDiv = new HTMLDiv(
            _id => "legendDiv",
            _class => "overDivSection"
        );
        my $legendImg = new HTMLImg(
            _id => "legendImg",
            _src => "../src/symbols_full.png"
        );
        $legendDiv -> ContentLoader(
            Content => $legendImg 
        );
        $debug = 0;
        return($legendDiv);
    }
    sub results_highlighters_div_Packager {

        my %args = (
            @_
        );
        my $parameters = $args{Parameters};
        my $highlightersDiv = new HTMLDiv(
            _id => "idselectors",
            _class => "overDivSection"
        );
        

        my $selectByTypeFont = new HTMLFont(
            _text => "Select ID Type to List Below",
            _class => "highlightFont overDivFont"
        );
        my $selectByIdFont = new HTMLFont(
            _text => "Select ID to Highlight",
            _class => "highlightFont overDivFont"
        );
        $highlightersDiv -> ContentLoader(
            Content => $selectByTypeFont
        );
        $highlightersDiv -> ContentLoader(
            Content => $args{Type}
        );
        $highlightersDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $highlightersDiv -> ContentLoader(
            Content => $selectByIdFont
        );
        return($highlightersDiv);
    }
    sub results_container3_Packager {
        my %args = (
            @_
        );
        my $highlightersDiv = $args{highlightersDiv};
        my $settingsDiv = $args{settingsDiv};
        my $logisticsDiv = $args{logisticsDiv};
        my $legendDiv = $args{legendDiv};

        my $overDiv = new HTMLDiv(
            _id => "container3",
            _class => "container3"
        );

        $overDiv -> ContentLoader(
            Content => $highlightersDiv
        );
        $overDiv -> ContentLoader(
            Content => $settingsDiv
        );
        $overDiv -> ContentLoader(
            Content => $logisticsDiv
        );
        $overDiv -> ContentLoader(
            Content => $legendDiv
        );

        return($overDiv);
    }

    #Results Selectors for Container3 (overDiv Highlighters)
    sub results_main_type_selector_Packager {
        my %args = (
            @_
        );
        my $parameters = $args{Parameters};

        my $type_selector_main_html = new HTMLSelect(
            _id => "select_type_main",
            _name => "select_type_main",
            #_onchange => "enable_selectors_results(this.value)",
            _title => "Select Type of Selector to Enable"
        );

        my $type_option_gene_html = new HTMLSelectOption(
            _value => "gene",
            _text => "Genes"
        );
        my $type_option_urna_html = new HTMLSelectOption(
            _value => "urna",
            _text => "miRNAs"
        );
        my $type_option_meta_html = new HTMLSelectOption(
            _value => "meta",
            _text => "Metabolites"
        );
        my $type_option_prot_html = new HTMLSelectOption(
            _value => "prot",
            _text => "Proteins"
        );
        my $type_option_ont_html = new HTMLSelectOption(
            _value => "ont",
            _text => "Onthologies"
        );
        my $type_option_tf_html = new HTMLSelectOption(
            _value => "tf",
            _text => "TFs"
        );


        if (
            $parameters -> {_enablegene} || 
            $parameters -> {_nodeg_select_urna} ||
            $parameters -> {_nodeg_select_meth} ||
            $parameters -> {_nodeg_select_chroma} ||
            $parameters -> {nodeg_select_tf_gene} ||
            $parameters -> {nodeg_select_tf_prot}
        ) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_gene_html
            );
            #$type_selector_main_html -> LoadOption(
            #    HTMLSelectOption => $type_option_ont_html
            #);
        }
        if ($parameters -> {_enableprot} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_prot_html
            );
        }
        if ($parameters -> {_enableurna} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_urna_html
            );
        }
        if ($parameters -> {_enablemeta} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_meta_html
            );
        }
        if ($parameters -> {_enabletfs_gene} == 1 || $parameters -> {_enabletfs_prot} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_tf_html
            );
        }
        return($type_selector_main_html);
    }
    sub results_ont_selector_Packager {
        my %args = (
            @_
        );
        my $parameters = $args{Parameters};
        my @ont_select_options = @{$args{ont_select_options}};
        my $script_section = $args{Script};
        my $ont2gene_js_var = $args{ont2gene_js_var};
        my $ont_selector_main_html = new HTMLSelect(
            _id => "ontUlSelect",
            _name => "ontUlSelect",
            _class => "ontSelector",
            #_onchange => "pathfilter(4)",
            _style => "display:block;",
            _title => "Display Genes related to an Ontology",
        );
        my $first_ont_select = new HTMLSelectOption(
            _value => "none",
            _text => "Ontologies"
        );
        $parameters -> {_enablenodeg} = $parameters -> {_nodeg_select_urna} || $parameters -> {_nodeg_select_meth} || $parameters -> {_nodeg_select_chroma} ? 1 : 0;
        if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth}) {
            foreach (@ont_select_options) {
                $ont_selector_main_html -> LoadOption(
                HTMLSelectOption => $_
            );
            }

            $ont_selector_main_html -> SortSelectByAlphabet();
            unshift(@{$ont_selector_main_html -> {_options}},$first_ont_select);
            $script_section -> VariablesLoader(
                Content => \%{$ont2gene_js_var -> {_data}},
                VariableID => "ont2gene"
            );
        }
        return($script_section,$ont_selector_main_html);
    }
    
    #Results Container6
    sub results_container6_Packager { #Pathways

        my %args = (
            @_
        );

        my $container = new HTMLDiv(
            _id => "container6",
            _class => "container6 dragscroll"
        );

        my $maps_container = new HTMLDiv(
            _id => "maps_div",
            _class => "maps_div"
        );

        foreach my $map_div (@{$args{MapDivs}}) {
            $maps_container -> ContentLoader(
                Content => $map_div
            );
        }
        $container -> ContentLoader(
            Content => $maps_container
        );

        return($container);
    }

    #Results WindowEngine
    sub results_window_engine_Packager {

        my $window_engine_group = new HTMLDiv(
            _class => "windowGroup"
        );
        my $info_container = new HTMLDiv(

            _id => "window1",
            _class => "window clipboard fade",
            #_style => "display:initial;"
        );
        my $window_engine_title = new HTMLDiv(
            _class => "lightblue disable-select"
        );

        my $window_engine_main = new HTMLDiv(
            _class => "mainWindow"
        );
        my $display1 = new HTMLDiv(
            _id => "display1"
        );
        my $title_info_1 = new HTMLDiv(
            _style => "text-align:center; background-color:#006699;border-radius: 8px 8px 8px 8px; width:97%;margin-left:5px;",
            _class => "disable-select"
        );
        my $info_display_div = new HTMLDiv(
            _id => "info_display_div",
            _class => "info_display_div",
            _contenteditable => "false"
        );
        my $display2 = new HTMLDiv(
            _style => "margin-top:20px;"
        );
        my $title_info_2 = new HTMLDiv(
            _style => "text-align:center; background-color:#006699;border-radius: 8px 8px 8px 8px; width:97%;margin-left:5px;",
            _class => "disable-select"
        );
        my $add_icon_button = new HTMLInput(
            _id => "add_icon_button",
            _type => "button",
            _value => "Add",
            _onClick => "fill_complex_pool(active_complex_id)",
            _style => "margin-left:105px;",
            _title => $resultsTitles -> {add_icon_button}
        );
        my $complex_pool_div = new HTMLDiv(
            _id => "complex_pool_div",
            _class => "complex_pool_div",
            _contenteditable => "false"
        );


        my $remove_icon_button = new HTMLInput(
            _id => "remove_icon_button",
            _type => "button",
            _value => "Remove",
            _onClick => "purge_complex_pool(active_complex_id)",
            _title => $resultsTitles -> {remove_icon_button}
        );
        my $download_info_button = new HTMLInput(
            _id => "download_info_button",
            _type => "button",
            _value => "Download",
            #_onClick => "download_from_pool()"
            _title => $resultsTitles -> {download_info_button}

        );
        my $select_maps_from_icon_button = new HTMLInput(
            _id => "select_maps_from_icon_button",
            _type => "button",
            _value => "Select",
            #_onClick => "select_from_pool(active_complex_obj)",
            _style => "margin-left:90px;",
            _title => $resultsTitles -> {select_maps_from_icon_button}

        );


        $window_engine_title -> ContentLoader(
            Content => "<p class=\"windowTitle\" style=\"margin-left:115px;\"><font size=\"+2\" color=\"white\">Clipboard</font></p>"
        );

        $title_info_1 -> ContentLoader(
            Content => "<font size=\"+2\" color=\"white\">Info</font>"
        );
        $title_info_2 -> ContentLoader(
            Content => "<font size=\"+2\" color=\"white\">Selected</font>"
        );

        $display1 -> ContentLoader(
            Content => $title_info_1
        );
        $display1 -> ContentLoader(
            Content => $info_display_div
        );

        $display2 -> ContentLoader(
            Content => $title_info_2
        );
        $display2 -> ContentLoader(
            Content => $complex_pool_div
        );

        $window_engine_main -> ContentLoader(
            Content => $display1
        );
        $window_engine_main -> ContentLoader(
            Content => $add_icon_button
        );
        $window_engine_main -> ContentLoader(
            Content => $remove_icon_button
        );

        $window_engine_main -> ContentLoader(
            Content => $display2
        );

        $window_engine_main -> ContentLoader(
            Content => $select_maps_from_icon_button
        );
        $window_engine_main -> ContentLoader(
            Content => $download_info_button
        );

        $info_container -> ContentLoader(
            Content => $window_engine_title
        );
        $info_container -> ContentLoader(
            Content => $window_engine_main
        );

        $window_engine_group -> ContentLoader(
            Content => $info_container
        );
        return($window_engine_group);
    }

}
sub printPage {
    my %args = (
        StyleSection => {},
        ScriptSection => {},
        Wrapper => {},
        WindowEngine => {},
        @_
    );
    my $style_section = $args{StyleSection};
    my $script_section = $args{ScriptSection};
    my $wrapper = $args{Wrapper};
    my $window_engine = $args{WindowEngine};
    my $parameters = $args{Parameters};
    my $js_function_last = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."results/window-engine.js"
    );
    print "Content-type: text/html\n\n";
    print "<!DOCType html>\n";
    print "<html>\n";
    print " <head>\n";
    print "<meta charset=\"UTF-8\"/>\n";
    $style_section -> PrintStyle();
    print " </head>\n";
    print "<body>\n";
    
    $script_section -> PrintScript();
    
    $wrapper -> PrintDiv();
    my $form = new HTMLForm(
        _id => "main",
        _name => "main",
        _action => "../cgi-bin/pathlay_home.pl",
        _method => "post",
        _enctype => "multipart/form-data"
    );
    my $form_textarea = new HTMLTextArea(
        _id => "info_to_download",
        _name => "info_to_download",
        _wrap => "off",
        _style => "visibility:hidden;"
    );
    my $h5 = new HTMLInput(
        _id => "ope",
        _name => "ope",
        _type => "text",
        _style => "display:none;",
        _value => ""
    );
    $form -> ContentLoader(
        Content => $form_textarea
    );
    $form -> ContentLoader(
        Content => $h5
    );
    $form -> PrintForm();
    $window_engine -> PrintDiv();
    print "</body>\n";
    print "</html>";
    $js_function_last -> PrintScriptSrc();
}
sub wrapperBuilder {
    my %args = (
        Container5 => {},
        Container2 => {},
        Container3 => {},
        Container6 => {},
        @_
    );

    my $container5 = $args{Container5};
    my $container2 = $args{Container2};
    my $container3 = $args{Container3};
    my $container6 = $args{Container6}; 

    my $wrapper = new HTMLDiv(
        _id => "wrapperDiv",
        _class => "wrapperDiv"
    );
    $wrapper -> ContentLoader(
        Content => $container5
    );
    $wrapper -> ContentLoader(
        Content => $container2
    );
    $wrapper -> ContentLoader(
        Content => $container3
    );
    $wrapper -> ContentLoader(
        Content => $container6
    );
    return($wrapper);
}
sub results_style_Packager {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    my $style_section = new HTMLStyle();
    my @style_links;
    my @styles = (
        "window-engine.css",
        "overDiv.css",
        "mainDivsHome.css",
        "mainDivsAccess.css",
        "mainDivs.css",
        "mainButtons.css",
        "mainButtons.css",
        "complexes.css",
        "boomBoxDiv.css",
        "animate.css",
        "old.css",
        "ul.css"
    );
    foreach my $cssfile (sort(@styles)) {
        next if ($cssfile !~ /\.css$/);
        #print $cssfile."\n";
        my $css = new HTMLStyleLink(
            _rel => "stylesheet",
            _href => $parameters -> {_styledir}."$cssfile"
        );
        #$css -> PrintStyleLink();
        push(@style_links,$css);
    }

    $style_section -> StyleLinksLoader(
        Content => \@style_links
    );
    return($style_section);
}
sub results_script_Packager {

    my %args = (
        @_
    );
    my $parameters = $args{Parameters};

    my $script_section = new HTMLScript();
    my @js_functions;
    my @jsFiles = (
        "global.js",
        "dragscroll.js",
        "boombox.js",
        "interfaces.js",
        "resultsUtils.js",
        "indicatorsUtils.js",
        "indicatorObject.js",
        "html2canvas.js",
        #"logic_alpha.js",
        "screenshot.js",
        "clipBoardUtils.js",
        "onLoad.js"
    );

    #opendir(JSDIR,$parameters -> {_jsdir}."results/");
    #foreach my $jsfile (sort(readdir(JSDIR))) {
    foreach my $jsfile (@jsFiles) {
        next if ($jsfile !~ /.js$/);
        next if ($jsfile eq "window-engine.js");


        my $js_function = new HTMLScriptSrc(
            _type => "text/javascript",
            _src => $parameters -> {_jsdir}."results/"."$jsfile"
        );
        #$js_function -> PrintScriptSrc();
        push(@js_functions,$js_function);
    }
    #closedir(JSDIR);

    opendir(JSDIR,$parameters -> {_jsdir}."common/");
    foreach my $jsfile (sort(readdir(JSDIR))) {
        next if ($jsfile !~ /.js$/);
        my $js_function = new HTMLScriptSrc(
            _type => "text/javascript",
            _src => $parameters -> {_jsdir}."common/"."$jsfile"
        );
        #$js_function -> PrintScriptSrc();
        push(@js_functions,$js_function);
    }
    closedir(JSDIR);
    #opendir(JSDIR,$parameters -> {_jsdir}."modules/");
    #foreach my $jsfile (sort(readdir(JSDIR))) {
    #    next if ($jsfile !~ /.js$/);
    #    my $js_module = new HTMLScriptSrc(
    #        _type => "module",
    #        _src => $parameters -> {_jsdir}."modules/"."$jsfile"
    #    );
    #    push(@js_functions,$js_module);
    #}
    #closedir(JSDIR);
    $script_section -> FunctionsLoader(
        Content => \@js_functions
    );

    #my $first_js = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."results/"."onLoad.js"
    #);

    #unshift(@{$script_section -> {_functions}},$first_js);
    return($script_section);
}
1;