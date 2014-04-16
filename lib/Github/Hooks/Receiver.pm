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
        if ($req->method eq 'POST' and my $payload = eval { decode_json $req->param('payload') }) {
            my $event_name = $req->header('X-GitHub-Event');
            my $event = Github::Hooks::Receiver::Event->new(
                payload => $payload,
                event   => $event_name,
            );

            if (my $code = $class->_events->{''}) {
                $code->($event, $req);
            }
            if (my $code = $class->_events->{$event_name}) {
                $code->($event, $req);
            }

            [200, [], ['OK']];
        }
        else {
            [400, [], ['BAD REQUEST']];
        }
    };
}

sub _events {
    no strict 'refs';
    ${"$_[0]\::_EVENTS"} ||= {};
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

