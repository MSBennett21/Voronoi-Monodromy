Data := proc()
   local this;
   this := module()
      export sites, vertex, segment, ray, line, vertices:={}, curves:={};


      vertices := NULL;
      curves := NULL;

      sites := proc(s) 
         vertices := vertices union {[op(map(evalf[percision],s))]};
         return this;
      end proc;

      segment := proc(x1,y1,x2,y2,s1,s2) 
         curves := curves union {[[x1,y1],[x2,y2]]};
         
         return this;
      end proc;


   end module;
end proc: