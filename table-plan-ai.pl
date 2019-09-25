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

/*
 --- UTILs
*/

smaller_seat(seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)):- not(var(TableId1)), 
                                                                      not(var(SeatId1)), 
                                                                      ((var(TableId2), !) ; var(SeatId2)).
smaller_seat(seat(_, TableId1, _), seat(_, TableId2, _)):- not(var(TableId1)), 
                                                           not(var(TableId2)), 
                                                           TableId1 @< TableId2, !. %@< is to compare strings
smaller_seat(seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)):- not(var(TableId1)), 
                                                                      not(var(TableId2)), 
                                                                      not(var(SeatId1)), 
                                                                      not(var(SeatId2)),
                                                                      TableId1 = TableId2, 
                                                                      SeatId1 < SeatId2. %@< is to compare strings

beg_smallest_seat([H|[]], [H]):- !.
beg_smallest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_smallest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
                                                          (
                                                               (
                                                                   smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !,
                                                                   L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
                                                               );
                                                               (
                                                                   smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
                                                                 L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
                                                            );
                                                               (
                                                                   L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]] % if non is smaller respect procided order
                                                                )
                                                           ).

beg_biggest_seat([H|[]], [H]):- !.
beg_biggest_seat([seat(GuestId, TableId, SeatId)|T], L):- beg_biggest_seat(T, [seat(GuestId2, TableId2, SeatId2)|T1]), 
                                                          (
                                                               (
                                                                   smaller_seat(seat(GuestId2, TableId2, SeatId2), seat(GuestId, TableId, SeatId)), !,
                                                                 L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]]
                                                               );
                                                               (
                                                                   smaller_seat(seat(GuestId, TableId, SeatId), seat(GuestId2, TableId2, SeatId2)), !, 
                                                                   L = [seat(GuestId2, TableId2, SeatId2) | [seat(GuestId, TableId, SeatId) | T1]]
                                                             );
                                                               (
                                                                   L = [seat(GuestId, TableId, SeatId) | [seat(GuestId2, TableId2, SeatId2) | T1]] % if non is smaller respect procided order
                                                                )
                                                           ).

sort_guests_seat([H|[]], [H|[]]):- !.
sort_guests_seat(Seats, [SmallestSeat | Ordered_Seats]):- beg_smallest_seat(Seats, [SmallestSeat| T]), sort_guests_seat(T,  Ordered_Seats).

find_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)).
find_guest_seat(GuestId, [seat(GuestId2, _, _) | T], Seat):- not(GuestId = GuestId2), 
                                                            find_guest_seat(GuestId, T, Seat).

find_guests_seat([GuestId | Guests], TP, Seats):- find_guest_seat(GuestId, TP, Seat), !, find_guests_seat(Guests, TP, Seats2), Seats = [Seat | Seats2].
find_guests_seat([_ | Guests], TP, Seats):- find_guests_seat(Guests, TP, Seats), !.
find_guests_seat([], _, []).

get_guest_seat(GuestId, [seat(GuestId, TableId, SeatId) | _], seat(GuestId, TableId, SeatId)):- !.
get_guest_seat(GuestId, [_|T], Seat):- get_guest_seat(GuestId, T, Seat).

/*
--- SORT GUESTs
*/

filter_list([], _, []):- !.
filter_list([H | T1], FilterList, [H | T2]):- member(H, FilterList), !, filter_list(T1, FilterList, T2).
filter_list([_ | T1], FilterList, T2):- filter_list(T1, FilterList, T2).

lists_to_set(L1, [], L1):- !.
lists_to_set(L1, [H | T], Set):- member(H, L1), lists_to_set(L1, T, Set), !.
lists_to_set(L1, [H | T], Set):- append(L1, [H], L2), lists_to_set(L2, T, Set).


lists_to_set([L|[]], L):- !.
lists_to_set([L1 |[L2 | Lists]], Uniques):- lists_to_set(L1, L2, Temp), lists_to_set([Temp | Lists], Uniques).

sort_guests(Guests, SortedGuests):- findall(NextTo, next_to(NextTo), AllNextTo), lists_to_set(AllNextTo, SortedGuestsTemp1),
                                    findall(NotNextTo, not_next_to(NotNextTo), AllNotNextTo), lists_to_set([SortedGuestsTemp1 | AllNotNextTo], SortedGuestsTemp2),
                                    findall(SpecificTable, specific_table(SpecificTable, _), AllSpecificTable), lists_to_set([SortedGuestsTemp2 | AllSpecificTable], SortedGuestsTemp3),
                                    findall(SameTable, same_table(SameTable), AllSameTable), lists_to_set([SortedGuestsTemp3 | AllSameTable], SortedGuestsTemp4),
                                    findall(ExclusiveTable, exclusive_table(ExclusiveTable), AllExclusiveTable), lists_to_set([SortedGuestsTemp4 | AllExclusiveTable], SortedGuestsTemp5),
                                    findall(DifferentTable, different_table(DifferentTable), AllDifferentTable), lists_to_set([SortedGuestsTemp5 | AllDifferentTable], SortedGuestsTemp6),
                                    lists_to_set([SortedGuestsTemp6 , Guests], SortedGuestsTemp7),
                                    filter_list(SortedGuestsTemp7, Guests, SortedGuests).

/*
 --- SAME TABLE 
*/

belong_to_same_table([_|[]]):- !.
belong_to_same_table([seat(_, TableId, _) | [seat(_, TableId, _) | T]]):- belong_to_same_table([seat(_, TableId, _) | T]).

get_same_table_condition_by_guest(GuestId, L):- findall(LL, (same_table(LL), member(GuestId, LL)), L).

respect_same_table(_, _, _, []):- !.
respect_same_table(GuestId, TableId, TP, [SameTableHead | SameTableTail]):- find_guests_seat(SameTableHead, TP, Seats),
                                                                            belong_to_same_table([seat(GuestId, TableId, nil) | Seats]),
                                                                              respect_same_table(GuestId, TableId, TP, SameTableTail).

respect_same_table(_, _, []):- !.
respect_same_table(GuestId, TableId, TP):- get_same_table_condition_by_guest(GuestId, SameTable), 
                                           respect_same_table(GuestId, TableId, TP, SameTable).

/*
--- DIFFERENT TABLE
*/
get_different_table_condition_by_guest(GuestId, DifferentTable):- findall(Guests, (different_table(Guests), member(GuestId, Guests)), DifferentTable).

belong_to_different_table(_, []):-!.
belong_to_different_table(seat(GuestId1, TableId1, _), [seat(_, TableId2, _) | Seats]):- TableId1 \= TableId2, !, 
                                                                                         belong_to_different_table(seat(GuestId1, TableId1, _), Seats).
belong_to_different_table(seat(GuestId1, TableId1, _), [seat(GuestId2, _, _) | Seats]):- GuestId1 = GuestId2, !, 
                                                                                         belong_to_different_table(seat(GuestId1, TableId1, _), Seats).

respect_different_table(_, _, _, []):-!. 
respect_different_table(GuestId, TableId, TP, [DifferentTable_H |DifferentTable_T]):- find_guests_seat(DifferentTable_H, TP, Seats),
                                                                                       belong_to_different_table(seat(GuestId, TableId, nil), Seats),
                                                                                       respect_different_table(GuestId, TableId, TP, DifferentTable_T). 

respect_different_table(_, _, []):-!.
respect_different_table(GuestId, TableId, TP):- get_different_table_condition_by_guest(GuestId, DifferentTable),
                                               respect_different_table(GuestId, TableId, TP, DifferentTable).

/*
--- HAVE EXCLUSIVE TABLE
*/

get_exclusive_table_condition_by_guest(GuestId, AllExclusiveTable):- findall(ExclusiveTable, (exclusive_table(ExclusiveTable), member(GuestId, ExclusiveTable)), AllExclusiveTable).
get_all_other_exclusive_table_condition(GuestId, OtherExclusiveTable):- findall(ExclusiveTable, (exclusive_table(ExclusiveTable), not(member(GuestId, ExclusiveTable))), OtherExclusiveTable).

seats_not_at_table([], _):- !.
seats_not_at_table([seat(_, TableId1, _) | T], TableId2):- TableId1 \= TableId2, seats_not_at_table(T, TableId2).

respect_other_exclusive_table(_, _, _, []):- !.
respect_other_exclusive_table(GuestId, TableId, TP, [ExclusiveTableHead | ExclusiveTableTail]):- table(TableId, _),
                                                                                                 find_guests_seat(ExclusiveTableHead, TP, Seats),
                                                                                                 seats_not_at_table(Seats, TableId), 
                                                                                                 respect_other_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail). 

nb_guests_at_table(_, [], 0):- !.
nb_guests_at_table(TableId, [seat(_, TableId2, _) | T], NB):- TableId2 = TableId, !, nb_guests_at_table(TableId, T, NB2), NB is NB2 + 1.
nb_guests_at_table(TableId, [_ | T], NB):- nb_guests_at_table(TableId, T, NB).

respect_exclusive_table(_, _, _, []):- !.
respect_exclusive_table(GuestId, TableId, TP, [ExclusiveTableHead | ExclusiveTableTail]):- find_guests_seat(ExclusiveTableHead, TP, [H|T]), !,
                                                                                            belong_to_same_table([seat(GuestId, TableId, nil) | [H|T]]),
                                                                                            respect_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail).
respect_exclusive_table(GuestId, TableId, TP, [_ | ExclusiveTableTail]):- table(TableId, _), 
                                                                          nb_guests_at_table(TableId, TP, 0),
                                                                          respect_exclusive_table(GuestId, TableId, TP, ExclusiveTableTail).

respect_exclusive_table(_, _, []):- !.
respect_exclusive_table(GuestId, TableId, TP):- get_exclusive_table_condition_by_guest(GuestId, ExclusiveTable), 
                                                respect_exclusive_table(GuestId, TableId, TP, ExclusiveTable),
                                                get_all_other_exclusive_table_condition(GuestId, OtherExclusiveTable), 
                                                respect_other_exclusive_table(GuestId, TableId, TP, OtherExclusiveTable).

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

% --- Find a seat respecting nextos

follow_each_other(S1, S2):- beg_smallest_seat([S1, S2], [seat(_, TableId1, SeatId1), seat(_, TableId2, SeatId2)]),
                            TableId1 = TableId2, 
                            next_seat_id(TableId1, SeatId1, NextSeatId),
                            NextSeatId = SeatId2.

get_next_to_conditions_by_guest(GuestId, AllNextTo):- findall(NextTo, (next_to(NextTo), member(GuestId, NextTo)), AllNextTo).

get_other_next_to_conditions(GuestId, OtherNextTo):- findall(NextTo, (next_to(NextTo), not(member(GuestId, NextTo))), OtherNextTo).

% This function considers that Seats are already following each others
respect_next_to_seats(_, []):- !.
respect_next_to_seats(Seat, Seats):- beg_biggest_seat(Seats, [BiggestSeat | _]),
                                      follow_each_other(Seat, BiggestSeat), !.
respect_next_to_seats(Seat, Seats):- beg_smallest_seat(Seats, [SmallestSeat | _]),
                                     follow_each_other(Seat, SmallestSeat), !.

respect_next_to(_, _, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP, [AllNextTo_H | AllNextTo_T]):- find_guests_seat(AllNextTo_H, TP, Seats),
                                                                             respect_next_to_seats(seat(GuestId, TableId, SeatId), Seats),
                                                                             respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo_T).
respect_next_to(_, _, _, []):- !.
respect_next_to(GuestId, TableId, SeatId, TP):- get_next_to_conditions_by_guest(GuestId, AllNextTo), 
                                                respect_next_to(GuestId, TableId, SeatId, TP, AllNextTo).

% --- No next to 

get_not_next_to_conditions_by_guest(GuestId, AllNotNextTo):- findall(NotNextTo, (not_next_to(NotNextTo), member(GuestId, NotNextTo)), AllNotNextTo).

not_next_to_seats(_, []):- !.
not_next_to_seats(Seat, [Seat_H | Seats_T]):- not(follow_each_other(Seat_H, Seat)), not_next_to_seats(Seat, Seats_T).

respect_not_next_to(_, _, _, _, []):- !.
respect_not_next_to(GuestId, TableId, SeatId, TP, [AllNotNextTo_H | AllNotNextTo_T]):- find_guests_seat(AllNotNextTo_H, TP, Seats),
                                                                                       not_next_to_seats(seat(GuestId, TableId, SeatId), Seats), 
                                                                                       respect_not_next_to(GuestId, TableId, SeatId, TP, AllNotNextTo_T).

respect_not_next_to(_, _, _, []):- !.
respect_not_next_to(GuestId, TableId, SeatId, TP):- get_not_next_to_conditions_by_guest(GuestId, AllNotNextTo), 
                                                    respect_not_next_to(GuestId, TableId, SeatId, TP, AllNotNextTo).

/*
--- SEAT AT SPECIFIC TABLE 
*/
get_specific_table_condictions_by_guest(GuestId, AllSpecificTable):- findall(TableId, (specific_table(Guests, TableId), member(GuestId, Guests)), AllSpecificTable).

respect_specific_table(_, _, []):- !.
respect_specific_table(GuestId, TableId, [SpecificTableId | AllSpecificTable_H]):- TableId = SpecificTableId,
                                                                                   respect_specific_table(GuestId, TableId, AllSpecificTable_H).

respect_specific_table(GuestId, TableId):- get_specific_table_condictions_by_guest(GuestId, AllSpecificTable),
                                           respect_specific_table(GuestId, TableId, AllSpecificTable).

/*
 --- SEAT GUESTs
*/

seat_guest(GuestId, TP, seat(GuestId, TableId, SeatId)):- respect_specific_table(GuestId, TableId),
                                                          respect_next_to(GuestId, TableId, SeatId, TP),
                                                          respect_same_table(GuestId, TableId, TP),
                                                          respect_exclusive_table(GuestId, TableId, TP),
                                                          free_seat(TableId, SeatId, TP),
                                                          % Can only check for enable_some_rule once we're sure TableId and SeatId are defined.
                                                          respect_not_next_to(GuestId, TableId, SeatId, TP),
                                                          respect_different_table(GuestId, TableId, TP),
                                                          enable_other_next_to(GuestId, TableId, SeatId, TP). 

seat_guests([], TPSoFar, TPSoFar).
seat_guests([GH | GT], TPSoFar, TP):- seat_guest(GH, TPSoFar, Seat), 
                                      %print_seat(Seat),
                                      print_short_table_plan([Seat | TPSoFar]),
                                      seat_guests(GT, [Seat | TPSoFar], TP).

seat_guests(Guests, TP):- tell('logs.txt'), 
                          sort_guests(Guests, SortedGuests), 
                          seat_guests(SortedGuests, [], TP), 
                          told.

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
