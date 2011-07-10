use strict;
use warnings;
use Test::More;

BEGIN {
    # capture exec()
    *CORE::GLOBAL::exec = sub {
        my @args = @_;
        my $pid = open my $pipe, '-|';
        if ($pid) {
            my $buf;
            while (defined (my $line = readline $pipe)) {
                $buf .= $line;
            }
            close $pipe;
            return $buf;
        }
        else {
            CORE::exec @args or die $!;
        }
    };
}

use App::envfile;

sub test_run {
    my %specs = @_;
    my ($input, $expects, $desc) = @specs{qw/input expects desc/};
    my ($envfile, $envmap) = @$input;

    local %ENV = %ENV;

    {
        no warnings 'redefine';
        *App::envfile::load_envfile = sub {
            my ($self, $file) = @_;
            is $file, $envfile, 'load_envfile ok';
            for my $key (sort keys %$envmap) {
                $ENV{$key} = $envmap->{$key};
            }
        };
    }

    my $command = join ',', map { "\$ENV{$_}" } sort keys %$envmap;

    subtest $desc => sub {
        my $envf = App::envfile->new;
        $envf->run($envfile, $^X, '-e', "print qq|$command|");
    };
}

test_run(
    input   => [file => { FOO => 'bar' }],
    expects => 'bar',
    desc    => 'with FOO',
);

test_run(
    input   => [file => { FOO => 'bar', BAR => 'baz' }],
    expects => 'baz,bar',
    desc    => 'with FOO, BAR',
);

done_testing;
