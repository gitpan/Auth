package dlgLogin;

use Wx qw[:everything];
use base qw(Wx::Dialog);
use strict;

use Wx::Locale gettext => '_T';
use Lang;
use Wx::Event qw(EVT_CLOSE EVT_BUTTON);

sub messageOK {
  my $self=shift;
  my $title=shift;
  my $msg=shift;

  Wx::MessageBox( $msg,$title,wxOK|wxCENTRE, $self);
}

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: dlgLogin::new

	$style = wxDIALOG_MODAL|wxCAPTION 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{label_1} = Wx::StaticText->new($self, -1, _T("Account:"), wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT);
	$self->{authAccount} = Wx::TextCtrl->new($self, -1, "", wxDefaultPosition, wxDefaultSize, );
	$self->{label_2} = Wx::StaticText->new($self, -1, _T("Password:"), wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT);
	$self->{authPass} = Wx::TextCtrl->new($self, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_PASSWORD);
	$self->{authCancel} = Wx::Button->new($self, -1, _T("&Cancel"));
	$self->{authOK} = Wx::Button->new($self, -1, _T("&OK"));

	$self->__set_properties();
	$self->__do_layout();

	return $self;

# end wxGlade
}


sub __set_properties {
	my $self = shift;

# begin wxGlade: dlgLogin::__set_properties

	$self->SetTitle(_T("Login"));
	$self->{authOK}->SetDefault();

# end wxGlade

	# Own code:

	EVT_BUTTON($self,$self->{authOK},\&Ok);
	EVT_BUTTON($self,$self->{authCancel},\&Cancel);
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: dlgLogin::__do_layout

	$self->{grid_sizer_1} = Wx::GridSizer->new(3, 2, 5, 5);
	$self->{grid_sizer_1}->Add($self->{label_1}, 0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL, 0);
	$self->{grid_sizer_1}->Add($self->{authAccount}, 0, wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 0);
	$self->{grid_sizer_1}->Add($self->{label_2}, 0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL, 0);
	$self->{grid_sizer_1}->Add($self->{authPass}, 0, wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 0);
	$self->{grid_sizer_1}->Add($self->{authCancel}, 0, wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 0);
	$self->{grid_sizer_1}->Add($self->{authOK}, 0, wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 0);
	$self->SetAutoLayout(1);
	$self->SetSizer($self->{grid_sizer_1});
	$self->{grid_sizer_1}->Fit($self);
	$self->{grid_sizer_1}->SetSizeHints($self);
	$self->Layout();

# end wxGlade
}

sub Ok {
  my $self=shift;
  if ($self->Ok()) {
    $self->EndModal(1);
  }
}

sub Cancel {
  my $self=shift;
  if ($self->Cancel()) {
    $self->EndModal(0);
  }
}

sub account {
  my $self=shift;
  my $account=shift;
  if (defined $account) { $self->{authAccount}->SetValue($account); }
return $self->{authAccount}->GetValue();
}

sub pass {
  my $self=shift;
  my $pass=shift;
  if (defined $pass) { $self->{authPass}->SetValue($pass); }
return $self->{authPass}->GetValue();
}

# end of class dlgLogin

1;

