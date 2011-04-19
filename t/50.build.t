use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 16;
use URI::Dispatch;



my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'homepage' );
$dispatch->add( '/user/#id',                    'profile'  );
$dispatch->add( '/#year/#month[/#day]',         'calendar' );
$dispatch->add( '/article/[#title:slug]',       'article'  );
$dispatch->add( '/category/#name:slug',         'category' );
$dispatch->add( '[/#slug]/section/[#slug]',     'section'  );
$dispatch->add( '/tag/#tag:slug[/#sub:slug]',   'tag'      );
$dispatch->add( '/list/#letter:([a-z])',        'az-page'  );

# static url
{
    my $url = $dispatch->url( 'homepage' );
    ok( $url eq '/' );
    
    $url = $dispatch->url( 'homepage', [ 'ignore', 'me' ] );
    ok( $url eq '/' );
}

# positional parameters
{
    my $url = $dispatch->url( 'profile', [ 55 ] );
    ok( $url eq '/user/55' );
}

# optional parameters
{
    my $url = $dispatch->url( 'calendar', [ '2010', '10', '05' ] );
    ok( $url eq '/2010/10/05' );
    
    $url = $dispatch->url( 'calendar', [ '2010', '10' ] );
    ok( $url eq '/2010/10' );
}
{
    my $url = $dispatch->url(
            'section',
            [ 'intro', 'something-tedious' ],
        );
    ok( $url eq '/intro/section/something-tedious' )
        or say " -> $url";
    
    $url = $dispatch->url(
            'section',
        );
    ok( $url eq '/section/' );
}

# named parameters
{
    my $url = $dispatch->url( 'article', { title => 'something-tedious' } );
    ok( $url eq '/article/something-tedious' );
}
{
    my $url = $dispatch->url( 'az-page', { letter => 's' } );
    ok( $url eq '/list/s' );
}

# named optional parameters
{
    my $url = $dispatch->url( 'article', {} );
    ok( $url eq '/article/' );
}

# named mixed parameters
{
    my $url = $dispatch->url( 'tag', { tag => 'urls' } );
    ok( $url eq '/tag/urls' );
    
    $url = $dispatch->url( 'tag', { tag => 'urls', sub => 'unread' } );
    ok( $url eq '/tag/urls/unread' );
}

# not enough parameters
{
    try {
        my $url = $dispatch->url( 'calendar', [ 2010 ] );
    };
    ok( catch 'args_short' );
    
    try {
        my $url = $dispatch->url( 'category', {} );
    };
    ok( catch 'args_short' );
}

# wrong type of parameters
{
    try {
        my $url = $dispatch->url( 'profile', { user => 5 } );
    };
    ok( catch 'args_wrong' );
    
    try {
        my $url = $dispatch->url( 'article', [ 'something-tedious' ] );
    };
    ok( catch 'args_wrong' );
}
