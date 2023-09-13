use strict;
#use warnings;
use lib '/var/www/html/pathlay_demo/cgi-bin/';
use HTMLObjects;
use PathLayUtils;




#TryAgain Form

sub div_main_tryagain_Packager {

    my $div_main_registration = new HTMLDiv(
        _id => "div_main_registration",
        _class => "div_main_registration",
        _style => "border:solid blue 2px;width:100%;margin-top:20px;text-align:center;"
    );
    $div_main_registration -> ContentLoader(
        Content => "<p>Wrong Password. Please try again.</p>"
    );
    return($div_main_registration);
}

#Registration Form

sub div_main_registration_Packager {
    my $div_main_registration = new HTMLDiv(
        _id => "div_main_registration",
        _class => "div_main_registration",
        _style => "border:solid blue 0px;width:100%;margin-top:20px;text-align:center;"
    );
    $div_main_registration -> ContentLoader(
        Content => "<p>It seems you are new user. Please register with the form below.</p>"
    );
    return($div_main_registration);
}

#Home Manager Front-End Routines

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
        _src => $parameters -> {_jsdir}."homeUtils.js"
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
                _type => "button",
                _value => "Load",
                _onClick => "homeExpLoader();"
            );
            my $button_save = new HTMLInput(
                _type => "button",
                _value => "Save",
                _onClick => "submitForm(\'save\');",
                _disabled => 1
            );
            my $button_add = new HTMLInput(
                _type => "button",
                _value => "Add New",
                _onClick => "submitForm(\'add\');",
                _disabled => 1
            );
            my $button_delete = new HTMLInput(
                _type => "button",
                _value => "Delete",
                _onClick => "submitForm(\'delete\');",
                _disabled => 1
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
                _disabled => 1
            );
            my $button_download_home = new HTMLInput(
                _type => "button",
                _value => "Download Home",
                _onClick => "submitForm(\'download_home\');",
                _disabled => 1
            );
            my $upload_button = new HTMLInput(
                _type => "button",
                _value => "Upload",
                _onClick => "submitForm(\'upload\')",
                _disabled => 1
            );
            my $browse_button = new HTMLInput(
                _type => "file",
                _id => "file",
                _name => "file",
                _disabled => 1
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
        _id => "div_upload",
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

    my ($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot) = div_setup_home_Packager();

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

    return($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot);

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

#Configuration Page Front-End Routines

sub div_setup_access_Packager {

    my $div_setup_gene = buildAccessSetupDiv(
        _dataType => "gene"
    );
    my $div_setup_prot = buildAccessSetupDiv(
        _dataType => "prot"
    );
    my $div_setup_urna = buildAccessSetupDiv(
        _dataType => "urna"
    );
    my $div_setup_meth = buildAccessSetupDiv(
        _dataType => "meth"
    );
    my $div_setup_meta = buildAccessSetupDiv(
        _dataType => "meta"
    );

    sub buildAccessSetupDiv {

        my %args = (
            _dataType => "gene",
            @_
        );

        my $type = $args{_dataType};
        my $setupDiv = new HTMLDiv (
            _id => "div_setup_$type",
            _class => "setupAccessDiv"
        );


        my $idTypeInputText = new HTMLInput(
            _id => $type."IdType",
            _name => $type."IdType",
            _class => "idTypeHomeInputText",
            _type => "text"
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
        }
        if ($type eq "prot") {
            $setupDiv -> ContentLoader(
                Content => "<b>Proteins Setup</b>"
            );
        }
        if ($type eq "urna") {
            $setupDiv -> ContentLoader(
                Content => "<b>miRNAs Setup</b>"
            );
        }
        if ($type eq "meth") {
            $setupDiv -> ContentLoader(
                Content => "<b>Methylations Setup</b>"
            );
        }
        if ($type eq "meta") {
            $setupDiv -> ContentLoader(
                Content => "<b>Metabolites Setup</b>"
            );
        }
        $setupDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $setupDiv -> ContentLoader(
            Content => $idTypeInputText
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
    sub buildAccessGeneSetupDiv {
        my $div_setup_gene = new HTMLDiv(
            _id => "div_setup_gene",
            _class => "div_setup_gene",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $gene_id_column_input_text = new HTMLInput(
            _id => "gene_id_column",
            _name => "gene_id_column",
            _type => "text"
        );
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
            Content => "<b>Genes/Proteins Setup</b>"
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
    }
    sub buildAccessProteinSetupDiv {
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
            _id => "prot_pvalue_column",
            _name => "prot_pvalue_column",
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
    }
    sub buildAccessmiRNASetupDiv {
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
            _name => "urna_strength"
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
        $div_setup_urna -> ContentLoader(
            Content => "miRNA Validation Strength: "
        );
        $div_setup_urna -> ContentLoader(
            Content => $urna_strength_select
        );
    }
    sub buildAccessMethylationSetupDiv {
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
    }
    sub buildAccessTFSetupDiv {
        my $div_setup_tf = new HTMLDiv(
            _id => "div_setup_tf",
            _class => "div_setup_tf",
            _style => "float:right;border:solid yellow 0px;width:49%;height:30%;margin-left:0px;text-align:center;display:none;"
        );
        my $tf_id_column_input_text = new HTMLInput(
            _id => "tf_id_column",
            _name => "tf_id_column",
            _type => "text"
        );
        my $tf_dev_type_select = new HTMLSelect(
            _id => "tf_dev_type",
            _name => "tf_dev_type"
        );
        my $tf_dev_type_select_opt1 = new HTMLSelectOption(
            _value => "logFC",
            _text => "logFC"
        );
        my $tf_dev_type_select_opt2 = new HTMLSelectOption(
            _value => "FC",
            _text => "FC"
        );
        my $tf_dev_type_select_opt3 = new HTMLSelectOption(
            _value => "raw",
            _text => "Raw"
        );
        $tf_dev_type_select -> LoadOption(
            HTMLSelectOption => $tf_dev_type_select_opt1
        );
        $tf_dev_type_select -> LoadOption(
            HTMLSelectOption => $tf_dev_type_select_opt2
        );
        $tf_dev_type_select -> LoadOption(
            HTMLSelectOption => $tf_dev_type_select_opt3
        );
        my $tf_dev_column_input_text = new HTMLInput(
            _type => "text",
            _name => "tf_dev_column",
            _id => "tf_dev_column"
        );
        my $tf_dev_dir_select = new HTMLSelect(
            _id => "tf_dev_dir",
            _name => "tf_dev_dir"
        );
        my $tf_dev_dir_select_opt1 = new HTMLSelectOption(
            _value => "out",
            _text => "<>"
        );
        my $tf_dev_dir_select_opt2 = new HTMLSelectOption(
            _value => "min",
            _text => "<"
        );
        my $tf_dev_dir_select_opt3 = new HTMLSelectOption(
            _value => "maj",
            _text => ">"
        );
        my $tf_dev_dir_select_opt4 = new HTMLSelectOption(
            _value => "in",
            _text => "><"
        );
        $tf_dev_dir_select -> LoadOption(
            HTMLSelectOption => $tf_dev_dir_select_opt1
        );
        $tf_dev_dir_select -> LoadOption(
            HTMLSelectOption => $tf_dev_dir_select_opt2
        );
        $tf_dev_dir_select -> LoadOption(
            HTMLSelectOption => $tf_dev_dir_select_opt3
        );
        $tf_dev_dir_select -> LoadOption(
            HTMLSelectOption => $tf_dev_dir_select_opt4
        );
        my $tf_dev_thr_input_text = new HTMLInput(
            _type => "text",
            _id => "tf_dev_thr",
            _name => "tf_dev_thr"
        );
        my $tf_pvalue_column_input_text = new HTMLInput(
            _type => "text",
            _name => "tf_pvalue_column",
            _id => "tf_pvalue_column"
        );
        my $tf_pvalue_thr_input_text = new HTMLInput(
            _type => "text",
            _name => "tf_pvalue_thr",
            _id => "tf_pvalue_thr"
        );
        $div_setup_tf -> ContentLoader(
            Content => "<b>Transcriptional Factors Setup</b>"
        );
        $div_setup_tf -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_tf -> ContentLoader(
            Content => "ID Column "
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_id_column_input_text
        );
        $div_setup_tf -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_dev_type_select
        );
        $div_setup_tf -> ContentLoader(
            Content => "Column "
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_dev_column_input_text
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_dev_dir_select
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_dev_thr_input_text
        );
        $div_setup_tf -> ContentLoader(
            Content => "<br><br>"
        );
        $div_setup_tf -> ContentLoader(
            Content => "p-Value Column"
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_pvalue_column_input_text
        );
        $div_setup_tf -> ContentLoader(
            Content => " < "
        );
        $div_setup_tf -> ContentLoader(
            Content => $tf_pvalue_thr_input_text
        );
    }
    sub buildAccessMetaboliteSetupDiv {
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
    }


    return($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot);
}
sub div_data_access_Packager {

    my $div_data = new HTMLDiv(
        _id => "div_data",
        _class => "div_data",
        _style => "float:left;border:solid orange 0px;margin-top:40px;margin-left:10px;width:100%;display:none;"
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

    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt1
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt2
    );
    $data_type_select -> LoadOption(
        HTMLSelectOption => $data_type_select_opt3
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
    my $meth_data_textarea =  new HTMLTextArea(
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
    return($div_data);
}
sub div_loader_access_Packager {

    my %args = (
        Parameters => {},
        @_
    );
    my $parameters = $args{Parameters};

    my $div_loader = new HTMLDiv(
            _id => "div_loader",
            _class => "div_loader"
    );

    my $load_exp_button = new HTMLInput(
        _id => "load_exp_button",
        _type => "button",
        _value => "Load",
        _onClick => "accessExpLoader();"
    );

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
    my $invert_exp_input_checkbox = new HTMLInput(
        _type => "checkbox",
        _id => "invert",
        _name => "invert",
        _value => "y"
    );
    my $exp_title_input_text = new HTMLInput(
        _type => "text",
        _name => "exp_name_input_text",
        _id => "exp_name_input_text",
        _value => "Experiment Name",
        _size => 20,
        _readonly => 1
    );
    my $exp_comment_input_text = new HTMLInput(
        _type => "text",
        _name => "exp_comment_input_text",
        _id => "exp_comment_input_text",
        _value => "Experiment Comments",
        _size => 20,
        _readonly => 1
    );
    my $exp_organism_input_text = new HTMLInput(
        _type => "text",
        _name => "exp_organism_input_text",
        _id => "exp_organism_input_text",
        _value => "Organism Related",
        _size => 10,
        _readonly => 1
    );


    $div_loader -> ContentLoader(
        Content => $exp_select
    );
    $div_loader -> ContentLoader(
        Content => $load_exp_button
    );
    #$div_loader -> ContentLoader(
    #    Content => $invert_exp_input_checkbox
    #);
    #$div_loader -> ContentLoader(
    #    Content => "<font size=\"-1\">invert experiment</font><a title=\"Fold changes will be inverted\">?</a>"
    #);
    $div_loader -> ContentLoader(
        Content => "<br><br>"
    );
    $div_loader -> ContentLoader(
        Content => "<b>Experiment Title </b>"
    );
    $div_loader -> ContentLoader(
        Content => $exp_title_input_text
    );
    $div_loader -> ContentLoader(
        Content => "<br><br>"
    );
    $div_loader -> ContentLoader(
        Content => "<b>Comments </b>"
    );
    $div_loader -> ContentLoader(
        Content => $exp_comment_input_text
    );
    $div_loader -> ContentLoader(
        Content => "<br><br>"
    );
    $div_loader -> ContentLoader(
        Content => "<b>Organism Selected </b>"
    );
    $div_loader -> ContentLoader(
        Content => $exp_organism_input_text
    );
    return($div_loader);

}
sub access_script_Packager {

    my %args = (
        @_
    );
    my $parameters = $args{Parameters};


    my $access_script = new HTMLScript();
    my @js_functions;
    my @js_variables;
    #$js_functions[0] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."showhide.js"
    #);
    $js_functions[0] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."accessUtils.js"
    );
    #$js_functions[1] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."loaddata.js"
    #);
    #$js_functions[2] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."enable_submit.js"
    #);
    #$js_functions[3] = new HTMLScriptSrc(
    #    _type => "text/javascript",
    #    _src => $parameters -> {_jsdir}."filter_handler.js"
    #);
    $js_functions[1] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."spawnHtmlElements.js"
    );
    $js_functions[2] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."accessCheckUtils.js"
    );

    #$parameters -> {_exps_available}

    $access_script -> FunctionsLoader(
        Content => \@js_functions
    );

    $access_script = BuildExpConfJS(
        Parameters => $parameters,
        Script => $access_script
    );

    unshift(@{$access_script -> {_variables}},"var exp_confs = {};");
    unshift(@{$access_script -> {_variables}},"var host = \"".$parameters -> {_host}."\";");
    unshift(@{$access_script -> {_variables}},"var base = \"".$parameters -> {_home}."\";");

    return($access_script);
}
sub div_exec_buttons_access_Packager {
    my $div_exec_buttons = new HTMLDiv(
        _id => "div_exec_buttons",
        _class => "div_exec_buttons",
        _style => "float:right; border:0px solid green; margin-top:40px; margin-right:150px;"
    );
    my $submit_button = new HTMLInput(
        _id => "main_submit",
        _type => "submit",
        _name => "submit",
        _value => "Submit",
        _style => "height:40px;width:100px;font-family:monospace;font-size:20px;"
    );
    $div_exec_buttons -> ContentLoader(
        Content => $submit_button
    );
    return($div_exec_buttons);
}
sub div_statistic_access_Packager {

    my $div_statistic = new HTMLDiv(
            _id => "div_statistic",
            _class => "div_statistic"
        );
    my $statistic_select = new HTMLSelect(
        _id => "statistic_select",
        _name => "statistic_select"
    );
    my $statistic_select_opt1 = new HTMLSelectOption(
        _value => "Nothing",
        _text => "Nothing"
    );
    my $statistic_select_opt2 = new HTMLSelectOption(
        _value => "FET",
        _text => "FET",
        _disabled => 0
    );
    $statistic_select -> LoadOption(
        HTMLSelectOption => $statistic_select_opt1
    );
    $statistic_select -> LoadOption(
        HTMLSelectOption => $statistic_select_opt2
    );
    my $mode_select = new HTMLSelect(
        _id => "mode_select",
        _name => "mode_select",
        _onchange => "displayThresholdsByMode()"
    );
    my $mode_select_opt1 = new HTMLSelectOption(
        _value => "full",
        _text => "Effect Size"
    );
    my $mode_select_opt2 = new HTMLSelectOption(
        _value => "id_only",
        _text => "ID Only"
    );

    $mode_select -> LoadOption(
        HTMLSelectOption => $mode_select_opt1
    );
    $mode_select -> LoadOption(
        HTMLSelectOption => $mode_select_opt2
    );


    my $nodeg_select = new HTMLSelect(
        _id => "nodeg_select",
        _name => "nodeg_select"
    );
    my $nodeg_select_opt1 = new HTMLSelectOption(
        _value => "all",
        _text => "miRNAs + Methylations + TFs",
    );
    my $nodeg_select_opt2 = new HTMLSelectOption(
        _value => "urna_only",
        _text => "Only miRNAs",
    );
    my $nodeg_select_opt3 = new HTMLSelectOption(
        _value => "meth_only",
        _text => "Only Methylations",
    );
    my $nodeg_select_opt4 = new HTMLSelectOption(
        _value => "tf_only",
        _text => "Only TFs",
    );
    my $nodeg_select_opt5 = new HTMLSelectOption(
        _value => "urna_meth",
        _text => "miRNAs + Methylations",
    );
    my $nodeg_select_opt6 = new HTMLSelectOption(
        _value => "urna_tf",
        _text => "miRNAs + TFs",
    );
    my $nodeg_select_opt7 = new HTMLSelectOption(
        _value => "meth_tf",
        _text => "Methylations + TFs",
    );
    my $nodeg_select_opt8 = new HTMLSelectOption(
        _value => "none",
        _text => "None",
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt1
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt2
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt3
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt4
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt5
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt6
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt7
    );
    $nodeg_select -> LoadOption(
        HTMLSelectOption => $nodeg_select_opt8
    );

    my $nodeg_select_urna_checkbox = new HTMLInput(
        _id => "nodeg_select_urna",
        _type => "checkbox",
        _name => "nodeg_select_urna",
        _onClick => "checkBox(this,'enableurna')",
        _value => 1,
        _checked => 0
    );
    my $nodeg_select_meth_checkbox = new HTMLInput(
        _id => "nodeg_select_meth",
        _type => "checkbox",
        _name => "nodeg_select_meth",
        _onClick => "checkBox(this,'enablemeth')",
        _value => 1,
        _checked => 0
    );
    my $nodeg_select_tf_checkbox = new HTMLInput(
        _id => "nodeg_select_tf",
        _type => "checkbox",
        _name => "nodeg_select_tf",
        _onClick => "checkBox(this,'enabletfs')",
        _value => 1,
        _checked => 0
    );

    ###################

    #my $filter_select_div = new HTMLDiv(
    #    _id => "div_filter_select",
    #    _class => "div_filter_select"
    #);
    my $filter_select_pval = new HTMLSelect(
        _id => "filter_select_pval",
        _name => "filter_select_pval",
        _onchange => "displayThresholdsByMode()"
    );
    my $filter_select_pval_opt4 =  new HTMLSelectOption(
        _value => "filter_none",
        _text => "Disabled"
    );
    #my $filter_select_opt2 =  new HTMLSelectOption(
    #    _value => "filter_de",
    #    _text => "Filter DEVs"
    #);
    my $filter_select_pval_opt3 =  new HTMLSelectOption(
        _value => "filter_p",
        _text => "Enabled",
        _disabled => 1
    );
    #my $filter_select_opt1 =  new HTMLSelectOption(
    #    _value => "filter_full",
    #    _text => "Full"
    #);
    #$filter_select -> LoadOption(
    #    HTMLSelectOption => $filter_select_opt1
    #);
    #$filter_select -> LoadOption(
    #    HTMLSelectOption => $filter_select_opt2
    #);
    $filter_select_pval -> LoadOption(
        HTMLSelectOption => $filter_select_pval_opt4
    );
    $filter_select_pval -> LoadOption(
        HTMLSelectOption => $filter_select_pval_opt3
    );
    #$filter_select_div -> ContentLoader(
    #    Content => "<b>Filter:</b>"
    #);
    #$filter_select_div -> ContentLoader(
    #    Content => $filter_select
    #);
    my $filter_select_es = new HTMLSelect(
        _id => "filter_select_es",
        _name => "filter_select_es",
        _onchange => "displayThresholdsByMode()"
    );
    my $filter_select_es_opt1 =  new HTMLSelectOption(
        _value => "filter_left",
        _text => "Left Only"
    );
    my $filter_select_es_opt2 =  new HTMLSelectOption(
        _value => "filter_right",
        _text => "Right Only"
    );
    my $filter_select_es_opt3 =  new HTMLSelectOption(
        _value => "filter_both",
        _text => "Left and Right"
    );
    $filter_select_es -> LoadOption(
        HTMLSelectOption => $filter_select_es_opt1
    );
    $filter_select_es -> LoadOption(
        HTMLSelectOption => $filter_select_es_opt2
    );
    $filter_select_es -> LoadOption(
        HTMLSelectOption => $filter_select_es_opt3
    );


    my $maps_db_select = new HTMLSelect(
        _id => "maps_db_select",
        _name => "maps_db_select",
        _onchange => "enable_submit()"
    );
    my $maps_db_select_opt1 = new HTMLSelectOption(
        _value => "kegg",
        _text => "KEGG"
    );
    my $maps_db_select_opt2 = new HTMLSelectOption(
        _value => "wikipathways",
        _text => "WikiPathways",
        _disabled => 0
    );
    $maps_db_select -> LoadOption(
        HTMLSelectOption => $maps_db_select_opt1
    );
    $maps_db_select -> LoadOption(
        HTMLSelectOption => $maps_db_select_opt2
    );
    my $enablegene_checkbox = new HTMLInput(
        _id => "enablegene",
        _type => "checkbox",
        _name => "enablegene",
        _onClick => "enable_submit()",
        _value => 1,
        _checked => 1
    );
    my $enableprot_checkbox = new HTMLInput(
        _id => "enableprot",
        _type => "checkbox",
        _name => "enableprot",
        _onClick => "enable_submit()",
        _value => 1,
        _checked => 0
    );
    my $enableurna_checkbox = new HTMLInput(
        _id => "enableurna",
        _type => "checkbox",
        _name => "enableurna",
        _onClick => "enable_submit()",
        _value => 1
    );
    my $enablemeta_checkbox = new HTMLInput(
        _id => "enablemeta",
        _type => "checkbox",
        _name => "enablemeta",
        _onClick => "enable_submit()",
        _value => 1
    );
    my $enablemeth_checkbox = new HTMLInput(
        _id => "enablemeth",
        _type => "checkbox",
        _name => "enablemeth",
        _onClick => "enable_submit()",
        _value => 1
    );
    my $enabletfs_checkbox = new HTMLInput(
        _id => "enabletfs",
        _type => "checkbox",
        _name => "enabletfs",
        _onClick => "enable_submit()",
        _value => 1,
        _checked => 0
    );





    $div_statistic -> ContentLoader(
        Content => "<b>Mode:</b>"
    );
    $div_statistic -> ContentLoader(
        Content => $mode_select
    );

    #$div_statistic -> ContentLoader(
    #    Content => $filter_select_div
    #);
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );

    ###################################
    
    $div_statistic -> ContentLoader(
        Content => "<b>p-Value Threshold: </b>"
    );
    $div_statistic -> ContentLoader(
        Content => $filter_select_pval
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );
    $div_statistic -> ContentLoader(
        Content => "<font id=\"effectSizeEnablerFont\"><b>Effect Size Threshold: </b></font>"
    );
    $div_statistic -> ContentLoader(
        Content => $filter_select_es
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );
    ###################################

    $div_statistic -> ContentLoader(
        Content => "<b>Load NODEGs from:</b>"
    );

    $div_statistic -> ContentLoader(
    Content => $nodeg_select_urna_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "miRNAs "
    );
    $div_statistic -> ContentLoader(
    Content => $nodeg_select_meth_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Methylations"
    );
    $div_statistic -> ContentLoader(
    Content => $nodeg_select_tf_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "TFs"
    );

    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );
    $div_statistic -> ContentLoader(
        Content => "<b>Map Restriction Procedure:</b>"
    );
    $div_statistic -> ContentLoader(
        Content => $statistic_select
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );
    $div_statistic -> ContentLoader(
        Content => "<b>Maps Database:</b>"
    );
    $div_statistic -> ContentLoader(
        Content => $maps_db_select
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );

    $div_statistic -> ContentLoader(
        Content => "<b>Enable TFs:</b>"
    );
    $div_statistic -> ContentLoader(
        Content => $enabletfs_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );
    $div_statistic -> ContentLoader(
        Content => "<b>Select Maps using:</b>"
    );
    $div_statistic -> ContentLoader(
        Content => $enablegene_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Genes"
    );
    $div_statistic -> ContentLoader(
        Content => $enableprot_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Proteins"
    );

    $div_statistic -> ContentLoader(
        Content => $enableurna_checkbox
    );

    $div_statistic -> ContentLoader(
        Content => "miRNAs"
    );

    $div_statistic -> ContentLoader(
        Content => $enablemeth_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Methylations"
    );
    $div_statistic -> ContentLoader(
        Content => $enablemeta_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Metabolites"
    );
    $div_statistic -> ContentLoader(
        Content => "<br><br>"
    );

    my $thresholdDiv = thresholdDivBuilder();
    $div_statistic -> ContentLoader(
        Content => $thresholdDiv
    );

    return($div_statistic);



    sub thresholdDivBuilder {


        my $thresholdDiv = new HTMLDiv(
            _id => "thresholdDiv",
            _class => "thresholdDiv"
        );
        my $thresholdSelectDiv = new HTMLDiv (
            _id => "thresholdSelectDiv",
            _class => "thresholdSelectDiv"
        );

        my $geneThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "gene"
        );
        my $protThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "prot"
        );
        my $urnaThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "urna"
        );
        my $methThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "meth"
        );
        my $metaThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "meta"
        );

        my $thresholdSelect = new HTMLSelect(
            _id => "thresholdSelect",
            _class => "thresholdSelect",
            _onchange => "toggleThresholds(this.selectedOptions[0].value)",
            _style => "display:none;"
        );

        $thresholdSelectDiv -> ContentLoader(
            Content => $thresholdSelect
        );

        $thresholdDiv -> ContentLoader(
            Content => $thresholdSelectDiv
        );
        $thresholdDiv -> ContentLoader(
            Content => $geneThresholdInputDiv
        );
        $thresholdDiv -> ContentLoader(
            Content => $protThresholdInputDiv
        );
        $thresholdDiv -> ContentLoader(
            Content => $urnaThresholdInputDiv
        );
        $thresholdDiv -> ContentLoader(
            Content => $methThresholdInputDiv
        );
        $thresholdDiv -> ContentLoader(
            Content => $metaThresholdInputDiv
        );

        return($thresholdDiv);
    }

    sub thresholdInputDivBuilder {

        my %args = (
            _dataType => "gene",
            @_
        );

        my $type = $args{_dataType};

        my $thresholdDiv = new HTMLDiv(
            _id => $type."ThresholdInputDiv",
            _class => "thresholdInputDiv"
        );

        my $thresholdLeftInputText = new HTMLInput(
            _id => $type."LeftThreshold",
            _name => $type."LeftThreshold",
            _type => "number",
            _class => "thresholdInput Effect Left",
            _step => "0.1"
            
        );
        my $thresholdRightInputText = new HTMLInput(
            _id => $type."RightThreshold",
            _name => $type."RightThreshold",
            _type => "number",
            _class => "thresholdInput Effect Right",
            _step => "0.1"
        );
        my $thresholdpValInputText = new HTMLInput(
            _id => $type."pValThreshold",
            _name => $type."pValThreshold",
            _type => "number",
            _class => "thresholdInput pVal",
            _step => "0.01"
        );

        $thresholdDiv -> ContentLoader(
            Content => "<font class=\"effectSizeFont Left\"><b>Effect Size < </b></font>"
        );
        $thresholdDiv -> ContentLoader(
            Content => $thresholdLeftInputText
        );
        $thresholdDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $thresholdDiv -> ContentLoader(
            Content => "<font class=\"effectSizeFont Right\"><b>Effect Size > </b></font>"
        );
        $thresholdDiv -> ContentLoader(
            Content => $thresholdRightInputText
        );
        $thresholdDiv -> ContentLoader(
            Content => "<br><br>"
        );
        $thresholdDiv -> ContentLoader(
            Content => "<font class=\"pValFont\"><b>p-value < </b></font>"
        );
        $thresholdDiv -> ContentLoader(
            Content => $thresholdpValInputText
        );
        $thresholdDiv -> ContentLoader(
            Content => "<br><br>"
        );
        return($thresholdDiv);
    }

}

#Results Page Front-End Routines

sub results_style_Packager {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    my $style_section = new HTMLStyle();
    my @style_links;
    opendir(STYLEDIR,$parameters -> {_styledir});
    foreach my $cssfile (sort(readdir(STYLEDIR))) {
        next if ($cssfile !~ /\.css$/);
        #print $cssfile."\n";
        my $css = new HTMLStyleLink(
            _rel => "stylesheet",
            _href => $parameters -> {_styledir}."$cssfile"
        );
        #$css -> PrintStyleLink();
        push(@style_links,$css);
    }
    closedir(STYLEDIR);

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
    opendir(JSDIR,$parameters -> {_jsdir});
    foreach my $jsfile (sort(readdir(JSDIR))) {
        next if ($jsfile !~ /.js$/);
        next if ($jsfile eq "wz_tooltip.js");
        next if ($jsfile eq "window-engine.js");
        next if ($jsfile eq "ont_ul_manager.js");
        my $js_function = new HTMLScriptSrc(
            _type => "text/javascript",
            _src => $parameters -> {_jsdir}."$jsfile"
        );
        #$js_function -> PrintScriptSrc();
        push(@js_functions,$js_function);
    }
    closedir(JSDIR);
    $script_section -> FunctionsLoader(
        Content => \@js_functions
    );

    my $first_js = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."wz_tooltip.js"
    );

    unshift(@{$script_section -> {_functions}},$first_js);
    return($script_section);
}

#Main Front-End Routines
sub RegistrationBuilder {
    my %args = (
        @_
    );

    my $form = new HTMLForm(
        _id => "main",
        _name => "pathlay",
        _action => "../cgi-bin/pathlay_home.pl",
        _method => "post",
        _enctype => "multipart/form-data"
    );
    my $container4_home = container4_Packager(
        Title => "PathLay - Registration"
    );
    my $container5_home = container5_Packager(
        Container4 => $container4_home
    );
    my $div_main_registration = div_main_registration_Packager();
    my $hidden_input = new HTMLInput(
        _type => "hidden",
        _id => "ope",
        _name => "ope",
        _value => ""
    );
    #<center>
    #E-mail <input type="text" name="username" id="username" size="20">
    #<br></br>
    #Password <input type="text" name="password" id="password" size="20">
    #</center>
    my $username_text = new HTMLInput(
        _type => "text",
        _name => "username",
        _id => "username"
    );
    my $password_text = new HTMLInput(
        _type => "text",
        _name => "password",
        _id => "password"
    );
    my $submit = new HTMLInput(
        _type => "button",
        _value => "Register",
        _onClick => "submitForm('register');"
    );

    $form -> ContentLoader(
        Content => $container5_home
    );
    $form -> ContentLoader(
        Content => $div_main_registration
    );
    $form -> ContentLoader(
        Content => $hidden_input
    );
    $form -> ContentLoader(
        Content => "<center> E-mail"
    );
    $form -> ContentLoader(
        Content => $username_text
    );
    $form -> ContentLoader(
        Content => "<br><br> Password "
    );
    $form -> ContentLoader(
        Content => $password_text
    );
    $form -> ContentLoader(
        Content => "<br><br>"
    );
    $form -> ContentLoader(
        Content => $submit
    );

    $form -> ContentLoader(
        Content => "</center>"
    );

    return($form);
}
sub TryAgainBuilder {

    my %args = (
        @_
    );

    my $form = new HTMLForm(
        _id => "main",
        _name => "pathlay",
        _action => "../cgi-bin/pathlay_home.pl",
        _method => "post",
        _enctype => "multipart/form-data"
    );
    my $container4_home = container4_Packager(
        Title => "PathLay - Registration"
    );
    my $container5_home = container5_Packager(
        Container4 => $container4_home
    );
    my $div_main_tryagain = div_main_tryagain_Packager();


    $form -> ContentLoader(
        Content => $container5_home
    );
    $form -> ContentLoader(
        Content => $div_main_tryagain
    );

    return($form);
}
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
        _enctype => "multipart/form-data"
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
sub AccessBuilder {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};

    $parameters -> LoadAvailableOrganisms();

    $parameters -> LoadAvailableExps(
        UsersDir => $parameters->{_base}."/pathlay_users/".$parameters->{_home}."/"
    );

    my $access_script = access_script_Packager(
        Parameters => $parameters
    );

    my $container4_access = container4_Packager(
        Title => "PathLay - Analysis Configuration"
    );

    my $container5_access = container5_Packager(
        Container4 => $container4_access
    );

    my $config_container = new HTMLDiv(
        _id => "configContainer"
    );

    my $div_access_main = new HTMLDiv(
        _id => "div_main",
        _style => "border:0px solid green;height:100%;overflow:hidden;width:100%;margin-top:20px;"
    );

    my $div_loader = div_loader_access_Packager(
        Parameters => $parameters
    );
    my ($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot) = div_setup_access_Packager();
    my $div_data = div_data_access_Packager();

    my $div_statistic = div_statistic_access_Packager();
    my $div_exec_buttons = div_exec_buttons_access_Packager();


    $div_access_main -> ContentLoader(
        Content => $div_loader
    );
    $div_access_main -> ContentLoader(
        Content => $div_setup_gene
    );
    $div_access_main -> ContentLoader(
        Content => $div_setup_urna
    );
    $div_access_main -> ContentLoader(
        Content => $div_setup_meta
    );
    $div_access_main -> ContentLoader(
        Content => $div_setup_meth
    );
    $div_access_main -> ContentLoader(
        Content => $div_setup_prot
    );
    $div_access_main -> ContentLoader(
        Content => $div_data
    );
    $div_access_main -> ContentLoader(
        Content => $div_statistic
    );
    $div_access_main -> ContentLoader(
        Content => $div_exec_buttons
    );

    my $form = new HTMLForm(
            _id => "main_form",
            _name => "pathlay",
            _action => "../cgi-bin/pathlay.pl",
            _method => "post",
            _target => "_blank"
    );


    $config_container -> ContentLoader(
        Content => "<br>Hi ".$parameters -> {_username}.", please Load your experiment using the drop down menu and clicking the \"Load\" button.<br>"
    );
    $config_container -> ContentLoader(
        Content => $div_access_main
    );

    my $h1 = new HTMLInput(
        _id => "h1",
        _name => "h1",
        _type => "text",
        _style => "display:none;",
        _value => $parameters -> {_username}
    );

    my $h2 = new HTMLInput(
        _id => "h2",
        _name => "h2",
        _type => "text",
        _style => "display:none;",
        _value => $parameters -> {_password}
    );

    my $h3 = new HTMLInput(
        _id => "h3",
        _name => "h3",
        _type => "text",
        _style => "display:none;",
        _value => $parameters -> {_home}
    );

    my $h4 = new HTMLInput(
        _id => "h4",
        _name => "h4",
        _type => "text",
        _style => "display:none;",
        _value => $parameters -> {_host}
    );

    $form -> ContentLoader(
        Content => $h1
    );
    $form -> ContentLoader(
        Content => $h2
    );
    $form -> ContentLoader(
        Content => $h3
    );
    $form -> ContentLoader(
        Content => $h4
    );
    $form -> ContentLoader(
        Content => $container5_access
    );
    $form -> ContentLoader(
        Content => $config_container
    );

    return($access_script,$form);
}
sub ResultsBuilder {
    my %args = (
        @_
    );
    my $parameters = $args{Parameters};
    #my $script_section = $args{Script};
    #my $map_selector = $args{MapSelector};
    #my $gene_selector_main_html = $args{GeneIDSelector};
    #my $urna_selector_main_html = $args{miRNAIDSelector};
    #my $meta_selector_main_html = $args{MetaIDSelector};
    my $gene_selector_main = $args{gene_selector_main};
    my $urna_selector_main = $args{urna_selector_main};
    my $meta_selector_main = $args{meta_selector_main};
    my $prot_selector_main = $args{prot_selector_main};
    my $tf_selector_main = $args{tf_selector_main};
    my $genesel_js_var = $args{genesel_js_var};
    my $urnasel_js_var = $args{urnasel_js_var};
    my $metasel_js_var = $args{metasel_js_var};
    my $protsel_js_var = $args{protsel_js_var};
    my $tfsel_js_var = $args{tfsel_js_var};
    my $gene2comp_js_var = $args{gene2comp_js_var};
    my $urna2comp_js_var = $args{urna2comp_js_var};
    my $meta2comp_js_var = $args{meta2comp_js_var};
    my $prot2comp_js_var = $args{prot2comp_js_var};
    my $tf2comp_js_var = $args{tf2comp_js_var};
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
    ($script_section,my $gene_selector_main_html) = results_gene_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        genesel_js_var => $genesel_js_var,
        gene2comp_js_var => $gene2comp_js_var,
        gene_selector_main => $gene_selector_main
    );
    ($script_section,my $urna_selector_main_html) = results_urna_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        urnasel_js_var => $urnasel_js_var,
        urna2comp_js_var => $urna2comp_js_var,
        urna_selector_main => $urna_selector_main
    );
    ($script_section,my $meta_selector_main_html) = results_meta_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        metasel_js_var => $metasel_js_var,
        meta2comp_js_var => $meta2comp_js_var,
        meta_selector_main => $meta_selector_main
    );
    ($script_section,my $prot_selector_main_html) = results_prot_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        protsel_js_var => $protsel_js_var,
        prot2comp_js_var => $prot2comp_js_var,
        prot_selector_main => $prot_selector_main
    );
    ($script_section,my $tf_selector_main_html) = results_tfs_selector_Packager(
        Parameters => $parameters,
        Script => $script_section,
        tfsel_js_var => $tfsel_js_var,
        tf2comp_js_var => $tf2comp_js_var,
        tf_selector_main => $tf_selector_main
    );

    my $container4 = results_container4_Packager();
    my $settings_div = results_settings_div_Packager();
    my $logistics_div = results_logistics_div_Packager(
        Parameters => $parameters,
        GeneIDSelector => \%{$gene_selector_main -> {_data}}, 
        miRNAIDSelector => \%{$urna_selector_main -> {_data}}, 
        MetaIDSelector => \%{$meta_selector_main -> {_data}}, 
        ProtIDSelector => \%{$prot_selector_main -> {_data}}
    );
    my $legend_div = results_legend_div_Packager();
    my $highlighters_div = results_highlighters_div_Packager(
        Parameters => $parameters,
        GeneIDSelectorMain => $gene_selector_main_html,
        miRNAIDSelectorMain => $urna_selector_main_html,
        MetaIDSelectorMain => $meta_selector_main_html,
        ProtIDSelectorMain => $prot_selector_main_html,
        TFIDSelectorMain => $tf_selector_main_html,
        ONTIDSelectorMain => $ont_selector_main_html,
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

    unshift(@{$script_section -> {_variables}},"document.onkeydown = checkKey;\n");
    unshift(@{$script_section -> {_variables}},"var metasel = {};\n");
    unshift(@{$script_section -> {_variables}},"var urnasel = {};\n");
    unshift(@{$script_section -> {_variables}},"var genesel = {};\n");
    unshift(@{$script_section -> {_variables}},"var protsel = {};\n");
    unshift(@{$script_section -> {_variables}},"var tfsel = {};\n");
    unshift(@{$script_section -> {_variables}},"var meta2comp = {};\n");
    unshift(@{$script_section -> {_variables}},"var urna2comp = {};\n");
    unshift(@{$script_section -> {_variables}},"var gene2comp = {};\n");
    unshift(@{$script_section -> {_variables}},"var prot2comp = {};\n");
    unshift(@{$script_section -> {_variables}},"var tf2comp = {};\n");
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
            Content => "<b> PathLay - MAPS</b>"
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

    #Results Container2 (mapselector and clickers)
    sub results_map_selector_Packager {

        my %args = (
            @_
        );

        my @map_ids = @{$args{MapIDs}};
        my @map_names = @{$args{MapNames}};
        my %nums_for_selector = %{$args{Nums}};

        my $map_selector = new HTMLSelect(
            _id => "mapselect",
            _name => "mapselect",
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
        #my $legend_clicker = '<br><a class="thumbnail" style="float:left;" href="#thumb\">Legend<span><img src="../src/symbols.png" width="800px"/></span></a>';
        my $legendClickerFont = new HTMLFont(
            _id => "legend_clicker",
            _name => "legend_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "?",
            _onclick => "toggleOverDiv('legendDiv')"
        );
        my $selectorsClickerFont = new HTMLFont(
            _id => "selectors_clicker",
            _name => "selectors_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "Selectors",
            _onclick => "toggleOverDiv('logistics_div')"
        );
        my $settingsClickerFont = new HTMLFont(
            _id => "settings_clicker",
            _name => "settings_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "Settings",
            _onclick => "toggleOverDiv('settings_div')"
        );
        my $clipboardClickerFont = new HTMLFont(
            _id => "button1",
            _name => "clipboard_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "Clipboard"
        );
        my $shotClickerFont = new HTMLFont(
            _id => "shot_clicker",
            _name => "shot_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "Screenshot",
            _onclick => "screenshot()"
        );
        my $highlightClickerFont = new HTMLFont(
            _id => "highlight_clicker",
            _name => "highlight_clicker",
            _class => "clicker",
            #_style => "margin-left:10px;margin-right:10px;float:right;cursor:pointer;",
            _size => "+1",
            _color => "white",
            _text => "Highlight",
            _onclick => "toggleOverDiv('idselectors')"
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
            _onClick => "change(\'trasp\',\'u\')"
        );
        my $transparencyDownButton = new HTMLInput(
            _id => "transparency_down",
            _type => "button",
            _value => "Transparency Down",
            _onClick => "change(\'trasp\',\'d\')"
        );
        my $sizeUpButton = new HTMLInput(
            _id => "size_up",
            _type => "button",
            _value => "Size Up",
            _onClick => "change(\'size\',\'u\')"
        );
        my $sizeDownButton = new HTMLInput(
            _id => "size_down",
            _type => "button",
            _value => "Size Down",
            _onClick => "change(\'size\',\'d\')"
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
            Content => $sizeFont
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
            Content => $transparencyFont
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

        if ($parameters -> {_mode_select} ne "id_only") {
            $logisticsDiv_agreement_selectors -> ContentLoader(
                Content => $agreementSelectionFont
            );
        }


        if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth}) {
            
            push @type_options,new HTMLSelectOption(
                _value => "gene",
                _text => "Gene",
                _width => 10
            );
            my $gene_selector_logical_html = new HTMLSelect(
                _id => "select1b",
                _name => "select1b",
                _onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
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
                _onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
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
                _onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
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
                _onchange => "activate_element_for_logic(this.selectedOptions[0].value)",
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
            $parameters -> {_enabletfs} ||
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
                        _text => "prot"
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
            _onClick => "add_element_to_logic(active_logical_selected_element)"
        );
        my $runlogic_button = new HTMLInput(
            _id => "runlogic",
            _type => "button",
            _value => "Select",
            _onClick => "pathfilter_logic(logical_pool_content,\'run\')"
        );
        my $resetlogic_button = new HTMLInput(
            _id => "resetlogic",
            _type => "button",
            _value => "Reset",
            _onClick => "pathfilter_logic(logical_pool_content,\'reset\')"
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
        my $logisticsDiv_pool_header2 = new HTMLDiv(
            _id => "logistics_div_pool_header2",
            _class => "logistics_div_pool_header",
            _style => "border:0px solid yellow;min-width:100%;overflow:hidden;background-color:#006699;text-align:center;opacity:0.9;border-radius: 0px 0px 0 0;"
        );
        my $logisticsDiv_pool = new HTMLDiv(
            _id => "logistics_div_pool",
            _class => "logistics_div_pool",
            _style => "float:right;border:1px #006699;min-width:100%;min-height:50px;max-height:100px;overflow: scroll;background-color:white;"
        );

        my $logisticsDiv_pool_agreement = new HTMLDiv(
            _id => "logistics_div_pool_agreement",
            _class => "logistics_div_pool_agreement",
            _style => "float:right;border:1px #006699;min-width:100%;min-height:50px;max-height:100px;overflow: scroll;background-color:white;" ##f2f2f2
        );


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
            _id => "logistics_ul_pool",
            _class => "logistics_ul_pool"
        );
        my $logistics_ul_pool_agreement = new HTMLul(
            _id => "logistics_ul_pool_agreement",
            _class => "logistics_ul_pool"
        );


        $logisticsDiv_pool -> ContentLoader(
            Content => $logistics_ul_pool
        );
        $logisticsDiv_pool_header1 -> ContentLoader(
            Content => "<p class=\"windowTitle\" style=\"margin-left:10px;\"><font size=\"+0\" color=\"white\">Ids Selected</font></p>"
        );
        $logisticsDiv_pool_header2 -> ContentLoader(
            Content => "<p class=\"windowTitle\" style=\"margin-left:10px;\"><font size=\"+0\" color=\"white\">Agreements Selected</font></p>"
        );

        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool_header1
        );
        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool
        );
        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool_header2
        );

        if ($parameters -> {_mode_select} ne "id_only") {
            $logisticsDiv_pool_agreement -> ContentLoader(
                Content => $logistics_ul_pool_agreement
            );
        }
        

        $logisticsDiv_pool_wrapper -> ContentLoader(
            Content => $logisticsDiv_pool_agreement
        );

        $logisticsDiv_selectors_wrapper -> ContentLoader(
            Content => $logisticsDiv_selectors
        );
        $logisticsDiv_selectors_wrapper -> ContentLoader(
            Content => "<br><br>"
        );
        if ($parameters -> {_mode_select} ne "id_only") {
            $logisticsDiv_selectors_wrapper -> ContentLoader(
                Content => $logisticsDiv_agreement_selectors
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

        my $debug = 0;
        print STDERR "--results_legend_div_packager--\n" if ($debug);
        my $legendDiv = new HTMLDiv(
            _id => "legendDiv",
            _class => "overDivSection"
        );
        my $legendImg = new HTMLImg(
            _id => "legendImg",
            _src => "../src/symbols.png"
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
        my @idselectors;
        if ($parameters -> {_enablegene} || $parameters -> {_enablenodeg} || $parameters -> {_enablemeth}) {
            if ($args{GeneIDSelectorMain}) {
                push(@idselectors,$args{GeneIDSelectorMain});
            }
            push(@idselectors,$args{ONTIDSelectorMain});
        }
        if ($parameters -> {_enableprot}) {
            if ($args{ProtIDSelectorMain}) {
                push(@idselectors,$args{ProtIDSelectorMain});
            } #? ont
        }
        if ($parameters -> {_enableurna}) {
            if ($args{miRNAIDSelectorMain}) {
                push(@idselectors,$args{miRNAIDSelectorMain});
            }
        }
        if ($parameters -> {_enablemeta}) {
            if ($args{MetaIDSelectorMain}){
                push(@idselectors,$args{MetaIDSelectorMain});
            }
        }
        if ($parameters -> {_enabletfs}) {
            if ($args{TFIDSelectorMain}) {
                #$idselectors_div -> ContentLoader(
                #    Content => $args{TFIDSelector}
                #);
                push(@idselectors,$args{TFIDSelectorMain});
            }
        }

        $idselectors[0] -> {_style} =~ s/none/block/;
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
        foreach my $html_selector (@idselectors) {
            $highlightersDiv -> ContentLoader(
                Content => $html_selector
            );
        }
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
            _onchange => "enable_selectors_results(this.value)",
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


        if ($parameters -> {_enablegene} == 1 || $parameters -> {_enablemeth} == 1 || $parameters -> {_enablenodeg} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_gene_html
            );
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_ont_html
            );
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
        if ($parameters -> {_enabletfs} == 1) {
            $type_selector_main_html -> LoadOption(
                HTMLSelectOption => $type_option_tf_html
            );
        }
        return($type_selector_main_html);
    }
    sub results_gene_selector_Packager {

        my %args = (
            @_
        );

        my $parameters = $args{Parameters};
        my $script_section = $args{Script};
        my $genesel_js_var = $args{genesel_js_var};
        my $gene2comp_js_var = $args{gene2comp_js_var};
        my $gene_selector_main = $args{gene_selector_main};

        my $gene_selector_main_html = new HTMLSelect(
            _id => "select1",
            _name => "select1",
            _class => "higlightSelector",
            _onchange => "pathfilter(1)",
            _title => "Select Maps Containing A Gene",
        );
        my $first_gene_select = new HTMLSelectOption(
            _value => "all",
            _text => "Gene"
        );
        if ($parameters -> {_enablegene} || $parameters -> {_enableurna} || $parameters -> {_enablemeth}) {

            $script_section -> VariablesLoader(
                Content => \%{$genesel_js_var -> {_data}},
                VariableID => "genesel"
            );
            $script_section -> VariablesLoader(
                Content => \%{$gene2comp_js_var -> {_data}},
                VariableID => "gene2comp"
            );
            $gene_selector_main_html -> LoadOption(
                HTMLSelectOption => \%{$gene_selector_main -> {_data}}
            );
            $gene_selector_main_html -> SortSelectByAlphabet();

            unshift(@{$gene_selector_main_html -> {_options}},$first_gene_select);

        }
        return($script_section,$gene_selector_main_html);
    }
    sub results_prot_selector_Packager {
        my %args = (
            @_
        );
        my $parameters = $args{Parameters};
        my $script_section = $args{Script};
        my $protsel_js_var = $args{protsel_js_var};
        my $prot2comp_js_var = $args{prot2comp_js_var};
        my $prot_selector_main = $args{prot_selector_main};

        my $prot_selector_main_html = new HTMLSelect(
            _id => "select6",
            _name => "select6",
            _class => "higlightSelector",
            _onchange => "pathfilter(6)",
            _title => "Select Maps Containing A Protein",
        );
        my $first_prot_select = new HTMLSelectOption(
            _value => "all",
            _text => "Protein"
        );
        if ($parameters -> {_enableprot}) {

                    $script_section -> VariablesLoader(
                        Content => \%{$protsel_js_var -> {_data}},
                        VariableID => "protsel"
                    );
                    $script_section -> VariablesLoader(
                        Content => \%{$prot2comp_js_var -> {_data}},
                        VariableID => "prot2comp"
                    );
                    $prot_selector_main_html -> LoadOption(
                        HTMLSelectOption => \%{$prot_selector_main -> {_data}}
                    );
                    $prot_selector_main_html -> SortSelectByAlphabet();

                    unshift(@{$prot_selector_main_html -> {_options}},$first_prot_select);

        }
        return($script_section,$prot_selector_main_html);

    }
    sub results_urna_selector_Packager {

        my %args = (
            @_
        );

        my $parameters = $args{Parameters};
        my $script_section = $args{Script};
        my $urnasel_js_var = $args{urnasel_js_var};
        my $urna2comp_js_var = $args{urna2comp_js_var};
        my $urna_selector_main = $args{urna_selector_main};


        my $urna_selector_main_html = new HTMLSelect(
            _id => "select2",
            _name => "select2",
            _class => "higlightSelector",
            _onchange => "pathfilter(2)",
            _title => "Select Maps Containing A miRNA",
        );
        my $first_urna_select = new HTMLSelectOption(
            _value => "all",
            _text => "miRNA"
        );
        if ($parameters -> {_enableurna}) {

            $script_section -> VariablesLoader(
                Content => \%{$urnasel_js_var -> {_data}},
                VariableID => "urnasel"
            );
            $script_section -> VariablesLoader(
                Content => \%{$urna2comp_js_var -> {_data}},
                VariableID => "urna2comp"
            );
            $urna_selector_main_html -> LoadOption(
                HTMLSelectOption => \%{$urna_selector_main -> {_data}}
            );
            $urna_selector_main_html -> SortSelectByAlphabet();

            unshift(@{$urna_selector_main_html -> {_options}},$first_urna_select);
        }
        return($script_section,$urna_selector_main_html);
    }
    sub results_meta_selector_Packager {

        my %args = (
            @_
        );

        my $parameters = $args{Parameters};
        my $script_section = $args{Script};
        my $metasel_js_var = $args{metasel_js_var};
        my $meta2comp_js_var = $args{meta2comp_js_var};
        my $meta_selector_main = $args{meta_selector_main};

        my $meta_selector_main_html = new HTMLSelect(
            _id => "select3",
            _name => "select3",
            _class => "higlightSelector",
            _onchange => "pathfilter(3)",
            _title => "Select Maps Containing A metabolite",
        );
        my $first_meta_select = new HTMLSelectOption(
            _value => "all",
            _text => "Metabolite"
        );
        if ($parameters -> {_enablemeta}) {

            $script_section -> VariablesLoader(
                Content => \%{$metasel_js_var -> {_data}},
                VariableID => "metasel"
            );
            $script_section -> VariablesLoader(
                Content => \%{$meta2comp_js_var -> {_data}},
                VariableID => "meta2comp"
            );
            $meta_selector_main_html -> LoadOption(
                HTMLSelectOption => \%{$meta_selector_main -> {_data}}
            );
            $meta_selector_main_html -> SortSelectByAlphabet();

            unshift(@{$meta_selector_main_html -> {_options}},$first_meta_select);
        }
        return($script_section,$meta_selector_main_html);
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
            _id => "select4",
            _name => "select4",
            _class => "higlightSelector",
            _onchange => "pathfilter(4)",
            _title => "Display Genes related to an Ontology",
        );
        my $first_ont_select = new HTMLSelectOption(
            _value => "none",
            _text => "Ontologies"
        );

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
    sub results_tfs_selector_Packager {

        my %args = (
            @_
        );
        my $parameters = $args{Parameters};
        my $script_section = $args{Script};
        my $tfsel_js_var = $args{tfsel_js_var};
        my $tf2comp_js_var = $args{tf2comp_js_var};
        my $tf_selector_main = $args{tf_selector_main};

        my $tf_selector_main_html = new HTMLSelect(
            _id => "select5",
            _name => "select5",
            _class => "higlightSelector",
            _onchange => "pathfilter(5)",
            _title => "Select Maps Containing a Transcriptional Factor",
            #_style => "display:none;float:right;"
        );
        my $first_tf_select = new HTMLSelectOption(
            _value => "all",
            _text => "TF"
        );

        if ($parameters -> {_enabletfs}) {
            $script_section -> VariablesLoader(
                Content => \%{$tfsel_js_var -> {_data}},
                VariableID => "tfsel"
            );
            $script_section -> VariablesLoader(
                Content => \%{$tf2comp_js_var -> {_data}},
                VariableID => "tf2comp"
            );
            $tf_selector_main_html -> LoadOption(
                HTMLSelectOption => \%{$tf_selector_main -> {_data}}
            );
            $tf_selector_main_html -> SortSelectByAlphabet();
            unshift(@{$tf_selector_main_html -> {_options}},$first_tf_select);
        }
        return($script_section,$tf_selector_main_html);
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
            _style => "margin-left:105px;"
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
            _onClick => "purge_complex_pool(active_complex_id)"
        );
        my $download_info_button = new HTMLInput(
            _id => "download_info_button",
            _type => "button",
            _value => "Download",
            _onClick => "download_from_pool()"
        );
        my $select_maps_from_icon_button = new HTMLInput(
            _id => "select_maps_from_icon_button",
            _type => "button",
            _value => "Select",
            _onClick => "select_from_pool(active_complex_obj)",
            _style => "margin-left:90px;"
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

#General Front-End Routines

sub BuildExpConfJS {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $home_script = $args{Script};
    my %exp_confs;

    foreach (sort keys %{$parameters -> {_exps_available}}) { #this should be handled with join btw :(
        print STDERR $_."\n";
        my @fields;
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data}) { #?
            push(@fields,"exp_name_input_text:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {expname}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data}) { #?
            push(@fields,"exp_comment_input_text:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {comments}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {gene_id_column}){
            
            push(@fields,"geneIdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {geneIdType}."\"");
            push(@fields,"gene_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {gene_id_column}."\"");
            push(@fields,"gene_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} ->{gene_dev_column}."\"");
            #push(@fields,"gene_dev_type:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {datatype}."\"");
            #push(@fields,"gene_dev_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {datathr}."\"");
            #push(@fields,"gene_dev_dir:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {datadir}."\"");
            push(@fields,"gene_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {gene_pvalue_column}."\"");
            #push(@fields,"gene_pvalue_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {pthr}."\"");
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {geneLeftThreshold}) {
                push(@fields,"geneLeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {geneLeftThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {geneRightThreshold}) {
                push(@fields,"geneRightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {geneRightThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {genepValThreshold}) {
                push(@fields,"genepValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {genepValThreshold}."\"");
            }
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urna_id_column}){
        
            push(@fields,"urnaIdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnaIdType}."\"");
            push(@fields,"urna_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urna_id_column}."\"");
            push(@fields,"urna_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urna_dev_column}."\"");
            push(@fields,"urna_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urna_pvalue_column}."\"");
            
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnaLeftThreshold}) {
                push(@fields,"urnaLeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnaLeftThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnaRightThreshold}) {
                push(@fields,"urnaRightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnaRightThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnapValThreshold}) {
                push(@fields,"urnapValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {urnapValThreshold}."\"");
            }
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meta_id_column}){
            push(@fields,"metaIdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metaIdType}."\"");
            push(@fields,"meta_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meta_id_column}."\"");
            push(@fields,"meta_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meta_dev_column}."\"");
            #push(@fields,"meta_dev_type:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metdatatype}."\"");
            #push(@fields,"meta_dev_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metdatathr}."\"");
            #push(@fields,"meta_dev_dir:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metdatadir}."\"");
            push(@fields,"meta_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meta_pvalue_column}."\"");
            #push(@fields,"meta_pvalue_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metpthr}."\"");
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metaLeftThreshold}) {
                push(@fields,"metaLeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metaLeftThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metaRightThreshold}) {
                push(@fields,"metaRightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metaRightThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metapValThreshold}) {
                push(@fields,"metapValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {metapValThreshold}."\"");
            }
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meth_id_column}){
            push(@fields,"methIdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methIdType}."\"");
            push(@fields,"meth_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meth_id_column}."\"");
            push(@fields,"meth_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meth_dev_column}."\"");
            #push(@fields,"meth_dev_type:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methdatatype}."\"");
            #push(@fields,"meth_dev_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methdatathr}."\"");
            #push(@fields,"meth_dev_dir:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methdatadir}."\"");
            push(@fields,"meth_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {meth_pvalue_column}."\"");
            #push(@fields,"meth_pvalue_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methpthr}."\"");
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methLeftThreshold}) {
                push(@fields,"methLeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methLeftThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methRightThreshold}) {
                push(@fields,"methRightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methRightThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methpValThreshold}) {
                push(@fields,"methpValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {methpValThreshold}."\"");
            }
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {prot_id_column}){

            push(@fields,"protIdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protIdType}."\"");
            push(@fields,"prot_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {prot_id_column}."\"");
            push(@fields,"prot_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {prot_dev_column}."\"");
            #push(@fields,"prot_dev_type:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protdatatype}."\"");
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protLeftThreshold}) {
                push(@fields,"protLeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protLeftThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protRightThreshold}) {
                push(@fields,"protRightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protRightThreshold}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protpValThreshold}) {
                push(@fields,"protpValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protpValThreshold}."\"");
            }
            
            #push(@fields,"prot_dev_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protdatathr}."\"");
            #push(@fields,"prot_dev_dir:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protdatadir}."\"");
            push(@fields,"prot_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {prot_pvalue_column}."\"");
            #push(@fields,"prot_pvalue_thr:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {protpthr}."\"");
        }

        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {mode_select}) {
            push(@fields,"mode_select:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {mode_select}."\"");
        }
        #if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select}) {
        #    push(@fields,"filter_select:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select}."\"");
        #}
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select_pval}) {
            push(@fields,"filter_select_pval:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select_pval}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select_es}) {
            push(@fields,"filter_select_es:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {filter_select_es}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_urna}) {
            push(@fields,"nodeg_select_urna:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_urna}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_meth}) {
            push(@fields,"nodeg_select_meth:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_meth}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_tf}) {
            push(@fields,"nodeg_select_tf:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {nodeg_select_tf}."\"");
        }

        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablegene}){
            push(@fields,"enablegene:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablegene}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enableprot}){
            push(@fields,"enableprot:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enableprot}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enableurna}){
            push(@fields,"enableurna:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enableurna}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablemeth}){
            push(@fields,"enablemeth:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablemeth}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablemeta}){
            push(@fields,"enablemeta:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {enablemeta}."\"");
        }

        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {maps_db_select}) {
            push(@fields,"maps_db_select:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {maps_db_select}."\"");
        }

        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}){
            push(@fields,"organism:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}."\"");
            if ($parameters -> {_organisms_available} -> {$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}} -> {wikipathways} == 1) {
                push(@fields,"wikipathways:1");
            }
            if ($parameters -> {_organisms_available} -> {$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}} -> {kegg} == 1) {
                push(@fields,"kegg:1");
            }
        } else {
            push(@fields,"organism:\"hsa\""); #problem
            push(@fields,"kegg:1");
            push(@fields,"wikipathways:1");
        }

        $exp_confs{$_} = "exp_confs[\"$_\"] = {".join(",",@fields)."};";
        push(@{$home_script -> {_variables}},$exp_confs{$_});
        print STDERR $exp_confs{$_}."\n";
        
    }
    return($home_script);
}
sub container4_Packager {

    my %args = (
        @_
    );

    my $title = $args{Title};

    my $container = new HTMLDiv(
        _id => "container4_access",
        _class => "container4",
        _style => "	position:relative; background-color:#006699; overflow:hidden; padding: 1px;"
    );
    my $header_div = new HTMLDiv(
        _id => "header_div_access",
        _class => "header_div"
    );
    my $unifi_logo_div = new HTMLDiv(
        _id => "unifi_logo_div_access",
        _class => "unifi_logo_div",
        _style => "float:right;"
    );
    my $unifi_logo_img = new HTMLImg(
        _id => "unifi_access",
        _src => "../src/sbsc-unifi-trasp-inv.png",
        _height => 100
    );

    $header_div -> ContentLoader(
        Content => "<font style=\"margin-top:35px; margin-left:60px; position:absolute;\" size=\"+2\" color=\"white\">"
    );
    $header_div -> ContentLoader(
        Content => "<b>$title</b>"
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
sub container5_Packager {

    my %args = (
        @_
    );
    my $container4 = $args{Container4};

    my $container5 = new HTMLDiv(
        _id => "container5",
        _class => "container5",
        _style => "	position:relative; border: 0px solid black; padding:1px; margin:5px;"
        #_style => "border: 5px solid black;"
    );
    $container5 -> ContentLoader(
        Content => $container4
    );
    return($container5);
}

1;
