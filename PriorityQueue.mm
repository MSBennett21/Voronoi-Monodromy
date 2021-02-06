PriorityQueue := proc()
  return module() 
    export clear, insert, remove, contains, empty, head, pop, count; 
    local size, events, priorities, positions; 

    clear := proc() 
       size := 0;
       events := table();
       positions := table();
       return NULL;
    end proc;
    clear();

    insert := proc(event, priority) 
       local i, p;
       ASSERT(not assigned(positions[event]),"Duplicate entry");
       size := size + 1;
       i := size;
       while i <> 1 do
          p := floor(i/2);
          if signum(0,priority - priorities[p],0) >= 0 then
             break;
          end if;
          events[i] := events[p];
          priorities[i] := priorities[p];
          positions[events[i]] := i;
          i := p;
       end do;
       events[i] := event;
       priorities[i] := priority;
       positions[event] := i;
    end proc;

    remove := proc(event) 
       local i, c, p, priority, lastevent;
       ASSERT(assigned(positions[event]),"Attempt to remove invalid event");
       ASSERT(events[positions[event]] = event,"Valid positions table");

       i := positions[event];
       lastevent := events[size];
       priority := priorities[size];
       unassign('positions[event]');
       unassign('priorities[size]');
       unassign('events[size]');
       size := size - 1;
       p := floor(i/2);

       if i > 1 and signum(0,priority - priorities[p],0) < 0 then
          while i <> 1 do
             p := floor(i/2);
             if signum(0,priority - priorities[p],0) >= 0 then
                break;
             end if;
             events[i] := events[p];
             priorities[i] := priorities[p];
             positions[events[i]] := i;
             i := p;
          end do;
          events[i] := lastevent;
          priorities[i] := priority;
          positions[lastevent] := i;
       else
          do 
             c := 2*i;
             if c > size then
                break;
             end if;
             if c < size and signum(0,priorities[c] - priorities[c+1],0) > 0 then
                 c := c + 1;
             end if;
             if signum(0,priorities[c] - priority,0) >= 0 then  
                break;
             end if;
             events[i] := events[c];
             positions[events[i]] := i;
             priorities[i] := priorities[c];
             i := c;
          end do;
          positions[lastevent] := i;
          priorities[i] := priority;
          events[i] := lastevent;
       end if;
    end proc;

    contains := proc(event) 
       return assigned(positions[event]);
    end; 

    empty := proc() 
       return evalb(size = 0);
    end;

    head := proc(priority::boolean:=false) 
       ASSERT(size <> 0, "Attempt to take head of empty queue");
       if priority then
          return events[1],priorities[1];
       else
          return events[1];
       end if;
    end proc;

    pop := proc(priority::boolean:=false) 
       local e,p;
       p := NULL;
       if priority then
          e,p := head(priority);
       else
          e := head();
       end if;
       ASSERT(positions[e] = 1,"Invalid positions table");
       remove(e);
       return e,p;
    end proc;

    count := proc() 
       return size;
    end proc;
  end module;
end proc:
