#!/usr/bin/perl

use Auth::Backend::SQL;
use Auth;
use Auth::Login;
use DBI;
use Lang::SQL;
use Lang;

my $IDIDIT=0;
my $dbname="zclass";
my $host="localhost";
my $user="zclass";
my $pass="";
my $dsn="dbi:Pg:dbname=$dbname;host=$host";

if (not $IDIDIT) {
    print "\n";
    print "\n";
    print "***************************************************\n";
    print "NB! You may need to enter proper values for\n";
    print "\$DSN, \$USER and \$PASS for this test to work!\n";
    print "Set \$IDIDIT to 1, after you set them to the right\n";
    print "values.\n";
    print "***************************************************\n";
    print "\n";
    print "continuing test...\n";
    print "\n";
    print "\n";
}

package testApp;

use base 'Wx::App';

sub OnInit {

  Lang::init(new Lang::SQL($dsn,$user,$pass));

  my $backend=Auth::Backend::SQL->new($dsn,$user,$pass);
  my $auth=Auth->new($backend);

  my $login=Auth::Login->new($auth,"test application");

  my $ticket=$login->login();
  $ticket->log();

  $ticket=Auth::Ticket->new(ADMIN => 1);
  $ticket->log();
  $auth->create_account("admin","test",$ticket);

  print "login with admin, pass=test\n";

  $ticket=$login->login();

  $ticket->log();

  $login->Destroy;

  print "\n\nTEST ENDED OK, please don't mind the OnInit error\n\n";

  return 0;
}

package main;

my $a= new testApp;
$a->MainLoop();




