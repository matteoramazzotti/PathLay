use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use HTMLObjects;
use GeneralFrontEnd;

sub TryAgainBuilder {

    my %args = (
        @_
    );

    my $form = new HTMLForm(
        _id => "main",
        _name => "pathlay",
        _action => "../cgi-bin/pathlay_home.pl",
        _method => "post",
        _enctype => "multipart/form-data"
    );
    my $container4_home = container4_Packager(
        Title => "PathLay - Registration"
    );
    my $container5_home = container5_Packager(
        Container4 => $container4_home
    );
    my $div_main_tryagain = div_main_tryagain_Packager();


    $form -> ContentLoader(
        Content => $container5_home
    );
    $form -> ContentLoader(
        Content => $div_main_tryagain
    );

    return($form);
}

sub div_main_tryagain_Packager {

    my $div_main_registration = new HTMLDiv(
        _id => "div_main_registration",
        _class => "div_main_registration",
        _style => "border:solid blue 2px;width:100%;margin-top:20px;text-align:center;"
    );
    $div_main_registration -> ContentLoader(
        Content => "<p>Wrong Password. Please try again.</p>"
    );
    return($div_main_registration);
}

sub NoPwdPrinter {
    my %args = (
        @_
    );

    my $form = $args{form};

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

1;