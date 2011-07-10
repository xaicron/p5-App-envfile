use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile tempdir);

use App::envfile;

sub test_load_envfile {
    my %specs = @_;
    my ($input, $expects, $desc) = @specs{qw/input expects desc/};

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    subtest $desc => sub {
        local %ENV;
        my $tempfile = write_envfile($input);
        my $envf = App::envfile->new;
        $envf->load_envfile($tempfile);
        for my $key (sort keys %$expects) {
            is $ENV{$key}, $expects->{$key}, "$key ok";
        }
    };
}

sub write_envfile {
    my $input = shift;
    my (undef, $filename) = tempfile DIR => tempdir CLEANUP => 1;
    open my $fh, '>', $filename or die "$filename: $!"; 
    print $fh $input;
    close $fh;
    return $filename;
}

test_load_envfile(
    expects => { FOO => 'bar' },
    desc    => 'simple',
    input   => << 'ENV');
FOO=bar
ENV

test_load_envfile(
    expects => { FOO => 'bar', HOGE => 'fuga' },
    desc    => 'multi',
    input   => << 'ENV');
FOO=bar
HOGE=fuga
ENV

test_load_envfile(
    expects => { FOO => 'bar=baz' },
    desc    => 'contains split charctor',
    input   => << 'ENV');
FOO=bar=baz
ENV

test_load_envfile(
    expects => { 'HOGE FUGA' => 'piyo' },
    desc    => 'key contains space',
    input   => << 'ENV');
HOGE FUGA=piyo
ENV

test_load_envfile(
    expects => { 'FOO' => 'bar baz' },
    desc    => 'value contains space',
    input   => << 'ENV');
FOO=bar baz
ENV

test_load_envfile(
    expects => { 'FOO' => 'bar baz' },
    desc    => 'spaces',
    input   => << 'ENV');
 FOO = bar baz  
ENV

test_load_envfile(
    expects => { 'FOO' => 'bar' },
    desc    => 'skip comment',
    input   => << 'ENV');
# here is comment
FOO = bar 
ENV

test_load_envfile(
    expects => { 'FOO' => 'bar' },
    desc    => 'skip white line',
    input   => << 'ENV');

FOO = bar 

ENV

subtest 'file not found' => sub {
    no warnings 'redefine';
    *App::envfile::usage = sub {
        ok "call this method", "call usage";
        die "oops";
    };
    eval { App::envfile->new->load_envfile('foo.bar') };
    like $@, qr/oops/;
};

done_testing;
