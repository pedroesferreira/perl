#!/usr/bin/perl
$ENV{ORACLE_HOME}='/path/to/OraHome';
$ENV{LD_LIBRARY_PATH}='/path/to/OraHome/lib';
$ENV{NLS_LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';

#example on how to call a remote Perl script with the parameter value passed through CGI
#https://url.com/path_to_perl/call_remote_perl_script_passing_values.pl?value=value_to_pass
#the "value_to_pass" is passed to the new script on the remote machine

use strict;
use CGI;

my $query = new CGI;
my $value = $query->param('value');

print `echo -ne | ssh -l <user> <machine> 'perl /path/to/script/<script>.pl $value'`