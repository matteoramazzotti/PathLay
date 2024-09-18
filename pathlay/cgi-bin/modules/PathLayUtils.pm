use strict;
use warnings;
use FindBin;
#use Data::Dumper qw(Dumper);

my $debug = 0;

sub getTimeStamp {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $timestamp = ($year+1900).sprintf("%02d",$mon+1).sprintf("%02d",$mday).sprintf("%02d",$hour).sprintf("%02d",$min).sprintf("%02d",$sec);
    return($timestamp);
}

sub prepareEnablersForFrontEnd {
    my %args = (
        Parameters => {},
        ScriptSection => {},
        @_
    );
    my $script_section = $args{ScriptSection};
    my $parameters = $args{Parameters};

    if ($parameters -> {_enablegene}) {
        push(@{$script_section -> {_variables}},"var enable_gene=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var geneLeftThreshold=".$parameters -> {_geneLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var geneRightThreshold=".$parameters -> {_geneRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_gene=0;");
        #push(@{$script_section -> {_variables}},"var geneLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var geneRightThreshold= undefined;");
    }
    if ($parameters -> {_enableprot}) {
        push(@{$script_section -> {_variables}},"var enable_prot=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var protLeftThreshold=".$parameters -> {_protLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var protRightThreshold=".$parameters -> {_protRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_prot=0;");
        #push(@{$script_section -> {_variables}},"var protLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var protRightThreshold= undefined;");
    }
    if ($parameters -> {_enablemeta}) {
        push(@{$script_section -> {_variables}},"var enable_meta=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var metaLeftThreshold=".$parameters -> {_metaLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var metaRightThreshold=".$parameters -> {_metaRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_meta=0;");
        #push(@{$script_section -> {_variables}},"var metaLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var metaRightThreshold= undefined;");
    }
    if ($parameters -> {_enableurna}) {
        push(@{$script_section -> {_variables}},"var enable_urna=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var urnaLeftThreshold=".$parameters -> {_urnaLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var urnaRightThreshold=".$parameters -> {_urnaRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_urna=0;");
        #push(@{$script_section -> {_variables}},"var urnaLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var urnaRightThreshold= undefined;");
    }
    if ($parameters -> {_enablemeth}) {
        push(@{$script_section -> {_variables}},"var enable_meth=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var methLeftThreshold=".$parameters -> {_methLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var methRightThreshold=".$parameters -> {_methRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_meth=0;");
        #push(@{$script_section -> {_variables}},"var methLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var methRightThreshold= undefined;");
    }
    if ($parameters -> {_enablechroma}) {
        push(@{$script_section -> {_variables}},"var enable_chroma=1;");
        #if ($parameters -> {_mode_select} eq "full") {
        #    push(@{$script_section -> {_variables}},"var chromaLeftThreshold=".$parameters -> {_chromaLeftThreshold}.";");
        #    push(@{$script_section -> {_variables}},"var chromaRightThreshold=".$parameters -> {_chromaRightThreshold}.";");
        #}
    } else {
        push(@{$script_section -> {_variables}},"var enable_chroma=0;");
        #push(@{$script_section -> {_variables}},"var chromaLeftThreshold= undefined;");
        #push(@{$script_section -> {_variables}},"var chromaRightThreshold= undefined;");

    }
    if ($parameters -> {_enabletfs_gene} || $parameters -> {_enabletfs_prot}) {
        push(@{$script_section -> {_variables}},"var enable_tfs=1;");
    } else {
        push(@{$script_section -> {_variables}},"var enable_tfs=0;");
    }
}

sub updateJSVariables {

    my %args = (
        Parameters => {},
        geneSelectorMain => {},
        geneSelJSVar => {},
        urnaSelectorMain => {},
        urnaSelJSVar => {},
        protSelectorMain => {},
        protSelJSVar => {},
        metaSelectorMain => {},
        metaSelJSVar => {},
        tfSelectorMain => {},
        tfSelJSVar => {},
        Pathway => {},
        @_
    );

    my $gene_selector_main = $args{geneSelectorMain};
    my $genesel_js_var = $args{geneSelJSVar};
    my $prot_selector_main = $args{protSelectorMain};
    my $protsel_js_var = $args{protSelJSVar};
    my $urna_selector_main = $args{urnaSelectorMain};
    my $urnasel_js_var = $args{urnaSelJSVar};
    my $meta_selector_main = $args{metaSelectorMain};
    my $metasel_js_var = $args{metaSelJSVar};
    my $tf_selector_main = $args{tfSelectorMain};
    my $tfsel_js_var = $args{tfSelJSVar};
    my $pathway = $args{Pathway};
    my $parameters = $args{Parameters};

    if ($parameters -> {_enablegene}) {
        $gene_selector_main -> UpdatePreSelector (
            DEGs => 1,
            Complexes => $pathway -> {_complexes}
        );

        $genesel_js_var -> UpdatePreJSVariable (
            DEGs => 1,
            Maps => $pathway -> {_complexes}
        );

    }
    if ($parameters -> {_enableprot}) {
        $prot_selector_main -> UpdatePreSelector (
            Proteins => 1,
            Complexes => $pathway -> {_complexes}
        );
        $protsel_js_var -> UpdatePreJSVariable (
            Proteins => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enableurna}) {
        $urna_selector_main -> UpdatePreSelector (
            uRNAs => 1,
            Complexes => $pathway -> {_complexes}
        );
        
        $urnasel_js_var -> UpdatePreJSVariable (
            uRNAs => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enablenodeg} || $parameters -> {_enablemeth} || $parameters -> {_enablechroma}) {
        $gene_selector_main -> UpdatePreSelector (
            NoDEGs => 1,
            Complexes => $pathway -> {_complexes}
        );
        
        $genesel_js_var -> UpdatePreJSVariable (
            NoDEGs => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enablemeta}) {
        $meta_selector_main -> UpdatePreSelector (
            Metas => 1,
            Complexes => $pathway -> {_complexes}
        );
        $metasel_js_var -> UpdatePreJSVariable (
            Metas => 1,
            Maps => $pathway -> {_complexes}
        );
    }
    if ($parameters -> {_enabletfs}) {
        $tf_selector_main -> UpdatePreSelector (
            TFs => 1,
            Complexes => $pathway -> {_complexes}
        );
        $tfsel_js_var -> UpdatePreJSVariable (
            TFs => 1,
            Maps => $pathway -> {_complexes}
        );
    }
}

sub prepareONTsForFrontend {

    my %args = (
        ONTs => {},
        ONT2GeneJSVar => {},
        @_
    );

    my $onts = $args{ONTs};
    #my $ont2gene_js_var = $args{ONT2GeneJSVar};

    my @ont_select_options;
    foreach (sort keys %{$onts -> {_ids}}) {
        my $ont_select_option = new HTMLSelectOption(
            _value => $_,
            _text => $onts -> {_names} -> {$_}
        );
        
        push(@ont_select_options,$ont_select_option);
    }
    my $ont2gene_js_var = new PreJSVariable (
        _id => "ont2gene_js_var"
    );
    $ont2gene_js_var -> UpdatePreJSVariable(
        ONTs => $onts
    );
    return($ont2gene_js_var,@ont_select_options);
}

package Parameters;
    sub new {

        my $class = shift;
        my $self = {
            _submit => "",
            _username => "",
            _password => "",
            _access => "",
            _home => "",
            _time => "",
            _styledir => "../css/",
            _jsdir => "../javascript/",
            _org => "",
            _mapdir => "../pathlay_data/pathways/",
            _expname => "",
            _comments => "",
            _userdir => "",
            #_urna_db_filter => "strongonly"
            @_
        };

        my @dataTypes = (
            "gene",
            "prot",
            "meta",
            "meth",
            "urna",
            "chroma"
        );

        foreach my $dataType (@dataTypes) {
            $self -> {"_enable".$dataType} = 0;
            $self -> {"_".$dataType."LeftEffectSizeCheck"} = 0;
            $self -> {"_".$dataType."RightEffectSizeCheck"} = 0;
            $self -> {"_".$dataType."pValCheck"} = 0;
            $self -> {"_".$dataType."IdOnlyCheck"} = 0;
            $self -> {"_".$dataType."pValThreshold"} = "";
            $self -> {"_".$dataType."LeftThreshold"} = "";
            $self -> {"_".$dataType."RightThreshold"} = "";
            $self -> {"_".$dataType."_data"} = "";
            $self -> {"_".$dataType."_id_column"} = "";
            $self -> {"_".$dataType."_dev_column"} = "";
            $self -> {"_".$dataType."_pvalue_column"} = "";
            if ($dataType ne "gene" && $dataType ne "prot" && $dataType ne "meta") {
                $self -> {"_nodeg_select_".$dataType} = 0;
                $self -> {"_".$dataType."NoDEFromIdOnlyCheck"} = 0;
            }
            if ($dataType eq "gene" || $dataType eq "prot") {
                $self -> {"_enabletfs_".$dataType} = 0;
                $self -> {"_nodeg_select_tf_".$dataType} = 0;
                $self -> {"_enabletfsIdOnly_".$dataType} = 0;
                $self -> {"_tfsNoDEFromIdOnlyCheck_".$dataType} = 0;
            }
        }

        bless $self,$class;
        return($self);
    }



    sub CheckUserData {
        print STDERR "CheckUserData\n";
        my $self = shift;
        my %args = (
            UsersFile => "",
            Form => {},
            @_
        );
        my $users_file = $args{'UsersFile'};
        my %form = %{$args{'Form'}};
        open(IN,$users_file) or die "Cannot find users file!";
        foreach my $line (<IN>) {
            next if ($line !~ /\w/);
            chomp($line);
            my (
                $username,
                $password,
                $home,
                $time
            ) = split (/\t/,$line);
            if ($username eq $form{'username'}) {
                if ($password eq $form{'password'}) {
                    $self -> {_username} = $username;
                    $self -> {_password} = $password;
                    $self -> {_time} = $time;
                    $self -> {_home} = $home;
                } else {
                    $self -> {_home} = 'nopwd';
                }
                last;
            } else {
                $self -> {_home} = 'unk';
            }
        }
        close(IN);
    }

    sub RegisterUser {
        print STDERR "RegisterUser\n";
        my $self = shift;
        my %args = (
            UsersFile => "",
            Form => {},
            @_
        );
        my $users_file = $args{'UsersFile'};
        my %form = %{$args{'Form'}};

        print STDERR $self -> {_username}."\n";
        print STDERR $self -> {_password}."\n";

        open(IN,$users_file) or die "Cannot find users file!";
        foreach my $line (<IN>) {
            next if ($line !~ /\w/);
            chomp($line);
            my (
                $username,
                $password,
                $home,
                $time
            ) = split (/\t/,$line);
            if ($username eq $form{'username'}) {
                if ($password eq $form{'password'}) {
                    $self -> {_username} = $username;
                    $self -> {_password} = $password;
                    $self -> {_home} = $home;
                    $self -> {_time} = $time;
                } else {
                    $self -> {_home} = 'nopwd';
                }
                last;
            } else {
                $self -> {_home} = 'unk';
            }
        }
        print STDERR $self -> {_username}."\n";
        print STDERR $self -> {_password}."\n";
        print STDERR $self -> {_home}."\n";
        if ($self -> {_home} eq 'unk') {
            $self -> {_username} = $form{'username'};
            $self -> {_password} = $form{'password'};
            if ($self -> {_username} =~ "@") {
                if ($self -> {_password} ne "") {
                    $self -> {_home} = "";
                    foreach my $i (0..9){
                        $self -> {_home} .= int(rand(9));
                        $i++;
                    }
                    my $line = $self -> {_username}."\t".$self -> {_password}."\t".$self -> {_home}."\t1010101010\n";
                    $self -> {_access} = "granted";
                    system("echo \"$line\" >> /var/www/html/pathlay/pathlay_users/users.list");
                }
                system("mkdir /var/www/html/pathlay/pathlay_users/".$self -> {_home});
            } else {
                $self -> {_access} = "try_again";
            }

        }
        if ($self -> {_home} ne 'unk' && $self -> {_home} ne 'nopwd') {
            $self -> {_access} = "granted";
        }
        print STDERR $self -> {_access}."\n";
        return($self);
    }

    sub LoadAvailableExps {
        print STDERR "LoadAvailableExps\n";
        my $self = shift;
        my %args = (
            UsersDir => "",
            @_
        );

        opendir(DIR,$args{UsersDir});
        

        my @nexps;

        foreach my $file (readdir(DIR)) {
            if ($file =~ /exp(.+?)\.conf$/) {
                push(@nexps,$1);
            }
        }
        closedir(DIR);
        print STDERR "HERE:".$args{UsersDir}."\n";
        foreach my $e (@nexps) {
            $self -> {_exps_available} -> {"exp$e"} -> {conf_file} = "exp$e.conf";
            $self -> {_exps_available} -> {"exp$e"} -> {gene_file} = "exp$e.mrna";
            $self -> {_exps_available} -> {"exp$e"} -> {urna_file} = "exp$e.mirna";
            $self -> {_exps_available} -> {"exp$e"} -> {meta_file} = "exp$e.meta";
            $self -> {_exps_available} -> {"exp$e"} -> {prot_file} = "exp$e.prot";
            $self -> {_exps_available} -> {"exp$e"} -> {last_file} = "exp$e.last";
            print STDERR $self->{_exps_available}->{"exp$e"}->{conf_file}."\n";
            open(CONFIG,$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{conf_file}) or print "No".$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{conf_file}."<br>";
            while (<CONFIG>) {
                chomp;
                next if ($_ !~ /\w/);
                my ($field,$value) = split (/=/,$_);
                $self -> {_exps_available} -> {"exp$e"} -> {conf_data} -> {$field} = $value;
                print STDERR $field.":".$value."\n";
            }
            close(CONFIG);
            open(LAST,$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{last_file}) or print STDERR "No".$args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{last_file}."<br>";
            if ($args{UsersDir}.$self->{_exps_available}->{"exp$e"}->{last_file}) {
                while (<LAST>) {
                    chomp;
                    next if ($_ !~ /\w/);
                    my ($field,$value) = split (/=/,$_);
                    $self -> {_exps_available} -> {"exp$e"} -> {conf_data} -> {$field} = $value;
                }
            }
            
            close(LAST);
        }



    }

    sub LoadAvailableONTs {
        print STDERR "LoadAvailableONTs\n";
        my $self = shift;
        my %args = (
            _ont_db_file => "ont_hsa.gmt",
            _ont_db_location => "../pathlay_data/hsa/db/",
            @_
        );
        my $debug = 1;


        foreach my $organism(sort keys %{$self -> {_organisms_available}}) {
            open(IN,"../pathlay_data/$organism/db/$organism"."_ont.gmt");
            while(<IN>) {
                chomp;
                my ($ont_id,$ont_name,$ont_link,$genes) = split(/\t/);
                #$ont_id =~ s/://;
                $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {link} = $ont_link;
                $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {name} = $ont_name;
                foreach my $gene (sort(split(/;/,$genes))) {
                    $self -> {_onts_available} -> {$organism} -> {$ont_id} -> {genes} -> {$gene} = 1;
                }
            }
            close(IN);
        }
        $debug = 0;

        %{$self -> {_onts_default} -> {hsa}} = (
            "GO:0005737" => "name" => "cytoplasm",
            "GO:0005737" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005737",
            "GO:0005739" => "name" => "mitochondrion",
            "GO:0005739" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005739",
            "GO:0005634" => "name" => "nucleus",
            "GO:0005634" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005634",
            "GO:0005764" => "name" => "lysosome",
            "GO:0005764" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005764",
            "GO:0005794" => "name" => "Golgi apparatus",
            "GO:0005794" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005794",
            "GO:0005783" => "name" => "endoplasmic reticulum",
            "GO:0005783" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005783",
            "GO:0016020" => "name" => "membrane",
            "GO:0016020" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0016020",
            "GO:0005856" => "name" => "cytoskeleton",
            "GO:0005856" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005856"
        );
        %{$self -> {_onts_default} -> {mmu}} = (
            "GO:0005737" => "name" => "cytoplasm",
            "GO:0005737" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005737",
            "GO:0005739" => "name" => "mitochondrion",
            "GO:0005739" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005739",
            "GO:0005634" => "name" => "nucleus",
            "GO:0005634" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005634",
            "GO:0005764" => "name" => "lysosome",
            "GO:0005764" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005764",
            "GO:0005794" => "name" => "Golgi apparatus",
            "GO:0005794" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005794",
            "GO:0005783" => "name" => "endoplasmic reticulum",
            "GO:0005783" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005783",
            "GO:0016020" => "name" => "membrane",
            "GO:0016020" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0016020",
            "GO:0005856" => "name" => "cytoskeleton",
            "GO:0005856" => "link" => "http://amigo.geneontology.org/amigo/term/GO:0005856"
        );

    }

    sub LoadAvailableOrganisms {
        print STDERR "LoadAvailableOrganisms\n";
        my $self = shift;
        my %args = (
            @_
        );
        my $scores = {};
        my $scores_for_db = {};
        my $dirchecks = {};
        opendir(DIR,"../pathlay_data/") or die "Cannot open ../pathlay_data/\n";
        foreach my $organism_dir (readdir(DIR)) {
            next if ($organism_dir eq ".." || $organism_dir eq ".");
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

            #foreach my $key (sort keys %{$dirchecks -> {$organism_dir}}) {
            #   	print STDERR "\t".$key."\t".$dirchecks -> {$organism_dir} -> {$key};
            #   	$scores -> {$organism_dir}++ if ($dirchecks -> {$organism_dir} -> {$key} == 1);
            #}
            print STDERR "\n";
            #if ($scores -> {$organism_dir} == (scalar keys %{$dirchecks -> {$organism_dir}})) {
            #   	$self -> {_organisms_available} -> {$organism_dir} = 1;
            #}
            if ($dirchecks -> {$organism_dir} -> {maps_dir_ok} == 1 &&
                $dirchecks -> {$organism_dir} -> {maps_kegg_dir_ok} == 1 &&
                $dirchecks -> {$organism_dir} -> {db_kegg_dir_ok} == 1
            ) {
                $self -> {_organisms_available} -> {$organism_dir} -> {kegg} = 1;
            }
            if ($dirchecks -> {$organism_dir} -> {maps_dir_ok} == 1 &&
                $dirchecks -> {$organism_dir} -> {maps_wikipathways_dir_ok} == 1 &&
                $dirchecks -> {$organism_dir} -> {db_wikipathways_dir_ok} == 1
            ) {
                $self -> {_organisms_available} -> {$organism_dir} -> {wikipathways} = 1;
            }
        }
        closedir(DIR);

    }
    sub LoadENV {
        
        #print STDERR "LoadENV\n";
        my $self = shift;


        my $buffer;
        my $name;
        my $value;
        $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
        if ($ENV{'REQUEST_METHOD'} eq "POST") {
            print STDERR "POST\n";
            read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
        } else {
            print STDERR "STRING\n";
            $buffer = $ENV{'QUERY_STRING'};
        }
        my @pairs = split(/&/,$buffer);
        
        foreach my $pair (@pairs) {
            ($name, $value) = split(/=/, $pair);
            $value =~ tr/+/ /;
            $value =~ s/%(..)/pack("C", hex($1))/eg;
            #print STDERR "_$name\n";
            if ($value){
                #print STDERR $name."---".$value."\n" if ($name =~ "FET");
                $self -> {"_$name"} = $value eq 'true' ? 1 : $value eq 'false' ? 0 : $value;
            }
            if (ref($value) eq "ARRAY") { #?
                foreach my $what (@$name) {
                    #print STDERR $what."\n";
                }
            }
        }

        $self -> {_gene_db_file} = $self -> {_exp_organism_input_text}.".gene_info";
        $self -> {_gene_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
        $self -> {_urna_db_file} = $self -> {_exp_organism_input_text}."_mirtarbase.tsv";
        $self -> {_urna_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_exp_organism_input_text}."_mirtarbase.tsv";
        $self -> {_prot_db_file} = $self -> {_exp_organism_input_text}."_uniprot.tsv";
        $self -> {_prot_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
        $self -> {_ont_db_file} = $self -> {_exp_organism_input_text}."_ont.gmt";
        $self -> {_ont_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
        $self -> {_tf_db_file} = $self -> {_exp_organism_input_text}."_tf.gmt";
        $self -> {_tf_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";
        $self -> {_meta_db_file} = $self -> {_exp_organism_input_text}.".compound_info";
        $self -> {_meta_db_location} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/";

        $self -> {_mapdir} .= $self -> {_maps_db_select}."/"; 
        $self -> {_nodesdir} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/maps/".$self -> {_maps_db_select}."/";
        $self -> {_universe_file} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_maps_db_select}."/".$self -> {_exp_organism_input_text}.".".$self -> {_maps_db_select}.".genes.universe";
        $self -> {_map_association_file} = "../pathlay_data/".$self -> {_exp_organism_input_text}."/db/".$self -> {_maps_db_select}."/".$self -> {_exp_organism_input_text}.".".$self -> {_maps_db_select}.".gmt";
    }
    sub LoadENVFromCGI {
        use Data::Dumper;
        my $self = shift;
        print STDERR Dumper $cgi->Vars;
        foreach my $param ($cgi->Vars) {
            if ($cgi->param($param)) {
                $self->{"_$param"} = $cgi->param($param) eq "true" ? 1 : $cgi->param($param) eq "false" ? 0 : $cgi->param($param);
            }
        }

        $self -> {_gene_db_file} = $self -> {_org}.".gene_info";
        $self -> {_gene_db_location} = "../pathlay_data/".$self -> {_org}."/db/";
        $self -> {_urna_db_file} = $self -> {_org}."_mirtarbase.tsv";
        $self -> {_urna_db_location} = "../pathlay_data/".$self -> {_org}."/db/".$self -> {_org}."_mirtarbase.tsv";
        $self -> {_prot_db_file} = $self -> {_org}."_uniprot.tsv";
        $self -> {_prot_db_location} = "../pathlay_data/".$self -> {_org}."/db/";
        $self -> {_ont_db_file} = $self -> {_org}."_ont.gmt";
        $self -> {_ont_db_location} = "../pathlay_data/".$self -> {_org}."/db/";
        $self -> {_tf_db_file} = $self -> {_org}."_tf.gmt";
        $self -> {_tf_db_location} = "../pathlay_data/".$self -> {_org}."/db/";
        $self -> {_meta_db_file} = $self -> {_org}.".compound_info";
        $self -> {_meta_db_location} = "../pathlay_data/".$self -> {_org}."/db/";

        $self -> {_mapdir} .= $self -> {_maps_db_select}."/"; 
        $self -> {_nodesdir} = "../pathlay_data/".$self -> {_org}."/maps/".$self -> {_maps_db_select}."/";
        $self -> {_universe_file} = "../pathlay_data/".$self -> {_org}."/db/".$self -> {_maps_db_select}."/".$self -> {_org}.".".$self -> {_maps_db_select}.".genes.universe";
        $self -> {_map_association_file} = "../pathlay_data/".$self -> {_org}."/db/".$self -> {_maps_db_select}."/".$self -> {_org}.".".$self -> {_maps_db_select}.".gene.gmt";
        $self -> {_map_association_file_meta} = "../pathlay_data/".$self -> {_org}."/db/".$self -> {_maps_db_select}."/".$self -> {_org}.".".$self -> {_maps_db_select}.".meta.gmt";
    }
    sub updateLastSession {
        
        my $self = shift;
        
        print STDERR $FindBin::Bin."\n";
        

        open(LAST,">",$self->{_userdir}."/".$self -> {_exp_select}.".last");
        print LAST "maps_db_select=".$self -> {_maps_db_select}."\n";
        if ($self -> {_FETPooling}) {
            print LAST "FETPooling=".$self -> {_FETPooling}."\n";
        } else {
            print LAST "FETPooling=0\n";
        }
        if ($self -> {_FETIntersect}) {
            print LAST "FETIntersect=".$self -> {_FETIntersect}."\n";
        } else {
            print LAST "FETIntersect=0\n";
        }
        
        my @dataTypes = (
            "gene",
            "prot",
            "meta",
            "meth",
            "urna",
            "chroma"
        );
        foreach my $dataType (@dataTypes) {
            print LAST "enable".$dataType."=".$self -> {"_enable".$dataType}."\n";
            print LAST $dataType."LeftEffectSizeCheck=".$self -> {"_".$dataType."LeftEffectSizeCheck"}."\n";
            print LAST $dataType."RightEffectSizeCheck=".$self -> {"_".$dataType."RightEffectSizeCheck"}."\n";
            print LAST $dataType."pValCheck=".$self -> {"_".$dataType."pValCheck"}."\n";
            print LAST $dataType."IdOnlyCheck=".$self -> {"_".$dataType."IdOnlyCheck"}."\n";
            print LAST $dataType."pValThreshold=".$self -> {"_".$dataType."pValThreshold"}."\n";
            print LAST $dataType."LeftThreshold=".$self -> {"_".$dataType."LeftThreshold"}."\n";
            print LAST $dataType."RightThreshold=".$self -> {"_".$dataType."RightThreshold"}."\n";
            print LAST $dataType."FETEnabled=".$self -> {"_".$dataType."FETEnabled"}."\n";
            if ($dataType ne "gene" && $dataType ne "prot" && $dataType ne "meta") {
                print LAST "nodeg_select_".$dataType."=".$self -> {"_nodeg_select_".$dataType}."\n";
                print LAST $dataType."NoDEFromIdOnlyCheck=".$self -> {"_".$dataType."NoDEFromIdOnlyCheck"}."\n";
            }
            if ($dataType eq "gene" || $dataType eq "prot") {
                print LAST "enabletfs_".$dataType."=".$self -> {"_enabletfs_".$dataType}."\n";
                print LAST "nodeg_select_tf_".$dataType."=".$self -> {"_nodeg_select_tf_".$dataType}."\n";
                print LAST "enabletfsIdOnly_".$dataType."=".$self -> {"_enabletfsIdOnly_".$dataType}."\n";
                print LAST "tfsNoDEFromIdOnlyCheck_".$dataType."=".$self -> {"_tfsNoDEFromIdOnlyCheck_".$dataType}."\n";
            }
        }

        close(LAST);
    }
    sub PrintParameters {
        my $self = shift;
        foreach my $parameter (sort keys %$self) {
            next if ($parameter =~ /data$/);
            print STDERR "$parameter => ". $self -> {$parameter}."\n";
        }
    }
    sub CheckParameters {
        print STDERR "CheckParameters\n";
        my $self = shift;

        my %bad_parameters;
        my @checks = (
            "_h1",
            "_h2",
            "_h3",
            "_exp_name_input_text"
        );
        $self -> {_selectors_to_enable} = 0;

        push(@checks,qw/_gene_data _gene_id_column _geneLeftThreshold _geneRightThreshold _gene_pvalue_column _genepValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enablegene});
        push(@checks,qw/_prot_data _prot_id_column _protLeftThreshold _protRightThreshold _prot_pvalue_column _protpValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enableprot});
        push(@checks,qw/_meth_data _meth_id_column _methLeftThreshold _methRightThreshold _meth_pvalue_column _methpValThreshold/) if ($self -> {_enablemeth});
        push(@checks,qw/_urna_data _urna_id_column _urnaLeftThreshold _urnaRightThreshold _urna_pvalue_column _urnapValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enableurna});
        push(@checks,qw/_meta_data _meta_id_column _metaLeftThreshold _metaRightThreshold _meta_pvalue_column _metapValThreshold/) && $self -> {_selectors_to_enable}++ if ($self -> {_enablemeta});


        print STDERR "_selectors_to_enable:".$self -> {_selectors_to_enable}."\n";
        foreach my $parameter (@checks) {
            $bad_parameters{$parameter} = 1 if (!$self -> {$parameter});
            #print STDERR "$parameter OK: ".$self -> {$parameter}."\n" if ($self -> {$parameter});
            #print STDERR "$parameter NO\n" if (!$self -> {$parameter});
        }
        if (scalar keys %bad_parameters > 0) {
            print "Content-type: text/html\n\n";
            print "<table width=\"1900px\" border=0>\n";
            print "<tr bgcolor=\"#006699\" width=\"80%\"><td>\n";
            print "<font size=\"+2\" color=\"white\"><b>PathLay Interface</b></font></td><td align=\"right\"><img src=\"../src/sbsc-unifi-trasp-inv.png\" height=100 id=\"unifi\"></td>\n";
            print "</tr></table>\n";
            print "<table width=\"1900px\" border=0>\n";
            print "<tr><td>","<b>ERROR: The following filelds are missing with no default:</b><br>",(join '<br>',keys %bad_parameters),"\n";
            #output('stop');
            exit;
        }

        if ($self -> {_enableurna} == 1) {
            $self -> {_enablenodeg} = 1;
        }
        if ($self -> {_selectors_to_enable} == 1 && $self -> {_enableurna} == 1) {
            $self -> {_selectors_to_enable}++;
        }
        if ($self -> {_enablegene} == 0 && $self -> {_enableurna} == 1 && $self -> {_selectors_to_enable} >= 2) {
            $self -> {_selectors_to_enable} = 3;
        }
        if ($self -> {_enablegene} == 0  && $self -> {_enableurna} == 1) { #?
            $self -> {_selectors_to_enable}++;
        }
        if (($self -> {_enablegene} == 1 || $self -> {_enableprot} == 1) && $self -> {_enabletfs} == 1 ) {
            $self -> {_selectors_to_enable}++;
        }
    }

package Report;
    sub new {
        my $class = shift;
        my $self = {
            _degs_loaded => 0,
            _urnas_loaded => 0,
            _metas_loaded => 0,
            _nodegs_loaded => 0,
            _degs_collapsed => 0,
            _urnas_collapsed => 0,
            _metas_collapsed => 0,
            _degs_filtered => 0,
            _urnas_filtered => 0,
            _metas_filtered => 0,
            _urnas_linked_to_degs => 0,
            _urnas_linked_to_nodegs => 0,
            _degs_methylated => 0,
            _maps_processed => 0,
            _maps_plotted => 0,
            @_
        };
        bless $self, $class;
        return($self);
    }
    sub UpdateByKey {

        my $self = shift;
        my %args = (
            @_
        );

        foreach my $key (keys %args) {
            print STDERR "$key:".$args{$key}."\n";
            $self -> {$key} = $args{$key};
        }
    }
    sub PrintReport {

        my $self = shift;

        foreach my $key (sort keys %$self){
            print STDERR "$key:".$self -> {$key}."\n";
        }
    }

    
package PreSelector;
    sub new {

        my $class = shift;
        my $self = {
            _id => "undefined",
            _content_type => "undefined",
            _data => {},
            @_
        };
        bless $self, $class;
        return($self);
    }
    sub UpdatePreSelector {

        my $self = shift;
        my %args = (
            Complexes => {},
            DEGs => 0,
            Proteins => 0,
            NoDEGs => 0,
            uRNAs => 0,
            Metas => 0,
            TFs => 0,
            @_
        );
        my $type;
        my $reverse_text = 1;
        if ($args{DEGs} == 1) {
            $type = "deg";
        }
        if ($args{NoDEGs} == 1) {
            $type = "nodeg";
        }
        if ($args{Metas} == 1) {
            $type = "meta";
        }
        if ($args{uRNAs} == 1) {
            $type = "urnas";
        }
        if ($args{TFs} == 1) {
            $type = "tfs";
        }
        if ($args{Proteins} == 1) {
            $type = "prot";
        }


        if ($type eq "deg" || $type eq "nodeg" || $type eq "meta") {
            foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
                #print STDERR $complex -> {_id}."\n";
                #print STDERR $complex -> {_type}."\n";
                foreach my $id (sort keys %{$complex -> {_data}}) {
                    #$self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                    #print STDERR $complex -> {_data} -> {$id} -> {name}."\n";
                    if (!$reverse_text){
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        $self -> {_data} -> {$id} -> {text} = "$id (".$self -> {_data} -> {$id} -> {name}.")";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    } else {
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        $self -> {_data} -> {$id} -> {text} = $self -> {_data} -> {$id} -> {name}." ($id)";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
            if ($type eq "nodeg") {
                foreach my $complex (sort @{$args{Complexes} -> {multi}}) {
                    foreach my $id (sort keys %{$complex -> {_data}}) {
                        #$self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        #print STDERR $complex -> {_data} -> {$id} -> {name}."\n";
                        if (!$reverse_text){
                            $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                            $self -> {_data} -> {$id} -> {text} = "$id (".$self -> {_data} -> {$id} -> {name}.")";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        } else {
                            $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                            $self -> {_data} -> {$id} -> {text} = $self -> {_data} -> {$id} -> {name}." ($id)";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        }
                    }
                }
            }
        }
        if ($type eq "prot") {
            foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
                foreach my $id (sort keys %{$complex -> {_data}}) {
                    if (!$reverse_text){
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {prot_id}." (".$complex -> {_data} -> {$id} -> {name}.")";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    } else {
                        $self -> {_data} -> {$id} -> {name} = $complex -> {_data} -> {$id} -> {name};
                        #$self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {name}." (".$complex -> {_data} -> {$id} -> {prot_id}.")";
                        $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$id} -> {name}." (".$id.")";
                        my $option = new HTMLSelectOption (
                            _value => $id,
                            _text => $self -> {_data} -> {$id} -> {text}
                        );
                        $self -> {_data} -> {$id} -> {option} = $option;
                    }
                }
            }
        }
        if ($type eq "urnas") {
            foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                #print STDERR $complex -> {_id}."\n";
                #print STDERR $complex -> {_type}."\n";
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {text} = "$id";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Complexes} -> {nodeg}}) {
                #print STDERR $complex -> {_id}."\n";
                #print STDERR $complex -> {_type}."\n";
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {text} = "$id";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        }
                    }
                }
            }
            foreach my $complex (sort @{$args{Complexes} -> {prot}}) {
                foreach my $prot (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$prot} -> {urnas}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                            $self -> {_data} -> {$id} -> {text} = "$id";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        }
                    }
                }
            }
        }
        if ($type eq "tfs") {
            foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                #print STDERR $complex -> {_id}."\n";
                #print STDERR $complex -> {_type}."\n";
                foreach my $gene (sort keys %{$complex -> {_data}}) {
                    if ($complex -> {_data} -> {$gene} -> {tfs}) {
                        foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                            $self -> {_data} -> {$id} -> {text} = $complex -> {_data} -> {$gene} -> {tfs} -> {$id} -> {name}." ($id)";
                            my $option = new HTMLSelectOption (
                                _value => $id,
                                _text => $self -> {_data} -> {$id} -> {text}
                            );
                            $self -> {_data} -> {$id} -> {option} = $option;
                        }
                    }
                }
            }
        }

    }

package PreJSVariable;
    sub new {

        my $class = shift;
        my $self = {
            _id => "undefined",
            _data => {},
            @_
        };
        bless $self, $class;
        return($self);
    }
    sub UpdatePreJSVariable {

        my $self = shift;
        my %args = (

            DEGs => 0,
            NoDEGs => 0,
            uRNAs => 0,
            Metas => 0,
            Proteins => 0,
            TFs => 0,
            Complexes => {},
            Maps => {},
            @_
        );

        my $type;
        if ($args{DEGs} == 1) {
            $type = "deg";
        }
        if ($args{NoDEGs} == 1) {
            $type = "nodeg";
        }
        if ($args{Proteins} == 1) {
            $type = "prot";
        }
        if ($args{Metas} == 1) {
            $type = "meta";
        }
        if ($args{uRNAs} == 1) {
            $type = "urnas";
        }
        if ($args{TFs} == 1) {
            $type = "tf"
        }
        if ($args{ONTs}) {
            $type = "onts";
        }


        if (scalar keys %{$args{Complexes}} > 1) {
            if ($type ne "urnas" && $type ne "tf") {
                foreach my $complex (sort @{$args{Complexes} -> {$type}}) {
                    foreach my $id (sort keys %{$complex -> {_data}}) {
                        $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1; #warnings
                    }
                }
                if ($type eq "nodeg") {
                    foreach my $complex (sort @{$args{Complexes} -> {multi}}) {
                        foreach my $id (sort keys %{$complex -> {_data}}) {
                            $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1; #warnings
                        }
                    }
                }
            }
            if ($type eq "urnas") {
                foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                            }
                        }
                    }
                }
                foreach my $complex (sort @{$args{Complexes} -> {prot}}) {
                    foreach my $prot (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$prot} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                            }
                        }
                    }
                }
                foreach my $complex (sort @{$args{Complexes} -> {nodeg}}) {
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                            }
                        }
                    }
                }

            }

            if ($type eq "tf") {
                foreach my $complex (sort @{$args{Complexes} -> {deg}}) {
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {tfs}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                                $self -> {_data} -> {$id} -> {$complex -> {_id}} = 1;
                            }
                        }
                    }
                }
            }
        }
        if (scalar keys %{$args{Maps}} > 1) {
            if ($type ne "urnas" && $type ne "tf") {
                foreach my $complex (sort @{$args{Maps} -> {$type}}) {
                    my $index = $complex -> {_index};
                    foreach my $id (sort keys %{$complex -> {_data}}) {
                        $self -> {_data} -> {$id} -> {$index} = 1;
                    }
                }

                if ($type eq "nodeg") {
                    foreach my $complex (sort @{$args{Maps} -> {multi}}) {
                        my $index = $complex -> {_index};
                        foreach my $id (sort keys %{$complex -> {_data}}) {
                            $self -> {_data} -> {$id} -> {$index} = 1;
                        }
                    }
                }
            }
            if ($type eq "urnas") {
                foreach my $complex (sort @{$args{Maps} -> {deg}}) {
                    my $index = $complex -> {_index};
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$index} = 1;
                            }
                        }
                    }
                }
                foreach my $complex (sort @{$args{Maps} -> {nodeg}}) {
                    my $index = $complex -> {_index};
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$index} = 1;
                            }
                        }
                    }
                }
                foreach my $complex (sort @{$args{Maps} -> {prot}}) {
                    my $index = $complex -> {_index};
                    foreach my $prot (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$prot} -> {urnas}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$prot} -> {urnas}}) {
                                $self -> {_data} -> {$id} -> {$index} = 1;
                            }
                        }
                    }
                }
            }

            if ($type eq "tf") {
                foreach my $complex (sort @{$args{Maps} -> {deg}}) {
                    my $index = $complex -> {_index};
                    foreach my $gene (sort keys %{$complex -> {_data}}) {
                        if ($complex -> {_data} -> {$gene} -> {tfs}) {
                            foreach my $id (sort keys %{$complex -> {_data} -> {$gene} -> {tfs}}) {
                                $self -> {_data} -> {$id} -> {$index} = 1;
                            }
                        }
                    }
                }
            }
        }
        if (scalar keys %{$args{ONTs}}) {
            foreach my $ont (sort keys %{$args{ONTs} -> {_ont_to_genes}}) {
                foreach my $gene (sort keys %{$args{ONTs} -> {_ont_to_genes} -> {$ont} -> {genes}}) {
                    $self -> {_data} -> {$ont} -> {$gene} = 1;
                }
            }
        }
        #if (scalar keys %{$args{TFs}} > 0) {

        #}
    }
1;

