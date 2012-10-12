
use warnings FATAL => 'all';
use strict;

{

    package Foo;
    use Moose;
    use MooseX::Types::Path::Class;

    has 'dir' => (
        is       => 'ro',
        isa      => 'Path::Class::Dir',
        coerce   => 1,
    );

    has 'file' => (
        is       => 'ro',
        isa      => 'Path::Class::File',
        coerce   => 1,
    );

    has 'dirs' => (
        is       => 'ro',
        isa      => 'ArrayRef[Path::Class::Dir]',
        coerce   => 1,
    );

    has 'files' => (
        is       => 'ro',
        isa      => 'ArrayRef[Path::Class::File]',
        coerce   => 1,
    );
}

{

    package Bar;
    use Moose;
    use MooseX::Types::Path::Class qw( Dir File );
    use MooseX::Types::Moose qw(ArrayRef);

    has 'dir' => (
        is       => 'ro',
        isa      => Dir,
        coerce   => 1,
    );

    has 'file' => (
        is       => 'ro',
        isa      => File,
        coerce   => 1,
    );

    has 'dirs' => (
        is       => 'ro',
        isa      => ArrayRef[Dir],
        coerce   => 1,
    );

    has 'files' => (
        is       => 'ro',
        isa      => ArrayRef[File],
        coerce   => 1,
    );
}

package main;

use Test::More;
use Path::Class;
plan tests => 10;

my $dir = dir('', 'tmp');
my $file = file('', 'tmp', 'foo');

my $check = sub {
    my $o = shift;
    isa_ok( $o->dir, 'Path::Class::Dir' );
    cmp_ok( $o->dir, 'eq', "$dir", "dir is $dir" );
    isa_ok( $o->file, 'Path::Class::File' );
    cmp_ok( $o->file, 'eq', "$file", "file is $file" );
};

for my $class (qw(Foo Bar)) {
    my $o = $class->new( dir => "$dir", file => [ '', 'tmp', 'foo' ] );
    isa_ok( $o, $class );
    $check->($o);
}



my @dirs = (dir('', 'tmp'), dir('', 'etc'));
my @files = (dir('', 'tmp', 'foo'), dir('', 'etc', 'foo'));

my $check_arrays = sub {
    my $o = shift;

    is(scalar($o->dirs), 2, '2 dirs');
    isa_ok( $_, 'Path::Class::Dir') foreach $o->dirs;
    cmp_ok( ($o->dirs)->[$_], 'eq', "$dirs[$_]", "dir is $dir" ) foreach (0 .. @dirs);

#    is(scalar($o->files), 2, '2 files');
#    isa_ok( $_, 'Path::Class::File' ) foreach $o->files;
#
#    cmp_ok( ($o->files)->[$_], 'eq', "$files[$_]", "file is $files[$_]" ) foreach (0.. @files);
};

for my $class (qw(Foo Bar)) {

my %args = (
dirs => [ map { "$_" } @dirs ],
file => [ map { [ split('/', $_->stringify) ] } @files ],
);
use Data::Dumper;
print "### constructing $class with args: ", Dumper(\%args);

    my $o = $class->new(
        dirs => [ map { "$_" } @dirs ],
#        file => [ map { [ split('/', $_->stringify) ] } @files ],
    );
    isa_ok( $o, $class );
    $check_arrays->($o);
}

