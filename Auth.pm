package Auth;

use 5.006;
use strict;
use warnings;
use Auth::Ticket;
use Digest::MD5 qw(md5_base64);

our $VERSION = '0.01';

sub new {
  my $class=shift;
  my $backend=shift;
  my $self;

  $self->{"status"}="none";
  $self->{"backend"}=$backend;

  bless $self,$class;

return $self;
}

sub has_accounts {
  my $self=shift;
  return ($self->{"backend"}->number_of_accounts()!=0);
}

sub admin_ticket {
  return new auth::ticket(ADMIN => 1);
}

sub check_login {
  my $self=shift;
  my $account=shift;
  my $pass=shift;
  my $retval="not set";
  
  my ($result,$p,$ticket)=$self->{"backend"}->fetch($account);

  if ($result eq "ok") {
    my $passmd5=md5_base64($pass);

    if ($p eq $passmd5) {
      $self->status("login_ok");
    }
    else {
      $ticket->invalidate();
      $self->status("bad_pass");
    }
  }
  else {
    $ticket->invalidate();
    $self->status("user_unknown");
  }

return $ticket;
}

sub logout {
  my $self=shift;
  $self->status("none");
}

sub status {
  my $self=shift;
  my $newstatus=shift;
  if ($newstatus) {
    $self->{"status"}=$newstatus;
  }
return $self->{"status"};
}

sub logged_in {
  my $self=shift;
  return $self->{"status"} eq "login_check_ok";
}

sub bad_pass {
  my $self=shift;
  return $self->{"status"} eq "bad_pass";
}

sub user_unknown {
  my $self=shift;
  return $self->{"status"} eq "user_unknown";
}

sub create_account {
  my $self=shift;
  my $account=shift;
  my $pass=shift;
  my $ticket=shift;

  my $md5pass=md5_base64($pass);
  $self->{"backend"}->store($account,$md5pass,$ticket);
}

sub update_pass_ticket {
  my $self=shift;
  my $account=shift;
  my $pass=shift;
  my $ticket=shift;

  my $md5pass=md5_base64($pass);
  $self->{"backend"}->store($account,$md5pass,$ticket);
}

1;
__END__

=head1 NAME

Auth - Authorization framework for Wx::Perl.

=head1 SYNOPSIS

    use Auth::Backend::SQL;
    use Auth;
    use Auth::Login;
    use DBI;
    use Lang::SQL;
    use Lang;

    package testApp;

    use base 'Wx::App';

    sub OnInit {
      my $dbname="zclass";
      my $host="localhost";
      my $user="zclass";
      my $pass="";
      my $dsn="dbi:Pg:dbname=$dbname;host=$host";

      Lang::init(new Lang::SQL("dbi:Pg:dbname=$dbname;host=$host",$user,$pass));

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

      return 0;
    }

    package main;

    my $a= new testApp;
    $a->MainLoop();

=head1 ABSTRACT

'Auth' is an authorization framework that can be used in conjunction with
wxPerl. It provides a simple login system with flexible login 
backends and a very simple ticket system, that has three levels of
authorization.

=head1 DESCRIPTION

=head2 Authorization levels

The Auth authorization framework has three levels of authorization:

=over 1

=item administrator

This level of authorization should be used for users that are 
'superuser' for a program.

=item mutate

This level of authorization should be used for users that can
modify data.

=item view

This level of authorization should be used for users that can
only view information.

=back

=head2 C<new(backend)> --E<gt> Auth

The new method instantiates an Auth object with a given backend. 
The backend has to be preinitialized. 

Returns the Auth object.

=head2 C<has_accounts()> --E<gt> boolean

This method returns if the backend has any accounts in the store.

=head2 C<admin_ticket()> --E<gt> Auth::Ticket

This method returns a ticket object with administrator authorization
level.

=head2 C<check_login(account,pass)> --E<gt> Auth::Ticket

This method checks with the backend if a (account,password) combination
is valid. If it is, it will return a ticket with the registered authorization
level. 

Otherwise, it will return a ticket that has property 'invalid'.

=head2 C<create_account(account,pass,ticket)> --E<gt> void

This method creates a (new) account. It should be passed a valid
ticket. Account and Pass must not be empty. 

The backend will create the new account in the store. If the account
already exists, the backend must overwrite the existing account.

=head2 C<update_pass_ticket(account,pass,ticket)> --E<gt> void

This method updates the password and ticket of an existing account
in the store of the backend. If the account doesn't exist, the 
backend will create it with the given password and ticket.

=head1 SEE ALSO

L<http://wxperl.sf.net>, L<|Auth::Login>, L<|Auth::Ticket>, L<|Auth::Backend::SQL>.

=head1 AUTHOR

Hans Oesterholt-Dijkema <oesterhol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under LGPL terms.

=cut
