use strict;
use warnings;
our $timestamp;
package ExpONTs;
    sub new {
        my $class = shift;
        my $self = {
            _loaded => 0,
            _ids => {},
            _links => {},
            @_
        };
        bless $self,$class;
        return($self);
    }
    
    sub ONTsLoader {
        my $self = shift;
        my %args = (
            Parameters => {},
            @_
        );
        my $parameters = $args{Parameters};
        my $user = $parameters -> {_h3} ? $parameters -> {_h3} : $parameters->{_userdir};
        my $base = $user ne "6135251850" ? "../pathlay_users/" : "../demo_exps/";
        my $exp = $parameters -> {_exp_select};
        my $ont_db = $parameters -> {_ont_db_file};
        my $ont_db_location = $parameters -> {_ont_db_location};

        my $debug = 0;
        if ( -e $user."/$exp/"."$exp.ont") {
            open(IN,$user."/$exp/"."$exp.ont");
            while (<IN>) {
                chomp;
                print STDERR "$_\n" if ($debug);
                next if ($_ eq "");
                $self -> {_ids} -> {$_} = 1;
            }
            close(IN);

            if (scalar keys %{$self -> {_ids}} == 0) {
                $parameters -> {_enableonts} = 0;
                return;
            } else {
                $parameters -> {_enableonts} = 1;
            }
            open(IN,$ont_db_location.$ont_db);
            while (<IN>) {
                chomp;
                print STDERR "$_\n" if ($debug);
                my ($ont_id,$ont_name,$ont_link,$ont_genes) = split(/\t/);
                my @ont_genes = split(/;/,$ont_genes);
                print STDERR "ID:$ont_id|LINK:$ont_link\n" if ($debug);
                if ($self -> {_ids} -> {$ont_id}) {
                    $self -> {_names} -> {$ont_id} = $ont_name;
                    $self -> {_links} -> {$ont_id} = $ont_link;
                    foreach (sort @ont_genes) {
                        $self -> {_ont_to_genes} -> {$ont_id} -> {genes} -> {$_} = 1;
                        $self -> {_gene_to_onts} -> {$_} -> {onts} -> {$ont_id} = 1;
                    }
                }
            }
            close(IN);
        } else {
            $parameters -> {_enableonts} = 0;
        }
        $debug = 0;
    }

    sub ONTsPrinter {
        my $self = shift;

        foreach my $ont (sort keys %{$self -> {_ids}}) {
            print STDERR "> ".$ont."\n";
            print STDERR $self -> {_links} -> {$ont}."\n";
            foreach my $gene (sort keys %{$self -> {_ont_to_genes} -> {$ont} -> {genes}}) {
                print STDERR $gene."|";
            }
            print STDERR "\n";
        }
    }
    sub ONTsFilter {
        my $self = shift;
        my %args = (
            DEGs => {},
            NODEGs => {},
            @_
        );
        my %keep;
        my $degs = $args{DEGs};
        my $nodegs = $args{NODEGs};

        foreach my $deg (sort keys %{$degs -> {_data}}) {
            if ($self -> {_gene_to_onts} -> {$deg}) {
                foreach (sort keys %{$self -> {_gene_to_onts} -> {$deg} -> {onts}}) {
                    $keep{$_} = 1;
                }
            }
        }

        foreach my $nodeg (sort keys %{$nodegs -> {_data}}) {
            if ($self -> {_gene_to_onts} -> {$nodeg}) {
                foreach (sort keys %{$self -> {_gene_to_onts} -> {$nodeg} -> {onts}}) {
                    $keep{$_} = 1;
                }
            }
        }

        foreach my $ont (sort keys %{$self -> {_ids}}) {
            if (!$keep{$ont}) {
                delete($self -> {_ids} -> {$ont});
                delete($self -> {_links} -> {$ont});
                delete($self -> {_ont_to_genes} -> {$ont});
                foreach my $gene (sort keys %{$self -> {_gene_to_onts}}) {

                    if ($self -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont}) {
                        delete($self -> {_gene_to_onts} -> {$gene} -> {onts} -> {$ont});
                        if (scalar keys %{$self -> {_gene_to_onts} -> {$gene} -> {onts}} == 0) {
                            delete($self -> {_gene_to_onts} -> {$gene});

                        }
                    }
                }
            } else {
                foreach my $gene (sort keys %{$self -> {_ont_to_genes} -> {$ont} -> {genes}}) {

                    if (!$degs -> {_data} -> {$gene} && !$nodegs -> {_data} -> {$gene}) {
                        delete($self -> {_ont_to_genes} -> {$ont} -> {genes} -> {$gene});

                    }
                }
            }
        }
    }

package ExpGenes;
    sub new {

        my $class = shift;
        my $self = {
            #_source => "undef",
            _name => "exp",
            _loaded => 0,
            _collapsed => 0,
            _filtered => 0,
            _methylated => 0,
            @_
        };
        my $debug;
        print STDERR $self -> {_name}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub ExpLoader {

        my $self = shift;
        my %args = (
            _id_column => 0,
            _logfc_column => 1,
            _pvalue_column => 2,
            _methyl_column => "undef",
            @_
        );
        my $debug;
        print STDERR "_source:".$args{_source}."\n" if ($debug);
        print STDERR "_id_column:".$args{_id_column}."\n" if ($debug);
        print STDERR "_logfc_column:".$args{_logfc_column}."\n" if ($debug);
        print STDERR "__pvalue_column:".$args{_pvalue_column}."\n" if ($debug);
        print STDERR "__methyl_column:".$args{_methyl_column}."\n" if ($debug);
        open(IN,$self -> {"_source"}) or die "Fatal: Cannot open ".$self -> {_source}."\n";
        while(<IN>) {
            chomp;
            $_ =~ s/\r//g;
            next if (
                $_ =~ /EntrezGeneID/ ||
                $_ =~ /MetaID/ ||
                $_ =~ /mirID/
            );
            my @data = split(/\t/,$_);
            my $id = $data[$args{"_id_column"}];
            my $logfc = $data[$args{"_logfc_column"}];
            my $pvalue = $data[$args{"_pvalue_column"}];
            next if ($id eq "NA");
            push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
            push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);
            if ($args{_methyl_column} ne "undef") {
                push(@{$self -> {_data} -> {$id} -> {methyls}} , $data[$args{"_methyl_column"}]);
            }
        }
        close(IN);
        return($self);
    }
    sub ExpLoaderFromBuffer {
        my $self = shift;
        my %args = (
            _id_column => 0,
            _logfc_column => 1,
            _pvalue_column => 2,
            @_
        );
        my $debug = 0;

        
        
        my @data = split(/\n/,$args{_buffer});
        shift @data;
        print STDERR ref($self)."\n";
        foreach (@data) {
            chomp;
            $_ =~ s/\r//g;
            my @entry = split(/\t/,$_);
            my $id = $entry[$args{"_id_column"} - 1];

            next if ($id eq "NA" || $id eq "");
            
            if (!$self -> {_data} -> {$id}) {
                $self -> {_data} -> {$id} = {};
                $self -> {_loaded}++;
            }

            if ($entry[$args{"_logfc_column"} - 1]) {
                my $logfc = $entry[$args{"_logfc_column"} - 1];
                if ($logfc && $logfc ne "") {
                    $logfc = sprintf("%3.3f",$logfc);
                    push(@{$self -> {_data} -> {$id} -> {devs}} , $logfc);
                }
            }
            
            # if ($args{_pValCheck} == 1) {
                if ($entry[$args{"_pvalue_column"} - 1]) {
                    my $pvalue = $entry[$args{"_pvalue_column"} - 1];
                    if ($pvalue ne "") {
                        push(@{$self -> {_data} -> {$id} -> {pvalues}} , $pvalue);
                    }
                    
                }
                
            # }
        }
        
        $debug = 0;
    }
    sub checkIdOnly {
        my $self = shift;
        my %args = (
            @_
        );
        foreach my $id (sort keys %{$self -> {_data}}) {
            if (!$self -> {_data} -> {$id} -> {devs} && !$self -> {_data} -> {$id} -> {devs}) {
                if (!$args{_idOnlyCheck}) {
                    delete($self -> {_data} -> {$id});
                }
            }
        }
    }
    sub ExpPrinter {

        my $self = shift;
        my $debug;
        print STDERR "ExpPrinter Method\n";
        print STDERR $self -> {_source}."\n"  if ($debug);
        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR $id."\n";

            if ($self -> {_data} -> {$id} -> {devs}) {
                print STDERR "logfcs:";
                foreach my $logfc (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                    print STDERR " ".$logfc;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {dev}) {
                print STDERR "logfcs:";
                print STDERR " ".$self -> {_data} -> {$id} -> {dev}."\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalues}) {
                print STDERR "pvalues:";
                foreach my $pvalue (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                    print STDERR " ".$pvalue;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalue}) {
                print STDERR "pvalues:";
                print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
            }
            if ($self -> {_data} -> {$id} -> {meth}) {
                print STDERR "Methylation:";
                print STDERR " ".$self -> {_data} -> {$id} -> {meth}."\n";

            }
            if ($self -> {_data} -> {$id} -> {chroma}) {
                print STDERR "Chromatin:";
                print STDERR " ".$self -> {_data} -> {$id} -> {chroma}."\n";

            }
            if ($self -> {_data} -> {$id} -> {methyls}) {
                print STDERR "Methylation:";
                foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyls}}) {
                    print STDERR " ".$methyl;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {chromas}) {
                print STDERR "Chromatin:";
                foreach my $chroma (sort @{$self -> {_data} -> {$id} -> {chromas}}) {
                    print STDERR " ".$chroma;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {tfs}) {
                print STDERR "TFs:";
                foreach my $tf (sort keys %{$self -> {_data} -> {$id} -> {tfs}}) {
                    print STDERR $tf;
                    if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev}) {
                        print STDERR "\tdev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev};
                    }
                    if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval}) {
                        print STDERR "\tpval:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval};
                    }
                    print STDERR "\n";
                }
                print STDERR "\n";
            }

            print STDERR "\n";
        }

        sub pValuePrint {

            my $self = shift;

            foreach my $id (sort keys %{$self -> {_data}}) {
                print STDERR "$id pvalues:";
                if ($self -> {_data} -> {$id} -> {pvalues}) {
                    foreach my $pvalues (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                        print STDERR " ".$pvalues;
                    }
                    print STDERR "\n";
                }
                if ($self -> {_data} -> {$id} -> {pvalue}) {
                    print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
                }
            }
        }

        sub DEVPrint {

            my $self = shift;
            foreach my $id (sort keys %{$self -> {_data}}) {
                print STDERR "$id logfc:";
                if ($self -> {_data} -> {$id} -> {devs}) {
                    foreach my $dev (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                        print STDERR " ".$dev;
                    }
                    print STDERR "\n";
                }
                if ($self -> {_data} -> {$id} -> {dev}) {
                    print STDERR $self -> {_data} -> {$id} -> {dev}."\n";
                }
            }
        }

        sub MethPrint {

            my $self = shift;
            foreach my $id (sort keys %{$self -> {_data}}) {

                if ($self -> {_data} -> {$id} -> {meth}) {
                    print STDERR "$id Methylation:";
                    foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {meth}}) {
                        print STDERR " ".$methyl;
                    }
                }
                print STDERR "\n";
            }
        }
        sub ChromaPrint {

            my $self = shift;
            foreach my $id (sort keys %{$self -> {_data}}) {

                if ($self -> {_data} -> {$id} -> {chroma}) {
                    print STDERR "$id Chromatin:";
                    foreach my $chroma (sort @{$self -> {_data} -> {$id} -> {chroma}}) {
                        print STDERR " ".$chroma;
                    }
                }
                print STDERR "\n";
            }
        }

        sub LinksPrint{

            my $self = shift;

            foreach my $id (sort keys %{$self -> {_data}}) {
                if ($self -> {_data} -> {$id} -> {urnas}) {
                    print STDERR $id."\n";
                    foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                        print STDERR " $urna";
                    }
                    print STDERR "\n";
                }
            }
        }
    }

    sub Collapse {
      use Statistics::Distributions qw(chisqrprob);
      my $self = shift;

      foreach my $id (sort keys %{$self->{_data}}) {
          if ($self->{_data}{$id}{pvalues}) {
              my @pvalues = @{$self->{_data}{$id}{pvalues}};
              if (@pvalues > 1) {
                  my $chi_squared = -2 * sum(map { log($_) } @pvalues);
                  my $new_p = 1 - chisqrprob(2 * scalar(@pvalues), $chi_squared);
                  if ($new_p eq 'NaN') {
                      delete $self->{_data}{$id};
                      next;
                  } else {
                      delete $self->{_data}{$id}{pvalues};
                      $self->{_data}{$id}{pvalue} = $new_p;
                  }
              } else {
                  my $new_p = shift @pvalues;
                  delete $self->{_data}{$id}{pvalues};
                  $self->{_data}{$id}{pvalue} = $new_p;
              }
              $self->{_collapsed}++;
          }

          if ($self->{_data}{$id}{devs}) {
              my @devs = @{$self->{_data}{$id}{devs}};
              if (@devs > 1) {
                  my $new_fc = sum(@devs) / scalar(@devs);
                  delete $self->{_data}{$id}{devs};
                  $self->{_data}{$id}{dev} = $new_fc;
              } else {
                  my $new_fc = shift @devs;
                  delete $self->{_data}{$id}{devs};
                  $self->{_data}{$id}{dev} = $new_fc;
              }
              $self->{_collapsed}++;
          }
      }
      return $self;
    }
    sub filterByEffectSize {
        my $self = shift;
        my %args = (
            @_
        );
        

        foreach my $id (sort keys %{$self -> {_data}}) {
            if ($self -> {_data} -> {$id} -> {dev}) {
                if ($args{_LeftEffectSizeCheck} == 1 && $args{_RightEffectSizeCheck} == 1) {
                    if ($self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold} && $self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}) {
                        #print STDERR "Deleted: ".$self -> {_data} -> {$id}."\n";
                        delete $self -> {_data} -> {$id};
                        
                        next;
                    }
                }
                if ($args{_LeftEffectSizeCheck} == 1 && $args{_RightEffectSizeCheck} == 0) {
                    if ($self -> {_data} -> {$id} -> {dev} > $args{_LeftThreshold}) {
                        delete $self -> {_data} -> {$id};
                        next;
                    }
                }
                if ($args{_LeftEffectSizeCheck} == 0 && $args{_RightEffectSizeCheck} == 1) {
                    if ($self -> {_data} -> {$id} -> {dev} < $args{_RightThreshold}) {
                        delete $self -> {_data} -> {$id};
                        next;
                    }
                }
            } else {
                if ($args{_IdOnlyCheck} != 1) {
                    print STDERR "$timestamp :: Deleting $id due to dev missing!\n";
                    delete $self -> {_data} -> {$id};
                }
            }
            
            $self -> {_filtered}++;
        }
    }
    sub filterBypVal {
        my $self = shift;
        my %args = (
            @_
        );
        foreach my $id (sort keys %{$self -> {_data}}) {
            
            if ($self -> {_data} -> {$id} -> {pvalue}) {
                if ($self -> {_data} -> {$id} -> {pvalue} > $args{_pValThreshold}) {
                    delete $self -> {_data} -> {$id};
                    next;
                }
                $self -> {_filtered}++;
            } else {
                if ($args{_IdOnlyCheck} != 1) {
                    print STDERR "$timestamp :: Deleting $id due to pvalue missing!\n";
                    delete $self -> {_data} -> {$id};
                }
            }
        }
    }
    sub checkIdForConversion {
        my $self = shift;
        my %args = (
            @_
        );
        my $db = $args{_DB};
        my $converted = {};

        foreach (sort keys %{$self -> {_data}}){
            #print STDERR "Found:".$_."\n";
            if ($_ =~ /^ENS/) {
              if ($db -> {ensembl2entrez} -> {$_}) {

                my $entrez = $db -> {ensembl2entrez} -> {$_};
                #print STDERR "Converted:".$_."->"."$entrez\n";
                $converted -> {$entrez} = $self -> {_data} -> {$_};
                next;
              }
            }
            #$converted -> {$_} = $self -> {_data} -> {$_};
        }
        $self -> {_data} = $converted;
    }

package ExpMeth;
    our @ISA = qw(ExpGenes);

package ExpChroma;
    our @ISA = qw(ExpGenes);



package ExpProteins;
    our @ISA = qw(ExpGenes);
    sub new {

        my $class = shift;
        my $self = {
            #_source => "undef",
            _name => "exp",
            _loaded => 0,
            _collapsed => 0,
            _filtered => 0,
            _methylated => 0,
            @_
        };
        my $debug;
        print STDERR $self -> {_name}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub ConvertToGenes {
        my $self = shift;
        my %args = (
            _db => "uniprot-compressed_true_download_true_fields_accession_2Cid_2Cgene_n-2022.09.05-14.07.25.80.tsv",
            @_
        );
        my $debug;
        my $prot_db_file = $args{_db};
        print STDERR $prot_db_file."\n";

        open(IN,$prot_db_file) or die "Cannot open protein db\n";
        while(<IN>) {
            chomp;
            my ($prot_id,$entry_name,$gene_name,$prot_name,$gene_id,$organism) = split("\t",$_);
            if ($gene_id =~ /;/) {
                $gene_id =~ s/;//g; #need check for incomplete fields between proteins and genes
            } else {
                delete($self -> {_data} -> {$prot_id});
                next;
            }
            if ($self -> {_data} -> {$prot_id}) {
                print STDERR $prot_id."\t".$gene_id."\t".$prot_name."\n";
                $self -> {_data} -> {$gene_id} = $self ->  {_data} -> {$prot_id};
                $self -> {_data} -> {$gene_id} -> {_prot_id} = $prot_id;
                $self -> {_data} -> {$gene_id} -> {_prot_name} = $prot_name;
                delete($self -> {_data} -> {$prot_id});
            }
        }
        close(IN);

    }
    sub checkIdForConversion {
        my $self = shift;
        my %args = (
            @_
        );
        my $debug;
        my $idtype = $args{_idType};
        my $db = $args{_DB};
        my $converted = {};

        foreach (sort keys %{$self -> {_data}}) {
            #print STDERR "Converting idType ".$idtype." to entrez\n";
            #print STDERR $db -> {$idtype."2entrez"} -> {$_}."\n";
            if ($db -> {$idtype."2entrez"} -> {$_}) {
                my $entrez = $db -> {$idtype."2entrez"} -> {$_};
                $converted -> {$entrez} = $self -> {_data} -> {$_};
                $converted -> {$entrez} -> {_prot_id} = $_;
                $converted -> {$entrez} -> {_prot_name} = $db -> {entrez2fullName} -> {$entrez};
                next;
            }
        }
        $self -> {_data} = $converted;
    }
    sub ExpPrinter {

        my $self = shift;
        my $debug;
        print STDERR "ExpPrinter Method\n";
        print STDERR $self -> {_source}."\n"  if ($debug);
        foreach my $id (sort keys %{$self -> {_data}}) {
            print STDERR $id."\n";
            if ($self -> {_data} -> {$id} -> {_prot_id}) {
                print STDERR "protein_id: ".$self -> {_data} -> {$id} -> {_prot_id}."\n";
            }
            if ($self -> {_data} -> {$id} -> {devs}) {
                print STDERR "logfcs:";
                foreach my $logfc (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                    print STDERR " ".$logfc;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {dev}) {
                print STDERR "logfcs:";
                print STDERR " ".$self -> {_data} -> {$id} -> {dev}."\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalues}) {
                print STDERR "pvalues:";
                foreach my $pvalue (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                    print STDERR " ".$pvalue;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {pvalue}) {
                print STDERR "pvalues:";
                print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
            }
            if ($self -> {_data} -> {$id} -> {meth}) {
                print STDERR "Methylation:";
                print STDERR " ".$self -> {_data} -> {$id} -> {meth}."\n";

            }
            if ($self -> {_data} -> {$id} -> {methyls}) {
                print STDERR "Methylation:";
                foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {methyls}}) {
                    print STDERR " ".$methyl;
                }
                print STDERR "\n";
            }
            if ($self -> {_data} -> {$id} -> {tfs}) {
                print STDERR "TFs:";
                foreach my $tf (sort keys %{$self -> {_data} -> {$id} -> {tfs}}) {
                    print STDERR $tf;
                    if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev}) {
                        print STDERR "\tdev:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {dev};
                    }
                    if ($self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval}) {
                        print STDERR "\tpval:".$self -> {_data} -> {$id} -> {tfs} -> {$tf} -> {pval};
                    }
                    print STDERR "\n";
                }
                print STDERR "\n";
            }

            print STDERR "\n";
        }

        sub pValuePrint {

            my $self = shift;

            foreach my $id (sort keys %{$self -> {_data}}) {
                print STDERR "$id pvalues:";
                if ($self -> {_data} -> {$id} -> {pvalues}) {
                    foreach my $pvalues (sort @{$self -> {_data} -> {$id} -> {pvalues}}) {
                        print STDERR " ".$pvalues;
                    }
                    print STDERR "\n";
                }
                if ($self -> {_data} -> {$id} -> {pvalue}) {
                    print STDERR $self -> {_data} -> {$id} -> {pvalue}."\n";
                }
            }
        }

        sub DEVPrint {

            my $self = shift;
            foreach my $id (sort keys %{$self -> {_data}}) {
                print STDERR "$id logfc:";
                if ($self -> {_data} -> {$id} -> {devs}) {
                    foreach my $dev (sort @{$self -> {_data} -> {$id} -> {devs}}) {
                        print STDERR " ".$dev;
                    }
                    print STDERR "\n";
                }
                if ($self -> {_data} -> {$id} -> {dev}) {
                    print STDERR $self -> {_data} -> {$id} -> {dev}."\n";
                }
            }
        }

        sub MethPrint {

            my $self = shift;
            foreach my $id (sort keys %{$self -> {_data}}) {

                if ($self -> {_data} -> {$id} -> {meth}) {
                    print STDERR "$id Methylation:";
                    foreach my $methyl (sort @{$self -> {_data} -> {$id} -> {meth}}) {
                        print STDERR " ".$methyl;
                    }
                }
                print STDERR "\n";
            }
        }

        sub LinksPrint{

            my $self = shift;

            foreach my $id (sort keys %{$self -> {_data}}) {
                if ($self -> {_data} -> {$id} -> {urnas}) {
                    print STDERR $id."\n";
                    foreach my $urna (sort keys %{$self -> {_data} -> {$id} -> {urnas}}) {
                        print STDERR " $urna";
                    }
                    print STDERR "\n";
                }
            }
        }
    }






package ExpMetas;
    our @ISA = qw(ExpGenes);
    sub new {

        my $class = shift;
        my $self = {
            _source => "undef",
            _loaded => 0,
            _collapsed => 0,
            _filtered => 0,
            @_
        };
        my $debug;
        print STDERR $self -> {_source}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub checkIdForConversion {
        my $self = shift;
        my %args = (
            @_
        );

        my $idtype = $args{_idType};
        my $db = $args{_DB};
        my $converted = {};
        foreach (sort keys %{$self -> {_data}}) {
            #print STDERR $db -> {$idtype."2keggcompound"} -> {$_}."\n";
            if ($db -> {$idtype."2keggcompound"} -> {$_}) {
                my $entrez = $db -> {$idtype."2keggcompound"} -> {$_};
                $converted -> {$entrez} = $self -> {_data} -> {$_};
                next;
            }
        }
        $self -> {_data} = $converted;
    }


package ExpuRNAs;
    our @ISA = qw(ExpGenes);
    sub new {

        my $class = shift;
        my $self = {
            _source => "undef",
            _loaded => 0,
            _collapsed => 0,
            _filtered => 0,
            @_
        };
        my $debug;
        print STDERR $self -> {_source}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }


package ExpNoDEGs;
    our @ISA = qw(ExpGenes);
    sub new {

        my $class = shift;
        my $self = {
            @_
        };
        my $debug;
        print STDERR $self -> {_source}."\n" if ($debug);
        bless $self, $class;
        return($self);
    }
    sub CheckProteins {
        my $self = shift;
        my %args = (
            ExpProteins => {},
            @_
        );
        my $exp_prot = $args{ExpProteins};

        foreach my $gene_id (sort keys %{$exp_prot -> {_data}}) {
            #print STDERR $gene_id."\t".$exp_prot -> {_data} -> {$gene_id} -> {_prot_id}."\n";
            if ($self -> {_data} -> {$gene_id}) {
                #print STDERR "FOUND SAME ID FOR: ".$gene_id."\n";
                my $prot_id = $exp_prot -> {_data} -> {$gene_id} -> {_prot_id};
                my $prot_name = $exp_prot -> {_data} -> {$gene_id} -> {_prot_name};
                my $prot_dev;
                if ($exp_prot -> {_data} -> {$gene_id} -> {dev}) {
                    $prot_dev = $exp_prot -> {_data} -> {$gene_id} -> {dev};
                }
                my $prot_pval;
                if ($exp_prot -> {_data} -> {$gene_id} -> {pval}) {
                    $prot_pval = $exp_prot -> {_data} -> {$gene_id} -> {pval};
                }
                $exp_prot -> {_data} -> {$gene_id} = $self -> {_data} -> {$gene_id};
                $exp_prot -> {_data} -> {$gene_id} -> {_prot_id} = $prot_id;
                $exp_prot -> {_data} -> {$gene_id} -> {_prot_name} = $prot_name;
                if ($prot_dev) {
                    $exp_prot -> {_data} -> {$gene_id} -> {dev} = $prot_dev;
                }
                if ($prot_pval) {
                    $exp_prot -> {_data} -> {$gene_id} -> {pvalue} = $prot_pval;
                }
                delete($self -> {_data} -> {$gene_id});
            }
        }

    }
    