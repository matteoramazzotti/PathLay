#!/usr/bin/perl
use CGI;
use Statistics::R;
use Data::Dumper qw(Dumper);
use lib '/var/www/html/pathlay_demo/cgi-bin/';
use PathLayUtils;
use PathLayFrontEnd;
use HTMLObjects;
use strict;
use warnings;
#use Logger;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = ($year+1900).sprintf("%02d",$mon+1).sprintf("%02d",$mday).sprintf("%02d",$hour).sprintf("%02d",$min).sprintf("%02d",$sec);

### defaults ###
#$server="localserver";
#$server="bioserver";
my $server="localserver";

my $base = '/mnt/CRUCIAL/apache/html/' if ($server eq 'localserver');
$base = '/var/www/html/pathlay_demo/' if ($server eq 'von');
$base = '/var/www/html/bioserver2.org/' if ($server eq 'bioserver');
$base = '/var/www/html/pathlay_demo/' if ($server eq 'localserver');

print STDERR "SERVER: $base\n";
print STDERR "SERVER: $server\n";
my $mode = 'web';
my $debug = 2; # 0:off, 1: routines, 2: filter1, 3: filter2, 4: varsize, 5: org, 6: ko2path, 7: 8: ...

my @i = qw /@ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z/;

my $runstart = time();

my $report = new Report();

my $parameters = new Parameters();
$parameters -> LoadENV();
#$parameters -> CheckParameters();
$parameters -> updateLastSession();

my $exp_onts = new ONTs ();
$exp_onts -> ONTsLoader2(
    Parameters => $parameters
);

my $exp_genes = new ExpGenes (
    _name => $parameters -> {_exp_name_input_text}
);
my $geneDB = new geneDB (
    _file => $parameters -> {_gene_db_file},
    _location => $parameters -> {_gene_db_location}
);
$geneDB -> geneDBLoader();

if ($parameters -> {_enablegene}) {

    $exp_genes -> ExpLoaderFromBuffer (
        _buffer => $parameters -> {_gene_data},
        _id_column => $parameters -> {_gene_id_column},
        _logfc_column => $parameters -> {_gene_dev_column},
        _pvalue_column => $parameters -> {_gene_pvalue_column},
        _methyl_column => $parameters -> {_gene_meth_column},
        _mode_select => $parameters -> {_mode_select}
    );

    if ($parameters -> {_geneIdType} ne "entrez") {
        $exp_genes -> checkIdForConversion(
            _geneDB => $geneDB
        );
    }
    
    #$exp_genes -> ExpPrinter();
    $report -> UpdateByKey(
        _degs_loaded => $exp_genes -> {_loaded}
    );

    $exp_genes -> Collapse();
    $report -> UpdateByKey(
        _degs_collapsed => $exp_genes -> {_collapsed}
    );
    $exp_genes -> ExpPrinter();
    if ($parameters -> {_mode_select} eq "full") {
        $exp_genes -> filterByEffectSize(
            _LeftThreshold => $parameters -> {_geneLeftThreshold},
            _RightThreshold => $parameters -> {_geneRightThreshold},
            _filter_select_es => $parameters -> {_filter_select_es}
        );
        $report -> UpdateByKey(
            _degs_filtered => $exp_genes -> {_filtered}
        );
    }
    if ($parameters -> {_filter_select_pval} ne "filter_none") {
        $exp_genes -> filterBypVal(
            _pValThreshold => $parameters -> {_genepValThreshold}
        );
        $report -> UpdateByKey(
            _degs_filtered => $exp_genes -> {_filtered}
        );
    }
}


my $exp_proteins = new ExpProteins(
    _name => $parameters -> {_exp_name_input_text}
);
my $protDB = new protDB(
    _file => $parameters -> {_prot_db_file},
    _location => $parameters -> {_prot_db_location}
);
$protDB -> protDBLoader();
$protDB -> protDBPrinter();

if ($parameters -> {_enableprot}) {

    $exp_proteins -> ExpLoaderFromBuffer (
        _buffer => $parameters -> {_prot_data},
        _id_column => $parameters -> {_prot_id_column},
        _logfc_column => $parameters -> {_prot_dev_column},
        _pvalue_column => $parameters -> {_prot_pvalue_column},
        _methyl_column => $parameters -> {_prot_meth_column},
        _mode_select => $parameters -> {_mode_select}
    );
    $report -> UpdateByKey(
        _prots_loaded => $exp_proteins -> {_loaded}
    );

    if ($parameters -> {_protIdType} ne "uniprot") {
        $exp_proteins -> checkIdForConversion(
            _protDB => $protDB,
            _idType => $parameters -> {_protIdType}
        );
    }
    $exp_proteins -> ExpPrinter();
    $exp_proteins -> Collapse();
    $report -> UpdateByKey(
        _proteins_collapsed => $exp_proteins -> {_collapsed}
    );

    if ($parameters -> {_mode_select} eq "full") {
        $exp_proteins -> filterByEffectSize(
            _LeftThreshold => $parameters -> {_protLeftThreshold},
            _RightThreshold => $parameters -> {_protRightThreshold},
            _filter_select_es => $parameters -> {_filter_select_es}
        );
        $report -> UpdateByKey(
            _proteins_filtered => $exp_proteins -> {_filtered}
        );
    }
    if ($parameters -> {_filter_select_pval} ne "filter_none") {
        $exp_proteins -> filterBypVal(
            _pValThreshold => $parameters -> {_protpValThreshold}
        );
        $report -> UpdateByKey(
            _proteins_filtered => $exp_proteins -> {_filtered}
        );
    }

    #$exp_proteins -> ConvertToGenes(
    #    _db => $parameters -> {_prot_db_location}.$parameters -> {_prot_db_file} #fix for wikipathways
    #);

}




my $exp_meths = new ExpGenes (
    _name => $parameters -> {_exp_name_input_text}
);
if ($parameters -> {_enablemeth}) {
    $exp_meths -> ExpLoaderFromBuffer (
        _buffer => $parameters -> {_meth_data},
        _id_column => $parameters -> {_meth_id_column},
        _logfc_column => $parameters -> {_meth_dev_column},
        _pvalue_column => $parameters -> {_meth_pvalue_column},
        _mode_select => $parameters -> {_mode_select}
    );

    $exp_meths -> Collapse();
    $report -> UpdateByKey(
        _degs_collapsed => $exp_meths -> {_collapsed}
    );

    if ($parameters -> {_methIdType} ne "entrez") {
        $exp_meths -> checkIdForConversion(
            _geneDB => $geneDB,
            _idType => $parameters -> {_methIdType}
        );
    }
    $exp_meths -> ExpPrinter();
    if ($parameters -> {_mode_select} eq "full") {
        $exp_meths -> filterByEffectSize(
            _LeftThreshold => $parameters -> {_methLeftThreshold},
            _RightThreshold => $parameters -> {_methRightThreshold},
            _filter_select_es => $parameters -> {_filter_select_es}
        );
        $report -> UpdateByKey(
            _degs_filtered => $exp_meths -> {_filtered}
        );
    }
    if ($parameters -> {_filter_select_pval} ne "filter_none") {
        $exp_meths -> filterBypVal(
            _pValThreshold => $parameters -> {_methpValThreshold}
        );
        $report -> UpdateByKey(
            _meths_filtered => $exp_meths -> {_filtered}
        );
    }
}



my $exp_urnas = new ExpuRNAs (
    _name => $parameters -> {_exp_name_input_text}
);
my $exp_nodegs = new ExpNoDEGs();
my $urna_db = new uRNADB(
    _location => $parameters -> {_urna_db_location},
    _type => "mirtarbase",
    _filter => $parameters ->  {_urna_db_filter},
    _file => $parameters -> {_urna_db_file}
);
if ($parameters -> {_enableurna}) {
    $exp_urnas -> ExpLoaderFromBuffer(
        _buffer => $parameters -> {_urna_data},
        _id_column => $parameters -> {_urna_id_column},
        _logfc_column => $parameters -> {_urna_dev_column},
        _pvalue_column => $parameters -> {_urna_pvalue_column},
        _mode_select => $parameters -> {_mode_select}
    );
    #$exp_urnas -> ExpPrinter();
    $report -> UpdateByKey(
        _urnas_loaded => $exp_urnas -> {_loaded}
    );

    $exp_urnas -> Collapse();
    $report -> UpdateByKey(
        _urnas_loaded => $exp_urnas -> {_collapsed}
    );

    if ($parameters -> {_mode_select} eq "full") {
        $exp_urnas -> filterByEffectSize(
            _LeftThreshold => $parameters -> {_urnaLeftThreshold},
            _RightThreshold => $parameters -> {_urnaRightThreshold},
            _filter_select_es => $parameters -> {_filter_select_es}
        );
        $report -> UpdateByKey(
            _degs_filtered => $exp_urnas -> {_filtered}
        );
    }
    if ($parameters -> {_filter_select_pval} ne "filter_none") {
        $exp_urnas -> filterBypVal(
            _pValThreshold => $parameters -> {_urnapValThreshold}
        );
        $report -> UpdateByKey(
            _urnas_filtered => $exp_urnas -> {_filtered}
        );
    }
    $urna_db -> uDBLoader(
        ExpGenes => $exp_genes,
        ExpuRNAs => $exp_urnas,
        ExpProteins => $exp_proteins
    );

    #if ($parameters -> {_nodeg_select} eq "all" || $parameters -> {_nodeg_select} eq "urna_only") {
    if ($parameters -> {_nodeg_select_urna} == 1) {
        $exp_nodegs -> NoDEGsLoader(
            uRNADB => $urna_db
        );
        #$exp_nodegs -> ExpPrinter();
    }

}


my %needed_maps;
if ($parameters -> {_statistic_select} eq "FET") {

    %needed_maps = FET(
        Parameters => $parameters,
        DEGs => $exp_genes,
        Proteins => $exp_proteins,
        NoDEGs => $exp_nodegs,
        Methyls => $exp_meths
    );
}

my $metaDB = new metaDB(
    _file => $parameters -> {_meta_db_file},
    _location => $parameters -> {_meta_db_location}
);
$metaDB -> metaDBLoader();

my $exp_metas = new ExpMetas (
    _name => $parameters -> {_exp_name_input_text}
);
if ($parameters -> {_enablemeta}){


    $exp_metas -> ExpLoaderFromBuffer(
        _buffer => $parameters -> {_meta_data},
        _id_column => $parameters -> {_meta_id_column},
        _logfc_column => $parameters -> {_meta_dev_column},
        _pvalue_column => $parameters -> {_meta_pvalue_column},
        _mode_select => $parameters -> {_mode_select}
    );
    $report -> UpdateByKey(
        _metas_loaded => $exp_metas -> {_loaded}
    );

    if ($parameters -> {metaIdType} ne "keggcompound") {
        $exp_metas -> checkIdForConversion(
            _idType => $parameters -> {_metaIdType},
            _metaDB => $metaDB
        );
    }
    $exp_metas -> ExpPrinter();
    $exp_metas -> Collapse();
    $report -> UpdateByKey(
        _metas_loaded => $exp_metas -> {_collapsed}
    );

    if ($parameters -> {_mode_select} eq "full") {
        $exp_metas -> filterByEffectSize(
            _LeftThreshold => $parameters -> {_metaLeftThreshold},
            _RightThreshold => $parameters -> {_metaRightThreshold},
            _filter_select_es => $parameters -> {_filter_select_es}
        );
        $report -> UpdateByKey(
            _metas_filtered => $exp_metas -> {_filtered}
        );
    }
    if ($parameters -> {_filter_select_pval} ne "filter_none") {
        $exp_metas -> filterBypVal(
            _pValThreshold => $parameters -> {_metapValThreshold}
        );
        $report -> UpdateByKey(
            _metas_filtered => $exp_metas -> {_filtered}
        );
    }
}


if ($parameters -> {_enableurna}) {
    LinkuRNAs(
        ExpGenes => $exp_genes,
        ExpuRNAs => $exp_urnas,
        ExpNoDEGs => $exp_nodegs,
        ExpProteins => $exp_proteins,
        uRNADB => $urna_db,
        Parameters => $parameters
    );
    $exp_nodegs -> AppendHyperText();
}
if ($parameters -> {_enablegene}) {
    $exp_genes -> AppendHyperText();
}
if ($parameters -> {_enableprot}) {
    $exp_proteins -> AppendHyperText();
}
if ($parameters -> {_enablemeta}) {
    $exp_metas -> AppendHyperText();
}

if ($parameters -> {_enabletfs}) {
    my $tfs_db = new TFs();
    $tfs_db -> TFsLoader(
        Parameters => $parameters,
        ExpGenes => $exp_genes
    );
    LinkTFs(
        ExpGenes => $exp_genes,
        ExpNoDEGs => $exp_nodegs,
        ExpProteins => $exp_proteins,
        TFsDB => $tfs_db,
        Parameters => $parameters,
    );
}

#print STDERR "EXP_GENES".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_NODEGs".(scalar keys %{$exp_nodegs -> {_data}})."\n";
#print STDERR "EXP_METH".(scalar keys %{$exp_meths -> {_data}})."\n";
if ($parameters -> {_enablemeth} && $parameters -> {_enablegene}) { #handle also for proteins
    $exp_genes -> MergeMethyls(
        Methyls => $exp_meths
    );
}

if ($parameters -> {_enablemeth} && $parameters -> {_enableprot}) { #handle also for proteins
    $exp_proteins -> MergeMethyls(
        Methyls => $exp_meths
    );
}

#print STDERR "EXP_GENES".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_METH".(scalar keys %{$exp_meths -> {_data}})."\n";
#print STDERR "EXP_NODEGs".(scalar keys %{$exp_nodegs -> {_data}})."\n";
if ($parameters -> {_enablemeth}) {
    #if ($parameters -> {_nodeg_select} eq "all" || $parameters -> {_nodeg_select} eq "meth_only") {
    if ($parameters -> {_nodeg_select_meth} == 1) {
        $exp_nodegs -> NoDEGsLoader(
            Methyls => $exp_meths
        );
        $exp_nodegs -> MergeMethyls(
            Methyls => $exp_meths
        );
        #die;
        if ($parameters -> {_mode_select} eq "id_only") {
            
        }
    }
}
#print STDERR "EXP_GENES".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_METH".(scalar keys %{$exp_meths -> {_data}})."\n";
#print STDERR "EXP_DEGs".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_NODEGs".(scalar keys %{$exp_nodegs -> {_data}})."\n";
#print STDERR "EXP_PROTEINS".(scalar keys %{$exp_proteins -> {_data}})."\n";

if ($parameters -> {_enableprot} && (scalar keys %{$exp_nodegs -> {_data}} > 0)) {

    $exp_nodegs -> CheckProteins(
        ExpProteins => $exp_proteins
    );
}
#print STDERR "EXP_GENES".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_METH".(scalar keys %{$exp_meths -> {_data}})."\n";
#print STDERR "EXP_DEGs".(scalar keys %{$exp_genes -> {_data}})."\n";
#print STDERR "EXP_NODEGs".(scalar keys %{$exp_nodegs -> {_data}})."\n";
#print STDERR "EXP_PROTEINS".(scalar keys %{$exp_proteins -> {_data}})."\n";





my $map_counter = 0;
my %available_maps;
my @maps;

#load first a kegg.pathway.list or wikipathways.pathway.list and then pick needed maps from generic maps directory



print STDERR $parameters -> {_nodesdir}."\n";
opendir(MAPDIR,$parameters -> {_nodesdir}) or die "cannot open map directory ".$parameters -> {_nodesdir}."\n";
foreach my $mapin (sort(readdir(MAPDIR))) {
    next if ($mapin !~ /\.nodes$/);
    next if ($mapin =~ /hsa01100/);
    my $id = $mapin;
    $id =~ s/\.nodes$//;
    next if ($parameters -> {_statistic_select} eq "FET" && !$needed_maps{$id});
    $available_maps{$id} = 1;
}
closedir(MAPDIR);
print STDERR "Maps found:".(scalar keys %available_maps)."\n";

print STDERR $parameters -> {_map_association_file}."\n";
open(GMT,$parameters -> {_map_association_file}) or die "cannot open gmt file ".$parameters -> {_map_association_file}."\n";
while(<GMT>) {
    my ($map_id,$map_name,@genes) = split(/\t/,$_);
    if ($available_maps{$map_id}) {
        $map_name =~ s/ - Homo sapiens \(human\)//;
        my $map_key = $map_name."_".$map_id;
        push(@maps,$map_key);
    }
}
close(GMT);


my $genesel_js_var = new PreJSVariable (
    _id => "genesel_js_var"
);
my $gene2comp_js_var = new PreJSVariable (
    _id => "gene2comp_js_var"
);
my $gene_selector_main = new PreSelector (
    _id => "gene_selector_main",
    _content_type => "gene"
);
my $protsel_js_var = new PreJSVariable (
    _id => "protsel_js_var"
);
my $prot2comp_js_var = new PreJSVariable(
    _id => "prot2comp_js_var"
);
my $prot_selector_main = new PreSelector (
    _id => "prot_selector_main",
    _content_type => "prot"
);
my $urnasel_js_var = new PreJSVariable (
    _id => "urnasel_js_var"
);
my $urna2comp_js_var  = new PreJSVariable (
    _id => "urna2comp_js_var"
);
my $urna_selector_main = new PreSelector (
    _id => "urna_selector_main",
    _content_type => "urna"
);
my $metasel_js_var = new PreJSVariable (
    _id => "metasel_js_var"
);
my $meta2comp_js_var  = new PreJSVariable (
    _id => "meta2comp_js_var"
);
my $meta_selector_main = new PreSelector (
    _id => "meta_selector_main",
    _content_type => "urna"
);
my $tf_selector_main = new PreSelector (
    _id => "tf_selector_main",
    _content_type => "tf"
);
my $tf2comp_js_var  = new PreJSVariable (
    _id => "tf2comp_js_var"
);
my $tfsel_js_var = new PreJSVariable(
    _id => "tfsel_js_var"
);


my @map_divs;
my @map_ids;
my @map_names;

my %nums_for_selector;

print STDERR  "Maps to be processed: ".(scalar @maps)."\n";

foreach my $map (sort(@maps)) {

    my ($map_name,$mapin) = split(/_/,$map);
    #print STDERR $map_name." - ".$mapin."\n";
    my $mapinfile = $mapin;
    $mapinfile .= ".nodes";
    my $organism = $parameters -> {_exp_organism_input_text};
    my $image_file = $mapin;
    $image_file =~ s/$organism//;
    $image_file .= ".png";
    #next if ($mapin ne "hsa01210");
    my $pathway = new Pathway(
        _source => $parameters -> {_nodesdir}."$mapinfile",
        _index => $map_counter
    );
    
    $pathway -> PathwayLoader(
        Params => $parameters,
        ExpGenes  => $exp_genes,
        ExpNoDEGs => $exp_nodegs,
        ExpProteins => $exp_proteins,
        ExpuRNAS  => $exp_urnas,
        ExpMetas  => $exp_metas
    );

    #here proteins should be merged with genes

    $pathway -> NodesInit();
    #$pathway -> LoadComplexes(
    #    Parameters => $parameters
    #);
    $pathway -> LoadComplexes_test(
        Parameters => $parameters
    );
    #$pathway -> PrintComplexes(
    #    Type => "multi"
    #);

    #if ($mapin eq "hsa04933") {
    #    print STDERR Dumper $pathway;
    #    die;
    #}
    next if (
        scalar  @{$pathway -> {_complexes} -> {deg}} < 1 &&
        scalar  @{$pathway -> {_complexes} -> {nodeg}} < 1 &&
        scalar  @{$pathway -> {_complexes} -> {meta}} < 1 &&
        scalar @{$pathway -> {_complexes} -> {prot}} < 1
    );

    if ($parameters -> {_enablegene}) {
        $gene_selector_main -> UpdatePreSelector (
            DEGs => 1,
            Complexes => $pathway -> {_complexes}
        );

        $gene2comp_js_var -> UpdatePreJSVariable (
            DEGs => 1,
            Complexes => $pathway -> {_complexes}
        );

        $genesel_js_var -> UpdatePreJSVariable (
            DEGs => 1,
            Maps => $pathway -> {_complexes}
        );

    }
    if ($parameters -> {_enableprot}) {
        $prot_selector_main -> UpdatePreSelector (
            Proteins => 1,
            Complexes => $pathway -> {_complexes}
        );
        $prot2comp_js_var -> UpdatePreJSVariable (
            Proteins => 1,
            Complexes => $pathway -> {_complexes}
        );
        $protsel_js_var -> UpdatePreJSVariable (
            Proteins => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enableurna}) {
        $urna_selector_main -> UpdatePreSelector (
            uRNAs => 1,
            Complexes => $pathway -> {_complexes}
        );
        $urna2comp_js_var -> UpdatePreJSVariable (
            uRNAs => 1,
            Complexes => $pathway -> {_complexes}
        );
        $urnasel_js_var -> UpdatePreJSVariable (
            uRNAs => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    #print STDERR Dumper $pathway;
    print STDERR Dumper $urnasel_js_var;
    if ($parameters -> {_enablenodeg} || $parameters -> {_enablemeth}) {
        $gene_selector_main -> UpdatePreSelector (
            NoDEGs => 1,
            Complexes => $pathway -> {_complexes}
        );
        $gene2comp_js_var -> UpdatePreJSVariable (
            NoDEGs => 1,
            Complexes => $pathway -> {_complexes}
        );
        $genesel_js_var -> UpdatePreJSVariable (
            NoDEGs => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enablemeta}) {
        $meta_selector_main -> UpdatePreSelector (
            Metas => 1,
            Complexes => $pathway -> {_complexes}
        );
        $meta2comp_js_var -> UpdatePreJSVariable (
            Metas => 1,
            Complexes => $pathway -> {_complexes}
        );
        $metasel_js_var -> UpdatePreJSVariable (
            Metas => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enabletfs}) {
        $tf_selector_main -> UpdatePreSelector (
            TFs => 1,
            Complexes => $pathway -> {_complexes}
        );

        $tf2comp_js_var -> UpdatePreJSVariable (
            TFs => 1,
            Complexes => $pathway -> {_complexes}
        );

        $tfsel_js_var -> UpdatePreJSVariable (
            TFs => 1,
            Maps => $pathway -> {_complexes}
        );
    }

    my $map_div = new MapDiv(
        _id => $mapin,
        _class => "pathway_div  animate-right",
        #_style => "position:absolute;z-index:1;visibility:hidden"
        _style => "display:none;"
    );
    my $map_complexes_div = new MapDiv(
        _id => $mapin."_complexes",
        _class => "complexes_div",
        #_style => "z-index:3;position:absolute;top:0;left:0;width:100%;height:100%;"
        _style => "position:absolute;top:0;left:0;bottom:0;right:0;display:block;width:100%;height:100%"
    );

    my $map_img = new HTMLImg(
        _id => $mapin."_path",
        _src => $parameters -> {_mapdir}.$image_file,
        _class => "animate-right",
        _usemap => "#".$mapin."_map",
        _border => 0
        # _style => "position:relative;"
    );
    $map_div -> ContentLoader(
        Content => $map_img
    );

    $map_complexes_div -> LoadComplexesOnDiv(
        Pathway => $pathway
    );

    $map_div -> ContentLoader(
        Content => $map_complexes_div
    );
    $map_counter++;
    push(@map_divs,$map_div);
    push(@map_ids,$mapin);
    push(@map_names,$map_name);
    #$pathway -> PrintComplexes();
    %{$nums_for_selector{$mapin}} = (
        degs => $pathway -> {_degs_loaded},
        nodegs => $pathway -> {_nodegs_loaded},
        proteins => $pathway -> {_proteins_loaded},
        urnas => $pathway -> {_urnas_loaded},
        metas => $pathway -> {_metas_loaded},
        methyls => $pathway -> {_methyls_loaded}
    );
}

$exp_onts -> ONTsFilter(
    DEGs => $exp_genes,
    NODEGs => $exp_nodegs
);

my @ont_select_options;
foreach (sort keys %{$exp_onts -> {_ids}}) {
    #print STDERR $_."\n";
    #print STDERR $exp_onts -> {_names} -> {$_}."\n";
    my $ont_select_option = new HTMLSelectOption(
        _value => $_,
        _text => $exp_onts -> {_names} -> {$_}
    );
    push(@ont_select_options,$ont_select_option);
}

my $ont2gene_js_var = new PreJSVariable (
    _id => "ont2gene_js_var"
);
$ont2gene_js_var -> UpdatePreJSVariable(
    ONTs => $exp_onts
);

$map_divs[0] -> {_style} = "display:block;";

my ($style_section,$script_section,$container5,$container2,$container3,$container6,$window_engine) = ResultsBuilder(
    Parameters => $parameters,
    gene_selector_main => $gene_selector_main,
    urna_selector_main => $urna_selector_main,
    meta_selector_main => $meta_selector_main,
    prot_selector_main => $prot_selector_main,
    tf_selector_main => $tf_selector_main,
    genesel_js_var => $genesel_js_var,
    urnasel_js_var => $urnasel_js_var,
    metasel_js_var => $metasel_js_var,
    protsel_js_var => $protsel_js_var,
    tfsel_js_var => $tfsel_js_var,
    gene2comp_js_var => $gene2comp_js_var,
    urna2comp_js_var => $urna2comp_js_var,
    meta2comp_js_var => $meta2comp_js_var,
    prot2comp_js_var => $prot2comp_js_var,
    tf2comp_js_var => $tf2comp_js_var,
    MapDivs => \@map_divs,
    MapIDs => \@map_ids,
    MapNames => \@map_names,
    Nums => \%nums_for_selector,
    ont_select_options => \@ont_select_options,
    ont2gene_js_var => $ont2gene_js_var
);

my $js_function_last = new HTMLScriptSrc(
    _type => "text/javascript",
    _src => $parameters -> {_jsdir}."window-engine.js"
); #!

if ($parameters -> {_enablegene}) {
    push(@{$script_section -> {_variables}},"var enable_gene=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_gene=0;");
}
if ($parameters -> {_enableprot}) {
    push(@{$script_section -> {_variables}},"var enable_prot=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_prot=0;");
}
if ($parameters -> {_enablemeta}) {
    push(@{$script_section -> {_variables}},"var enable_meta=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_meta=0;");
}
if ($parameters -> {_enableurna}) {
    push(@{$script_section -> {_variables}},"var enable_urna=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_urna=0;");
}
if ($parameters -> {_enablemeth}) {
    push(@{$script_section -> {_variables}},"var enable_meth=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_meth=0;");
}
if ($parameters -> {_enabletfs}) {
    push(@{$script_section -> {_variables}},"var enable_tfs=1;");
} else {
    push(@{$script_section -> {_variables}},"var enable_tfs=0;");
}

#to enable grid in interface
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

print STDERR "--PRINTING PAGE--\n";
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


######### PLACE THIS IN FRONTEND ##########
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
###################

$window_engine -> PrintDiv();
print "</body>\n";
print "</html>";
$js_function_last -> PrintScriptSrc();
