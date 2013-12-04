package Github::Hooks::Receiver;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use JSON;
use Plack::Request;

use parent 'Exporter';
our @EXPORT = qw/to_app _events on_event/;

sub to_app {
    my $class = shift;
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        my $payload    = decode_json $req->param('payload');
        my $event_name = $req->header('X-GitHub-Event');
        my $event = Github::Hooks::Receiver::Event->new(
            payload => $payload,
            event   => $event_name,
        );

        if (my $code = $class->_events->{''}) {
            $code->($event);
        }
        if (my $code = $class->_events->{$event_name}) {
            $code->($event);
        }

        [200, [], ['OK']]
    };
}

{
    my $_events = {};
    sub _events { $_events }
}
sub on_event {
    my $class = caller;
    my ($event, $code) = @_;
    if (ref $event eq 'CODE') {
        $code  = $event;
        $event = '';
    }
    $class->_events->{$event} = $code;
}

package Github::Hooks::Receiver::Event;
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/payload event/],
);

1;
__END__

=encoding utf-8

=head1 NAME

Github::Hooks::Receiver - It's new $module

=head1 SYNOPSIS

    use Github::Hooks::Receiver;

=head1 DESCRIPTION

Github::Hooks::Receiver is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

