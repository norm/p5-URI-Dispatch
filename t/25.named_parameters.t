use Modern::Perl;
use Ouch            qw( :traditional );
use Test::More      tests => 8;
use URI::Dispatch;



# named parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/user/#user:id', 'user' );
    
    my( $handler, $options ) = $dispatch->handler( '/user/5' );
    ok( $handler eq 'user' );
    is_deeply( $options, { keys => {user => '5'}, args => ['5'] } );
    
}

# not confused by matching names
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year:year', 'by-year' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011' );
    ok( $handler eq 'by-year' );
    is_deeply( $options, { keys => {year => '2011'}, args => ['2011'] } );
}

# multiple named parameters
{
    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/#year:year/#month:month/#day:day', 'calendar' );
    
    my( $handler, $options ) = $dispatch->handler( '/2011/05/18' );
    ok( $handler eq 'calendar' );
    is_deeply(
            $options,
            { 
                keys => {
                    year  => '2011',
                    month => '05',
                    day   => '18',
                },
                args => [ '2011', '05', '18', ],
            } 
        );
}

# cannot mix positional with named parameters
{
    my $dispatch = URI::Dispatch->new();
    
    try {
        $dispatch->add( '/#year:year/#month/#day', 'calendar' );
    };
    ok( catch 'cannot_mix' );
}
{
    my $dispatch = URI::Dispatch->new();
    
    try {
        $dispatch->add( '/#year/#month/#day:day', 'calendar' );
    };
    ok( catch 'cannot_mix' );
}
