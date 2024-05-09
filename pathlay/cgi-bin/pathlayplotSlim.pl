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



my $params = decodeQuery();
# print STDERR Dumper $params;

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
my $mainIndicator;

if ($params -> {mainShape} eq "donut") {
  my @colorsToUse;
  foreach my $colorString (@{$params -> {mainColors}}) {
    my $color = 
      $colorString eq "mag" ? $magenta :
      $colorString eq "yel" ? $yellow :
      $blue;
    push(@colorsToUse,$color);
  }
  $mainIndicator = new Pin();
  $mainIndicator -> makeArc(
    Color => $black
  );
  $mainIndicator -> defineTip(
    Tip => $params -> {tip},
    Color => $black
  );
  $mainIndicator -> colorTip(
    Color => $colorsToUse[0],
  );
}

if ($params -> {mainShape} eq "pin") {
  my @colorsToUse;
  foreach my $colorString (@{$params -> {mainColors}}) {
    my $color = 
      $colorString eq "mag" ? $magenta :
      $colorString eq "yel" ? $yellow :
      $blue;
    push(@colorsToUse,$color);
  }
  $mainIndicator = new Pin();
  $mainIndicator -> makeArc(
    Color => $black
  );
  $mainIndicator -> defineTip(
    Tip => $params -> {tip},
    Color => $black
  );
  $mainIndicator -> colorTip(
    Color => $colorsToUse[0],
    Tip => $params -> {tip}
  );
}

if ($params -> {mainShape} eq "square") {
  my @colorsToUse;

  foreach my $colorString (@{$params -> {mainColors}}) {
    my $color = 
      $colorString eq "red" ? $red : 
      $colorString eq "cya" ? $cyan :
      $colorString eq "gry" ? $grey :
      $colorString eq "grn" ? $green :
      $colorString eq "mag" ? $magenta :
      $colorString eq "yel" ? $yellow :
      $blue;
    push(@colorsToUse,$color);
  }
  $mainIndicator = new Square();
  $mainIndicator -> defineShape();
  $mainIndicator -> colorBorder(
      Color => $black
  );
  $mainIndicator -> colorBody(
      Color => $colorsToUse[0]
  );

}

if ($params -> {mainShape} eq "circle") {

  my @colorsToUse;
  foreach my $colorString (@{$params -> {mainColors}}) {
    my $color = 
      $colorString eq "red" ? $red : 
      $colorString eq "cya" ? $cyan :
      $colorString eq "gry" ? $grey :
      $colorString eq "grn" ? $green :
      $colorString eq "mag" ? $magenta :
      $colorString eq "yel" ? $yellow :
      $blue;
    push(@colorsToUse,$color);
  }

  $mainIndicator = new Circle();
  $mainIndicator -> makeArc(
      Color => $black
  );

  if (scalar @{$params -> {mainColors}} == 1) {
    $mainIndicator -> colorArc(
      Color => $colorsToUse[0]
    );
  }

  if (scalar @{$params -> {mainColors}} == 2) {
    
    $mainIndicator -> splitInTwo(
      Position => $params -> {circleCut},
      Color => $black
    );
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

  if (scalar @{$params -> {mainColors}} == 3) {
    my $colorToX = {};
    my $colorToY = {};


    if ($params -> {circleCut} eq "equal") {
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

    if ($params -> {circleCut} eq "bot") {
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

    if ($params -> {circleCut} eq "top1") {
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

    if ($params -> {circleCut} eq "top2") {
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

  if (scalar @{$params -> {mainColors}} == 4) {
    my $colorToX = {};
    my $colorToY = {};
    $colorToX -> {0} = 35;
    $colorToY -> {0} = 25;
    $colorToX -> {1} = 65;
    $colorToY -> {1} = 25;
    $colorToX -> {2} = 35;
    $colorToY -> {2} = 70;
    $colorToX -> {3} = 65;
    $colorToY -> {3} = 70;

    $mainIndicator -> splitInFour(
      Color => $black
    );
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
    $mainIndicator -> colorArc(
      Color => $colorsToUse[3],
      x => $colorToX -> {3},
      y => $colorToY -> {3}
    );
  }

}

foreach my $side (("right","top", "bot")) {

    my @colorsToUse;
    my @xCoords;
    my @yCoords;
    my $centerXSingle = $side eq "right" ? 85 : $side eq "top" ? 50 : 50;
    my $centerYSingle = $side eq "right" ? 50 : $side eq "top" ? 15 : 80;
    my $centerXOne = $side eq "right" ? 80 : $side eq "top" ? 35 : 35;
    my $centerYOne = $side eq "right" ? 35 : $side eq "top" ? 15 : 80;
    my $centerXTwo = $side eq "right" ? 80 : $side eq "top" ? 65 : 65;
    my $centerYTwo = $side eq "right" ? 65 : $side eq "top" ? 15 : 80;
    my $centerXThree = $side eq "right" ? 80 : $side eq "top" ? 50 : 50;
    my $centerYThree = $side eq "right" ? 50 : $side eq "top" ? 15 : 80;
    my $distance = 20;
  if ($params -> {$side."Num"}) {


    if ($params -> {$side."Num"} == 1) {
      my ($xtmp,$ytmp) = smallSquareScaler(
        centerX => $centerXSingle,
        centerY => $centerYSingle,
        distance => $distance
      );
      push(@xCoords,@$xtmp);
      push(@yCoords,@$ytmp);
    }

    if ($params -> {$side."Num"} > 1) {
      
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

      if ($params -> {$side."Num"} == 3) {
        my ($xtmp,$ytmp) = smallSquareScaler(
          centerX => $centerXThree,
          centerY => $centerYThree,
          distance => $distance
        );
        push(@xCoords,@$xtmp);
        push(@yCoords,@$ytmp);
      }

    }


    foreach my $colorString (@{$params -> {$side."Colors"}}) {
      my $color = 
        $colorString eq "ora" ? $orange :
        $colorString eq "yel" ? $yellow :
        $blue;
      push(@colorsToUse,$color);
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
}

if ($params -> {leftNum}) {
  my @colorsToUse;
  foreach my $colorString (@{$params -> {leftColors}}) {
    my $color = 
      $colorString eq "ora" ? $orange :
      $colorString eq "yel" ? $yellow :
      $blue;
    push(@colorsToUse,$color);
  }

  if ($params -> {leftNum} == 1) {
    $graph->filledEllipse(20,35,20,20,$colorsToUse[0]);
    $graph->arc(20,35,20,20,0,360,$black);
  }
  if ($params -> {leftNum} > 1) {
    my @x = (17.5,17.5);
    my @y = (35,65);

    if (scalar(@colorsToUse) == 3) {
      push(@x,17.5);
      push(@y,50);
    }
    foreach my $cnt (0..$#x) {
      $graph->filledEllipse($x[$cnt],$y[$cnt],15,15,$colorsToUse[$cnt]);
      $graph->arc($x[$cnt],$y[$cnt],15,15,0,360,$black);
    }
  }
}


# if ($params -> {topNum}) {

#   my @colorsToUse;
#   my @xCoords;
#   my @yCoords;
#   my $centerXSingle = 50;
#   my $centerYSingle = 15;
#   my $centerXOne = 35;
#   my $centerYOne = 15;
#   my $centerXTwo = 65;
#   my $centerYTwo = 15;
#   my $centerXThree = 50;
#   my $centerYThree = 15;
#   my $distance = 20;

#   if ($params -> {topNum} == 1) {
#     my ($xtmp,$ytmp) = smallSquareScaler(
#       centerX => $centerXSingle,
#       centerY => $centerYSingle,
#       distance => $distance
#     );
#     push(@xCoords,@$xtmp);
#     push(@yCoords,@$ytmp);
#   }

#   if ($params -> {topNum} > 1) {
    
#     my ($xtmp,$ytmp) = smallSquareScaler(
#       centerX => $centerXOne,
#       centerY => $centerYOne,
#       distance => $distance
#     );
#     push(@xCoords,@$xtmp);
#     push(@yCoords,@$ytmp);

#     ($xtmp,$ytmp) = smallSquareScaler(
#       centerX => $centerXTwo,
#       centerY => $centerYTwo,
#       distance => $distance
#     );

#     push(@xCoords,@$xtmp);
#     push(@yCoords,@$ytmp);

#     if ($params -> {topNum} == 3) {
#       my ($xtmp,$ytmp) = smallSquareScaler(
#         centerX => $centerXThree,
#         centerY => $centerYThree,
#         distance => $distance
#       );
#       push(@xCoords,@$xtmp);
#       push(@yCoords,@$ytmp);
#     }

#   }


#   foreach my $colorString (@{$params -> {topColors}}) {
#     my $color = 
#       $colorString eq "ora" ? $orange :
#       $colorString eq "yel" ? $yellow :
#       $blue;
#     push(@colorsToUse,$color);
#   }

  
#   foreach my $i (0..$#xCoords) {
#     my $diamond = new GD::Polygon;
#     my $last = scalar(@{$xCoords[$i]}) - 1;
#     foreach my $c (0..$last) {
#       $diamond -> addPt($xCoords[$i][$c],$yCoords[$i][$c]);
#     }
#     $graph -> filledPolygon($diamond,$colorsToUse[$i]);
#     $graph -> setThickness(1);
#     $graph -> openPolygon($diamond,$black);
#   }
# }


Draw(
    Graph => $graph
);

sub decodeQuery{
  my $cgi=new CGI;
  my $params = {};
  foreach my $key (sort keys %{$cgi -> {param}}) {
    if ($key =~ /Colors/) {
      @{$params -> {$key}} = split(/\|/,${$cgi -> {param} -> {$key}}[0]);
    } else {
      $params -> {$key} = ${$cgi -> {param} -> {$key}}[0];
    }
  }
  return($params);
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
sub smallSquareScaler {
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