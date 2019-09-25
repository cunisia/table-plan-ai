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

%seat_guests([pc], S), print_table_plan(S).
%seat_guests([pc, rc], S), print_table_plan(S).
%seat_guests([pc, rc, pg], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf, tj], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf, tj, rl], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf, tj, rl, ds], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf, tj, rl, ds, abc], S), print_table_plan(S).
%seat_guests([pc, rc, pg, hf, tj, rl, ds, abc, mc], S), print_table_plan(S).
%

guest_num(pc, 1).
guest_num(rc, 2).
guest_num(pg, 3).
guest_num(hf, 4).
guest_num(tj, 5).
guest_num(rl, 6).
guest_num(ds, 7).
guest_num(abc, 8).
guest_num(mc, 9).
guest_num(gc, 10).

table(main, 5).
table(t1, 5).
table(t2, 5).
table(t3, 5).

table_num(main, 1).
table_num(t1, 2).
table_num(t2, 3).
table_num(t3, 4).

seat(main, 1).
seat(main, 2).
seat(main, 3).
seat(main, 4).
seat(main, 5).

seat(t1, 1).
seat(t1, 2).
seat(t1, 3).
seat(t1, 4).
seat(t1, 5).

seat(t2, 1).
seat(t2, 2).
seat(t2, 3).
seat(t2, 4).
seat(t2, 5).

seat(t3, 1).
seat(t3, 2).
seat(t3, 3).
seat(t3, 4).
seat(t3, 5).

same_table([pc, gc, hf, mc, rl]).
same_table([pg, ds]).
next_to([pc, gc]).
different_table([tj, pg]).
exclusive_table([rc, abc]).
not_next_to([hf, rl]).
specific_table([gc, pc], t1).

:-seat_guests([pc, rc, pg, hf, tj, rl, ds, abc, mc, gc], S), print_table_plan(S).