use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/modules/frontend/";
use HTMLObjects;
use GeneralFrontEnd;

sub HomeBuilderOld {    


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

sub HomeBuilderNew {
    my %args = (
        @_
    );
    my $parameters = $args{Parameters};
        $parameters -> LoadAvailableExps(
        UsersDir => $parameters->{_base}."/pathlay_users/".$parameters->{_home}."/"
    );

    my $home_script = home_script_Packager(
        Parameters => $parameters
    );
    my $parentDiv = new HTMLDiv();
    my $header = new HTMLDiv(
        _class => "header"
    );
    $header -> ContentLoader(
        Content => "<h1>PathLay - Home</h1>"
    );
    my $container = new HTMLDiv(
        _class => "container"
    );
    my $iconsRow = new HTMLDiv(
        _class => "icons",
    );
    my $iconsDiv = new HTMLDiv(
        _class => "container-row",
        _id => "iconsRow"
    );
    my @icons = (
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">add</i><span>Add New</span></a>',
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">upload_file</i><span>Upload Pack</span></a>',
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">cloud_download</i><span>Download Home</span></a>'
    );
    my @formIds = (
        'add_new_form',
        'upload_pack_form',
        'download_home_form'
    );
    my @formActions = (
        'addNewExp',
        'uploadPack',
        'downloadHome'
    );
    my $i = 0;
    foreach my $icon (@icons) {
        my $form = new HTMLForm(
            _id => $formIds[$i],
            _name => $formIds[$i],
            _action => "../cgi-bin/pathlayHomeActions.pl?action=$formActions[$i]",
            _method => "post",
            _enctype => "multipart/form-data",
            _autocomplete => "off"
        );
        $form -> ContentLoader(
            Content => $icon
        );
        if ($formActions[$i] eq 'uploadPack') {
            my $inputFile = new HTMLInput(
                _type => 'file',
                _id => 'packInput',
                _name => 'packInput',
                _style => 'display:none;'
            );
            $form -> ContentLoader(
                Content => $inputFile
            );
        }

        $iconsDiv -> ContentLoader(
            Content => $form
        );
        $i++;
    }
    $iconsRow -> ContentLoader(
        Content => $iconsDiv
    );
    my $expItemsRow = new HTMLDiv(
        _id => "expItemsRow",
        _class => "container-row"
    );
    my @expBoxes;
    foreach my $exp (sort keys %{$parameters -> {_exps_available}}) {
        my $box = new HTMLDiv(
            _id => "$exp-box",
            _class => "exp-package-item-box"
        );
        my $boxIconsDiv = new HTMLDiv(
            _id => "$exp-icons",
            _class => "exp-package-item-icons"
        );
        my @boxIcons = (
            '<a onClick=performAction("editExp","'.$exp.'") class="exp-package-item-icon"><i class="material-icons">edit_note</i><span>Edit Pack</span></a>',
            '<a onClick=performAction("downloadExp","'.$exp.'") class="exp-package-item-icon"><i class="material-icons">download</i><span>Download</span></a>',
            '<a onClick=performAction("deleteExp","'.$exp.'") class="exp-package-item-icon"><i class="material-icons">delete</i><span>Delete</span></a>',
        );
        foreach my $icon (@boxIcons) {
            $boxIconsDiv -> ContentLoader(
                Content => $icon
            );
        }

        my $expID = $parameters -> {_exps_available} -> {$exp} -> {conf_data} -> {expname};

        $box -> ContentLoader(
            Content => "<span>Title: ${expID}</span>"
        );
        $box -> ContentLoader(
            Content => $boxIconsDiv
        );
        push(@expBoxes,$box);
    }
    foreach my $box (@expBoxes) {
        $expItemsRow -> ContentLoader(
            Content => $box
        );
    }
    $container -> ContentLoader(
        Content => $header
    );
    $container -> ContentLoader(
        Content => $iconsRow
    );
    $container -> ContentLoader(
        Content => $expItemsRow
    );
    return($home_script,$container);
}

sub HomeEditBuilder {
    my %args = (
        @_
    );
    my $parameters = $args{Parameters};
    $parameters -> LoadAvailableExps(
        UsersDir => $parameters->{_base}."/pathlay_users/".$parameters->{_home}."/"
    );
    my $home_script = home_script_Packager(
        Parameters => $parameters
    );
    my $parentDiv = new HTMLDiv();
    my $header = new HTMLDiv(
        _class => "header"
    );
    $header -> ContentLoader(
        Content => "<h1>PathLay - Home</h1>"
    );
    my $container = new HTMLDiv(
        _class => "container"
    );

    my @containerRows;
    foreach my $row (my @i = 0..3) {
        $containerRows[$row] = new HTMLDiv(
            _class => "container-row"
        );
    }

    


    #icons 
    $containerRows[0] = editIconsRowPackager();

    # info
    my $infoContainer = editInfoBoxPackager(
        Organisms => \%{$parameters -> {_organisms_available}}
    );
    
    #nb: conf and ont generated dynamically 


    #Load on Container Row
    $containerRows[1] -> ContentLoader(
        Content => $infoContainer
    );


    # Load on Container
    foreach my $containerRow (@containerRows) {
        $container -> ContentLoader(
            Content => $containerRow
        );
    }

    # Load on Main Div
    $parentDiv -> ContentLoader(
        Content => $header
    );
    $parentDiv -> ContentLoader(
        Content => $container
    );

    return($home_script,$parentDiv);
}
sub editIconsRowPackager {

    my %args = (
        @_
    );
    my $row  = new HTMLDiv(
        _class => "container-row"
    );
    my @icons = (
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">save</i><span>Save Changes</span></a>',
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">upload_file</i><span>Upload Pack</span></a>',
        '<a onClick="submitForm(event)" class="icon"><i class="material-icons">download</i><span>Download Pack</span></a>'
    );
    my @formIds = (
        'save_form',
        'upload_pack_form',
        'download_pack_form'
    );
    my @formActions = (
        'saveExp',
        'uploadPack',
        'downloadExp'
    );
    my $i = 0;
    foreach my $icon (@icons) {
        my $form = new HTMLForm(
            _id => $formIds[$i],
            _name => $formIds[$i],
            _action => "../cgi-bin/pathlayHomeActions.pl?action=$formActions[$i]",
            _method => "post",
            _enctype => "multipart/form-data",
            _autocomplete => "off"
        );
        $form -> ContentLoader(
            Content => $icon
        );
        if ($formActions[$i] eq 'uploadPack') {
            my $inputFile = new HTMLInput(
                _type => 'file',
                _id => 'packInput',
                _name => 'packInput',
                _style => 'display:none;'
            );
            $form -> ContentLoader(
                Content => $inputFile
            );
        }

        $row -> ContentLoader(
            Content => $form
        );
        $i++;
    }
    return($row);
}
sub editInfoBoxPackager {
    my %args = (
        @_
    );
    my $orgAvailable = $args{Organisms};

    my $infoContainer = new HTMLDiv(
        _class => "info-container"
    );
    my $selectContainer = new HTMLDiv(
        _class => "select-container"
    );
    my $organismSelect = new HTMLSelect(
        _id => 'organismSelect',
        #_onchange => 'loadConfBox(event)'
    );
    foreach my $org (keys %$orgAvailable) {
        my $opt = new HTMLSelectOption(
            _value => $org,
            _text => $org
        );
        if ($org eq "hsa"){
            $organismSelect -> AppendOptionOnTop(
                HTMLSelectOption => $opt
            );
        } else {
            $organismSelect -> LoadOption(
                HTMLSelectOption => $opt
            );
        }
    }
    $selectContainer -> ContentLoader(
        Content => $organismSelect
    );
    #Load on Info Container
    foreach (my @i = 0..2) {
        $infoContainer -> ContentLoader(
            Content => new HTMLDiv(
                _class => "info-row"
            )
        );
    }
    @{$infoContainer->{_content}}[0] -> ContentLoader(
        Content => "<span>Title</span>"
    );
    @{$infoContainer->{_content}}[0] -> ContentLoader(
        Content => new HTMLInput(
            _id => 'expnameInput',
            _type => 'text'
        )
    );
    @{$infoContainer->{_content}}[1] -> ContentLoader(
        Content => "<span>Comment</span>"
    );
    @{$infoContainer->{_content}}[1] -> ContentLoader(
        Content => new HTMLInput(
            _id => 'commentsInput',
            _type => 'text'
        )
    );
    @{$infoContainer->{_content}}[2] -> ContentLoader(
        Content => "<span>Organism</span>"
    );
    @{$infoContainer->{_content}}[2] -> ContentLoader(
        Content => $selectContainer
    );
    return($infoContainer);
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
        _src => $parameters -> {_jsdir}."home/homeUtils2.js"
    );
    
    $home_script -> FunctionsLoader(
        Content => \@js_functions
    );

    $home_script = BuildExpConfJS(
        Parameters => $parameters,
        Script => $home_script
    );

    unshift(@{$home_script -> {_variables}},"var exp_confs = {};");
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
        _text => "Genes"
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
        _style => "background-color: #e6faff; display:block;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
    );
    my $urna_data_textarea = new HTMLTextArea(
        _id => "urna_data",
        _name => "urna_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #ffb3b3; display:none;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
    );
    my $meta_data_textarea = new HTMLTextArea(
        _id => "meta_data",
        _name => "meta_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #ffffb3; display:none;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
    );
    my $meth_data_textarea = new HTMLTextArea(
        _id => "meth_data",
        _name => "meth_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #99e699; display:none;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
    );
    my $prot_data_textarea = new HTMLTextArea(
        _id => "prot_data",
        _name => "prot_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #e6b3ff; display:none;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
    );
    my $chroma_data_textarea = new HTMLTextArea(
        _id => "chroma_data",
        _name => "chroma_data",
        _rows => 20,
        _cols => 100,
        _wrap => "off",
        _style => "background-color: #e6b3ff; display:none;margin-left:40px;margin-top:40px;",
        _autocomplete => "usrAddrInput"
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