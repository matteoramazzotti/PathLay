use strict;
use warnings;

sub BuildExpConfJS {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $JSscript = $args{Script};
    my %exp_confs;
    my @dataTypes = (
        "gene",
        "prot",
        "chroma",
        "meth",
        "urna",
        "meta"
    );

    foreach (sort keys %{$parameters -> {_exps_available}}) { #this should be handled with join btw :(
        print STDERR $_."\n";
        my @fields;
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {expname}) { #?
            push(@fields,"exp_name_input_text:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {expname}."\"");
        }
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {comments}) { #?
            push(@fields,"exp_comment_input_text:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {comments}."\"");
        }

        foreach my $dataType (@dataTypes) {
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."IdType"}){
                push(@fields,$dataType."IdType:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."IdType"}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."_id_column"}) {
                push(@fields,$dataType."_id_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."_id_column"}."\"");

            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} ->{$dataType."_dev_column"}) {
                push(@fields,$dataType."_dev_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} ->{$dataType."_dev_column"}."\"");

            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."_pvalue_column"}) {
                push(@fields,$dataType."_pvalue_column:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."_pvalue_column"}."\"");

            }
        }
    
        

        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}){
            push(@fields,"organism:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}."\"");
            if ($parameters -> {_organisms_available} -> {$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}} -> {wikipathways} == 1) {
                push(@fields,"wikipathways:1");
            }
            if ($parameters -> {_organisms_available} -> {$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {organism}} -> {kegg} == 1) {
                push(@fields,"kegg:1");
            }
        } else {
            push(@fields,"organism:\"hsa\""); #problem
            push(@fields,"kegg:1");
            push(@fields,"wikipathways:1");
        }

        $exp_confs{$_} = "exp_confs[\"$_\"] = {".join(",",@fields)."};";
        push(@{$JSscript -> {_variables}},$exp_confs{$_});
        #print STDERR $exp_confs{$_}."\n";
        
    }
    return($JSscript);
}
sub BuildExpLastJS {
    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $JSscript = $args{Script};
    my %exp_last;
    my @dataTypes = (
        "gene",
        "prot",
        "chroma",
        "meth",
        "urna",
        "meta"
    );


    foreach (sort keys %{$parameters -> {_exps_available}}) {
        print STDERR $_."\n";
        my @fields;
        foreach my $dataType (@dataTypes) {
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enable".$dataType}){
                push(@fields,"enable".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enable".$dataType});
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."LeftEffectSizeCheck"}) {
                push(@fields,$dataType."LeftEffectSizeCheck:".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."LeftEffectSizeCheck"});
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."RightEffectSizeCheck"}) {
                push(@fields,$dataType."RightEffectSizeCheck:".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."RightEffectSizeCheck"});
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."pValCheck"}) {
                push(@fields,$dataType."pValCheck:".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."pValCheck"});
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."LeftThreshold"}) {
                push(@fields,$dataType."LeftThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."LeftThreshold"}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."RightThreshold"}) {
                push(@fields,$dataType."RightThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."RightThreshold"}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."pValThreshold"}) {
                push(@fields,$dataType."pValThreshold:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."pValThreshold"}."\"");
            }
            if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."IdOnlyCheck"}) {
                push(@fields,$dataType."IdOnlyCheck:".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."IdOnlyCheck"});
            }
            if ($dataType ne "gene" && $dataType ne "prot") {
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"nodeg_select_".$dataType}) {
                    push(@fields,"nodeg_select_".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"nodeg_select_".$dataType});
                }
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."NoDEFromIdOnlyCheck"}) {
                    push(@fields,$dataType."NoDEFromIdOnlyCheck:".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {$dataType."NoDEFromIdOnlyCheck"});
                }
            }
            if ($dataType eq "gene" || $dataType eq "prot") {
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enabletfs_".$dataType}) {
                    push(@fields,"enabletfs_".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enabletfs_".$dataType});
                }
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"nodeg_select_tf_".$dataType}) {
                    push(@fields,"nodeg_select_tf_".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"nodeg_select_tf_".$dataType});
                }
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enabletfsIdOnly_".$dataType}) {
                    push(@fields,"enabletfsIdOnly_".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"enabletfsIdOnly_".$dataType});
                }
                if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"tfsNoDEFromIdOnlyCheck_".$dataType}) {
                    push(@fields,"tfsNoDEFromIdOnlyCheck_".$dataType.":".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {"tfsNoDEFromIdOnlyCheck_".$dataType});
                }
            }
        }
        
        if ($parameters -> {_exps_available} -> {$_} -> {conf_data} -> {maps_db_select}) {
            push(@fields,"maps_db_select:\"".$parameters -> {_exps_available} -> {$_} -> {conf_data} -> {maps_db_select}."\"");
        }
        $exp_last{$_} = "exp_last[\"$_\"] = {".join(",",@fields)."};";
        push(@{$JSscript -> {_variables}},$exp_last{$_});
        #print STDERR $exp_confs{$_}."\n";
        
    }
    return($JSscript);
}
1;