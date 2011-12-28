use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile tempdir);
use t::Util;

use App::envfile;

sub test_load_envfile {
    my %specs = @_;
    my ($input, $expects, $desc) = @specs{qw/input expects desc/};

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    runtest $desc => sub {
        my $tempfile = write_envfile($input);
        my $envf = App::envfile->new;
        my $got = $envf->load_envfile($tempfile);
        is_deeply $got, $expects, 'parse ok';
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
+{
    FOO => 'bar',
}
ENV

test_load_envfile(
    expects => { FOO => 'bar', HOGE => 'fuga' },
    desc    => 'multi',
    input   => << 'ENV');
+{
    FOO  => 'bar',
    HOGE => 'fuga',
}
ENV

runtest 'hushref must return' => sub {
    my $input = <<'ENV';
[qw/foo bar/]
ENV
    my $tempfile = write_envfile($input);
    eval { App::envfile->new->load_envfile($tempfile) };
    note $@;
    ok $@, 'throw error';
};

runtest 'file not found' => sub {
    eval { App::envfile->new->load_envfile('foo.perl') };
    note $@;
    ok $@, 'throw error';
};

done_testing;
