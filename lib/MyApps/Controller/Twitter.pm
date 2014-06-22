package MyApps::Controller::Twitter;
use Moose;
use namespace::autoclean;
use Net::Twitter;
use Data::Dumper;
use Encode;
use Text::MeCab;
use LWP::Simple;
use HTML::Entities;

my @ng_list = ('年','月','日','(',')','-','+',':',';','<','>','[',']','|','=','一覧','記事','>>');

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApps::Controller::Twitter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut
sub index :Path :Args(0) {
  my ($self, $c) = @_;

  my $nt = Net::Twitter->new(
    traits => [qw/API::RESTv1_1 API::Search WrapError/],
    consumer_key => $c->config->{tw_consumer_key},
    consumer_secret => $c->config->{tw_consumer_secret},
    access_token => $c->config->{tw_token},
    access_token_secret => $c->config->{tw_token_secret},
    ssl => 1,
  );

  #$nt->update('test');
  $c->stash->{timelines} = [];

  #my $tl = $nt->home_timeline({count => 20});
  my $tl = $nt->search({q=>"リクルート", lang=>"ja", page=>1, rpp=>100});
  #foreach my $tl (@$tl) {
  #  my $text = Encode::encode('utf8', $tl->{text});
  #  next if ($text =~ m/艦これ/);
  #  push @{$c->stash->{timelines}}, $text; 
  #}
}

sub hoge :Local :Args(0) {
  my ($self, $c) = @_;
  my $url = $c->req->param('url');

  if ($url) {
    $url =~ s/\s//g;
    if (!$c->model('Twitter::Mecab')->find({domain => $url})) {
      warn 'insert: ' . $url;

      $c->stash->{words} = [];
      $c->stash->{sites} = [];

      my $mec = Text::MeCab->new();
      my $encoding = Encode::find_encoding( Text::MeCab::ENCODING );

      my $content = get($url);
      $content = decode_entities($content);
      $content =~ s/<script.*?>.*?<\/script>//gs;
      $content =~ s/<.*?>//gs;
      $content = Encode::encode('utf8', $content);

      for (my $n = $mec->parse($content); $n; $n = $n->next) {
        next if ($n->stat =~ /[23]/);

        my $surface = sprintf("%s", $encoding->decode($n->surface));
        my $features = sprintf("%s", $n->feature);
        my @feature = split(/,/, $features);

        next if ($feature[0] ne '名詞');
        next if ($feature[1] eq '数');
        next if (grep {$_ eq $n->surface} @ng_list);

        $c->model('Twitter::Mecab')->create({
          word => $surface,
          num  => 1 || 0,
          domain => $url || '',
          posted_at => DateTime->now(),
        });
      }
    }
    my @words = $c->model('Twitter::Mecab')->search({'domain' => $url}, 
                                                      {rows => 20,
                                                       page => 1,
                                                     select => ['word', {count => 'word'}],
                                                         as => [qw/word word_count/],
                                                   order_by => {-desc => 'count(word)'}, 
                                                   group_by => 'word'});

    # 関連ページ検索 + stash
    my %page_hash = {};
    foreach my $word (@words) {
      my @pages = $c->model('Twitter::Mecab')->search({'word' => $word->word},
                                                      {select => ['domain'],
                                                    group_by => 'domain'});
      foreach my $page (@pages) {
        my $url = $page->domain;
        if ($page_hash{$url}) {
          $page_hash{$url} += 1;
        } else {
          $page_hash{$url} = 1;
        }
      }
      my $hash = {word => $word->word, count => sprintf("%.1f", $word->get_column('word_count') * 1.2)};
      push @{$c->stash->{words}}, $hash;
    }

    my $i = 0;
    foreach (sort { $page_hash{$b} <=> $page_hash{$a} } keys %page_hash) {
      next if ($i++ == 0);
      last if $i > 6;
      my $rate = sprintf("%d", $page_hash{$_});
      push @{$c->stash->{sites}}, {url => $_, rate => sprintf("%.2f", $rate * 0.87)};
    }
    $c->stash->{url} = $url;
  }
}

sub api :Local :Args(0) {
}
sub add :Local :Args(0) {
  my ($self, $c) = @_;
  my $user_name = $c->req->param('user_name');

  if ($user_name) {
    my $nt = Net::Twitter->new(
      traits => [qw/API::RESTv1_1/],
      consumer_key => $c->config->{tw_consumer_key},
      consumer_secret => $c->config->{tw_consumer_secret},
      access_token => $c->config->{tw_token},
      access_token_secret => $c->config->{tw_token_secret},
    );

    my $mec = Text::MeCab->new();
    my $encoding = Encode::find_encoding( Text::MeCab::ENCODING );

    my $tl = $nt->user_timeline({screen_name => $user_name, count => 1});
    foreach my $tl (@$tl) {
      my $timeline = [];
      my $text = Encode::encode('utf8', $tl->{text});
      warn 'insert: ' . $text;
      for (my $n = $mec->parse($text); $n; $n = $n->next) {
        next if ($n->stat =~ /[23]/);

        my $surface = $n->surface;
        my @feature = split(/,/, $encoding->decode($n->feature));
        my $hinshi = sprintf("%s", $feature[0]);
        #my $num = sprintf("%d", $feature[]);

        $c->model('Twitter::Twitter')->create({
            word => $surface,
            num  => 1 || 0,
            posted_at => DateTime->now(),
          });
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
