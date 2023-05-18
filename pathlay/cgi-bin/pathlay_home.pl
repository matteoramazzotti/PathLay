#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/modules/";
use lib "$FindBin::Bin/modules/structures/";
use lib "$FindBin::Bin/modules/home/";
use lib "$FindBin::Bin/modules/frontend/";
use lib "$FindBin::Bin/modules/frontend/home/";
use lib "$FindBin::Bin/modules/frontend/access/";
use lib "$FindBin::Bin/modules/frontend/registration/";
use lib "$FindBin::Bin/modules/frontend/tryagain/";
use PathLayUtils;
use HTMLObjects;
use PathLayHomeUtils;
use PathLayTryAgainFrontEnd;
use PathLayRegistrationFrontEnd;
use PathLayAccessFrontEnd;
use PathLayHomeFrontEnd;
use PathLayJSObjects;
use CGI;
use Data::Dumper;



our $CGI = CGI->new;
$CGI::POST_MAX = 1024 * 2000;
our $server = "localserver";
our $base = "$FindBin::Bin/..";

our %form = $CGI->Vars;

my $remoteurl = $ENV{'REMOTE_ADDR'};

our $localhost;
$localhost = `hostname -I` if ($server eq 'localserver');
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



my $parameters = new Parameters();
if ($form{'ope'}) {
    print STDERR $form{'ope'}."\n";
}

if ($form{ope} ne "download_pool" && $form{ope} ne "register") {


    $parameters -> CheckUserData(
        UsersFile => "$base/pathlay_users/users.list",
        Form => \%form
    );

    $parameters -> {_host} = $localhost;
    $parameters -> {_base} = $base;

}
if ($form{ope} eq 'register') {
    $parameters -> RegisterUser(
        UsersFile => "$base/pathlay_users/users.list",
        Form => \%form
    );
}

if ($form{ope} eq 'pathlay') {
    if ($parameters -> {_home} ne "nopwd" && $parameters -> {_home} ne "unk") {

        $parameters -> LoadAvailableExps(
            UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
        );

        my ($access_script,$form) = AccessBuilder(
            Parameters => $parameters
        );

        AccessPrinter(
            script => $access_script,
            form => $form
        );
    } else {
        if ($parameters -> {_home} eq "unk") {
            my $form = RegistrationBuilder();
            UnkPrinter(
                form => $form
            );
        }
        if ($parameters -> {_home} eq "nopwd") {
            my $form = TryAgainBuilder();
            NoPwdPrinter(
                form => $form
            );
        }
    }
}

if ($parameters -> {_access} eq "try_again") {
    if ($parameters -> {_home} eq "unk") {
        my $form = RegistrationBuilder();
        UnkPrinter(
            form => $form
        );
    }
    if ($parameters -> {_home} eq "nopwd") {
        my $form = TryAgainBuilder();
        NoPwdPrinter(
            form => $form
        );
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
        HomePrinter(
            script => $home_script,
            form => $form
        );
    } else {
        if ($parameters -> {_home} eq "unk") {
            my $form = RegistrationBuilder();
            UnkPrinter(
                form => $form
            );
        }
        if ($parameters -> {_home} eq "nopwd") {
            my $form = TryAgainBuilder();
            NoPwdPrinter(
                form => $form
            );
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
        Parameters => $parameters,
        Form => \%form
    );

    $parameters -> LoadAvailableExps(
        UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
    );
    my ($home_script,$form) = HomeBuilder(
        Parameters => $parameters
    );
    HomePrinter(
        form => $form,
        script => $home_script
    );
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

    SaveData(
        mainBase => $base,
        userHome => $parameters -> {_home},
        expId => $parameters -> {_expname},
        form => \%form
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
        form => \%form
    );

    $parameters -> LoadAvailableExps(
        UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
    );

    my ($home_script,$form) = HomeBuilder(
        Parameters => $parameters
    );
    HomePrinter(
        form => $form,
        script => $home_script
    );
}

if ($form{ope} eq 'add') {
    

    
    
    $parameters -> {_expname}= getExpToAdd(
        mainBase => $base,
        userHome => $parameters -> {_home}
    );

    #$parameters -> {_expname} = "exp$max";
    print STDERR "exp".$parameters -> {_expname}."\n";

    SaveData(
        mainBase => $base,
        userHome => $parameters -> {_home},
        expId => $parameters -> {_expname},
        form => \%form
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
        form => \%form
    );

    $parameters -> LoadAvailableExps(
        UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
    );
    my ($home_script,$form) = HomeBuilder(
        Parameters => $parameters
    );
    HomePrinter(
        script => $home_script,
        form => $form
    );
}

if ($form{ope} eq 'delete') {

    $parameters -> {_expname} = $form{exp_select};

    DeleteData(
        expId => $parameters -> {_expname},
        userHome => $parameters -> {_home},
        mainBase => $base
    );

    $parameters -> LoadAvailableExps(
        UsersDir => "$base/pathlay_users/".$parameters->{_home}."/"
    );

    my ($home_script,$form) = HomeBuilder(
        Parameters => $parameters
    );
    HomePrinter(
        script => $home_script,
        form => $form
    );
    
}

if ($form{ope} eq 'download_pool') {
    PoolDownload(
        form => \%form
    );
}









