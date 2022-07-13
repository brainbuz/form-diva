# NAME

Form::Diva - Generate HTML5 form label and input fields

# VERSION

version 1.04

# DESCRIPTION

Generate Form Label and Input Tags from a simple data structure.
Simplify form code in your views without replacing it without a lot of even
uglier Perl Code in your Controller.

# VERSION

Version 1.04

# USAGE

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
       hidden => [
         { name => 'control_no' }
       ]
    );

    my $fields = $diva->generate;
    my $filledfields = $diva->generate( $hashref_of_data );
    my $filledfields = $diva->generate( $DBIx::Class::Row );

Once you send this to your stash or directly to the templating system the form might look like:

     <form class="form-horizontal col-md-8" role="form"
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

# METHODS

## new

Create a new object from a Data Structure ().

## generate

When called without arguments returns the blank form with placeholders and value set to default or null if there is no default.

When provided an optional hashref of data it sets values based on the hashref and suppresses placeholder. A DBIx::Class::Row may be used in place of the hashref.

A second optional hashref may be passed to override the values list for select, checkbox and radio button inputs, see below.

The data returned is in the form of an array reference where each element of the array three  hashreferences: label, input and comment.

## prefill

The prefill method differs from generate in that while it sets values for data provided to it, but leaves defaults and placeholders for fields without a value. The syntax is the same as for generate and providing no data will provide a blank form as generate would. Internally it temporarily overrides the default value of the fields for which data is provided leaving existing default or placeholder values on the remaining fields.

## hidden

Generate the hidden fields in the data structure. The generated hidden tags are returned as a singular block of text since no formatting is applicable and they just need to be included somewhere in the form.

    my $diva = Form::Diva->new(
       ...
       form        => [ ... ],
       hidden => [ { name => 'control_no' }, { name => 'reviewer', type = 'number'} ],
    );

    $c->stash( hidden => $diva->hidden( $data_hashref ) );

## clone

Copy a Form::Diva object optionally modifying some of the values in the copy. This is useful if you have several similar forms, define a form diva object with all of the fields, then make copies for the shorter forms.

    my $newdiva = $diva->clone({
       neworder => [ qw / A B c D E /],
       newhidden   => [ 'X' , 'Zebra'] });

### Arguments to clone

Arguments to clone are passed as a hashref. All of the arguments are optional since if omitted the original object is just copied. The arguments are:

#### neworder, newhidden

Array refs of the names of fields in your form. This will let you re-order fields and you do not need to include all of the fields. You cannot define new fields on a clone but you can omit them. You can change fields between hidden and visible, fields originally defined as hidden become text fields, unless you defined a type for them.

#### input\_class, label\_class

Change these values for your copy. Note that id\_base cannot be changed in the clone process.

## datavalues

Returns the data that would be used by generate as an array\_ref of hashrefs for: name, type, label, and value. This applies only to visible fields, if you want hidden fields you'll need to clone the object and make them visible.

There are two optional parameters: 'moredata' and 'skipempty'.

skipempty suppresses returning fields with no data. Without data skipempty returns an empty array\_ref, this might become an exception in the future.

moredata returns all internal data defined for each row including placeholder and default which are meaningless when there is data.
When these parameters are used without data it is necessary to pass undef in place of data.

    my $datavalues = $diva->datavalues( undef, 'moredata');
    say $datavalues->[2]{name};

    my $dv = $diva->datavalues( { user => 'me', password => 'secret' } );
    foreach my $row ( @{$dv} ) { say "$row->{name} = $row->{value}" }
      output : user = me
               password = secret

# The Form::Diva Data Structure

    { label_class => 'some class in your css',
      input_class => 'some class in your css',
      form        => [
           { name => 'some_field_name', ... },
           ...
      ],
      hidden       => [
           { name => 'some_hidden_field_name', ... },
           ...
      ],
    }

## label\_class, input\_class

Specify the contents the label's class attribute and the input's class attribute. The input\_class can be over-ridden for a single field by using the c/class attribute in a field definition.

If you need to access these two values in code they both have accessor methods $diva->label\_class() and $diva>input\_class();.

## id\_base

Sets the base from which autogenerated field ids are created. This defaults to 'formdiva\_'.

## form

Form::Diva knows about the most frequently needed attributes in HTML5 label and input tags. The attribute extra is provided to handle valueless attributes like required and attributes that are not explicitly supported by Form::Diva. Each supported tag has a single character shortcut. When no values in a field definition require spaces the shortcuts make it extremely compact to describe a field using qw/.

The only required value in a field definition is name. When not specified type defaults to text. Comments may be added to fields and are returned by generate as a seperate hash element. Comments on hidden fields are not returned by the hidden method.

Multivalued fields (checkboxes, select) are not currently supported, but may be in the future.

Supported attributes and their shortcuts

    c       class        over-ride input_class for this field
    lc      label_class  over-ride label_class for this field
    d       default      sets value for an empty form
    e,x     extra        any other attribute(s)
    i       id           defaults to formdiva_$field{name}
    l       label        defaults to ucfirst(name)
    n       name         field name -- required
    p       placeholder  placeholder to show in an empty form
    t       type         checkbox, radio, textarea or any input types
                         type defaults to text input type
    v       values       for radio, select and checkbox inputs only

            comment      comment has no shortcut and is not included in the input tag
                         or label it is instead returned as a seperate element by generate.

## extra attribute

The contents of extra are placed verbatim in the input tag. Use for HTML5 attributes that have no value such as disabled and any of the other attributes you may wish to use in your forms that have not been implemented, you will need to type out attribute="something" if it is not valueluess.

### Common Attributes with no Value

**disabled**, **readonly**, **required**

Should be placed in the extra field when needed.

## hidden fields

Hidden fields are specified with a seperate hash reference in the data structure. They use a subset of the same options as normal fields. The relevant options are name (which is mandatory), id, extra, and default. If you define type for a hidden field and then later in a clone make it visible it will be that type, otherwise it would be text.

## TextArea

TextArea fields are treated by the Form::Diva structure as a regular input type, but <TextArea... is what gets generated.

## Select Radio Button and CheckBox

Select, Radio Button and CheckBox Input types are similar to each other, and take an extra attribute 'values'. Form::Diva does not currently support multi-valued.

### values

For CheckBoxes the values attribute is just the values of the check boxes. If value is set and matches one of the values it will be checked.

    { type => 'checkbox',
      name => 'mycheckbox',
      values => [ 'Miami', 'Chicago', 'London', 'Paris' ] }

For RadioButtons the values attribute is a number and text seperated by a colon. When the form is submitted just the number will be returned.

    { t => 'radio',
      n => 'myradio',
      v => [ '1:New York', '2:Philadelphia', '3:Boston' ] }

For Select inputs there are two forms of values. If the value itself and the label are the same then values is just a list of those values which will also be used as the label. The second form requires the value and the label to be seperated by a colon.

    values => [ qw / pineapple persimmon nectarine / ]
    or
    values => [ 'item1:Pineapple', 'item2:Georgia Peach', 'item3:Naval Orange']

When using the first form of values the label is not CamelCased or otherwise changed, if you want that you'll need to use the second form.

### Over-Riding Values

It is possible to override values by passing an extra argument to generate. The override argument is a hashref `{ field_name => [ values ...] } `. It is even possible to create your initial object with an empty values lists and pass a list every time you generate the form.

# Miscellaneous

## id Tags

Form::Diva strives to put an id tag everywhere it can. When you define a field you can specify an id, if you don't Form::Diva generates one by prepending 'formdiva\_' to the value for name.

For the elements of CheckBox, Radio or Select the id tag is generated as $field\_id\_$option\_name. To insure uniqueness it is lowercased, and in the case of a duplicate a number is appended. This insures that the generated ids are unique but predictable.

## Errors

Form::Diva doesn't do a huge amount of Error Checking or validation, but it does check that you don't use a field more than once on both `new` and `clone` methods.

# FAQ

## Why Doesn't Form::Diva generate an entire form?

Form::Diva is intented to be used with Templating systems, the HTML generation is best left to the templating system. Telling form diva what you need in the Form Tag and whether you prefer to use a submit input or a button instead and what goes in them is only going to make it more complex, and make your application less readable because you will have replaced HTML with abstract perl code but not saved any space or labor. If you really want to generate your whole form in Perl, there are plenty of other Form Modules on CPAN.

## Where do I use Form::Diva? in my Model, View or Controller?

Wherever works best for you. Think of it as preparing your data for the View.

# SEE ALSO

Here are a few other Form Modules on CPAN: [HTML::Form::Fu](https://metacpan.org/pod/HTML%3A%3AForm%3A%3AFu), [Form::Sensible](https://metacpan.org/pod/Form%3A%3ASensible), [Form::Factory](https://metacpan.org/pod/Form%3A%3AFactory), [Form::Toolkit](https://metacpan.org/pod/Form%3A%3AToolkit)

Form::Diva is meant to be used with a Templating System. [Template::Toolkit](https://metacpan.org/pod/Template%3A%3AToolkit) is the default templating system for Catalyst and Dancer. [Template::Alloy](https://metacpan.org/pod/Template%3A%3AAlloy) is a drop in replacement for TemplateToolkit. [Mojo::Template](https://metacpan.org/pod/Mojo%3A%3ATemplate) is a Perl reimplemenation of ERB and the default for [Mojolicious](https://metacpan.org/pod/Mojolicious).

# AUTHOR

John Karr, `brainbuz at brainbuz.org`

# BUGS

Please report any bugs or feature requests through the web interface at [https://github.com/brainbuz/form-diva/issues](https://github.com/brainbuz/form-diva/issues). I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Form::Diva

You can also look for information at:

# LICENSE AND COPYRIGHT

Copyright 2014-2019 John Karr.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

# AUTHOR

John Karr <brainbuz@brainbuz.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by John Karr.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
