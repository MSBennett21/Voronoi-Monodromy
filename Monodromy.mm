Monodromy:=proc(f,x,y,percision) local Bisector, Edge, intersections, SweepLine, Data  ,n, N, j,r, yhat, problemPtsRaw:={}, singularitiesRaw,branchPtsRaw, problemPts:={}, problemPtsFts:={},problemPtsFts1:={}, f_x, f_y, minimalDist, val:=1, center, aux_fun1, auxSites:={}, plotter; 
global FortunesAlgorithm; uses ComputationalGeometry;

$include "Bisector.mm"
$include "Edge.mm"
$include "Intersections.mm"
$include "FortunesAlgorithm.mm"
$include "SweepLine.mm"
$include "Data.mm"

#######################################################
print("Checking irreducibility and obtaining problem points");
##Check f,x,y for conditions
		if not irreduc(f) then
		return "Not irreducible";
		fi;
#################################################### Obtaining problem points


f_y:=diff(f,y);
#problemPtsRawYup:=singularities(f, x, y);

#there are a few variations to the output of the solve command
problemPtsRaw:={solve({f_y=0, f=0},{x,y})};

print("Formating data. Some curves may run into problems here.");
for j in problemPtsRaw do
if type(j,set) then
problemPts:=problemPts union {allvalues(rhs(j[1]))};
##certain polynomials will run into problems here!!!!!
else
problemPts:=problemPts union {rhs(j)};
fi;
od;
print("Conversion of problemPts completed, further refining this is also a place in which we a polynomial make not work here");
for j in problemPts do
problemPtsFts:=problemPtsFts union {[convert(evalf[percision](Re(j)), rational, exact), convert(evalf[percision](Im(j)),rational, exact)]};
od;
print(problemPtsFts);

###################################################

#CURRENT STATE: Should have all problem points processed.

################################################# Center
N:=numelems(problemPts);

if N=1 then
return "only one problem point";
		fi;
center:=[normal(add(problemPtsFts[k][1]/N,k=1..N)),normal(add(problemPtsFts[k][2]/N,k=1..N))];
aux_fun1:=(a,b)->normal(a+I*b-center[1]-I*center[2]);
print("Center:");
print(center);

r:=convert(2*max(evalf[percision](abs~(aux_fun1~(op(problemPtsFts)))),1), rational, exact);
print("radius");
print(r);

print("creating the boundary region");
for j from 1 to 6 do
#we choose a site to be vertices of the 6 sided polygon that approx circle centered at center so at center+ rexp(j*pi/3) j=1..6
auxSites:=auxSites union {[convert(evalf[percision](Re(center[1]+I*center[2]+ r*exp(1/3*I*Pi*j))),rational,exact), convert(evalf[percision](Im(center[1]+I*center[2] + r*exp(1/3*I*Pi*j))),rational,exact)]};
od;

print("Now determining distances for accuracy");

minimalDist:=ComputationalGeometry[ClosestPointPair](convert(problemPtsFts union auxSites ,list))[1]; 
print(minimalDist);
#assuming that the dist is never zero.
while trunc(minimalDist)=0 do
minimalDist:=minimalDist*10;
val:=val+1;
end do;
print("The distance between singularities requires is of the order");
print(10^(-val+1));


print("now applying voronoi algo");
plotter:=Data();

## Get edges and verts in plane

plotter:=FortunesAlgorithm(problemPtsFts union auxSites,plotter):
plotter:-sites(problemPtsFts);

print(plots[display]({plot(plotter:-curves,color="Red"),plots[pointplot](op(plotter:-vertices),symbol=solidcircle,color="Red")}));
end proc;