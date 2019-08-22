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

table(main, 5).
table(t1, 5).
table(t2, 5).

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


same_table([pc, gc, hf, mc, rl]).
same_table([pg, ds]).
next_to([pc, gc]).
exclusive_table([rc, abc]).
not_next_to([hf, rl]).

get_guest_seat(_, [], nil).
get_guest_seat(GuestId, [seat(TableId, SeatId, GuestId)|_], seat(TableId, SeatId, GuestId)):- !.
get_guest_seat(GuestId, [_|T], Seat):- get_guest_seat(GuestId, T, Seat).

same_table_as_guest(GuestId, _, GuestId, _).
same_table_as_guest(_, _, GuestId2, TablePlan):- get_guest_seat(GuestId2, TablePlan, nil).
same_table_as_guest(_, TableId, GuestId2, TablePlan):- get_guest_seat(GuestId2, TablePlan, seat(GuestId2, TableId,_)).

same_table_as_guests(_, _, [], _).
same_table_as_guests(GuestId, TableId, [HG | TG], TablePlan):- same_table_as_guest(GuestId, TableId, HG, TablePlan), 
															   same_table_as_guests(GuestId, TableId, TG, TablePlan).

get_same_table_condition(GuestId, L):- same_table(L), member(GuestId, L).

get_all_same_table_condition(GuestId, L):- findall(LL, get_same_table_condition(GuestId, LL), L).

respect_same_table(_, _, _, []).
respect_same_table(GuestId, TableId, TablePlan, [SameTableHead | SameTableTail]):- same_table_as_guests(GuestId, TableId, SameTableHead, TablePlan), 
																				   respect_same_table(GuestId, TableId, TablePlan, SameTableTail).

respect_same_table(GuestId, TableId, TablePlan):- get_all_same_table_condition(GuestId, SameTable), 
												  respect_same_table(GuestId, TableId, TablePlan, SameTable).

% free_seat(seat(GuestId, TableId, SeatId), TablePlan): check if a seat is not already taken
free_seat(_, []).
free_seat(seat(_, TableId, SeatId), [seat(_, TableId2, SeatId2) | T]):- (not(TableId = TableId2) ; not(SeatId = SeatId2)), 
																		free_seat(seat(_, TableId, SeatId), T). 

/*
 --- SEAT GUESTs
*/

seat_guest(GuestId, TP, seat(GuestId, TableId, SeatId)):- seat(TableId, SeatId),
														  free_seat(seat(GuestId, TableId, SeatId), TP), 
														  respect_same_table(GuestId, TableId, TP).


seat_guests(Guests, TP):- seat_guests(Guests, [], TP).

seat_guests([], TPSoFar, TPSoFar).
seat_guests([GH | GT], TPSoFar, TP):- seat_guest(GH, TPSoFar, Seat), 
									  seat_guests(GT, [Seat | TPSoFar], TP).

/*
 --- PRINT TABLE PLAN
*/	

list_table_seats(_, 0, []).
list_table_seats(TableId, Size, [seat(TableId, Size) | T]):- Size > 0, 
															 	NewSize is Size - 1,
															 	list_table_seats(TableId, NewSize, T).
list_table_seats(TableId, L):- table(TableId, Size), list_table_seats(TableId, Size, L).

list_all_seats(L):- findall(LL, (table(TableId, _), list_table_seats(TableId, LL)), L).

guest_at_seat(TableId, SeatId, [seat(GuestId, TableId, SeatId) | _], GuestId):- !.
guest_at_seat(TableId, SeatId, [_ | TP_T], GuestId):- guest_at_seat(TableId, SeatId, TP_T, GuestId).
guest_at_seat(_, _, [], "empty").

get_printable_table_plan([], _, []).
get_printable_table_plan([seat(TableId, SeatId) | Seats_T], TP, [seat(GuestId, TableId, SeatId)|T]):- guest_at_seat(TableId, SeatId, TP, GuestId), get_printable_table_plan(Seats_T, TP, T).


get_all_printable_table_plan([], _, PTPs, PTPs).
get_all_printable_table_plan([SGBT_H | SGBT_T], TP, SoFar, PTPs):- get_printable_table_plan(SGBT_H, TP, PTP), get_all_printable_table_plan(SGBT_T, TP, [PTP | SoFar], PTPs).
get_all_printable_table_plan(TP, PTPs):- list_all_seats(SGBT), get_all_printable_table_plan(SGBT, TP, [], PTPs).


print_seats([seat(GuestId, _, SeatId) | T]):- nl,
										      write("#"), write(SeatId), write(": "), write(GuestId),
										      print_seats(T).
print_seats([]).

print([[seat(GuestId, TableId, SeatId) | T2]|T]):- nl, 
									  write("---"), write(TableId), write("---"), 
									  print_seats([seat(GuestId, TableId, SeatId) | T2]),
									  print(T).

print_table_plan(TP):- get_all_printable_table_plan(TP, PTPs), print(PTPs).
