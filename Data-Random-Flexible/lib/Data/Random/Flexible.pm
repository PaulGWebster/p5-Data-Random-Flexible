package Data::Random::Flexible;

use 5.010;
use strict;
use warnings;

BEGIN {
    eval {
        require Math::Random::Secure; 
    };
    if (!$@) {
        Math::Random::Secure->import('rand'); 
    }
}

=head1 NAME

Data::Random::Flexible - Fast flexible profilable randoms

=head1 VERSION

Version 1.02

=cut

our $VERSION = '1.02';


=head1 SYNOPSIS

A more flexible set of randoms for when you want to be random FAST

    use Data::Random::Flexible;

    my $random = Data::Random::Flexible->new();

    say "32 Character random of numbers?, sure: ".$random->int(32);

    say "16 Character random of letters?, sure: ".$random->char(16);

    say "16 Of a mixture of numbers and letters?, sure: ".$random->mix(16);

    say "Random mixture of 16 your own characters?, sure: ".$random->profile('irc',16, [qw(a b c 1 2 3)]);
    
    say "Random mixture of 16 your own characters from a saved profile?, sure: ".$random->profile('irc',16);

=head1 new()

Create a new Math::Random::Flexible object, accepts 1 optional argument, a hashref of profiles

=cut

sub new {
    my ($class,$profiles) = @_;
    $profiles = {} if (!$profiles);

    return bless { profiles=>$profiles }, $class;
}

=head1 store()

Set and/or return the stored profiles, will always return the currently used profiles,
unless you pass it something it did not expect as a first argument, where it will return
a blank hashref. 

=cut 

sub store {
    my ($self,$new_profiles) = @_;

    if (!$new_profiles) {
        return $self->{profiles};
    }
    elsif (ref $new_profiles ne 'HASH') {
        warn "First argument for profiles() must be a hashref!";
        return {};
    }
    else {
        $self->{profiles} = $new_profiles;
    }

    return $self->{profiles};
}

=head1 alpha()

Return a random alpha character uppercase or lowercase, accepts 1 argument 'length',
if length is ommited return a single alpha-char;

=head2 char()

Though technically wrong, its a shorthand to alpha()

=cut

sub char { 
    return alpha(@_)
}

sub alpha {
    my ($self,$length) = @_;

    if ( !defined $length || $length !~ m#^\d+$# ) {
        $length = 1;
    }
    elsif (!$length) {
        # If we got 0 passed as a length
        return;
    }

    my $randAlpha = "";

    for ( 1..$length ) {
        my $key = 'a';
        for ( 1..CORE::int(rand(26)) ) { $key++ }
        if ( CORE::int(rand(2)) ) { $key = uc($key) }
        $randAlpha .= $key;
    }

    return $randAlpha;
}

=head1 numeric()

Return a random whole number, accepts 1 argument 'length', if length is ommited 
return a single number.

=head2 int()

A shorthand for numeric()

=cut

sub int {
    return numeric(@_);
}

sub numeric {
    my ($self,$length) = @_;

    if ( !defined $length || $length !~ m#^\d+$# ) {
        $length = 1; 
    }
    elsif (!$length) {
        # If we got 0 passed as a length
        return;
    }

    # Never allow the first number to be a 0 as it does not
    # really exist as a prefixed number.
    my $randInt = 1+CORE::int(rand(9));
    $length--;

    for (1..$length) {
        $randInt .= CORE::int(rand(10));
    }

    return $randInt;
}

=head1 alphanumeric()

Return a random alphanumeric string, accepts 1 argument 'length', if length is ommited
return a single random alpha or number.

=head2 mix()

A shorthand for alphanumeric()

=cut

sub mix {
    return alphanumeric(@_);
}

sub alphanumeric {
    my ($self,$length) = @_;

    if ( !defined $length || $length !~ m#^\d+$# ) {
        $length = 1;
    }
    elsif (!$length) {
        # If we got 0 passed as a length
        return;
    }

    my $randAN = "";

    for ( 1..$length) {
        if ( CORE::int(rand(2)) ) { $randAN .= $self->numeric() }
        else                { $randAN .= $self->alpha() }
    }

    return $randAN;
}

=head1 profile()

Set or adjust a profile of characters to be used for randoms, accepts 3 arguments in
the following usages:

Create or edit a profile named some_name and return a 16 long string from it

$random->profile('some_name',16,[qw(1 2 3)]);


Return 16 chars from the pre-saved profile 'some_name'

$random->profile('some_name',16);


Delete a stored profile

$random->profile('some_name',0,[]);

=cut

sub profile {
    my ($self,$profile_name,$length,$charset) = @_;

    if ( !defined $length || $length !~ m#^\d+$# ) {
        $length = 1;
    }
    elsif (!$length) {
        # If we got 0 passed as a length
        return;
    }

    # Maybe we are adding or overwriting a profile
    if ( $charset ) {
        if ( ref $charset ne 'ARRAY' ) {
            warn "Charset MUST be an arrayref!";
            return;
        }
        elsif ( scalar @{ $charset } == 0 ) {
            return delete $self->{profiles}->{$profile_name};
        }

        $self->{profiles}->{$profile_name} = $charset;

        return $self->profile( $profile_name, $length );
    }

    # Ok lets check we have the profile, if not return nothing
    if (! $self->{profiles}->{$profile_name} ) {
        return " "x$length;
    }

    # All looks good..
    my $randProf = "";
    my $key_max = scalar @{ $self->{profiles}->{$profile_name} };

    for ( 1..$length ) {
        $randProf .= $self->{profiles}->{$profile_name}->[ CORE::int( rand( $key_max ) ) ];
    }

    return $randProf;
}


=head1 AUTHOR

Paul G Webster, C<< <daemon at cpan.org> >>

=head1 BUGS

Please report any bugs to: L<https://github.com/PaulGWebster/p5-Data-Random-Flexible>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc p5::Data::Random::Flexible


You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/p5-Data-Random-Flexible>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/p5-Data-Random-Flexible>

=item * Search CPAN

L<http://search.metacpan.org/dist/p5-Data-Random-Flexible/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Paul G Webster.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Paul G Webster's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of p5::Data::Random::Flexible
