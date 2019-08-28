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
%seat_guests([pc, rc, pg, hf, tj, rl, ds, abc, mc, gc], S), print_table_plan(S).

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

table_num(main, 1).
table_num(t1, 2).
table_num(t2, 3).

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

/*
 --- UTILs
*/


smaller_seat(seat(_, TableId, _), seat(_, TableId2, _)):- TableId @< TableId2, !.
smaller_seat(seat(_, TableId, SeatId), seat(_, TableId2, SeatId2)):- TableId = TableId2, SeatId < SeatId2.

beg_smallest_seat([H|[]], [H]):- !.
beg_smallest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_smallest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
														  (
														   	(
														   		((var(TableId), !) ; (var(SeatId), !) ; (smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !)),
													   			L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
													   		);
														   	(
														   		smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
														     	L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
														     )
														   ).

beg_biggest_seat([H|[]], [H]):- !.
beg_biggest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_biggest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
														  (
														   	(
														   		((var(TableId), !) ; (var(SeatId), !) ; (smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !)),
														     	L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
													   		);
														   	(
														   		smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
													   			L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
														     )
														   ).

sort_guests_seat([H|[]], [H|[]]):- !.
sort_guests_seat(Seats, [SmallestSeat | Ordered_Seats]):- beg_smallest_seat(Seats, [SmallestSeat| T]), sort_guests_seat(T,  Ordered_Seats).

find_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)).
find_guest_seat(GuestId, [seat(GuestId2, _, _) | T], Seat):- not(GuestId = GuestId2), 
															find_guest_seat(GuestId, T, Seat).

find_guests_seat([], _, []).
find_guests_seat([GuestId | Guests], TP, [Seat|Seats]):- find_guest_seat(GuestId, TP, Seat), !, find_guests_seat(Guests, TP, Seats).
find_guests_seat([_ | Guests], TP, Seats):- find_guests_seat(Guests, TP, Seats).

get_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)):- !.
get_guest_seat(GuestId, [_|T], Seat):- get_guest_seat(GuestId, T, Seat).

/*
--- SORT GUESTs
*/

filter_list([], _, []):- !.
filter_list([H | T1], FilterList, [H | T2]):- member(H, FilterList), !, filter_list(T1, FilterList, T2).
filter_list([H | T1], FilterList, T2]):- filter_list(T1, FilterList, T2).

lists_to_set(L1, [], L1):- !.
lists_to_set(L1, [H | T], Set):- member(H, L1), lists_to_set(L1, T, Set), !.
lists_to_set(L1, [H | T], Set):- append(L1, [H], L2), lists_to_set(L2, T, Set).


lists_to_set([L|[]], L):- !.
lists_to_set([L1 |[L2 | Lists]], Uniques):- lists_to_set(L1, L2, Temp), lists_to_set([Temp | Lists], Uniques).

sort_guests(Guests, SortedGuests):- findall(NextTo, next_to(NextTo), AllNextTo), lists_to_set(AllNextTo, SortedGuestsTemp1),
								    findall(SameTable, same_table(SameTable), AllSameTable), lists_to_set([SortedGuestsTemp1 | AllSameTable], SortedGuestsTemp2),
								    lists_to_set([SortedGuestsTemp2 , Guests], SortedGuestsTemp3),
								    filter_list(SortedGuestsTemp2, Guests, SortedGuests).

/*
 --- SAME TABLE 
*/

belong_to_same_table([_|[]]):- !.
belong_to_same_table([seat(_, TableId, _) | [seat(_, TableId, _) | T]]):- belong_to_same_table([seat(_, TableId, _) | T]).

same_table_as_guests(GuestId, TableId, Guests, TablePlan):- find_guests_seat(Guests, TablePlan, Seats), belong_to_same_table([seat(GuestId, TableId, nil) | Seats]).

get_same_table_condition(GuestId, L):- same_table(L), member(GuestId, L).

get_all_same_table_condition(GuestId, L):- findall(LL, get_same_table_condition(GuestId, LL), L).

respect_same_table(_, _, _, []):- !.
respect_same_table(GuestId, TableId, TablePlan, [SameTableHead | SameTableTail]):- same_table_as_guests(GuestId, TableId, SameTableHead, TablePlan), 
																				   respect_same_table(GuestId, TableId, TablePlan, SameTableTail).

respect_same_table(_, _, []):- !.
respect_same_table(GuestId, TableId, TablePlan):- get_all_same_table_condition(GuestId, SameTable), 
												  respect_same_table(GuestId, TableId, TablePlan, SameTable).

/*
 --- FREE SEAT
*/

% free_seat(seat(GuestId, TableId, SeatId), TablePlan): check if a seat is not already taken
free_seat(TableId, SeatId, []):- seat(TableId, SeatId), !.
free_seat(TableId, SeatId, [seat(_, TableId2, SeatId2) | T]):-  seat(TableId, SeatId),
																not((TableId = TableId2, SeatId = SeatId2)), 
																free_seat(TableId, SeatId, T). 

/*
 --- NEXT TO
*/

% --- Make sure this seat won't prevent other next tos.

next_seat_id(TableId, SeatId, NextSeatId):- table(TableId, Size), NextSeatId is SeatId + 1, NextSeatId =< Size, !.
next_seat_id(_, _, NextSeatId):- NextSeatId is 0.

previous_seat_id(_, SeatId, PreviousSeatId):- PreviousSeatId is SeatId - 1, PreviousSeatId > 0, !.
previous_seat_id(TableId, _, PreviousSeatId):- table(TableId, Size), PreviousSeatId is Size.


nb_appended_free_seats_right(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- next_seat_id(TableId, SeatId, NextSeatId), 
																					 free_seat(TableId, NextSeatId, TP), !,
																					 NewSoFar is SoFar + 1,
																					 nb_appended_free_seats_right(TP, seat("", TableId, NextSeatId), NewSoFar, NbAppendedFreeSeats).

nb_appended_free_seats_right(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- next_seat_id(TableId, SeatId, NextSeatId), 
																					 not(free_seat(TableId, NextSeatId, TP)), 
																					 NbAppendedFreeSeats is SoFar, !.

nb_appended_free_seats_right(TP, Seat, NbAppendedFreeSeats):- nb_appended_free_seats_right(TP, Seat, 0, NbAppendedFreeSeats).


nb_appended_free_seats_left(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- previous_seat_id(TableId, SeatId, PreviousSeatId), 
																					 free_seat(TableId, PreviousSeatId, TP), !,
																					 NewSoFar is SoFar + 1,
																					 nb_appended_free_seats_left(TP, seat("", TableId, PreviousSeatId), NewSoFar, NbAppendedFreeSeats).

nb_appended_free_seats_left(TP, seat(_, TableId, SeatId), SoFar, NbAppendedFreeSeats):- previous_seat_id(TableId, SeatId, PreviousSeatId), 
																					 not(free_seat(TableId, PreviousSeatId, TP)), 
																					 NbAppendedFreeSeats is SoFar, !.

nb_appended_free_seats_left(TP, Seat, NbAppendedFreeSeats):- nb_appended_free_seats_left(TP, Seat, 0, NbAppendedFreeSeats). 

enough_appended_free_seats(TP, Seats, NbNonSeated):- beg_biggest_seat(Seats, [Seat | _]), nb_appended_free_seats_right(TP, Seat, Nb), Nb >= NbNonSeated, !.
enough_appended_free_seats(TP, Seats, NbNonSeated):- beg_smallest_seat(Seats, [Seat | _]), nb_appended_free_seats_left(TP, Seat, Nb), Nb >= NbNonSeated.

enable_next_to_condition(_, _, _, _, _, []):- !.
enable_next_to_condition(_, TableId, _, _, _, [seat(_, TableId2, _)]):- TableId \= TableId2, !.
enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition, Seats):- length(Seats, NbSeated),
																				 length(NextToCondition, L), 
																				 NbNonSeated is L - NbSeated,
																				 enough_appended_free_seats([seat(GuestId, TableId, SeatId) | TP], Seats, NbNonSeated).

enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition):- find_guests_seat(NextToCondition, TP, Seats),
																		  enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition, Seats).

enable_other_next_to(_, _, _, _, []).
enable_other_next_to(GuestId, TableId, SeatId, TP, [NextToCondition | OtherNextTo]):- enable_next_to_condition(GuestId, TableId, SeatId, TP, NextToCondition),
																				      enable_other_next_to(GuestId, TableId, SeatId, TP, OtherNextTo).

enable_other_next_to(GuestId, TableId, SeatId, TP):- get_other_next_to_conditions(GuestId, OtherNextTo),
		   											 enable_other_next_to(GuestId, TableId, SeatId, TP, OtherNextTo).

% --- Find a set respecting nextos

next_to_each_other(seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)):- TableId1 = TableId2, 
																			 table(TableId1, Size), 
																			 SS is SeatId1 + 1, 
																			 ((SS =< Size, !, SeatId2 = SS) ; (SS > Size, SeatId2 = 0)).

follow_each_others([]):- !.
follow_each_others([_|[]]):- !.
follow_each_others(Seats):- beg_smallest_seat(Seats, [Seat1 | Seats2]), 
							beg_smallest_seat(Seats2, [Seat2 | Seats3]), 
							next_to_each_other(Seat1, Seat2), 
							follow_each_others(Seats3).

next_to_guests(GuestId, TableId, SeatId, TP, Guests):- find_guests_seat(Guests, TP, Seats), 
													   follow_each_others([seat(GuestId, TableId, SeatId) | Seats]).

get_next_to_conditions_by_guest(GuestId, AllNextTo):- findall(NextTo, (next_to(NextTo), member(GuestId, NextTo)), AllNextTo).

get_other_next_to_conditions(GuestId, OtherNextTo):- findall(NextTo, (next_to(NextTo), not(member(GuestId, NextTo))), OtherNextTo).

respect_next_to(_, _, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP, [AllNextTo_H | AllNextTo_T]):- next_to_guests(GuestId, TableId, SeatId, TP, AllNextTo_H), 
																			 respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo_T).
respect_next_to(_, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP):- get_next_to_conditions_by_guest(GuestId, AllNextTo), 
												respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo).


/*
 --- SEAT GUESTs
*/

seat_guest(GuestId, TP, seat(GuestId, TableId, SeatId)):- respect_next_to(GuestId, TableId, SeatId, TP),
														  respect_same_table(GuestId, TableId, TP),
														  free_seat(TableId, SeatId, TP),
														  % Can only check for enable_some_rule once we're sure TableId and SeatId are defined.
														  enable_other_next_to(GuestId, TableId, SeatId, TP). 

seat_guests([], TPSoFar, TPSoFar).
seat_guests([GH | GT], TPSoFar, TP):- seat_guest(GH, TPSoFar, Seat), 
									  %print_seat(Seat),
									  print_short_table_plan([Seat | TPSoFar]),
									  seat_guests(GT, [Seat | TPSoFar], TP).

seat_guests(Guests, TP):- tell('logs.txt'), sort_guests(Guests, SortedGuests), seat_guests(SortedGuests, [], TP), told.


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

print_seat(seat(GuestId, TableId, SeatId)):- nl, write(GuestId), write(': '), write(TableId), write(' - '), write(SeatId).

print_seats([seat(GuestId, _, SeatId) | T]):- nl,
										      write("#"), write(SeatId), write(": "), write(GuestId),
										      print_seats(T).
print_seats([]).

print([[seat(GuestId, TableId, SeatId) | T2]|T]):- nl, 
									  write("---"), write(TableId), write("---"), 
									  print_seats([seat(GuestId, TableId, SeatId) | T2]),
									  print(T).
print([]).

print_table_plan(TP):- get_all_printable_table_plan(TP, PTPs), print(PTPs).

write_short_table_plan([]).
write_short_table_plan([seat(GuestId, TableId, SeatId) | T]):- guest_num(GuestId, GuestNum), 
															   table_num(TableId, TableNum), 
															   write('('),write(GuestNum), write(', '), write(TableNum), write(', '), write(SeatId), write(') '),
															   write_short_table_plan(T). 

print_short_table_plan(L):- nl, reverse(L, L1), write_short_table_plan(L1).
