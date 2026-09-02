% ============================================================
%  harness.pl  --  EVALUATION HARNESS
%  Final Project starter kit
%  Student release: 2026-08-25
%
%  Provides the measurements required in Part C of the report.
%  Do not modify this file; it is used unchanged when grading.
% ============================================================

:- module(harness, [ parse/2, accepts/1, rejects/1,
                     parses/2, n_parses/2,
                     generate/2, sample/2,
                     evaluate/2, evaluate/3,
                     show_tree/1 ]).

:- use_module(library(apply), [include/3]).
:- use_module(library(lists), [list_to_set/2, member/2, sum_list/2]).
:- use_module(grammar_core).

% --- Parsing ------------------------------------------------

parse(Words, Tree) :- phrase(sentence(Tree), Words).

accepts(Words) :- \+ \+ phrase(sentence(_), Words).
rejects(Words) :- \+ phrase(sentence(_), Words).

parses(Words, Trees)  :- findall(T, phrase(sentence(T), Words), Trees).
n_parses(Words, N)    :- parses(Words, Ts), length(Ts, N).

% --- Generation (bounded, to guarantee termination) ---------

generate(Length, Words) :-
    length(Words, Length),
    phrase(sentence(_), Words).

sample(Length, Words) :-
    findall(W, generate(Length, W), All),
    list_to_set(All, Words).

% --- Quantitative evaluation --------------------------------
%  Good = list of grammatical strings   (must be accepted)
%  Bad  = list of ungrammatical strings (must be rejected)
%
%  Coverage         = accepted(Good) / |Good|
%  Challenge error  = accepted(Bad)  / |Bad|
%  Mean ambiguity   = mean number of parses over accepted Good
%
%  Challenge error is a false-acceptance rate on the supplied finite
%  negative set; it is not an estimate over all strings.

evaluate(Good, Bad) :- evaluate(Good, Bad, _).

evaluate(Good, Bad, metrics(Cov, Challenge, Amb)) :-
    include(accepts, Good, GoodOk),
    include(accepts, Bad,  BadWrong),
    length(Good, NG), length(GoodOk, NGok),
    length(Bad,  NB), length(BadWrong, NBw),
    safe_ratio(NGok, NG, Cov),
    safe_ratio(NBw,  NB, Challenge),
    mean_ambiguity(GoodOk, Amb),
    format("~n== EVALUATION ==========================~n"),
    format("Coverage         : ~d/~d  (~2f)~n", [NGok, NG, Cov]),
    format("Challenge errors : ~d/~d  (~2f)~n", [NBw, NB, Challenge]),
    format("Mean ambiguity   : ~2f parses/sentence~n", [Amb]),
    format("----------------------------------------~n"),
    report_failures("UNDERGENERATED (grammatical, rejected)", Good, rejects),
    report_failures("FALSE ACCEPTANCE (ungrammatical, accepted)", Bad, accepts),
    format("========================================~n").

safe_ratio(_, 0, 0.0) :- !.
safe_ratio(X, N, R)   :- R is X / N.

mean_ambiguity([], 0.0) :- !.
mean_ambiguity(Ss, Mean) :-
    findall(N, (member(S, Ss), n_parses(S, N)), Ns),
    sum_list(Ns, Sum), length(Ns, K),
    Mean is Sum / K.

report_failures(Label, List, Test) :-
    Goal =.. [Test, S],
    findall(S, (member(S, List), Goal), Fails),
    (   Fails == []
    ->  true
    ;   format("~w:~n", [Label]),
        forall(member(F, Fails), format("   ~w~n", [F]))
    ).

% --- Readable phrase markers --------------------------------

show_tree(Words) :-
    forall(parse(Words, T),
           ( format("~n"), print_term(T, [indent_arguments(2)]), format("~n") )).
