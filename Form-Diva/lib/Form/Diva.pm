use strict;
use warnings;
no  warnings 'uninitialized';

package Form::Diva;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->{class}   = $class;
    unless( $self->{input_class}) { die 'input_class is required.' }
    unless( $self->{label_class}) { die 'label_class is required.' }
    $self->{FormMap} = &_expandshortcuts( $self->{form} );
    return $self;
}

# specification calls for single letter shortcuts on all fields
# these all need to expand to the long form.
sub _expandshortcuts {
    my %DivaShortMap = (
        qw /
            n name t type i id e extra x extra l label p placeholder
            d default v values c class/
    );
    my %DivaLongMap = map { $DivaShortMap{$_}, $_ } keys(%DivaShortMap);
    my $FormMap = shift;
    foreach my $formfield ( @{$FormMap} ) {
        foreach my $tag ( keys %{$formfield} ) {
            if ( $DivaShortMap{$tag} ) {
                $formfield->{ $DivaShortMap{$tag} }
                    = delete $formfield->{$tag};
            }
        }
        unless ( $formfield->{type} ) { $formfield->{type} = 'text'  }
        unless ( $formfield->{name} ) { die "fields must have names" }     
    }
    return $FormMap;
}

# given a field returns either the default field class="string"
# or the field specific one
sub _class_input {
    my $self   = shift;
    my $field  = shift;
    my $fclass = $field->{class} || '';
    if   ($fclass) { return qq!class="$fclass"! }
    else           { return qq!class="$self->{input_class}"! }
}

sub _field_bits {
    my $self      = shift;
    my $field_ref = shift;
    my $data      = shift;
    my %in        = %{$field_ref};
    my %out       = ();
    my $fname     = $in{name};
    $out{extra} = $in{extra};    # extra is taken literally
    $out{input_class} = $self->_class_input($field_ref);
    $out{name}        = qq!name="$in{name}"!;
    $out{id}          = $in{id} ? qq!id="$in{id}"! : qq!id="$in{name}"!;

    if ( lc( $in{type} ) eq 'textarea' ) {
        $out{type}     = 'textarea';
        $out{textarea} = 1;
    }
    else {
        $out{type}     = qq!type="$in{type}"!;
        $out{textarea} = 0;
    }
    if ($data) {
        $out{placeholder} = '';
        $out{rawvalue} = $data->{$fname} || '';
    }
    else {
        if ( $in{placeholder} ) {
            $out{placeholder} = qq!placeholder="$in{placeholder}"!;
        }
        else { $out{placeholder} = '' }
        if   ( $in{default} ) { $out{rawvalue} = $in{default}; }
        else                  { $out{rawvalue} = '' }
    }
    $out{value} = qq!value="$out{rawvalue}"!;
    return %out;
}

sub _label {
    my $self        = shift;
    my $field       = shift;
    my $fname       = $field->{name};
    my $label_class = $self->{label_class};
    my $label_tag   = $field->{label} || ucfirst($fname);
    return
          qq|<LABEL for="$fname" class="$label_class">|
        . qq|$label_tag</LABEL>|;
}

sub _input {
    my $self  = shift;
    my $field = shift;
    my $data  = shift;
    my %B     = $self->_field_bits( $field, $data );
    my $input = '';
    if ( $B{textarea} ) {
        $input = qq|<TEXTAREA $B{name} $B{id}"
        $B{input_class} $B{placeholder} $B{extra} >$B{rawvalue}</TEXTAREA>|;
    }
    else {
        $input .= qq|<INPUT $B{type} $B{name} $B{id}"
        $B{input_class} $B{placeholder} $B{extra} $B{value} >|;
    }
    $input =~ s/\s+/ /g;     # remove extra whitespace.
    $input =~ s/\s+>/>/g;    # cleanup space before closing >
    return $input;
}

# Note need to check default field and disable disabled fields
# this needs to be implemented after data is being handled because
# default is irrelevant if there is data.

sub _radiocheck {            # field, input_class, data;
    my $self        = shift;
    my $field       = shift;
    my $input_class = shift;
    my $data        = shift;
    my $output      = '';
    my $extra       = $field->{extra} || "";
    my $default     = $field->{default}
        ? do {
        if   ($data) {undef}
        else         { $field->{default} }
        }
        : undef;
    foreach my $val ( @{ $field->{values} } ) {
        my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
        my $checked = '';
        if    ( $data    eq $value ) { $checked = 'checked ' }
        elsif ( $default eq $value ) { $checked = 'checked ' }
        $output
            .= qq!<input type="$field->{type}" $input_class $extra name="$field->{name}" value="$value" $checked>$v_lab<br>\n!;
    }
    return $output;
}

sub generate {
    my $self = shift;
    my $data = shift;
    unless ( keys %{$data} ) { $data = undef }
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $input = undef;
        if ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck(
                $field,
                $self->_class_input($field),
                $data->{ $field->{name} }
            );
        }
        else {
            $input = $self->_input( $field, $data );
        }
        $input =~ s/  +/ /g;     # remove extra whitespace.
        $input =~ s/\s+>/>/g;    # cleanup space before closing >
        push @generated,
            {
            label => $self->_label($field),
            input => $input
            };
    }
    return \@generated;
}

1;

=head1 NAME
 
Form::Diva - Generate HTML5 form label and input fields

=head1 SYNOPSIS
 
Generate Form Label and Input Tags from a simple data structure.
Simplify form code in your views without replacing it without a lot of even
uglier Perl Code in your Controller. 

Drastically reduce form clutter in your View Templates with small Data Structures.

=head1 DESCRIPTION

Create a new instance of Form::Diva from an array_ref of hash_refs describing each field of your form. The most common attributes have a single letter abbreviation to reduce typing.

Return a similar structure of the label and input attributes ready for inclusion in a web page by your templating system.

=head1 USAGE

 use Form::Diva;

 my $diva = Form::Diva->new(
    label_class => 'col-sm-3 control-label',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        { qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'myradio', type => 'radio', default => 1,
           values => [ "1:Yes", "2:No", "3:Maybe" ] },   
    ],
 );

 my $fields = $diva->generate;
 my $filledfields = $diva->generate( $hashref_of_data );

Once you send this to your stash or directly to the templating system the form might look like:

  <form class="form-horizontal well col-md-8" role="form"
   method="post" action="/form1" name="DIVA1" >  

  <div class="form-group">
In Template Toolkit:
  [% FOREACH field IN fields %] {
    [% field.label %]
    <div class="col-sm-8">
        [% field.input %]
    </div>
  [% END %]
Or in Mojo::Template
  % foreach my $field (@$fields) {
    <%== $field->{'label'} %>
    <div class="col-sm-8">
        <%== $field->{'input'} %>
    </div>
 % }

 </div>

 <div class="form-group">
    <div class="col-sm-offset-3 col-sm-8">
      <input type="submit" class="btn btn-large btn-primary" 
      name="submit" value="submit_me" >&nbsp;
    </div>
 </div>
 </form>

=head1 METHODS

=head2 new

Create a new object from a Data Structure ().

=head2 generate

When called without arguments returns the blank form with placeholders and value set to default or null if there is no default.

When provided an optional hashref it sets values based on the hashref and suppresses placeholder. 

The data returned is in the form of an array reference with a hash reference for the label and input attributes.

=head2 spawn

Not yet implemented. The same as generate but specify which fields to include and or change field order.

=head1 The Form::Diva Data Structure

 { label_class => 'some class in your css',
   input_class => 'some class in your css',
   form        => [
        { name => 'some_field_name', ... },
        ...
   ],
 }

=head2 label_class, input_class

Specify the contents the label's class attribute and the input's class attribute. The input_class can be over-ridden for a single field by using the c/class attribute in a field definition.

=head2 form

Form::Diva knows about the most frequently needed attributes in HTML5 label and input tags. The attribute extra is provided to handle valueless attributes like required and attributes that are not explicitly supported by Form::Diva. Each supported tag has a single character shortcut. When no values in a field definition require spaces the shortcuts make it extremely compact to describe a field using qw/. 

The only required value in a field definition is name. When not specified type defaults to text. 

Multivalued fields are not currently supported, but may be in the future.

Supported attributes and their shortcuts

 c       class        over-ride input_class for this field
 d       default      sets value for an empty form
 e,x     extra        any other attribute(s)
 i       id           defaults to name
 l       label        defaults to ucfirst(name)
 n       name         field name -- required
 p       placeholder  placeholder to show in an empty form
 t       type         checkbox, radio, textarea or any input types
                      type defaults to text input type
 v       values       for radio and checkbox inputs only

=head2 extra attribute

The contents of extra are placed verbatim in the input tag. Use for HTML5 attributes that have no value such as disabled and any of the other attributes you may wish to use in your forms that have not been implemented, you will need to type out attribute="something" if it is not valueluess.

=head3 Common Attributes with no Value

B<disabled>, B<readonly>, B<required>

Should be placed in the extra field when needed.

=head2 TextArea, Radio Button and CheckBox

TextArea fields are handled the same as the text type. Radio Buttons and CheckBoxes are very similar to each other, and take an extra attribute 'values'. Form::Diva does not currently support multi-valued Radio Buttons and CheckBoxes, if a record's data has multiple values only one will be selected in the form.

=head3 values

For CheckBoxes the values attribute is just the values of the check boxes. If value is set and matches one of the values it will be checked. 

  { type => 'checkbox',
    name => 'mycheckbox',
    values => [ 'Miami', 'Chicago', 'London', 'Paris' ] }

For RadioButtons the values attribute is a number and text seperated by a colon. When the form is submitted just the number will be returned.

  { t => 'radio',
    n => 'myradio',
    v => [ '1:New York', '2:Philadelphia', '3:Boston' ] }

=head1 AUTHOR

John Karr, C<brainbuz at brainbuz.org>

=head1 BUGS

Please report any bugs or feature requests through the web interface at L<https://bitbucket.org/brainbuz/formdiva/issues>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Form::Diva

You can also look for information at:

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2014 John Karr.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut

1;

