#!/usr/bin/perl
use CGI;
use GD;
use Data::Dumper qw(Dumper);
use FindBin;
use lib "$FindBin::Bin/./modules/results/";
use PathLayIndicators;
use strict;
use warnings;




our $graph;

my $debug = 1;
our $switches = {
    _enabledeg => 0,
    _enablenodeg => 0,
    _enableprot => 0,
    _totalMains => 0,
    _totalmiRNAs => 0,
    _totalChromas => 0,
    _totalMeths => 0,
    _totalMetas => 0,
    _totalTfs => 0,
    _totalUp => 0,
    _totalDn => 0,
    _totalNo => 0,
    _enableurna => 0,
    _enablemeta => 0,
    _enablemeth => 0,
    _enablechroma => 0,
    _enabletf => 0,
    _idOnly => 0,
    _idOnlymiRNAs => 0,
    _idOnlyTfs => 0,
    _idOnlyMeths => 0,
    _idOnlyChromas => 0,
    _idOnlyMetas => 0,
    _degDn => 0,
    _degUp => 0,
    _degNo => 0,
    _protUp => 0,
    _protDn => 0,
    _urnaUp => 0,
    _urnaDn => 0,
    _chromaUp => 0,
    _chromaDn => 0,
    _methUp => 0,
    _methDn => 0,
    _metaUp => 0,
    _metaDn => 0,
    _tfUp => 0,
    _tfDn => 0,
    _components => {}
};
my $info;


my ($thr,$src) = decodeQuery();

my @thrs = @$thr;
my @srcs = @$src;

print STDERR Dumper \@srcs;
#my $parameters = getThrs(\@thrs);
foreach my $line (@srcs) {
    next if ($line =~ /map_name/);
    ($info,$switches) = getinfo($line,$switches);

}
$graph = new GD::Image(100,100);




our $white = $graph->colorAllocate(255,255,255);
our $black = $graph->colorAllocate(0,0,0);
our $grey = $graph->colorAllocate(128,128,128);
our $blue = $graph->colorAllocate(0,0,255);
our $orange = $graph ->colorAllocate(255,108,0);
our $yellow = $graph->colorAllocate(255,255,0);


my $red = $graph->colorAllocate(255,0,0);
my $green = $graph->colorAllocate(0,255,0);
my $cyan = $graph->colorAllocate(0,255,255);
my $magenta = $graph->colorAllocate(255,0,255);
my $pink = $graph->colorAllocate(255,192,203);

my $mainColor;
$graph->transparent($white);
$graph->interlaced('true');

our $thick = 1;

my $colorsNumber = scalar(keys(%{$switches -> {_components} -> {_main}}));

my @keysToCheck = ();
my @colorsToUse = ();

if ($switches -> {_components} -> {_main} -> {_red}) {
    push(@keysToCheck,'_totalUp');
    push(@colorsToUse,$red);
}
if ($switches -> {_components} -> {_main} -> {_cyan}) {
    push(@keysToCheck,'_idOnly');
    push(@colorsToUse,$cyan);
}
if ($switches -> {_components} -> {_main} -> {_grey}) {
    push(@keysToCheck,'_totalNo');
    push(@colorsToUse,$graph -> colorAllocate(128,128,128));
}
if ($switches -> {_components} -> {_main} -> {_green}) {
    push(@keysToCheck,'_totalDn');
    push(@colorsToUse,$green);
}
if ($switches -> {_components} -> {_main} -> {_pink}) {
    push(@colorsToUse,$magenta);
}
if ($switches -> {_components} -> {_main} -> {_purple}) {
    push(@colorsToUse,$blue);
}
if ($switches -> {_components} -> {_main} -> {_yellow}) {
    push(@colorsToUse,$yellow);
}
my $tip;
if ($switches -> {_metaUp} > $switches -> {_metaDn}) {
    $tip = "up"
} else {
    $tip = "dn";
}

if ($debug == 1 && $switches -> {_totalMetas} >= 1) {
    # print STDERR Dumper $switches;
    # print STDERR Dumper \@colorsToUse;
    # print STDERR $colorsNumber."\n";
    # print STDERR Dumper \@keysToCheck;
    foreach (@keysToCheck) {
        # print STDERR $_." -> ".$switches -> {$_}."\n";
    }
}

my $mainIndicator;


if ($switches -> {_totalMetas} == 1) {

    $mainIndicator = new Pin();
    $mainIndicator -> makeArc(
        Color => $black
    );
    $mainIndicator -> defineTip(
        Tip => $tip,
        Color => $black
    );
    $mainIndicator -> colorTip(
        Color => $colorsToUse[0],
        Tip => $tip
    );
}
if ($switches -> {_totalMains} == 1) {

    $mainIndicator = new Square();
    $mainIndicator -> defineShape();
    $mainIndicator -> colorBorder(
        Color => $black
    );
    $mainIndicator -> colorBody(
        Color => $colorsToUse[0]
    );
}

if ($switches -> {_totalMains} > 1) {
    
    $mainIndicator = new Circle();
    $mainIndicator -> makeArc(
        Color => $black
    );

    if ($colorsNumber == 1) {
        $mainIndicator -> colorArc(
            Color => $colorsToUse[0]
        );
    }
    if ($colorsNumber == 2) {
        if ($debug) {
                print STDERR "Fine B\n";
            }
        if ($switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]}) {
            $mainIndicator -> splitInTwo(
                Position => "half",
                Color => $black
            );
        }
        if ($switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[1]}) {
            $mainIndicator -> splitInTwo(
                Position => "lower",
                Color => $black
            );
        }
        if ($switches -> {$keysToCheck[0]} < $switches -> {$keysToCheck[1]}) {
            $mainIndicator -> splitInTwo(
                Position => "higher",
                Color => $black
            );
        }
        $mainIndicator -> colorArc(
            Color => $colorsToUse[0],
            x => 50,
            y => 20
        );
        $mainIndicator -> colorArc(
            Color => $colorsToUse[1],
            x => 50,
            y => 70
        );
    }
    if ($colorsNumber == 3) {
        print STDERR "3 colors\n";
        print STDERR Dumper \@keysToCheck;
        print STDERR Dumper $switches;
        #need to map coordinates to colors here!
        my $colorToX = {};
        my $colorToY = {};



        if (
            $switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]} && 
            $switches -> {$keysToCheck[1]} == $switches -> {$keysToCheck[2]}
        ) {
            if ($debug) {
                print STDERR "Fine 0\n";
            }
            $mainIndicator -> splitInThree(
                Color => $black,
                Method => "equal"
            );
            $colorToX -> {0} = 35;
            $colorToY -> {0} = 40;
            $colorToX -> {1} = 50;
            $colorToY -> {1} = 70;
            $colorToX -> {2} = 65;
            $colorToY -> {2} = 40;
        }

        if (
          (
            $switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[1]} &&
            $switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[2]}
          ) || 
          (
            $switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]} &&
            $switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[2]}
          )

        ) { #red half up
            if ($debug) {
                print STDERR "Fine 1\n";
            }
            $mainIndicator -> splitInThree(
                Color => $black,
                Method => "bot"
            );
            $colorToX -> {0} = 35;
            $colorToY -> {0} = 40;
            $colorToX -> {1} = 65;
            $colorToY -> {1} = 70;
            $colorToX -> {2} = 35;
            $colorToY -> {2} = 70;
        }

        if (
            (
                $switches -> {$keysToCheck[2]} > $switches -> {$keysToCheck[1]} &&
                $switches -> {$keysToCheck[2]} > $switches -> {$keysToCheck[0]}
            )  || 
          (
            $switches -> {$keysToCheck[1]} == $switches -> {$keysToCheck[2]} &&
            $switches -> {$keysToCheck[0]} < $switches -> {$keysToCheck[2]}
          )
        ) {
            if ($debug) {
                print STDERR "Fine 3 alpha\n";
            }
            $mainIndicator -> splitInThree(
                Color => $black,
                Method => "top"
            );
            $colorToX -> {0} = 65;
            $colorToY -> {0} = 25;
            $colorToX -> {1} = 35;
            $colorToY -> {1} = 25;
            $colorToX -> {2} = 65;
            $colorToY -> {2} = 70;
        }

         
        if (
            $switches -> {$keysToCheck[1]} > $switches -> {$keysToCheck[2]} &&
            $switches -> {$keysToCheck[1]} > $switches -> {$keysToCheck[0]}
        ) {
            if ($debug) {
                print STDERR "Fine 3 beta\n";
            }
            $mainIndicator -> splitInThree(
                Color => $black,
                Method => "top"
            );
            $colorToX -> {0} = 65;
            $colorToY -> {0} = 25;
            $colorToX -> {1} = 35;
            $colorToY -> {1} = 70;
            $colorToX -> {2} = 35;
            $colorToY -> {2} = 25;
        }

        if ($debug) {
                print STDERR "Coloring\n";
            }
 

        


        #red
        #grey(/cyan?)
        #green
        #corner up left x35 y40
        #corner up right x65 y40
        #down full x50 y70
        #$mainIndicator -> colorArc(
        #    Color => $colorsToUse[0],
        #    x => 50,
        #    y => 70
        #);
        #$mainIndicator -> colorArc(
        #    Color => $colorsToUse[1],
        #    x => 35,
        #    y => 40
        #);
        #$mainIndicator -> colorArc(
        #    Color => $colorsToUse[2],
        #    x => 65,
        #    y => 40
        #);
        $mainIndicator -> colorArc(
            Color => $colorsToUse[0],
            x => $colorToX -> {0},
            y => $colorToY -> {0}
        );
        $mainIndicator -> colorArc(
            Color => $colorsToUse[1],
            x => $colorToX -> {1},
            y => $colorToY -> {1}
        );
        $mainIndicator -> colorArc(
            Color => $colorsToUse[2],
            x => $colorToX -> {2},
            y => $colorToY -> {2}
        );
    }
    if ($colorsNumber == 4) {
        if (
            $switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]} && 
            $switches -> {$keysToCheck[1]} == $switches -> {$keysToCheck[2]} &&
            $switches -> {$keysToCheck[1]} == $switches -> {$keysToCheck[3]} 
        ) {
            
        }
    }
}

if ($switches -> {_totalmiRNAs} > 0) {
    $mainIndicator -> addSmallCircles();
    
}

if ($switches -> {_totalMeths} > 0) {
    #$mainIndicator -> addSmallBorderedSquaresTop();
    #$mainIndicator -> addSmallSquaresTop();
    $mainIndicator -> addSmallSquares(
        Position => "top",
        SwitchesTotal => $switches -> {_totalMeths},
        SwitchesUp => $switches -> {_methUp},
        SwitchesDn => $switches -> {_methDn},
        SwitchesId => $switches -> {_idOnlyMeths}
    );
}

if ($switches -> {_totalTfs} > 0) {
    $mainIndicator -> addSmallSquares(
        Position => "right",
        SwitchesTotal => $switches -> {_totalTfs},
        SwitchesUp => $switches -> {_tfUp},
        SwitchesDn => $switches -> {_tfDn},
        SwitchesId => $switches -> {_idOnlyTfs}
    );
}

if ($switches -> {_totalChromas} > 0) {
    $mainIndicator -> addSmallSquares(
        Position => "bot",
        SwitchesTotal => $switches -> {_totalChromas},
        SwitchesUp => $switches -> {_chromaUp},
        SwitchesDn => $switches -> {_chromaDn},
        SwitchesId => $switches -> {_idOnlyChromas}
    );
}
Draw(
    Graph => $graph
);



sub decodeQuery {
    my $cgi=new CGI;
    my $source;
    my $thr;
    my @sourceArray;
    my @thrArray;
    #print STDERR "decodequery ->\n";
    
    if ($cgi->param('thr')) {
        
        $thr = $cgi->param('thr');
        $thr =~ s/\|$//;
        $thr =~ s/%0A/\n/g;
        $thr =~ s/^\n//g;
        @thrArray = split(/\|/,$thr);
    }
    #print STDERR "\nSTOP\n";
    if ($cgi->param('source')) {
        
        $source = $cgi->param('source');
        $source =~ s/%0A/\n/g;
        $source =~ s/^\n//g;
        @sourceArray = split(/\n/,$source);
        shift @sourceArray;
    }
    #print STDERR "decoded!\n";
    return(\@thrArray,\@sourceArray);
}

sub getThrs {

    my $ref = shift @_;
    my @lines = @$ref;

    my $parameters = {};

    foreach my $thrLine (@lines) {

        my @thrs = split(/:/,$thrLine);
        my $type = shift @thrs;

        foreach my $thr (@thrs) {
            chomp($thr);
            if ($thr =~ /^l(.+?)$/) {
                $parameters -> {"_".$type."LeftThreshold"} = $1; 
            }
            if ($thr =~ /^r(.+?)$/ || $thr =~ /^r (.+?)/) {
                $parameters -> {"_".$type."RightThreshold"} = $1; 
            }
        }
    }
    return($parameters);
}

sub getinfo {

    my $line = shift;
    my $switches = shift;
    #my $parameters = shift;
    my $info = {};
    my $thr_dev = 0;
    my $thr_meth = 0;
    
    my $thr_meta = 0;
    
    my $thr_urna = 0;
    

    $line =~ s/^ +//; #this is to fix the 3 white spaces in front of the miRNA
    my $seen_dev = 0;
    my $seen_meth = 0;
    my $seen_chroma = 0;

    my $currentType;
    my $currentDev;

    foreach (split(/\|/,$line)) {
        my ($tag,$value) = split(/:/,$_);
        if ($tag eq "type") {
            $switches -> {"_enable$value"}++;
            $currentType = $value;
            $currentDev = "";
            if ($currentType eq "meta") {
                $switches -> {_totalMetas}++;
            }
            if ($currentType eq "deg") {
                $switches -> {_totalMains}++;
            }
            if ($currentType eq "prot") {
                $switches -> {_totalMains}++;
            }
            if ($currentType eq "nodeg") {
                $switches -> {_totalNo}++;
                $switches -> {_totalMains}++;
                $switches -> {_components} -> {_main} -> {_grey} = {};
            }
            if ($currentType eq "urna") {
                $switches -> {_totalmiRNAs}++;
            }
            if ($currentType eq "meth") {
                $switches -> {_totalMeths}++;
            }
            if ($currentType eq "chroma") {
                $switches -> {_totalChromas}++;
            }
            if ($currentType eq "tf") {
                $switches -> {_totalTfs}++;
            }
        }
        if ($tag eq "dev") {
            $currentDev = $value;
            if ($currentDev < 0) {
                $switches -> {"_".$currentType."Dn"}++;
                if ($currentType eq "meta") {
                    $switches -> {_components} -> {_main} -> {_purple} = {};
                }
                if ($currentType eq "deg" || $currentType eq "prot") {
                    $switches -> {_totalDn}++;
                    $switches -> {_components} -> {_main} -> {_green} = {};
                }
                if ($currentType eq "urna") {
                    $switches -> {_components} -> {_left} -> {_blue} = {};
                }
                if ($currentType eq "meth") {
                    $switches -> {_components} -> {_top} -> {_blue} = {};
                }
                if ($currentType eq "chroma") {
                    $switches -> {_components} -> {_bot} -> {_blue} = {};
                }
                if ($currentType eq "tf") {
                    $switches -> {_components} -> {_right} -> {_blue} = {};
                }
            }
            if ($currentDev > 0) {
                $switches -> {"_".$currentType."Up"}++;
                $switches -> {_totalUp}++;
                if ($currentType eq "meta") {
                    $switches -> {_components} -> {_main} -> {_pink} = {};
                }
                if ($currentType eq "deg" || $currentType eq "prot") {
                    $switches -> {_components} -> {_main} -> {_red} = {};
                }
                if ($currentType eq "urna") {
                    $switches -> {_components} -> {_left} -> {_yellow} = {};
                }
                if ($currentType eq "meth") {
                    $switches -> {_components} -> {_top} -> {_yellow} = {};
                }
                if ($currentType eq "chroma") {
                    $switches -> {_components} -> {_bot} -> {_yellow} = {};
                }
                if ($currentType eq "tf") {
                    $switches -> {_components} -> {_right} -> {_yellow} = {};
                }
            }
        }
        
    }
     
    $switches -> {_idOnly} = $switches -> {_totalMains} - ($switches -> {_totalUp} + $switches -> {_totalDn} + $switches -> {_totalNo});
    $switches -> {_idOnlymiRNAs} = $switches -> {_totalmiRNAs} - ($switches -> {_urnaUp} + $switches -> {_urnaDn});
    $switches -> {_idOnlyChromas} = $switches -> {_totalChromas} - ($switches -> {_chromaUp} + $switches -> {_chromaDn});
    $switches -> {_idOnlyMeths} = $switches -> {_totalMeths} - ($switches -> {_methUp} + $switches -> {_methDn});
    $switches -> {_idOnlyTfs} = $switches -> {_totalTfs} - ($switches -> {_tfUp} + $switches -> {_tfDn});
    $switches -> {_idOnlyMetas} = $switches -> {_totalMetas} - ($switches -> {_metaUp} + $switches -> {_metaDn});


    if ($switches -> {_idOnly} > 0) {
        $switches -> {_components} -> {_main} -> {_cyan} = {};
    }
    if ($switches -> {_idOnlymiRNAs} > 0) {
        $switches -> {_components} -> {_left} -> {_orange} = {};
    }
    if ($switches -> {_idOnlyChromas} > 0) {
        $switches -> {_components} -> {_bot} -> {_orange} = {};
    }
    if ($switches -> {_idOnlyMeths} > 0) {
        $switches -> {_components} -> {_top} -> {_orange} = {};
    }
    if ($switches -> {_idOnlyTfs} > 0) {
        $switches -> {_components} -> {_right} -> {_orange} = {};
    }
    if ($switches -> {_idOnlyMetas} > 0) {
        $switches -> {_components} -> {_main} -> {_yellow} = {};
    }

    return($info,$switches); #returning info is useless
}

sub Draw{
    my %args = (
        Graph => {},
        @_
    );

    my $graph = $args{Graph};
    print "Content-type: image/png\n\n";
    binmode STDOUT;
    print $graph->png;
}
