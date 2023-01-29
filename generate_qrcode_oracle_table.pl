#!/usr/bin/perl -w

use Imager;
use Imager::QRCode;
use CGI;
use DBI;

#example on how to generate a QRCode based a string saved on an Oracle table
#params passed through CGI
#the exact string to generate the QRCode is obtained through the given table_id
#https://url.com/path_to_perl/generate_qrcode_oracle_table.pl?table_id=123&filename=qrcode_123
#saves the generated image on a path with the given filename

my $query = new CGI;
my $filename = $query->param('filename');
my $table_id = $query->param('table_id');

my $ora_bd = "dbi:Oracle:bd";
my $ora_user = "bd_username";
my $ora_pwd = "bd_password";

my $stat;
my @row;
my $sql;
my $text;

my $ora_conn = DBI->connect($ora_bd, $ora_user, $ora_pwd, {RaiseError => 1});

if (defined $table_id) {
	
	$sql=qq{select rm.qrcode_msg from table_qrcode_msg rm where rm.id = '$table_id'};
	$stat=$ora_conn->prepare($sql);
	$stat->execute;
	@row = $stat->fetchrow_array;
	($text)=@row;
	$stat->finish;
	
    my $qrcode = Imager::QRCode->new(
		size          => 2,
		margin        => 0.25,
		version       => 9,
		level         => 'M',
		casesensitive => 1,
		lightcolor    => Imager::Color->new(255, 255, 255),
		darkcolor     => Imager::Color->new(0, 0, 0)
    );
	
    my $img = $qrcode->plot($text);
	$img->write(file => "/path/to/folder/$filename.bmp") or die $img->errstr;
}
