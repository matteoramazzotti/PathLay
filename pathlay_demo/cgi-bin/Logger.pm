#!/usr/bin/perl
use 5.010;
use Data::Dumper qw(Dumper);
Logger() if not caller();
 
sub Logger {
	$proc = $_[0];
	$type = $_[1];

	if ($proc eq "runtime") {
		if ($type eq "log") {
			$start	= $_[3];
			$end	= $_[4];
			$diff	= $_[4]-$_[3];
			open(LOG,'>',"/var/www/html/pathlay/pathlay_logs/runtime/runtime_".$_[2].".log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/runtime/runtime_".$_[2].".log\n";
			print LOG $_[2]."\t".$start."\t".$end."\t".$diff."\n";
			close LOG;
		}
	}

	if ($proc eq "load_input") {
		if ($type eq "log") {
			open(LOG,'>',"/var/www/html/pathlay/pathlay_logs/load_input/load_input_sub.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/load_input/load_input_sub.log\n";
			print LOG "#	Form Data\n";
			print LOG Dumper \%{$_[2]};
			close LOG;
		}
	}
	
	if ($proc eq "exp_loader") {
		if ($type eq "log") {
			
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/exp_loader/exp_loader_sub_".@{$_[2]}[0].".log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/exp_loader/exp_loader_sub_".@{$_[2]}[0].".log\n";
			print LOG "# INPUT\n";
			print LOG "\$what 		= ".@{$_[2]}[0]."\n";
			print LOG "\$data		= ".@{$_[2]}[1]."\n";
			print LOG "\@index		= \n";
			print LOG Dumper \@{@{$_[2]}[2]};
			print LOG "\$idcol		= ".@{$_[2]}[3]."\n";
			print LOG "\$datacol	= ".@{$_[2]}[4]."\n";
			print LOG "\$datatype 	= ".@{$_[2]}[5]."\n";
			print LOG "\$datathr 	= ".@{$_[2]}[6]."\n";
			print LOG "\$datadir 	= ".@{$_[2]}[7]."\n";
			print LOG "\$pcol 		= ".@{$_[2]}[8]."\n";
			print LOG "\$pthr 		= ".@{$_[2]}[9]."\n";
			print LOG "\$fcrange 	= ".@{$_[2]}[10]."\n";
			print LOG "\$dbtype 	= ".@{$_[2]}[11]."\n";
			close LOG;

			open (LOG, '>',"/var/www/html/pathlay/pathlay_logs/exp_loader/exp_loader_sub_hash.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/exp_loader/exp_loader_sub_hash.log\n";
			print LOG "# HASH\n";
			print LOG "\%hash  		= \n";
			print LOG Dumper \%{@{$_[2]}[12]};
			close LOG;
		}
	}
	
	if ($proc eq "collapse") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/collapse/collapse_sub_hash.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/collapse/collapse_sub_hash.log\n";
			print LOG Dumper \%{@{$_[2]}[1]};
			close LOG;
		}
	}
	
	if ($proc eq "filter") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/filter/filter_sub_".@{$_[2]}[0].".log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/filter/filter_sub_".@{$_[2]}[0].".log\n";
			print LOG "# INPUT\n";
			print LOG "\$what 		= ".@{$_[2]}[0]."\n";
			print LOG "\@index		= \n";
			print LOG Dumper \@{@{$_[2]}[1]};
			print LOG "\%hash		= \n";
			print LOG Dumper \%{@{$_[2]}[2]};
			print LOG "\$idcol		= ".@{$_[2]}[3]."\n";
			print LOG "\$datacol	= ".@{$_[2]}[4]."\n";
			print LOG "\$datatype 	= ".@{$_[2]}[5]."\n";
			print LOG "\$datathr 	= ".@{$_[2]}[6]."\n";
			print LOG "\$datadir 	= ".@{$_[2]}[7]."\n";
			print LOG "\$pcol 		= ".@{$_[2]}[8]."\n";
			print LOG "\$pthr 		= ".@{$_[2]}[9]."\n";
			print LOG "\$fcrange 	= ".@{$_[2]}[10]."\n";
			print LOG "\$dbtype 	= ".@{$_[2]}[11]."\n";
			close LOG;
			
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/filter/filter_sub_hash.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/filter/filter_sub_hash.log\n";
			print LOG Dumper \%{@{$_[2]}[12]};
			close LOG;
		}
	}
	if ($proc eq "statistic") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/statistic/statistic_sub_input.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/statistic/statistic_sub_input.log\n";
			print LOG Dumper \%{@{$_[2]}[0]};
			close LOG;
			
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/statistic/statistic_sub_output.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/statistic/statistic_sub_output.log\n";
			print LOG Dumper \%{@{$_[2]}[1]};
			close LOG;
		}
	}
	
	if ($proc eq "meta_update") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/meta_update/meta_update_sub_input.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/meta_update/meta_update_sub_input.log\n";
			print LOG "\%exp	=\n";
			print LOG Dumper \%{@{$_[2]}[0]};
			print LOG "\%needed_maps	=\n";
			print LOG Dumper \%{@{$_[2]}[1]};
			close LOG;
			
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/meta_update/meta_update_sub_output.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/meta_update/meta_update_sub_output.log\n";
			print LOG "\%needed_maps	=\n";
			print LOG Dumper \%{@{$_[2]}[2]};
			close LOG;
		}
	}
	
	if ($proc eq "node_loader") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/node_loader/node_loader_sub_input.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/node_loader/node_loader_sub_input.log\n";
			print LOG Dumper \@{@{$_[2]}[0]};
			close LOG;
#			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/node_loader/node_loader_sub_output.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/node_loader/node_loader_sub_output.log\n";
#			print LOG Dumper \%{@{$_[2]}[1]};
#			close LOG;
		}
	}
	
	if ($proc eq "check") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/check/check_sub_input.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/check/check_sub_input.log\n";
			print LOG Dumper \%{@{$_[2]}[0]};
			print LOG Dumper \%{@{$_[2]}[1]};
			close LOG;
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/check/check_sub_output.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/check/check_sub_output.log\n";
			print LOG Dumper \%{@{$_[2]}[2]};
			close LOG;			
		}
	}
	
	if ($proc eq "build_complexes") {
		if ($type eq "log") {
			open (LOG,'>',"/var/www/html/pathlay/pathlay_logs/build_complexes/build_complexes_output.log") or die "Error: Cannot write /var/www/html/pathlay/pathlay_logs/build_complexes/build_complexes_output.log\n";
			print LOG Dumper \%{@{$_[2]}[0]};
			close LOG;
		}
	}
}
 
1;
