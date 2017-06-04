package PPIx::Utils::_Common;

use strict;
use warnings;
use Exporter 'import';
use ReadonlyX;
use Scalar::Util 'blessed';

our $VERSION = '0.001';

our @EXPORT_OK = qw(
    is_ppi_expression_or_generic_statement
    is_ppi_simple_statement
);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

sub is_ppi_expression_or_generic_statement {
    my $element = shift;

    return undef if not $element;
    return undef if not $element->isa('PPI::Statement');
    return 1 if $element->isa('PPI::Statement::Expression');

    my $element_class = blessed($element);

    return undef if not $element_class;
    return $element_class eq 'PPI::Statement';
}

Readonly::Hash my %SIMPLE_STATEMENT_CLASS => map { $_ => 1 } qw<
    PPI::Statement
    PPI::Statement::Break
    PPI::Statement::Include
    PPI::Statement::Null
    PPI::Statement::Package
    PPI::Statement::Variable
>;

sub is_ppi_simple_statement {
    my $element = shift or return undef;

    my $element_class = blessed( $element ) or return undef;

    return $SIMPLE_STATEMENT_CLASS{ $element_class };
}

1;

=for Pod::Coverage *EVERYTHING*
