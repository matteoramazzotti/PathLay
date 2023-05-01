use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use HTMLObjects;
use GeneralFrontEnd;

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
    my ($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot,$div_setup_chroma) = div_setup_access_Packager();
    my $div_data = div_data_access_Packager();

    my $div_statistic = div_statistic_access_Packager();
    my $div_exec_buttons = div_exec_buttons_access_Packager();
    my $div_preview = div_preview_access_Packager();
    $div_loader -> ContentLoader(
        Content => $div_preview
    );
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
        Content => $div_setup_chroma
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
    my $div_setup_chroma = buildAccessSetupDiv(
        _dataType => "chroma"
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
        if ($type eq "chroma") {
            $setupDiv -> ContentLoader(
                Content => "<b>Chromatin Status Setup</b>"
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


    return($div_setup_gene,$div_setup_urna,$div_setup_meta,$div_setup_meth,$div_setup_prot,$div_setup_chroma);
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
    
    $js_functions[0] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."access/confInterfaces.js"
    );
    $js_functions[1] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."access/checkInterfaces.js"
    );
    $js_functions[2] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."access/global.js"
    );
    $js_functions[3] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."access/accessUtilsNew.js"
    );
    
    $js_functions[4] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."common/spawnHtmlElements.js"
    );
    $js_functions[5] = new HTMLScriptSrc(
        _type => "text/javascript",
        _src => $parameters -> {_jsdir}."access/onLoad.js"
    );
    

    $access_script -> FunctionsLoader(
        Content => \@js_functions
    );

    $access_script = BuildExpConfJS(
        Parameters => $parameters,
        Script => $access_script
    );
    $access_script = BuildExpLastJS(
        Parameters => $parameters,
        Script => $access_script
    );

    unshift(@{$access_script -> {_variables}},"var exp_confs = {};");
    unshift(@{$access_script -> {_variables}},"var exp_last = {};");
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




    



    my $maps_db_select = new HTMLSelect(
        _id => "maps_db_select",
        _name => "maps_db_select",
        #_onchange => "enable_submit()"
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
        #_onClick => "enable_submit()",
        _value => 1,
        _checked => 1
    );
    my $enableprot_checkbox = new HTMLInput(
        _id => "enableprot",
        _type => "checkbox",
        _name => "enableprot",
        #_onClick => "enable_submit()",
        _value => 1,
        _checked => 0
    );
    my $enableurna_checkbox = new HTMLInput(
        _id => "enableurna",
        _type => "checkbox",
        _name => "enableurna",
        #_onClick => "enable_submit()",
        _value => 1
    );
    my $enablemeta_checkbox = new HTMLInput(
        _id => "enablemeta",
        _type => "checkbox",
        _name => "enablemeta",
        #_onClick => "enable_submit()",
        _value => 1
    );
    my $enablemeth_checkbox = new HTMLInput(
        _id => "enablemeth",
        _type => "checkbox",
        _name => "enablemeth",
        #_onClick => "enable_submit()",
        _value => 1
    );
    my $enablechroma_checkbox = new HTMLInput(
        _id => "enablechroma",
        _type => "checkbox",
        _name => "enablechroma",
        #_onClick => "enable_submit()",
        _value => 1
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
        Content => $enablechroma_checkbox
    );
    $div_statistic -> ContentLoader(
        Content => "Chromatin Status"
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

    my $thresholdSelectDiv = new HTMLDiv (
        _id => "thresholdSelectDiv",
        _class => "thresholdSelectDiv"
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

    $div_statistic -> ContentLoader(
        Content => $thresholdSelectDiv
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
        my $chromaThresholdInputDiv = thresholdInputDivBuilder(
            _dataType => "chroma"
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
        $thresholdDiv -> ContentLoader(
            Content => $chromaThresholdInputDiv
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
        my $left_checkbox = new HTMLInput(
            _id => $type."LeftEffectSizeCheck",
            _type => "checkbox",
            _name => $type."LeftEffectSizeCheck",
            _onClick => "",
            _value => 1,
            _checked => 0
        );
        my $right_checkbox = new HTMLInput(
            _id => $type."RightEffectSizeCheck",
            _type => "checkbox",
            _name => $type."RightEffectSizeCheck",
            _onClick => "",
            _value => 1,
            _checked => 0
        );
        my $pval_checkbox = new HTMLInput(
            _id => $type."pValCheck",
            _type => "checkbox",
            _name => $type."pValCheck",
            _onClick => "",
            _value => 1,
            _checked => 0
        );
        my $id_only_checkbox = new HTMLInput(
            _id => $type."IdOnlyCheck",
            _type => "checkbox",
            _name => $type."IdOnlyCheck",
            _onClick => "",
            _value => 1,
            _checked => 0
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
            Content => $left_checkbox
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
            Content => $right_checkbox
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
            Content => $pval_checkbox
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
        $thresholdDiv -> ContentLoader(
            Content => $id_only_checkbox
        );
        $thresholdDiv -> ContentLoader(
            Content => "<font class=\"idOnlyFont\"><b>Preserve non DE IDs</b></font>"
        );
        $thresholdDiv -> ContentLoader(
            Content => "<br><br>"
        );
        if ($type ne "gene" && $type ne "prot" && $type ne "meta") {
            my $no_de_checkbox = new HTMLInput(
                _id => "nodeg_select_$type",
                _type => "checkbox",
                _name => "nodeg_select_$type",
                #_onClick => "checkBox(this,'enable$type')",
                _value => 1,
                _checked => 0
            );
            $thresholdDiv -> ContentLoader(
                Content => $no_de_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<font class=\"noDeFont\"><b>No DE Loading </b></font>"
            );
            $thresholdDiv -> ContentLoader(
                Content => "<br><br>"
            );
            my $no_de_from_id_only_checkbox = new HTMLInput(
                _id => $type."NoDEFromIdOnlyCheck",
                _type => "checkbox",
                _name => $type."NoDEFromIdOnlyCheck",
                _onClick => "",
                _value => 1,
                _checked => 0
            );
            $thresholdDiv -> ContentLoader(
                Content => $no_de_from_id_only_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<font class=\"noDeFont\"><b>No DE Loading From Preserved IDs </b></font>"
            );
        }
        if ($type eq "gene" || $type eq "prot") {
            my $enabletfs_checkbox = new HTMLInput(
                _id => "enabletfs_$type",
                _type => "checkbox",
                _name => "enabletfs_$type",
                #_onClick => "enable_submit()",
                _value => 1,
                _checked => 0
            );
            my $nodeg_select_tf_checkbox = new HTMLInput(
                _id => "nodeg_select_tf_$type",
                _type => "checkbox",
                _name => "nodeg_select_tf_$type",
                #_onClick => "checkBox(this,'enabletfs_$type')",
                _value => 1,
                _checked => 0
            );
            my $enabletfsIdOnly_checkbox = new HTMLInput(
                _id => "enabletfsIdOnly_$type",
                _type => "checkbox",
                _name => "enabletfsIdOnly_$type",
                #_onClick => "enable_submit()",
                _value => 1,
                _checked => 0
            );
            my $nodeg_select_tf_IdOnly_checkbox = new HTMLInput(
                _id => "tfsNoDEFromIdOnlyCheck_$type",
                _type => "checkbox",
                _name => "tfsNoDEFromIdOnlyCheck_$type",
                #_onClick => "enable_submit()",
                _value => 1,
                _checked => 0
            );


            $thresholdDiv -> ContentLoader(
                Content => $enabletfs_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<b>Enable TFs</b>"
            );
            $thresholdDiv -> ContentLoader(
                Content => "<br><br>"
            );
            $thresholdDiv -> ContentLoader(
                Content => $nodeg_select_tf_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<b>Load Non DE from TFs</b>"
            );
            $thresholdDiv -> ContentLoader(
                Content => "<br><br>"
            );
            $thresholdDiv -> ContentLoader(
                Content => $enabletfsIdOnly_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<b>Preserve IDs for TFs</b>"
            );
            $thresholdDiv -> ContentLoader(
                Content => "<br><br>"
            );
            $thresholdDiv -> ContentLoader(
                Content => $nodeg_select_tf_IdOnly_checkbox
            );
            $thresholdDiv -> ContentLoader(
                Content => "<b>Load Non DE from Preserved TFs</b>"
            );
            $thresholdDiv -> ContentLoader(
                Content => "<br><br>"
            );
        }


        return($thresholdDiv);
    }
}
sub div_preview_access_Packager {
    my $div_preview = new HTMLDiv(
        _id => "div_preview",
        _class => "div_preview"
    );
    $div_preview -> ContentLoader(
        Content => "<b>Preview</b>"
    );
    $div_preview -> ContentLoader(
        Content => "<br>"
    );
    return($div_preview);
}

sub AccessPrinter {

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
    print '<link rel="stylesheet" href="../css/mainDivsAccess.css">';
    print "</head>\n";
    print "<body>";
    $script -> PrintScript();
    $form -> PrintForm();
    print "</body>";
    print "</html>\n";

}
1;