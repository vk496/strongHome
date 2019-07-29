#!/usr/bin/perl

use CGI;

my $cgi = CGI->new();

my $wifi = $cgi->param( "wifi" );
my $hidden = $cgi->param( "hidden" );

if (not length $wifi) {
    print $cgi->header(-status => 404);
    exit 1;
}

my $pass_hidden = "";
if (length $hidden) {
  $pass_hidden = "yes";
}

print "Content-Type:application/octet-stream\n";
print "Content-Disposition: attachment; filename=strongHome_prfile.mobileconfig\n\n";
my $output = `/template.mobileconfig.sh /usr/share/nginx/html/ca.pem $wifi $pass_hidden | openssl smime -sign -signer /cert/radius.pem -inkey /cert/radius-key.pem -certfile /usr/share/nginx/html/ca.pem -nodetach -outform der -in - -out -`;
print "$output";
