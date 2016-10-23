#!/usr/bin/env perl 

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use Net::DNS;
use List::Util qw(first any);

my $resolver = Net::DNS::Resolver->new;

do_test(shift || File::Spec->catfile($Bin, 'list.dns'));

sub do_test {
    my $fn = shift;

    open(my $fh, '<', $fn) or die "Can't open file $fn: $!";
    while (my $l = <$fh>) {
        chomp($l);

        test_domain($l);
    }

    done_testing;
}

sub test_domain {
    my $domain = shift;

    subtest $domain => sub {
        my $reply = $resolver->send("test.$domain", 'A', 'IN');
        my @list  = $reply->answer;

        ok(scalar(@list), 'answer present');

        my $cname = first { $_->type eq 'CNAME' } @list;
        ok($cname, 'cname present');

        my $a = first { $_->type eq 'A' && $cname->rdstring eq ($_->name .'.') } @list;
        ok($a, 'a present');

        is($a->rdstring, '192.168.1.42', 'a record is 192.168.1.42');

        done_testing;
    };
}
