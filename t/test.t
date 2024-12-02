use strict;
use warnings;

use Test2::V0;

use JSON::XS;
use JSON::PP ();
use Cpanel::JSON::XS ();

use Types::Common -types;
use Smart::Args::TypeTiny qw(args_pos);

my $json_pp = JSON::PP->new;
my $json_xs = JSON::XS->new;
my $cpanel_json = Cpanel::JSON::XS->new;

note 'Perl: ' . $];
note 'JSON::PP: ' . $JSON::PP::VERSION;
note 'JSON::XS: ' . $JSON::XS::VERSION;
note 'Cpanel::JSON::XS: ' . $Cpanel::JSON::XS::VERSION;

sub test_json {
    my $data = shift;
    my $c = context;

    my $expected = '{"foo":123}';

    is $json_pp->encode($data), $expected, 'JSON::PP is valid';
    is $json_xs->encode($data), $expected, 'JSON::XS is valid';
    is $cpanel_json->encode($data), $expected, 'Cpanel::JSON::XS is valid';

    $c->release;
}

subtest 'Do nothing' => sub {
    my $data = { foo => 123 };
    test_json($data);
};

subtest 'Match regex' => sub {
    my $data = { foo => 123 };
    ok $data->{foo} =~ qr/^\d+$/;
    test_json($data);
};

subtest 'Use as hash key' => sub {
    my $data = { foo => 123 };

    my %cache;
    $cache{$data->{foo}} = 'cache!';

    test_json($data);
};

subtest 'Equal' => sub {
    my $data = { foo => 123 };

    my $owner = 999;
    if ($data->{foo} eq $owner) {
        # ...
    }

    test_json($data);
};

subtest 'length' => sub {
    my $data = { foo => 123 };

    if (length $data->{foo} == 0) {
        # ...
    }

    test_json($data);
};

subtest 'Types' => sub {

    subtest 'Type (Int)' => sub {
        my $data = { foo => 123 };

        my $type = Dict[ foo => Int];
        ok $type->check($data);

        test_json($data);
    };

    subtest 'Type (Str)' => sub {
        my $data = { foo => 123 };

        my $type = Dict[ foo => Str];
        ok $type->check($data);

        test_json($data);
    };

    subtest 'Type (NonEmptyStr)' => sub {
        my $data = { foo => 123 };

        my $type = Dict[ foo => NonEmptyStr ];
        ok $type->check($data);

        test_json($data);
    };

    subtest 'Type (StrLength)' => sub {
        my $data = { foo => 123 };

        my $type = Dict[ foo => StrLength[1,] ];
        ok $type->check($data);

        test_json($data);
    };
};

subtest 'Validation with types' => sub {
    my $test = sub {
        my $callback = shift;

        my $data = { foo => 123 };

        $callback->($data);

        test_json($data);
    };

    subtest 'Smart::Args::TypeTiny' => sub {
        subtest 'check' => sub {
            my $cb = sub {
                args_pos my $data => Dict[ foo => NonEmptyStr ];
                # do something
            };

            $test->($cb);
        };

        subtest 'no check' => sub {
             no warnings 'redefine';
             local *Smart::Args::TypeTiny::check_rule = \&Smart::Args::TypeTiny::Check::no_check_rule;

             my $cb = sub {
                 args_pos my $data => Dict[ foo => NonEmptyStr ];
                 # do something
             };

             $test->($cb);
        };
    };
};

