use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use HTMLObjects;
use GeneralFrontEnd;

sub HomeBuilder {    


    my %args = (
        @_
    );

    #my ($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot) = div_setup_access_Packager();

    my $parameters = $args{Parameters};
    $parameters -> LoadAvailableOrganisms();
    $parameters -> LoadAvailableExps(
        UsersDir => $parameters->{_base}."/pathlay_users/".$parameters->{_home}."/"
    );
    $parameters -> LoadAvailableONTs(
        _ont_db_file => $parameters -> {_ont_db_file},
        _ont_db_location => $parameters -> {_ont_db_location},
    );# different ontologies must be loaded for different organisms so this should be rewritten

    my $home_script = home_script_Packager(
        Parameters => $parameters
    );

    my $container4_home = container4_Packager(
        Title => "PathLay - Home Manager"
    );

    my $container5_home = container5_Packager(
        Container4 => $container4_home
    );

    my $container_buttons_home = container_buttons_home_Packager(
        Parameters => $parameters
    );

    my $container_data_home = container_data_home_Packager(
        Parameters => $parameters
    );

    my $ont_div = div_ont_home_packager(
        Parameters => $parameters
    );

    my $form = new HTMLForm(
        _id => "main",
        _name => "pathlay",
        _action => "../cgi-bin/pathlay_home.pl",
        _method => "post",
        _enctype => "multipart/form-data",
        _autocomplete => "off"
    );

    $form -> ContentLoader(
        Content => $container5_home
    );
    $form -> ContentLoader(
        Content => $container_buttons_home
    );
    $form -> ContentLoader(
        Content => $container_data_home
    );
    $form -> ContentLoader(
        Content => $ont_div
    );
    return($home_script,$form);
}

sub home_script_Packager {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    my $home_script = new HTMLScript();

    my @js_functions;
    my @js_variables;
    $js_functions[0] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."home/homeUtils.js"
    );
    #$js_functions[1] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."loaddata.js"
    #);
    #$js_functions[2] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."showhide.js"
    #);
    #$js_functions[3] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."ont_ul_manager.js"
    #);
    #$js_functions[4] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."searchONT.js"
    #);

    $home_script -> FunctionsLoader(
        Content => \@js_functions
    );

    $home_script = BuildExpConfJS(
        Parameters => $parameters,
        Script => $home_script
    );

    unshift(@{$home_script -> {_variables}},"var exp_confs = {};");
    unshift(@{$home_script -> {_variables}},"var host = \"".$parameters -> {_host}."\";");
    unshift(@{$home_script -> {_variables}},"var base = \"".$parameters -> {_home}."\";");

    return($home_script);
}
sub container_buttons_home_Packager {

            my %args = (
                @_
            );
            my $parameters = $args{Parameters};

            my $div_loader = div_loader_home_Packager();
            my $div_upload = div_upload_home_Packager();

            my $exp_select = new HTMLSelect(
                _id => "exp_select",
                _name => "exp_select"
            );
            foreach my $exp (sort keys %{$parameters -> {_exps_available}}) {
                #print STDERR $exp."\n";
                #print STDERR " ".$parameters -> {_exps_available} -> {$exp} -> {conf_data} -> {expname}."\n";
                my $exp_select_opt = new HTMLSelectOption(
                    _value => $exp,
                    _text => $parameters -> {_exps_available} -> {$exp} -> {conf_data} -> {expname}
                );
                $exp_select -> LoadOption(
                    HTMLSelectOption => $exp_select_opt
                );

            }

            my $container_buttons_home = new HTMLDiv(
                _id => "container_buttons",
                _style => "position:relative;margin:5px;border:0px solid blue;width:100%;"
            );
            my $button_load = new HTMLInput(
                _id => "expLoaderButton",
                _type => "button",
                _value => "Load",
                _onClick => "homeExpLoader();"
            );
            my $button_save = new HTMLInput(
                _id => "expSaveButton",
                _type => "button",
                _value => "Save",
                _onClick => "submitForm(\'save\');",
                #_disabled => 1
            );
            my $button_add = new HTMLInput(
                _id => "addNewExp",
                _type => "button",
                _value => "Add New",
                #_onClick => "submitForm(\'add\');",
                #_disabled => 1
            );
            my $button_delete = new HTMLInput(
                _type => "button",
                _value => "Delete",
                _onClick => "submitForm(\'delete\');",
                #_disabled => 1
            );
            my $button_refresh = new HTMLInput(
                _type => "button",
                _value => "Refresh",
                _onClick => "submitForm(\'home\');"
            );
            my $button_download = new HTMLInput(
                _type => "button",
                _value => "Download",
                _onClick => "submitForm(\'download\');",
                #_disabled => 1
            );
            my $button_download_home = new HTMLInput(
                _type => "button",
                _value => "Download Home",
                _onClick => "submitForm(\'download_home\');",
                #_disabled => 1
            );
            my $upload_button = new HTMLInput(
                _type => "button",
                _value => "Upload",
                _onClick => "submitForm(\'upload\')",
                #_disabled => 1
            );
            my $browse_button = new HTMLInput(
                _type => "file",
                _id => "file",
                _name => "file",
                #_disabled => 1
            );

            my $h1 = new HTMLInput(
                _id => "username",
                _name => "username",
                _type => "text",
                _style => "display:none;",
                _value => $parameters -> {_username}
            );
            my $h2 = new HTMLInput(
                _id => "password",
                _name => "password",
                _type => "text",
                _style => "display:none;",
                _value => $parameters -> {_password}
            );
            my $h3 = new HTMLInput(
                _id => "home",
                _name => "home",
                _type => "text",
                _style => "display:none;",
                _value => $parameters -> {_home}
            );
            my $h4 = new HTMLInput(
                _id => "base",
                _name => "base",
                _type => "text",
                _style => "display:none;",
                _value => $parameters -> {_host}
            );
            my $h5 = new HTMLInput(
                _id => "ope",
                _name => "ope",
                _type => "text",
                _style => "display:none;",
                _value => ""
            );


            $div_loader -> ContentLoader(
                Content => "Guess who's back? "
            );
            $div_loader -> ContentLoader(
                Content => $parameters -> {_username}
            );
            $div_loader -> ContentLoader(
                Content => "<br><br>"
            );
            $div_loader -> ContentLoader(
                Content => $exp_select
            );
            $div_loader -> ContentLoader(
                Content => $button_load
            );
            $div_loader -> ContentLoader(
                Content => $button_save
            );
            $div_loader -> ContentLoader(
                Content => $button_add
            );
            $div_loader -> ContentLoader(
                Content => $button_delete
            );
            $div_loader -> ContentLoader(
                Content => $button_refresh
            );
            $div_loader -> ContentLoader(
                Content => $button_download
            );
            $div_loader -> ContentLoader(
                Content => $button_download_home
            );
            $div_loader -> ContentLoader(
                Content => "<br><br>"
            );

            $div_upload -> ContentLoader(
                Content => "or "
            );
            $div_upload -> ContentLoader(
                Content => $upload_button
            );
            $div_upload -> ContentLoader(
                Content => " a zipped experiment file "
            );
            $div_upload -> ContentLoader(
                Content => $browse_button
            );

            $container_buttons_home -> ContentLoader(
                Content => $h1
            );
            $container_buttons_home -> ContentLoader(
                Content => $h2
            );
            $container_buttons_home -> ContentLoader(
                Content => $h3
            );
            $container_buttons_home -> ContentLoader(
                Content => $h4
            );
            $container_buttons_home -> ContentLoader(
                Content => $h5
            );

            $container_buttons_home -> ContentLoader(
                Content => $div_loader
            );
            $container_buttons_home -> ContentLoader(
                Content => $div_upload
            );

            #return($container_buttons_home);
            return($container_buttons_home);
}
sub div_upload_home_Packager {
    my $div_upload = new HTMLDiv(
        _id => "div_upload",
        _class => "div_upload",
        _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;margin-top:20px;text-align:center;"
    );
    return($div_upload);
}
sub div_loader_home_Packager {
    my $div_loader = new HTMLDiv(
        _id => "div_loader",
        _class => "div_upload",
        _style => "float:left;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;"
    );
    return($div_loader);
}
sub container_data_home_Packager {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    my $div_data_main = new HTMLDiv(
        _id => "div_main",
        _style => "border:0px solid green;height:100%;overflow:hidden;width:100%;margin-top:20px;"
    );

    my ($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot,$div_setup_chroma) = div_setup_home_Packager();

    my $exp_title_input_text = new HTMLInput(
        _type => "text",
        _name => "exp_name_input_text",
        _id => "exp_name_input_text",
        _value => "Experiment Name",
        _size => 20
    );
    my $exp_comment_input_text = new HTMLInput(
        _type => "text",
        _name => "exp_comment_input_text",
        _id => "exp_comment_input_text",
        _value => "Experiment Comments",
        _size => 20
    );
    my $exp_organism_selector = new HTMLSelect(
        _name => "exp_organism_selector",
        _id => "exp_organism_selector",
        _onchange => "toggleONTs(this.value)"
    );
    foreach my $organism (sort keys %{$parameters -> {_organisms_available}}) {
        $exp_organism_selector -> LoadOption(
            HTMLSelectOption => new HTMLSelectOption(
                _value => $organism,
                _text => $organism
            )
        );
    }

    my $experiment_info_container = new HTMLDiv(
            _id => "exp_info_div",
            _class => "exp_info_div",
            _style => "float:left; border:solid magenta 0px;width:49%;height:30%;margin-right:0px; text-align:center;"
    );

    $experiment_info_container -> ContentLoader(
        Content => "<b>Experiment Title </b>"
    );
    $experiment_info_container -> ContentLoader(
        Content => $exp_title_input_text
    );
    $experiment_info_container -> ContentLoader(
        Content => "<br><br>"
    );
    $experiment_info_container -> ContentLoader(
        Content => "<b>Comments </b>"
    );
    $experiment_info_container -> ContentLoader(
        Content => $exp_comment_input_text
    );
    $experiment_info_container -> ContentLoader(
        Content => "<br><br>"
    );
    $experiment_info_container -> ContentLoader(
        Content => "<b>Organism Selected </b>"
    );
    $experiment_info_container -> ContentLoader(
        Content => $exp_organism_selector
    );

    my $div_data = div_data_home_Packager(
        Parameters => $parameters
    );



    $div_data_main -> ContentLoader(
        Content => $experiment_info_container
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_gene
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_meth
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_urna
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_meta
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_prot
    );
    $div_data_main -> ContentLoader(
        Content => $div_setup_chroma
    );
    $div_data_main -> ContentLoader(
        Content => $div_data
    );
    return($div_data_main);
}
sub div_setup_home_Packager {

    #my $div_setup_gene = buildHomeGeneSetupDiv();
    #my $div_setup_prot = buildHomeProteinSetupDiv();
    #my $div_setup_urna = buildHomemiRNASetupDiv();
    #my $div_setup_meth = buildHomeMethylationSetupDiv();
    #my $div_setup_meta = buildHomeMetaboliteSetupDiv();

    my $div_setup_gene = buildHomeSetupDiv(
        _dataType => "gene"
    );
    my $div_setup_prot = buildHomeSetupDiv(
        _dataType => "prot"
    );
    my $div_setup_urna = buildHomeSetupDiv(
        _dataType => "urna"
    );
    my $div_setup_meth = buildHomeSetupDiv(
        _dataType => "meth"
    );
    my $div_setup_meta = buildHomeSetupDiv(
        _dataType => "meta"
    );
    my $div_setup_chroma = buildHomeSetupDiv(
        _dataType => "chroma"
    );

    return($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot,$div_setup_chroma);

    sub buildHomeSetupDiv {

        my %args = (
            _dataType => "gene",
            @_
        );

        my $type = $args{_dataType};
        my $setupDiv = new HTMLDiv (
            _id => "div_setup_$type",
            _class => "setupHomeDiv"
        );
        
        if ($type eq "gene"){
            $setupDiv -> {_style} = "display:block;";
        }
        
        my $idSelector = new HTMLSelect(
            _id => $type."IdTypeSelector",
            _name => $type."IdType",
            _class => $type."IdTypeSelector"
        );

        my $idColumnInputText = new HTMLInput(
            _id => $type."_id_column",
            _name => $type."_id_column",
            _class => "idColumnHomeInputText",
            _type => "text"
        );
        my $devColumnInputText = new HTMLInput(
            _name => $type."_dev_column",
            _id => $type."_dev_column",
            _type => "text"
        );
        my $pvalColumnInputText = new HTMLInput(
            _name => $type."_pvalue_column",
            _id => $type."_pvalue_column",
            _type => "text"
        );
        
        if ($type eq "gene") {
            $setupDiv -> ContentLoader(
                Content => "<b>Genes Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "entrez",
                _text => "EntrezGeneID"
            );
            my $idSelectorOpt2 = new HTMLSelectOption(
                _value => "ensembl",
                _text => "Ensembl"
            );
            my $idSelectorOpt3 = new HTMLSelectOption(
                _value => "symbol",
                _text => "Gene Symbol"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt2
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt3
            );
        }
        if ($type eq "prot") {
            $setupDiv -> ContentLoader(
                Content => "<b>Proteins Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "entry",
                _text => "UniProt Entry"
            );
            my $idSelectorOpt2 = new HTMLSelectOption(
                _value => "entrez",
                _text => "EntrezGeneID"
            );
            my $idSelectorOpt3 = new HTMLSelectOption(
                _value => "symbol",
                _text => "Protein Symbol"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt2
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt3
            );
        }
        if ($type eq "urna") {
            $setupDiv -> ContentLoader(
                Content => "<b>miRNAs Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "mirbase",
                _text => "miRBase"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
        }
        if ($type eq "meth") {
            $setupDiv -> ContentLoader(
                Content => "<b>Methylations Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "entrez",
                _text => "EntrezGeneID"
            );
            my $idSelectorOpt2 = new HTMLSelectOption(
                _value => "ensembl",
                _text => "Ensembl"
            );
            my $idSelectorOpt3 = new HTMLSelectOption(
                _value => "symbol",
                _text => "Gene Symbol"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt2
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt3
            );
        }
        if ($type eq "meta") {
            $setupDiv -> ContentLoader(
                Content => "<b>Metabolites Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "keggcompound",
                _text => "Kegg Compound"
            );
            my $idSelectorOpt2 = new HTMLSelectOption(
                _value => "name",
                _text => "Compound Name"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt2
            );
        }
        if ($type eq "chroma") {
            $setupDiv -> ContentLoader(
                Content => "<b>Chromatin tatus Setup</b>"
            );
            my $idSelectorOpt1 = new HTMLSelectOption(
                _value => "entrez",
                _text => "EntrezGeneID"
            );
            my $idSelectorOpt2 = new HTMLSelectOption(
                _value => "ensembl",
                _text => "Ensembl"
            );
            my $idSelectorOpt3 = new HTMLSelectOption(
                _value => "symbol",
                _text => "Gene Symbol"
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt1
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt2
            );
            $idSelector -> LoadOption(
                HTMLSelectOption => $idSelectorOpt3
            );
        }
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $setupDiv -> ContentLoader(
            Content => "ID Type "
        );
        $setupDiv -> ContentLoader(
            Content => $idSelector
        );
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $setupDiv -> ContentLoader(
            Content => "ID Column "
        );
        $setupDiv -> ContentLoader(
            Content => $idColumnInputText
        );
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $setupDiv -> ContentLoader(
            Content => "Effect Size Column "
        );
        $setupDiv -> ContentLoader(
            Content => $devColumnInputText
        );
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $setupDiv -> ContentLoader(
            Content => "p-value Column "
        );
        $setupDiv -> ContentLoader(
            Content => $pvalColumnInputText
        );
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        
        return($setupDiv);
    }


    sub buildHomeGeneSetupDiv {
        my $div_setup_gene = new HTMLDiv(
            _id => "div_setup_gene",
            _class => "div_setup_gene",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:block;"
        );
        my $gene_id_column_input_text = new HTMLInput(
            _id => "gene_id_column",
            _name => "gene_id_column",
            _type => "text"
        );


        #########
        my $gene_dev_type_select = new HTMLSelect(
            _id => "gene_dev_type",
            _name => "gene_dev_type"
        );
        my $gene_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $gene_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $gene_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $gene_dev_type_select -> LoadOption(
            HTMLSelectOption => $gene_dev_type_select_opt1
        );
        $gene_dev_type_select -> LoadOption(
            HTMLSelectOption => $gene_dev_type_select_opt2
        );
        $gene_dev_type_select -> LoadOption(
            HTMLSelectOption => $gene_dev_type_select_opt3
        );
        #######




        my $gene_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "gene_dev_column",
            _id => "gene_dev_column"
        );
        my $gene_dev_dir_select = new HTMLSelect(
            _id => "gene_dev_dir",
            _name => "gene_dev_dir"
        );
        my $gene_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $gene_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $gene_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $gene_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $gene_dev_dir_select -> LoadOption(
            HTMLSelectOption => $gene_dev_dir_select_opt1
        );
        $gene_dev_dir_select -> LoadOption(
            HTMLSelectOption => $gene_dev_dir_select_opt2
        );
        $gene_dev_dir_select -> LoadOption(
            HTMLSelectOption => $gene_dev_dir_select_opt3
        );
        $gene_dev_dir_select -> LoadOption(
            HTMLSelectOption => $gene_dev_dir_select_opt4
        );
        my $gene_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "gene_dev_thr",
            _name => "gene_dev_thr"
        );
        my $gene_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "gene_pvalue_column",
            _id => "gene_pvalue_column"
        );
        my $gene_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "gene_pvalue_thr",
            _id => "gene_pvalue_thr"
        );
        $div_setup_gene -> ContentLoader(
            Content => "<b>Genes Setup</b>"
        );
        $div_setup_gene -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_gene -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_id_column_input_text
        );
        $div_setup_gene -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_dev_type_select
        );
        $div_setup_gene -> ContentLoader(
            Content => "Column "
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_dev_column_input_text
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_dev_dir_select
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_dev_thr_input_text
        );
        $div_setup_gene -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_gene -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_pvalue_column_input_text
        );
        $div_setup_gene -> ContentLoader(
            Content => " < "
        );
        $div_setup_gene -> ContentLoader(
            Content => $gene_pvalue_thr_input_text
        );
        return($div_setup_gene);
    }
    sub buildHomeProteinSetupDiv {
        my $div_setup_prot = new HTMLDiv(
            _id => "div_setup_prot",
            _class => "div_setup_prot",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $prot_id_column_input_text = new HTMLInput(
            _id => "prot_id_column",
            _name => "prot_id_column",
            _type => "text"
        );
        my $prot_dev_type_select = new HTMLSelect(
            _id => "prot_dev_type",
            _name => "prot_dev_type"
        );
        my $prot_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $prot_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $prot_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $prot_dev_type_select -> LoadOption(
            HTMLSelectOption => $prot_dev_type_select_opt1
        );
        $prot_dev_type_select -> LoadOption(
            HTMLSelectOption => $prot_dev_type_select_opt2
        );
        $prot_dev_type_select -> LoadOption(
            HTMLSelectOption => $prot_dev_type_select_opt3
        );
        my $prot_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "prot_dev_column",
            _id => "prot_dev_column"
        );
        my $prot_dev_dir_select = new HTMLSelect(
            _id => "prot_dev_dir",
            _name => "prot_dev_dir"
        );
        my $prot_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $prot_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $prot_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $prot_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $prot_dev_dir_select -> LoadOption(
            HTMLSelectOption => $prot_dev_dir_select_opt1
        );
        $prot_dev_dir_select -> LoadOption(
            HTMLSelectOption => $prot_dev_dir_select_opt2
        );
        $prot_dev_dir_select -> LoadOption(
            HTMLSelectOption => $prot_dev_dir_select_opt3
        );
        $prot_dev_dir_select -> LoadOption(
            HTMLSelectOption => $prot_dev_dir_select_opt4
        );
        my $prot_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "prot_dev_thr",
            _name => "prot_dev_thr"
        );
        my $prot_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "prot_pvalue_column",
            _id => "prot_pvalue_column"
        );
        my $prot_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "prot_pvalue_thr",
            _id => "prot_pvalue_thr"
        );
        $div_setup_prot -> ContentLoader(
            Content => "<b>Proteins Setup</b>"
        );
        $div_setup_prot -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_prot -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_id_column_input_text
        );
        $div_setup_prot -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_dev_type_select
        );
        $div_setup_prot -> ContentLoader(
            Content => "Column "
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_dev_column_input_text
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_dev_dir_select
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_dev_thr_input_text
        );
        $div_setup_prot -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_prot -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_pvalue_column_input_text
        );
        $div_setup_prot -> ContentLoader(
            Content => " < "
        );
        $div_setup_prot -> ContentLoader(
            Content => $prot_pvalue_thr_input_text
        );
        return($div_setup_prot);
    }
    sub buildHomemiRNASetupDiv {
        my $div_setup_urna = new HTMLDiv(
            _id => "div_setup_urna",
            _class => "div_setup_urna",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $urna_id_column_input_text = new HTMLInput(
            _id => "urna_id_column",
            _name => "urna_id_column",
            _type => "text"
        );
        my $urna_dev_type_select = new HTMLSelect(
            _id => "urna_dev_type",
            _name => "urna_dev_type"
        );
        my $urna_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $urna_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $urna_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $urna_dev_type_select -> LoadOption(
            HTMLSelectOption => $urna_dev_type_select_opt1
        );
        $urna_dev_type_select -> LoadOption(
            HTMLSelectOption => $urna_dev_type_select_opt2
        );
        $urna_dev_type_select -> LoadOption(
            HTMLSelectOption => $urna_dev_type_select_opt3
        );
        my $urna_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "urna_dev_column",
            _id => "urna_dev_column"
        );
        my $urna_dev_dir_select = new HTMLSelect(
            _id => "urna_dev_dir",
            _name => "urna_dev_dir"
        );
        my $urna_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $urna_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $urna_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $urna_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $urna_dev_dir_select -> LoadOption(
            HTMLSelectOption => $urna_dev_dir_select_opt1
        );
        $urna_dev_dir_select -> LoadOption(
            HTMLSelectOption => $urna_dev_dir_select_opt2
        );
        $urna_dev_dir_select -> LoadOption(
            HTMLSelectOption => $urna_dev_dir_select_opt3
        );
        $urna_dev_dir_select -> LoadOption(
            HTMLSelectOption => $urna_dev_dir_select_opt4
        );
        my $urna_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "urna_dev_thr",
            _name => "urna_dev_thr"
        );
        my $urna_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "urna_pvalue_column",
            _id => "urna_pvalue_column"
        );
        my $urna_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "urna_pvalue_thr",
            _id => "urna_pvalue_thr"
        );
        my $urna_strength_select = new HTMLSelect(
            _id => "urna_strength",
            _name => "urna_strength",
            _style => "display:none;"
        );
        my $urna_strength_select_opt1 = new HTMLSelectOption(
            _value => "both",
            _text => "Weak and Strong"
        );
        my $urna_strength_select_opt2 = new HTMLSelectOption(
            _value => "strongonly",
            _text => "Only Strong"
        );
        my $urna_strength_select_opt3 = new HTMLSelectOption(
            _value => "weakonly",
            _text => "Only Weak"
        );
        $urna_strength_select -> LoadOption(
            HTMLSelectOption => $urna_strength_select_opt1
        );
        $urna_strength_select -> LoadOption(
            HTMLSelectOption => $urna_strength_select_opt2
        );
        $urna_strength_select -> LoadOption(
            HTMLSelectOption => $urna_strength_select_opt3
        );
        $div_setup_urna -> ContentLoader(
            Content => "<b>miRNAs Setup</b>"
        );
        $div_setup_urna -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_urna -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_id_column_input_text
        );
        $div_setup_urna -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_dev_type_select
        );
        $div_setup_urna -> ContentLoader(
            Content => "Column "
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_dev_column_input_text
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_dev_dir_select
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_dev_thr_input_text
        );
        $div_setup_urna -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_urna -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_pvalue_column_input_text
        );
        $div_setup_urna -> ContentLoader(
            Content => " < "
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_pvalue_thr_input_text
        );
        $div_setup_urna -> ContentLoader(
            Content => "<br><br>"
        );
        return($div_setup_urna);
    }
    sub buildHomeMetaboliteSetupDiv {
        my $div_setup_meta = new HTMLDiv(
            _id => "div_setup_meta",
            _class => "div_setup_meta",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $meta_id_column_input_text = new HTMLInput(
            _id => "meta_id_column",
            _name => "meta_id_column",
            _type => "text"
        );
        my $meta_dev_type_select = new HTMLSelect(
            _id => "meta_dev_type",
            _name => "meta_dev_type"
        );
        my $meta_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $meta_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $meta_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $meta_dev_type_select -> LoadOption(
            HTMLSelectOption => $meta_dev_type_select_opt1
        );
        $meta_dev_type_select -> LoadOption(
            HTMLSelectOption => $meta_dev_type_select_opt2
        );
        $meta_dev_type_select -> LoadOption(
            HTMLSelectOption => $meta_dev_type_select_opt3
        );
        my $meta_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "meta_dev_column",
            _id => "meta_dev_column"
        );
        my $meta_dev_dir_select = new HTMLSelect(
            _id => "meta_dev_dir",
            _name => "meta_dev_dir"
        );
        my $meta_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $meta_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $meta_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $meta_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $meta_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meta_dev_dir_select_opt1
        );
        $meta_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meta_dev_dir_select_opt2
        );
        $meta_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meta_dev_dir_select_opt3
        );
        $meta_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meta_dev_dir_select_opt4
        );
        my $meta_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "meta_dev_thr",
            _name => "meta_dev_thr"
        );
        my $meta_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "meta_pvalue_column",
            _id => "meta_pvalue_column"
        );
        my $meta_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "meta_pvalue_thr",
            _id => "meta_pvalue_thr"
        );
        $div_setup_meta -> ContentLoader(
            Content => "<b>Metabolites Setup</b>"
        );
        $div_setup_meta -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meta -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_id_column_input_text
        );
        $div_setup_meta -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_dev_type_select
        );
        $div_setup_meta -> ContentLoader(
            Content => "Column "
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_dev_column_input_text
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_dev_dir_select
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_dev_thr_input_text
        );
        $div_setup_meta -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meta -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_pvalue_column_input_text
        );
        $div_setup_meta -> ContentLoader(
            Content => " < "
        );
        $div_setup_meta -> ContentLoader(
            Content => $meta_pvalue_thr_input_text
        );
        return($div_setup_meta);
    }
    sub buildHomeMethylationSetupDiv {
        my $div_setup_meth = new HTMLDiv(
            _id => "div_setup_meth",
            _class => "div_setup_meth",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $meth_id_column_input_text = new HTMLInput(
            _id => "meth_id_column",
            _name => "meth_id_column",
            _type => "text"
        );
        my $meth_dev_type_select = new HTMLSelect(
            _id => "meth_dev_type",
            _name => "meth_dev_type"
        );
        my $meth_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $meth_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $meth_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $meth_dev_type_select -> LoadOption(
            HTMLSelectOption => $meth_dev_type_select_opt1
        );
        $meth_dev_type_select -> LoadOption(
            HTMLSelectOption => $meth_dev_type_select_opt2
        );
        $meth_dev_type_select -> LoadOption(
            HTMLSelectOption => $meth_dev_type_select_opt3
        );
        my $meth_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "meth_dev_column",
            _id => "meth_dev_column"
        );
        my $meth_dev_dir_select = new HTMLSelect(
            _id => "meth_dev_dir",
            _name => "meth_dev_dir"
        );
        my $meth_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $meth_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $meth_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $meth_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $meth_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meth_dev_dir_select_opt1
        );
        $meth_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meth_dev_dir_select_opt2
        );
        $meth_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meth_dev_dir_select_opt3
        );
        $meth_dev_dir_select -> LoadOption(
            HTMLSelectOption => $meth_dev_dir_select_opt4
        );
        my $meth_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "meth_dev_thr",
            _name => "meth_dev_thr"
        );
        my $meth_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "meth_pvalue_column",
            _id => "meth_pvalue_column"
        );
        my $meth_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "meth_pvalue_thr",
            _id => "meth_pvalue_thr"
        );
        $div_setup_meth -> ContentLoader(
            Content => "<b>Methylations Setup</b>"
        );
        $div_setup_meth -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meth -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_id_column_input_text
        );
        $div_setup_meth -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_dev_type_select
        );
        $div_setup_meth -> ContentLoader(
            Content => "Column "
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_dev_column_input_text
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_dev_dir_select
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_dev_thr_input_text
        );
        $div_setup_meth -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_meth -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_pvalue_column_input_text
        );
        $div_setup_meth -> ContentLoader(
            Content => " < "
        );
        $div_setup_meth -> ContentLoader(
            Content => $meth_pvalue_thr_input_text
        );

        return($div_setup_meth);
    }
}
sub div_data_home_Packager {

    my $div_data = new HTMLDiv(
        _id => "div_data",
        _class => "div_data",
        _style => "float:left;border:solid orange 0px;margin-top:40px;margin-left:10px;width:100%;border-top:3px solid grey;padding-top:10px;"
    );
    my $data_type_select = new HTMLSelect(
        _id => "datatype",
        _name => "datatype",
        _onchange => "showhide();"
    );
    my $data_type_select_opt1 = new HTMLSelectOption(
        _value => "gene",
        _text => "Gene/Protein"
    );
    my $data_type_select_opt2 = new HTMLSelectOption(
        _value => "urna",
        _text => "miRNAs"
    );
    my $data_type_select_opt3 = new HTMLSelectOption(
        _value => "meta",
        _text => "Metabolites"
    );
    my $data_type_select_opt4 = new HTMLSelectOption(
        _value => "meth",
        _text => "Methylation"
    );
    my $data_type_select_opt5 = new HTMLSelectOption(
        _value => "prot",
        _text => "Proteins"
    );
    my $data_type_select_opt6 = new HTMLSelectOption(
        _value => "chroma",
        _text => "Chromatin Status"
    );

    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt1
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt2
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt3
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt4
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt5
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt6
    );

    my $gene_data_textarea = new HTMLTextArea(
        _id => "gene_data",
        _name => "gene_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #e6faff; display:block;margin-left:40px;margin-top:40px;"
    );
    my $urna_data_textarea = new HTMLTextArea(
        _id => "urna_data",
        _name => "urna_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #ffb3b3; display:none;margin-left:40px;margin-top:40px;"
    );
    my $meta_data_textarea = new HTMLTextArea(
        _id => "meta_data",
        _name => "meta_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #ffffb3; display:none;margin-left:40px;margin-top:40px;"
    );
    my $meth_data_textarea = new HTMLTextArea(
        _id => "meth_data",
        _name => "meth_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #99e699; display:none;margin-left:40px;margin-top:40px;"
    );
    my $prot_data_textarea = new HTMLTextArea(
        _id => "prot_data",
        _name => "prot_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #e6b3ff; display:none;margin-left:40px;margin-top:40px;"
    );
    my $chroma_data_textarea = new HTMLTextArea(
        _id => "chroma_data",
        _name => "chroma_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #e6b3ff; display:none;margin-left:40px;margin-top:40px;"
    );

    $div_data -> ContentLoader(
        Content => "<b>Data type: </b>"
    );
    $div_data -> ContentLoader(
        Content => $data_type_select
    );
    $div_data -> ContentLoader(
        Content => $gene_data_textarea
    );
    $div_data -> ContentLoader(
        Content => $urna_data_textarea
    );
    $div_data -> ContentLoader(
        Content => $meta_data_textarea
    );
    $div_data -> ContentLoader(
        Content => $meth_data_textarea
    );
    $div_data -> ContentLoader(
        Content => $prot_data_textarea
    );
    $div_data -> ContentLoader(
        Content => $chroma_data_textarea
    );
    return($div_data);
}
sub div_ont_home_packager {

    my %args = (
        Parameters => {},
        @_
    );
    my $parameters = $args{Parameters};
    my $div_ont = new HTMLDiv(
        _id => "div_ont",
        _class => "div_ont",
        _style => "float:left;border:solid orange 0px;margin-top:40px;margin-left:10px;width:100%;border-top:3px solid grey;padding-top:10px;"
    );
    my $ont_search_div = new HTMLDiv(
        _id => "div_ont_search",
        _class => "div_ont_search",
        _style => "border:solid orange 0px;margin-top:40px;margin-bottom:20px;width:100%;"
    );

    my $ont_search_field = new HTMLInput(
        _type => "text",
        _name => "ont_search_text",
        _id => "searchBarONT",
        _onkeyup => "searchONT(event)",
        _placeholder => "Search for Cellular Compartments",
        _value => "",
        _size => 20
    );
    my $ont_search_button = new HTMLInput(
        _type => "button",
        _name => "ont_search_button",
        _id => "ont_search_button",
        _value => "Search",
        _onClick => "searchONT()"
    );
    my %default_onts = (
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

    $ont_search_div -> ContentLoader(
        Content => $ont_search_field
    );
    $ont_search_div -> ContentLoader(
        Content => $ont_search_button
    );

    $div_ont -> ContentLoader(
        Content => $ont_search_div
    );

    foreach my $organism (keys %{$parameters -> {_onts_available}}) {
        print STDERR "HomeBuilder: Loading ONTs for $organism\n";
        my $ont_display = new HTMLDiv(
            _id => "ont_display_$organism",
            _class =>"ont_display",
            _style => "border:5px solid #006699;margin-top:10px; overflow:scroll; height:500px; border-radius:15px; padding:10px;float:left;display:none;"
        );
        my $ont_pool = new HTMLDiv(
            _id => "ont_pool_$organism",
            _class =>"ont_pool",
            _style => "left:1050px;border:5px solid #006699;margin-top:10px; overflow:scroll;border-radius:15px; padding:10px;float:right;height:500px;display:none;"
        );
        my $ont_ul = new HTMLul(
            _id => "ont_ul_$organism",
            _class => "ont_ul"
        );
        my $ont_ul_pool = new HTMLul(
            _id => "ont_ul_pool_$organism",
            _class => "ont_ul_pool"
        );
        $ont_pool -> ContentLoader(
            Content => $ont_ul_pool
        );
        foreach my $ont (sort keys %{$parameters -> {_onts_available} -> {$organism}}) {
            if ($default_onts{$ont}) {
                my $ont_li = new HTMLli(
                    _id => $ont."_".$organism,
                    _name => "onts_selected_".$organism,
                    #_text => $parameters -> {_onts_available} -> {$ont} -> {name}."($ont)",
                    _text => $parameters -> {_onts_available} -> {$organism} -> {$ont} -> {name}." (<a target=\"_blank\" style=\"text-decoration:none;\" href=\"".$parameters -> {_onts_available} -> {$organism} -> {$ont} -> {link}."\">GO!</a>)",
                    _class => "ont_li_pool"
                );
                $ont_ul_pool -> ContentLoader(
                    Content => $ont_li
                );
                next;
            }
            my $ont_li = new HTMLli(
                _id => $ont."_".$organism,
                _name => "onts",
                #_text => $parameters -> {_onts_available} -> {$ont} -> {name}."($ont)",
                _text => $parameters -> {_onts_available} -> {$organism} -> {$ont} -> {name}." (<a target=\"_blank\" style=\"text-decoration:none;\" href=\"".$parameters -> {_onts_available} -> {$organism} -> {$ont} -> {link}."\">GO!</a>)",
                _class => "ont_li"
            );
            my $add_button = new HTMLInput(
                _class => "ul_add_button",
                _type => "button",
                _value => "+",
                _style => "margin-left:25px;width:20px;height:20px;font-size:10px;"
                #_style => "cursor: pointer;top: 50%;right: 0%;padding: 12px 16px;transform: translate(0%, -50%);"
            );
            $ont_li -> ContentLoader(
                Content => $add_button
            );
            $ont_ul -> ContentLoader(
                Content => $ont_li
            );
        }
        $ont_display -> ContentLoader(
            Content => $ont_ul
        );

        $div_ont -> ContentLoader(
            Content => $ont_display
        );
        $div_ont -> ContentLoader(
            Content => $ont_pool
        );
    }

    return($div_ont);
}

sub HomePrinter {
    my %args = (
        @_
    );

    my $script = $args{script};
    my $form = $args{form};

    print "Content-type: text/html\n\n";
    print "<!DOCTYPE html>\n";
    print "<html>\n";
    print "<head>\n";
    print "<meta charset=\"UTF-8\"/>\n";
    print '<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />'."\n";
    print '<meta http-equiv="Pragma" content="no-cache" />'."\n";
    print '<meta http-equiv="Expires" content="0" />'."\n";
    print '<link rel="stylesheet" href="../css/ul.css">'."\n";
    print '<link rel="stylesheet" href="../css/mainDivsHome.css">'."\n";
    print "</head>\n";
    print "<body>";
    $script -> PrintScript();
    $form -> PrintForm();
    print "</body>";
    print "</html>\n";
}
1;