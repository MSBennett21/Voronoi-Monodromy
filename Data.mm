Data:= proc()
   local this; uses ListTools, GraphTheory, plots;
   this := module()
# exported procedures/modules
      export setSites, setVertex, setSegment, setRay, setLine, getData,
      # exported variables
       edges:= {}, vertices := {}, cellData := table(), vertexEdgeData := table(), edgeSiteData := table(), sitesOfDiagram:={}, cycleData := table();
      # local procedures/modules
      local generateCell, generateCells, canonicalVert, produceCycle,
      # local vars
      curves := {}, e, s, G;

      # sets the sites of the diagram. Expected input is a set and since users do not access it, there is no need to catch errors
      setSites := proc(site) 
         sitesOfDiagram := site;
         return this;
      end proc;

      # sets the sites of the diagram. Expected input is a set and since users do not access it, there is no need to catch errors      
      setSegment := proc(x1,y1,x2,y2,s1,s2) 
      local temp;
         temp:=[[x1,y1],[x2,y2]];
         curves := curves union {temp};
         edges:=edges union {{op(temp)}};
         edgeSiteData[{op(temp)}]:={s1,s2};
         vertices := vertices union { temp[1], temp[2] };
         if assigned( vertexEdgeData[ temp[1]] ) then 
            vertexEdgeData[ temp[1]] :=  vertexEdgeData[ temp[1]] union { {op(temp)} };
            #print("there should be two");
            #print(vertexEdgeData[pt1]);
         else
            vertexEdgeData[ temp[1]] :=  { {op(temp)} };
         fi;
         if assigned( vertexEdgeData[ temp[2]] ) then 
            vertexEdgeData[ temp[2] ] :=  vertexEdgeData[temp[2]] union { {op(temp)} };
         else
            vertexEdgeData[temp[2]] :=  {{op(temp)} };
         fi;

         return this;
      end proc;
      #Determines vertex to be called canonical
      #In our case, we will take a the vertex with the smallest x value, and then the smallest y
      #as we said above this is not user interactive so we need not catch errors
      canonicalVert := proc(V)
         local w ,v := V[1]; #start with an arbitrary vert
         #print("the canonical vert for");
         #print(V);
         #print("is");
         for w in V do
            # if both verts of the edge have a larger x then nothing to do
            if w[1] > v[1] then
               break;
            else
            #otherwise if the first vert either has smaller x val or the same x val and smaller y replace
               if ( w[1] = v[1] and w[2] < v[2] ) or w[1] < v[1]  then
                  v := w;
               end;
            end;               
         od;
         #print(v);
         return v;
      end proc;
   #Takes a vert of the graph and makes a cycle out of it. The graph in question has obvious constraints on it in the context of what we are doing
      produceCycle := proc( pt, E);
         local crtEdge, crtPt, nxtEdge, nxtPt, walk := [], auxEdgeSet, auxEdge, auxSet;
         #print("producing cycle for");
         #print(pt);
         #print("with ");
         
         #intialize: We need a current edge, we need to know the direction is correct.
         auxEdgeSet := E; #we need a set to remove edges from
         #print(auxEdgeSet);
         auxSet := E intersect vertexEdgeData[pt]; # need to start with set of edges that contain the starting pt
      
         #print("first set of edges COMES FROM"         );
         #print(vertexEdgeData[pt]);
         #print("and is");
         #print(auxSet);
         crtPt := pt; #starting pt is current pt
         # for the curent edge we have two choices and only one is correct. The choice of pt is cannoical (so smallest x, smallest y). This and a simple argument about lines show that the correct direction
         # will be obtained (CCW of course) by taking the edge with the property that the other end pt has the smallest y value
         
         #if the first edge in this set has ending vert of y value less than the ending vert of the others y value it is the edge we need
         if op( auxSet[1] minus {crtPt})[2]< op( auxSet[2] minus {crtPt})[2] then
            crtEdge:= [crtPt,op( (auxSet[1] minus {crtPt}) )]; #need to start with one of the two choices for edge paths. it must start at pt. because edge data is a set the end pt is just the arbitrary edge minus the start pt. We convert this to a directed edge.
         else
            crtEdge:= [crtPt,op( (auxSet[2] minus {crtPt}) )];
         fi;
         
         #SCRATCH
         #crtEdgeVector := <crtEdge[2][1]-crtEdge[1][1], crtEdge[2][2]-crtEdge[1][2]>; #used to calculate orientation of path
         #assuming that pt is chosen in the canonical way, the direction we must travel is in the positive x and negative y. More testing needs to be done, but this appears to be a charachterization
         #if not( crtEdgeVector[1]>0 and crtEdgeVector[2]<0) then 
         #   crtEdge:= [crtPt,op( (auxSet[2]) minus {crtPt})];
         #   crtEdgeVector := <crtEdge[2][1]-crtEdge[1][1], crtEdge[2][2]-crtEdge[1][2]>;
         #fi;
         
         walk := [crtEdge];
         #Intialization is complete
         #print("starting walk");
         #print(walk);
         auxEdgeSet := auxEdgeSet minus { {op(crtEdge)} }; #the directed edge now needs to be converted and then removed from our set of edges
         #print(auxEdgeSet);
         # we can now inductively continue. while the set is not empty, choose the two set collection of edges that correspond to the nxt pt. The current edge is in this set so remove it to determine the direction
         # we are traveling. then update location and remove the edge from our collection.
         while not( auxEdgeSet = {} ) do
            nxtPt := crtEdge[2]; #travel down edge
         #   print(nxtPt);
         #   print( auxEdgeSet intersect vertexEdgeData[ nxtPt]);
            auxEdge := op( auxEdgeSet intersect vertexEdgeData[ nxtPt ] ); #there are only two edges that contain the nxt pt: the current edge and the one we need-we already removed the current edge
            nxtEdge := [nxtPt, op( auxEdge minus { nxtPt } ) ] ; #edges are stored as {pt1, pt2} so this is op({pt})=pt
            walk := [op(walk), nxtEdge];
         #   print("updated walk");
         #   print(walk);
            #update location
            crtPt := crtEdge[1];
            crtEdge := nxtEdge;
            #remove from list
            auxEdgeSet := auxEdgeSet minus { {op(crtEdge)} }
         od;       
         return walk;

      end proc;




   #Determines vertex to be called canonical
      #In our case, we will take a the vertex with the smallest x value, and then the smallest y
      #as we said above this is not user interactive so we need not catch errors
      

     
     
   
      # for a site collect edges that form cell. Take verts of cell and choose canonical one. Then arrange edges as directed cycle starting at canonical choice. The output is a ordered tuple: the canonical pt, and a ordered tuple that represents the path around the site.
      generateCell := proc(site)
         local auxSet := {}, auxSet1 := {}, auxSet2 := {}, pt;
         #print(edges);
         #print("generating cell for");
         #print(site);
         for e in edges do
         #print("edge data");
         #print(e);
         #print(edgeSiteData[e]);
         #print(evalb(site in edgeSiteData[e]) );
            if site in edgeSiteData[e] then
               auxSet := {e} union auxSet;
               auxSet1 := {[op(e)]} union auxSet1;
               auxSet2 := {op(e)} union auxSet2;
            fi;
         od;
         pt := canonicalVert(auxSet2);
         #print(plot(auxSet1));
         #print(auxSet);
         cellData[site] := [pt, produceCycle(pt, auxSet)];
         #print(plot(cellData[site][2]));
      end proc;

      generateCells := proc()
         for s in sitesOfDiagram do
            generateCell(s);
         od;
      end proc;

      # the output will be [P1,P2,P3] P1 is the cannonical pt of the diagram, P2 is an ordered tuple of sites ordered by angle of cannonical-site, P3 is the table of cell data, P4 is the complete cycle table
      
      #we make use of maple-implimented algorithms. The graph theory package. To do this, we must associate each vertice of the diagram to a number--an ordering. We make a graph with no edges but |V| nodes each corresponding to an vert.
      # from here we need to add the edges. Runtime analysis might be good here. We then have a graph with undirected. 
      # to create the cycles, we take the cell data and concatenate it onto two other paths. After obtaining this data, we enumerate the sites according to ascending argument
      getData := proc()
         local auxSet1, auxSet2, i, j, k, v, p1 := [], p2, p3, P:=[], Q :=[];
         #print(plot(curves));
         #intialization
         generateCells(); # construct cell data
         auxSet1 := convert( vertices, list ); # enumerate the list
         v := canonicalVert( vertices );
         G := Graph( nops(auxSet1) );
         for e in edges do
            i:=Search( e[1], auxSet1 );
            j:=Search( e[2], auxSet1 );
            AddEdge( G, {i,j} );
         od;
         #print("graph");
         #print((DrawGraph(G, layout=planar)));
         k:= Search( v, auxSet1 ); # convert the canonical one
         #print(k);
         for s in sitesOfDiagram do
            i :=  Search( cellData[s][1], auxSet1 );
          #  print(assigned(cellData[s]));
           # print(cellData[s][1]);
           # print(auxSet1);
           # print({k,i});
            auxSet2 := auxSet1[ ShortestPath( G, k, i) ];
            for j from 1 to nops(auxSet2)-1 do
               p1 := [op(p1), [ auxSet2[j], auxSet2[j+1] ] ];
            od;
            p2 := cellData[s][2];
             print(display({plot({op(p1), op(p2)}, color="Red"), pointplot([v,s], symbol=solidcircle, color="Red")}));
            p3 := Reverse(p1);
            P := [ op(P), [op(p1), op(p2), op(p3)] ];
           
            Q := [op(Q), p2];
            p1:=[];
         od;
         return [v, sitesOfDiagram, P, Q];
      end proc;


  #NOT USED IN OUR IMPLIMENTATION
      setRay := proc( x, y, dx, dy, s1, s2) 
        # local mult;
        # mult := range/evalf(sqrt(dx^2+dy^2)); 
        # curves := curves union {[[x,y],[x+mult*dx,y+mult*dy]]};
        return this;
      end proc;
      #NOT USED IN OUR IMPLIMENTATION
      setLine := proc( x, y, dx, dy, s1, s2 )
        # local mult;
        # mult := range/evalf(sqrt(dx^2+dy^2)); # ensure the line extends to the edges
        # curves := curves union {[[x-mult*dx,y-mult*dy],[x+mult*dx,y+mult*dy]]};
         return this;
      end proc;
   

    

   end module;
end proc:
