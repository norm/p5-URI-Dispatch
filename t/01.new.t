use Modern::Perl;
use Test::More      tests => 1;
use URI::Dispatch;



my $dispatch = URI::Dispatch->new();
isa_ok( $dispatch, 'URI::Dispatch' );
