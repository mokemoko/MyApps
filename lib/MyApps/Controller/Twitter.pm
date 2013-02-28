package MyApps::Controller::Twitter;
use Moose;
use namespace::autoclean;
use Net::Twitter;
use Data::Dumper;
use Encode;

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
    traits => [qw/OAuth API::REST/],
    consumer_key => $c->config->{tw_consumer_key},
    consumer_secret => $c->config->{tw_consumer_secret},
    access_token => $c->config->{tw_token},
    access_token_secret => $c->config->{tw_token_secret},
  );

  #$nt->update('test');
  $c->stash->{timelines} = [];

  my $tl = $nt->home_timeline({count => 3});
  foreach my $tl (@$tl) {
    push @{$c->stash->{timelines}}, Encode::encode('utf8', $tl->{text}); 
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
