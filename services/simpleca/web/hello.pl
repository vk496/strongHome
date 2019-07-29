#!/usr/bin/perl

use CGI;

my $cgi = CGI->new();

my $user = $cgi->param( "wifi" );
my $mail = $cgi->param( "hidden" );

print "Content-Type:application/x-download\n";
print "Content-Disposition: attachment; filename=test.mobileconfig\n\n";
my $output = `openssl smime -sign -signer /cert/radius.pem -inkey /cert/radius-key.pem -certfile /usr/share/nginx/html/ca.pem -nodetach -outform der -in /usr/share/nginx/html/hello.pl -out -`;
print "$output";


# print <<EndOfHTML;
# <html><head><title>Perl Environment Variables</title></head>
# <body>
# <h1>Perl Environment Variables</h1>
# EndOfHTML
#
# foreach $key (sort(keys %ENV)) {
#   print "$key = $ENV{$key}<br>\n";
# }
#
# print "Hello $user please confirm your email $mail\n";
#
# print "</body></html>";
