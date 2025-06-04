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
use PathLayDBs;
use PathLayExpPackages;
use PathLayComplex;
use PathLayPathway;

my $t0 = Benchmark->new;

our $timestamp = getTimeStamp();
### defaults ###
my $server="localserver";
my $base = "$FindBin::Bin/..";
my $cgi = CGI->new;
my $json_text = $cgi->param('json_data');
my $json_data = decode_json($json_text);


my @maps = @{$json_data->{maps}};
my $parameters = $json_data->{parameters};
my $expPackages = $json_data->{expPackages};

my @map_divs;
my @map_ids;
my @map_names;

my $map_counter = 0;
my %nums_for_selector;


foreach my $map (sort(@maps)) {
  # next if ($map !~ "hsa00020"); #hsa04933
  my ($map_name,$mapin) = split(/_/,$map);
  my $mapinfile = $mapin;
  $mapinfile .= ".nodes";
  my $organism = $parameters -> {_org};
  my $image_file = $mapin;
  $image_file =~ s/$organism//;
  $image_file .= ".png";
  my $pathway = new Pathway(
    _source => $parameters -> {_nodesdir}."$mapinfile",
    _index => $map_counter
  );
  $pathway -> PathwayLoader2(
    Params => $parameters,
    ExpPackages => $expPackages,
  );
  
  #here proteins should be merged with genes
  #print STDERR Dumper $pathway;
  #$pathway -> NodesInit();

  $pathway -> LoadComplexes2(
    Parameters => $parameters
  );
  next if (
    # scalar  @{$pathway -> {_complexes} -> {deg}} < 1 &&
    # scalar  @{$pathway -> {_complexes} -> {nodeg}} < 1 &&
    # scalar  @{$pathway -> {_complexes} -> {meta}} < 1 &&
    # scalar @{$pathway -> {_complexes} -> {prot}} < 1 &&
    # scalar @{$pathway -> {_complexes} -> {multi}} < 1
    scalar @{$pathway -> {_complexes}} < 1
  );
  $pathway -> PathwayEncoder2();
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

  $map_complexes_div -> LoadComplexesOnDiv2(
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

$map_divs[0] -> {_style} = "display:block;";



my ($ont2gene_js_var,@ont_select_options) = prepareONTsForFrontend(
  ONTs => $expPackages -> {ont}
  #ONT2GeneJSVar => $ont2gene_js_var
);

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







