## mondoromy.mm
##
## DESCRIPTION
## -The main procedure of the package. Given an algebrain curve f(x,y) with x the independent variable, the procedure outputs the monodromy group and a plot of the voronoi diagram used to obtain said group.

Monodromy := proc(f, x, y, val1 :: posint := 10, showpath := true )
	local FortunesAlgorithm, PriorityQueue, Data, Edge, Bisector, intersections, SweepLine,
	#local vars
		n := algcurves[genus](f, x, y), a_n, X, Y, f_y, discrimiant, auxSet1 := {}, j, problemPts := {}, problemPtsFloat := {}, auxSet2 := {}, N, centerOfData, r, boundarySites := {}, minimalDist, val2 := 1, aux_fun1, data, tempCell, edgeData := {}, indexer := 0; 
	uses ComputationalGeometry;
		 
$include "Voronoi-Monodromy\PriorityQueue.mm"	
$include "Voronoi-Monodromy\FortunesAlgorithm.mm"
$include "Voronoi-Monodromy\Data.mm"
$include "Voronoi-Monodromy\SweepLine.mm"
$include "Voronoi-Monodromy\Bisector.mm"
$include "Voronoi-Monodromy\Edge.mm"
$include "Voronoi-Monodromy\Intersections.mm"

	print("curve:");
	print(f);
	print("genus");
	print(n);

	#Check that f is reasonable here
	#1) is f of type ?
	#2) any other thing worth checking?
	if not irreduc(f) then
		return "Not irreducible";
	fi;
	

	# Obtaining problem points Q: should f be normalized? Does that matter? Should we switch to algcurves here? 
	#f_y:=diff(expand(f),y); 
	a_n := expand( lcoeff(f, y) );
	discrimiant :=expand( discrim(f, y) ); 
	#print("f_y");
	#print(f_y);
	print("disc");
	print( discrimiant );
	print("a_n");
	print( a_n );
	# Solving discrimiant=0 External code impacts runtime here
	print("exact problem points"); 

	problemPts := allvalues~( { solve( discrimiant=0 ) } );
	problemPts := problemPts union allvalues~( { solve( a_n=0 ) } );

	print( problemPts );
	
	#convert to floats in R2
	print("converting values to two dimensional floats. This may take time"	);
	 
	auxSet1 := evalf[val1]~( problemPts );
	for j in auxSet1 do
		indexer := indexer + 1;
		#print( indexer );
	
		X :=  Re( j );
		#print( "real" );
		Y :=  Im( j );
		#print( "im" );
		problemPtsFloat := problemPtsFloat union { [ X,Y ] };
		auxSet2 := auxSet2 union { [ X, 0. ], [ 0., Y ] };
	od;
	
	
	#this is where accuracy becomes an issue. Q could we use a less explicit way to obtain these floats? This line seems redundant.
	print("there are");
	print( nops(problemPts) );
	N := nops( problemPtsFloat );
	print( N );
	print("number of problem pts (both numbers should match above)");
	print( problemPtsFloat );

	#CURRENT STATE: All problem points are processed. 

	# compute center and boundary sites 
	print("computing center of data and boundary region");
	
	centerOfData := [ add( problemPtsFloat[k][1]/N, k=1..N ), add( problemPtsFloat[k][2]/N, k=1..N ) ];

	aux_fun1 := (a,b) -> distance( [ a, b ], centerOfData );

	print("Center:");
	print( centerOfData );

	#the radius can be larger than the max so lets ensure that it is atleast of the order of 10^0 QUESTION: does radius change this impact accuracy
	r := 2*max(  evalf[val1]~( aux_fun1~( op(problemPtsFloat) ) ), 1  );
	print("radius");
	print( r );

	#we choose boundary sites at center + r*exp(j*pi/3) j=1..6
	for j from 1 to 6 do
		X := evalf[val1]( centerOfData[1] + r*cos( 1/3*Pi*j ) );
		Y := evalf[val1]( centerOfData[2] + r*sin( 1/3*Pi*j ) );
		boundarySites := boundarySites union { [ X, Y ] };
		auxSet2 :=auxSet2 union {[X,0.], [0.,Y]};
	od;

	print("accuracy needed is found by computing the minimal dist between x values and y values because we need to beable to distinguish when two components are not the same. This distance is:");
	
	#External code impacting runtime
	minimalDist := ComputationalGeometry[ClosestPointPair]( convert( auxSet2, list ) )[1]; 
	print(minimalDist);
	#assuming that the dist is never zero.
	while trunc(minimalDist)=0 do
		minimalDist := minimalDist*10;
		val2 := val2 + 1;
	end do;
	Digits := val1 + val2;
	#print("boundary sites to be inputed to algo");
	#print(boundarySites);
	
	#print("sites to be inputed to algo");
	#print(problemPtsFloat);


	#apply the algorithm
	print( "applying algorimthm now");
	data := Data();
	data :- setSites( problemPtsFloat );
	## Get edges and verts in plane
	data := FortunesAlgorithm( problemPtsFloat union boundarySites , data ):
	
	data:-getData();
	#print("The data is given below");
	#for j in data:-vertices do
	#	tempCell:=data:-cellData[j];
	#	print(plots[display]({plot(tempCell,color="Red"),plots[pointplot]({j},symbol=solidcircle,color="Red")}));
	#	edgeData:=edgeData union tempCell;
	#od;
	if showpath then
		print( plots[display]( { plot( data:-edges, color="Red" ), plots[pointplot]( data:-vertices, symbol=solidcircle, color="Red") } ) );
	fi;
end proc;