/* Function and utils, by: JosueRV99 */

% generate all the sublists
sublist([], []).
sublist([X|Xs], [X|Ys]) :- sublist(Xs, Ys).
sublist(Xs, [_|Ys]) :- sublist(Xs, Ys).

% generate all the groups not repeated with N elements
createGroups(List, Group) :- 
    findall(X, (sublist(X,List), X\=[]), Result),
    member(Group, Result).

% insert all the elements from a list into another
insertAll([],L,L).  
insertAll([X|Xs], List, NewList) :-
    insert(X, List, List1),
    insertAll(Xs, List1, NewList).  

% insert one element into a list
insert(X,[Y|Ys],[X,Y|Ys]) :- precedes(X,Y).   % Elemento va al inicio
insert(X,[Y|Ys],[Y|Zs]) :- precedes(Y,X),insert(X,Ys,Zs).  % Insertar m�s adentro.
insert(X,[],[X]).                           % Insertar como �nico elemento.

% establish the order between the (name, time) pairs
precedes([N,_],[N1,_]) :- N @< N1.

% find the max time from a [name, time] list using time
maxTime([],0.0).
maxTime([[_,T1]|Tail],Max) :-
    maxTime(Tail,TailMax),
    T1 > TailMax, Max is T1.
maxTime([[_,T1]|Tail],Max) :-
    maxTime(Tail,TailMax),
    T1 =< TailMax, Max is TailMax.

% find the min time from a [name, time] list using time
bestCrosser([],0.0). 
bestCrosser([[_,T1]|Tail],Max) :-
    bestCrosser(Tail,TailMax), T1 < TailMax, Max is T1.
bestCrosser([[_,T1]|Tail],Max) :-
    bestCrosser(Tail,TailMax),T1 >= TailMax, Max is TailMax.

% generate the (name, time) pairs
getPeople(X) :- findall( [P,T], people(P,T), X).