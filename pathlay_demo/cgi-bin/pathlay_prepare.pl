use Getopt::Long qw(GetOptions);
use File::Basename;
use List::Util qw( min max );
use List::MoreUtils qw(uniq);

GetOptions (
    'input|i=s' => \$input, ##project list to input
    'output|o=s' => \$outf, ##folder to output .nodes
    'extension|e=s' => \$ext, ##file extension: gpml or kgml
) or die "No input!\n\t Usage:\tperl parse_kegg_kgml.pl -i \"path/to/kegg/file.kgml\"\n\tperl parse_kegg_kgml.pl -i directory/with/kegg/file.kgml";

if (-f $input) {
    push @inputs, $input;
    $outdir = dirname($outf);
}
if (-d $input) {
    if ($input !~ m/\/$/) {$input =~ s/$/\//};
    $outdir = ($outf);
    opendir (DIR, $input);
    foreach $file (readdir(DIR)) {
        if ($file eq "." ||
                $file eq ".." ||
                $file !~ /.$ext/
            ) {next}
        push @inputs, "$input$file";
    }
    closedir DIR;
}

load_src();
foreach $input (@inputs) {
  start($ext,$input);
  if ($ext eq "gpml") {
    parse_gpml(\@file);
  }
  if ($ext eq "kgml") {
    parse_kgml(\@file);
  }
  print_out($ext,$input);
}

sub start {

  $i = 0;
  $c = 0;
  $d = 0;
  $e = 0;
  $f = 0;

  our $catch = 0;

  our %ids;
  our %types;
  our %xcoords;
  our %ycoords;
  our @ids;

  if ($_[0] eq "gpml") {
    our @labels;
    our @ids;
    our @tmp;
    our %databases;
  }


  if ($_[0] eq "kgml") {
    our %dbs;
  }
  print $_[1]."\n";
  open(IN,$_[1]);
  chomp(our @file = <IN>);
  close IN;
}

sub parse_kgml{
  @file = @{$_[0]};
  foreach $line (@file) {
      chomp $line;
      if ($line =~ /<\/entry>/) {
          $catch = 0;
          next
      }
      if ($line =~ /<pathway name=\"path:(.+?)\" org=\"(.+?)\" number=\".+?\"/) {
          $path_id = $1;
          $path_org = $2;
          next
      }
      if ($line =~ /title=\"(.+?)\"/) {
          $path_name = $1;
      }
      if ($line =~ /image=\"(.+?)\"/) {
          $png_link = $1;
      }
      if ($line =~ /<entry id=\".+?\" name=\"(.+?)\" type=\"(.+?)\"/) {
          $tmp1 = $1;
          $tmp2 = $2;
          next if ($tmp2 !~ "gene" && $tmp2 !~ "compound");
          if ($tmp2 =~ "gene") {
              $type = "GeneProduct";
              $db = "Entrez Gene";
              $id = $tmp1;
              $id =~ s/$path_org://g;
              @ids = split /\s/,$id;
          }
          if ($tmp2 =~ "compound") {
              $type = "Metabolite";
              $db = "KEGG Compound";
              $id = $tmp1;
              $id =~ s/cpd://g;
              @ids = split /\s/,$id;
          }
          foreach $k (@ids) {
              $ids{$k} = 1;
              $types{$k} = $type;
              $dbs{$k} = $db;
              push @entrezs, $k;
          }
          $catch = 1;
          next
      }
      if ($catch == 1) {
          if (
                  $line =~ /type=\"rectangle\" x=\".+?\" y=\".+?\" width=\".+?\" height=\".+?\"\/>/ ||
                  $line =~ /type=\"circle\" x=\".+?\" y=\".+?\" width=\".+?\" height=\".+?\"\/>/ ||
                  $line =~ /<graphics name=\".+?\" fgcolor=\".+?\" bgcolor=\".+?\" type=\".+?\" coords=\".+?\"\/>/ ||
                  $line =~ /type=\".+?\" coords=\"(.+?)\"\/>/
              ) {
              if ($line =~ /type=\"rectangle\" x=\"(.+?)\" y=\"(.+?)\" width=\"(.+?)\" height=\"(.+?)\"\/>/ ||
                  $line =~ /type=\"circle\" x=\"(.+?)\" y=\"(.+?)\" width=\".+?\" height=\".+?\"\/>/) {
                  if (scalar @ids > 1) {
                      foreach $id (@ids) {
                        push @{$xcoords{$id}} , $1;
                        push @{$ycoords{$id}} , $2;
                      }
                  } else {
                      push @{$xcoords{$ids[0]}} , $1;
                      push @{$ycoords{$ids[0]}} , $2;
                  }
                  next;
              }

              if (   $line =~ /<graphics name=\".+?\" fgcolor=\".+?\" bgcolor=\".+?\" type=\".+?\" coords=\"(.+?)\"\/>/ ||
                          $line =~ /type=\".+?\" coords=\"(.+?)\"\/>/) {
                  @coords = split /,/, $1;
                  $x1 = $coords[0];
                  $y1 = $coords[1];
                  $x2 = $coords[2];
                  $y2 = $coords[3];

                  $x = ($x2 + $x1)/2;
                  $y = ($y2 + $y1)/2;

                  if (scalar @ids > 1) {
                      foreach $id (@ids) {
                          push @{$xcoords{$id}} , $x;
                        push @{$ycoords{$id}} , $y;
                      }
                  } else {
                      push @{$xcoords{$ids[0]}} , $x;
                      push @{$ycoords{$ids[0]}} , $y;
                  }
                  next
              }
          }
      }
  }
  @tmp = uniq @entrezs;
  @entrezs = @tmp;
}

sub parse_gpml{
  my @file = @{$_[0]};
  if ($input =~ /(WP.+)_/ || $input =~ /(WP.+)\./) {
      $pathid = $1;
  }

  foreach $line (@file) {

      $line =~ s/&#xA;/ /;
      $line =~ s/&#10;/ /;
      if ($line =~ /<Pathway.+?Name="(.+?)".+Version=".+".+Organism="(.+?)"/ || $line =~ /<Pathway.+?xmlns=".+?" Name="(.+?)".+Organism="(.+?)">/) {
          $pathname = $1;
          $pathorga = $2;
      }

      if ($line =~ "<DataNode") {
          $c++;
          $catch = 1;
          if ($line =~ /TextLabel="(.+?)"/) {
              $label = $1;
              push @labels, $1;
              push @tmp,$1; #0
              $i++;
          }
          if ($line =~ /Type="(.+?)"/) {
              $type = $1;
              push @tmp,$type; #1
              $f++;
          }
          next;
      }
      if ($line =~ "</DataNode>") {
          $catch = 0;
          $names{$tmp[5]}  = $tmp[0];
          $types{$tmp[5]}   = $tmp[1];
          push @{$xcoords{$tmp[5]}} , $tmp[2];
          push @{$ycoords{$tmp[5]}} , $tmp[3];
          @uniqs = uniq @{$xcoords{$tmp[5]}};
          @{$xcoords{$tmp[5]}} = @uniqs;
          @uniqs = uniq @{$ycoords{$tmp[5]}};
          @{$ycoords{$tmp[5]}} = @uniqs;
          $databases{$tmp[5]} = $tmp[4];
          @tmp = ();
      }
      if ($catch == 1) {
          if ($line =~ /<Graphics CenterX="(.+?)" CenterY="(.+?)".*>/) {
              push @tmp, $1; #2
              push @tmp, $2; #3
              $d++;
          }
          if ($line =~ /<Xref Database="(.+?)" ID="(.+?)".*>/) {
              push @ids,$2;
              push @tmp,$1; #4
              push @tmp,$2; #5
              $e++;
          }
      }
  }
}

sub load_src{
  open IN, "./src/entrez2symbol";
  chomp( @array = <IN> );
  close IN;
  shift @array;
  foreach $line (@array) {
      @tmp = split /\t/, $line;
      $id = @tmp[0];
      $names{$id} = @tmp[1];
  }

  open IN, "kegg2chebi_compounds.list";
  chomp( @array = <IN>);
  close IN;
  foreach $line (@array) {
    @tmp = split /\t/, $line;
    $id = @tmp[0];
    $id =~ s/cpd://;
		@chebis = split /\;/, @tmp[2];
	  foreach $chebi (@chebis) {
	     $ids{"CHEBI:".$chebi} = $id;
			 $databases{"CHEBI:".$chebi} = "KEGG Compound";
    }
    $ids{$id} = $id;
    @names = split /;/,@tmp[1];
    $names{$id} = @names[0];
  }

}

sub print_out{

  $output = $outf.basename($_[1]);
  $output =~ s/.$_[0]$/.nodes/;
  open(OUT,">",$output);
  if ($_[0] eq "kgml") {
    print OUT "TEXT\tTYPE\tDB\tID\tX\tY\n";
    print OUT "$path_name\t$path_org\tKEGG\t$path_id\n";
    foreach $id (sort keys %ids) {
        print OUT $names{$id}."\t".$types{$id}."\t".$dbs{$id}."\t".$id;
        $y = 0;
        foreach $xcoord (@{$xcoords{$id}}) {
          print OUT "\t".$xcoord.",".@{$ycoords{$id}}[$y];
          $y++;
        }
        print OUT "\n";
    }
  }
  if ($_[0] eq "gpml") {
    print OUT "TEXT\tTYPE\tDB\tID\tX\tY\n";
    print OUT "$pathname\t$pathorga\tWikiPathways\t$pathid\n";
    @tmp = uniq @ids;
    @ids = @tmp;
    foreach $id (@ids) {
      next if (
        $databases{$id} ne "KEGG Compound" &&
        $databases{$id} ne "ChEBI" &&
        $databases{$id} ne "Entrez Gene"
      );
      print OUT $names{$id}."\t".$types{$id}."\t".$databases{$id}."\t".$ids{$id};
      $y = 0;
      foreach $xcoord (@{$xcoords{$id}}) {
        print OUT "\t".$xcoord.",".@{$ycoords{$id}}[$y];
        $y++;
      }
      print OUT "\n";
   }
  }
  close(OUT);
}
