use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../";
use HTMLObjects;
use GeneralFrontEnd;

sub RegistrationBuilder {
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
    my $div_main_registration = div_main_registration_Packager();
    my $hidden_input = new HTMLInput(
        _type => "hidden",
        _id => "ope",
        _name => "ope",
        _value => ""
    );
    #<center>
    #E-mail <input type="text" name="username" id="username" size="20">
    #<br></br>
    #Password <input type="text" name="password" id="password" size="20">
    #</center>
    my $username_text = new HTMLInput(
        _type => "text",
        _name => "username",
        _id => "username"
    );
    my $password_text = new HTMLInput(
        _type => "text",
        _name => "password",
        _id => "password"
    );
    my $submit = new HTMLInput(
        _type => "button",
        _value => "Register",
        _onClick => "submitForm('register');"
    );

    $form -> ContentLoader(
        Content => $container5_home
    );
    $form -> ContentLoader(
        Content => $div_main_registration
    );
    $form -> ContentLoader(
        Content => $hidden_input
    );
    $form -> ContentLoader(
        Content => "<center> E-mail"
    );
    $form -> ContentLoader(
        Content => $username_text
    );
    $form -> ContentLoader(
        Content => "<br><br> Password "
    );
    $form -> ContentLoader(
        Content => $password_text
    );
    $form -> ContentLoader(
        Content => "<br><br>"
    );
    $form -> ContentLoader(
        Content => $submit
    );

    $form -> ContentLoader(
        Content => "</center>"
    );

    return($form);
}
sub div_main_registration_Packager {
    my $div_main_registration = new HTMLDiv(
        _id => "div_main_registration",
        _class => "div_main_registration",
        _style => "border:solid blue 0px;width:100%;margin-top:20px;text-align:center;"
    );
    $div_main_registration -> ContentLoader(
        Content => "<p>It seems you are new user. Please register with the form below.</p>"
    );
    return($div_main_registration);
}
sub UnkPrinter {
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

1;