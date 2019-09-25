:-[table_plan_ai].

%guest(Id, Sex, Group).
guest(pc, male, maried).
guest(gc, female, maried).
guest(hf, male, best_man).
guest(mc, male, best_man).
guest(rl, male, best_man).
guest(pg, male, friend).
guest(ds, female, friend).
guest(tj, male, nil).
guest(rc, male, family).
guest(abc, female, family).

table(t1, 5).

seat(t1, 1).
seat(t1, 2).
seat(t1, 3).
seat(t1, 4).
seat(t1, 5).

same_table([]).
same_table([]).
next_to([]).
different_table([]).
exclusive_table([]).
not_next_to([]).
specific_table([pc], t1).

:- respect_specific_table(pc, t1), not(respect_specific_table(pc, t2)).