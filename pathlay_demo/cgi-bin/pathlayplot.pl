#!/usr/bin/perl
use CGI;
use GD;
use Data::Dumper qw(Dumper);
use lib '/var/www/html/pathlay_demo/cgi-bin/';
use Indicators;
use strict;
use warnings;

my $debug = 1;

my $cgi=new CGI;
my $src = $cgi->param('source');
my $cnt = 0;
$src =~ s/%0A/\n/g;
#print STDERR "SOURCE:\n".$src."\n";
#print LOG2 "PLOT\n$src\n";
my @src = split (/\n/,$src);
if ($src =~ "pathlayplot"){
    shift @src
};

my $switches = {
    _enabledeg => 0,
    _enablenodeg => 0,
    _enableprot => 0,
    _totalgenes => 0,
    _enableurna => 0,
    _enablemeta => 0,
    _enablemeth => 0,
    _enabletf => 0,
    _enabledev => 0,
    _devup => 0,
    _devdn => 0,
    _methup => 0,
    _methdn => 0,
    _urnaup => 0,
    _urnadn => 0,
    _metaup => 0,
    _metadn => 0,
    _tfup => 0,
    _tfdn => 0,
    _dev_only => 0,
    _meth_only => 0
};

my $info;
#print STDERR ">PLOTTING:\n";
#print STDERR @src;
#print STDERR "\n";
foreach my $line (@src) {
    next if ($line =~ /map_name/);
    ($info,$switches) = getinfo($line,$switches);
    #print STDERR $line."\n";
}

#if ($switches -> {_enableprot} > 0) {
    #print STDERR Dumper $switches;
#}
#print STDERR $info -> {id}."\n";
my $graph = new GD::Image(100,100);
my $white = $graph->colorAllocate(255,255,255);
my $black = $graph->colorAllocate(0,0,0);
my $red = $graph->colorAllocate(255,0,0);
my $green = $graph->colorAllocate(0,255,0);
my $blue = $graph->colorAllocate(0,0,255);
my $cyan = $graph->colorAllocate(0,255,255);
my $magenta = $graph->colorAllocate(255,0,255);
my $yellow = $graph->colorAllocate(255,255,0);
my $pink = $graph->colorAllocate(255,192,203);
my $grey = $graph->colorAllocate(128,128,128);
my $orange = $graph ->colorAllocate(255,108,0);
$graph->transparent($white);
$graph->interlaced('true');

my $thick = 1;

if ($switches -> {_mode} eq "full") {

    if ($switches -> {_totalgenes} == 1) {

        $graph = SquareHandler(
            Graph => $graph,
            Switches => $switches
        );

        $graph = AddmiRNAsSquare(
            Graph => $graph,
            miRNAs => $switches -> {_enableurna},
            _urnaup => $switches -> {_urnaup},
            _urnadn => $switches -> {_urnadn},
            ColorUp => $yellow,
            ColorDn => $blue
        );

        $graph = AddTFsSquare(
            Graph => $graph,
            TFs => $switches -> {_enabletf},
            _tfup => $switches -> {_tfup},
            _tfdn => $switches -> {_tfdn},
            ColorUp => $yellow,
            ColorDn => $blue
        );
        #if ($switches -> {_enableprot} > 0) {
        #    print STDERR "prot: total genes -> ".$switches -> {_totalgenes}."\n";
        #    print STDERR "prot: meth found -> ".$switches -> {_enablemeth}."\n";
        #}
        $graph = AddMethylsSquare(
            Graph => $graph,
            Methyls => $switches -> {_enablemeth},
            _methup => $switches -> {_methup},
            _methdn => $switches -> {_methdn},
            ColorUp => $yellow,
            ColorDn => $blue
        );

    }

    if ($switches -> {_totalgenes} > 1) {
        $graph = CircleHandler(
            Graph => $graph,
            Switches => $switches
        );

        $graph = AddmiRNAsCirc2(
            Graph => $graph,
            miRNAs => $switches -> {_enableurna},
            _urnaup => $switches -> {_urnaup},
            _urnadn => $switches -> {_urnadn},
            ColorUp => $yellow,
            ColorDn => $blue
        );

        $graph = AddMethylsCirc2(
            Graph => $graph,
            Methyls => $switches -> {_enablemeth},
            _methup => $switches -> {_methup},
            _methdn => $switches -> {_methdn},
            ColorUp => $yellow,
            ColorDn => $blue
        );

        $graph = AddTFsDiamondsCirc(
            Graph => $graph,
            TFs => $switches -> {_enabletf},
            _tfup => $switches -> {_tfup},
            _tfdn => $switches -> {_tfdn},
            ColorUp => $yellow,
            ColorDn => $blue
        );
    }

    if ($switches -> {_metaup} == 1) {
        #print STDERR "M1\n";

        $graph = BuildPointer(
            Graph => $graph,
            Color => $magenta,
            Tip => "up"
        );
        $graph = FillPointer(
            Graph => $graph,
            Color => $magenta,
            Tip => "up",
            x=> 50,
            y=> 20,
        );
    }
    if ($switches -> {_metadn} == 1) {
        #print STDERR "M2\n";
        $graph = BuildPointer(
            Graph => $graph,
            Color => $blue,
            Tip => "dn"
        );
        $graph = FillPointer(
            Graph => $graph,
            Color => $blue,
            Tip => "dn",
            x => 50,
            y => 80
        );
    }

}

if ($switches -> {_mode} eq "id_only") {

    if ($switches -> {_totalgenes} == 1) {

        $graph = SquareHandler_demo(
            Graph => $graph,
            Switches => $switches
        );

        $graph = AddmiRNAsSquare_demo(
            Graph => $graph,
            miRNAs => $switches -> {_enableurna},
            Color => $orange
        );

        $graph = AddTFsSquare_demo(
            Graph => $graph,
            TFs => $switches -> {_enabletf},
            ColorUp => $orange
        );

        $graph = AddMethylsSquare_demo(
            Graph => $graph,
            Meths => $switches -> {_enablemeth},
            Color => $orange
        );

    }

    if ($switches -> {_totalgenes} > 1) {
        CircleHandler_demo(
            Graph => $graph,
            Switches => $switches
        );

        $graph = AddmiRNAsSquare_demo(
            Graph => $graph,
            miRNAs => $switches -> {_enableurna},
            Color => $orange
        );

        $graph = AddTFsSquare_demo(
            Graph => $graph,
            TFs => $switches -> {_enabletf},
            ColorUp => $orange
        );

        $graph = AddMethylsSquare_demo(
            Graph => $graph,
            Meths => $switches -> {_enablemeth},
            Color => $orange
        );

    }

    if ($switches -> {_enablemeta} == 1) {
        $graph = BuildGenericPointer(
            Graph => $graph,
            Color => $black,
        );
        $graph = FillGenericPointer(
            Graph => $graph,
            Color => $yellow,
            x=> 50,
            y=> 20,
        );
    }

}

#Draw Here#
Draw(
    Graph => $graph
);

sub CircleHandler {
    my %args = (
        Graph => {},
        Switches => {},
        @_
    );

    my $graph = $args{Graph};
    my $switches = $args{Switches};

    my $black = $graph->colorAllocate(0,0,0);
    my $red = $graph->colorAllocate(255,0,0);
    my $green = $graph->colorAllocate(0,255,0);
    my $grey = $graph->colorAllocate(128,128,128);

    my $upratio = $switches -> {_devup} / $switches -> {_totalgenes};
    my $dnratio = $switches -> {_devdn} / $switches -> {_totalgenes};
    my $noratio = $switches -> {_enablenodeg} / $switches -> {_totalgenes};

    $graph = BuildCircle(
        Graph => $graph,
        Color => $black
    );

    if ($upratio == 1) { #1 component in the circle
        #color circle red
        $graph = FillCircle(
            Graph => $graph,
            Color => $red,
            x => 50,
            y => 40
        );
        return($graph);
    }
    if ($dnratio == 1) { #1 component in the circle
        #color circle green
        $graph = FillCircle(
            Graph => $graph,
            Color => $green,
            x => 50,
            y => 40
        );
        return($graph);
    }
    if ($noratio == 1) { #1 component in the circle
        #color circle grey
        $graph = FillCircle(
            Graph => $graph,
            Color => $grey,
            x => 50,
            y => 40
        );
        return($graph);
    }


    if ($switches -> {_devdn} > 0 && $switches -> {_devup} > 0 && $switches -> {_enablenodeg} == 0) { #2 components in the circle
        if ($switches -> {_devdn} > $switches -> {_devup}) {
            #split circle to have lower half bigger
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 40,
                x2 => 85,
                y2 => 40,
                Color => $black
            );
            #color upper half in red
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 20
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devdn} < $switches -> {_devup}) {
            #split circle to have lower half smaller
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 60,
                x2 => 85,
                y2 => 60,
                Color => $black
            );
            #color upper half in red
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 20
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devdn} == $switches -> {_devup}) {
            #split circle in half
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 12,
                y1 => 50,
                x2 => 90,
                y2 => 50,
                Color => $black
            );
            #color upper side in red
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 30
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
    }
    if ($switches -> {_devdn} > 0 && $switches -> {_devup} == 0 && $switches -> {_enablenodeg} > 0) { #2 components in the circle
        if ($switches -> {_devdn} > $switches -> {_enablenodeg}) {
            #split circle to have lower half bigger
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 40,
                x2 => 85,
                y2 => 40,
                Color => $black
            );
            #color upper half in grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 20
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devdn} < $switches -> {_enablenodeg}) {
            #split circle to have lower half smaller
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 60,
                x2 => 85,
                y2 => 60,
                Color => $black
            );
            #color upper half in grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 20
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devdn} == $switches -> {_enablenodeg}) {
            #split circle in half
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 12,
                y1 => 50,
                x2 => 90,
                y2 => 50,
                Color => $black
            );
            #color upper side in grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 30
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 50,
                y => 70
            );
            return($graph);
        }
    }
    if ($switches -> {_devdn} == 0 && $switches -> {_devup} > 0 && $switches -> {_enablenodeg} > 0) { #2 components in the circle
        if ($switches -> {_devup} > $switches -> {_enablenodeg}) {
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 60,
                x2 => 85,
                y2 => 60,
                Color => $black
            );
            #color upper half in red
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 20
            );
            #color down half in grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devup} < $switches -> {_enablenodeg}) {
            #split circle to have lower half bigger
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 14,
                y1 => 40,
                x2 => 85,
                y2 => 40,
                Color => $black
            );
            #color upper half in red
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 20
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 70
            );
            return($graph);
        }
        if ($switches -> {_devup} == $switches -> {_enablenodeg}) {
            #split circle in half
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 12,
                y1 => 50,
                x2 => 90,
                y2 => 50,
                Color => $black
            );
            #color upper side in grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 50,
                y => 30
            );
            #color down half in green
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 70
            );
            return($graph);
        }
    }

    if ($switches -> {_devdn} > 0 && $switches -> {_devup} > 0 && $switches -> {_enablenodeg} > 0) { #3 components in the circle

        if ($upratio >= 0.5 || $dnratio >= 0.5 || $noratio >= 0.5) {
            #draw a line to split by half
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 12,
                y1 => 50,
                x2 => 90,
                y2 => 50,
                Color => $black
            );
            #draw a line to split one of the halves
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 50,
                y1 => 10,
                x2 => 50,
                y2 => 50,
                Color => $black
            );
            #color

            if ($upratio >= 0.5) {
                #color bottom in red
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $red,
                    x => 50,
                    y => 70
                );
                #color rest in green and grey
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $green,
                    x => 35,
                    y => 40
                );
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $grey,
                    x => 65,
                    y => 40
                );
                return($graph);
            }
            if ($dnratio >= 0.5) {
                #color bottom in green
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $green,
                    x => 50,
                    y => 70
                );
                #color rest in red and grey
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $red,
                    x => 35,
                    y => 40
                );
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $grey,
                    x => 65,
                    y => 40
                );
                return($graph);
            }
            if ($noratio >= 0.5) {
                #color bottom in grey
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $grey,
                    x => 50,
                    y => 70
                );
                #color rest in red and green
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $red,
                    x => 35,
                    y => 40
                );
                $graph = FillCircle(
                    Graph => $graph,
                    Color => $green,
                    x => 65,
                    y => 40
                );
                return($graph);
            }
            #return($graph);
        } else {
            #draw a vertical line
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 50,
                y1 => 10,
                x2 => 50,
                y2 => 50,
                Color => $black
            );

            #draw left skewed line
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 15,
                y1 => 90,
                x2 => 50,
                y2 => 50,
                Color => $black
            );

            #draw right skewed $line
            $graph = SplitCircle(
                Graph => $graph,
                x1 => 75,
                y1 => 90,
                x2 => 50,
                y2 => 50,
                Color => $black
            );

            #color green
            #color red
            #color grey
            $graph = FillCircle(
                Graph => $graph,
                Color => $red,
                x => 50,
                y => 70
            );
            $graph = FillCircle(
                Graph => $graph,
                Color => $green,
                x => 35,
                y => 40
            );
            $graph = FillCircle(
                Graph => $graph,
                Color => $grey,
                x => 65,
                y => 40
            );
            return($graph);
        }
        # exit here
    }


    return($graph);
}

sub SquareHandler {
    my %args = (
        Graph => {},
        Switches => {},
        @_
    );

    my $graph = $args{Graph};
    my $switches = $args{Switches};

    my $black = $graph->colorAllocate(0,0,0);
    my $red = $graph->colorAllocate(255,0,0);
    my $green = $graph->colorAllocate(0,255,0);
    my $grey = $graph->colorAllocate(128,128,128);

    $graph = BuildSquare(
        Graph => $graph,
        Color => $black
    );



    if ($switches -> {_enablenodeg} == 1) {
        $graph = FillSquare(
            Graph => $graph,
            Color => $grey
        );
        return($graph);
    }
    if ($switches -> {_devup} == 1) {
        #fill with red
        $graph = FillSquare(
            Graph => $graph,
            Color => $red
        );
        return($graph);
    }
    if ($switches -> {_devdn} == 1) {
        #fill with green
        $graph = FillSquare(
            Graph => $graph,
            Color => $green
        );
        return($graph);
    }


    return($graph);
}

sub SquareHandler_demo {
    my %args = (
        Graph => {},
        Switches => {},
        @_
    );

    my $graph = $args{Graph};
    my $switches = $args{Switches};

    my $black = $graph->colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);
    my $cyan = $graph->colorAllocate(0,255,255);

    my $color;
    if ($switches -> {_enabledeg} == 1) {
        $color = $cyan;
    }
    if ($switches -> {_enableprot} == 1) {
        $color = $cyan;
    }
    if ($switches -> {_enablenodeg} == 1) {
        $color = $grey;
    }


    $graph = BuildSquare(
        Graph => $graph,
        Color => $black
    );
    $graph = FillSquare(
        Graph => $graph,
        Color => $color,
        x => 50,
        y => 50
    );

    return($graph);
}

sub CircleHandler_demo {
    my %args = (
        Graph => {},
        Switches => {},
        @_
    );

    my $graph = $args{Graph};
    my $switches = $args{Switches};

    my $black = $graph->colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);
    my $cyan = $graph->colorAllocate(0,255,255);

    my $deratio = ($switches -> {_enabledeg} + $switches -> {_enableprot}) / $switches -> {_totalgenes};
    my $noratio = $switches -> {_enablenodeg} / $switches -> {_totalgenes};

    $graph = BuildCircle(
        Graph => $graph,
        Color => $black
    );


    if ($deratio == 1) { #1 component in the circle
        #color circle green
        $graph = FillCircle(
            Graph => $graph,
            Color => $cyan,
            x => 50,
            y => 40
        );
        return($graph);
    }
    if ($noratio == 1) { #1 component in the circle
        #color circle grey
        $graph = FillCircle(
            Graph => $graph,
            Color => $grey,
            x => 50,
            y => 40
        );
        return($graph);
    }

    if ($deratio == 0.5) { #2 components in the circle
        $graph = SplitCircle(
            Graph => $graph,
            x1 => 12,
            y1 => 50,
            x2 => 90,
            y2 => 50,
            Color => $black
        );
        #color upper side in grey
        $graph = FillCircle(
            Graph => $graph,
            Color => $cyan,
            x => 50,
            y => 30
        );
        #color down half in green
        $graph = FillCircle(
            Graph => $graph,
            Color => $grey,
            x => 50,
            y => 70
        );
        return($graph);
    }

    if ($deratio > $noratio) { #2 components in the circle
        $graph = SplitCircle(
            Graph => $graph,
            x1 => 14,
            y1 => 60,
            x2 => 85,
            y2 => 60,
            Color => $black
        );
        #color upper half in cyan
        $graph = FillCircle(
            Graph => $graph,
            Color => $cyan,
            x => 50,
            y => 20
        );
        #color down half in grey
        $graph = FillCircle(
            Graph => $graph,
            Color => $grey,
            x => 50,
            y => 70
        );
        return($graph);
    }
    if ($deratio < $noratio) { #2 components in the circle
        #split circle to have lower half bigger
        $graph = SplitCircle(
            Graph => $graph,
            x1 => 14,
            y1 => 40,
            x2 => 85,
            y2 => 40,
            Color => $black
        );
        #color upper half in cyan
        $graph = FillCircle(
            Graph => $graph,
            Color => $cyan,
            x => 50,
            y => 20
        );
        #color down half in grey
        $graph = FillCircle(
            Graph => $graph,
            Color => $grey,
            x => 50,
            y => 70
        );
        return($graph);
    }

    return($graph);
}