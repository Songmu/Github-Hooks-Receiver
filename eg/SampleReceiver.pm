package SampleReceiver;
use strict;
use warnings;
use utf8;

use Github::Hooks::Receiver;

on_event push => sub {
    my $event = shift;

    warn $event->event;
    my $payload = $event->payload;
};

1;
