Monodromy:=proc(f,x,y,percision) 
	local 
	# sub-procedures/modules
	FortunesAlgorithm, Bisector, Edge, intersections, SweepLine, Data,
	# local variables
	n, f_y, problemPtsRaw:={}, j, problemPts:={}, problemPtsFloat:={},N, centerOfData,r, boundarySites:={}, minimalDist, val:=1, aux_fun1, plotter; 
	uses ComputationalGeometry;
	with(algcurves);

$include "Voronoi-Monodromy//Bisector.mm"
$include "Voronoi-Monodromy//Edge.mm"
$include "Voronoi-Monodromy//Intersections.mm"
$include "Voronoi-Monodromy//FortunesAlgorithm.mm"
$include "Voronoi-Monodromy//SweepLine.mm"
$include "Voronoi-Monodromy//Data.mm"

#Check that f is reasonable here
if not irreduc(f) then
	return "Not irreducible";
fi;
n:=genus(f,x,y);
if n<2 then
	return "trivial Monodromy";
fi;

# Obtaining problem points Q: should f be normalized? Does that matter?

f_y:=diff(normal(f),y);
#problemPtsRawYup:=singularities(f, x, y);

#there are a few variations to the output of the solve command and this needs to be normalized Q:Or is it best to approximate from here instead of finding all roots explicitly
problemPtsRaw:={solve({f_y=0, f=0},{x,y})};

for j in problemPtsRaw do
if type(j,set) then
problemPts:=problemPts union {allvalues(rhs(j[1]))};
else
##certain polynomials will run into problems in the above line, is it better to approxmate and leave the root of command?
problemPts:=problemPts union {rhs(j)};
fi;
od;

#We want to work in R2 not in complex arithmetic so we further process, the accuracy at this point depends on the user
for j in problemPts do
problemPtsFloat:=problemPtsFloat union {[Re(j), Im(j)]};
od;

problemPtsFloat:=evalf[percision]~(problemPtsFloat);


#CURRENT STATE: Should have all problem points processed. Now we need to compute the center of the data to produce a bounding region

################################################# computer center and boundary sites Q:should center be complex number to make this snippit of code more readable?
N:=numelems(problemPtsFloat);
centerOfData:=[add(problemPtsFloat[k][1]/N,k=1..N),add(problemPtsFloat[k][2]/N,k=1..N)];

aux_fun1:=(a,b)->a+I*b-centerOfData[1]-I*centerOfData[2];

print("Center:");
print(centerOfData);

#the radius can be larger than the max so lets ensure that it is atleast of the order of 10^0 Q: does changing this impact accuracy
r:=2*max(evalf[percision]~(abs~(aux_fun1~(op(problemPtsFloat)))),1);
print("radius");
print(r);

for j from 1 to 6 do
#we choose a site to be vertices of the 6 sided polygon that approx circle centered at center so at center+ rexp(j*pi/3) j=1..6
boundarySites:=boundarySites union {[centerOfData[1]+ r*evalf[percision](cos(1/3*Pi*j)) ,centerOfData[2] + r*evalf[percision](sin(1/3*Pi*j)) ]};
od;

print("to be inputed to algo");
print(boundarySites);
print(problemPtsFloat);


#apply the algorithm
print("now applying voronoi algo");
plotter:=Data();

## Get edges and verts in plane
plotter:=FortunesAlgorithm(problemPtsFloat union boundarySites,plotter):
plotter:-sites(problemPtsFloat);

print(plots[display]({plot(plotter:-curves,color="Red"),plots[pointplot](op(plotter:-vertices),symbol=solidcircle,color="Red")}));
end proc;