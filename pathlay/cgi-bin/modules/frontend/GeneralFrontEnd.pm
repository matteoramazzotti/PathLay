use strict;
use warnings;
use lib '.';
use HTMLObjects;

sub container4_Packager {

    my %args = (
        @_
    );

    my $title = $args{Title};

    my $container = new HTMLDiv(
        _id => "container4_access",
        _class => "container4",
        _style => "	position:relative; background-color:#006699; overflow:hidden; padding: 1px;"
    );
    my $header_div = new HTMLDiv(
        _id => "header_div_access",
        _class => "header_div"
    );
    my $unifi_logo_div = new HTMLDiv(
        _id => "unifi_logo_div_access",
        _class => "unifi_logo_div",
        _style => "float:right;"
    );
    my $unifi_logo_img = new HTMLImg(
        _id => "unifi_access",
        _src => "../src/sbsc-unifi-trasp-inv.png",
        _height => 100
    );

    $header_div -> ContentLoader(
        Content => "<font style=\"margin-top:35px; margin-left:60px; position:absolute;\" size=\"+2\" color=\"white\">"
    );
    $header_div -> ContentLoader(
        Content => "<b>$title</b>"
    );
    $header_div -> ContentLoader(
        Content => "</font>"
    );

    $unifi_logo_div -> ContentLoader(
        Content => $unifi_logo_img
    );

    $container -> ContentLoader(
        Content => $header_div
    );
    $container -> ContentLoader(
        Content => $unifi_logo_div
    );

    return($container);
}
sub container5_Packager {

    my %args = (
        @_
    );
    my $container4 = $args{Container4};

    my $container5 = new HTMLDiv(
        _id => "container5",
        _class => "container5",
        _style => "	position:relative; border: 0px solid black; padding:1px; margin:5px;"
        #_style => "border: 5px solid black;"
    );
    $container5 -> ContentLoader(
        Content => $container4
    );
    return($container5);
}

1;