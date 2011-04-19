use Modern::Perl;
use MooseX::Declare;

use version;

class URI::Dispatch {
    use URI::Dispatch::Route;
    use version;
    our $VERSION = qv( 0.5 );
    
    has routes => (
        isa     => 'HashRef',
        is      => 'ro',
        builder => 'build_routes',
    );
    
    method build_routes {
        return {};
    }
    
    
    method add ( $path, $handler ) {
        my $route = URI::Dispatch::Route->new(
                path => $path,
                handler => $handler
            );
        $self->routes->{ $handler } = $route;
    }
    method handler ( $path ) {
        foreach my $handler ( keys %{ $self->routes } ) {
            my $route   = $self->routes->{ $handler };
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

=head1 NAME

B<URI::Dispatch> - determine which code to execute based upon path

=head1 SYNOPSIS

    my $dispatch = URI::Dispatch->new();
    $dispatch->add( '/', 'homepage' );
    
    # common matching patterns are available
    $dispatch->add( '/user/#id', 'profile' );
    
    # optional parts of the path
    $dispatch->add( '/article/#id[/#slug]', 'article' );
    
    # named captures
    $dispatch->add( '/tag/#name:slug', 'tag' );
    
    # use a custom regexp
    $dispatch->add( '/a-z/#letter:([a-z])', 'az-page' );
    
    # pass in a path and determine what matches
    my( $handler, $options) 
        = $dispatch->handler( '/article/5/awesome-article' );
    # handler='article', options=['5','awesome-article']
    
    # construct paths
    my $uri = $dispatch->url( 'article', [ '1', 'some-article' ] );
    # uri='/article/1/some-article'

=head1 METHODS

=head2 add( I<path>, I<handler> )

Add I<path> that can be handled by I<handler>. The path string is a literal
string, with special markers.

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

=item B<*>

matches anything

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

Adding a new path with the same I<handler> will overwrite the previous path.

Different handlers having the same path will result in unpredictable
behaviour.

=head2 handler( I<path> )

Determine which handler should be used for the given I<path>.

Returns the I<handler> string, and either an array of the captured elements,
or a hash if the captures were named. For example, this code:
    
    $dispatch->add( '/article/#key:id/#title:slug', 'article' );
    my( $handler, $captures )
        = $dispatch->handler( '/article/5/awesome-article' );

will return a data structure equivalent to:    

    $captures = {
        key   => '5',
        title => 'awesome-article',
    };

=head2 url( I<handler>, I<$arguments> )

Build a path that I<handler> would accept. If the path contains captures,
you can pass them as an arrayref (or hashref if they are named captures).

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

=back

=head1 AUTHOR

Mark Norman Francis, L<norm@cackhanded.net>.

=head1 COPYRIGHT AND LICENSE

Copyright 2011 Mark Norman Francis.

This program is free software, you can redistribute it and/or modify it under the terms of the Artistic License version 2.0.

=cut

}
