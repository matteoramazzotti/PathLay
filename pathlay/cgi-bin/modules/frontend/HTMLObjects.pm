use strict;
#use warnings;
use Data::Dumper;



package HTMLStyleLink;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<link",
        _end => ">",
        _rel => "",
        _href => "",
        @_
    };
    bless($self,$class);
    return($self);
}
sub PrintStyleLink {
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $rel = $self -> {_rel};
    my $href =  $self -> {_href};

    print(
        $begin.
        " rel=\"".$rel."\"".
        " href=\"".$href."\"".
        $end.
        "\n"
    );
}

package HTMLStyle;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<style>",
        _end => "</style>",
        _src => "",
        _type => "",
        _css => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub StyleLinksLoader {
    my $self = shift;

    my %args = (
        Content => {},
        @_
    );
    my $new_object = $args{Content};

    if (ref($new_object) ne "ARRAY") {
        push(@{$self -> {_css}},$new_object);
        return();
    }
    if (ref($new_object) eq "ARRAY") {
        @{$self -> {_css}} = @$new_object;
        return();
    }
}
sub PrintStyle {
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $src = $self -> {_src};
    my $type = $self -> {_type};

    $begin =~ s/>$/ src=\"$src\">/;
    $begin =~ s/>$/ type=\"$type\">/;

    #print $begin."\n";
    foreach my $link (@{$self -> {_css}}) {
        $link -> PrintStyleLink();
    }
    #print $end."\n";

}

package HTMLScript;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<script>",
        _end => "</script>",
        _src => "",
        _type => "",
        _variables => [],
        _functions => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub FunctionsLoader{

        my $self = shift;
        my %args = (
            Content => {},
            @_
        );
        my $new_object = $args{Content};


        if (ref($new_object) ne "ARRAY") {
            push(@{$self -> {_functions}},$new_object);
            return();
        }
        if (ref($new_object) eq "ARRAY") {

            @{$self -> {_functions}} = @$new_object;
            return();
        }
}
sub VariablesLoader{
    my $self = shift;
    my %args = (
        Content => {},
        VariableID => "jsvariable",
        @_
    );
    my $content = $args{Content};
    my $varid = $args{VariableID};

    if (ref($content) eq "SCALAR") {
        push(@{$self -> {_variables}},$content);
        return();
    }
    if (ref($content) eq "ARRAY") {
        @{$self -> {_variables}} = $content;
        return();
    }
    if (ref($content) eq "HASH") {
        #print ref($content)."\n";
        my $var;
        foreach my $main_id (sort keys %$content) {
            $var = "$varid\['$main_id'\] = [";
            foreach my $linked_id (sort keys %{$content -> {$main_id}}) {
                $var .= "\"".$linked_id."\",";
            }
            $var =~ s/,$//;
            $var .= "];";
            push(@{$self -> {_variables}},$var);
        }
        return();
    }
}
sub PrintScript {
    my $self = shift;
    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $src = $self -> {_src};
    my $type = $self -> {_type};

    if ($type ne "") {
        $begin =~ s/>$/ type=\"$type\">/;
    }
    if ($src ne "") {
        $begin =~ s/>$/ src=\"$src\">/;
    }


    foreach my $function (@{$self -> {_functions}}) {
        $function -> PrintScriptSrc();
    }
    print $begin."\n";
    foreach my $variable (@{$self -> {_variables}}) {
        print $variable."\n";
    }
    print $end."\n";
}

package HTMLScriptSrc;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<script>",
        _end => "</script>",
        _type => "",
        _src => "",
        @_
    };
    bless($self,$class);
    return($self);
}
sub PrintScriptSrc {
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $type = $self -> {_type};
    my $src =  $self -> {_src};

    $begin =~ s/>$/ src=\"$src\">/;
    $begin =~ s/>$/ type=\"$type\">/;

    print $begin;
    print $end."\n";
}

package HTMLSelect;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<select>",
        _end => "</select>",
        _name => "",
        _id => "",
        _onchange => "",
        _title => "",
        _options => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub LoadOption{
    my $self = shift;
    my %args = (
        HTMLSelectOption => {},
        @_
    );
    my $option = $args{HTMLSelectOption};
    if (ref($option) eq "HTMLSelectOption") {
        push(@{$self -> {_options}},$option);
        return();
    }
    if (ref($option) eq "ARRAY") {
        @{$self -> {_options}} = @$option;
        return();
    }
    if (ref($option) eq "HASH") {
        foreach my $id (sort keys %$option){
            my $real_option = $option -> {$id} -> {option};
            push(@{$self -> {_options}},$real_option);
        }
        return();
    }
}
sub PrintSelect{
    my $self = shift;

    my $begin = $self -> {_begin};
    my $name = $self -> {_name};
    my $id = $self -> {_id};
    my $title = $self -> {_title};
    my $onchange = $self -> {_onchange};
    my $class = $self -> {_class};
    my $end = $self -> {_end};
    my $style = "";
    if ($self -> {_style}) {
        $style = $self -> {_style};
    }

    $begin =~ s/>$/ name=\"$name\">/;
    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ class=\"$class\">/;
    $begin =~ s/>$/ onchange=\"$onchange\">/;
    $begin =~ s/>$/ title=\"$title\">/;
    $begin =~ s/>$/ style=\"$style\">/;

    print $begin."\n";
    #foreach my $option (sort { $a->{_text} cmp $b->{_text} } @{$self -> {_options}}) {
        #print "".$option."\n";
        #print " ";
        #$option -> PrintSelectOption();
        #}
    foreach my $option (@{$self -> {_options}}) {
        $option -> PrintSelectOption();
    }
    print $end."\n";
}

sub SortSelectByAlphabet {

    my $self = shift;
    my @sorted_array = sort{ $a->{_text} cmp $b->{_text} } @{$self -> {_options}};
    @{$self -> {_options}} = @sorted_array;
}

sub SortSelectByNumeric {

    my $self = shift;
    my @sorted_array = sort{ $a->{_text} <=> $b->{_text} } @{$self -> {_options}};
    @{$self -> {_options}} = @sorted_array;
}

sub AppendOptionOnTop {

    my $self = shift;
    my %args = (
        HTMLSelectOption => {},
        @_
    );
    unshift(@{$self->{_options}},$args{HTMLSelectOption});
}

package HTMLSelectOption;
sub new {

    my $class = shift;
    my $self = {
        _begin => "<option>",
        _end => "</option>",
        _value => "",
        _text => "",
        _title => "",
        _disabled => 0,
        @_
    };
    bless($self,$class);
    return($self);
}
sub PrintSelectOption {
    my $self = shift;
    my $begin = $self -> {_begin};
    my $value = $self -> {_value};
    my $text = $self -> {_text};
    my $title = $self -> {_title};
    my $end = $self -> {_end};
    my $checked = $self -> {_checked};
    my $disabled = $self -> {_disabled};

    $begin =~ s/>$/ title=\"$title\">/;
    $begin =~ s/>$/ value=\"$value\">/;
    if ($disabled == 1) {
        $begin =~ s/>$/ disabled>/;
    }
    print $begin.$text.$end."\n";
}

package HTMLTextArea;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<textarea>",
        _end => "</textarea>",
        _id => "",
        _name => "",
        #_rows => 10,
        #_cols => 20,
        _wrap => "off",
        _style => "",
        @_
    };
    #<textarea id="gene_data" name="gene_data" rows="20" cols="100" wrap="off" style="background-color: #e6faff; display:none;"></textarea>
    bless($self,$class);
    return($self);
}
sub PrintTextArea{

    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $id = $self -> {_id};
    my $name = $self -> {_name};
    my $rows = "";
    my $cols = "";
    if ($self -> {_rows}) {
        $rows = $self -> {_rows};
    }
    if ($self -> {_cols}) {
        $cols = $self -> {_cols};
    }
    my $wrap = $self -> {_wrap};
    my $style = $self -> {_style};

    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ name=\"$name\">/;
    $begin =~ s/>$/ rows=\"$rows\">/;
    $begin =~ s/>$/ cols=\"$cols\">/;
    $begin =~ s/>$/ wrap=\"$wrap\">/;
    $begin =~ s/>$/ style=\"$style\">/;

    print $begin;
    print $end."\n";
}

package HTMLFont;

sub new{

    my $class = shift;
    my $self = {
        _begin => "<font>",
        _end => "</font>",
        _id => "",
        _name => "",
        _text => "",
        _style => "",
        _onclick => "",
        _color => "",
        @_
    };
    bless($self,$class);
    return($self);
}

sub PrintFont {
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $id = $self -> {_id};
    my $name = $self -> {_name};
    my $class = $self -> {_class};
    my $text = $self -> {_text};
    my $style = $self -> {_style};
    my $color = $self -> {_color};
    my $size = $self -> {_size};
    my $onclick = $self -> {_onclick};

    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ name=\"$name\">/;
    $begin =~ s/>$/ class=\"$class\">/;
    $begin =~ s/>$/ style=\"$style\">/;
    $begin =~ s/>$/ color=\"$color\">/;
    $begin =~ s/>$/ size=\"$size\">/;
    $begin =~ s/>$/ onclick=\"$onclick\">/;

    print $begin;
    print $text;
    print $end."\n";
}

package HTMLul;
sub new{
    my $class = shift;
    my $self = {
        _begin => "<ul>",
        _end => "</ul>",
        _id => "",
        _name => "",
        _class => "",
        _style => "list-style-type: none;padding: 0;margin: 0;",
        _content => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub ContentLoader{

    my $self = shift;
    my %args = (
        Content => {},
        @_
    );
    my $li = $args{Content};
    if (ref($li) eq "HTMLli") {
        push(@{$self -> {_content}},$li);
    }
}
sub ulPrinter{
    my $self = shift;
    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $id = $self -> {_id};
    my $style = $self -> {_style};
    my $class = $self -> {_class};
    my @content = @{$self -> {_content}};

    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ class=\"$class\">/;
    $begin =~ s/>$/ style=\"$style\">/;
    print $begin;
    foreach (@content) {
        $_ -> liPrinter();
        print "\n";
    }
    print $end;
}

package HTMLli;
sub new{
    my $class = shift;
    my $self = {
        _begin => "<li>",
        _end => "</li>",
        _class => "",
        _id => "",
        _name => "",
        _text => "ciccio",
        _style => "",
        _content => [],
        #_style => "border-radius: 10px;border: 1px solid #ddd;margin: 5px;background-color: #f6f6f6;padding: 12px;text-decoration: none;font-size: 15px;color: black;display: inline-block;position: relative;",
        @_
    };
    bless($self,$class);
    return($self);
}
sub ContentLoader{

    my $self = shift;
    my %args = (
        Content => {},
        @_
    );
    push(@{$self -> {_content}},$args{Content});
}
sub liPrinter{
    my $self = shift;
    my $begin = $self -> {_begin};
    my $id = $self -> {_id};
    my $name = $self -> {_name};
    my $end = $self -> {_end};
    my $text = $self -> {_text};
    my $style = $self -> {_style};
    my $class = $self -> {_class};
    my @content = @{$self -> {_content}};

    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ class=\"$class\">/;
    $begin =~ s/>$/ style=\"$style\">/;
    print $begin;
    print $text."<input type='hidden' name='$name' value='$id\@'/>";
    foreach (@content) {
        $_ -> PrintInput();
    }
    print $end."\n";
}

package HTMLInput;
sub new {

    my $class = shift;
    my $self = {
        _begin => "<input",
        _end => "/>",
        _id => "",
        _class => "",
        _type => "",
        _value => "",
        _onClick => "",
        _title => "",
        _style => "",
        _readonly => "",
        _name => "",
        _checked => 0,
        _size => 1,
        _disabled => 0,
        @_
    };
    bless($self,$class);
    return($self);
}
sub PrintInput {
    my $self = shift;
    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $id = $self -> {_id};
    my $class = $self -> {_class};
    my $name = $self -> {_name};
    my $type = $self -> {_type};
    my $value = $self -> {_value};
    my $onclick = $self -> {_onClick}; #####
    my $title = $self -> {_title};
    my $style = $self -> {_style};
    my $readonly = $self -> {_readonly};
    my $checked = $self -> {_checked};
    my $size = $self -> {_size};
    my $onkeyup = $self -> {_onkeyup};
    my $placeholder = $self -> {_placeholder};
    my $step = $self -> {_step};
    my $disabled = $self -> {_disabled};

    print $begin.
    " id=\"".$id."\"".
    " class=\"".$class."\"".
    " name=\"".$name."\"".
    " type=\"".$type."\"".
    " value=\"".$value."\"";
    if ($disabled == 1) {
        print " disabled";
    }
    if ($onclick ne "") {
        print " onClick=\"".$onclick."\"";
    }
    if ($onkeyup) {
        print " onkeyup=\"".$onkeyup."\"";
    }
    if ($placeholder) {
        print " placeholder=\"".$placeholder."\"";
    }
    if ($step) {
        print " step=\"$step\"";
    }
    if ($size > 1) {
        print " size=\"".$size."\"";
    }
    print " title=\"".$title."\"".
    " style=\"".$style."\"";
    if ($checked == 1) {
        print " checked";
    }
    if ($readonly ne "") {
        print " readonly=\"".$readonly."\"";
        print $end;
    } else {
        print $end;
    }
}
package HTMLImg;
sub new{
    my $class = shift;
    my $self = {
        _begin => "<img",
        _end => "/>",
        _id => "",
        _name => "",
        _src => "",
        _border => "",
        _usemap => "",
        _onClick => "",
        _onmouseover => "",
        _onmouseout => "",
        _height => "",
        _width => " ",
        _alt => "",
        _style => "",
        _class => "",
        _title => "",
        @_
    };
    bless($self,$class);
    return($self);
}
sub PrintImg{
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $id = $self -> {_id};
    my $name = $self -> {_name};
    my $src = $self -> {_src};
    my $border = $self -> {_border};
    my $usemap = $self -> {_usemap};
    my $onclick = $self -> {_onClick};
    my $ondblclick = $self -> {_ondblclick};
    my $onmouseover = $self -> {_onmouseover};
    my $onmouseout = $self -> {_onmouseout};
    my $height = $self -> {_height};
    my $width = $self -> {_width};
    my $alt = $self -> {_alt};
    my $class = $self -> {_class};
    my $style = $self -> {_style};
    my $title = $self -> {_title};



    print(
        $begin.
        " id=\"".$id."\"".
        " name=\"".$name."\"".
        " class=\"".$class."\"".
        " alt=\"".$alt."\"".
        " src=\"".$src."\"".
        " border=\"".$border."\"".
        " height=\"".$height."\"".
        " width=\"".$width."\"".   ########
        " usemap=\"".$usemap."\"".
        " onClick=\"".$onclick."\"".
        " ondblclick=\"".$ondblclick."\"".
        " onmouseover=\"".$onmouseover."\"".
        " onmouseout=\"".$onmouseout."\"".
        " style=\"".$style."\"".
        " title=\"".$title."\"".
        $end.
        "\n"
    );
}

package HTMLDiv;
sub new {
    my $class = shift;
    my $self = {
        _begin => "<div>",
        _end => "</div>",
        _style => "",
        _name => "",
        _id => "",
        _content => [],
        _class => "",
        _contenteditable => "",
        @_
    };
    bless($self,$class);
    return($self);
}
sub ContentLoader {

    my $self = shift;
    my %args = (
        Content => {},
        @_
    );
    my $new_object = $args{Content};


    if (ref($new_object) ne "ARRAY") {
        push(@{$self -> {_content}},$new_object);
        return();
    }
    if (ref($new_object) eq "ARRAY") {
        @{$self -> {_content}} = $new_object;
        return();
    }
    if (!ref($new_object)) {
        push(@{$self -> {_content}},$new_object);
        return();
    }
}
sub PrintDiv{
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $style = $self -> {_style};
    my $id = $self -> {_id};
    my @contents = @{$self -> {_content}};
    my $class = $self -> {_class};
    my $name = $self -> {_name};
    my $content_editable = $self -> {_contenteditable};

    $begin =~ s/>$/ id=\"$id\">/;
    if ($name ne "") {
        $begin =~ s/>$/ name=\"$name\">/;

    }
    if ($style ne "") {
        $begin =~ s/>$/ style=\"$style\">/;
    }
    if ($class ne "") {
        $begin =~ s/>$/ class=\"$class\">/;
    }
    if ($content_editable ne "") {
        $begin =~ s/>$/ contentEditable=\"$content_editable\">/;
    }
    print $begin."\n";
    foreach my $content (@{$self -> {_content}}) {
        #print "".$option."\n";
        print  " ";
        #$content -> PrintSelectOption();
        #print ref($content)."\n";
        if (ref($content) eq "HTMLDiv" || ref($content) eq "MapDiv") {

            $content -> PrintDiv();
            #print STDERR "Printing Div ".$content -> {_id}."\n";
            next;
        }
        if (ref($content) eq "HTMLImg") {
            $content -> PrintImg();
        }
        if (ref($content) eq "HTMLSelect") {
            $content -> PrintSelect();
        }
        if (ref($content) eq "HTMLInput") {
            $content -> PrintInput();
        }
        if (ref($content) eq "HTMLTable") {
            $content -> PrintTable();
        }
        if (ref($content) eq "HTMLTextArea") {
            $content -> PrintTextArea();
        }
        if (ref($content) eq "HTMLul") {
            $content -> ulPrinter();
        }
        if (ref($content) eq "HTMLFont") {
            $content -> PrintFont();
        }
        if (!ref($content)) {
            print $content."\n";
        }
    }
    print $end."\n";
}

package HTMLTable;
sub new{
    my $class = shift;
    my $self = {
        _begin => "<table>",
        _end => "</table>",
        _width => "",
        _border => "",
        _style => "",
        _content => []
    };
    bless($self,$class);
    return($self);
}
sub PrintTable {
    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $width = $self -> {_width};
    my $border = $self -> {_border};
    my @content = @{$self -> {_content}};

    $begin =~ s/>$/ width=\"$width\">/;
    $begin =~ s/>$/ border=\"$border\">/;

    print $begin."\n";
    foreach my $content (@{$self -> {_content}}) {
        print " ";
        #$content -> PrintSelectOption();
        #print ref($content)."\n";
        if (ref($content) eq "HTMLDiv") {
            $content -> PrintDiv();
        }
        if (ref($content) eq "HTMLImg") {
            $content -> PrintImg();
        }
        if (ref($content) eq "HTMLSelect") {
            $content -> PrintSelect();
        }
        if (ref($content) eq "HTMLInput") {
            $content -> PrintInput();
        }
        if (ref($content) eq "HTMLTable") {
            $content -> PrintTable();
        }
        if (ref($content) eq "HTMLTableRow") {
            $content -> PrintTableRow();
        }
        if (!ref($content)) {
            print $content."\n";
        }
    }
    print $end."\n";
}
sub ContentLoader{

    my $self = shift;
    my %args = (
        @_
    );
    my $content = $args{Content};
    if (ref($content) eq "ARRAY") {
        @{$self -> {_content}} = @$content;
    }
    if (ref($content) eq "HTMLTableRow") {
        push(@{$self -> {_content}},$content);
    }
    if (!ref($content)) {
        push(@{$self -> {_content}},$content);
    }
}

package HTMLTableRow;
sub new{

    my $class = shift;
    my $self = {
        _begin => "<tr>",
        _end => "</tr>",
        _bgcolor => "",
        _width => "80%",
        _align => "",
        _colspan => "",
        _content => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub ContentLoader{

    my $self = shift;
    my %args = (
        @_
    );
    my $content = $args{Content};
    if (ref($content) eq "ARRAY") {
        @{$self -> {_content}} = @$content;
    }
    if (ref($content) eq "HTMLTableData") {
        push(@{$self -> {_content}},$content);
    }
    if (!ref($content)) {
        push(@{$self -> {_content}},$content);
    }
}
sub PrintTableRow {
    my $self = shift;
    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $align = $self -> {_align};
    my $colspan = $self -> {_colspan};

    $begin =~ s/>/ align=\"$align\">/;
    $begin =~ s/>/ colspan=\"$colspan\">/;

    print($begin."\n");
    foreach my $content (@{$self -> {_content}}) {
        if (ref($content) eq "HTMLDiv") {
            $content -> PrintDiv();
        }
        if (ref($content) eq "HTMLImg") {
            $content -> PrintImg();
        }
        if (ref($content) eq "HTMLSelect") {
            $content -> PrintSelect();
        }
        if (ref($content) eq "HTMLInput") {
            $content -> PrintInput();
        }
        if (ref($content) eq "HTMLTable") {
            $content -> PrintTable();
        }
        if (ref($content) eq "HTMLTableData") {
            $content -> PrintTableData();
        }
        if (ref($content) eq "HTMLTableRow") {
            $content -> RowPrint();
        }
        if (!ref($content)) {
            print $content."\n";
        }
    }
    print($end."\n");
}

package HTMLTableData;
sub new {

    my $class = shift;
    my $self = {
        _begin => "<td>",
        _end => "</td>",
        _align => "",
        _colspan => "",
        _content => [],
        @_
    };
    bless($self,$class);
    return($self);
}
sub ContentLoader{

    my $self = shift;
    my %args = (
        Content => {},
        @_
    );
    my $content = $args{Content};
    if (ref($content) eq "ARRAY") {
        @{$self -> {_content}} = @$content;
        return();
    }
    if (ref($content) eq "HTMLTableData") {
        push(@{$self -> {_content}},$content);
        return();
    }
    if (!ref($content)) {
        push(@{$self -> {_content}},$content);
        return();
    }
    push(@{$self -> {_content}},$content);
}
sub PrintTableData{
    my $self = shift;
    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $align = $self -> {_align};
    my $colspan = $self -> {_colspan};

    $begin =~ s/>/ align=\"$align\">/;
    $begin =~ s/>/ colspan=\"$colspan\">/;

    print($begin."\n");
    foreach my $content (@{$self -> {_content}}) {
        if (ref($content) eq "HTMLDiv") {
            $content -> PrintDiv();
        }
        if (ref($content) eq "HTMLImg") {
            $content -> PrintImg();
        }
        if (ref($content) eq "HTMLSelect") {
            $content -> PrintSelect();
        }
        if (ref($content) eq "HTMLInput") {
            $content -> PrintInput();
        }
        if (ref($content) eq "HTMLTable") {
            $content -> PrintTable();
        }
        if (ref($content) eq "HTMLTableData") {
            $content -> PrintTableData();
        }
        if (ref($content) eq "HTMLTableRow") {
            $content -> RowPrint();
        }
        if (!ref($content)) {
            print $content."\n";
        }
    }
    print($end."\n");
}

package HTMLForm;

sub new {

    my $class = shift;
    my $self = {
        _begin => "<form>",
        _end => "</form>",
        _style => "",
        _id => "",
        _content => [],
        _class => "",
        _method => "post",
        _target => "_blank",
        _name => "",
        _action => "",
        _enctype => "",
        _autocomplete => "off",
        @_
    };

    bless($self,$class);
    return($self);
}
sub PrintForm {

    my $self = shift;

    my $begin = $self -> {_begin};
    my $end = $self -> {_end};
    my $style = $self -> {_style};
    my $id = $self -> {_id};
    my $method = $self -> {_method};
    my $target = $self -> {_target};
    my $name = $self -> {_name};
    my $action = $self -> {_action};
    my @contents = @{$self -> {_content}};
    my $class = $self -> {_class};
    my $enctype = $self -> {_enctype};
    my $autocomplete = $self -> {_autocomplete};

    $begin =~ s/>$/ id=\"$id\">/;
    $begin =~ s/>$/ name=\"$name\">/;
    $begin =~ s/>$/ action=\"$action\">/;
    $begin =~ s/>$/ method=\"$method\">/;
    $begin =~ s/>$/ target=\"$target\">/;
    $begin =~ s/>$/ enctype=\"$enctype\">/;
    $begin =~ s/>$/ autocomplete=\"$autocomplete\">/;
    if ($style ne "") {
        $begin =~ s/>$/ style=\"$style\">/;
    }
    if ($class ne "") {
        $begin =~ s/>$/ class=\"$class\">/;
    }

    print $begin."\n";
    foreach my $content (@{$self -> {_content}}) {
        #print "".$option."\n";
        print " ";
        #$content -> PrintSelectOption();
        #print ref($content)."\n";
        if (ref($content) eq "HTMLDiv" || ref($content) eq "MapDiv") {

            $content -> PrintDiv();
            #print STDERR "Printing Div ".$content -> {_id}."\n";
            next;
        }
        if (ref($content) eq "HTMLImg") {
            $content -> PrintImg();
        }
        if (ref($content) eq "HTMLSelect") {
            $content -> PrintSelect();
        }
        if (ref($content) eq "HTMLInput") {
            $content -> PrintInput();
        }
        if (ref($content) eq "HTMLTable") {
            $content -> PrintTable();
        }
        if (ref($content) eq "HTMLTextArea") {
            $content -> PrintTextArea();
        }
        if (ref($content) eq "HTMLFont") {
            $content -> PrintFont();
        }
        if (!ref($content)) {
            print $content."\n";
        }
    }
    print $end."\n";
}
sub ContentLoader {

    my $self = shift;
    my %args = (
        Content => {},
        @_
    );
    my $new_object = $args{Content};


    if (ref($new_object) ne "ARRAY") {
        push(@{$self -> {_content}},$new_object);
        return();
    }
    if (ref($new_object) eq "ARRAY") {
        @{$self -> {_content}} = $new_object;
        return();
    }
    if (!ref($new_object)) {
        push(@{$self -> {_content}},$new_object);
        return();
    }
}


1;
