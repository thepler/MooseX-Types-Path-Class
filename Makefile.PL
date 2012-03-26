
use warnings FATAL => 'all';
use strict;
use inc::Module::Install 0.75;
use Module::Install::ExtraTests;

name     'MooseX-Types-Path-Class';
all_from 'lib/MooseX/Types/Path/Class.pm';
license  'perl';

# prereqs
requires 'Class::MOP'     => 0;
requires 'Moose'          => '0.39';
requires 'MooseX::Types'  => '0.04';
requires 'Path::Class'    => '0.16';

# things the tests need
test_requires 'Test::More'      => '0.88';
test_requires 'Test::Exception' => '0.27';

#auto_provides;

#auto_install;

extra_tests();

WriteAll;

