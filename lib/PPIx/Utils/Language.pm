package PPIx::Utils::Language;

use strict;
use warnings;
use Exporter 'import';
use ReadonlyX;

our $VERSION = '0.001';

our @EXPORT_OK = qw(precedence_of);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

Readonly::Hash my %PRECEDENCE_OF => (
    '->'   => 1,
    '++'   => 2,
    '--'   => 2,
    '**'   => 3,
    '!'    => 4,
    '~'    => 4,
    '\\'   => 4,
    '=~'   => 5,
    '!~'   => 5,
    '*'    => 6,
    '/'    => 6,
    '%'    => 6,
    'x'    => 6,
    '+'    => 7,
    '-'    => 7,
    '.'    => 7,
    '<<'   => 8,
    '>>'   => 8,
    '-R'   => 9,
    '-W'   => 9,
    '-X'   => 9,
    '-r'   => 9,
    '-w'   => 9,
    '-x'   => 9,
    '-e'   => 9,
    '-O'   => 9,
    '-o'   => 9,
    '-z'   => 9,
    '-s'   => 9,
    '-M'   => 9,
    '-A'   => 9,
    '-C'   => 9,
    '-S'   => 9,
    '-c'   => 9,
    '-b'   => 9,
    '-f'   => 9,
    '-d'   => 9,
    '-p'   => 9,
    '-l'   => 9,
    '-u'   => 9,
    '-g'   => 9,
    '-k'   => 9,
    '-t'   => 9,
    '-T'   => 9,
    '-B'   => 9,
    '<'    => 10,
    '>'    => 10,
    '<='   => 10,
    '>='   => 10,
    'lt'   => 10,
    'gt'   => 10,
    'le'   => 10,
    'ge'   => 10,
    '=='   => 11,
    '!='   => 11,
    '<=>'  => 11,
    'eq'   => 11,
    'ne'   => 11,
    'cmp'  => 11,
    '~~'   => 11,
    '&'    => 12,
    '|'    => 13,
    '^'    => 13,
    '&&'   => 14,
    '//'   => 15,
    '||'   => 15,
    '..'   => 16,
    '...'  => 17,
    '?'    => 18,
    ':'    => 18,
    '='    => 19,
    '+='   => 19,
    '-='   => 19,
    '*='   => 19,
    '/='   => 19,
    '%='   => 19,
    '||='  => 19,
    '&&='  => 19,
    '|='   => 19,
    '&='   => 19,
    '**='  => 19,
    'x='   => 19,
    '.='   => 19,
    '^='   => 19,
    '<<='  => 19,
    '>>='  => 19,
    '//='  => 19,
    ','    => 20,
    '=>'   => 20,
    'not'  => 22,
    'and'  => 23,
    'or'   => 24,
    'xor'  => 24,
);

sub precedence_of {
    my $elem = shift;
    return if !$elem;
    return $PRECEDENCE_OF{ ref $elem ? "$elem" : $elem };
}

1;

=head1 NAME

PPIx::Utils::Language - Utility functions for PPI related to the Perl language

=head1 SYNOPSIS

    use PPIx::Utils::Language ':all';

=head1 DESCRIPTION

This package is a component of L<PPIx::Utils> that contains functions
related to aspects of the Perl language.

=head1 FUNCTIONS

All functions can be imported by name, or with the tag C<:all>.

=head2 precedence_of

    my $precedence = precedence_of($element);

Given a L<PPI::Token::Operator> or a string, returns the precedence of
the operator, where 1 is the highest precedence.  Returns undef if the
precedence can't be determined (which is usually because it is not an
operator).

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

Code originally from L<Perl::Critic::Utils> by Jeffrey Ryan Thalhammer
<jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2005-2011 Imaginative Software Systems,
2017 Dan Book.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 SEE ALSO

L<Perl::Critic::Utils>
