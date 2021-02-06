SweepLine := proc(pq::`module`(insert,contains,remove),out::`module`(setRay,setSegment,setLine))
   return module()
      export initialize, site, intersection, addIntersection, terminate, debug;
      local line;

      #
      # initialize - insert the supplied set of sites into the empty sweepline
      initialize := proc(sites::set([numeric,numeric]))
         local sorted, i, s, previous;
         # Sort on x
         sorted := sort([op(sites)],(s1,s2)->evalb(s1[1]<s2[1]));
         line := sorted[1];
         # For each remaining site, add a separating edge and the region to the line
         previous := sorted[1];
         for i from 2 to nops(sorted) do
            s := sorted[i];
            line := line, Edge(previous, s, Bisector(out, previous, s, true), true),s;
            previous := s;
         end do; 
         line := [line];
      end proc;

      #
      # site - process the sweepline hitting a site
      #     * locate the containing region
      #     * remove the old intersections and add the new ones
      #     * insert the new edges and the region
      site := proc(site::[numeric,numeric], yprime)
         local i,edge, region,left,right,b;
         for i from 1 to nops(line)-2 by 2 do
             edge := line[i+1];
             ASSERT(edge:-leftSite = line[i]);
             ASSERT(edge:-rightSite = line[i+2]);
             if edge:-compare(site,yprime) <= 0 then 
                break;
             end if;
         end do;
         region := line[i];
         # If we are between two edges, make sure any scheduled intersection event is removed
         if i > 1 and i < nops(line) and pq:-contains([line[i-1],line[i+1]]) then
            pq:-remove([line[i-1],line[i+1]]);
         end if;

         b := Bisector(out, region, site, false);
         left := Edge(region, site, b);
         right := Edge(site, region, b);

         # Now update the event queue with any new intersections
         if i > 1 then
            intersections(pq, line[i-1],left,yprime);
         end if;
         if i < nops(line) then
            intersections(pq, right,line[i+1],yprime);
         end if;
         line := [op(1..i,line),left,site,right,op(i..nops(line),line)];
      end proc;

      #
      # intersection - process the sweepline hitting an intersection
      #     * terminate the incoming edges
      #     * remove the incoming edges and the region
      #     * create a new outgoing edge
      #     * add intersections for the new edge and its neighbours
      intersection := proc(edges::list(`module`), yprime)
         local e1, e2, i, e, s, s1, s2, b, p, left;
         e1 := edges[1];
         e2 := edges[2];

         ASSERT(e1:-rightSite = e2:-leftSite,"Non-adjacent edges intersecting?");
         for i from 2 to nops(line)-2 by 2 do 
            if e1 = line[i] then
               break;
            end if;
         end do;

         ASSERT(i < nops(line)-2, "Failed to find intersecting edges");
         ASSERT(e2 = line[i+2],"Bad sweepline order 1");
         p := e1:-bisector:-intersects(e2:-bisector);
         ASSERT(p <> NULL,"No intersection found?");

         s := line[i+1];
         ASSERT(e1:-rightSite = s,"Bad sweepline order 2");
         e1:-endpoint(p);
         if i > 2 and pq:-contains([line[i-2],e1]) then
            pq:-remove([line[i-2],e1]);
         end if;

         e2:-endpoint(p);
         if i < nops(line)-3 and pq:-contains([e2,line[i+4]]) then
            pq:-remove([e2,line[i+4]]);
         end if;
         s1 := line[i-1];
         s2 := line[i+3];
         b := Bisector(out,s1,s2,false);
         e := Edge(s1,s2,b);
         # Register the intersection point as the starting "endpoint" by negating the direction
         b:-endpoint(p,-e:-direction);
         if i > 2 then 
            intersections(pq,line[i-2],e,yprime);
         end if;
         if i < nops(line)-3 then
            intersections(pq,e,line[i+4],yprime);
         end if;
         line := [op(1..i-1,line),e,op(i+3..nops(line),line)];
      end proc;

      #
      # terminate - process the remaining items in the tree
      #     * for each remaining internal node, produce a ray or line
      terminate := proc()
         local i;
         for i from 2 to nops(line) by 2 do
            line[i]:-emit();
         end do;
         line := [];
      end proc;

      #
      # debug - perform some basic integrity checks and print the sweepline
      debug := proc(str)
         local i;
         printf("\n%s\n   Sweep:\n",str);
         for i from 1 to nops(line) do 
            if (i mod 2) = 0 then
               printf("      %s\n",line[i]:-debug());
            else
               printf("      Site: %a\n",line[i]);
            end if;
         end do;
      end proc;
   end module;
end proc:
