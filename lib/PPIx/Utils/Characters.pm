package PPIx::Utils::Characters;

use strict;
use warnings;
use Exporter 'import';
use ReadonlyX;

our $VERSION = '0.001';

our @EXPORT_OK = qw(
    $COLON
    $COMMA
    $DQUOTE
    $EMPTY
    $EQUAL
    $FATCOMMA
    $PERIOD
    $PIPE
    $QUOTE
    $BACKTICK
    $SCOLON
    $SPACE
    $SLASH
    $BSLASH
    $LEFT_PAREN
    $RIGHT_PAREN
);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

Readonly::Scalar our $COMMA        => q{,};
Readonly::Scalar our $EQUAL        => q{=};
Readonly::Scalar our $FATCOMMA     => q{=>};
Readonly::Scalar our $COLON        => q{:};
Readonly::Scalar our $SCOLON       => q{;};
Readonly::Scalar our $QUOTE        => q{'};
Readonly::Scalar our $DQUOTE       => q{"};
Readonly::Scalar our $BACKTICK     => q{`};
Readonly::Scalar our $PERIOD       => q{.};
Readonly::Scalar our $PIPE         => q{|};
Readonly::Scalar our $SPACE        => q{ };
Readonly::Scalar our $SLASH        => q{/};
Readonly::Scalar our $BSLASH       => q{\\};
Readonly::Scalar our $LEFT_PAREN   => q{(};
Readonly::Scalar our $RIGHT_PAREN  => q{)};
Readonly::Scalar our $EMPTY        => q{};

1;

=head1 NAME

PPIx::Utils::Characters - Character constants

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Maintained by Dan Book <dbook@cpan.org>

Code originally from L<Perl::Critic::Utils> and L<Perl::Critic::Utils::PPI> by
Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2005-2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 SEE ALSO

L<Perl::Critic::Utils>
