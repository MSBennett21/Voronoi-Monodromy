$define distance(a,b) sqrt((a[1]-b[1])^2+(a[2]-b[2])^2)

Voronoi:=module() 
option package; 


export 
    Monodromy,
    PriorityQueue;



$include "Voronoi-Monodromy//Monodromy.mm"
$include "Voronoi-Monodromy//PriorityQueue.mm"


end module:
