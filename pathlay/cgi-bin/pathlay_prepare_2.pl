use strict;
use warnings;
use lib '/var/www/html/pathlay_2/cgi-bin/';
use XMLUtils;

my $idir = "/var/www/html/pathlay_2/pathlay_data/KEGG/hsa/maps/";
my $ext  = "kgml";
opendir(DIR,$idir);
if ( $ext eq "kgml" ) {
    foreach my $file (sort readdir(DIR)) {
        next if ($file !~ /$ext$/);
        print STDERR $file."\n";
        my $kgml = new KGML();
        $kgml -> Loader(
            _file => "$idir"."$file"
        );
        $kgml -> GetPathway();
        $kgml -> GetEntries();
        $kgml -> Printer();
    }
}
closedir(DIR);
