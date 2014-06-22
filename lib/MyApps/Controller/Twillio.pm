package MyApps::Controller::Twillio;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::Twillio - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub auto :Private {
  my ($self, $c) = @_;

  if ($c->action ne 'twillio/index') {
    my $from = $c->req->param('From');  # 発信元電話番号(+81~の形式)
    my $sid  = $c->req->param('AccountSid'); # twillioのsecret_id twillioからのアクセスに限定する用

    # twillio以外からのアクセスはすべて404に
    if (!$sid || $sid ne $c->config->{twillio_secret_id}) {
      $c->res->status(404);
      $c->stash->{template} = "404.tt";
      return;
    }

    $c->response->content_type('text/xml');

    # 発信元番号が取得できなかった場合
    return $c->stash->{template} = "twillio/withheld.tt" unless ($from);

    $from =~ s/^\+81//;
    $from = '0' . $from;
    $c->stash->{from} = $from;
    $c->stash->{shop} = $c->model('Twillio::Shop')->find({tel => $from});
  }

  1;
}

sub index :Path :Args(0) {
  my ($self, $c) = @_;
  $c->stash->{shops} = [$c->model('Twillio::Shop')->search({}, {order_by => {-desc => 'created_at'}})];
}

sub req :Local :Args(0) {
  my ($self, $c) = @_;

  return $c->stash->{template} = "twillio/notfound.tt" unless ($c->stash->{shop});

  1;
}

sub req2 :Local :Args(0) {
  my ($self, $c) = @_;
  my $digits = $c->req->param('Digits');

  if ($digits eq '1') {
    # 登録
    $c->stash->{shop}->update({flg => 1});
    return $c->stash->{template} = "twillio/complete.tt";
  } else {
    # キャンセル
    return $c->stash->{template} = "twillio/cancel.tt";
  }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
