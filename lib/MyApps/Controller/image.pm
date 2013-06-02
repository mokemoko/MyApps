package MyApps::Controller::image;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use HTML::TreeBuilder;
use Data::Dumper;

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
  my ( $self, $c ) = @_;

  my $domain = $c->config->{domain};
  my $url = $domain . '/post/index?tags=initial-g';
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
        push @{$c->stash->{images}}, $image->as_HTML();
      }
    }

    my $detail_url = $domain . @items->[4]->find('a')->attr('href');

    $content = $ua->get($detail_url)->content;

    $tree = $tree->delete;
    $tree = HTML::TreeBuilder->new;
    $tree->parse($content);
    $tree->eof();

    my $stat = $tree->look_down(_tag => 'a', title => qr(^\d{4}-));
    $c->stash->{last_post} = $stat->attr('title');

    $tree = $tree->delete;
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
