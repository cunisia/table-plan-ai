/*
 * --- PRINT TABLE PLAN
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
print([]):- nl.

print_table_plan(TP):- get_all_printable_table_plan(TP, PTPs), print(PTPs).

write_short_table_plan([]).
write_short_table_plan([seat(GuestId, TableId, SeatId) | T]):- guest_num(GuestId, GuestNum), 
                                                               table_num(TableId, TableNum), 
                                                               write('('),write(GuestNum), write(', '), write(TableNum), write(', '), write(SeatId), write(') '),
                                                               write_short_table_plan(T). 

print_short_table_plan(L):- nl, reverse(L, L1), write_short_table_plan(L1).

get_json_seat(seat(GuestId, TableId, SeatId), JSON_Seat):- format(atom(JSON_Seat), '{"guestId": "~w", "tableId": "~w", "seatId": "~w"}', [GuestId, TableId, SeatId]).

get_json_seats([], Acc, Acc):- !.
get_json_seats([Seat | Seats], Acc, JSON_Seats):- get_json_seat(Seat, JSON_Seat), get_json_seats(Seats, [JSON_Seat | Acc], JSON_Seats).

get_json_table_plan(TP, JSON_TP):- get_json_seats(TP, [], JSON_Seats), 
                                   atomic_list_concat(JSON_Seats, ", ", JSON_Seats_Str), 
                                   format(atom(JSON_TP), '[~w]', [JSON_Seats_Str]).