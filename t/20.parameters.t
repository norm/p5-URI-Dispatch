use Modern::Perl;
use URI::Dispatch;
use Test::More      tests => 28;



# standard parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/user/#id', 'user' );
    
    my( $handler, $options ) = $dispatch->handler( '/user/5' );
    ok( $handler eq 'user' );
    is_deeply( $options->{'args'}, [ '5' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/user/bob' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/user/5a' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year', 'by-year' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011' );
    ok( $handler eq 'by-year' );
    is_deeply( $options->{'args'}, [ '2011' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/bob' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/201' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/20111' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#month', 'by-month' );
    
    my( $handler, $options ) = $dispatch->handler( '/05' );
    ok( $handler eq 'by-month' );
    is_deeply( $options->{'args'}, [ '05' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/13' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/111' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/00' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#day', 'by-day' );
    
    my( $handler, $options ) = $dispatch->handler( '/31' );
    ok( $handler eq 'by-day' );
    is_deeply( $options->{'args'}, [ '31' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/32' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/00' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year/#month/#day', 'calendar' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011/05/18' );
    ok( $handler eq 'calendar' );
    is_deeply( $options->{'args'}, [ '2011', '05', '18' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/2011/05' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/bookmark/#slug', 'bookmark' );
    
    my( $handler, $options ) = $dispatch->handler( '/bookmark/1' );
    ok( $handler eq 'bookmark' );
    is_deeply( $options->{'args'}, [ '1' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/bookmark/link-summary' );
    ok( $handler eq 'bookmark' );
    is_deeply( $options->{'args'}, [ 'link-summary' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/bookmark/' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/bookmark/NO-CAPS' );
    ok( !defined $handler );
    
    ( $handler, $options ) = $dispatch->handler( '/bookmark/no_underscore' );
    ok( !defined $handler );
}
