intersections := proc(pq::`module`(insert), e1::`module`(bisector), e2::`module`(bisector), yprime) 
   local p,yp,h,b1,b2;

   b1 := e1:-bisector;
   b2 := e2:-bisector;
   p := b1:-intersects(b2);
   if p = NULL or not (e1:-valid(p) and e2:-valid(p)) then
      return;
   end if;
 
   yp := p[2] + distance(p, e1:-rightSite);

   h := signum(0,yp-yprime,0);
   if h < 0 then
      return;
   end if;
         
   # When the intersection is exactly at the current spot, we need to look at 
   # the direction of the edges and their slope to determine which ones will
   # actually meet.  These cases occur when a site occurs exactly on an intersection
   # or where multiple intersections occur at one point.
   if h = 0 then
      if e1:-direction < 0 then
         if e2:-direction < 0 then
            if signum(0,b1:-dy/b1:-dx - b2:-dy/b2:-dx,0) < 0 then
               return;
            end if;
         elif e2:-direction >= 0 then
            return;  # left then right or vertical
         end if;
      elif e1:-direction > 0 then
         if e2:-direction > 0 then 
            if signum(0,b1:-dy/b1:-dx - b2:-dy/b2:-dx,0) > 0 then
               return;
            end if;
         end if;
      else # e1 is vertical
         if e2:-direction >= 0 then
            return;
         end if;
      end if;
   end if;
   pq:-insert([e1,e2],yp);
end:
