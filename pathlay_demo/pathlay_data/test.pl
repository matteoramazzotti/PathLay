my $scores = {};
my $dirchecks = {};
my $parameters = {};
opendir(DIR,"../pathlay_data/");
foreach my $organism_dir (readdir(DIR)) {
   	next if (!-d $organism_dir || $organism_dir eq ".." || $organism_dir eq ".");
    print STDERR $organism_dir;
	$dirchecks -> {$organism_dir} = {
		maps_dir_ok => 0,
		maps_kegg_dir_ok => 0,
		maps_wikipathways_dir_ok => 0,
		db_dir_ok => 0,
		db_kegg_dir_ok => 0,
		db_wikipathways_dir_ok => 0,
			
	};
	$scores -> {$organism_dir} = 0;
	
    $dirchecks -> {$organism_dir} -> {maps_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps");
    $dirchecks -> {$organism_dir} -> {maps_kegg_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps/kegg");
    $dirchecks -> {$organism_dir} -> {maps_wikipathways_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/maps/wikipathways");
    $dirchecks -> {$organism_dir} -> {db_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db");
    $dirchecks -> {$organism_dir} -> {db_kegg_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db/kegg");
    $dirchecks -> {$organism_dir} -> {db_wikipathways_dir_ok} = 1 if (-d "../pathlay_data/$organism_dir/db/wikipathways");
        
    foreach my $key (sort keys %{$dirchecks -> {$organism_dir}}) {
       	print STDERR "\t".$key."\t".$dirchecks -> {$organism_dir} -> {$key};
       	$scores -> {$organism_dir}++ if ($dirchecks -> {$organism_dir} -> {$key} == 1);
    }
    print STDERR "\n";
    if ($scores -> {$organism_dir} == (scalar keys %{$dirchecks -> {$organism_dir}})) {
       	$parameters -> {_organisms_available} -> {$organism_dir} = 1;
    }
}
closedir(DIR);
print STDERR "Organisms available:";
foreach my $key (sort keys %{$parameters -> {_organisms_available}}) {
  	print STDERR " $key";
}
