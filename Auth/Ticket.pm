package Auth::Ticket;

use strict;
use warnings;

sub new {
    my $class=shift;
    my $self={
	ADMIN => 0,
	MUTATE => 0,
	VIEW => 0,
	VALID => 0,
	FROM => undef,
	@_
    };

    if (defined $self->{"FROM"}) {
	my ($admin, $mutate, $view, $valid) = split /,/,$self->{"FROM"};
      $self->{"ADMIN"} = $admin;
      $self->{"MUTATE"} = $mutate;
      $self->{"VIEW"} = $view;
      $self->{"VALID"} = $valid;
    }

    if ($self->{"ADMIN"} or $self->{"MUTATE"} or $self->{"VIEW"}) {
      $self->{"VALID"}=1;
    }

    bless $self,$class;
return $self;
}

sub invalidate {
  my $self=shift;
  $self->{"VALID"}=0;
}

sub valid {
  my $self=shift;
return $self->{"VALID"};
}

sub admin {
  my $self=shift;
return $self->{"ADMIN"};
}

sub mutate {
  my $self=shift;
return $self->{"MUTATE"} or $self->{"ADMIN"};
}

sub view {
  my $self=shift;
return $self->{"VIEW"} or $self->mutate() or $self->admin();
}

sub log {
  my $self=shift;
  print "auth::ticket: admin=",$self->admin(),
        " mutate=",$self->mutate(),
        " view=",$self->view(),
	" valid=",$self->valid(),
	"\n";
}

sub to_string {
  my $self=shift;
return sprintf("%d,%d,%d,%d",$self->admin(),$self->mutate(),$self->view(),$self->valid());
}
1;
__END__

=head1 NAME

Auth::Login - Authorization Framework for wxPerl - Tickets

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

'Auth::Ticket' is part of the authorization framework that can be used
in conjunction with wxPerl. It provides the ticket authorization system.

=head1 DESCRIPTION

=head2 C<new(ADMIN => 0/1, MUTATE => 0/1, VIEW => 0/1, VALID => 0/1, FROM => string)> --E<gt> Auth::Ticket

This method initializes a ticket with given values for ADMIN, MUTATE, VIEW and VALID;
or let's it initialize from the 'FROM' argument, that has earlier been created with
the C<to_string> function.

=head2 C<invalidate()> --E<gt> void

This method invalidates the ticket it's called on, e.g:

    my $ticket=new Auth::Ticket(ADMIN => 1);
    
    (...)

    $ticket->invalidate();

=head2 C<valid()> --E<gt> boolean

This method returns 'true' for a valid ticket and 'false'
for an invalid one.

=head2 C<admin()> --E<gt> boolean

This method returns true if the ticket it's called on 
has ADMIN =E<gt> 1.

=head2 C<mutate()> --E<gt> boolean

This method returns true if the ticket it's called on 
has MUTATE =E<gt> 1.

=head2 C<view()> --E<gt> boolean

This method returns true if the ticket it's called on 
has VIEW =E<gt> 1.

=head2 C<log()> --E<gt> void

This method prints the internals of an Auth::Ticket object
(with function 'print').

=head2 C<to_string()> --E<gt> string

This method converts an Auth::Ticket object to a string.
The Auth::Ticket class provides a way to instantiate
a new Auth::Ticket object from such a string (using the
'FROM' keyword with method 'new').

=head1 SEE ALSO

L<http://wxperl.sf.net>, L<Lang framework|Lang>, L<Auth framework|Auth>, L<Auth::Login|Auth::Login>, 
L<Auth::Backend::SQL|Auth::Backend::SQL>.

=head1 AUTHOR

Hans Oesterholt-Dijkema <oesterhol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under LGPL terms.

=cut


