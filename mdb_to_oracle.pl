#!/usr/bin/perl -w

$ENV{ORACLE_HOME}='/path/to/OraHome';
$ENV{LD_LIBRARY_PATH}='/path/to/OraHome/lib';
$ENV{NLS_LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';
$ENV{LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';
$ENV{MDB_ICONV}='ISO-8859-15';

use strict;
use DBI;

my $PATH_FILES = "/path/to/access_bd_file";
my $FILE = "$PATH_FILES/data.mdb";
my $DBNAME = 'dbi:Oracle:bd';
my $DBUSER = 'bd_username';
my $PASS = 'bd_password';


sub myLTrim {
	my $mystr = $_[0];

	if ($mystr =~ m/^[\s]+(.*)/) {
		return $1;
	}

	return $mystr;
}


sub updateIntChar {
	my $tabela = $_[0];
	my $c = 0;
	my @tabelas = `mdb-export -H -Q -d '####' $FILE $tabela`;

	my $con = DBI->connect($DBNAME, $DBUSER, $PASS, { RaiseError => 1});

	foreach(@tabelas) {   
		chomp;
		my @aux = split(/####/, $_);
		my $arg1 = "";

		if ($#aux == -1) {
			print "Saltando linha vazia\n";
			next;
		}

		$arg1 = "$aux[0]";
		my $arg2 = "";
		
		if ($aux[1]) {
			$arg2 = myLTrim("$aux[1]");
		}
		
		my $sth = $con->prepare(qq{ INSERT INTO $tabela VALUES (to_number($arg1), ?) });
		$sth->execute("$arg2");
		$sth->finish();
		$c++;
	}  
	
	print("---------- Total de Linhas $tabela: " . $c . " ---------------\n");

	$con->disconnect;
}


sub main {
	deleteTabela("TABLE_NAME");
	updateIntChar("TABLE_NAME");
	
	my $end_date = `echo -n "\`date +"\%d \%B \%Y \%H:\%M:\%S"\`"`;
    print("$end_date : Fim dos Inserts.\n");
}

main;
