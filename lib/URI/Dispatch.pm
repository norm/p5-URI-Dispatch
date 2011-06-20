use Modern::Perl;
use MooseX::Declare;

class URI::Dispatch {
    use Ouch        qw( :traditional );
    use URI::Dispatch::Route;
    use version;
    our $VERSION = qv( 1.3 );
    
    has routes => (
        isa     => 'HashRef',
        is      => 'ro',
        builder => 'build_routes',
    );
    has routes_ordered => (
        isa     => 'ArrayRef',
        is      => 'ro',
        builder => 'build_routes_ordered',
    );
    
    method build_routes {
        return {};
    }
    method build_routes_ordered {
        return [];
    }
    
    
    method add ( $path, $handler, $name? ) {
        my %args = (
                handler => $handler,
                path    => $path,
            );
        
        $args{'name'} = $name
            if defined $name;
        
        my $key   = $name // $handler;
        my $route = URI::Dispatch::Route->new( %args );
        
        $self->routes->{ $key } = $route;
        
        push @{ $self->routes_ordered }, {
            handler => $handler,
            route   => $route,
        };
    }
    method dispatch ( $argument, @extra_args ) {
        my $method = 'get';
        my $path   = $argument;
        my $request;
        
        if ( 'Plack::Request' eq ref $argument ) {
            $method  = lc $argument->method;
            $path    = $argument->path;
            $request = $argument;
        }
        
        my( $handler, $options ) = $self->handler( $path );
        
        throw 404
            unless defined $handler;
        
        my $sub = "${handler}::${method}";
        my @args;
        
        push @args, @extra_args
            if @extra_args;
        push @args, $request
            if defined $request;
        push @args, $options;
        
        {
            no strict 'refs';
            return $sub->( @args );
        }
    }
    method handler ( $path ) {
        foreach my $option ( @{ $self->routes_ordered } ) {
            my $route   = $option->{'route'};
            my $handler = $option->{'handler'};
            my $options = $route->match_path( $path );
            
            return( $handler, $options )
                if defined $options;
        }
        
        return;
    }
    method url ( $name, $args? ) {
        my $route = $self->routes->{ $name };
        return unless defined $route;
        
        return $route->reverse_path( $args );
    }

=pod

=head1 NAME

URI::Dispatch - determine which code to execute based upon path

=head1 SYNOPSIS

    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/', 'Homepage' );
    
    # common matching patterns are available
    $dispatch->add( '/user/#id', 'Profile' );
    
    # optional parts of the path
    $dispatch->add( '/article/#id[/#slug]', 'Article' );
    
    # named captures
    $dispatch->add( '/tag/#name:slug', 'Tag' );
    
    # use a custom regexp
    $dispatch->add( '/a-z/#letter:([a-z])', 'AZ::Page' );
    
    # pass in a path and determine what matches
    my( $handler, $options) 
        = $dispatch->handler( '/article/5/awesome-article' );
    # handler='Article', options=['5','awesome-article']
    
    # automatically calls Tag::get (as that matches the path)
    my $response = $dispatch->dispatch( '/tag/perl' );
    
    # construct paths
    my $uri = $dispatch->url( 'article', [ '1', 'some-article' ] );
    # uri='/article/1/some-article'

=head1 METHODS

=head2 add( I<path>, I<handler> [, I<name>] )

Add I<path> that can be handled by I<handler>, with an optional symbolic
I<name>. The I<$path> string will be matched literally, except for the special
markers described below. They have been specially chosen because they are not
legal URI path characters, so should never break your actual chosen URI
scheme.

=over

=item captures

To capture part of the path for later use, mark it with a hash (#) and the 
capture type. Builtin types are:

=over 12

=item B<id>

matches digits

=item B<hex>

matches digits and the letters a, b, c, d, e, and f case insensitively

=item B<slug>

matches lowercase letters, digits and hyphens

=item B<year>

matches four digits

=item B<month>

matches numbers 01 through 12

=item B<day>

matches numbers 01 through 31

=item B<date>

matches year, month and day separated by dashes

=item B<hour>

matches numbers 00 through 23

=item B<minute>

matches numbers 00 through 59

=item B<second>

matches numbers 00 through 59

=item B<time>

matches hour, minute and second separated by any of colons, periods or dashes

=item B<*>

matches anything

=item B<0>

matches nothing, an empty match; useful for binding to things like homepage
matches with optional parameters (eg. '/#0[page-#id/]').

=item (I<regexp>)

matches a custom regular expression

=back

=item named captures

Rather than relying on the order of the captures, they can be named. The
name goes immediately after the hash (#), is formed of "word" characters
(alphanumeric plus underscore) and is followed by a colon and then the
capture type. Some examples:

=over

=item *

#id:id

=item *

#title:slug

=item *

#letter:([a-z])

=back

=item optional segments

To mark part of the path as optional, surround it with square brackets. 
Optional segments cannot be nested.

=back

=head3 Limitations

Different handlers having the same path and multiple handlers having different
paths will result in unpredictable behaviour.

=head2 handler( I<path> )

Determine which handler should be used for the given I<path>. The handlers
are examined in the same order that they were given with C<add()>.

Returns the I<handler> string, and either an array of the captured elements,
or a hash if the captures were named. For example, this code:
    
    $dispatch->add( '/article/#key:id/#title:slug', 'article' );
    my( $handler, $captures )
        = $dispatch->handler( '/article/5/awesome-article' );

would return C<$captures> set to:

    {
        key   => '5',
        title => 'awesome-article',
    }

=head2 dispatch( I<path or request>, [ ... ] )

Call the handler that matches the given argument, which can either be a
simple string that represents a path, or it can be a L<Plack::Request>
object.  The handlers are examined in the same order that they were given 
with C<add()>.

The handler is interpreted as a class, and the HTTP method is the subroutine
within the class to call.

Any extra arguments to C<dispatch()> are passed to the handler routine first,
then the reference to the array of captures or hash of named captures.

=head3 path string

When C<dispatch()> is called with a simple string, the method is assumed
to be an HTTP GET. For example:
 
    $dispatch->add( '/tag/#name:slug', 'Tags::SingleTag' );
    my $response = $dispatch->dispatch( '/tag/perl', $obj );

would set C<$response> to the return value of

    Tags::SingleTag::get( $obj, { name => 'perl' } );

=head3 Plack::Request

When C<dispatch()> is called with a L<Plack::Request> object, the path and
method are determined automatically; and the object is passed to the handler
before the captures, but after any extra arguments to dispatch(). For example:
    
    $dispatch->add( '/tag/#name:slug', 'Tags::SingleTag' );
    
    # $env contains the environment of an HTTP DELETE 
    # request on /tag/perl
    my $request  = Plack::Request->new( $env );
    my $response = $dispatch->dispatch( $request, $obj );

would set C<$response> to the return value of

    Tags::SingleTag::delete( $obj, $request, { name => 'perl' } );

=head2 url( I<handler or name>, I<$arguments> )

Build a path that would be accepted by the route specified by I<name> (or
I<handler> if it wasn't added with a name parameter). When the path contains
captures, you can pass them as an arrayref (or hashref if they are named
captures).

The I<$arguments> are tested to ensure they would match. If they would not,
an L<Ouch> exception is thrown. This can be caught in your code like so:

    use Ouch qw( :traditional );
    
    ...
    
    $dispatch->add( '/list/#letter:([a-z])', 'az-page' );
    try { $url = $dispatch->url( 'az-page', 'too big' ); };
    if ( catch 'wrong_input' ) {
        # handle errors
    }

=head1 EXCEPTIONS

=over

=item cannot_mix

Named and positional captures cannot be mixed. An attempt to do so will
throw this exception.

=item unmatched_brackets

Thrown if the opening and closing square brackets representing optional
segments of a path do not match up.

=item wrong_input

A provided argument when calling B<url()> will not match the relevant
capture type.

=item args_short

Not enough arguments are provided when calling B<url()>.

=item args_wrong

The wrong type of arguments (arrayref versus hashref) were provided when
calling B<url()>.

=item no_param

An unknown builtin parameter type was requested.

=item 404

No handler was found for the path when calling C<dispatch()>.

=back

=head1 AUTHOR

Mark Norman Francis, L<norm@cackhanded.net>.

=head1 COPYRIGHT AND LICENSE

Copyright 2011 Mark Norman Francis.

This program is free software, you can redistribute it and/or modify it under the terms of the Artistic License version 2.0.

=cut

}
