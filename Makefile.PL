use inc::Module::Install;
name 'App-envfile';
all_from 'lib/App/envfile.pm';

#requires '';

test_requires 'Test::More', 0.98;

install_script 'bin/envfile';

tests join q{ }, map { sprintf 't%s.t', '/*' x $_ } 1..3;
author_tests 'xt';

auto_set_repository();

WriteAll;
