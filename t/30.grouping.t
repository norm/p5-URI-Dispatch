use Modern::Perl;
use Test::More          tests => 23;
use URI::Dispatch;



# parameters do not require slashes
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year-#month-#day', 'calendar' );
    
    my( $handler, $captures ) = $dispatch->handler( '/2011-05-18' );
    ok( $handler eq 'calendar' );
    is_deeply( $captures, [ '2011', '05', '18' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/2011-05-bob' );
    ok( !defined $handler );
}

# optional parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year/#month[/#day]', 'calendar' );
    
    my( $handler, $captures ) = $dispatch->handler( '/2011/05/18' );
    ok( $handler eq 'calendar' );
    is_deeply( $captures, [ '2011', '05', '18' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/2011/05' );
    ok( $handler eq 'calendar' );
    is_deeply( $captures, [ '2011', '05', ] );
}

# matching anything
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#id/#*', 'article' );
    
    my( $handler, $captures ) = $dispatch->handler( '/5/any/old/thing' );
    ok( $handler eq 'article' );
    is_deeply( $captures, [ '5', 'any/old/thing' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/5' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#id:id/#extra:*', 'article' );
    
    my( $handler, $captures ) = $dispatch->handler( '/5/any/old/thing' );
    ok( $handler eq 'article' );
    is_deeply(
            $captures,
            {
                id    => '5',
                extra => 'any/old/thing',
            }
        );
}

# matching custom regexp
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/about/#( me | this )', 'about-page' );
    
    my( $handler, $captures ) = $dispatch->handler( '/about/me' );
    ok( $handler eq 'about-page' );
    is_deeply( $captures, [ 'me' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/about/this' );
    ok( $handler eq 'about-page' );
    is_deeply( $captures, [ 'this' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/about/miss' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/actor/thee' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/list/#letter:([a-z])', 'az-page' );
    
    my( $handler, $captures ) = $dispatch->handler( '/list/s' );
    ok( $handler eq 'az-page' );
    is_deeply( $captures, { letter => 's' } );
    
    ( $handler, $captures ) = $dispatch->handler( '/list/sa' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/list/S' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/list/5' );
    ok( !defined $handler );
}
