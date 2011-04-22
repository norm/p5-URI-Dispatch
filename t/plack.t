use Modern::Perl;
use HTTP::Request::Common   qw( GET POST DELETE );
use Ouch                    qw( :traditional );
use Plack::Request;
use Plack::Test;
use Test::More              tests => 11;
use URI::Dispatch;

{
    package Homepage;
    
    sub get {
        my $options = shift;
        my $request = shift;
        
        return [ 200, [], [ "Hello world!" ] ];
    }
}
{
    package Article;
    use Test::More;
    
    sub get {
        my $options = shift;
        my $request = shift;
        
        return [ 200, [], [ 'Article ' . $options->{'title'} ] ];
    };
    sub post {
        my $options = shift;
        my $request = shift;
        
        ok( $request->param('comment') eq 'Meh.' );
        return [ 200, [], [ 'Comment added to ' . $options->{'title'} ] ];
    }
    sub delete {
        my $options = shift;
        my $request = shift;
        
        return [ 403, [], [ 'Cannot delete ' . $options->{'title'} ] ];
    }
}


my $dispatch = URI::Dispatch->new();
$dispatch->add( '/',                            'Homepage' );
$dispatch->add( '/article/[#title:slug]',       'Article'  );

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );
    my $response;
    
    try {
        $response = $dispatch->dispatch( $req );
    };
    if ( catch 404 ) {
        $response = [ 404, [], [ 'Bummer' ] ];
    }
    
    return $response;
};

test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET '/' );
        is $res->code, 200;
        is $res->content, 'Hello world!';
    };
test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET '/broken' );
        is $res->code, 404;
        is $res->content, 'Bummer';
    };
test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET '/article/blah' );
        is $res->code, 200;
        is $res->content, 'Article blah';
    };
test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( POST '/article/blah', [ comment => 'Meh.'] );
        is $res->code, 200;
        is $res->content, 'Comment added to blah';
    };
test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( DELETE '/article/blah' );
        is $res->code, 403;
        is $res->content, 'Cannot delete blah';
    };
