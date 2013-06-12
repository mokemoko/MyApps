package MyApps::Controller::Batch;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use LWP::Simple;
use HTML::TreeBuilder;
use File::Basename;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::Batch - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

# 画像取得処理
sub getImages :Private {
  my ($self, $c) = @_;

  warn "start getImages";

  my $domain = $c->config->{image_domain};
  my @artists = $c->model('Image::Artist')->all;

  foreach my $artist (@artists) {
    my $an = $artist->name;
    warn "start get $an images";

    my $url = $domain . '/post/index?tags=' . $an;
    my $ua = LWP::UserAgent->new('agent' => 'Mozilla/5.0 (Windows NT 6.2; rv:21.0) Gecko/20130314 Firefox/21.0');
    my $content = $ua->get($url)->content;

    my $mt = HTML::TreeBuilder->new;
    $mt->parse($content);
    $mt->eof();

    my @items = $mt->look_down('class', 'content')->find('span');

    warn sprintf("find %d items", scalar(@items));

    # ヘッダの4個を削除
    splice(@items, 0, 4);

    foreach my $item (@items) {
      my $elem = $item->find('a');
      next if(!$elem);

      my $href = $elem->attr('href');
      my $gid = basename($href);

      # IDが既にDBに存在すれば飛ばす
      next if ($c->model('Image::Image')->find({gid => $gid}));

      my $detail_url = $domain . $href;
      $content = $ua->get($detail_url)->content;

      my $dt = HTML::TreeBuilder->new;
      $dt->parse($content);
      $dt->eof();

      # 投稿日
      my $stat = $dt->look_down(_tag => 'a', title => qr(^\d{4}-));
      my $posted = $stat ? $stat->attr('title') : undef;

      # 画像URL
      my $ie = $dt->look_down(_tag => 'a', id => 'image-link');
      my $iu = $ie->attr('href') ? $ie->attr('href') : $ie->find('img')->attr('src');

      if (defined $iu) {
        my $path = $self->saveImage($c, $an, $iu);

        $c->model('Image::Image')->create({
            gid => $gid,
            path => $path,
            posted_at => $posted,
          });
        warn "insert $gid : $path\n";
      } else {
        warn "ERROR: $gid is not found.\n";
      }
      $dt = $dt->delete;
    }
    $mt = $mt->delete;
  }
  warn "end getImages";
}

# URLで渡された画像を保存
sub saveImage {
  my $self   = shift;
  my $c      = shift;
  my $artist = shift || '__OTHER__';
  my $url    = shift;

  # ディレクトリが存在しなければ作成
  my $dir = $c->config->{image_writeout_dir} . $artist;
  mkdir $dir unless (-d $dir);

  my $path = $dir . '/' . basename($url);
  warn LWP::Simple->getstore($url, basename($url));
  #unless (LWP::Simple->getstore($url, $path)) {
  #  warn("failed store $url to $path");
  #  return undef;
  #}

  return $path;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
