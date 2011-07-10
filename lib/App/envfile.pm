package App::envfile;

use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.01';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my ($self, $envfile, @args) = @_;
    $self->usage unless defined $envfile;
    $self->load_envfile($envfile);
    exec(@args);
}

sub load_envfile {
    my ($self, $file) = @_;
    $self->usage unless -f $file;
    open my $fh, '<', $file or die "$file: $!\n";
    while (defined (my $line = readline $fh)) {
        chomp $line;
        next if index($line, '#') == 0;
        next if $line =~ /^\s*$/;
        my ($key, $value) = $self->_split_line($line);
        $ENV{$key} = $value;
    }
    close $fh;
}

sub _split_line {
    my ($self, $line) = @_;
    my ($key, $value) = map { my $str = $_; $str =~ s/^\s+|\s+$//g; $str } split '=', $line, 2;
    return $key, $value;
}

sub usage {
    my $self = shift;
print << 'USAGE';
Usage: evnfile file commands

USAGE
    exit 1;
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

=item C<< run($envfile, @commands) >>

Runs another program.

  $envf->run($envfile, @commands);

=item C<< load_envfile($envfile) >>

Sets %ENV from file.

  $envf->load_envfile($envfile);

Supported file format are:

  KEY=VALUE
  KEY2=VALUE
  ...

=item C<< usage() >>

Show usage.

  $envf->usage();

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
