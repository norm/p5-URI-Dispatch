use Modern::Perl;
use URI::Dispatch;
use Test::More      tests => 1;

my $dispatch = URI::Dispatch->new();
isa_ok( $dispatch, 'URI::Dispatch' );
