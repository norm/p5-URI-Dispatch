use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 6;
use URI::Dispatch;

{
    package Homepage;
    use Test::More;
    sub get { pass('homepage'); }
}
{
    package Calendar;
    use Test::More;
    sub get { pass('homepage'); }
}
{
    package Default;
    use Test::More;
    sub get {
        my $options = shift;
        state $run  = 0;
        
        if ( $run ) {
            is_deeply( $options, [ 'icky/icky', ] );
        }
        else {
            is_deeply( $options, [ 'flibble/', ] );
            $run++;
        }
    }
}
{
    package Never;
    use Test::More;
    sub get { fail('never get here'); }
}


my $dispatch = URI::Dispatch->new();

$dispatch->add( '/',                        'Homepage' );
$dispatch->add( '/#year/[#month/][#day/]',  'Calendar' );
$dispatch->add( '/#*',                      'Default'  );
$dispatch->add( '/#*',                      'Never'    );
$dispatch->add( '/2010/',                   'Never'    );

$dispatch->dispatch( '/' );
$dispatch->dispatch( '/2010/' );
$dispatch->dispatch( '/flibble/' );
$dispatch->dispatch( '/icky/icky' );
$dispatch->dispatch( '/' );
$dispatch->dispatch( '/icky/icky' );
