package MooseX::Types::Path::Class;

use warnings FATAL => 'all';
use strict;

use Path::Class ();
# TODO: export dir() and file() from Path::Class? (maybe)

use MooseX::Types
    -declare => [qw( Dir File ExistingDir ExistingFile NonExistingDir NonExistingFile )];

use MooseX::Types::Moose qw(Str ArrayRef);

class_type('Path::Class::Dir');
class_type('Path::Class::File');

subtype Dir, as 'Path::Class::Dir';
subtype File, as 'Path::Class::File';

subtype ExistingFile, as File, where { -e $_->stringify },
    message { "File '$_' must exist." };

subtype NonExistingFile, as File, where { !-e $_->stringify },
    message { "File '$_' must not exist." };

subtype ExistingDir, as Dir,
    where { -e $_->stringify && -d $_->stringify },
    message { "Directory '$_' must exist" };

subtype NonExistingDir, as Dir,
    where { !-e $_->stringify },
    message { "Directory '$_' not must exist" };

for my $type ( 'Path::Class::Dir', Dir, ExistingDir, NonExistingDir ) {
    coerce $type,
        from Str,      via { Path::Class::Dir->new($_) },
        from ArrayRef, via { Path::Class::Dir->new(@$_) };
}

for my $type ( 'Path::Class::File', File, ExistingFile, NonExistingFile ) {
    coerce $type,
        from Str,      via { Path::Class::File->new($_) },
        from ArrayRef, via { Path::Class::File->new(@$_) };
}

# optionally add Getopt option type
eval { require MooseX::Getopt; };
if ( !$@ ) {
    MooseX::Getopt::OptionTypeMap->add_option_type_to_map( $_, '=s', )
        for (
            'Path::Class::Dir', 'Path::Class::File',
            Dir,                 File,
            ExistingDir,         ExistingFile,
            NonExistingFile,     NonExistingDir,
        );
}

1;
__END__


=head1 NAME

MooseX::Types::Path::Class - A Path::Class type library for Moose


=head1 SYNOPSIS

  package MyClass;
  use Moose;
  use MooseX::Types::Path::Class;
  with 'MooseX::Getopt';  # optional

  has 'dir' => (
      is       => 'ro',
      isa      => 'Path::Class::Dir',
      required => 1,
      coerce   => 1,
  );

  has 'file' => (
      is       => 'ro',
      isa      => 'Path::Class::File',
      required => 1,
      coerce   => 1,
  );

  # these attributes are coerced to the
  # appropriate Path::Class objects
  MyClass->new( dir => '/some/directory/', file => '/some/file' );


=head1 DESCRIPTION

MooseX::Types::Path::Class creates common L<Moose> types,
coercions and option specifications useful for dealing
with L<Path::Class> objects as L<Moose> attributes.

Coercions (see L<Moose::Util::TypeConstraints>) are made
from both 'Str' and 'ArrayRef' to both L<Path::Class::Dir> and
L<Path::Class::File> objects.  If you have L<MooseX::Getopt> installed,
the Getopt option type ("=s") will be added for both
L<Path::Class::Dir> and L<Path::Class::File>.


=head1 EXPORTS

None of these are exported by default.  They are provided via
L<MooseX::Types>.

=over

=item Dir, File

These exports can be used instead of the full class names.  Example:

  package MyClass;
  use Moose;
  use MooseX::Types::Path::Class qw(Dir File);

  has 'dir' => (
      is       => 'ro',
      isa      => Dir,
      required => 1,
      coerce   => 1,
  );

  has 'file' => (
      is       => 'ro',
      isa      => File,
      required => 1,
      coerce   => 1,
  );

Note that there are no quotes around Dir or File.

=item ExistingDir, ExistingFile

Like File and Dir, but the files or directories must exist on disk
when the type is checked, and the object on disk must be a file (for
ExistingFile) or directory (for ExistingDir).

At no point will this library attempt to coerce a path into existence
by creating directories or files.  The coercions for ExistingDir and ExistingFile
simply coerce 'Str' and 'ArrayRef' to L<Path::Class> objects.

These types do rely on I/O.  The case could be made that this makes them not
suitable to be called "types".  Consider a file that gets removed after the
ExistingFile type is checked.  This can be a source of difficult to find bugs
(you've been warned).  Often, you're going to check (either explicitly or implicitly)
whether a path exists at the point where you're actually going to use it
anyway.  In such cases you may be better off using the Dir or File type and then
later (say, in some method) check for existence yourself instead of using these types
constraints that you can't really trust to remain true indefinitely.


=item NonExistingDir, NonExistingFile

Like File and Dir, but the path must not exist on disk
when the type is checked.

At no point will this library attempt to coerce a path into non-existence
by removing directories or files.  The coercions for NonExistingDir and NonExistingFile
simply coerce 'Str' and 'ArrayRef' to L<Path::Class> objects.

The same caveats regarding I/O for the Existing* types above apply here as well.

=item is_$type($value)

Returns true or false based on whether $value passes the constraint for $type.

=item to_$type($value)

Attempts to coerce $value to the given $type.  Returns the coerced value
or false if the coercion failed.

=back


=head1 SEE ALSO

L<MooseX::Types::Path::Class::MoreCoercions>


=head1 DEPENDENCIES

L<Moose>, L<MooseX::Types>, L<Path::Class>


=head1 BUGS AND LIMITATIONS

If you find a bug please either email the author, or add
the bug to cpan-RT L<http://rt.cpan.org>.


=head1 AUTHOR

Todd Hepler  C<< <thepler@employees.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007-2009, Todd Hepler C<< <thepler@employees.org> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


