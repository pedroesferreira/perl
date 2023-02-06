#!/usr/bin/perl
$ENV{ORACLE_HOME}='/opt/oracle/OraHome_1';
$ENV{LD_LIBRARY_PATH}='/opt/oracle/OraHome_1/lib';
$ENV{NLS_LANG}='PORTUGUESE_PORTUGAL.WE8ISO8859P15';

use strict;

use HTTP::Cookies;
use LWP::UserAgent;
use Data::Dumper;
use CGI;
use DBI;
use MIME::Base64;
use JSON;
use Encode qw( encode decode encode_utf8 decode_utf8);

# example on how to use a Perl script as an endpoint for a JSON HTTP POST
# this script has examples on how to manually check the Auth header,
# get the POST content, parse through the JSON to get the desired values,
# call a PLSQL function that builds the response and return it with the appropriate status code

# read AUTH header
my $status;
my $auth_string = substr($ENV{'HTTP_AUTHORIZATION'}, index($ENV{'HTTP_AUTHORIZATION'}, ' ')+1);
my $auth_decoded = decode_base64($auth_string);
my $username_decoded = substr($auth_decoded, 0, index($auth_decoded, ':'));
my $password_decoded = substr($auth_decoded, index($auth_decoded, ':')+1);

# validate auth header
if ($username_decoded eq "username" and $password_decoded eq "password") {
	$status = "200";
} else {
	$status = "403";
}

if ($status eq "200") {
	# read POST content
	my $post_content;

	if ($ENV{'REQUEST_METHOD'} eq "POST"){
		read(STDIN, $post_content, $ENV{'CONTENT_LENGTH'});
	} else {
		$post_content = $ENV{'QUERY_STRING'};
	}

	my $encoded_utf8 = encode_utf8($post_content);
	my $decoded_json = decode_json($encoded_utf8);
	my $id_header;
	my $event_code;
	my $idx = 0;

	# parses through JSON array named "entry"
	foreach my $listing ($decoded_json->{entry})
	{ 
		if ($listing->[$idx]->{resource}->{resourceType} eq "Header") {
			$id_header = $listing->[$idx]->{resource}->{id};
			$event_code = $listing->[$idx]->{resource}->{event}->{code};
		}
		$idx = $idx + 1;
	}
	
	# oracle DB connection
	my $ora_bd = "dbi:Oracle:bd";
	my $ora_user = "bd_username";
	my $ora_pwd = "bd_password";
	my $stat;
	my @row;
	my $sql;
	my $result;
	
	my $ora_conn = DBI->connect($ora_bd, $ora_user, $ora_pwd, {RaiseError => 1});
	
	# call oracle JSON building function using params
	$sql=qq{select pk_package.my_function(?, ?) from dual};
	$stat=$ora_conn->prepare($sql);
	$stat->execute("$id_header", "$event_code");
	@row = $stat->fetchrow_array;
	($result)=@row;
	$stat->finish;
	
	$ora_conn->disconnect;
}

# return response with the status code
my $q = CGI->new;
print $q->header(-type=>"application/json", -charset=>'utf-8', -status=>$status);
print $result;
