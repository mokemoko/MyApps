package MyApps::Controller::Batch;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use LWP::Simple;
use HTML::TreeBuilder;
use HTML::TreeBuilder::LibXML;
use Web::Scraper;
use File::Basename;
use File::Path;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::Batch - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

our $ua = LWP::UserAgent->new('agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0');

our $support_extension = [
  'jpg',
  'png',
  'gif',
  'webm',
];

# サムネURLのみ取得
sub getThumbs :Private {
  my ($self, $c) = @_;
  warn "start getThumbs\n";

  my $domain = $c->config->{image_domain};

  # 引数が指定されていた場合は対象を限定
  my $query = scalar(@{$c->request->args}) ? {
    name => {
      -in => [@{$c->request->args}],
    },
  } : {};

  my @artists = $c->model('Image::Artist')->search($query);

  foreach my $artist (@artists) {
    my $an = $artist->name;
    warn "start get $an thumbs\n";

    eval {
      my $url = $domain . '/post/index?tags=' . $an;
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
        my $ou = $self->getOriginURL($c, $tu);

        $c->model('Image::Image')->create({
            gid => $gid,
            aid => $artist->id,
            thumb_url  => $self->saveImage($c, $tu),
            original_url  => $self->saveImage($c, $ou),
          });
        warn "insert $gid : $tu\n";
      }
      $mt = $mt->delete;
      sleep 1;
    };

    if ($@) {
      warn "NG: unexpected error has occured !!";
    }
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
  my $content = $ua->get($url)->content;

  my $mt = HTML::TreeBuilder->new;
  $mt->parse($content);
  $mt->eof();

  ## 投稿日
  #my $stat = $mt->look_down(_tag => 'a', title => qr(^\d{4}-));
  #my $posted = $stat ? $stat->attr('title') : undef;

  # 画像URL
  my $ie = $mt->look_down(_tag => 'a', title => qr(^\d{4}-));

  $mt = $mt->delete;
  warn "end getImages\n";
}

sub getOriginURL {
  my ($self, $c, $thumb) = @_;
  $thumb =~ s/^(.*)c\d?(\.san.*)preview\/(.*)$/$1cs$2$3/;

  # 存在チェック
  foreach my $extension (@$support_extension) {
    $thumb =~ s/\.[^\/]*$/.$extension/;

    if ($ua->head($thumb)->is_success) {
      last;
    }
  }

  warn "ERROR: ORIGINAL IMAGE NOT FOUND $thumb" unless $ua->head($thumb)->is_success;

  return $thumb;
}

# URLで渡された画像を保存
sub saveImage {
  my ($self, $c, $target) = @_;

  my $uri = URI->new($target);
  my $path = $c->config->{image_writeout_dir} . $uri->path;
  (my $dir = $path) =~ s/[^\/]*$//;

  # ディレクトリが存在しなければ作成
  mkpath $dir unless (-d $dir);

  $ua->get($target, ':content_file' => $path);

  return $uri->path;
}

# Amazon仕入商材チェック
sub getStocks :Private {
  my ($self, $c) = @_;
  my $model = $c->model('Image::Stock');

  $model->update_all({flg => 0});

  my $scraper = scraper {
    process 'li.s-result-item a.s-access-detail-page', 'items[]' => { title => 'TEXT', link  => '@href' };
  };
  $scraper->user_agent($ua);

  my $res = $scraper->scrape(URI->new($c->config->{amazon_url}));

  foreach my $item (@{$res->{items}}) {
    my $rec = $model->find({title => $item->{title}})
      || $model->create($item);

    $rec->update({flg => 1});
  }
}

# 移行用
sub doTransrate :Private {
  my ($self, $c) = @_;
  my @all = $c->model('Image::Image')->all;

  my $url_base = "https://cs.sankakucomplex.com";
  my $count = 0;

  foreach my $rec (@all) {
    my $gid = $rec->gid;

    my $url = '';
    my $ou = $rec->original_url;
    my $path = $c->config->{image_writeout_dir} . $ou;

    next if (-f $path);

    warn "file($path) not found. retry getting image\n";

    foreach my $extension (@$support_extension) {
      $ou =~ s/\.[^\/]*$/.$extension/;
      $url = $url_base . $ou;

      if ($ua->head($url)->is_success) {
        $path =~ s/\.[^\/]*$/.$extension/;
        last;
      }
    }

    warn "ERROR: failed to download image $gid" unless $ua->get($url, ':content_file' => $path)->is_success;

    $rec->update({
        original_url  => $ou,
      });

    warn "transrate $gid \n";

    sleep 1;
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
