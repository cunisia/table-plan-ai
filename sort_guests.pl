/*
 * --- SORT GUESTs: sort guests by constraints 
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