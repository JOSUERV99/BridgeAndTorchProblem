:- include('Utils.pl').

/* solving the problem using deep first search (DFS). */
solve_dfs( State,_,[] ) :- 
    final_state(State).

solve_hill_climb(State,History,[Move|Moves]) :-
    hill_climb(State,Move),     
    update(State,Move,State1),   
    legal(State1),              
    not(member(State1,History)), 
    solve_hill_climb(State1,[State1|History],Moves).   

/* Main functions */
hill_climb(State,Move) :-
    findall(M,move(State,M),Moves),         
    evaluate_and_order(Moves,State,[],MVs), 
    member((Move,_),MVs).                  

evaluate_and_order([Move|Moves],State,MVs,OrderedMVs) :-
    update(State,Move,State1),         
    value(State1,Value),               
    insertPair((Move,Value),MVs,MVs1), 
    evaluate_and_order(Moves,State,MVs1,OrderedMVs).  
    
evaluate_and_order([],_,MVs,MVs).

insertPair(MV,[],[MV]).
insertPair((M,V),[(M1,V1)|MVs],[(M,V),(M1,V1)|MVs]) :-V >= V1.
insertPair((M,V),[(M1,V1)|MVs],[(M1,V1)|MVs1]) :-V < V1, insertPair((M,V),MVs,MVs1).

test_hill_climb(Problem,Moves) :-
   initial_state(Problem,State),          
   solve_hill_climb(State,[State],Moves).  

value(ctb(_,_,[]),0).
value(ctb(_,_,[_]),1).
value(ctb(_,_,[_,_]),2).
value(ctb(_,_,[_,_,_]),3).

%///////////////////////////////////////////////////////////////////////////////////////////////////

% change between problem states, def: (CurrentState, Limit, Crossers, NewMovement)
move(ctb(leftSide,Left,_,_), Load) :- 
    createGroups(Left, Load),
    length(Load, M), amountAtTheSameTime(N),
    M =< N, M > 0.

move(ctb(rightSide,_,Right,_), Load) :- 
    select(X,Right,_), Load = [X].

% update the problem state, def: (CurrentState, Crossers, NewState)
update(
    ctb(CurrentSide,PeopleOnTheLeft,PeopleOnTheRight,CurrentTime),
    Load,
    ctb(NewSide,NewLeft,NewRight,NewCurrentTime)
) :-
    update_crossers(CurrentSide, NewSide),                  
    update_sides(Load, CurrentSide, PeopleOnTheLeft, PeopleOnTheRight, NewLeft, NewRight),
    update_time(CurrentTime, Load, NewCurrentTime).

% update the problem time using the current and new times from the crossers weight
% def: (CurrentTime, bridgeSide, PeopleOnTheLeft, PeopleOnTheRigth, NewCurrentTime)
update_time(CurrentTime, Load, NewCurrentTime) :-
    maxTime(Load, MaxTime),
    NewCurrentTime is CurrentTime - MaxTime.

% change the state where the crossers go trough the bridge
update_crossers(leftSide, rightSide).
update_crossers(rightSide,leftSide).

% update the sides of the bridge
update_sides(Load,leftSide,PeopleOnTheLeft,PeopleOnTheRight,NewLeft,NewRight) :-      
    subtract(PeopleOnTheLeft, Load, NewLeft),
    append(Load, PeopleOnTheRight, NewRight).

update_sides(Load,rightSide,PeopleOnTheLeft,PeopleOnTheRight,NewLeft,NewRight) :-
    subtract(PeopleOnTheRight, Load, NewRight),    
    append(Load,   PeopleOnTheLeft,   NewLeft).

% problem params
people(alberto, 1).
people(beatriz, 2).
people(carlos,  5).
people(dora,   10).
people(emilio, 15).

timeAvailable( 21 ). 
amountAtTheSameTime( 3 ).

% problem start and stop
initial_state(ctb, ctb(leftSide, X, [], Ta)) :- getPeople(X), timeAvailable(Ta).
final_state(ctb(rightSide, [], People, N)) :- N >= 0, getPeople(X), is_permutation(X,People).

% problem predicates
legal( ctb(_, _, _, CurrentTime) ) :- CurrentTime >= 0.