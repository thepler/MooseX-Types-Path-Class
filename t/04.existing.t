
{

    package Bar;
    use Moose;
    use MooseX::Types::Path::Class qw( ExistingDir ExistingFile );

    has 'dir' => (
        is       => 'ro',
        isa      => ExistingDir,
        coerce   => 1,
    );

    has 'file' => (
        is       => 'ro',
        isa      => ExistingFile,
        coerce   => 1,
    );
}

package main;

use strict;
use warnings;
use Test::More;
use Test::Fatal;

my $no_exist = '/should/not/exist';

plan skip_all => "Preconditions failed; your filesystem is strange"
    unless -d "/etc" && -e "/etc/passwd";

plan skip_all => "Preconditions failed"
    if -e $no_exist;

use MooseX::Types::Path::Class qw(ExistingFile ExistingDir);

ok is_ExistingFile(to_ExistingFile("/etc/passwd")), '/etc/passwd is an existing file';

ok is_ExistingDir(to_ExistingDir("/etc/")), '/etc/ is an existing directory';

like(
    exception { Bar->new(dir  => $no_exist); },
    qr/Directory .* must exist/,
    'no exist dir throws',
);
like(
    exception { Bar->new(file => "$no_exist/either"); },
    qr/File .* must exist/,
    'no exist file throws',
);

done_testing;

