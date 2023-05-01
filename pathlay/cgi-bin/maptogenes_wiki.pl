#!/bin/perl
use Data::Dumper qw(Dumper);
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use File::Basename;
use List::Util qw( min max );

GetOptions (
    'input|i=s' => \$input, ##file list or directory to input
    'entrez|e' => \$entrezonly ##filters entrezs
);

if ($input) {
    print "$input\n";
} else {
    print "No input!\n\t Usage:\tperl parse_wikipath.pl -i \"path/to/wikipath/file.nodes\"\n\tperl parse_wikipath.pl -i directory/with/wikipath/file.nodes\n";
}

if (-f $input) {
    push @inputs, $input;
    $outdir = dirname($input);
}
if (-d $input) {
    if ($input !~ m/\/$/) {$input =~ s/$/\//};
    $outdir = $input;
    opendir (DIR, $input);
    foreach $file (readdir(DIR)) {
        if ($file eq "." ||
                $file eq ".." ||
                $file !~ /.nodes/ 
            ) {next}
            print STDERR "$input$file\n"; 
        push @inputs, "$input$file";
    }
    closedir DIR;
}

foreach $input (@inputs) {
    open (IN,$input);
    print STDERR "$input\n";
    chomp(@nodes = <IN>);
    close IN;
    print "$input\n";
    shift @nodes;
    @pathwaydata = split '\t', $nodes[0]; 
    $pathid = $pathwaydata[3];
#    print "$pathid\n";
    $pathname = $pathwaydata[0];
#    print "$pathname\n";
    $pathnames{$pathid} = $pathname;
    shift @nodes;
    foreach $line (@nodes) {
        my @tmp = split '\t', $line;
        $genename = @tmp[0];
        $genedb = @tmp[2];
        $genetype = @tmp[1];
        @tmp[3] =~ s/ //;
        $geneid = @tmp[3];
        next if ($entrezonly && $genedb !~ "Entrez Gene");
        print "$genedb\n";
        $genenames{$geneid} = $genename;
        push @{$pathtogenes{$pathid}}, $geneid;
    }
}

#print Dumper \%pathtogenes;

open (OUT, '>', "$outdir"."hsa.gmt");

foreach $key (sort keys %pathtogenes) {
    print OUT "$key\t".$pathnames{$key};
    foreach $item (@{$pathtogenes{$key}}) {
        print OUT "\t$item";
    }
    print OUT "\n";
}

close OUT;




