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

# サムネURLのみ取得
sub getThumbs :Private {
  my ($self, $c) = @_;
  warn "start getThumbs\n";

  my $domain = $c->config->{image_domain};
  my @artists = $c->model('Image::Artist')->all;

  foreach my $artist (@artists) {
    my $an = $artist->name;
    warn "start get $an thumbs\n";

    my $url = $domain . '/post/index?tags=' . $an;
    my $ua = LWP::UserAgent->new('agent' => 'Mozilla/5.0 (Windows NT 6.2; rv:21.0) Gecko/20130314 Firefox/21.0');
    my $content = $ua->get($url)->content;

    my $mt = HTML::TreeBuilder->new;
    $mt->parse($content);
    $mt->eof();

    my @items = $mt->look_down('class', 'content')->find('span');

    # ヘッダの4個を削除
    splice(@items, 0, 4);

    foreach my $item (@items) {
      my $elem = $item->find('a');
      next if(!$elem);

      my $href = $elem->attr('href');
      my $gid = basename($href);

      # IDが既にDBに存在すれば飛ばす
      next if ($c->model('Image::Image')->find({gid => $gid}));

      my $thumb = $elem->find('img');
      (my $tu = $thumb->attr('src')) =~ s/^\/\//http:\/\//;
      my $path = $c->config->{image_writeout_dir} . 'thumb/' . $gid . '.jpg';
      $ua->get($tu, ':content_file' => $path);

      $c->model('Image::Image')->create({
          gid => $gid,
          aid => $artist->id,
          thumb_url  => $tu,
        });
      warn "insert $gid : $tu\n";
    }
    $mt = $mt->delete;
    sleep 1;
  }
  warn "end getThumbs\n";
}

# 画像取得処理
sub getImages :Private {
  my ($self, $c) = @_;

  warn "start getImages\n";
  my $domain = $c->config->{image_domain};
  my $gid = '3345433';

  my $url = $domain . '/post/show/' . $gid;
  warn "target = $url\n";
  #my $ua = LWP::UserAgent->new('agent' => 'Mozilla/5.0 (Windows NT 6.2; rv:21.0) Gecko/20130314 Firefox/21.0');
  my $ua = LWP::UserAgent->new;
  my $content = $ua->get($url)->content;

  my $mt = HTML::TreeBuilder->new;
  $mt->parse($content);
  $mt->eof();

  use Data::Dumper;
  warn Dumper($mt->as_text());
  ## 投稿日
  #my $stat = $mt->look_down(_tag => 'a', title => qr(^\d{4}-));
  #my $posted = $stat ? $stat->attr('title') : undef;

  # 画像URL
  my $ie = $mt->look_down(_tag => 'a', title => qr(^\d{4}-));
  warn Dumper($ie);

  $mt = $mt->delete;
  warn "end getImages\n";
}

# URLで渡された画像を保存
sub saveImage {
  my $self   = shift;
  my $c      = shift;
  my $artist = shift || '__OTHER__';
  my $url    = shift;

  # ディレクトリが存在しなければ作成
  my $dir = $c->config->{image_writeout_dir} . $artist;
  my $rel_dir = $artist . '/' . basename($url);
  mkdir $dir unless (-d $dir);

  my $path = $dir . '/' . basename($url);

  # 何故かLWP::Simple::getで501が返ってくるので暫定的にwgetを使用
  warn $url;
  if (system("wget -O $path $url > /dev/null") == -1) {
    warn("failed store $url to $path");
    return undef;
  }

  return $rel_dir;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
