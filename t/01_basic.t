use strict;
use warnings;
use utf8;

my $counter;

package
    SamplaReceiver;
use Github::Hooks::Receiver;

on_event sub {
    $counter++;
};

on_event hoge => sub {
    $counter++;
};

package main;
use Test::More 0.98;
use Plack::Test;
use HTTP::Request::Common;

my $app = SamplaReceiver->to_app;

test_psgi $app => sub {
    my $cb  = shift;

    my $req = POST '/', [
        payload => '{"hoge":"fuga"}',
    ], 'X-GitHub-Event' => 'hoge';

    my $res = $cb->($req);
    is $res->content, 'OK';
    is $counter, 2;

    $req = POST '/', [
        payload => '{"hoge":"fuga"}',
    ], 'X-GitHub-Event' => 'piyo';
    $res = $cb->($req);
    is $res->content, 'OK';
    is $counter, 3;
};

done_testing;
