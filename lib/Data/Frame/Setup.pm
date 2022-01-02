package Data::Frame::Setup;

# ABSTRACT: Import stuffs into Data::Frame classes

use 5.016;
use warnings;

use utf8;
use feature ':5.16';

use Import::Into;

use Carp;
use Data::Dumper ();
use Function::Parameters 2.001003;
use PDL::Lite ();   # PDL::Lite is the minimal to get PDL work
use Ref::Util 0.204           ();
use Safe::Isa 1.000009        ();
use Feature::Compat::Try ();
use boolean ();

use Moo 2.003004 ();
use Moo::Role ();

use List::AllUtils qw(uniq);

use Data::Frame::Autobox ();

use Role::Tiny ();
Role::Tiny->apply_roles_to_package( 'PDL', 'Data::Frame::PDL' );

# PDL versions between 2.040 and 2.054 has not PDL::Core::at_c
unless (defined &PDL::Core::at_c) {
    *PDL::Core::at_c = \&{"PDL::Core::at_bad_c"};
}

sub import {
    my ( $class, @tags ) = @_;

    unless (@tags) {
        @tags = qw(:base);
    }
    $class->_import( scalar(caller), @tags );
}

sub _import {
    my ( $class, $target, @tags ) = @_;

    for my $tag ( uniq @tags ) {
        $class->_import_tag( $target, $tag );
    }
}

sub _import_tag {
    my ( $class, $target, $tag ) = @_;

    if ( $tag eq ':base' ) {
        strict->import::into($target);
        warnings->import::into($target);
        utf8->import::into($target);
        feature->import::into( $target, ':5.16' );

        Carp->import::into($target);
        Data::Dumper->import::into($target);
        Function::Parameters->import::into($target);
        Ref::Util->import::into($target);
        Safe::Isa->import::into($target);
        Feature::Compat::Try->import::into($target);
        boolean->import::into($target);

        Data::Frame::Autobox->import::into($target);
    }
    elsif ( $tag eq ':class' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moo->import::into($target);
        # repeating to unimport warning experimental::try
        Feature::Compat::Try->import::into($target);
    }
    elsif ( $tag eq ':role' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moo::Role->import::into($target);
        # repeating to unimport warning experimental::try
        Feature::Compat::Try->import::into($target);
    }
    else {
        croak qq["$tag" is not exported by the $class module\n];
    }
}

1;

__END__

=head1 SYNOPSIS

    use Data::Frame::Setup;

=head1 DESCRIPTION

This module is a building block of classes in the Data::Frame project.
It uses L<Import::Into> to import stuffs into classes, thus largely removing 
the annoyance of writing a lot "use" statements in each class.

=head1 SEE ALSO

L<Import::Into>

