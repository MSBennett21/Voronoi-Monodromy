Edge := proc(ls,rs,b) 
   return module()
      export leftSite,rightSite,bisector,direction,set,valid,endpoint,
             compare,emit,debug;

      set := proc(ls, rs, b) 
         leftSite := ls;
         rightSite := rs;
         bisector := b;
         direction := signum(0,leftSite[2]-rightSite[2],0);
      end proc;
      set(ls,rs,b);

      endpoint := proc(point) 
         bisector:-endpoint(point, direction);
      end proc;

      emit := proc()
         bisector:-emit(direction);
      end proc;

      compare := proc(s,yprime)
         local t,y;
         if direction < 0 then
            if s[1] > rightSite[1] then
               return 1;
            end if;
         elif direction > 0 then
            if s[1] < leftSite[1] then
               return -1;
            end if;
         else 
            return signum(0,s[1]-bisector:-x,0);
         end if;
         t := (s[1]-bisector:-x)/bisector:-dx;
         y := bisector:-y+t*bisector:-dy;
         y := y + distance([s[1],y],leftSite);              
         if direction < 0 then
            return signum(0,yprime-y,0);
         else
             return signum(0,y-yprime,0);
         end if;
      end proc;

      valid := proc(p)
         local v;
         if direction < 0 then
            v := evalb(signum(0,p[1] - rightSite[1],0) <= 0); 
         elif direction > 0 then
            v := evalb(signum(0,p[1] - leftSite[1],0) >= 0);
         else
            if bisector:-leftEnd <> NULL then
               v := evalb(signum(0,p[2] - bisector:-leftEnd[2],0) >= 0);
            else 
               v := true;
            end if;
         end if;
         return v;
      end proc;

      debug := proc() 
         return sprintf("Edge(%a): %s left:%a right:%a",direction,bisector:-debug(),leftSite, rightSite);
      end proc;
   end module;
end proc:
