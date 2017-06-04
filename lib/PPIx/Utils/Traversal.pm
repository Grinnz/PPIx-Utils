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
    return undef if !$sib;

    if ( $sib->isa('PPI::Structure::List') ) {

        #Pull siblings from list
        my @list_contents = $sib->schildren();
        return undef if not @list_contents;

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

L<Perl::Critic::Utils>, L<Perl::Critic::Utils::PPI>
