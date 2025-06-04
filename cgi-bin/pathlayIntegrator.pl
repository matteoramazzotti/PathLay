#!/usr/bin/perl
use CGI;
use CGI::Session;
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use FindBin;
use JSON;
use Data::Structure::Util qw( unbless );
use lib "$FindBin::Bin/modules/";
use lib "$FindBin::Bin/modules/structures/";
use lib "$FindBin::Bin/modules/results/";
use lib "$FindBin::Bin/modules/frontend/";
use lib "$FindBin::Bin/modules/frontend/results/";

use PathLayUtils;
use PathLayIntegration;
use PathLayResultsFrontEnd;
use HTMLObjects;
use Benchmark;
use PathLayStatistic;
use PathLayDBs qw(protDB metaDB uRNADB geneDB TFs);
use PathLayExpPackages;
use PathLayComplex;
use PathLayPathway;



my $t0 = Benchmark->new;

our $timestamp = getTimeStamp();
### defaults ###
my $server="localserver";
my $base = "$FindBin::Bin/..";
my $cgi = CGI->new;
# my $session_id = $cgi->param('sid');

my $json_text = $cgi->param('POSTDATA');

my $json_data = decode_json($json_text);

my $session_id = $json_data->{sid};
my $session = CGI::Session->load($session_id);
my $username = $session->param('username');
my $home = $session->param('home');
my $expId = $cgi->param('exp') ? $cgi->param('exp') : $json_data->{exp} ? $json_data->{exp} : "";
print STDERR "$0: $session_id\n";
print STDERR "$0: $username\n";
print STDERR "$0: $home\n";
print STDERR "$0: $expId\n";
my $parameters = new Parameters();
$parameters -> {_exp_name_input_text} = $expId;
$parameters->{_userdir} = $home ne "6135251850" ? "$base/pathlay_users/".$home."/" : "$base/demo_exps/6135251850/";


if (scalar keys %$json_data == 2) {
  $parameters -> LoadLastENV(
    expId => $expId
  );
} else {
  $parameters -> LoadENVFromJson(
    JSON => $json_data
  );
}
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
  "prot" => "entrez",
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

my $enabledForStat = {
  gene => 0,
  prot => 0,
  chroma => 0,
  meth => 0,
  urna => 0,
  meta => 0
};

my $statOn = 0;
foreach my $dataType (@dataTypes) {
  next if (!$parameters -> {"_enable$dataType"});
  if ($parameters -> {"_${dataType}FETEnabled"}) {
    $enabledForStat -> {$dataType} = 1;
    $statOn++;
  }
}
if ($statOn == 0) {
  $parameters -> {_statistic_select} = "Nothing";
}


#db loading for ID Conversions
@$DBs{"gene","meth","chroma"} = (
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
    if ($parameters -> {"_${dataType}IdType"} ne $validIdTypes -> {$dataType} || $dataType eq "prot") {
      $expPackages -> {$dataType} -> checkIdForConversion(
        _DB => $DBs -> {$dataType},
        _idType => $parameters -> {"_${dataType}IdType"},
        _validType => $validIdTypes->{$dataType}
      );
    }
    if ($parameters -> {"_${dataType}pValCheck"}) {
      $expPackages -> {$dataType} -> filterBypVal(
        _pValThreshold => $parameters -> {"_${dataType}pValThreshold"},
        _IdOnlyCheck => $parameters -> {"_${dataType}IdOnlyCheck"}
      );
    }
    if ($parameters -> {"_${dataType}LeftEffectSizeCheck"} == 1 || $parameters -> {"_${dataType}RightEffectSizeCheck"} == 1) {
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


$expPackages -> {ont} -> ONTsLoader(
  Parameters => $parameters
);
$interfaces -> {ont} -> integrateAll(
  DEGs => $expPackages -> {gene},
  NODEGs => $expPackages -> {nodeg},
  Prots => $expPackages -> {prot},
  ONTs => $expPackages -> {ont}
);
# print STDERR Dumper  $expPackages -> {prot} -> {_data} -> {"7532"};
#statistic steps
my %needed_maps;
if ($parameters -> {_statistic_select} eq "FET") {

  my @typesForStat = map{ if ($enabledForStat -> {$_}) {$_} else {} } (keys(%$enabledForStat));


  #prepare id list with pvalues for test here
      # if (!$dePack -> {_data} -> {$id} -> {pvalue}) {
  #   $dePack -> {_data} -> {$id} -> {pvalue} = 0.0001; # assign a fake pval to idOnly to perform test, else it crashes
  # } to be added
    my $dePack = {};
  foreach my $dataType (@typesForStat) {
    if ($dataType =~ /^(gene|prot|meta)$/) {
      $dePack->{$dataType} = makeListMain(
        dePacks => $expPackages,
        dataType => $dataType
      );
    } else {
      if ($dataType eq 'urna') {
        $dePack->{$dataType} = makeListmiRNA(
          dePacks => $expPackages,
          Parameters => $parameters
        );
      }
      if ($dataType eq 'meth') {
        $dePack->{$dataType} = makeListMethChroma(
          dePacks => $expPackages,
          dataType => 'meth',
          Parameters => $parameters
        );
      }
      if ($dataType eq 'chroma') {
        $dePack->{$dataType} = makeListMethChroma(
          dePacks => $expPackages,
          dataType => 'chroma',
          Parameters => $parameters
        );
      }
    }
  }
  if ($parameters -> {_FETPooling}) {
    #join all gene list into one
    foreach my $dataType (@typesForStat) {
      next if ($dataType eq 'meta');
      while (my ($id,$value) = each %{$dePack -> {$dataType} -> {_data}}) {
        if (!$dePack -> {pool} -> {_data} -> {$id}) {
          $dePack -> {pool} -> {_data} -> {$id} = $value;
        } else {
          if ($dePack -> {pool} -> {_data} -> {$id} -> {pvalue} < $value -> {pvalue}) {
            $dePack -> {pool} -> {_data} -> {$id} -> {pvalue} = $value -> {pvalue};
          }
        }
      }
    }
    push(@typesForStat,"pool");
  }





  foreach my $dataType (@typesForStat) {
    if ($parameters -> {_FETPooling} && ($dataType ne "pool" && $dataType ne "meta")) {
      next;
    }
    
    
    %{$needed_maps{$dataType}} = FETp(
      Parameters => $parameters,
      DePack => $dePack->{$dataType},
      gmtFile => $dataType ne "meta" ? $parameters -> {_map_association_file} : $parameters -> {_map_association_file_meta}
    );
  }
  %{$needed_maps{'ready'}} = JoinMaps(
    Maps => \%needed_maps
  );
  if ($parameters -> {_FETIntersect}) {
    %{$needed_maps{'ready'}} = IntersectMaps(
      Maps => \%needed_maps
    );
  }
}
my $map_counter = 0;
my %available_maps;
my @maps;


opendir(MAPDIR,$parameters -> {_nodesdir}) or die "cannot open map directory ".$parameters -> {_nodesdir}."\n";
foreach my $mapin (sort(readdir(MAPDIR))) {
  next if ($mapin !~ /\.nodes$/);
  next if ($mapin =~ /hsa01100/);
  my $id = $mapin;
  $id =~ s/\.nodes$//;
  next if ($parameters -> {_statistic_select} eq "FET" && !${$needed_maps{'ready'}}{$id});
  $available_maps{$id} = 1;
}
closedir(MAPDIR);
print STDERR "Maps found:".(scalar keys %available_maps)."\n";
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
print STDERR  "Maps to be processed: ".(scalar @maps)."\n";



my $response = {
	status => "Success",
	messagge => "Enjoy your data",
	data => {
    maps => [@maps],
    parameters => $parameters,
    expPackages => $expPackages
  }
};

$response = encode_json(unbless($response));
$response = to_json($response);
# print STDERR Dumper $json_data;
print $cgi->header('application/json');
print $response;

exit;


