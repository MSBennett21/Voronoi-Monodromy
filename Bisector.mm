Bisector := proc(out, ls, rs, starter) 
   return module()
      export sites,x,y,dx,dy,set,emit,endpoint,intersects,debug,leftEnd, rightEnd;
      leftEnd := NULL;
      rightEnd := NULL;
      sites := {ls, rs};
      x := (ls[1]+rs[1])/2;
      y := (ls[2]+rs[2])/2;
      # Take the perpendicular
      dy := -(ls[1]-rs[1]);
      dx := (ls[2]-rs[2]);

      endpoint := proc(point, direction) 
         if direction < 0 then
            leftEnd := point;
         elif direction > 0 then
            rightEnd := point;
         elif leftEnd = NULL then
            leftEnd := point;
         else
            rightEnd := point;
         end if;
         if starter then
            out:-setRay(op(point),0,-1,op(sites));;
         elif leftEnd <> NULL and rightEnd <> NULL then
            # Zero length segments are possible and can be filtered out
            if leftEnd <> rightEnd then
               out:-setSegment(op(leftEnd),op(rightEnd),op(sites));
            end if; 
         end if;
      end proc;

      emit := proc(direction) 
         if leftEnd = NULL and rightEnd = NULL then
            if (direction <= 0) then
               out:-setLine(x,y,dx,dy,op(sites));
            end if;
         elif dx = 0 then
            if leftEnd <> NULL then
               out:-setRay(op(leftEnd),0,1,op(sites));
            else
               out:-setRay(op(rightEnd),0,1,op(sites));
            end if;
         elif leftEnd <> NULL then
            if (signum(dx) < 0) then
               out:-setRay(op(leftEnd),-dx,-dy,op(sites));
            else
               out:-setRay(op(leftEnd),dx,dy,op(sites));
            end if;
         else
            if (signum(dx) < 0) then
               out:-setRay(op(rightEnd),dx,dy,op(sites));
            else
               out:-setRay(op(rightEnd),-dx,-dy,op(sites));
            end if;
         end if;
      end proc;

      intersects := proc(b)
         local d, t;
         d := dx*b:-dy - dy*b:-dx;
         if d = 0 then 
            return NULL;
         end if;
         t := ((b:-x - x)*b:-dy + b:-dx*(y - b:-y))/d; # -x1*dy2+x2*dy2+dx2*y1-dx2*y2
         return [x+t*dx,y+t*dy];
      end;

      debug := proc() 
         return sprintf("[%a,%a]-><%a,%a>",x,y,dx,dy);
      end proc;

   end module;
end proc:
