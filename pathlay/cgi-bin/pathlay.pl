#!/usr/bin/perl
use CGI;
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use FindBin;
use lib "$FindBin::Bin/./modules/";
use lib "$FindBin::Bin/./modules/structures/";
use lib "$FindBin::Bin/./modules/results/";
use lib "$FindBin::Bin/./modules/frontend/";
use lib "$FindBin::Bin/./modules/frontend/results/";


use PathLayUtils;
use PathLayIntegration;
use PathLayResultsFrontEnd;
use HTMLObjects;
use Benchmark;
use PathLayStatistic;
use PathLayDBs;
use PathLayExpPackages;
use PathLayComplex;
use PathLayPathway;

#use Logger;
my $t0 = Benchmark->new;

our $timestamp = getTimeStamp();
### defaults ###
#my $server="bioserver";
my $server="localserver";
my $base = '/mnt/CRUCIAL/apache/html/' if ($server eq 'localserver');
$base = '/var/www/html/pathlay/' if ($server eq 'von');
$base = '/var/www/html/bioserver2.org/' if ($server eq 'bioserver');
$base = '/var/www/html/pathlay/' if ($server eq 'localserver');

print STDERR "SERVER: $base\n";
print STDERR "SERVER: $server\n";

my $debug = 0;
my $runstart = time();
my $report = new Report();

my $parameters = new Parameters();
$parameters -> LoadENV();
$parameters -> updateLastSession();
$parameters -> PrintParameters();

my @dataTypes = (
    "gene",
    "prot",
    "urna",
    "meth",
    "chroma",
    "meta"
);
my $expPackages = {
    "gene" => new ExpGenes (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "prot" => new ExpProteins (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "urna" => new ExpuRNAs (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "meth" => new ExpMeth (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "chroma" => new ExpChroma (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "meta" => new ExpMetas (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "nodeg" => new ExpNoDEGs (
        _name => $parameters -> {_exp_name_input_text}
    ),
    "ont" => new ExpONTs()
};
my $validIdTypes = {
    "gene" => "entrez",
    "prot" => "uniprot",
    "meth" => "entrez",
    "chroma" => "entrez",
    "meta" => "keggcompound",
    "urna" => "mirbase"
};
my $DBs = {
    prot => new protDB(
        _file => $parameters -> {_prot_db_file},
        _location => $parameters -> {_prot_db_location}
    ),
    meta => new metaDB(
        _file => $parameters -> {_meta_db_file},
        _location => $parameters -> {_meta_db_location}
    ),
    urna => new uRNADB(
        _location => $parameters -> {_urna_db_location},
        _type => "mirtarbase",
        _filter => $parameters ->  {_urna_db_filter},
        _file => $parameters -> {_urna_db_file}
    ),
    tf => new TFs()
};
my $interfaces = {
    urna => new miRNAInterface(),
    meth => new MethInterface(),
    chroma => new ChromaInterface(),
    tf => new TFInterface(),
    ont => new ONTInterface()
};

#db loading for ID Conversions
@$DBs{gene,meth,chroma} = (
    new geneDB (
        _file => $parameters -> {_gene_db_file},
        _location => $parameters -> {_gene_db_location}
    )
) x 3; 
$DBs -> {gene} -> geneDBLoader();
$DBs -> {prot} -> protDBLoader();
$DBs -> {meta} -> metaDBLoader();

#load exp data
foreach my $dataType (@dataTypes) {
    if ($parameters -> {"_enable${dataType}"}) {
        $expPackages -> {$dataType} -> ExpLoaderFromBuffer(
            _buffer => $parameters -> {"_${dataType}_data"},
            _id_column => $parameters -> {"_${dataType}_id_column"},
            _logfc_column => $parameters -> {"_${dataType}_dev_column"},
            _pvalue_column => $parameters -> {"_${dataType}_pvalue_column"},
            _LeftEffectSizeCheck => $parameters -> {"_${dataType}LeftEffectSizeCheck"},
            _RightEffectSizeCheck => $parameters -> {"_${dataType}RightEffectSizeCheck"},
            _pValCheck => $parameters -> {"_${dataType}pValCheck"}
        );
        
        $expPackages -> {$dataType} -> checkIdOnly(
            _idOnlyCheck => $parameters -> {"_${dataType}IdOnlyCheck"}
        );
        $expPackages -> {$dataType} -> Collapse();

        if ($parameters -> {"_${dataType}IdType"} ne $validIdTypes -> {$dataType}) {
            $expPackages -> {$dataType} -> checkIdForConversion(
                _DB => $DBs -> {$dataType},
                _idType => $parameters -> {"_${dataType}IdType"}
            );
        }

        if ($parameters -> {"_${dataType}pValCheck"}) {
            $expPackages -> {$dataType} -> filterBypVal(
                _pValThreshold => $parameters -> {"_${dataType}pValThreshold"},
                _IdOnlyCheck => $parameters -> {"_${dataType}IdOnlyCheck"}
            );
        }
        if ($parameters -> {"_${dataType}LeftEffectSizeCheck"} == 1 || $parameters -> {"_${dataType}LeftEffectSizeCheck"} == 1) {
            $expPackages -> {$dataType} -> filterByEffectSize(
                _LeftThreshold => $parameters -> {"_${dataType}LeftThreshold"},
                _RightThreshold => $parameters -> {"_${dataType}RightThreshold"},
                _LeftEffectSizeCheck => $parameters -> {"_${dataType}LeftEffectSizeCheck"},
                _RightEffectSizeCheck => $parameters -> {"_${dataType}RightEffectSizeCheck"},
                _IdOnlyCheck => $parameters -> {"_${dataType}IdOnlyCheck"}
            );
        }
        
    }
}
#print STDERR Dumper $expPackages -> {prot} -> {_data} -> {'148327'} ;
#print STDERR Dumper $expPackages -> {gene} -> {_data} -> {'148327'} ;
    #print STDERR "BARX2 on gene:\n";
    #print STDERR Dumper $expPackages -> {gene} -> {_data} -> {'8538'} ;

#db loading for Integrations
$DBs -> {urna} -> DBLoader(
    ExpuRNAs => $expPackages -> {urna}
);
$DBs -> {tf} -> TFsLoader(
    Parameters => $parameters,
    ExpGenes => $expPackages -> {gene},
    ExpProteins => $expPackages -> {prot},
    geneCheck => $parameters -> {_enabletfs_gene},
    protCheck => $parameters -> {_enabletfs_prot},
    geneIdOnly => $parameters -> {_enabletfsIdOnly_gene},
    protIdOnly => $parameters -> {_enabletfsIdOnly_prot}
);

#integration steps
foreach my $dataType (("urna","meth","chroma")) {
    $interfaces -> {$dataType} -> integrateWithDEs(
        DB => $DBs -> {$dataType},
        IntegrationExp => $expPackages -> {$dataType},
        ExpGenes => $expPackages -> {gene},
        ExpProteins => $expPackages -> {prot}
    );
    if ($parameters -> {"_nodeg_select_${dataType}"}) {
        $interfaces -> {$dataType} -> integrateWithNoDEs(
            DB => $DBs -> {$dataType},
            ExpNoDegs => $expPackages -> {nodeg},
            IntegrationExp => $expPackages -> {$dataType},
            ExpGenes => $expPackages -> {gene},
            ExpProteins => $expPackages -> {prot},
            NoDeFromIdOnly => $parameters -> {"_${dataType}NoDEFromIdOnlyCheck"}
        );
    }
}
if ($parameters -> {"_enabletfs_gene"} || $parameters -> {"_enabletfs_prot"}) {
    
    $interfaces -> {tf} -> integrateWithDEs(
        DB => $DBs -> {tf},
        ExpGenes => $expPackages -> {gene},
        ExpProteins => $expPackages -> {prot},
        geneEnabler => $parameters -> {"_enabletfs_gene"},
        protEnabler => $parameters -> {"_enabletfs_prot"},
        idOnlyFromGene => $parameters -> {"_enabletfsIdOnly_gene"},
        idOnlyFromProt => $parameters -> {"_enabletfsIdOnly_prot"}
    );
    

    if (
        $parameters -> {"_nodeg_select_tf_gene"} || 
        $parameters -> {"_nodeg_select_tf_prot"}
    ) {
        $interfaces -> {tf} -> integrateWithNoDEs(
            DB => $DBs -> {tf},
            ExpNoDEGs => $expPackages -> {nodeg},
            ExpGenes => $expPackages -> {gene},
            ExpProteins => $expPackages -> {prot},
            noDegeneEnabler => $parameters -> {"_nodeg_select_tf_gene"},
            noDeprotEnabler => $parameters -> {"_nodeg_select_tf_prot"},
            noDeFromIdOnlyGene => $parameters -> {"_tfsNoDEFromIdOnlyCheck_gene"},
            noDeFromIdOnlyProt => $parameters -> {"_tfsNoDEFromIdOnlyCheck_prot"},
        );
    }
    
}
#

$expPackages -> {ont} -> ONTsLoader(
    Parameters => $parameters
);
$interfaces -> {ont} -> integrateAll(
    DEGs => $expPackages -> {gene},
    NODEGs => $expPackages -> {nodeg},
    Prots => $expPackages -> {prot},
    ONTs => $expPackages -> {ont}
);

#statistic steps
my %needed_maps;
if ($parameters -> {_statistic_select} eq "FET") {

    %needed_maps = FET(
        Parameters => $parameters,
        DEGs => $expPackages -> {gene},
        Proteins => $expPackages -> {prot},
        NoDEGs => $expPackages -> {nodeg}
    );
}
#


#if ($parameters -> {_enableprot} && (scalar keys %{$exp_nodegs -> {_data}} > 0)) {
#
#    $exp_nodegs -> CheckProteins(
#        ExpProteins => $exp_proteins
#    );
#}

############

my $map_counter = 0;
my %available_maps;
my @maps;

#print STDERR Dumper $expPackages -> {prot} -> {_data} -> {'148327'} ;
#print STDERR Dumper $expPackages -> {gene} -> {_data} -> {'148327'} ;
#load first a kegg.pathway.list or wikipathways.pathway.list and then pick needed maps from generic maps directory

print STDERR $parameters -> {_nodesdir}."\n";
opendir(MAPDIR,$parameters -> {_nodesdir}) or die "cannot open map directory ".$parameters -> {_nodesdir}."\n";
foreach my $mapin (sort(readdir(MAPDIR))) {
    next if ($mapin !~ /\.nodes$/);
    next if ($mapin =~ /hsa01100/);
    #next if ($mapin !~ /hsa05034/);
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

my @map_divs;
my @map_ids;
my @map_names;

my %nums_for_selector;

#$exp_genes -> ExpPrinter();

print STDERR  "Maps to be processed: ".(scalar @maps)."\n";

foreach my $map (sort(@maps)) {

    my ($map_name,$mapin) = split(/_/,$map);
    my $mapinfile = $mapin;
    $mapinfile .= ".nodes";
    my $organism = $parameters -> {_exp_organism_input_text};
    my $image_file = $mapin;
    $image_file =~ s/$organism//;
    $image_file .= ".png";
    my $pathway = new Pathway(
        _source => $parameters -> {_nodesdir}."$mapinfile",
        _index => $map_counter
    );
    
    $pathway -> PathwayLoader(
        Params => $parameters,
        ExpGenes  => $expPackages -> {gene},
        ExpNoDEGs => $expPackages -> {nodeg},
        ExpProts => $expPackages -> {prot},
        ExpuRNAS  => $expPackages -> {urna},
        ExpMetas  => $expPackages -> {meta}
    );

    #here proteins should be merged with genes

    $pathway -> NodesInit();

    $pathway -> LoadComplexes(
        Parameters => $parameters
    );

    next if (
        scalar  @{$pathway -> {_complexes} -> {deg}} < 1 &&
        scalar  @{$pathway -> {_complexes} -> {nodeg}} < 1 &&
        scalar  @{$pathway -> {_complexes} -> {meta}} < 1 &&
        scalar @{$pathway -> {_complexes} -> {prot}} < 1
    );

    
    my $map_div = new MapDiv(
        _id => $mapin,
        _name => $map_name,
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


my ($ont2gene_js_var,@ont_select_options) = prepareONTsForFrontend(
    ONTs => $expPackages -> {ont}
    #ONT2GeneJSVar => $ont2gene_js_var
);
#print STDERR Dumper $ont2gene_js_var;

$map_divs[0] -> {_style} = "display:block;";

my ($style_section,$script_section,$container5,$container2,$container3,$container6,$window_engine) = ResultsBuilder(
    Parameters => $parameters,
    MapDivs => \@map_divs,
    MapIDs => \@map_ids,
    MapNames => \@map_names,
    Nums => \%nums_for_selector,
    ont_select_options => \@ont_select_options,
    ont2gene_js_var => $ont2gene_js_var
);

 

prepareEnablersForFrontEnd(
    Parameters => $parameters,
    ScriptSection => $script_section
);

my $wrapper = wrapperBuilder(
    Container5 => $container5,
    Container2 => $container2,
    Container3 => $container3,
    Container6 => $container6
);


printPage(
    StyleSection => $style_section,
    ScriptSection => $script_section,
    Wrapper => $wrapper,
    WindowEngine => $window_engine,
    Parameters => $parameters
);
my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print STDERR "DIFF:".timestr($td)."\n";

