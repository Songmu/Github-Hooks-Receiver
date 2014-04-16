package Github::Hooks::Receiver;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Github::Hooks::Receiver::Event;

use JSON;
use Plack::Request;
use Class::Accessor::Lite (
    new => 1,
);

sub _events { shift->{_events} ||= {} }

sub to_app {
    my $self = shift;
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        if ($req->method eq 'POST' and my $payload = eval { decode_json $req->param('payload') }) {
            my $event_name = $req->header('X-GitHub-Event');
            my $event = Github::Hooks::Receiver::Event->new(
                payload => $payload,
                event   => $event_name,
            );

            if (my $code = $self->_events->{''}) {
                $code->($event, $req);
            }
            if (my $code = $self->_events->{$event_name}) {
                $code->($event, $req);
            }

            [200, [], ['OK']];
        }
        else {
            [400, [], ['BAD REQUEST']];
        }
    };
}

sub on {
    my $self = shift;
    my ($event, $code) = @_;
    if (ref $event eq 'CODE') {
        $code  = $event;
        $event = '';
    }
    $self->_events->{$event} = $code;
}

1;
__END__

=encoding utf-8

=head1 NAME

Github::Hooks::Receiver - It's new $module

=head1 SYNOPSIS

    use Github::Hooks::Receiver;
    my $receiver = Github::Hooks::Receiver->new;
    $receiver->on(push => sub {
        my ($event, $req) = @_;
        warn $event->event;
        my $payload = $event->payload;
    });
    $receiver->to_app;

=head1 DESCRIPTION

Github::Hooks::Receiver is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

