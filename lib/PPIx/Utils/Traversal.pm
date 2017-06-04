package PPIx::Utils::Traversal;

use strict;
use warnings;
use Exporter 'import';
use PPI::Token::Quote::Single;
use ReadonlyX;

use PPIx::Utils::Language qw(precedence_of);
use PPIx::Utils::_Common qw(
    is_ppi_expression_or_generic_statement
    is_ppi_simple_statement
);

our $VERSION = '0.001';

our @EXPORT_OK = qw(
    first_arg parse_arg_list split_nodes_on_comma
    get_next_element_in_same_simple_statement
    get_previous_module_used_on_same_line
);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

Readonly::Scalar my $MIN_PRECEDENCE_TO_TERMINATE_PARENLESS_ARG_LIST =>
    precedence_of( 'not' );

sub first_arg {
    my $elem = shift;
    my $sib  = $elem->snext_sibling();
    return undef if !$sib;

    if ( $sib->isa('PPI::Structure::List') ) {

        my $expr = $sib->schild(0);
        return undef if !$expr;
        return $expr->isa('PPI::Statement') ? $expr->schild(0) : $expr;
    }

    return $sib;
}

sub parse_arg_list {
    my $elem = shift;
    my $sib  = $elem->snext_sibling();
    return() if !$sib;

    if ( $sib->isa('PPI::Structure::List') ) {

        #Pull siblings from list
        my @list_contents = $sib->schildren();
        return() if not @list_contents;

        my @list_expressions;
        foreach my $item (@list_contents) {
            if (
                is_ppi_expression_or_generic_statement($item)
            ) {
                push
                    @list_expressions,
                    split_nodes_on_comma( $item->schildren() );
            }
            else {
                push @list_expressions, $item;
            }
        }

        return @list_expressions;
    }
    else {

        #Gather up remaining nodes in the statement
        my $iter     = $elem;
        my @arg_list = ();

        while ($iter = $iter->snext_sibling() ) {
            last if $iter->isa('PPI::Token::Structure') and $iter eq ';';
            last if $iter->isa('PPI::Token::Operator')
                and $MIN_PRECEDENCE_TO_TERMINATE_PARENLESS_ARG_LIST <=
                    precedence_of( $iter );
            push @arg_list, $iter;
        }
        return split_nodes_on_comma( @arg_list );
    }
}

sub split_nodes_on_comma {
    my @nodes = @_;

    my $i = 0;
    my @node_stacks;
    for my $node (@nodes) {
        if (
                $node->isa('PPI::Token::Operator')
            and ($node eq ',' or $node eq '=>')
        ) {
            if (@node_stacks) {
                $i++; #Move forward to next 'node stack'
            }
            next;
        } elsif ( $node->isa('PPI::Token::QuoteLike::Words' )) {
            my $section = $node->{sections}->[0];
            my @words = split ' ', substr $node->content, $section->{position}, $section->{size};
            my $loc = $node->location;
            for my $word (@words) {
                my $token = PPI::Token::Quote::Single->new(q{'} . $word . q{'});
                $token->{_location} = $loc;
                push @{ $node_stacks[$i++] }, $token;
            }
            next;
        }
        push @{ $node_stacks[$i] }, $node;
    }
    return @node_stacks;
}

sub get_next_element_in_same_simple_statement {
    my $element = shift or return undef;

    while ( $element and (
            not is_ppi_simple_statement( $element )
            or $element->parent()
            and $element->parent()->isa( 'PPI::Structure::List' ) ) ) {
        my $next;
        $next = $element->snext_sibling() and return $next;
        $element = $element->parent();
    }
    return undef;

}

sub get_previous_module_used_on_same_line {
    my $element = shift or return undef;

    my ( $line ) = @{ $element->location() || []};

    while (not is_ppi_simple_statement( $element )) {
        $element = $element->parent() or return undef;
    }

    while ( $element = $element->sprevious_sibling() ) {
        ( @{ $element->location() || []} )[0] == $line or return undef;
        $element->isa( 'PPI::Statement::Include' )
            and return $element->schild( 1 );
    }

    return undef;
}

1;

=head1 NAME

PPIx::Utils::Traversal - Utility functions for traversing PPI documents

=head1 SYNOPSIS

    use PPIx::Utils::Traversal ':all';

=head1 DESCRIPTION

This package is a component of L<PPIx::Utils> that contains functions for
traversal of L<PPI> documents.

=head1 FUNCTIONS

All functions can be imported by name, or with the tag C<:all>.

=head2 first_arg

    my $first_arg = first_arg($element);

Given a L<PPI::Element> that is presumed to be a function call (which
is usually a L<PPI::Token::Word>), return the first argument.  This is
similar of L</parse_arg_list> and follows the same logic.  Note that
for the code:

    int($x + 0.5)

this function will return just the C<$x>, not the whole expression.
This is different from the behavior of L</parse_arg_list>.  Another
caveat is:

    int(($x + $y) + 0.5)

which returns C<($x + $y)> as a L<PPI::Structure::List> instance.

=head2 parse_arg_list

    my @args = parse_arg_list($element);

Given a L<PPI::Element> that is presumed to be a function call (which
is usually a L<PPI::Token::Word>), splits the argument expressions
into arrays of tokens.  Returns a list containing references to each
of those arrays.  This is useful because parentheses are optional when
calling a function, and PPI parses them very differently.  So this
method is a poor-man's parse tree of PPI nodes.  It's not bullet-proof
because it doesn't respect precedence. In general, I don't like the
way this function works, so don't count on it to be stable (or even
present).

=head2 split_nodes_on_comma

    my @args = split_nodes_on_comma(@nodes);

This has the same return type as L</parse_arg_list> but expects to be
passed the nodes that represent the interior of a list, like:

    'foo', 1, 2, 'bar'

=head2 get_next_element_in_same_simple_statement

    my $element = get_next_element_in_same_simple_statement($element);

Given a L<PPI::Element>, this subroutine returns the next element in
the same simple statement as defined by
L<PPIx::Utils::Classification/is_ppi_simple_statement>. If no next
element can be found, this subroutine simply returns C<undef>.

If the $element is undefined or unblessed, we simply return C<undef>.

If the $element satisfies
L<PPIx::Utils::Classification/is_ppi_simple_statement>, we return
C<undef>, B<unless> it has a parent which is a L<PPI::Structure::List>.

If the $element is the last significant element in its L<PPI::Node>,
we replace it with its parent and iterate again.

Otherwise, we return C<< $element->snext_sibling() >>.

=head2 get_previous_module_used_on_same_line

    my $element = get_previous_module_used_on_same_line($element);

Given a L<PPI::Element>, returns the L<PPI::Element> representing the
name of the module included by the previous C<use> or C<require> on
the same line as the $element. If none is found, simply returns
C<undef>.

For example, with the line

    use version; our $VERSION = ...;

given the L<PPI::Token::Symbol> instance for C<$VERSION>, this will
return "version".

If the given element is in a C<use> or <require>, the return is from
the previous C<use> or C<require> on the line, if any.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

Code originally from L<Perl::Critic::Utils> by Jeffrey Ryan Thalhammer
<jeff@imaginative-software.com> and L<Perl::Critic::Utils::PPI> by
Elliot Shank <perl@galumph.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2005-2011 Imaginative Software Systems,
2007-2011 Elliot Shank, 2017 Dan Book.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 SEE ALSO

L<Perl::Critic::Utils>, L<Perl::Critic::Utils::PPI>
