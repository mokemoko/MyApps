package MyApps::Controller::Twitter;
use Moose;
use namespace::autoclean;
use Net::Twitter;
use Data::Dumper;
use Encode;
use Text::MeCab;

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
    traits => [qw/API::RESTv1_1/],
    consumer_key => $c->config->{tw_consumer_key},
    consumer_secret => $c->config->{tw_consumer_secret},
    access_token => $c->config->{tw_token},
    access_token_secret => $c->config->{tw_token_secret},
  );

  my $mec = Text::MeCab->new();
  my $encoding = Encode::find_encoding( Text::MeCab::ENCODING );

  #$nt->update('test');
  $c->stash->{timelines} = [];

  #my $tl = $nt->home_timeline({count => 3});
  my $tl = $nt->user_timeline({screen_name => 'healer0120', count => 1});
  foreach my $tl (@$tl) {
    my $timeline = [];
    my $text = Encode::encode('utf8', $tl->{text});
    #warn $text;
    my $n = $mec->parse($text);
    my $str = $n->surface;
    my @feature = split(/,/, $encoding->decode($n->feature));
    my $prev_hinshi = sprintf("%s", $feature[0]);
    $n = $n->next;
    for (; $n; $n = $n->next) {
      next if ($n->stat =~ /[23]/);
      my $surface = $n->surface;
      @feature = split(/,/, $encoding->decode($n->feature));
      my $hinshi = sprintf("%s", $feature[0]);
      if ($hinshi ne $prev_hinshi) {
        push @$timeline, $str; 
        $str = '';
        warn $hinshi;
      }
      $str .= $surface;
      $prev_hinshi = $hinshi;
    }
    push @$timeline, $str; 
    push @{$c->stash->{timelines}}, $timeline; 
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
