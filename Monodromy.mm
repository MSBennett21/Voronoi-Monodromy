## mondoromy.mm
##
## DESCRIPTION
## -The main procedure of the package. Given an algebrain curve f(x,y) with x the independent variable, the procedure outputs the monodromy group and a plot of the voronoi diagram used to obtain said group.

Monodromy := proc(f,x,y, val1:: posint := 10)

	local 
	FortunesAlgorithm, PriorityQueue, Data, Edge, Bisector, intersections, SweepLine,
	#local variables
	n:=algcurves[genus](f,x,y), X, Y, f_y, problemPtsRaw:={}, j, problemPts:={}, problemPtsFloat:={}, auxSet:={}, N, centerOfData, r, boundarySites:={}, minimalDist, val2:=1, aux_fun1, data, tempCell, edgeData:={}; 
	uses ComputationalGeometry;
	
	with(algcurves):
	#Won't take algcurves in line above Q: why
	 
$include "Voronoi-Monodromy\PriorityQueue.mm"	
$include "Voronoi-Monodromy\FortunesAlgorithm.mm"
$include "Voronoi-Monodromy\Data.mm"
$include "Voronoi-Monodromy\SweepLine.mm"
$include "Voronoi-Monodromy\Bisector.mm"
$include "Voronoi-Monodromy\Edge.mm"
$include "Voronoi-Monodromy\Intersections.mm"

	#Check that f is reasonable here
	#1) is f of type ?
	#2) any other thing worth checking?
	if not irreduc(f) then
		return "Not irreducible";
	fi;
	if n<2 then
		return "trivial Monodromy";
	fi;


	# Obtaining problem points Q: should f be normalized? Does that matter? Should we switch to algcurves here? 
	f_y:=diff(normal(f),y); 

	# Solving discrimiant=0 this is one place in the code were we may have limits on what algebraic curves can be used. Q is solve the right move here?
	# There are a few variations to the output of the solve command and this needs to be normalized Q:Or is it best to approximate from here instead of finding all roots explicitly
	print("solving for explicit problem points");
	problemPtsRaw:={solve({f_y=0, f=0},{x,y})};
	for j in problemPtsRaw do
		if type(j,set) then
			problemPts:=problemPts union {allvalues(rhs(j[1]))};
		else
			problemPts:=problemPts union {rhs(j)};
		fi;
	od;

	#We want to work in R2 not in complex arithmetic so we further process, the accuracy at this point depends on the user. Perhapse we should wait to do this for later?
	print("converting values to two dimensional floats"	);
	for j in problemPts do
		X:=evalf[val1](Re(j));
		Y:=evalf[val1](Im(j));
		problemPtsFloat:=problemPtsFloat union {[X,Y]};
		auxSet:=auxSet union {[X,0.], [0.,Y]};
	od;

	#this is where accuracy becomes an issue. Q could we use a less explicit way to obtain these floats? This line seems redundant.
	#print(problemPtsFloat);

	#CURRENT STATE: All problem points are processed. 

	# compute center and boundary sites Q:should center be complex number to make this snippit of code more readable? 
	print("computing center of data and boundary region");
	N:=numelems(problemPtsFloat);
	centerOfData:=[add(problemPtsFloat[k][1]/N,k=1..N),add(problemPtsFloat[k][2]/N,k=1..N)];

	aux_fun1:=(a,b)->distance([a,b],centerOfData);

	print("Center:");
	print(centerOfData);

	#the radius can be larger than the max so lets ensure that it is atleast of the order of 10^0 Q: does changing this impact accuracy
	r:=2*max(evalf[val1]~(aux_fun1~(op(problemPtsFloat))),1);
	print("radius");
	print(r);

	#we choose boundary sites at center + r*exp(j*pi/3) j=1..6
	for j from 1 to 6 do
		X:=evalf[val1](centerOfData[1]+ r*cos(1/3*Pi*j) );
		Y:=evalf[val1](centerOfData[2]+ r*sin(1/3*Pi*j) );
		boundarySites:=boundarySites union {[X, Y ] };
		auxSet:=auxSet union {[X,0.], [0.,Y]};
	od;

	print("the amount of accuracy needed on top of the given value is found by computing the minimal dist between component values and making sure that there is enough accuracy to discren between x vals and y vals. This distance is:");
	minimalDist:=ComputationalGeometry[ClosestPointPair](convert(auxSet ,list))[1]; 
	print(minimalDist);
	#assuming that the dist is never zero.
	while trunc(minimalDist)=0 do
		minimalDist:=minimalDist*10;
		val2:=val2+1;
	end do;
	Digits:=val1+val2;
	print("boundary sites to be inputed to algo");
	print(boundarySites);
	
	print("sites to be inputed to algo");
	print(problemPtsFloat);


	#apply the algorithm
	data:=Data();
	data:-setSites(problemPtsFloat);
	## Get edges and verts in plane
	data:=FortunesAlgorithm(problemPtsFloat union boundarySites,data):
	

	data:-getData();
	print("The data is given below");
	for j in data:-vertices do
		tempCell:=data:-cellData[j];
		print(plots[display]({plot(tempCell,color="Red"),plots[pointplot]({j},symbol=solidcircle,color="Red")}));
		edgeData:=edgeData union tempCell;
	od;
	print(plots[display]({plot(edgeData,color="Red"),plots[pointplot](data:-vertices,symbol=solidcircle,color="Red")}));
end proc;