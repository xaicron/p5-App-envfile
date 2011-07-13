package App::envfile;

use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.03';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run_with_env {
    my ($self, $env, $commands) = @_;
    local %ENV = %ENV;
    for my $key (keys %$env) {
        $ENV{$key} = $env->{$key};
    }
    exec(@$commands);
}

sub parse_envfile {
    my ($self, $file) = @_;
    open my $fh, '<', $file or die "$file: $!\n";
    my $env = {};
    while (defined (my $line = readline $fh)) {
        chomp $line;
        next if index($line, '#') == 0;
        next if $line =~ /^\s*$/;
        my ($key, $value) = $self->_parse_line($line);
        $env->{$key} = $value;
    }
    close $fh;

    return $env;
}

sub _parse_line {
    my ($self, $line) = @_;
    my ($key, $value) = map { my $str = $_; $str =~ s/^\s+|\s+$//g; $str } split '=', $line, 2;
    return $key, $value;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

App::envfile - runs another program with environment modified according to envfile

=head1 SYNOPSIS

  $ cat > foo.env
  FOO=bar
  HOGE=fuga
  $ envfile foo.env perl -le 'print "$ENV{FOO}, $ENV{HOGE}"'
  bar, fuga

like

  $ env FOO=bar HOGE=fuga perl -le 'print "$ENV{FOO}, $ENV{HOGE}"'

=head1 DESCRIPTION

App::envfile is sets environment from file.

envfile inspired djb's envdir program.

=head1 METHODS

=over

=item C<< new() >>

Create App::envfile instance.

  my $envf = App::envfile->new();

=item C<< run_with_env(\%env, \@commands) >>

Runs another program with environment modified according to C<< \%env >>.

  $envf->run_with_env(\%env, \@commands);

=item C<< parse_envfile($envfile) >>

Parse the C<< envfile >>. Returned value is HASHREF.

  my $env = $envf->parse_envfile($envfile);

Supported file format are:

  KEY=VALUE
  # comment
  KEY2=VALUE
  ...

=back

=head1 AUTHOR

xaicron E<lt>xaicron@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2011 - xaicron

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
