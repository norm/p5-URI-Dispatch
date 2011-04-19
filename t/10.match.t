use Modern::Perl;
use URI::Dispatch;
use Test::More      tests => 3;



# simple matches
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/user/', 'user' );
    $dispatch->add( '/', 'homepage' );
    
    my( $handler, $args ) = $dispatch->handler( '/' );
    ok( $handler eq 'homepage' );
    
    ( $handler, $args ) = $dispatch->handler( '/user/' );
    ok( $handler eq 'user' );
    
    ( $handler, $args ) = $dispatch->handler( '/blah/' );
    ok( !defined $handler );
}
