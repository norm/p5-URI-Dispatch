use Modern::Perl;
use URI::Dispatch;
use Test::More			tests => 4;



# simple matches
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/user/', 'user' );
    $dispatch->add( '/', 'homepage' );
    
    my $handler = $dispatch->handler( '/' );
    ok( $handler eq 'homepage' );
    
    $handler = $dispatch->handler( '/user/' );
    ok( $handler eq 'user' );
    
    $handler = $dispatch->handler( '/blah/' );
    ok( !defined $handler );
}

# multiple routes returns the first match
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/', 'homepage' );
    $dispatch->add( '/', 'homepage-alt' );
    
    my $handler = $dispatch->handler( '/' );
    ok( $handler eq 'homepage' );
}
