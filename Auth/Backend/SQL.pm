package Auth::Backend::SQL;

use strict;
use Auth::Ticket;

sub new {
  my $class=shift;
  my $dsn=shift;
  my $user=shift;
  my $pass=shift;
  my $self;

  $self->{"dsn"}=$dsn;
  $self->{"dbh"}=DBI->connect($dsn,$user,$pass);
  $self->{"status"}="none";

  bless $self,$class;

  { # Check existence

    my $sth=$self->{"dbh"}->prepare("SELECT COUNT(account) FROM auth_accounts");
    if (not $sth->execute()) {
      $sth->finish();
      $self->{"dbh"}->do("CREATE TABLE auth_accounts (account varchar(200), pass varchar(250), ticket varchar(250))");
      $self->{"dbh"}->do("CREATE INDEX auth_accounts_idx ON auth_accounts(account)");
    }
    else {
      $sth->finish();
    }
  }

return $self;
}

sub DESTROY {
  my $self=shift;
  $self->{"dbh"}->disconnect();
}

sub number_of_accounts {
  my $self=shift;
  my $retval=0;

  my $sth=$self->{"dbh"}->prepare("SELECT count(account) FROM auth_accounts");
  
  $sth->execute();
  if ($sth->rows() == 1) {
    my @a=$sth->fetchrow_array();
    $retval=shift @a;
  }
  $sth->finish();

return $retval;
}

sub fetch {
  my $self=shift;
  my $account=shift;
  my @result;
  
  my $sth=$self->{"dbh"}->prepare("SELECT account,pass,ticket FROM auth_accounts WHERE account='$account'");
  $sth->execute();

  if ($sth->rows() == 1) {
    my ($a,$p,$t) = $sth->fetchrow_array();
    push @result, "ok";
    push @result, $p;
    push @result, new Auth::Ticket(FROM => $t);
  }
  elsif ($sth->rows() > 1) {
    my ($a,$p,$t) = $sth->fetchrow_array();
    push @result, "!uniq";
    push @result, $p;
    push @result, new Auth::Ticket(FROM => $t);
  }
  else {
    push @result, "!found";
    push @result, "";
    push @result, new Auth::Ticket(VALID => 0);
  }

  $sth->finish();

return @result;
}

sub store {
  my $self=shift;
  my $account=shift;
  my $newpass=shift;
  my $newticket=shift;

  my ($result,$pass,$ticket)=$self->fetch($account);

  my $ticket_str=$newticket->to_string();

  if ($result eq "!found") {
    $self->{"dbh"}->do("INSERT INTO auth_accounts (account,pass,ticket) VALUES ('$account','$newpass','$ticket_str')");
  }
  else {
    if ($result eq "!uniq") {
      $self->{"dbh"}->do("DELETE FROM auth_accounts WHERE account='$account'");
      $self->store($account,$pass);
    }
    else {
      $self->{"dbh"}->do("UPDATE auth_accounts SET pass='$newpass',ticket='$ticket_str' WHERE account='$account'");
    }
  }
}

1;
__END__

=head1 NAME

Auth::Login - Authorization Framework for wxPerl - SQL Backend

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

'Auth::Backend::SQL' is part of the authorization framework that can be used
in conjunction with wxPerl. It provides the an SQL backend for storing and
fetching accounts.

=head1 DESCRIPTION

=head2 C<new(DSN (see DBI),user,pass)> --E<gt> Auth::Backend::SQL

This method initializes the backend (see DBI for more details about
perl and databases). This method creates a table C<auth_accounts>
in the database mentioned in the DSN (if it does not exist).

=head2 C<store(account,pass,ticket)> --E<gt> void

This method stores an account, pass and ticket in the database.
It uses Digest::MD5 to hash the password.

=head2 C<fetch(account)> --E<gt> (result, pass, ticket)

This method fetches an account from the database. If account exists
in the database, pass (md5 string) and ticket are given
back. The result will have value C<"ok">.

If account cannot be found, result will be C<"!found">. Pass will be C<"">
and C<ticket->valid() --E<gt> false>.

If account is not uniq, a valid result will be returned, but result
will have the value C<"!uniq">.

=head2 C<number_of_accounts()> --E<gt> integer

This method returns the number of accounts in the database.

=head1 BUGS

This module has only been tested with PostgreSQL.

=head1 SEE ALSO

L<http://wxperl.sf.net>, L<Lang framework|Lang>, L<Auth framework|Auth>, L<Auth::Login|Auth::Login>, 
L<Auth::Ticket|Auth::Ticket>.

=head1 AUTHOR

Hans Oesterholt-Dijkema <oesterhol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under LGPL terms.

=cut


