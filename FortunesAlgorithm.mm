FortunesAlgorithm := proc(sites::set([numeric,numeric]), out::`module`(setSegment,setRay,setLine)) 
   local pq, ycurrent, yprime, first, s, sweepline, event;
   pq := PriorityQueue();



   sweepline := SweepLine(pq, out);
   # First add the original sites to the priority queue
   map(p->(pq:-insert(p,p[2])), sites);

   # Get the set of sites with lowest y value and add them to the sweepline
   first, ycurrent := pq:-pop(true);
   first := {first};
   while not pq:-empty() do
      s,yprime := pq:-head(true);
      if yprime = ycurrent then
         first := first union {s};
         pq:-pop();
      else 
         break;
      end if
   end do;

   sweepline:-initialize(first);

   while not pq:-empty() do
      event,yprime := pq:-pop(true);
      if type(event, [numeric,numeric]) then
         sweepline:-site(event, yprime);
         #sweepline:-debug("Site");
      else
         sweepline:-intersection(event, yprime);
         #sweepline:-debug("Intersection");
      end if
   od;
   sweepline:-terminate();
   return out;
end proc:
