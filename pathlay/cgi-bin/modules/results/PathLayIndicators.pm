use strict;
use warnings;
use GD;

our $switches;
our $graph;
our $thick;

our $black;
our $orange;
our $yellow;
our $blue;
our $grey;



package Square;
    sub new {

        my $class = shift;
        my $self = {
            @_
        };

        bless $self, $class;
        return($self);
    }
    sub defineShape {
        my $self = shift;
        my %args = (
            Thickness => 1,
            @_
        );

        my $thick = $args{Thickness}; 

        $self -> {shape} = new GD::Polygon;

        
        $self -> {shape} -> addPt(0,50);
        $self -> {shape} -> addPt(50,0);
        $self -> {shape} -> addPt(99,50);
        $self -> {shape} -> addPt(50,100);

        $graph->setThickness($thick);
    }
    sub colorBorder {
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        $graph->openPolygon($self -> {shape},$color);
    }
    sub colorBody {
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        $graph->fill(50,50,$color);
    }
    sub addSmallCircles {
        
        my $self = shift;
        my %args = (
            @_
        );
        my @colorsToUse;
        if ($switches -> {_components} -> {_left} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {_left} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {_left} -> {_orange}) {
            push(@colorsToUse,$orange);
        }

        if ($switches -> {_totalmiRNAs} == 1) {
            $graph->filledEllipse(20,35,20,20,$colorsToUse[0]);
            $graph->arc(20,35,20,20,0,360,$black);
        }
        if ($switches -> {_totalmiRNAs} > 1) {
            
            my @x = (20,20);
            my @y = (35,65);

            if (scalar(@colorsToUse) == 3) {
                push(@x,10);
                push(@y,50);
            }
            if (scalar(@colorsToUse) == 1) {
                push(@colorsToUse,$colorsToUse[0]);
            } else {
                if ($switches -> {_idOnlymiRNAs} == 0) {
                    if ($switches -> {_urnaUp} > $switches -> {_urnaDn}) {
                        @colorsToUse = ($yellow,$yellow);
                    }
                    if ($switches -> {_urnaUp} < $switches -> {_urnaDn}) {
                        @colorsToUse = ($blue,$blue);
                    }
                } elsif ($switches -> {_urnaUp} == 0) {
                    @colorsToUse = ($blue,$orange);
                } elsif ($switches -> {_urnaDn} == 0) {
                    @colorsToUse = ($yellow,$orange);
                }
            }
            foreach my $cnt (0..$#x) {
                $graph->filledEllipse($x[$cnt],$y[$cnt],20,20,$colorsToUse[$cnt]);
                $graph->arc($x[$cnt],$y[$cnt],20,20,0,360,$black);
            }
        }
        return($graph);
    }
    sub addSmallSquares {
        use Data::Dumper;
        local *smallSquareScaler = sub {
            my %args = (
                @_
            );
            my $centerX = $args{centerX};
            my $centerY = $args{centerY};
            my $distance = $args{distance};

            my @xCoords = [
                ($centerX - ($distance/2)),
                $centerX,
                ($centerX + ($distance/2)),
                $centerX
            ]; 
            my @yCoords = [
                $centerY,
                ($centerY + ($distance/2)),
                $centerY,
                ($centerY - ($distance/2))
            ];
            return(\@xCoords,\@yCoords);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $position = $args{Position};
        my $total = $args{SwitchesTotal};
        my $up = $args{SwitchesUp};
        my $dn = $args{SwitchesDn};
        my $idOnly = $args{SwitchesId};
        my $centerXSingle;
        my $centerYSingle;
        my $centerXOne;
        my $centerYOne;
        my $centerXTwo;
        my $centerYTwo;
        my $centerXThree;
        my $centerYThree;
        my $distance = 20;


        if ($position eq "top") {
            $centerXSingle = 50;
            $centerYSingle = 15;
            print STDERR "$total\t$up\t$dn\t$idOnly\n";
        }
        if ($position eq "bot") {
            $centerXSingle = 50;
            $centerYSingle = 80;
        }
        if ($position eq "right") {
            $centerXSingle = 85;
            $centerYSingle = 35;
            $centerXOne = 80;
            $centerYOne = 35;
            $centerXTwo = 80;
            $centerYTwo = 65;
            $centerXThree = 80;
            $centerYThree = 50;
        }

        my @colorsToUse;
        my @xCoords;
        my @yCoords;
        if ($switches -> {_components} -> {"_".$position} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {"_".$position} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {"_".$position} -> {_orange}) {
            push(@colorsToUse,$orange);
        }
        if ($total == 1) {
            my ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXSingle,
                centerY => $centerYSingle,
                distance => $distance
            );
            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);
            
        }
        if ($total > 1) {
            my ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXOne,
                centerY => $centerYOne,
                distance => $distance
            );
            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);

            ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXTwo,
                centerY => $centerYTwo,
                distance => $distance
            );
            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);

            if (scalar(@colorsToUse) == 3) {
                my ($xtmp,$ytmp) = smallSquareScaler(
                    centerX => $centerXThree,
                    centerY => $centerYThree,
                    distance => $distance
                );
                push(@xCoords,@$xtmp);
                push(@yCoords,@$ytmp);
            }
            if (scalar(@colorsToUse) == 1) {
                push(@colorsToUse,$colorsToUse[0]);
            } else {
                if ($idOnly == 0) {
                    if ($up > $dn) {
                        @colorsToUse = ($yellow,$yellow);
                    }
                    if ($up < $dn) {
                        @colorsToUse = ($blue,$blue);
                    }
                } elsif ($up == 0) {
                    @colorsToUse = ($blue,$orange);
                } elsif ($dn == 0) {
                    @colorsToUse = ($yellow,$orange);
                }
            }
        }
        foreach my $i (0..$#xCoords) {
            my $diamond = new GD::Polygon;
            my $last = scalar(@{$xCoords[$i]}) - 1;
            foreach my $c (0..$last) {
                $diamond -> addPt($xCoords[$i][$c],$yCoords[$i][$c]);
            }
            $graph -> filledPolygon($diamond,$colorsToUse[$i]);
            $graph -> setThickness(1);
            $graph -> openPolygon($diamond,$black);
        }
    }
    sub addSmallBorderedSquaresTop {
        my $self = shift;
        my %args = (
            @_
        );
        my @colorsToUse;
        my @xBorderCoords;
        my @yBorderCoords;
        my @xInsideCoords;
        my @yInsideCoords;
        if ($switches -> {_components} -> {_top} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {_top} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {_top} -> {_orange}) {
            push(@colorsToUse,$orange);
        }

        if ($switches -> {_totalMeths} == 1) {
            push(@xBorderCoords,[35,50,65,50]);
            push(@yBorderCoords,[15,0,15,30]);
            push(@xInsideCoords,[40,50,60,50]);
            push(@yInsideCoords,[15,5,15,25]);
        }
        


        foreach my $i (0..$#xBorderCoords){
            my $squareInside = new GD::Polygon;
            my $squareBorder = new GD::Polygon;
            my $last = scalar(@{$xBorderCoords[$i]}) - 1;
            foreach my $c (0..$last) {
                $squareBorder -> addPt($xBorderCoords[$i][$c],$yBorderCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareBorder,$graph -> colorAllocate(128,128,128));
            $graph -> openPolygon($squareBorder,$black);
            foreach my $c (0..$last) {
                $squareInside -> addPt($xInsideCoords[$i][$c],$yInsideCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareInside,$colorsToUse[$i]);
            $graph -> openPolygon($squareInside,$black);
        }
        
    }
    sub addSmallSquaresTop {
        my $self = shift;
        my %args = (
            @_
        );
        my @colorsToUse;
        my @xBorderCoords;
        my @yBorderCoords;
        my @xInsideCoords;
        my @yInsideCoords;
        if ($switches -> {_components} -> {_top} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {_top} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {_top} -> {_orange}) {
            push(@colorsToUse,$orange);
        }

        if ($switches -> {_totalMeths} == 1) {
            push(@xBorderCoords,[35,50,65,50]);
            push(@yBorderCoords,[15,0,15,30]);
            push(@xInsideCoords,[40,50,60,50]);
            push(@yInsideCoords,[15,5,15,25]);
        }
        


        foreach my $i (0..$#xBorderCoords){
            my $squareInside = new GD::Polygon;
            my $squareBorder = new GD::Polygon;
            my $last = scalar(@{$xBorderCoords[$i]}) - 1;
            foreach my $c (0..$last) {
                $squareBorder -> addPt($xBorderCoords[$i][$c],$yBorderCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareBorder,$graph -> colorAllocate(128,128,128));
            $graph -> openPolygon($squareBorder,$black);
            foreach my $c (0..$last) {
                $squareInside -> addPt($xInsideCoords[$i][$c],$yInsideCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareInside,$colorsToUse[$i]);
            $graph -> openPolygon($squareInside,$black);
        }
        
    }
package Circle;
    our @ISA = qw(Square);
    sub makeArc {
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        $graph->arc(50,50,75,75,0,360,$color);
    }
    sub colorArc {
        my $self = shift;
        my %args = (
            Color => {},
            x => 50,
            y => 50,
            @_
        );
        my $color = $args{Color};
        my $x = $args{x};
        my $y = $args{y};
        $graph->fill($x,$y,$color);
    }
    sub splitInTwo {
        my $self = shift;
        my %args = (
            Color => {},
            Position => "half", 
            @_
        );
        my $color = $args{Color};
        my $position = $args{Position};
        my ($x1,$y1,$x2,$y2);
        if ($position eq "half") {
            ($x1,$y1,$x2,$y2) = (12,50,90,50);
        }
        if ($position eq "higher") {
            ($x1,$y1,$x2,$y2) = (14,40,85,40);    
        }
        if ($position eq "lower") {
            ($x1,$y1,$x2,$y2) = (14,60,85,60);    
        }
        $graph -> line($x1,$y1,$x2,$y2,$color);
    }
    sub splitInThree {
        use Data::Dumper qw(Dumper);
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        my $method = $args{Method};
        my @lineCoords;

        if ($method eq "equal") {
            push(@lineCoords,[50,10,50,50]);
            push(@lineCoords,[15,90,50,50]); #draw left skewed line
            push(@lineCoords,[75,90,50,50]); #draw right skewed $line
        }
        if ($method eq "top") {
            push(@lineCoords,[12,50,90,50]);
            push(@lineCoords,[50,10,50,50]);
        }
        if ($method eq "bot") {
            push(@lineCoords,[12,50,90,50]);
            push(@lineCoords,[50,90,50,50]);
        }
        #print STDERR Dumper \@lineCoords;
        foreach my $coordSet (0..$#lineCoords) {
            $graph -> line($lineCoords[$coordSet][0],$lineCoords[$coordSet][1],$lineCoords[$coordSet][2],$lineCoords[$coordSet][3],$color);
        }
    }
    sub splitInFour {
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        my ($x1,$y1,$x2,$y2);
        $graph -> line($x1,$y1,$x2,$y2,$color);
    }
    sub addSmallCircles {
        my $self = shift;
        my %args = (
            @_
        );
        my @colorsToUse;
        if ($switches -> {_components} -> {_left} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {_left} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {_left} -> {_orange}) {
            push(@colorsToUse,$orange);
        }

        if ($switches -> {_totalmiRNAs} == 1) {
            $graph->filledEllipse(20,35,20,20,$colorsToUse[0]);
            $graph->arc(20,35,20,20,0,360,$black);
        }
        if ($switches -> {_totalmiRNAs} > 1) {
            
            my @x = (17.5,17.5);
            my @y = (35,65);

            if (scalar(@colorsToUse) == 3) {
                push(@x,17.5);
                push(@y,50);
            }
            if (scalar(@colorsToUse) == 1) {
                push(@colorsToUse,$colorsToUse[0]);
            } else {
                if ($switches -> {_idOnlymiRNAs} == 0) {
                    if ($switches -> {_urnaUp} > $switches -> {_urnaDn}) {
                        @colorsToUse = ($yellow,$yellow);
                    }
                    if ($switches -> {_urnaUp} < $switches -> {_urnaDn}) {
                        @colorsToUse = ($blue,$blue);
                    }
                } elsif ($switches -> {_urnaUp} == 0) {
                    @colorsToUse = ($blue,$orange);
                } elsif ($switches -> {_urnaDn} == 0) {
                    @colorsToUse = ($yellow,$orange);
                }
            }
            foreach my $cnt (0..$#x) {
                $graph->filledEllipse($x[$cnt],$y[$cnt],15,15,$colorsToUse[$cnt]);
                $graph->arc($x[$cnt],$y[$cnt],15,15,0,360,$black);
            }
        }
        return($graph);
    }

    sub addSmallBorderedSquaresTop {
        my $self = shift;
        my %args = (
            @_
        );
        my @colorsToUse;
        my @xBorderCoords;
        my @yBorderCoords;
        my @xInsideCoords;
        my @yInsideCoords;
        if ($switches -> {_components} -> {_top} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {_top} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {_top} -> {_orange}) {
            push(@colorsToUse,$orange);
        }

        if ($switches -> {_totalMeths} == 1) {
            push(@xBorderCoords,[35,50,65,50]);
            push(@yBorderCoords,[15,0,15,30]);
            push(@xInsideCoords,[40,50,60,50]);
            push(@yInsideCoords,[15,5,15,25]);
        }

        if ($switches -> {_totalMeths} > 1) {
            push(@xBorderCoords,[22.5,35,47.5,35]);
            push(@yBorderCoords,[20,7.5,20,32.5]);
            push(@xInsideCoords,[27.5,35,42.5,35]);
            push(@yInsideCoords,[20,12.5,20,27.5]);

            push(@xBorderCoords,[53.5,66,78.5,66]);
            push(@yBorderCoords,[20,7.5,20,32.5]);
            push(@xInsideCoords,[58.5,66,73.5,66]);
            push(@yInsideCoords,[20,12.5,20,27.5]);


            if (scalar(@colorsToUse) == 3) {
                push(@xBorderCoords,[53.5,66,78.5,66]);
                push(@yBorderCoords,[20,7.5,20,32.5]);
                push(@xInsideCoords,[58.5,66,73.5,66]);
                push(@yInsideCoords,[20,12.5,20,27.5]);
            }
            if (scalar(@colorsToUse) == 1) {
                push(@colorsToUse,$colorsToUse[0]);
            } else {
                if ($switches -> {_idOnlyMeths} == 0) {
                    if ($switches -> {_tfUp} > $switches -> {_tfDn}) {
                        @colorsToUse = ($yellow,$yellow);
                    }
                    if ($switches -> {_tfUp} < $switches -> {_tfDn}) {
                        @colorsToUse = ($blue,$blue);
                    }
                } elsif ($switches -> {_methUp} == 0) {
                    @colorsToUse = ($blue,$orange);
                } elsif ($switches -> {_methDn} == 0) {
                    @colorsToUse = ($yellow,$orange);
                }
            }
        }
        


        foreach my $i (0..$#xBorderCoords){
            my $squareInside = new GD::Polygon;
            my $squareBorder = new GD::Polygon;
            my $last = scalar(@{$xBorderCoords[$i]}) - 1;
            foreach my $c (0..$last) {
                $squareBorder -> addPt($xBorderCoords[$i][$c],$yBorderCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareBorder,$graph -> colorAllocate(128,128,128));
            $graph -> openPolygon($squareBorder,$black);
            foreach my $c (0..$last) {
                $squareInside -> addPt($xInsideCoords[$i][$c],$yInsideCoords[$i][$c]);
            }
            $graph -> filledPolygon($squareInside,$colorsToUse[$i]);
            $graph -> openPolygon($squareInside,$black);
        }
    }
    sub addSmallSquares {
        use Data::Dumper;
        local *smallSquareScaler = sub {
            my %args = (
                @_
            );
            my $centerX = $args{centerX};
            my $centerY = $args{centerY};
            my $distance = $args{distance};

            my @xCoords = [
                ($centerX - ($distance/2)),
                $centerX,
                ($centerX + ($distance/2)),
                $centerX
            ]; 
            my @yCoords = [
                $centerY,
                ($centerY + ($distance/2)),
                $centerY,
                ($centerY - ($distance/2))
            ];
            return(\@xCoords,\@yCoords);
        };

        my $self = shift;
        my %args = (
            @_
        );
        my $position = $args{Position};
        my $total = $args{SwitchesTotal};
        my $up = $args{SwitchesUp};
        my $dn = $args{SwitchesDn};
        my $idOnly = $args{SwitchesId};
        my $centerXSingle;
        my $centerYSingle;
        my $centerXOne;
        my $centerYOne;
        my $centerXTwo;
        my $centerYTwo;
        my $centerXThree;
        my $centerYThree;
        my $distance = 20;

        if ($position eq "top") {
            $centerXSingle = 50;
            $centerYSingle = 15;
            $centerXOne = 35;
            $centerYOne = 15;
            $centerXTwo = 65;
            $centerYTwo = 15;
            $centerXThree = 50;
            $centerYThree = 15;
        }
        if ($position eq "bot") {
            $centerXSingle = 50;
            $centerYSingle = 80;
            $centerXOne = 35;
            $centerYOne = 80;
            $centerXTwo = 65;
            $centerYTwo = 80;
            $centerXThree = 50;
            $centerYThree = 80;
        }
        if ($position eq "right") {
            $centerXSingle = 85;
            $centerYSingle = 50;
            $centerXOne = 80;
            $centerYOne = 35;
            $centerXTwo = 80;
            $centerYTwo = 65;
            $centerXThree = 80;
            $centerYThree = 50;
        }

        my @colorsToUse;
        my @xCoords;
        my @yCoords;
        if ($switches -> {_components} -> {"_".$position} -> {_yellow}) {
            push(@colorsToUse,$yellow);
        }
        if ($switches -> {_components} -> {"_".$position} -> {_blue}) {
            push(@colorsToUse,$blue);
        }
        if ($switches -> {_components} -> {"_".$position} -> {_orange}) {
            push(@colorsToUse,$orange);
        }
        if ($total == 1) {
            my ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXSingle,
                centerY => $centerYSingle,
                distance => $distance
            );
            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);
            
        }
        if ($total > 1) {
            my ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXOne,
                centerY => $centerYOne,
                distance => $distance
            );
            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);

            ($xtmp,$ytmp) = smallSquareScaler(
                centerX => $centerXTwo,
                centerY => $centerYTwo,
                distance => $distance
            );

            push(@xCoords,@$xtmp);
            push(@yCoords,@$ytmp);

            if (scalar(@colorsToUse) == 3) {
                my ($xtmp,$ytmp) = smallSquareScaler(
                    centerX => $centerXThree,
                    centerY => $centerYThree,
                    distance => $distance
                );
                push(@xCoords,@$xtmp);
                push(@yCoords,@$ytmp);
            }
            if (scalar(@colorsToUse) == 1) {
                push(@colorsToUse,$colorsToUse[0]);
            } else {
                if ($idOnly == 0) {
                    if ($up > $dn) {
                        @colorsToUse = ($yellow,$yellow);
                    }
                    if ($up < $dn) {
                        @colorsToUse = ($blue,$blue);
                    }
                } elsif ($up == 0) {
                    @colorsToUse = ($blue,$orange);
                } elsif ($dn == 0) {
                    @colorsToUse = ($yellow,$orange);
                }
            }
        }
        foreach my $i (0..$#xCoords) {
            my $diamond = new GD::Polygon;
            my $last = scalar(@{$xCoords[$i]}) - 1;
            foreach my $c (0..$last) {
                $diamond -> addPt($xCoords[$i][$c],$yCoords[$i][$c]);
            }
            $graph -> filledPolygon($diamond,$colorsToUse[$i]);
            $graph -> setThickness(1);
            $graph -> openPolygon($diamond,$black);
        }
    }

package Pin;
    sub new {

        my $class = shift;
        my $self = {
            @_
        };

        bless $self, $class;
        return($self);
    }
    sub makeArc {
        my $self = shift;
        my %args = (
            Color => {},
            @_
        );
        my $color = $args{Color};
        $graph->arc(50,50,30,30,0,360,$color);
        $graph->arc(50,50,50,50,0,360,$color);
    }
    sub defineTip {
        my $self = shift;
        my %args = (
            Thickness => 1,
            @_
        );

        my $thick = $args{Thickness}; 

        my $color = $args{Color};
        my $tip = $args{Tip};

        $self -> {tip} = new GD::Polygon;
        if ($tip eq "up") {
            $self -> {tip} -> addPt(30,35);
            $self -> {tip} -> addPt(50,10);
            $self -> {tip} -> addPt(70,35);
        }
        if ($tip eq "dn") {
            $self -> {tip} -> addPt(30,65);
            $self -> {tip} -> addPt(50,90);
            $self -> {tip} -> addPt(70,65);
        }
        $graph->openPolygon($self -> {tip},$color);
        $graph->setThickness($thick);
    }
    sub colorTip {
        my $self = shift;
        my %args = (
            Color => {},
            Tip => "",
            @_
        );
        my $color = $args{Color};
        my $tip = $args{Tip};
        my $x;
        my $y;
        if ($tip eq "dn") {
            $x = 50;
            $y = 80;
        }
        if ($tip eq "up") {
            $x = 50;
            $y = 20;
        }
        $graph->fill(30,50,$color);
        $graph->fill($x,$y,$color);
        if ($tip eq "dn") {
            $graph->fill(50,70,$color);
        }
        if ($tip eq "up") {
            $graph->fill(50,30,$color);
        }
    }

1;