#############################################################################
##
##  LinearSystems.gi            Sheaves package              Mohamed Barakat
##
##  Copyright 2008-2009, Mohamed Barakat, University of Kaiserslautern
##
##  Implementation stuff for linear systems.
##
#############################################################################

# a new representation for the GAP-category IsLinearSystem

##  <#GAPDoc Label="IsLinearSystemRep">
##  <ManSection>
##    <Filt Type="Representation" Arg="L" Name="IsLinearSystemRep"/>
##    <Returns>true or false</Returns>
##    <Description>
##      The &GAP; representation of linear systems. <P/>
##      (It is a representation of the &GAP; category <Ref Filt="IsLinearSystem"/>.)
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsLinearSystemRep",
        IsLinearSystem,
        [ "module", "HomalgRingOfUnderlyingGradedModule" ] );

####################################
#
# families and types:
#
####################################

# a new family:
BindGlobal( "TheFamilyOfLinearSystems",
        NewFamily( "TheFamilyOfLinearSystems" ) );

# a new type:
BindGlobal( "TheTypeLinearSystems",
        NewType( TheFamilyOfLinearSystems,
                IsLinearSystemRep ) );

####################################
#
# methods for operations:
#
####################################

##
InstallMethod( UnderlyingGradedModule,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return L!.module;
    
end );

##
InstallMethod( HomalgRing,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return HomalgRing( UnderlyingGradedModule( L ) );
    
end );

##
InstallMethod( GeneratorsOfLinearSystem,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return GeneratorsOfModule( UnderlyingGradedModule( L ) );
    
end );

##
InstallMethod( HomalgRingOfUnderlyingGradedModule,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return L!.HomalgRingOfUnderlyingGradedModule;
    
end );

##
InstallMethod( MatrixOfGenerators,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return MatrixOfGenerators( UnderlyingGradedModule( L ) );
    
end );

##
InstallMethod( Degree,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return DegreeOfLinearSystem( L );
    
end );

##
InstallMethod( InducedRingMap,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    local S, T, images, phi;
    
    ## the source ring
    S := AssociatedGradedPolynomialRing( L );
    
    ## the target ring
    T := HomalgRingOfUnderlyingGradedModule( L );
    
    ## the substitutions
    images := MatrixOfGenerators( L );
    
    if NrRows( images ) <> 1 and NrColumns( images ) <> 1 then
        Error( "the matrix of images is neither a one-row nor a one-column matrix\n" );
    fi;
    
    images := EntriesOfHomalgMatrix( images );
    
    phi := RingMap( images, S, T );
    
    SetDegreeOfMorphism( phi, 0 );
    
    return phi;
    
end );

##
InstallMethod( InducedMorphismToProjectiveSpace,
        "for linear systems",
        [ IsLinearSystem ],
        
  function( L )
    
    return Proj( InducedRingMap( L ) );
    
end );

####################################
#
# constructor functions and methods:
#
####################################

##
InstallMethod( AsLinearSystem,
        "constructor for linear systems",
        [ IsGradedModuleRep and HasEmbeddingOfSubmoduleGeneratedByHomogeneousPart,
          IsString ],
        
  function( M, x )
    local S, L, dim;
    
    S := HomalgRing( EmbeddingOfSubmoduleGeneratedByHomogeneousPart( M ) );
    
    L := rec( module := M,
              HomalgRingOfUnderlyingGradedModule := S,
              );
    
    dim := NrGenerators( M );
    
    ObjectifyWithAttributes(
            L, TheTypeLinearSystems,
            Dimension, dim - 1
            );
    
    L!.variable_name := x;
    
    return L;
    
end );

##
InstallMethod( AsLinearSystem,
        "constructor for linear systems",
        [ IsGradedModuleRep and HasUnderlyingSubobject,
          IsString ],
        
  function( M, x )
    local V, S, L, dim;
    
    V := SuperObject( UnderlyingSubobject( M ) );
    
    if not HasEmbeddingOfSubmoduleGeneratedByHomogeneousPart( V ) then
        TryNextMethod( );
    fi;
    
    S := HomalgRing( EmbeddingOfSubmoduleGeneratedByHomogeneousPart( V ) );
    
    L := rec( module := M,
              HomalgRingOfUnderlyingGradedModule := S,
              );
    
    dim := NrGenerators( M );
    
    ObjectifyWithAttributes(
            L, TheTypeLinearSystems,
            Dimension, dim - 1
            );
    
    L!.variable_name := x;
    
    return L;
    
end );

##
InstallMethod( AsLinearSystem,
        "constructor for linear systems",
        [ IsGradedModuleRep ],
        
  function( M )
    
    return AsLinearSystem( M, "x" );
    
end );

####################################
#
# View, Print, and Display methods:
#
####################################

##
InstallMethod( ViewObj,
        "for linear systems",
        [ IsLinearSystemRep ],
        
  function( L )
    local dim;
    
    Print( "<A" );
    
    if HasIsComplete( L ) then
        if IsComplete( L ) then
            Print( " complete" );
        else
            Print( "n incomplete" );
        fi;
    fi;
    
    Print( " linear system" );
    
    if HasDimension( L ) then
        dim := Dimension( L );
        Print( " of dimension ", dim );
        if dim = 1 then
            Print( " (pencil)" );
        elif dim = 2 then
            Print( " (net)" );
        elif dim = 3 then
            Print( " (web)" );
        fi;
    fi;
    
    Print( ">" );
    
end );

##
InstallMethod( ViewObj,
        "for linear systems",
        [ IsLinearSystemRep and IsEmpty ],
        
  function( L )
    
    Print( "<An empty linear system>" );
    
end );

##
InstallMethod( Display,
        "for linear systems",
        [ IsLinearSystemRep ],
        
  function( L )
    local M, dim;
    
    M := UnderlyingGradedModule( L );
    
    Display( MatrixOfGenerators( M ) );
    
    dim := NrGenerators( M );
    
    Print( "\na linear system generated by the " );
    
    if dim <> 1 then
        Print( dim, " " );
    fi;
    
    if IsHomalgLeftObjectOrMorphismOfLeftObjects( M ) then
        Print( "row" );
    else
        Print( "column" );
    fi;
    
    if dim <> 1 then
        Print( "s" );
    fi;
    
    Print( " of the above matrix\n" );
    
end );
