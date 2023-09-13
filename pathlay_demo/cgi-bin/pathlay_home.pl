#!/usr/bin/perl
use strict;
use warnings;
use lib '/var/www/html/pathlay_demo/cgi-bin/';
use PathLayUtils;
use HTMLObjects;
use PathLayFrontEnd;
use CGI;
use Data::Dumper;



my $CGI = CGI->new;
$CGI::POST_MAX = 1024 * 2000;
my $server = "localserver";
my $base;

$base = '/var/www/html/pathlay_demo/' if ($server eq 'von');
$base = '/var/www/html/bioserver2.org/' if ($server eq 'bioserver');
$base = '/var/www/html/pathlay_demo/' if ($server eq 'localserver');

my %form = $CGI->Vars;

my $remoteurl = $ENV{'REMOTE_ADDR'};

my $localhost;
$localhost = `hostname -I` if ($server eq 'localserver');
$localhost = '150.217.62.191' if ($server eq 'von');
$localhost = '150.217.62.250' if ($server eq 'bioserver');
chomp $localhost;
$localhost =~ s/ .+//g;
$localhost =~ s/ //g;
print STDERR $localhost."\n";
print STDERR $base."\n";
if ($form{ope}) {
    print STDERR $form{ope}."\n";
}

foreach (sort keys %form) {
    print STDERR $_.":".$form{$_}."\n";
}
print STDERR "###\n";
my $timestamp;

#if ($form{'username'} =~ /@/ && $form{'password'} =~ /\w/) {
#	$timestamp = get_timestamp();
#	home_user();
#}


CheckForm(
    Form => \%form
);

sub CheckForm {
    my %args = (
        @_
    );
    my %form = %{$args{'Form'}};
    my $parameters = new Parameters();
    if ($form{'ope'}) {
        print STDERR $form{'ope'}."\n";
    }
    if ($form{ope} ne "download_pool" && $form{ope} ne "register") {
        #foreach (sort keys %form) {
        #    next if ($_ =~ /_data/);
        #    print STDERR "KEY:".$_." VALUE:".$form{$_}."\n";
        #}

        $parameters -> CheckUserData(
            UsersFile => "$base/pathlay_users/users.list",
            Form => \%form
        );

        $parameters -> {_host} = $localhost;
        $parameters -> {_base} = $base;

    }
    if ($form{'ope'}) {
        print STDERR $form{'ope'}."\n";
    }
    if ($form{ope} eq 'register') {
        $parameters -> RegisterUser(
            UsersFile => "$base/pathlay_users/users.list",
            Form => \%form
        );
    }
    if ($form{'ope'}) {
        print STDERR $form{'ope'}."\n";
    }
    print STDERR $parameters -> {_access}."\n";
    if ($form{ope} eq 'pathlay') {
        if ($parameters -> {_home} ne "nopwd" && $parameters -> {_home} ne "unk") {

            $parameters -> LoadAvailableExps(
                UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
            );

            my ($access_script,$form) = AccessBuilder(
                Parameters => $parameters
            );
            print "Content-type: text/html\n\n";
            print "<!DOCTYPE html>\n";
            print "<html>\n";
            print "<head>\n";
            print "<meta charset=\"UTF-8\"/>\n";
            print '<link rel="stylesheet" href="../css/mainDivsAccess.css">';
            print "</head>\n";
            print "<body>";
            $access_script -> PrintScript();
            $form -> PrintForm();
            print "</body>";
            print "</html>\n";
        } else {
            if ($parameters -> {_home} eq "unk") {
                my $form = RegistrationBuilder();
                print "Content-type: text/html\n\n";
                print "<!DOCTYPE html>\n";
                print "<html>\n";
                print "<head>\n";
                print "<meta charset=\"UTF-8\"/>\n";
                print "</head>\n";
                print "<script>\n";
                print "doit = function (what) {\n";
                print "	var input = document.getElementById('ope')\n";
                print "	input.setAttribute(\"value\", what);\n";
                print "	document.getElementById('main').submit();\n";
                print "}\n";
                print "</script>\n";
                print "<body>";
                $form -> PrintForm();
                print "</body>";
                print "</html>\n";
            }
            if ($parameters -> {_home} eq "nopwd") {
                my $form = TryAgainBuilder();
                print "Content-type: text/html\n\n";
                print "<!DOCTYPE html>\n";
                print "<html>\n";
                print "<head>\n";
                print "<meta charset=\"UTF-8\"/>\n";
                print "</head>\n";
                print "<body>";
                $form -> PrintForm();
                print "</body>";
                print "</html>\n";
            }
        }
    }

    if ($parameters -> {_access} eq "try_again") {
        if ($parameters -> {_home} eq "unk") {
            my $form = RegistrationBuilder();
            print "Content-type: text/html\n\n";
            print "<!DOCTYPE html>\n";
            print "<html>\n";
            print "<head>\n";
            print "<meta charset=\"UTF-8\"/>\n";
            print "</head>\n";
            print "<script>\n";
            print "doit = function (what) {\n";
            print "	var input = document.getElementById('ope')\n";
            print "	input.setAttribute(\"value\", what);\n";
            print "	document.getElementById('main').submit();\n";
            print "}\n";
            print "</script>\n";
            print "<body>";
            $form -> PrintForm();
            print "</body>";
            print "</html>\n";
        }
        if ($parameters -> {_home} eq "nopwd") {
            my $form = TryAgainBuilder();
            print "Content-type: text/html\n\n";
            print "<!DOCTYPE html>\n";
            print "<html>\n";
            print "<head>\n";
            print "<meta charset=\"UTF-8\"/>\n";
            print "</head>\n";
            print "<body>";
            $form -> PrintForm();
            print "</body>";
            print "</html>\n";
        }
    }


    if ($form{ope} eq 'home' || $parameters -> {_access} eq "granted") {

        print STDERR "GOING HOME\n";
        print STDERR $parameters -> {_home}."\n";
        if ($parameters -> {_home} ne "nopwd" && $parameters -> {_home} ne "unk") {
            $parameters -> LoadAvailableOrganisms(); #maybe redundant
            $parameters -> LoadAvailableONTs();
            $parameters -> LoadAvailableExps(
                UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
            ); #maybe redundant
            my ($home_script,$form) = HomeBuilder(
                Parameters => $parameters
            );

            print "Content-type: text/html\n\n";
            print "<!DOCTYPE html>\n";
            print "<html>\n";
            print "<head>\n";
            print "<meta charset=\"UTF-8\"/>\n";
            print '<link rel="stylesheet" href="../css/ul.css">';
            print '<link rel="stylesheet" href="../css/mainDivsHome.css">';
            print "</head>\n";
            print "<body>";
            $home_script -> PrintScript();
            $form -> PrintForm();
            print "</body>";
            print "</html>\n";
        } else {
            if ($parameters -> {_home} eq "unk") {
                my $form = RegistrationBuilder();
                print "Content-type: text/html\n\n";
                print "<!DOCTYPE html>\n";
                print "<html>\n";
                print "<head>\n";
                print "<meta charset=\"UTF-8\"/>\n";
                print "</head>\n";
                print "<script>\n";
                print "doit = function (what) {\n";
                print "	var input = document.getElementById('ope')\n";
                print "	input.setAttribute(\"value\", what);\n";
                print "	document.getElementById('main').submit();\n";
                print "}\n";
                print "</script>\n";
                print "<body>";
                $form -> PrintForm();
                print "</body>";
                print "</html>\n";
            }
            if ($parameters -> {_home} eq "nopwd") {
                my $form = TryAgainBuilder();
                print "Content-type: text/html\n\n";
                print "<!DOCTYPE html>\n";
                print "<html>\n";
                print "<head>\n";
                print "<meta charset=\"UTF-8\"/>\n";
                print "</head>\n";
                print "<body>";
                $form -> PrintForm();
                print "</body>";
                print "</html>\n";
            }

        }
    }

    if ($form{ope} eq 'upload') {
        #$parameters -> PrintParameters();
        CheckUploadedFile(
            File => $form{file},
            Parameters => $parameters
        );
        ExtractZip(
            File => $parameters -> {_base}."/pathlay_users/".$parameters -> {_home}."/tmpfile.zip",
            Parameters => $parameters
        );

        $parameters -> LoadAvailableExps(
            UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
        );
        my ($home_script,$form) = HomeBuilder(
            Parameters => $parameters
        );

        print "Content-type: text/html\n\n";
        print "<!DOCTYPE html>\n";
        print "<html>\n";
        print "<head>\n";
        print "<meta charset=\"UTF-8\"/>\n";
        print '<link rel="stylesheet" href="../css/ul.css">';
        print "</head>\n";
        print "<body>";
        $home_script -> PrintScript();
        $form -> PrintForm();
        print "</body>";
        print "</html>\n";
    }

    if ($form{ope} eq 'download') {
        $parameters -> {_expname} = $form{exp_select};

        DownloadZip(
            Parameters => $parameters,
            Target => "experiment"
        );
        #$parameters -> PrintParameters();
    }

    if ($form{ope} eq 'download_home') {
        DownloadZip(
            Parameters => $parameters,
            Target => "home"
        );
    }

    if ($form{ope} eq 'save') {

        $parameters -> {_expname} = $form{exp_select};

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'gene_data'},
            dataType => "mrna"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'prot_data'},
            dataType => "prot"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'urna_data'},
            dataType => "urna"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'meth_data'},
            dataType => "meth"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'meta_data'},
            dataType => "meta"
        );

        writeExpONT(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expOrganism => $form{'exp_organism_selector'},
            expONT => $form{"onts_selected_".$form{'exp_organism_selector'}}
        );

        writeExpConf(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expOrganism => $form{'exp_organism_selector'},
            expName => $form{exp_name_input_text},
            expComments => $form{exp_comment_input_text},
            geneIdColumn => $form{gene_id_column},
            geneDevColumn => $form{gene_dev_column},
            genepValColumn =>$form{gene_pvalue_column},
            geneIdType => $form{geneIdType},
            protIdColumn => $form{prot_id_column},
            protDevColumn => $form{prot_dev_column},
            protpValColumn => $form{prot_pvalue_column},
            protIdType => $form{protIdType},
            urnaIdColumn => $form{urna_id_column},
            urnaDevColumn => $form{urna_dev_column},
            urnapValColumn => $form{urna_pvalue_column},
            urnaIdType => $form{urnaIdType},
            methIdColumn => $form{meth_id_column},
            methDevColumn => $form{meth_dev_column},
            methpValColumn => $form{meth_pvalue_column},
            methIdType => $form{methIdType},
            metaIdColumn => $form{meta_id_column},
            metaDevColumn => $form{meta_dev_column},
            metapValColumn => $form{meta_pvalue_column},
            metaIdType => $form{metaIdType}
        );

        $parameters -> LoadAvailableExps(
            UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
        );

        my ($home_script,$form) = HomeBuilder(
            Parameters => $parameters
        );

        print "Content-type: text/html\n\n";
        print "<!DOCTYPE html>\n";
        print "<html>\n";
        print "<head>\n";
        print "<meta charset=\"UTF-8\"/>\n";
        print '<link rel="stylesheet" href="../css/ul.css">';
        print '<link rel="stylesheet" href="../css/mainDivsHome.css">';
        print "</head>\n";
        print "<body>";
        $home_script -> PrintScript();
        $form -> PrintForm();
        print "</body>";
        print "</html>\n";
    }

    if ($form{ope} eq 'add') {
        my $first = 1;
        my $max;
        opendir(DIR,"$base/pathlay_users/".$parameters -> {_home}."/");
        foreach my $file (sort(readdir(DIR))) {
            next if ($file !~ /^exp/);
            my $n = $file;
            $n =~ s/\..+$//;
            $n =~ s/exp//;
            if ($first == 1) {
                $max = $n;
                $first = 0;
                next;
            }
            if ($n > $max) {
                $max = $n;
            }
        }
        closedir(DIR);

        if (!$max) {
            $max = 1;
        }

        $parameters -> {_expname} = "exp$max";
        print STDERR "exp".$parameters -> {_expname}."\n";
        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'gene_data'},
            dataType => "mrna"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'prot_data'},
            dataType => "prot"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'urna_data'},
            dataType => "urna"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'meth_data'},
            dataType => "meth"
        );

        writeExpData(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expData => $form{'meta_data'},
            dataType => "meta"
        );

        writeExpONT(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expOrganism => $form{'exp_organism_selector'},
            expONT => $form{"onts_selected_".$form{'exp_organism_selector'}}
        );

        writeExpConf(
            mainBase => $base,
            userHome => $parameters -> {_home},
            expId => $parameters -> {_expname},
            expOrganism => $form{'exp_organism_selector'},
            expName => $form{exp_name_input_text},
            expComments => $form{exp_comment_input_text},
            geneIdColumn => $form{gene_id_column},
            geneDevColumn => $form{gene_dev_column},
            genepValColumn =>$form{gene_pvalue_column},
            protIdColumn => $form{prot_id_column},
            protDevColumn => $form{prot_dev_column},
            protpValColumn => $form{prot_pvalue_column},
            urnaIdColumn => $form{urna_id_column},
            urnaDevColumn => $form{urna_dev_column},
            urnapValColumn => $form{urna_pvalue_column},
            methIdColumn => $form{meth_id_column},
            methDevColumn => $form{meth_dev_column},
            methpValColumn => $form{meth_pvalue_column},
            metaIdColumn => $form{meta_id_column},
            metaDevColumn => $form{meta_dev_column},
            metapValColumn => $form{meta_pvalue_column}
        );

        $parameters -> LoadAvailableExps(
            UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
        );
        my ($home_script,$form) = HomeBuilder(
            Parameters => $parameters
        );
        print "Content-type: text/html\n\n";
        print "<!DOCTYPE html>\n";
        print "<html>\n";
        print "<head>\n";
        print "<meta charset=\"UTF-8\"/>\n";
        print '<link rel="stylesheet" href="../css/ul.css">';
        print '<link rel="stylesheet" href="../css/mainDivsHome.css">';
        print "</head>\n";
        print "<body>";
        $home_script -> PrintScript();
        $form -> PrintForm();
        print "</body>";
        print "</html>\n";
    }

    if ($form{ope} eq 'delete') {

        $parameters -> {_expname} = $form{exp_select};

        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".conf") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".conf");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".last") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".last");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".mrna") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".mrna");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".mirna") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".mirna");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".meta") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".meta");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".meth") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".meth");
        }
        if (-e "$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".prot") {
            unlink("$base/pathlay_users/".$parameters -> {_home}."/".$parameters -> {_expname}.".prot");
        }

        $parameters -> LoadAvailableExps(
            UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
        );

        my ($home_script,$form) = HomeBuilder(
            Parameters => $parameters
        );

        print "Content-type: text/html\n\n";
        print "<!DOCTYPE html>\n";
        print "<html>\n";
        print "<head>\n";
        print "<meta charset=\"UTF-8\"/>\n";
        print '<link rel="stylesheet" href="../css/ul.css">';
        print "</head>\n";
        print "<body>";
        $home_script -> PrintScript();
        $form -> PrintForm();
        print "</body>";
        print "</html>\n";
    }

    if ($form{ope} eq 'download_pool') {
        print "Content-Type:application/x-download\n";
        print "Content-Disposition:attachment;filename=pathlay_data_pool.txt\n\n";
        print "ID\tName\tType\tlogFC (Expression)\tlogFC (Methylation)\tMap\tGene/miRNA Association\n";
        print $form{'info_to_download'};
    }

}


sub CheckUploadedFile {

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $filename = $args{File};
    my $base = $parameters -> {_base};
    my $home = $parameters -> {_home};


    my $safe_filename_characters = "a-zA-Z0-9_.-";

    if (!$filename) {
        print "Content-type: text/html\n\n";
        print "There was a problem uploading your file: maybe size exceeds 2 MBytes.";
        exit;
    } else {
        if ($filename !~ /\.zip/) {
            print "Content-type: text/html\n\n";
            print "There was a problem uploading your file: only zip files accepted.";
            exit;
        }
        my @tmp = split(/[\\\/]/,$filename);
        $filename = shift @tmp;
        $filename =~ tr/ /_/;
        $filename =~ s/[^$safe_filename_characters]//g;
        if ( $filename =~ /^([$safe_filename_characters]+)$/ ) {
            $filename = $1;
        } else {
            print "Content-type: text/html\n\n";
            print "There was a problem uploading your file: characters other than $safe_filename_characters are not accepted.";
            exit;
        }
        my $upload_filehandle = $CGI->upload("file");
        open(UP,">$base/pathlay_users/$home/tmpfile.zip") or die "$!";
        binmode(UP);
        while(<$upload_filehandle>) {
            print UP;
        }
        close(UP);
        if (!-e "$base/pathlay_users/$home/tmpfile.zip") {
            print "Content-type: text/html\n\n";
            print "There was a problem uploading your file: transfer failed.";
            #print LOG "$timestamp $remoteurl ",$form{'username'}," upload failed: not completed\n";
            exit;
        }
    }

}
sub ExtractZip {

    use Archive::Zip;

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $zip = $args{File};
    my $base = $parameters -> {_base};
    my $home = $parameters -> {_home};


    my $expn = 0;
    foreach (1..10000) {
        $expn++;
        last if (!-e "$base/pathlay_users/$form{home}/exp$expn.conf");
    }
    $zip = Archive::Zip->new($zip);
    my @members = $zip -> memberNames();
    foreach my $file (@members) {
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.conf") if ($file =~ /\.conf/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.sel") if ($file =~ /\.sel/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.mirna") if ($file =~ /\.mirna/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.mrna") if ($file =~ /\.mrna/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.meta") if ($file =~ /\.meta/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.assoc") if ($file =~ /\.assoc/);
        $zip->extractMember($file,"$base/pathlay_users/$home/exp$expn.meta") if ($file =~ /\.prot/);
    }
}
sub DownloadZip {

    use Archive::Zip;

    my %args = (
        @_
    );

    my $parameters = $args{Parameters};
    my $target = $args{Target};

    my $base = $parameters -> {_base};
    my $user = $parameters -> {_username};
    my $home = $parameters -> {_home};
    my $exp = $parameters -> {_expname};

    my $zip = Archive::Zip->new();

    if ($target eq "experiment") {
        $zip -> addTree($base."/pathlay_users/".$home."/",'',sub { /$exp/ });
        print "Content-Type:application/zip\n";
        print "Content-Disposition:attachment;filename=".$user."_$exp.zip\n\n";
    }

    if ($target eq "home") {
        $zip -> addTree($base."/pathlay_users/".$home."/",'');
        print "Content-Type:application/zip\n";
        print "Content-Disposition:attachment;filename=".$user."_home.zip\n\n";
    }
    binmode(STDOUT);
    $zip->writeToFileHandle(*STDOUT);
}


sub writeExpData {
    my %args = (
        @_
    );

    my $mainBase = $args{mainBase};
    my $userHome = $args{userHome};

    my $expId = $args{expId};
    my $dataType = $args{dataType};
    my $expData = $args{expData};

    print STDERR "$base/pathlay_users/$userHome/$expId.$dataType\n";

    open(OUT, ">", "$mainBase/pathlay_users/$userHome/$expId.$dataType") or die "writeExpData Failed!";
    print OUT $expData;
    close(OUT);

    return();
}
sub writeExpONT {
    
    my %args = (
        @_
    );

    my $mainBase = $args{mainBase};
    my $userHome = $args{userHome};
    my $expId = $args{expId};
    my $expONT = $args{expONT};
    my $expOrganism = $args{expOrganism};

    $expONT =~ s/[\x00|\x08\x0B|\x0C\x0E|\x1F\x7F|\x9F|\x87]//g;

    open(OUT,">","$mainBase/pathlay_users/$userHome/$expId.ont");
    my @array = split(/\@/,$expONT);

    foreach my $ont (sort @array) {
        #$ont =~ s/[\x00|\x08\x0B|\x0C\x0E|\x1F\x7F|\x9F|\x87]//g;
        #$ont =~ s/%(..)/pack("C", hex($1))/eg;
        $ont =~ s/\_$expOrganism//;
        print OUT "$ont\n";
    }
    close(OUT);
    return();
}
sub writeExpConf {

    my %args = (
        @_
    );

    my $mainBase = $args{mainBase};
    my $userHome = $args{userHome};
    my $expId = $args{expId};
    my $expName = $args{expName};
    my $expComments = $args{expComments};
    my $expOrganism = $args{expOrganism};


    my @dataTypes = (
        "gene",
        "prot",
        "urna",
        "meth",
        "meta"
    );
    print STDERR "$base/pathlay_users/$userHome/$expId.conf\n";
    open(OUT, ">" ,"$base/pathlay_users/$userHome/$expId.conf") or die "$base/pathlay_users/$userHome/$expId.conf"."writeExpData Failed!";
    print OUT "expname=$expName\n";
    print OUT "comments=$expComments\n";
    print OUT "organism=$expOrganism\n";

    foreach my $dataType (@dataTypes) {
        print OUT $dataType."IdType=".$args{$dataType."IdType"}."\n";
        print OUT $dataType."_id_column=".$args{$dataType."IdColumn"}."\n";
        print OUT $dataType."_dev_column=".$args{$dataType."DevColumn"}."\n";
        print OUT $dataType."_pvalue_column=".$args{$dataType."pValColumn"}."\n";
    }
    close OUT;
}