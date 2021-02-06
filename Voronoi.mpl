##MODULE Voronoi
##
##DESCRIPTION
## A package that computes the monodromy group of an algebraic curve using a
## bounded voronoi diagram

$define distance(a,b) sqrt((a[1]-b[1])^2+(a[2]-b[2])^2)

Voronoi := module() 
    option package; 


    export Monodromy;

$include "Voronoi-Monodromy\Monodromy.mm"

end module:
