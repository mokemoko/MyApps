package MyApps::Controller::Diary;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::Diary - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{diaries} = [$c->model('Diary::Diary')->search({}, {order_by => {-desc => 'posted_at'}})];
}

sub add :Local :Args(0) {
  my ($self, $c) = @_;

  if($c->req->param('.submit')) {
    $c->model('Diary::Diary')->create({
        title => $c->req->param('title') || '',
        text => $c->req->param('text') || '',
        posted_at => DateTime->now(),
      });
    $c->res->redirect('/');
  }  

  $c->res->redirect('/');
}

sub delete :Local :Args(0) {
  my ($self, $c) = @_;

  my $id = $c->req->param('id');

  if(my $d = $c->model('Diary::Diary')->find($id)){
    $d->delete;
  }  

  $c->res->redirect('/');
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
