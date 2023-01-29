#!/usr/bin/perl
$ENV{ORACLE_HOME}='/path/to/OraHome';
$ENV{LD_LIBRARY_PATH}='/path/to/OraHome/lib';
$ENV{NLS_LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';
$ENV{LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';
$ENV{MDB_ICONV}='ISO-8859-15';

use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use Data::Dumper;
use CGI;
use DBI;
use MIME::Lite;

my $ora_bd = "dbi:Oracle:bd";
my $ora_user = "bd_username";
my $ora_pwd = "bd_password";

my $stat;
my @row;
my $sql;

my $query = new CGI;

my $table_id = $query->param('table_id');

my $ora_conn= DBI->connect($ora_bd,$ora_user,$ora_pwd,{RaiseError => 1});

$sql=qq{select convert(xml_col, 'UTF8') from table_with_xml rm where rm.id = '$table_id' and rownum = 1};
$stat=$ora_conn->prepare($sql);
$stat->execute;
@row = $stat->fetchrow_array;
($xml)=@row;
$stat->finish;

$ora_conn->disconnect;

my $ua = new LWP::UserAgent;
    $ua->cookie_jar(HTTP::Cookies->new());
my $url = 'https://endpoint.com/api/1.00';

my $header = new HTTP::Headers (
        'Content-Type'   => 'text/xml; charset=utf-8',
        'User-Agent'     => 'SOAP 0.1'
    );

my $req = new HTTP::Request('POST', $url, $header, $xml);
my $res = $ua->request($req);

my $response .= $res->content;
print "Content-type: text/xml\n\n";
print "$response\n";
