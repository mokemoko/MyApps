package MyApps::Controller::image;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use HTML::TreeBuilder;
use File::Basename;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::image - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ($self, $c) = @_;

  $c->stash->{images} = [$c->model('Image::Image')->search({}, {rows => 50, page => 1, order_by => {-desc => 'posted_at'}})];
}

sub list :Local :Args(0) {
  my ($self, $c) = @_;
  if ($c->req->env->{HTTP_X_FORWARDED_FOR} || !$c->req->param('mode')) {
    $c->res->redirect('/image/');
  }

  $c->stash->{images} = [$c->model('Image::Image')->search({}, {order_by => {-desc => 'posted_at'}})];
}

# 追加
sub add :Local :Args(0) {
  my ($self, $c) = @_;

  if($c->req->param('.submit') && $c->req->param('name')) {
    $c->model('Image::Artist')->create({
        name => $c->req->param('name'),
        created_at => DateTime->now(),
      });
  }  
}

# 一覧表示
sub artist :Local :Args(0) {
  my ($self, $c) = @_;

  if ($c->req->param('id')) {
    $c->stash->{artist} = $c->model('Image::Artist')->find({id => $c->req->param('id')});;
  } else {
    $c->stash->{artists} = [$c->model('Image::Artist')->search({}, {order_by => {-desc => 'created_at'}})];
  }
}

# 追加画面でのAjax呼び出し用
sub imgnum :Local :Args(0) {
  my ($self, $c) = @_;

  if($c->req->param('name')) {
    my $domain = $c->config->{image_domain};
    # postではなくtagsで投稿数はすぐ取得できるのでは？
    my $url = $domain . '/post/index?tags='. $c->req->param('name');
    my $ua = LWP::UserAgent->new('agent' => 'Mozilla/5.0 (Windows NT 6.2; rv:21.0) Gecko/20130314 Firefox/21.0');
    my $content = $ua->get($url)->content;

    if ($content) {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse($content);
      $tree->eof();

      my @items = $tree->look_down('class', 'content')->find('span');
      foreach my $item (@items) {
        my $image = $item->find('a');
        if ($image) {

        }
      }
    }
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
