use strict;
use warnings;
use MooseX::Types::Path::Class qw( Dir File );
use MooseX::Types::Moose qw(ArrayRef);

# just validate directly, without using a class:
(ArrayRef[Dir])->assert_coerce(['/tmp', '/etc']);
exit;
