use Modern::Perl;
use Test::More      tests => 32;
use URI::Dispatch;



# standard parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/user/#id', 'user' );
    
    my( $handler, $captures ) = $dispatch->handler( '/user/5' );
    ok( $handler eq 'user' );
    is_deeply( $captures, [ '5' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/user/bob' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/user/5a' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/bookmark/#hex', 'bookmark' );
    
    my( $handler, $captures ) = $dispatch->handler( '/bookmark/C5d4b0' );
    ok( $handler eq 'bookmark' );
    is_deeply( $captures, [ 'C5d4b0' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/user/abcdefg' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/user/dead-beef' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year', 'by-year' );
    
    my( $handler, $captures ) = $dispatch->handler( '/2011' );
    ok( $handler eq 'by-year' );
    is_deeply( $captures, [ '2011' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/bob' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/201' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/20111' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#month', 'by-month' );
    
    my( $handler, $captures ) = $dispatch->handler( '/05' );
    ok( $handler eq 'by-month' );
    is_deeply( $captures, [ '05' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/13' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/111' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/00' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#day', 'by-day' );
    
    my( $handler, $captures ) = $dispatch->handler( '/31' );
    ok( $handler eq 'by-day' );
    is_deeply( $captures, [ '31' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/32' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/00' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year/#month/#day', 'calendar' );
    
    my( $handler, $captures ) = $dispatch->handler( '/2011/05/18' );
    ok( $handler eq 'calendar' );
    is_deeply( $captures, [ '2011', '05', '18' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/2011/05' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/bookmark/#slug', 'bookmark' );
    
    my( $handler, $captures ) = $dispatch->handler( '/bookmark/1' );
    ok( $handler eq 'bookmark' );
    is_deeply( $captures, [ '1' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/bookmark/link-summary' );
    ok( $handler eq 'bookmark' );
    is_deeply( $captures, [ 'link-summary' ] );
    
    ( $handler, $captures ) = $dispatch->handler( '/bookmark/' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/bookmark/NO-CAPS' );
    ok( !defined $handler );
    
    ( $handler, $captures ) = $dispatch->handler( '/bookmark/no_underscore' );
    ok( !defined $handler );
}
