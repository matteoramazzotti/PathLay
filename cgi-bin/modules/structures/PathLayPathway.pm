use strict;
use warnings;

package Pathway;

	our @ISA = qw(Complex);
	sub new {
		my $class = shift;
		my $self = {
			_source => "undef",
			_organism => "undef",
			_name => "undef",
			_id => "undef",
			_db => "undef",
			_data => {},
			@_
		};
		my $debug = 0;
		print STDERR $self -> {_source}."\n" if ($debug);
		bless $self, $class;
		return($self);
	}
	sub NodesInit { #this should be in parallel in PathwayLoader since _nodes is created here

		my $self = shift;
		#my %check_for_mix;

		($self,my $check_for_mix) = CreateSingleNodes(
			Self => $self
		);

		($self) = CreateMultiNodes (
			Self => $self,
			Mix => $check_for_mix
		);

		sub CreateSingleNodes {

			my %args = (
				@_
			);

			my $self = $args{Self};
			my %check_for_mix;
			foreach my $id (sort keys %{$self -> {_data}}) {

				if ($self -> {_data} -> {$id} -> {type} eq "deg+prot") {
					foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
						$self -> {_nodes} -> {deg} -> {$_} -> {$id} = 1;
						$self -> {_nodes} -> {prot} -> {$_} -> {$id} = 1;
						${$check_for_mix{$_}}{deg} = 1;
						${$check_for_mix{$_}}{prot} = 1;
					}
				}

				if ($self -> {_data} -> {$id} -> {type} eq "deg") {
					foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
						$self -> {_nodes} -> {deg} -> {$_} -> {$id} = 1;
						${$check_for_mix{$_}}{deg} = 1;
					}
				}
				if ($self -> {_data} -> {$id} -> {type} eq "nodeg") {
					foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
						$self -> {_nodes} -> {nodeg} -> {$_} -> {$id} = 1;
						${$check_for_mix{$_}}{nodeg} = 1;
					}
				}
				if ($self -> {_data} -> {$id} -> {type} eq "meta") {
					foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
						$self -> {_nodes} -> {meta} -> {$_} -> {$id} = 1;
					}
				}
				if ($self -> {_data} -> {$id} -> {type} eq "prot") {
					foreach (sort @{$self -> {_data} -> {$id} -> {coordinates}}) {
						$self -> {_nodes} -> {prot} -> {$_} -> {$id} = 1;
						${$check_for_mix{$_}}{prot} = 1;
					}
				}
			}
			return($self,\%check_for_mix);
		}

		sub CreateMultiNodes {

			my %args = (
				@_
			);

			my $self = $args{Self};
			my $hash_ref = $args{Mix};
			my %check_for_mix = %$hash_ref;

			foreach my $coord (sort keys %check_for_mix) {
				if (${$check_for_mix{$coord}}{nodeg} && ${$check_for_mix{$coord}}{deg}) { #this should also handle proteins

					#print STDERR "check for mix: mixing at $coord:\n";
					#print STDERR "check for mix: deg:\n";
					foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
						$self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
						$self -> {_multi_available} -> {$deg} = 1;
						#print STDERR "\t$deg";
					}
					#print STDERR "\n";
					#print STDERR "check for mix: nodeg:\n";
					foreach my $nodeg (sort keys %{$self -> {_nodes} -> {nodeg} -> {$coord}}) {
						$self -> {_nodes} -> {multi} -> {$coord} -> {$nodeg} = 1;
						$self -> {_multi_available} -> {$nodeg} = 1;
						#print STDERR "\t$nodeg";
					}
					#print STDERR "\n";
				}

				##test
				if (${$check_for_mix{$coord}}{nodeg} && ${$check_for_mix{$coord}}{prot}) {

					#print STDERR "check for mix: mixing at $coord:\n";
					#print STDERR "check for mix: prot:\n";
					foreach my $prot (sort keys %{$self -> {_nodes} -> {prot} -> {$coord}}) {
						$self -> {_nodes} -> {multi} -> {$coord} -> {$prot} = 1;
						$self -> {_multi_available} -> {$prot} = 1;
						# print STDERR "\t$prot";
						# print STDERR "\n";
						print STDERR "check for mix: nodeg:\n";
						foreach my $nodeg (sort keys %{$self -> {_nodes} -> {nodeg} -> {$coord}}) {
							$self -> {_nodes} -> {multi} -> {$coord} -> {$nodeg} = 1;
							$self -> {_multi_available} -> {$nodeg} = 1;
							print STDERR "\t$nodeg";
						}
						print STDERR "\n";
					}
				}

				if (${$check_for_mix{$coord}}{deg} && ${$check_for_mix{$coord}}{prot}) {

					#print STDERR "check for mix: mixing at $coord:\n";
					#print STDERR "check for mix: prot:\n";
					foreach my $prot (sort keys %{$self -> {_nodes} -> {prot} -> {$coord}}) {
						$self -> {_nodes} -> {multi} -> {$coord} -> {$prot} = 1;
						$self -> {_multi_available} -> {$prot} = 1;
						#print STDERR "\t$prot";
						#print STDERR "\n";
						#print STDERR "check for mix: deg:\n";
						foreach my $deg (sort keys %{$self -> {_nodes} -> {deg} -> {$coord}}) {
							$self -> {_nodes} -> {multi} -> {$coord} -> {$deg} = 1;
							$self -> {_multi_available} -> {$deg} = 1;
							# print STDERR "\t$deg";
						}
						#print STDERR "\n";
					}
				}

				###
			}

			return($self);
		}
	}
	sub PrintComplexes {

		my $self = shift;

		my %args = (
			Type => "all",
			@_
		);
		my $type_to_print = $args{Type};
		foreach my $type ( keys %{$self -> {_complexes}}) {
			#print STDERR "$type\n";
			next if ($type ne "all" && $type ne $type_to_print);
			foreach my $complex (sort @{$self -> {_complexes} -> {$type}}) {
				$complex -> ComplexPrinter();
			}
		}
	}
	sub LoadComplexes {

		my $self = shift;
		my %args = (
			@_
		);

		my $count = 1;
		my $parameters = $args{Parameters};

		#multi must be handled first due to not generate indicator duplicates

		foreach my $type (("multi","deg","prot","nodeg","meta")) {
			if (!$self -> {_complexes} -> {$type}) {
				@{$self -> {_complexes} -> {$type}} = ();
			}
			foreach my $coord (sort keys %{$self -> {_nodes} -> {$type}}) {
				my $complex = new Complex(
					_id => $self -> {_id}."_$count",
					_coordinates => $coord,
					_type => $type,
					_index => $self -> {_index}
				);
				$complex -> CheckOffSetAndTrim(
					Nodes => $self -> {_nodes},
					Type => $type,
					Coord => $coord
				);
				$complex -> InitLegends(
					MapName => $self -> {_name},
					Parameters => $parameters
				);
				$complex -> ComplexLoader(
					_ids => $self -> {_nodes} -> {$type} -> {$coord},
					_data => $self -> {_data},
					_nodes => $self -> {_nodes},
					_multi_available => $self -> {_multi_available},
					#_mode => $parameters -> {_mode_select}
				);
				next if ($complex -> {_purge});
				
				push(@{$self -> {_complexes} -> {$type}},$complex);
				# if ($type eq "prot") {
				# 	push (@prot_complexes,$complex);
				# } elsif ($type eq "deg") {
				# 	push (@deg_complexes,$complex);
				# } elsif ($type eq "nodeg") {
				# 	push (@nodeg_complexes,$complex);
				# } elsif ($type eq "meta") {
				# 	push (@meta_complexes,$complex);
				# }
				$count++;
			}
		}
	}
	sub PathwayPrinter {
		my $self = shift;

		print STDERR $self -> {_id}."|".$self -> {_name}."|".$self -> {_organism}."|".$self -> {_db}."\n";
		foreach my $node_id (sort keys %{$self -> {_data}}) {
			print STDERR " ".$node_id." ".
			$self -> {_data} -> {$node_id} -> {name}." ".
			$self -> {_data} -> {$node_id} -> {type};
			if ($self -> {_data} -> {$node_id} -> {dev}) {
				print STDERR " DEV:".$self -> {_data} -> {$node_id} -> {dev};
			}
			if ($self -> {_data} -> {$node_id} -> {meth}) {
				print STDERR " Meth:".$self -> {_data} -> {$node_id} -> {meth};
			}
			foreach (sort @{$self -> {_data} -> {$node_id} -> {coordinates}}) {
				print STDERR " ".$_;
			}
			print STDERR "\n";
			if ($self -> {_data} -> {$node_id} -> {urnas}) {
				foreach my $urna (sort keys %{$self -> {_data} -> {$node_id} -> {urnas}}) {
					# print STDERR "\t".$urna;
				}
				print STDERR "\n";
			}
		}
		print STDERR "\n";
	}
	sub PathwayLoader {
		use Data::Dumper;
		my $seen = {
			deg => {},
			nodeg => {},
			prot => {},
			urna => {},
			meth => {},
			meta => {},
			chroma => {},
			tf => {}
		};

		local *checkByType = sub {
			my %args = (
				NodeId  => {},
				Pathway  => {},
				ExpToCheck => {},
				DataType => "",
				@_
			);
			my $nodeId = $args{NodeId};
			my $pathway = $args{Pathway};
			my $expPack = $args{ExpToCheck};
			my $dataType = $args{DataType};

			$pathway -> {_data} -> {$nodeId} -> {type} = $dataType;
			$seen -> {$dataType} -> {$nodeId}++;
			# print STDERR "Checking by type $nodeId\n";
			if ($expPack -> {_data} -> {$nodeId} -> {_prot_id}) {

				$pathway -> {_data} -> {$nodeId} -> {prot_id} = $expPack -> {_data} -> {$nodeId} -> {_prot_id};
				$pathway -> {_data} -> {$nodeId} -> {prot_name} =  $expPack -> {_data} -> {$nodeId} -> {_prot_name};
			}
			if ($expPack -> {_data} -> {$nodeId} -> {dev}) {
				$pathway -> {_data} -> {$nodeId} -> {dev} = $expPack -> {_data} -> {$nodeId} -> {dev};
			}
			if ($expPack -> {_data} -> {$nodeId} -> {urnas}) {
				%{$pathway -> {_data} -> {$nodeId} -> {urnas}} = %{$expPack -> {_data} -> {$nodeId} -> {urnas}}; #this includes mirt
				foreach (keys %{$pathway -> {_data} -> {$nodeId} -> {urnas}}) {
					$seen -> {urna} -> {$nodeId}++;
				}
			}
			if ($expPack -> {_data} -> {$nodeId} -> {meth}) {
				$pathway -> {_data} -> {$nodeId} -> {meth} = $expPack -> {_data} -> {$nodeId} -> {meth};
				$seen -> {meth} -> {$nodeId}++;
			}
			if ($expPack -> {_data} -> {$nodeId} -> {chroma}) {
				$pathway -> {_data} -> {$nodeId} -> {chroma} = $expPack -> {_data} -> {$nodeId} -> {chroma};
				$seen -> {chroma} -> {$nodeId}++;
			}
			if ($expPack -> {_data} -> {$nodeId} -> {tfs}) {
				foreach my $tf_id (sort keys %{$expPack -> {_data} -> {$nodeId} -> {tfs}}) {
					$pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev} = $expPack -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev};
					$pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name} = $expPack -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name};
					$seen -> {tf} -> {$nodeId}++;
				}
			}
		};
		local *checkDegProt = sub {
			my %args = (
				NodeId  => {},
				Pathway  => {},
				ExpToCheckGene => {},
				ExpToCheckProt => {},
				@_
			);
			my $nodeId = $args{NodeId};
			my $pathway = $args{Pathway};
			my $expPackProt = $args{ExpToCheckProt};
			my $expPackGene = $args{ExpToCheckGene};
			my $dataType = $args{DataType};

			$seen -> {deg} -> {$nodeId}++;
			$seen -> {prot} -> {$nodeId}++;
			$pathway -> {_data} -> {$nodeId} -> {type} = "deg+prot";
			$pathway -> {_data} -> {$nodeId} -> {dev_prot} = $expPackProt -> {_data} -> {$nodeId} -> {dev};
			$pathway -> {_data} -> {$nodeId} -> {prot_id} =  $expPackProt -> {_data} -> {$nodeId} -> {_prot_id};
			$pathway -> {_data} -> {$nodeId} -> {prot_name} =  $expPackProt -> {_data} -> {$nodeId} -> {_prot_name};
			$pathway -> {_data} -> {$nodeId} -> {dev_gene} = $expPackGene -> {_data} -> {$nodeId} -> {dev};
			if ($expPackGene -> {_data} -> {$nodeId} -> {urnas}) {
				%{$pathway -> {_data} -> {$nodeId} -> {urnas}} = %{$expPackGene -> {_data} -> {$nodeId} -> {urnas}}; #this includes mirt
				foreach (keys %{$pathway -> {_data} -> {$nodeId} -> {urnas}}) {
					$seen -> {urna} -> {$nodeId}++;
				}
			}
			if ($expPackGene -> {_data} -> {$nodeId} -> {meth}) {
				$pathway -> {_data} -> {$nodeId} -> {meth} = $expPackGene -> {_data} -> {$nodeId} -> {meth};
				$seen -> {meth} -> {$nodeId}++;
			}
			if ($expPackGene -> {_data} -> {$nodeId} -> {chroma}) {
				$pathway -> {_data} -> {$nodeId} -> {chroma} = $expPackGene -> {_data} -> {$nodeId} -> {chroma};
				$seen -> {chroma} -> {$nodeId}++;
			}
			if ($expPackGene -> {_data} -> {$nodeId} -> {tfs}) {
				foreach my $tf_id (sort keys %{$expPackGene -> {_data} -> {$nodeId} -> {tfs}}) {
					$pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev} = $expPackGene -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {dev};
					$pathway -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name} = $expPackGene -> {_data} -> {$nodeId} -> {tfs} -> {$tf_id} -> {name};
					$seen -> {tf} -> {$nodeId}++;
				}
			}
		};

		my $self = shift;
		my %args = (
			ExpPackages => {},
			Params => {},
			@_
		);

		my $parameters = $args{Params};
		my $debug = 0;
		
		my $expPacks = $args{ExpPackages};

		open(IN,$self -> {_source});
		chomp(my @nodes = <IN>);
		close(IN);
		shift @nodes;
		($self -> {_name},$self -> {_organism},$self -> {_db},$self -> {_id}) = split(/\t/,shift(@nodes));


		foreach (sort @nodes) {
			my ($node_name,$node_type,$node_db,$node_id,@coords) = split(/\t/,$_);
			# print STDERR "Checking $node_id\n";
			next if (
				!$expPacks -> {deg} -> {_data} -> {$node_id} &&
				!$expPacks -> {nodeg} -> {_data} -> {$node_id} &&
				!$expPacks -> {meta} -> {_data} -> {$node_id} &&
				!$expPacks -> {prot} -> {_data} -> {$node_id}
			);
			# print STDERR "$node_id Passed\n";


			$self -> {_data} -> {$node_id} -> {name} = $node_name;
			$self -> {_data} -> {$node_id} -> {db} = $node_db; #useless

			if ($expPacks -> {deg} -> {_data} -> {$node_id} && $expPacks -> {prot} -> {_data} -> {$node_id}) {
				checkDegProt(
					ExpToCheckGene => $expPacks -> {deg},
					ExpToCheckProt => $expPacks -> {prot},
					Pathway => $self,
					NodeId => $node_id
				);
			} else {
				foreach my $type (("deg","prot","meta","nodeg")) {
					if ($expPacks -> {$type} -> {_data} -> {$node_id}) {
						checkByType(
							ExpToCheck => $expPacks -> {$type},
							DataType => $type,
							NodeId => $node_id,
							Pathway => $self
						);
					}
				}
			}
			
			@{$self -> {_data} -> {$node_id} -> {coordinates}} = @coords;
			print STDERR "FOUND $node_id id at ".$self -> {_id}."\n" if ($debug);
		}
		$self -> {_degs_loaded} = scalar keys %{$seen -> {deg}};
		$self -> {_nodegs_loaded} = scalar keys %{$seen -> {nodeg}};
		$self -> {_urnas_loaded} = scalar keys %{$seen -> {urna}};
		$self -> {_metas_loaded} = scalar keys %{$seen -> {meta}};
		$self -> {_methyls_loaded} = scalar keys %{$seen -> {meth}};
		$self -> {_proteins_loaded} = scalar keys %{$seen -> {prot}};
		$self -> {_chroma_loaded} = scalar keys %{$seen -> {chroma}};

	}
	sub PathwayEncoder {
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
							#$switches -> {_totalUp}++;
							if ($currentType eq "meta") {
								$switches -> {_components} -> {_main} -> {_pink} = {};
							}
							if ($currentType eq "deg" || $currentType eq "prot") {
								$switches -> {_totalUp}++;
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
			$switches -> {_idOnlyTFs} = $switches -> {_totalTfs} - ($switches -> {_tfUp} + $switches -> {_tfDn});
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
			if ($switches -> {_idOnlyTFs} > 0) {
				$switches -> {_components} -> {_right} -> {_orange} = {};
			}
			if ($switches -> {_idOnlyMetas} > 0) {
				$switches -> {_components} -> {_main} -> {_yellow} = {};
			}

			return($info,$switches); #returning info is useless
		}
		sub encodeShape {
			my $switches = shift(@_);
			my $code = shift(@_);
			my @keysToCheck = ();
			my @colorsToUse = ();
			if ($switches -> {_components} -> {_main} -> {_red}) {
				push(@keysToCheck,'_totalUp');
				push(@colorsToUse,"red");
			}
			if ($switches -> {_components} -> {_main} -> {_cyan}) {
				push(@keysToCheck,'_idOnly');
				push(@colorsToUse,"cya");
			}
			if ($switches -> {_components} -> {_main} -> {_grey}) {
				push(@keysToCheck,'_totalNo');
				push(@colorsToUse,"gry");
			}
			if ($switches -> {_components} -> {_main} -> {_green}) {
				push(@keysToCheck,'_totalDn');
				push(@colorsToUse,"grn");
			}
			if ($switches -> {_components} -> {_main} -> {_pink}) {
				push(@colorsToUse,"mag");
			}
			if ($switches -> {_components} -> {_main} -> {_purple}) {
				push(@colorsToUse,"blu");
			}
			if ($switches -> {_components} -> {_main} -> {_yellow}) {
				push(@colorsToUse,"yel");
			}
			my $colorsNumber = scalar(keys(%{$switches -> {_components} -> {_main}}));
			if ($switches -> {_totalMains} == 1) {
				#square
				# just need color
				$code -> {mainShape} = "square";
				$code -> {mainColors} = join("|",@colorsToUse);
			}
			if ($switches -> {_totalMains} > 1) {
				$code -> {mainShape} = "circle";

				if ($colorsNumber == 1) {
					$code -> {circleCut} = "none";
					$code -> {mainColors} = join("|",@colorsToUse);

				}
				if ($colorsNumber == 2) {
					if ($switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]}) {
						$code -> {circleCut} = "half";
					}
					if ($switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[1]}) {
						$code -> {circleCut} = "lower";
					}
					if ($switches -> {$keysToCheck[0]} < $switches -> {$keysToCheck[1]}) {
						$code -> {circleCut} = "higher";
					}
					$code -> {mainColors} = join("|",@colorsToUse);
				}
				if ($colorsNumber == 3) {
					if (
						$switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]} &&
						$switches -> {$keysToCheck[1]} == $switches -> {$keysToCheck[2]}
					) {
						$code -> {circleCut} = "equal";
					}

					if (
						(
							$switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[1]} &&
							$switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[2]}
						) ||
						(
							$switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[1]} &&
							$switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[2]}
						) ||
						(
							$switches -> {$keysToCheck[0]} == $switches -> {$keysToCheck[2]} &&
							$switches -> {$keysToCheck[0]} > $switches -> {$keysToCheck[1]}
						)
					) {
						$code -> {circleCut} = "bot";
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
						$code -> {circleCut} = "top1";
					}

					if (
						$switches -> {$keysToCheck[1]} > $switches -> {$keysToCheck[2]} &&
						$switches -> {$keysToCheck[1]} > $switches -> {$keysToCheck[0]}
					) {
						$code -> {circleCut} = "top2";
					}




					$code -> {mainColors} = join("|",@colorsToUse);

				}
				if ($colorsNumber == 4) {
					$code -> {circleCut} = "cross";
					$code -> {mainColors} = join("|",@colorsToUse);
				}

			}
			if ($switches -> {_totalMetas} == 1) {
				$code -> {mainShape} = "pin";
				if ($switches -> {_metaDn} > 0) {
					$code -> {tip} = "dn";
					$code -> {mainColors} = "blu";

				} elsif ($switches -> {_metaUp} > 0){
					$code -> {tip} = "up";
					$code -> {mainColors} = "mag";
				} else {
					$code -> {mainShape} = "donut";
					$code -> {mainColors} = "yel";
					$code -> {tip} = "no";
				}
			}
			if ($switches -> {_totalMetas} > 1) {
				$code -> {mainShape} = "donut";
				$code -> {mainColors} = "yel";
				$code -> {tip} = "no";
			}
			return($code);
		}
		sub encodemiRNAs {
			my $switches = shift(@_);
			my $code = shift(@_);
			my @colorsToUse = ();
			if ($switches -> {_components} -> {_left} -> {_yellow}) {
				push(@colorsToUse,"yel");
			}
			if ($switches -> {_components} -> {_left} -> {_blue}) {
				push(@colorsToUse,"blu");
			}
			if ($switches -> {_components} -> {_left} -> {_orange}) {
				push(@colorsToUse,"ora");
			}
			if ($switches -> {_totalmiRNAs} == 1) {
				$code -> {leftNum} = 1;
				$code -> {leftColors} = $colorsToUse[0];
			}

			if ($switches -> {_totalmiRNAs} > 1) {
				if (scalar(@colorsToUse) == 3) {
					$code -> {leftNum} = 3;
				} else {
					$code -> {leftNum} = 2;
				}
			}
			if ($code -> {leftNum} == 2) {
				if ($switches -> {_idOnlymiRNAs} == 0) {
					if ($switches -> {_urnaUp} > $switches -> {_urnaDn}) {
						$code -> {leftColors} = "yel|yel";
					}
					if ($switches -> {_urnaUp} < $switches -> {_urnaDn}) {
						$code -> {leftColors} = "blu|blu";
					}
					if ($switches -> {_urnaUp} == $switches -> {_urnaDn}) {
						$code -> {leftColors} = join("|",@colorsToUse);
					}
				} elsif ($switches -> {_urnaUp} == 0) {
					$code -> {leftColors} = "blu|ora";
				} elsif ($switches -> {_urnaDn} == 0) {
					$code -> {leftColors} = "yel|ora";
				} else {
					$code -> {leftColors} = join("|",@colorsToUse);

				}
			} else {
				$code -> {leftColors} = join("|",@colorsToUse);
			}
			return($code);
		}
		sub encodeMeths {
			my $switches = shift(@_);
			my $code = shift(@_);
			my @colorsToUse = ();

			my $position = "top";

			if ($switches -> {_components} -> {"_".$position} -> {_yellow}) {
				push(@colorsToUse,"yel");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_blue}) {
				push(@colorsToUse,"blu");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_orange}) {
				push(@colorsToUse,"ora");
			}
			if ($switches -> {_totalMeths} == 1) {
				$code -> {$position."Num"} = 1;
			}
			if ($switches -> {_totalMeths} > 1) {
				if (scalar(@colorsToUse) == 3) {
					$code -> {$position."Num"} = 3;
				} else {
					$code -> {$position."Num"} = 2;
				}
			}

			if ($code -> {$position."Num"} == 2) {
				if ($switches -> {_idOnlyMeths} == 0) {
					if ($switches -> {_methUp} > $switches -> {_methDn}) {
						$code -> {$position."Colors"} = "yel|yel";
					}
					if ($switches -> {_methUp} < $switches -> {_methDn}) {
						$code -> {$position."Colors"} = "blu|blu";
					}
					if ($switches -> {_methUp} == $switches -> {_methDn}) {
						$code -> {$position."Colors"} = join("|",@colorsToUse);
					}
				} elsif ($switches -> {_methUp} == 0) {
					$code -> {$position."Colors"} = "blu|ora";
				} elsif ($switches -> {_methDn} == 0) {
					$code -> {$position."Colors"} = "yel|ora";
				} else {
					$code -> {$position."Colors"} = join("|",@colorsToUse);

				}
			} else {
				$code -> {$position."Colors"} = join("|",@colorsToUse);
			}

			return($code);
		}

		sub encodeChromas {
			my $switches = shift(@_);
			my $code = shift(@_);
			my @colorsToUse = ();

			my $position = "bot";

			if ($switches -> {_components} -> {"_".$position} -> {_yellow}) {
				push(@colorsToUse,"yel");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_blue}) {
				push(@colorsToUse,"blu");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_orange}) {
				push(@colorsToUse,"ora");
			}
			if ($switches -> {_totalChromas} == 1) {
				$code -> {$position."Num"} = 1;
			}
			if ($switches -> {_totalChromas} > 1) {
				if (scalar(@colorsToUse) == 3) {
					$code -> {$position."Num"} = 3;
				} else {
					$code -> {$position."Num"} = 2;
				}
			}

			if ($code -> {$position."Num"} == 2) {
				if ($switches -> {_idOnlyChromas} == 0) {
					if ($switches -> {_chromaUp} > $switches -> {_chromaDn}) {
						$code -> {$position."Colors"} = "yel|yel";
					}
					if ($switches -> {_chromaUp} < $switches -> {_chromaDn}) {
						$code -> {$position."Colors"} = "blu|blu";
					}
					if ($switches -> {_chromaUp} == $switches -> {_chromaDn}) {
						$code -> {$position."Colors"} = join("|",@colorsToUse);
					}

				} elsif ($switches -> {_chromaUp} == 0) {
					$code -> {$position."Colors"} = "blu|ora";
				} elsif ($switches -> {_chromaDn} == 0) {
					$code -> {$position."Colors"} = "yel|ora";
				} else {
					$code -> {$position."Colors"} = join("|",@colorsToUse);

				}
			} else {
				$code -> {$position."Colors"} = join("|",@colorsToUse);
			}

			return($code);
		}
		sub encodeTFs {
			my $switches = shift(@_);
			my $code = shift(@_);
			my @colorsToUse = ();

			my $position = "right";

			if ($switches -> {_components} -> {"_".$position} -> {_yellow}) {
				push(@colorsToUse,"yel");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_blue}) {
				push(@colorsToUse,"blu");
			}
			if ($switches -> {_components} -> {"_".$position} -> {_orange}) {
				push(@colorsToUse,"ora");
			}
			if ($switches -> {_totalTfs} == 1) {
				$code -> {$position."Num"} = 1;
			}
			if ($switches -> {_totalTfs} > 1) {
				if (scalar(@colorsToUse) == 3) {
					$code -> {$position."Num"} = 3;
				} else {
					$code -> {$position."Num"} = 2;
				}
			}

			if ($code -> {$position."Num"} == 2) {
				if ($switches -> {_idOnlyTFs} == 0) {
					if ($switches -> {_tfUp} > $switches -> {_tfDn}) {
						$code -> {$position."Colors"} = "yel|yel";

					}
					if ($switches -> {_tfUp} < $switches -> {_tfDn}) {
						$code -> {$position."Colors"} = "blu|blu";
					}
					if ($switches -> {_tfUp} == $switches -> {_tfDn}) {
						$code -> {$position."Colors"} = join("|",@colorsToUse);
					}

				} elsif ($switches -> {_tfUp} == 0 && $switches -> {_tfDn} == $switches -> {_idOnlyTFs}) {
					$code -> {$position."Colors"} = "blu|ora";
				} elsif ($switches -> {_tfDn} == 0 && $switches -> {_tfUp} == $switches -> {_idOnlyTFs}) {
					$code -> {$position."Colors"} = "yel|ora";
				} elsif ($switches -> {_tfDn} == 0 && $switches -> {_tfUp} == 0) {
					$code -> {$position."Colors"} = "ora|ora";
				} else {
					$code -> {$position."Colors"} = join("|",@colorsToUse);
				}
			} else {
				$code -> {$position."Colors"} = join("|",@colorsToUse);
			}

			return($code);
		}
		use Data::Dumper;
		my $self = shift;
		#'pathlayplot.pl?source=%0Amap_name:Citrate cycle (TCA cycle)%0Atype:prot|id:P31040|name:6389%0Atype:tf|id:3198|name:HOXA1%0Atype:tf|id:3397|name:ID1%0Atype:tf|id:8427|name:ZNF282%0Atype:prot|id:P21912|name:6390|dev:1.804%0Atype:tf|id:84436|name:ZNF528%0Atype:tf|id:9739|name:SETD1A%0Atype:tf|id:9972|name:NUP153%0Atype:deg|id:6391|name:SDHC%0Atype:meth|id:6391|dev:1.395%0Atype:chroma|id:6391|dev:1.882%0Atype:prot|id:Q99643|name:6391%0Atype:tf|id:148327|name:CREB3L4%0Atype:prot|id:O14521|name:6392|dev:-1.388%0Atype:tf|id:22926|name:ATF6|dev:-1.593%0Atype:tf|id:3398|name:ID2%0Atype:tf|id:4303|name:FOXO4|dev:-1.772%0Atype:tf|id:55870|name:ASH1L|dev:-1.567%0Atype:tf|id:7699|name:ZNF140|dev:1.145%0A'

		foreach my $complexType (keys %{$self -> {_complexes}}) {
			# print STDERR $complexType."\n";
			foreach my $complexObj (@{$self -> {_complexes} -> {$complexType}}) {
				my @elements = split("%0A",$complexObj -> {_queryForPlot});
				shift(@elements) for (1..2);
				#print STDERR Dumper \@elements;
				my $switches = {
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
					_idOnlyTFs => 0,
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
				my $code = {};
				my $info;
				foreach my $line (@elements) {
					($info,$switches) = getinfo($line,$switches);
				}
				#print STDERR Dumper $switches;
				$code = encodeShape($switches,$code);
				if ($switches -> {_totalmiRNAs} > 0) {
					$code = encodemiRNAs($switches,$code);
				}
				if ($switches -> {_totalMeths} > 0) {
					$code = encodeMeths($switches,$code);
				}
				if ($switches -> {_totalChromas} > 0) {
					$code = encodeChromas($switches,$code);
				}
				if ($switches -> {_totalTfs} > 0) {
					$code = encodeTFs($switches,$code);
				}

				$complexObj -> {_queryForPlotSlim} = "pathlayplotSlim.pl?";
				foreach my $key (sort keys %$code) {
					$complexObj -> {_queryForPlotSlim} .= "$key=".$code -> {$key}."&";
				}
				#print STDERR $complexObj -> {_queryForPlotSlim}."\n";
				#print STDERR Dumper $code;
				# encode switches in string following plot tree rules
			}
		}

	}

package MapDiv;
	our @ISA = qw(HTMLDiv);
	sub LoadComplexesOnDiv {
		my $self = shift;
		my %args = (
			Pathway => {},
			@_
		);
		my $pathway = $args{Pathway};
		foreach my $complex_type (sort keys %{$pathway -> {_complexes}}) {
			foreach my $complex (sort @{$pathway -> {_complexes} -> {$complex_type}}) {
				my $compid = $complex -> {_id};
				my ($map_id,$complex_number) = split(/_/,$compid);
				my $div_name = "";
				my $div_title = $complex -> {_legend_for_title};
				my $content = $complex -> {_queryForPlot};
				my $plot_source = $complex -> {_queryForPlotSlim};
				my $top_coord = $complex -> {_coordinates} -> {y};
				my $left_coord = $complex -> {_coordinates} -> {x};
				foreach my $content_id (sort keys %{$complex -> {_data}}) {

					my $content_name = $complex -> {_data} -> {$content_id} -> {name};
					$div_name .= "\_$content_id($content_name)";
				}
				$div_name =~ s/^\_//;
				my $complex_img = new HTMLImg(
					_id => $compid,
					_name => $div_name,
					_alt => "complex",
					_class => "complex animate-right",
					_style => "position:absolute; top:$top_coord"."px; left:$left_coord"."px; visibility:visible; opacity:0.6;z-index:+1;",
					_src => "$plot_source",
					_content => $content,
					_width => 50,
					_height => 50,
					_title => $complex -> {_legend_for_title},
					_onClick => "complex_selector($compid)",
					_ondblclick => "spawnBoomBox(this)"
				);
				$self -> ContentLoader(
					Content => $complex_img
				);
			}
		}
	}
1;