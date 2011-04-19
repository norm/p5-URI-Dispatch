use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 8;
use URI::Dispatch;



my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'homepage' );
$dispatch->add( '/user/#id',                    'profile'  );
$dispatch->add( '/#year/#month[/#day]',         'calendar' );
$dispatch->add( '/article/[#title:slug]',       'article'  );
$dispatch->add( '/list/#letter:([a-z])',        'az-page'  );

{
    try {
        my $url = $dispatch->url( 'profile', [ 'snarf' ] );
    };
    ok( catch 'wrong_input' );
}
{
    try {
        my $url = $dispatch->url( 'calendar', [ 'snarf', 'snarf' ] );
    };
    ok( catch 'wrong_input' );
    
    try {
        my $url = $dispatch->url( 'calendar', [ '2011', '05', '32' ] );
    };
    ok( catch 'wrong_input' );
    
    try {
        my $url = $dispatch->url( 'calendar', [ '5', '0' ] );
    };
    ok( catch 'wrong_input' );
    
    try {
        my $url = $dispatch->url( 'calendar', [ '2011', '05', 'snarf' ] );
    };
    ok( catch 'wrong_input' );
    
    try {
        my $url = $dispatch->url( 'calendar', [ '2011', 'snarf' ] );
    };
    ok( catch 'wrong_input' );
}
{
    try {
        my $url = $dispatch->url( 'article', { title => 'SNARF_SNARF' } );
    };
    ok( catch 'wrong_input' );
}
{
    try {
        my $url = $dispatch->url( 'az-page', { letter => 'snarf' } );
    };
    ok( catch 'wrong_input' );
}
