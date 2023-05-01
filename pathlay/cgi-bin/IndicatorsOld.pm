use strict;
use warnings;
use GD;
#use Data::Dumper qw(Dumper);

our $graph;

sub getinfo {

    my $line = shift;
    my $switches = shift;
    my $parameters = shift;
    my $info = {};
    my $thr_dev = 0;
    my $thr_meth = 0;
    
    my $thr_meta = 0;
    
    my $thr_urna = 0;
    #my $det = "FC";
    #my $thr_dev = 1;
    #my $dmt = "FC";
    #my $thr_meth = 1;

    if ($line =~ /^mode:/) {
        chomp($line);
        my ($tag,$mode) = split(/:/,$line);
        $switches -> {_mode} = $mode;
        return($info,$switches);
    }

    $line =~ s/^ +//; #this is to fix the 3 white spaces in front of the miRNA
    my $seen_dev = 0;
    my $seen_meth = 0;
    my $seen_chroma = 0;
    foreach (split(/\|/,$line)) {
        my ($tag,$value) = split(/:/,$_);
        $info -> {$tag} = $value;
        #print STDERR $tag." - ".$value."\n";
        if ($tag eq "type") {
            $switches -> {"_enable$value"}++;
        }
        if ($info -> {type} eq "deg"){
            if ($tag eq "dev") {
                $switches -> {"_enable$tag"}++;
                next if ($value eq "");
                if ($value ne "on") {
                    if ($tag eq "meth" && $value < $thr_meth) {
                        $switches -> {_methdn}++;
                        $seen_meth++;
                    }
                    if ($tag eq "meth" && $value > $thr_meth) {
                        $switches -> {_methup}++;
                        $seen_meth++;
                    }
                }
                
                if ($tag eq "meth" && $value eq "on") {
                    #$switches -> {_enablemeth}++;
                    $seen_meth++;
                }
                if ($tag eq "dev" && $value < $thr_dev) {
                    $switches -> {_devdn}++;
                    $seen_dev++;
                }
                if ($tag eq "dev" && $value > $thr_dev) {
                    $switches -> {_devup}++;
                    $seen_dev++;
                }
            }
        }
        if ($info -> {type} eq "prot") {

            next if ($value eq "");
            #print STDERR "prot: getting info\n";
            if ($tag eq "dev" && $value < $thr_dev) {
                $switches -> {"_enable$tag"}++;
                $switches -> {_devdn}++;
                $seen_dev++;
                #print STDERR "prot: found low dev\n";
            }
            if ($tag eq "dev" && $value > $thr_dev) {
                $switches -> {"_enable$tag"}++;
                $switches -> {_devup}++;
                $seen_dev++;
                #print STDERR "prot: found high dev\n";
            }
            if ($tag eq "meth" && $value < $thr_meth) {
                $switches -> {"_enable$tag"}++;
                $switches -> {_methdn}++;
                $seen_meth++;
                #print STDERR "prot: found low meth\n";
            }
            if ($tag eq "meth" && $value > $thr_meth) {
                $switches -> {"_enable$tag"}++;
                $switches -> {_methup}++;
                $seen_meth++;
                #print STDERR "prot: found high meth\n";
            }
        }
        if ($info -> {type} eq "meta") {
            next if ($value eq "");
            if ($tag eq "dev" && $value < $thr_meta) {
                $switches -> {_metadn}++;
            }
            if ($tag eq "dev" && $value > $thr_meta) {
                $switches -> {_metaup}++;
            }

        }
        if ($info -> {type} eq "meth" ) {
            next if ($value eq "");
            if ($tag eq "dev" && $value ne "on") {
                if ($value < $thr_meth) {
                    $switches -> {_methdn}++;
                    $seen_meth++;
                }
                if ($value > $thr_meth) {
                    $switches -> {_methup}++;
                    $seen_meth++;
                }
            }
        }
        if ($info -> {type} eq "chroma" ) {
            next if ($value eq "");
            if ($tag eq "dev" && $value ne "on") {
                if ($value < $thr_meth) {
                    $switches -> {_chromadn}++;
                    $seen_chroma++;
                }
                if ($value > $thr_meth) {
                    $switches -> {_chromaup}++;
                    $seen_chroma++;
                }
            }
        }
        if ($info -> {type} eq "urna") {
            next if ($value eq "");
            if ($tag eq "dev" && $value < $thr_urna) {
                $switches -> {_urnadn}++;
            }
            if ($tag eq "dev" && $value > $thr_urna) {
                $switches -> {_urnaup}++;
            }
        }
        if ($info -> {type} eq "nodeg") {
            if ($tag eq "meth") {
                $switches -> {"_enable$tag"}++;
                next if ($value eq "");
                if ($value < $thr_meth) {
                    $switches -> {_methdn}++;
                    $seen_meth++;
                }
                if ($value > $thr_meth) {
                    $switches -> {_methup}++;
                    $seen_meth++;
                }
                if ($tag eq "meth" && $value eq "on") {
                    $switches -> {_enablemeth}++;
                    $seen_meth++;
                }
            }
        }
        if ($info -> {type} eq "tf") {
            if ($tag eq "dev") {
                $switches -> {"_enable$tag"}++;
                next if ($value eq "");
                if ($tag eq "dev" && $value < $thr_dev) {
                    $switches -> {_tfdn}++;
                }
                if ($tag eq "dev" && $value > $thr_dev) {
                    $switches -> {_tfup}++;
                }
            }
        }
    }

    if ($seen_meth >= 1 && $seen_dev == 0) {
        $switches -> {_meth_only}++;
    }
    if ($seen_meth == 0 && $seen_dev >= 1) {
        $switches -> {_dev_only}++;
    }

    $switches -> {_totalgenes} = $switches -> {_enabledeg} + $switches -> {_enablenodeg} + $switches -> {_enableprot};
    return($info,$switches); #returning info is useless
}



#Triangles
sub BuildTriangle{

    #print STDERR "BuildTraingle\n";
    my %args = (
        Tip => "",
        Graph => {},
        Color => {},
        Thickness => 1,
        @_
    );

    my $graph = $args{Graph};
    my $color = $args{Color};
    my $thick = $args{Thickness};
    my $tip = $args{Tip};

    my $poly = new GD::Polygon;
    $graph->setThickness($thick);
    if ($tip eq "up") {
        $poly->addPt(50,0);
        $poly->addPt(10,80);
        $poly->addPt(90,80);
    }
    if ($tip eq "dn") {
        $poly->addPt(10,20);
		$poly->addPt(50,100);
		$poly->addPt(90,20);
    }
    $graph->openPolygon($poly,$color);
    return($graph);
}
sub FillTriangle{
    #print STDERR "FillTraingle\n";
    my %args = (
        Graph => {},
        Color => {},
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};

    $graph->fill(50,45,$color);

    return($graph);
}
sub SmokeTriangle{

    my %args = (
        Graph => {},
        Smoke => {},
        @_
    );
    my $graph = $args{Graph};
    my $smoke = $args{Smoke};

    if ($args{Smoke}) {
        $graph->setStyle($smoke,gdTransparent,gdTransparent,$smoke,gdTransparent,gdTransparent);
        $graph->fill(50,50,gdStyled);
    }
    return($graph);
}
sub AddmiRNAsTri{

    #print STDERR "AddmiRNAsTri\n";
    my %args = (
        Graph => {},
        miRNAs => 0,
        _urnaup => 0,
        _urnadn => 0,
        _devup => 0,
        _devdn => 0,
        @_
    );
    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $up = $args{_urnaup};
    my $dn = $args{_urnadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $tip;
    my @mir;

    for (1..$urnas) {
        if ($up != 0) {
            push(@mir,"up");
            $up--;
        }
        if ($dn != 0) {
            push(@mir,"dn");
            $dn--;
        }
    }

    if ($args{_devup} == 1) {
        $tip = "up";
    }
    if ($args{_devdn} == 1) {
        $tip = "dn";
    }

    if ($args{_devup} == 0 && $args{_devdn} == 0) {
        $tip = "up";
    }
    if ($tip eq "dn") {
        if ($urnas == 1) {
    		$graph->filledEllipse(50,50,20,20,$color_up) if ($mir[0] eq 'up');
    		$graph->filledEllipse(50,50,20,20,$color_dn) if ($mir[0] eq 'dn');
    	}
    	if ($urnas == 2) {
    		$graph->filledEllipse(50,35,20,20,$color_up) if ($mir[0] eq 'up');
    		$graph->filledEllipse(50,35,20,20,$color_dn) if ($mir[0] eq 'dn');
    		$graph->filledEllipse(50,65,20,20,$color_up) if ($mir[1] eq 'up');
    		$graph->filledEllipse(50,65,20,20,$color_dn) if ($mir[1] eq 'dn');
    	}
    	if ($urnas == 3) {
    		$graph->filledEllipse(30,35,20,20,$color_up) if ($mir[0] eq 'up');
    		$graph->filledEllipse(30,35,20,20,$color_dn) if ($mir[0] eq 'dn');
    		$graph->filledEllipse(70,35,20,20,$color_up) if ($mir[1] eq 'up');
    		$graph->filledEllipse(70,35,20,20,$color_dn) if ($mir[1] eq 'dn');
    		$graph->filledEllipse(50,70,20,20,$color_up) if ($mir[2] eq 'up');
    		$graph->filledEllipse(50,70,20,20,$color_dn) if ($mir[2] eq 'dn');
    	}
    	if ($urnas == 4) {
    		$graph->filledEllipse(30,30,20,20,$color_up) if ($mir[0] eq 'up');
    		$graph->filledEllipse(30,30,20,20,$color_dn) if ($mir[0] eq 'dn');
    		$graph->filledEllipse(70,30,20,20,$color_up) if ($mir[1] eq 'up');
    		$graph->filledEllipse(70,30,20,20,$color_dn) if ($mir[1] eq 'dn');
    		$graph->filledEllipse(50,50,20,20,$color_up) if ($mir[2] eq 'up');
    		$graph->filledEllipse(50,50,20,20,$color_dn) if ($mir[2] eq 'dn');
    		$graph->filledEllipse(50,75,20,20,$color_up) if ($mir[3] eq 'up');
    		$graph->filledEllipse(50,75,20,20,$color_dn) if ($mir[3] eq 'dn');
    	}
    }
    if ($tip eq "up") {
        if (scalar @mir == 1) {
            $graph->filledEllipse(50,55,20,20,$color_up) if ($mir[0] eq 'up');
            $graph->filledEllipse(50,55,20,20,$color_dn) if ($mir[0] eq 'dn');
        }
        if (scalar @mir == 2) {
            $graph->filledEllipse(50,30,20,20,$color_up) if ($mir[0] eq 'up');
            $graph->filledEllipse(50,30,20,20,$color_dn) if ($mir[0] eq 'dn');
            $graph->filledEllipse(50,60,20,20,$color_up) if ($mir[1] eq 'up');
            $graph->filledEllipse(50,60,20,20,$color_dn) if ($mir[1] eq 'dn');
        }
        if (scalar @mir == 3) {
            $graph->filledEllipse(50,35,20,20,$color_up) if ($mir[0] eq 'up');
            $graph->filledEllipse(50,35,20,20,$color_dn) if ($mir[0] eq 'dn');
            $graph->filledEllipse(30,67,20,20,$color_up) if ($mir[1] eq 'up');
            $graph->filledEllipse(30,67,20,20,$color_dn) if ($mir[1] eq 'dn');
            $graph->filledEllipse(70,67,20,20,$color_up) if ($mir[2] eq 'up');
            $graph->filledEllipse(70,67,20,20,$color_dn) if ($mir[2] eq 'dn');
        }
        if (scalar @mir >= 4) {
            $graph->filledEllipse(50,30,20,20,$color_up) if ($mir[0] eq 'up');
            $graph->filledEllipse(50,30,20,20,$color_dn) if ($mir[0] eq 'dn');
            $graph->filledEllipse(50,55,20,20,$color_up) if ($mir[1] eq 'up');
            $graph->filledEllipse(50,55,20,20,$color_dn) if ($mir[1] eq 'dn');
            $graph->filledEllipse(30,67,20,20,$color_up) if ($mir[2] eq 'up');
            $graph->filledEllipse(30,67,20,20,$color_dn) if ($mir[2] eq 'dn');
            $graph->filledEllipse(70,67,20,20,$color_up) if ($mir[3] eq 'up');
            $graph->filledEllipse(70,67,20,20,$color_dn) if ($mir[3] eq 'dn');
        }
    }
    return($graph);
}

sub AddmiRNAsTri2{
    my %args = (
        Graph => {},
        miRNAs => 0,
        _urnaup => 0,
        _urnadn => 0,
        _devup => 0,
        _devdn => 0,
        @_
    );
    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $up = $args{_urnaup};
    my $dn = $args{_urnadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $tip;
    my @mir;

    my $black = $graph -> colorAllocate(0,0,0);

    if ($args{_devup} == 1) {
        $tip = "up";
        if ($up > 0 && $dn > 0) {
            my @x = (20,30);
            my @y = (65,40);
            my @c;
            if ($up == $dn) {
                @c = ($color_up,$color_dn);
            }
            if ($up > $dn) {
                @c = ($color_up,$color_up);
            }
            if ($up < $dn) {
                @c = ($color_dn,$color_dn);
            }
            foreach my $cnt (0..$#x) {
                $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
            }
        }
        if ($up > 0 && $dn == 0) {
            if ($up == 1) {
                my $x = 25;
                my $y = 50;
                $graph->filledEllipse($x,$y,20,20,$color_up);
                $graph->arc($x,$y,20,20,0,360,$black);
            } else {
                my @x = (20,30);
                my @y = (65,40);
                my @c = ($color_up,$color_up);
                foreach my $cnt (0..$#x) {
                    $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                    $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
                }
            }
        }
        if ($dn > 0 && $up == 0) {
            if ($dn == 1) {
                my $x = 25;
                my $y = 50;
                $graph->filledEllipse($x,$y,20,20,$color_dn);
                $graph->arc($x,$y,20,20,0,360,$black);
            } else {
                my @x = (20,30);
                my @y = (65,40);
                my @c = ($color_dn,$color_dn);
                foreach my $cnt (0..$#x) {
                    $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                    $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
                }
            }
        }
    }
    if ($args{_devdn} == 1) {
        $tip = "dn";
        if ($up > 0 && $dn > 0) {
            my @x = (20,30);
            my @y = (40,65);
            my @c;
            if ($up == $dn) {
                @c = ($color_up,$color_dn);
            }
            if ($up > $dn) {
                @c = ($color_up,$color_up);
            }
            if ($up < $dn) {
                @c = ($color_dn,$color_dn);
            }
            foreach my $cnt (0..$#x) {
                $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
            }
        }
        if ($up > 0 && $dn == 0) {

            if ($up == 1) {
                my $x = 25;
                my $y = 50;
                $graph->filledEllipse($x,$y,20,20,$color_up);
                $graph->arc($x,$y,20,20,0,360,$black);
            } else {
                my @x = (20,30);
                my @y = (40,65);
                my @c = ($color_up,$color_up);
                foreach my $cnt (0..$#x) {
                    $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                    $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
                }
            }
        }
        if ($dn > 0 && $up == 0) {
            if ($dn == 1) {
                my $x = 25;
                my $y = 50;
                $graph->filledEllipse($x,$y,20,20,$color_dn);
                $graph->arc($x,$y,20,20,0,360,$black);
            } else {
                my @x = (20,30);
                my @y = (40,65);
                my @c = ($color_dn,$color_dn);
                foreach my $cnt (0..$#x) {
                    $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$c[$cnt]);
                    $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
                }
            }
        }
    }
    return($graph);
}
sub AddMethylsTri{
    my %args = (
        Graph => {},
        _devup => 0,
        _devdn => 0,
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my @x;
    my @y;
    my $offset1 = 30;
    my $gap = 5;
    my $offset2 = 20;

    my $square;
    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph ->  colorAllocate(128,128,128);

    if ($args{_devup} == 1) {
        @x = (35,50); #sx and up x coords
        @y = (80,65); #sx and up y coords
        $square = new GD::Polygon;
        $square -> addPt($x[0],$y[0]); #sx
        $square -> addPt($x[1],$y[1]); #up
        $square -> addPt($x[0] + $offset1,$y[0]); #dx
        $square -> addPt($x[1],$y[1] + $offset1); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt($x[0] + $gap,$y[0]); #sx
        $square -> addPt($x[1],$y[1] + $gap); #up
        $square -> addPt($x[0] + $gap + $offset2,$y[0]); #dx
        $square -> addPt($x[1],$y[1] + $gap + $offset2); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);
    }
    if ($args{_devdn} == 1) {
        #$tip = "dn";
        @x = (35,50); #sx and up x coords
        @y = (20,5); #sx and up y coords
        $square = new GD::Polygon;
        $square -> addPt($x[0],$y[0]); #sx
        $square -> addPt($x[1],$y[1]); #up
        $square -> addPt($x[0] + $offset1,$y[0]); #dx
        $square -> addPt($x[1],$y[1] + $offset1); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt($x[0] + $gap,$y[0]); #sx
        $square -> addPt($x[1],$y[1] + $gap); #up
        $square -> addPt($x[0] + $gap + $offset2,$y[0]); #dx
        $square -> addPt($x[1],$y[1] + $gap + $offset2); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    return($graph);
}


#Circles
sub BuildCircle{

    #print STDERR "BuildCircle\n";
    my %args = (
        Graph => {},
        Color => {},
        Thickness => 1,
        @_
    );

    my $graph = $args{Graph};
    my $color = $args{Color};
    my $thick = $args{Thickness};
    $graph->setThickness($thick);
    $graph->arc(50,50,75,75,0,360,$color);

    return($graph);
}
sub SplitCircle{
    #print STDERR "SplitCircle\n";
    my %args = (
        Graph => {},
        Color => {},
        x1 => 0,
        y1 => 0,
        x2 => 0,
        y2 => 0,
        @_
    );

    my $graph = $args{Graph};
    my $color = $args{Color};
    my $x1 = $args{x1};
    my $y1 = $args{y1};
    my $x2 = $args{x2};
    my $y2 = $args{y2};

    $graph -> setThickness(1);
    $graph -> line($x1,$y1,$x2,$y2,$color);

    return($graph);
}
sub FillCircle{

    #print STDERR "FillCircle\n";
    my %args = (
        Graph => {},
        Color => {},
        x => 0,
        y => 0,
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my $x = $args{x};
    my $y = $args{y};


    $graph->fill($x,$y,$color);
    return($graph);
}
sub SmokeCircle{
    #print STDERR "SmokeCircle\n";
    my %args = (
        Graph => {},
        Smoke => {},
        x => 0,
        y => 0,
        @_
    );
    my $graph = $args{Graph};
    my $smoke = $args{Smoke};
    my $x = $args{x};
    my $y = $args{y};

    $graph->setStyle($smoke,gdTransparent,gdTransparent,$smoke,gdTransparent,gdTransparent);
    $graph->fill($x,$y,gdStyled);

    return($graph);
}
sub AddmiRNAsCirc{

    #print STDERR "AddmiRNAsCirc\n";
    my %args = (
        Graph => {},
        miRNAs => 0,
        _urnaup => 0,
        _urnadn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $up = $args{_urnaup};
    my $dn = $args{_urnadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};

    my @mir;

    for (1..$urnas) {
        if ($up != 0) {
            push(@mir,"up");
            $up--;
        }
        if ($dn != 0) {
            push(@mir,"dn");
            $dn--;
        }
    }

    my @x = (50,50,50,20,80,30,70,70,30);
    my @y = (50,20,80,50,50,30,70,30,70);
    foreach my $cnt (0..8) {
        last if (!$mir[$cnt]);
        $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$color_up) if ($mir[$cnt] eq 'up');
        $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$color_dn) if ($mir[$cnt] eq 'dn');
    }
    return($graph);
}

sub AddChromasCirc {

    my %args = (
        Graph => {},
        Chromas => 0,
        _chromaup => 0,
        _chromadn => 0,
        @_
    );

    my $chromas = $args{Chromas};
    my $up = $args{_chromaup};
    my $dn = $args{_chromadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $graph = $args{Graph};
    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);
    my @c;

    if ($chromas > 1) {

        if ($up > $dn) {
            @c = ($color_up,$color_up);
        }
        if ($dn > $up) {
            @c = ($color_dn,$color_dn);
        }
        if ($dn == $up) {
            @c = ($color_dn,$color_up);
        }

        my $square = new GD::Polygon;
        $square -> addPt(22.5,80); #sx
        $square -> addPt(35,67.5); #up
        $square -> addPt(47.5,80); #dx
        $square -> addPt(35,92.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(27.5,80); #sx
        $square -> addPt(35,72.5); #up
        $square -> addPt(42.5,80); #dx
        $square -> addPt(35,87.5); #dn
        $graph -> filledPolygon($square,$c[0]);
        $graph -> openPolygon($square,$black);
        #little square two
        $square = new GD::Polygon;
        $square -> addPt(53.5,80); #sx
        $square -> addPt(66,67.5); #up
        $square -> addPt(78.5,80); #dx
        $square -> addPt(66,92.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(58.5,80); #sx
        $square -> addPt(66,72.5); #up
        $square -> addPt(73.5,80); #dx
        $square -> addPt(66,87.5); #dn
        $graph -> filledPolygon($square,$c[1]);
        $graph -> openPolygon($square,$black);
    }
    if ($chromas == 1) {
        my $color;
        if ($dn == 0) {
            $color = $color_up;
        }
        if ($up == 0) {
            $color = $color_dn;
        }
        my $square = new GD::Polygon;
        $square -> addPt(35,80); #sx
        $square -> addPt(50,65); #up
        $square -> addPt(65,80); #dx
        $square -> addPt(50,95); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,80); #sx
        $square -> addPt(50,70); #up
        $square -> addPt(60,80); #dx
        $square -> addPt(50,90); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);
        
    }
    return($graph);
}

sub AddMethylsCirc2{
    my %args = (
        Graph => {},
        Methyls => 0,
        _methup => 0,
        _methdn => 0,
        @_
    );
    my $graph = $args{Graph};

    my $umeths = $args{Methyls};
    my $up = $args{_methup};
    my $dn = $args{_methdn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);

    my @x;
    my @y;
    my @x2;
    my @y2;
    my @c;

    if ($up > 0 && $dn > 0) {
        
        if ($up > $dn) {
            @c = ($color_up,$color_up);
        }
        if ($dn > $up) {
            @c = ($color_dn,$color_dn);
        }
        if ($dn == $up) {
            @c = ($color_dn,$color_up);
        }

        my $square = new GD::Polygon;
        $square -> addPt(22.5,20); #sx
        $square -> addPt(35,7.5); #up
        $square -> addPt(47.5,20); #dx
        $square -> addPt(35,32.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(53.5,20); #sx
        $square -> addPt(66,7.5); #up
        $square -> addPt(78.5,20); #dx
        $square -> addPt(66,32.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(27.5,20); #sx
        $square -> addPt(35,12.5); #up
        $square -> addPt(42.5,20); #dx
        $square -> addPt(35,27.5); #dn
        $graph -> filledPolygon($square,$c[0]);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(58.5,20); #sx
        $square -> addPt(66,12.5); #up
        $square -> addPt(73.5,20); #dx
        $square -> addPt(66,27.5); #dn
        $graph -> filledPolygon($square,$c[1]);
        $graph -> openPolygon($square,$black); 
    }

    if ($up >= 1 && $dn == 0) {

        if ($up == 1) {
            @c = ($color_up);
            my $square = new GD::Polygon;
            $square -> addPt(35,20); #sx
            $square -> addPt(50,5); #up
            $square -> addPt(65,20); #dx
            $square -> addPt(50,35); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);

            $square = new GD::Polygon;
            $square -> addPt(40,20); #sx
            $square -> addPt(50,10); #up
            $square -> addPt(60,20); #dx
            $square -> addPt(50,30); #dn
            $graph -> filledPolygon($square,$c[0]);
            $graph -> openPolygon($square,$black);
        } else {
            @c = ($color_up,$color_up);
            my $square = new GD::Polygon;
            $square -> addPt(22.5,20); #sx
            $square -> addPt(35,7.5); #up
            $square -> addPt(47.5,20); #dx
            $square -> addPt(35,32.5); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);

            $square = new GD::Polygon;
            $square -> addPt(27.5,20); #sx
            $square -> addPt(35,12.5); #up
            $square -> addPt(42.5,20); #dx
            $square -> addPt(35,27.5); #dn
            $graph -> filledPolygon($square,$c[0]);
            $graph -> openPolygon($square,$black);

            #little square two

            $square = new GD::Polygon;
            $square -> addPt(53.5,20); #sx
            $square -> addPt(66,7.5); #up
            $square -> addPt(78.5,20); #dx
            $square -> addPt(66,32.5); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);


            $square = new GD::Polygon;
            $square -> addPt(58.5,20); #sx
            $square -> addPt(66,12.5); #up
            $square -> addPt(73.5,20); #dx
            $square -> addPt(66,27.5); #dn
            $graph -> filledPolygon($square,$c[1]);
            $graph -> openPolygon($square,$black);
        }
    }

    if ($dn >= 1 && $up == 0) {
        if ($dn == 1) {
            @c = ($color_dn);
            my $square = new GD::Polygon;
            $square -> addPt(35,20); #sx
            $square -> addPt(50,5); #up
            $square -> addPt(65,20); #dx
            $square -> addPt(50,35); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);

            $square = new GD::Polygon;
            $square -> addPt(40,20); #sx
            $square -> addPt(50,10); #up
            $square -> addPt(60,20); #dx
            $square -> addPt(50,30); #dn
            $graph -> filledPolygon($square,$c[0]);
            $graph -> openPolygon($square,$black);
        } else {
            @c = ($color_dn,$color_dn);
            my $square = new GD::Polygon;
            $square -> addPt(22.5,20); #sx
            $square -> addPt(35,7.5); #up
            $square -> addPt(47.5,20); #dx
            $square -> addPt(35,32.5); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);

            $square = new GD::Polygon;
            $square -> addPt(27.5,20); #sx
            $square -> addPt(35,12.5); #up
            $square -> addPt(42.5,20); #dx
            $square -> addPt(35,27.5); #dn
            $graph -> filledPolygon($square,$c[0]);
            $graph -> openPolygon($square,$black);

            #little square two

            $square = new GD::Polygon;
            $square -> addPt(53.5,20); #sx
            $square -> addPt(66,7.5); #up
            $square -> addPt(78.5,20); #dx
            $square -> addPt(66,32.5); #dn
            $graph -> filledPolygon($square,$grey);
            $graph -> openPolygon($square,$black);


            $square = new GD::Polygon;
            $square -> addPt(58.5,20); #sx
            $square -> addPt(66,12.5); #up
            $square -> addPt(73.5,20); #dx
            $square -> addPt(66,27.5); #dn
            $graph -> filledPolygon($square,$c[1]);
            $graph -> openPolygon($square,$black);
        }
    }

    return($graph);
}
sub AddmiRNAsCirc2{
    my %args = (
        Graph => {},
        miRNAs => 0,
        _urnaup => 0,
        _urnadn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $up = $args{_urnaup};
    my $dn = $args{_urnadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);

    my @x;
    my @y;
    my @c;

    if ($up > 0 && $dn > 0) {
        if ($up > $dn) {
            @x = (17.5,17.5);
            @y = (40,65);
            @c = ($color_up,$color_up);
        }
        if ($dn > $up) {
            @x = (17.5,17.5);
            @y = (40,65);
            @c = ($color_dn,$color_dn);
        }
        if ($dn == $up) {
            @x = (17.5,17.5);
            @y = (40,65);
            @c = ($color_dn,$color_up);
        }
    }

    if ($up >= 1 && $dn == 0) {

        if ($up == 1) {
            @x = (17.5);
            @y = (50);
            @c = ($color_up);
        } else {
            @x = (17.5,17.5);
            @y = (40,65);
            @c = ($color_up,$color_up);
        }
    }

    if ($dn >= 1 && $up == 0) {
        if ($dn == 1) {
            @x = (17.5);
            @y = (50);
            @c = ($color_dn);
        } else {
            @x = (17.5,17.5);
            @y = (40,65);
            @c = ($color_dn,$color_dn);
        }
    }

    foreach my $cnt (0..$#x) {
        $graph->filledEllipse($x[$cnt],$y[$cnt],15,15,$c[$cnt]);
        $graph->arc($x[$cnt],$y[$cnt],15,15,0,360,$black);
    }
    return($graph);
}
sub AddmiRNAsCirc_demo{
    my %args = (
        Graph => {},
        miRNAs => 0,
        @_
    );

    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $color = $args{Color};


    if ($urnas > 1) {
        my @x = (17.5,17.5);
        my @y = (40,65);
        foreach my $cnt (0..$#x) {
            $graph->filledEllipse($x[$cnt],$y[$cnt],15,15,$color);
            $graph->arc($x[$cnt],$y[$cnt],15,15,0,360,$graph->colorAllocate(0,0,0));
        }
    }
    if ($urnas == 1) {
        $graph->filledEllipse(17.5,50,15,15,$color);
        $graph->arc(17.5,50,15,15,0,360,$graph->colorAllocate(0,0,0));
    }

    return($graph);
}

sub AddTFsCirc_demo{
    my %args = (
        Graph => {},
        TFs => 0,
        Color => {},
        @_
    );

    my $graph = $args{Graph};
    my $tfs = $args{TFs};
    my $color = $args{Color};

    my $black = $graph->colorAllocate(0,0,0);

    my @x1;
    my @y1;
    my @x2;
    my @y2;

    if ($tfs > 1) {
        #@x1 = (65,80,95,80);
        #@y1 = (35,20,35,50);
        
        #@x2 = @x1;
        #@y2 = (65,50,65,80);
        @x1 = (75,85,95,85);
        @y1 = (40,30,40,50);
        @x2 = (75,85,95,85);
        @y2 = (70,60,70,80);
        my $diamond1 = new GD::Polygon;
        my $diamond2 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
            $diamond2 -> addPt($x2[$i],$y2[$i]);
        }
        $graph -> filledPolygon($diamond1,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
        $graph -> filledPolygon($diamond2,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond2,$black);
    }
    if ($tfs == 1) {
        #@x1 = (65,80,95,80);
        #@y1 = (30,15,30,45);
        @x1 = (72.5,85,97.5,85);
        @y1 = (40,27.5,40,52.5);


        my $diamond1 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
        }
        $graph -> filledPolygon($diamond1,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
    }
    return($graph);
}



sub AddMethylsCirc_demo{
    my %args = (
        Graph => {},
        Methyls => 0,
        @_
    );
    my $graph = $args{Graph};

    my $meths = $args{Methyls};
    my $color = $args{Color};
    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);


    #little square one
    if ($meths > 1) {
        my $square = new GD::Polygon;
        $square -> addPt(22.5,20); #sx
        $square -> addPt(35,7.5); #up
        $square -> addPt(47.5,20); #dx
        $square -> addPt(35,32.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(27.5,20); #sx
        $square -> addPt(35,12.5); #up
        $square -> addPt(42.5,20); #dx
        $square -> addPt(35,27.5); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

        #little square two

        $square = new GD::Polygon;
        $square -> addPt(53.5,20); #sx
        $square -> addPt(66,7.5); #up
        $square -> addPt(78.5,20); #dx
        $square -> addPt(66,32.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);


        $square = new GD::Polygon;
        $square -> addPt(58.5,20); #sx
        $square -> addPt(66,12.5); #up
        $square -> addPt(73.5,20); #dx
        $square -> addPt(66,27.5); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    if ($meths == 1) {
        my $square = new GD::Polygon;
        $square -> addPt(35,20); #sx
        $square -> addPt(50,5); #up
        $square -> addPt(65,20); #dx
        $square -> addPt(50,35); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,20); #sx
        $square -> addPt(50,10); #up
        $square -> addPt(60,20); #dx
        $square -> addPt(50,30); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);
    }

    return($graph);
}

sub AddChromasCirc_demo{
    my %args = (
        Graph => {},
        Chromas => 0,
        @_
    );
    my $graph = $args{Graph};

    my $chromas = $args{Chromas};
    my $color = $args{Color};
    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);


    #little square one
    if ($chromas > 1) {
        my $square = new GD::Polygon;
        $square -> addPt(22.5,80); #sx
        $square -> addPt(35,67.5); #up
        $square -> addPt(47.5,80); #dx
        $square -> addPt(35,92.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(27.5,80); #sx
        $square -> addPt(35,72.5); #up
        $square -> addPt(42.5,80); #dx
        $square -> addPt(35,87.5); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

        #little square two

        $square = new GD::Polygon;
        $square -> addPt(53.5,80); #sx
        $square -> addPt(66,67.5); #up
        $square -> addPt(78.5,80); #dx
        $square -> addPt(66,92.5); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);


        $square = new GD::Polygon;
        $square -> addPt(58.5,80); #sx
        $square -> addPt(66,72.5); #up
        $square -> addPt(73.5,80); #dx
        $square -> addPt(66,87.5); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    if ($chromas == 1) {
        my $square = new GD::Polygon;
        $square -> addPt(35,80); #sx
        $square -> addPt(50,65); #up
        $square -> addPt(65,80); #dx
        $square -> addPt(50,95); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,80); #sx
        $square -> addPt(50,70); #up
        $square -> addPt(60,80); #dx
        $square -> addPt(50,90); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);
    }
    return($graph);
}

#######

#Squares
sub BuildSquare{

    #print STDERR "BuildSquare\n";
    my %args = (
        Graph => {},
        Color => {},
        Thickness => 1,
        @_
    );

    my $graph = $args{Graph};
    my $color = $args{Color};
    my $thick = $args{Thickness};

    my $poly = new GD::Polygon;
    $graph->setThickness($thick);
	$poly -> addPt(0,50);
	$poly -> addPt(50,0);
	$poly -> addPt(99,50);
    $poly -> addPt(50,100);
    $graph->openPolygon($poly,$color);

    return($graph);
}
sub FillSquare{
    #print STDERR "FillSquare\n";
    my %args = (
        Graph => {},
        Color => {},
        x => 50,
        y => 50,
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my $x = $args{x};
    my $y = $args{y};


    $graph->fill($x,$y,$color);
    return($graph);
}

sub AddmiRNAsSquare{
    my %args = (
        Graph => {},
        miRNAs => 0,
        _urnaup => 0,
        _urnadn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $color = $args{Color};
    my $up = $args{_urnaup};
    my $dn = $args{_urnadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);

    if ($urnas > 1) {
        #my @x = (20,35);
        #my @y = (35,20);
        my @x = (20,20);
        my @y = (35,65);

        my @colors;

        if ($up == $dn) {
            @colors = ($color_up,$color_dn);
        }
        if ($up > $dn) {
            @colors = ($color_up,$color_up);
        }
        if ($dn > $up) {
            @colors = ($color_dn,$color_dn);
        }

        foreach my $cnt (0..$#x) {
            $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$colors[$cnt]);
            $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
        }
    }
    if ($urnas == 1) {
        my $color;
        if ($up > $dn) {
            $color = $graph->colorAllocate(255,255,0);
        } else {
            $color = $graph->colorAllocate(0,0,255);
        }
        #$graph->filledEllipse(30,25,20,20,$color);
        $graph->filledEllipse(20,35,20,20,$color);
        $graph->arc(20,35,20,20,0,360,$black);
    }

    return($graph);
}
sub AddTFsSquare{
    my %args = (
        Graph => {},
        TFs => 0,
        Color => {},
        _tfup => 0,
        _tfdn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $tfs = $args{TFs};
    my $up = $args{_tfup};
    my $dn = $args{_tfdn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);
    #my $yellow = $graph -> colorAllocate(255,255,0);
    #my $blue = $graph->colorAllocate(0,0,255);
    my @x1;
    my @y1;
    my @x2;
    my @y2;
    my $color1;
    my $color2;
    #print STDERR "ADDING TFs to Circles $tfs\n";
    if ($tfs > 1) {
        #@x1 = (50,65,80,65);
        #@y1 = (20,5,20,35);

        @x1 = (67.5,80,92.5,80);
        @y1 = (35,22.5,35,47.5);

        #@x2 = (70,85,100,85);
        #@y2 = (40,25,40,55);

        @x2 = (67.5,80,92.5,80);
        @y2 = (65,52.5,65,77.5);

        if ($up == $dn) {
            $color1 = $color_up;
            $color2 = $color_dn;
        }
        if ($up > $dn) {
            $color1 = $color_up;
            $color2 = $color_up;
        }
        if ($dn > $up) {
            $color1 = $color_dn;
            $color2 = $color_dn;
        }

        my $diamond1 = new GD::Polygon;
        my $diamond2 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
            $diamond2 -> addPt($x2[$i],$y2[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
        $graph -> filledPolygon($diamond2,$color2);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond2,$black);
    }
    if ($tfs == 1) {
        #@x1 = (60,75,90,75);
        #@y1 = (30,15,30,45);

        @x1 = (67.5,80,92.5,80);
        @y1 = (35,22.5,35,47.5);
        
        if ($up > $dn) {
            $color1 = $color_up;
        }
        if ($dn > $up) {
            $color1 = $color_dn;
        }

        my $diamond1 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
    }
    #print STDERR "Returning from AddTFsSquare\n";
    return($graph);
}

sub AddMethylsSquare{
    my %args = (
        Graph => {},
        Methyls => 0,
        ColorUp => {},
        ColorDn => {},
        _methup => 0,
        _methdn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $meths = $args{Methyls};
    my $up = $args{_methup};
    my $dn = $args{_methdn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};

    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);

    if ($meths == 1) {
        my $color;
        #print STDERR "meth found -> ".$meths."\n";
        if ($up == 1) {
            $color = $color_up;
        }
        if ($dn == 1) {
            $color = $color_dn;
        }

        my $square = new GD::Polygon;
        $square -> addPt(35,15); #sx
        $square -> addPt(50,0); #up
        $square -> addPt(65,15); #dx
        $square -> addPt(50,30); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,15); #sx
        $square -> addPt(50,5); #up
        $square -> addPt(60,15); #dx
        $square -> addPt(50,25); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    return($graph);
}
sub AddChromaSquare {
    my %args = (
        Graph => {},
        Chromas => 0,
        ColorUp => {},
        ColorDn => {},
        _chromaup => 0,
        _chromadn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $chromas = $args{Chromas};
    my $up = $args{_chromaup};
    my $dn = $args{_chromadn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};

    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);

    if ($chromas == 1) {
        my $color;
        #print STDERR "meth found -> ".$meths."\n";
        if ($up == 1) {
            $color = $color_up;
        }
        if ($dn == 1) {
            $color = $color_dn;
        }

        my $square = new GD::Polygon;
        $square -> addPt(35,85); #sx chroma
        $square -> addPt(50,70); #up
        $square -> addPt(65,85); #dx
        $square -> addPt(50,100); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,85); #sx
        $square -> addPt(50,75); #up
        $square -> addPt(60,85); #dx
        $square -> addPt(50,95); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    return($graph);
}
sub AddmiRNAsSquare_demo{
    my %args = (
        Graph => {},
        miRNAs => 0,
        @_
    );

    my $graph = $args{Graph};
    my $urnas = $args{miRNAs};
    my $color = $args{Color};


    if ($urnas > 1) {
        #my @x = (20,35);
        #my @y = (35,20);
        my @x = (20,20);
        my @y = (35,65);
        foreach my $cnt (0..$#x) {
            $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$color);
            $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$graph->colorAllocate(0,0,0));
        }
    }
    if ($urnas == 1) {
        $graph->filledEllipse(20,35,20,20,$color);
        $graph->arc(20,35,20,20,0,360,$graph->colorAllocate(0,0,0));
    }

    return($graph);
}
sub AddTFsSquare_demo{
    my %args = (
        Graph => {},
        TFs => 0,
        Color => {},
        @_
    );

    my $graph = $args{Graph};
    my $tfs = $args{TFs};
    my $color = $args{Color};

    my $black = $graph->colorAllocate(0,0,0);

    my @x1;
    my @y1;
    my @x2;
    my @y2;

    if ($tfs > 1) {
        #@x1 = (52.5,65,77.5,65);
        #@y1 = (20,7.5,20,32.5);

        @x1 = (67.5,80,92.5,80);
        @y1 = (35,22.5,35,47.5);

        #@x2 = (70,85,100,85);
        #@y2 = (40,25,40,55);

        @x2 = (67.5,80,92.5,80);
        @y2 = (65,52.5,65,77.5);

        my $diamond1 = new GD::Polygon;
        my $diamond2 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
            $diamond2 -> addPt($x2[$i],$y2[$i]);
        }
        $graph -> filledPolygon($diamond1,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
        $graph -> filledPolygon($diamond2,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond2,$black);
    }
    if ($tfs == 1) {
        #@x1 = (62.5,75,87.5,75);
        #@y1 = (30,17.5,30,42.5);
        @x1 = (67.5,80,92.5,80);
        @y1 = (35,22.5,35,47.5);
        my $diamond1 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
        }
        $graph -> filledPolygon($diamond1,$color);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
    }
    return($graph);
}
sub AddMethylsSquare_demo{
    my %args = (
        Graph => {},
        Methyls => 0,
        Color => {},
        @_
    );

    my $color1;

    my $graph = $args{Graph};
    my $meths = $args{Methyls};
    my $color = $args{Color};


    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);

    if ($meths == 1) {
        #print STDERR "Trying to print\n";
        my $square = new GD::Polygon;
        #$square -> addPt(35,85); #sx chroma
        #$square -> addPt(50,70); #up
        #$square -> addPt(65,85); #dx
        #$square -> addPt(50,100); #dn
        $square -> addPt(35,15); #sx
        $square -> addPt(50,0); #up
        $square -> addPt(65,15); #dx
        $square -> addPt(50,30); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        #$square -> addPt(40,85); #sx
        #$square -> addPt(50,75); #up
        #$square -> addPt(60,85); #dx
        #$square -> addPt(50,95); #dn
        $square -> addPt(40,15); #sx
        $square -> addPt(50,5); #up
        $square -> addPt(60,15); #dx
        $square -> addPt(50,25); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    return($graph);
}
sub AddChromaSquare_demo {
    my %args = (
        Graph => {},
        Chromas => 0,
        Color => {},
        @_
    );

    my $color1;

    my $graph = $args{Graph};
    my $chromas = $args{Chromas};
    my $color = $args{Color};


    my $black = $graph -> colorAllocate(0,0,0);
    my $grey = $graph->colorAllocate(128,128,128);

    if ($chromas == 1) {
        #print STDERR "Trying to print\n";
        my $square = new GD::Polygon;
        $square -> addPt(35,85); #sx chroma
        $square -> addPt(50,70); #up
        $square -> addPt(65,85); #dx
        $square -> addPt(50,100); #dn
        #$square -> addPt(35,15); #sx
        #$square -> addPt(50,0); #up
        #$square -> addPt(65,15); #dx
        #$square -> addPt(50,30); #dn
        $graph -> filledPolygon($square,$grey);
        $graph -> openPolygon($square,$black);

        $square = new GD::Polygon;
        $square -> addPt(40,85); #sx
        $square -> addPt(50,75); #up
        $square -> addPt(60,85); #dx
        $square -> addPt(50,95); #dn
        #$square -> addPt(40,15); #sx
        #$square -> addPt(50,5); #up
        #$square -> addPt(60,15); #dx
        #$square -> addPt(50,25); #dn
        $graph -> filledPolygon($square,$color);
        $graph -> openPolygon($square,$black);

    }
    return($graph);
}
####


#Pointers
sub BuildPointer{

    my %args = (
        Graph => {},
        Color => {},
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my $tip = $args{Tip};

    my $poly = new GD::Polygon;
    $graph->arc(50,50,30,30,0,360,$color);
    $graph->arc(50,50,50,50,0,360,$color);
    if ($tip eq "up") {
        $poly->addPt(30,35);
        $poly->addPt(50,10);
        $poly->addPt(70,35);
    }
    if ($tip eq "dn") {
        $poly->addPt(30,65);
        $poly->addPt(50,90);
        $poly->addPt(70,65);
    }
    $graph->openPolygon($poly,$color);
    return($graph);
}
sub FillPointer{

    my %args = (
        Graph => {},
        Color => {},
        Tip => "",
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my $x = $args{x};
    my $y = $args{y};
    my $tip = $args{Tip};
    $graph->fill(30,50,$color);
    $graph->fill($x,$y,$color);
    if ($tip eq "dn") {
        $graph->fill(50,70,$color);
    }
    if ($tip eq "up") {
        $graph->fill(50,30,$color);
    }


    return($graph);
}

sub BuildGenericPointer{
    my %args = (
        Graph => {},
        Color => {},
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    $graph->arc(50,50,30,30,0,360,$color);
    $graph->arc(50,50,50,50,0,360,$color);
    return($graph);
}
sub FillGenericPointer{
    my %args = (
        Graph => {},
        Color => {},
        @_
    );
    my $graph = $args{Graph};
    my $color = $args{Color};
    my $x = $args{x};
    my $y = $args{y};
    $graph->fill(30,50,$color);
    return($graph);
}

#Diamonds

sub AddTFsDiamondsTri{

    my %args = (
        Graph => {},
        TFs => 0,
        _tfup => 0,
        _tfdn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $tfs = $args{TFs};
    my $up = $args{_tfup};
    my $dn = $args{_tfdn};
    my $devup = $args{_devup};
    my $devdn = $args{_devdn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);
    #my $yellow = $graph -> colorAllocate(255,255,0);
    #my $blue = $graph->colorAllocate(0,0,255);
    my $color1;
    my $color2;
    my @x1; #sx - up - dx - dn
    my @y1;
    my @x2;
    my @y2;

    #$diamond -> addPt(65,65); #sx
    #$diamond -> addPt(70,45); #up
    #$diamond -> addPt(75,65); #dx
    #$diamond -> addPt(70,85); #dn

    if ($up > 0 && $dn > 0) {

        if ($devdn > $devup) {
            @x1 = (65,80,95,80);
            @y1 = (40,25,40,55);
            @x2 = (50,65,80,65);
            @y2 = (70,55,70,85);
        } else {
            @x1 = (50,65,80,65);
            @y1 = (30,15,30,45);
            @x2 = (65,80,95,80);
            @y2 = (60,45,60,75);
        }
        if ($up > $dn) {
            $color1 = $args{ColorUp};
            $color2 = $args{ColorUp};
        }
        if ($dn > $up) {
            $color1 = $args{ColorDn};
            $color2 = $args{ColorDn};
        }
        if ($up == $dn) {
            $color1 = $args{ColorDn};
            $color2 = $args{ColorUp};
        }
    }
    if ($up >= 1 && $dn == 0) {
        if ($up == 1) {
            if ($devdn > $devup) {
                @x1 = (60,75,90,75);
                @y1 = (55,40,55,70);
            } else {
                @x1 = (60,75,90,75);
                @y1 = (50,35,50,65);
            }
            $color1 = $args{ColorUp};
        } else {
            if ($devdn > $devup) {
                @x1 = (65,80,95,80);
                @y1 = (40,25,40,55);
                @x2 = (50,65,80,65);
                @y2 = (70,55,70,85);
            } else {
                @x1 = (50,65,80,65);
                @y1 = (30,15,30,45);
                @x2 = (65,80,95,80);
                @y2 = (60,45,60,75);
            }
            $color1 = $args{ColorUp};
            $color2 = $args{ColorUp};
        }
    }
    if ($dn >= 1 && $up == 0) {
        if ($dn == 1) {
            if ($devdn > $devup) {
                @x1 = (60,75,90,75);
                @y1 = (55,40,55,70);
            } else {
                @x1 = (60,75,90,75);
                @y1 = (50,35,50,65);
            }
            $color1 = $args{ColorDn};
        } else {
            if ($devdn > $devup) {
                @x1 = (65,80,95,80);
                @y1 = (40,25,40,55);
                @x2 = (50,65,80,65);
                @y2 = (70,55,70,85);
            } else {
                @x1 = (50,65,80,65);
                @y1 = (30,15,30,45);
                @x2 = (65,80,95,80);
                @y2 = (60,45,60,75);
            }
            $color1 = $args{ColorDn};
            $color2 = $args{ColorDn};
        }
    }

    if (scalar @x2 > 0) {
        my $diamond1 = new GD::Polygon;
        my $diamond2 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
            $diamond2 -> addPt($x2[$i],$y2[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
        $graph -> filledPolygon($diamond2,$color2);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond2,$black);
    } else {
        my $diamond1 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
    }

    return($graph);

    #my $diamond = new GD::Polygon;
    #$diamond -> addPt(75,40); #sx
    #$diamond -> addPt(80,20); #up
    #$diamond -> addPt(85,40); #dx
    #$diamond -> addPt(80,60); #dn
    #$graph -> filledPolygon($diamond,$yellow);
    #$diamond = new GD::Polygon;
    #$diamond -> addPt(75,40); #sx
    #$diamond -> addPt(80,20); #up
    #$diamond -> addPt(85,40); #dx
    #$diamond -> addPt(80,60); #dn
    #$graph -> setThickness(1);
    #$graph -> openPolygon($diamond,$black);
    #$diamond = new GD::Polygon;
    #$diamond -> addPt(65,65); #sx
    #$diamond -> addPt(70,45); #up
    #$diamond -> addPt(75,65); #dx
    #$diamond -> addPt(70,85); #dn
    #$graph -> filledPolygon($diamond,$blue);
    #$diamond = new GD::Polygon;
    #$diamond -> addPt(65,65); #sx
    #$diamond -> addPt(70,45); #up
    #$diamond -> addPt(75,65); #dx
    #$diamond -> addPt(70,85); #dn
    #$graph -> setThickness(1);
    #$graph -> openPolygon($diamond,$black);
}

sub AddTFsDiamondsCirc{
    my %args = (
        Graph => {},
        TFs => 0,
        _tfup => 0,
        _tfdn => 0,
        @_
    );

    my $graph = $args{Graph};
    my $tfs = $args{TFs};
    my $up = $args{_tfup};
    my $dn = $args{_tfdn};
    my $devup = $args{_devup};
    my $devdn = $args{_devdn};
    my $color_up = $args{ColorUp};
    my $color_dn = $args{ColorDn};
    my $black = $graph -> colorAllocate(0,0,0);

    my $color1;
    my $color2;
    my @x1; #sx - up - dx - dn
    my @y1;
    my @x2;
    my @y2;
    #print STDERR "ADDING TFs to Circles $tfs\n";
    if ($up > 0 && $dn > 0) {

        #@x1 = (72.5,85,97.5,85);
        #@y1 = (40,27.5,40,52.5);
        #@x2 = (72.5,85,97.5,85);
        #@y2 = (70,57.5,70,82.5);

        @x1 = (75,85,95,85);
        @y1 = (40,30,40,50);
        @x2 = (75,85,95,85);
        @y2 = (70,60,70,80);


        if ($up > $dn) {
            $color1 = $args{ColorUp};
            $color2 = $args{ColorUp};
        }
        if ($dn > $up) {
            $color1 = $args{ColorDn};
            $color2 = $args{ColorDn};
        }
        if ($up == $dn) {
            $color1 = $args{ColorDn};
            $color2 = $args{ColorUp};
        }
    }

    if ($up >= 1 && $dn == 0) {

        if ($up == 1) {
            $color1 = $args{ColorUp};
            @x1 = (72.5,85,97.5,85);
            @y1 = (50,37.5,50,62.5);
        } else {
            $color1 = $args{ColorUp};
            $color2 = $args{ColorUp};
            @x1 = (75,85,95,85);
            @y1 = (40,30,40,50);
            @x2 = (75,85,95,85);
            @y2 = (70,60,70,80);
        }

    }

    if ($dn >= 1 && $up == 0) {

        if ($dn == 1) {
            $color1 = $args{ColorUp};
            @x1 = (72.5,85,97.5,85);
            @y1 = (50,37.5,50,62.5);
        } else {
            $color1 = $args{ColorDn};
            $color2 = $args{ColorDn};
            @x1 = (75,85,95,85);
            @y1 = (40,30,40,50);
            @x2 = (75,85,95,85);
            @y2 = (70,60,70,80);
        }
    }

    if (scalar @x2 > 0) {
        my $diamond1 = new GD::Polygon;
        my $diamond2 = new GD::Polygon;
        #$color1 = $args{ColorUp};
        #$color2 = $args{ColorDn};
        # What ?
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
            $diamond2 -> addPt($x2[$i],$y2[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
        $graph -> filledPolygon($diamond2,$color2);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond2,$black);
    } else {
        $color1 = $args{ColorUp};
        my $diamond1 = new GD::Polygon;
        foreach my $i (0..$#x1) {
            $diamond1 -> addPt($x1[$i],$y1[$i]);
        }
        $graph -> filledPolygon($diamond1,$color1);
        $graph -> setThickness(1);
        $graph -> openPolygon($diamond1,$black);
    }
    #print STDERR "Returning from AddTFsDiamondsCirc\n";
    return($graph);
}


sub Draw{
    #print STDERR "Draw\n";
    my %args = (
        Graph => {},
        @_
    );

    my $graph = $args{Graph};
    #open(OUT,">","prova.png");
    #binmode OUT;
    #print OUT $graph->png;
    #close OUT;
    print "Content-type: image/png\n\n";
    binmode STDOUT;
    print $graph->png;
}

1;
