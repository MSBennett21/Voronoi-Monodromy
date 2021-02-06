Data:= proc()
   local this;
   this := module()
      export setSites, setVertex, setSegment, setRay, setLine, getData, cellData:=table(),edgeSiteData:=table(), vertices, edges:={};
      local generateCell, generateCells, curves := {}, temp, e, s;


      setSites := proc(site) 
         vertices := site;
         return this;
      end proc;

      
      setSegment := proc(x1,y1,x2,y2,s1,s2) 
         temp:=[[x1,y1],[x2,y2]];
         curves := curves union {temp};
         edges:=edges union {temp};
         edgeSiteData[temp]:={s1,s2};
         return this;
      end proc;

      setRay := proc(x,y,dx,dy,s1,s2) 
         local mult;
         mult := range/evalf(sqrt(dx^2+dy^2)); 
         curves := curves union {[[x,y],[x+mult*dx,y+mult*dy]]};
         return this;
      end proc;

      setLine := proc(x,y,dx,dy,s1,s2)
         local mult;
         mult := range/evalf(sqrt(dx^2+dy^2)); # ensure the line extends to the edges
         curves := curves union {[[x-mult*dx,y-mult*dy],[x+mult*dx,y+mult*dy]]};
         return this;
      end proc;

      generateCell := proc(site)
         local auxSet:={};
           
         for e in edges do
            if site in edgeSiteData[e] then
               auxSet := {e} union auxSet;
            fi;
         od;
         cellData[site]:=auxSet;
      end proc;

      generateCells := proc()
         
         for s in vertices do
            generateCell(s);
         od;
      end proc;

      getData := proc()
         generateCells();
      end proc;

   
   end module;
end proc:


