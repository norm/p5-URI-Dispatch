use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 22;
use URI::Dispatch;

{
    package Homepage;
    use Test::More;
    sub get { pass('homepage'); }
}
{
    package Profile;
    use Test::More;
    sub get {
        my $options = shift;
        is_deeply( $options, [ '5' ] );
    }
}
{
    package Calendar;
    use Test::More;
    sub get {
        my $options = shift;
        state $run  = 0;

        if ( $run ) {
            is_deeply( $options, [ '2010', '12' ] );
        }
        else {
            is_deeply( $options, [ '2010', '12', '31' ] );
            $run++;
        }
    }
}
{
    package Article;
    use Test::More;
    sub get {
        my $options = shift;
        state $run  = 0;

        if ( $run ) {
            is_deeply(
                $options,
                {
                    title => 'the-unbearable-lightness-of-articles',
                },
            );
        }
        else {
            is_deeply( $options, [] );
            $run++;
        }
    }
}
{
    package Category;
    use Test::More;
    sub get {
        my $options = shift;
        is_deeply( $options, { name => 'the-face' } );
    }
}
{
    package Section;
    use Test::More;
    sub get {
        my $options = shift;
        state $run  = 0;
        
        if ( $run ) {
            is_deeply( $options, [ 'first', 'the-beginning' ] );
        }
        else {
            is_deeply( $options, [] );
            $run++;
        }
    }
}
{
    package Tag;
    use Test::More;
    sub get {
        my $options = shift;
        state $run  = 0;
        
        if ( $run ) {
            is_deeply(
                $options,
                {
                    tag => 'perl',
                    sub => 'best-practices',
                },
            );
        }
        else {
            is_deeply( $options, { tag => 'perl' } );
            $run++;
        }
    }
}
{
    package AZ::Page;
    use Test::More;
    sub get {
        my $options = shift;
        is_deeply( $options, { letter => 'c' } );
    }
}


my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'Homepage' );
$dispatch->add( '/user/#id',                    'Profile'  );
$dispatch->add( '/#year/#month[/#day]',         'Calendar' );
$dispatch->add( '/article/[#title:slug]',       'Article'  );
$dispatch->add( '/category/#name:slug',         'Category' );
$dispatch->add( '[/#slug]/section/[#slug]',     'Section'  );
$dispatch->add( '/tag/#tag:slug/[#sub:slug]',   'Tag'      );
$dispatch->add( '/list/#letter:([a-z])',        'AZ::Page' );

$dispatch->dispatch( '/' );
$dispatch->dispatch( '/user/5' );
$dispatch->dispatch( '/2010/12/31' );
$dispatch->dispatch( '/2010/12' );
$dispatch->dispatch( '/article/' );
$dispatch->dispatch( '/article/the-unbearable-lightness-of-articles' );
$dispatch->dispatch( '/category/the-face' );
$dispatch->dispatch( '/section/' );
$dispatch->dispatch( '/first/section/the-beginning' );
$dispatch->dispatch( '/tag/perl/' );
$dispatch->dispatch( '/tag/perl/best-practices' );
$dispatch->dispatch( '/list/c' );

try { $dispatch->dispatch( '/broken' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/user/norm' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/2010/48' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/article/FACE' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/category/FACE' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/section/FACE' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/tag/' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/tag/FACE' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/list/0' ); };
ok( catch 404 );

try { $dispatch->dispatch( '/list/ab' ); };
ok( catch 404 );

