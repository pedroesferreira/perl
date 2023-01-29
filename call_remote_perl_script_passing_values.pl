#!/usr/bin/perl
$ENV{ORACLE_HOME}='/path/to/OraHome';
$ENV{LD_LIBRARY_PATH}='/path/to/OraHome/lib';
$ENV{NLS_LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';

use strict;
use CGI;

my $query = new CGI;
my $value = $query->param('value');

print `echo -ne | ssh -l <user> <machine> 'perl /path/to/script/<script>.pl $value'`