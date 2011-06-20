use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 18;
use URI::Dispatch;



my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'App::Homepage', 'homepage' );
$dispatch->add( '/user/#id',                    'App::Profile',  'profile'  );
$dispatch->add( '/#year/#month[/#day]',         'App::Calendar', 'calendar' );
$dispatch->add( '/article/[#title:slug]',       'App::Article',  'article'  );
$dispatch->add( '/category/#name:slug',         'App::Category', 'category' );
$dispatch->add( '[/#slug]/section/[#slug]',     'App::Section',  'section'  );
$dispatch->add( '/tag/#tag:slug[/#sub:slug]',   'App::Tag',      'tag'      );
$dispatch->add( '/list/#letter:([a-z])',        'App::AZ'                   );
$dispatch->add( '/#0[page-#id/]',               'App::Paged'                );

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
    my $url = $dispatch->url( 'App::AZ', { letter => 's' } );
    ok( $url eq '/list/s' );
}

# named optional parameters
{
    my $url = $dispatch->url( 'article', {} );
    ok( $url eq '/article/' );
}

# empty parameters
{
    my $url = $dispatch->url( 'App::Paged' );
    ok( $url eq '/' );
    
    $url = $dispatch->url( 'App::Paged', [ 5 ] );
    ok( $url eq '/page-5/' );
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
