use Modern::Perl;
use Ouch                qw( :traditional );
use Test::More          tests => 25;
use URI::Dispatch;

{
    package Thing;
    
    sub new {
        my $class = shift;
        
        my $self  = {};
        bless $self, $class;
        
        return $self;
    }
    sub check_thing {
        return 1;
    }
}
{
    package Homepage;
    use Test::More;
    sub get {
        my $self    = shift;
        my $extra   = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        ok( $extra eq 'extra' );
        is_deeply( $options, [] );
        
        pass('homepage');
    }
}
{
    package Profile;
    use Test::More;
    sub get {
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        is_deeply( $options, [ '5' ] );
    }
}
{
    package Calendar;
    use Test::More;
    sub get {
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        state $run = 0;
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
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        state $run = 0;
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
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        is_deeply( $options, { name => 'the-face' } );
    }
}
{
    package Section;
    use Test::More;
    sub get {
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        state $run = 0;
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
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        state $run = 0;
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
        my $self    = shift;
        my $options = shift;
        return unless $self->check_thing;
        
        is_deeply( $options, { letter => 'c' } );
    }
}


my $thing = Thing->new();
ok( $thing->check_thing );

my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'Homepage' );
$dispatch->add( '/user/#id',                    'Profile'  );
$dispatch->add( '/#year/#month[/#day]',         'Calendar' );
$dispatch->add( '/article/[#title:slug]',       'Article'  );
$dispatch->add( '/category/#name:slug',         'Category' );
$dispatch->add( '[/#slug]/section/[#slug]',     'Section'  );
$dispatch->add( '/tag/#tag:slug/[#sub:slug]',   'Tag'      );
$dispatch->add( '/list/#letter:([a-z])',        'AZ::Page' );

$dispatch->dispatch( '/',                               $thing, 'extra' );
$dispatch->dispatch( '/user/5',                         $thing );
$dispatch->dispatch( '/2010/12/31',                     $thing );
$dispatch->dispatch( '/2010/12',                        $thing );
$dispatch->dispatch( '/article/',                       $thing );
$dispatch->dispatch( '/article/the-unbearable-lightness-of-articles', 
                                                        $thing );
$dispatch->dispatch( '/category/the-face',              $thing );
$dispatch->dispatch( '/section/',                       $thing );
$dispatch->dispatch( '/first/section/the-beginning',    $thing );
$dispatch->dispatch( '/tag/perl/',                      $thing );
$dispatch->dispatch( '/tag/perl/best-practices',        $thing );
$dispatch->dispatch( '/list/c',                         $thing );

try { $dispatch->dispatch( '/broken',           $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/user/norm',        $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/2010/48',          $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/article/FACE',     $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/category/FACE',    $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/section/FACE',     $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/tag/',             $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/tag/FACE',         $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/list/0',           $thing ); };
ok( catch 404 );

try { $dispatch->dispatch( '/list/ab',          $thing ); };
ok( catch 404 );
