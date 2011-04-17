use Modern::Perl;
use URI::Dispatch;
use Test::More          tests => 12;



# parameters do not require slashes
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year-#month-#day', 'calendar' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011-05-18' );
    ok( $handler eq 'calendar' );
    is_deeply( $options->{'args'}, [ '2011', '05', '18' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/2011-05-bob' );
    ok( !defined $handler );
}

# optional parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year/#month[/#day]', 'calendar' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011/05/18' );
    ok( $handler eq 'calendar' );
    is_deeply( $options->{'args'}, [ '2011', '05', '18' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/2011/05' );
    ok( $handler eq 'calendar' );
    is_deeply( $options->{'args'}, [ '2011', '05', ] );
}

# matching anything
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#id/#*', 'article' );
    
    my( $handler, $options ) = $dispatch->handler( '/5/any/old/thing' );
    ok( $handler eq 'article' );
    is_deeply( $options->{'args'}, [ '5', 'any/old/thing' ] );
    
    ( $handler, $options ) = $dispatch->handler( '/5' );
    ok( !defined $handler );
}
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#id:id/#extra:*', 'article' );
    
    my( $handler, $options ) = $dispatch->handler( '/5/any/old/thing' );
    ok( $handler eq 'article' );
    is_deeply(
            $options,
            {
                args => [ '5', 'any/old/thing' ],
                keys => {
                    id    => '5',
                    extra => 'any/old/thing',
                },
            }
        );
}
