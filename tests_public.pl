% ============================================================
%  tests_public.pl  --  PUBLIC ACCEPTANCE SUITE (Part A)
%  Final Project starter kit
%  Student release: 2026-08-25
%
%  Run:  ?- [tests_public], run_tests.
%  All tests must pass before Milestone 1 is accepted.
% ============================================================

:- use_module(library(plunit)).
:- use_module(grammar_core).
:- use_module(harness).
:- begin_tests(baseline).

ok(S)  :- assertion(accepts(S)).
bad(S) :- assertion(rejects(S)).

% --- Ch. 2-3: constituency, NP and NOM ----------------------
test(np_det_n)        :- ok([the, student, sleeps]).
test(np_ap_nom)       :- ok([the, old, student, sleeps]).
test(np_stacked_ap)   :- ok([the, clever, old, student, sleeps]).
test(np_proper)       :- ok([kim, sleeps]).
test(np_no_det)       :- bad([student, sleeps]).
test(np_det_order)    :- bad([old, the, student, sleeps]).

% --- Ch. 4: subcategorisation -------------------------------
test(intrans)         :- ok([kim, slept]).
test(trans)           :- ok([kim, wrote, the, letter]).
test(ditrans)         :- ok([kim, gave, lucy, the, book]).
test(intensive_ap)    :- ok([kim, seems, happy]).
test(complex_trans)   :- ok([kim, considered, lucy, clever]).
test(prepositional)   :- ok([kim, relied, on, lucy]).
test(intrans_no_obj)  :- bad([kim, slept, the, letter]).
test(trans_needs_obj) :- bad([kim, wrote]).
test(prep_selection)  :- bad([kim, relied, with, lucy]).

% --- Ch. 5: adjuncts ----------------------------------------
test(adjunct_adv)     :- ok([kim, slept, yesterday]).
test(adjunct_pp)      :- ok([kim, slept, in, the, book]).
test(adjunct_stack)   :- ok([kim, wrote, the, letter, quickly, yesterday]).

% --- Ch. 6: agreement, case, auxiliaries --------------------
test(agr_3sg)         :- ok([she, writes, the, letter]).
test(agr_3pl)         :- ok([they, write, the, letter]).
test(agr_violation_1) :- bad([she, write, the, letter]).
test(agr_violation_2) :- bad([they, writes, the, letter]).
test(case_nom)        :- bad([them, write, the, letter]).
test(case_acc)        :- ok([they, give, her, a, story]).

test(modal)           :- ok([she, can, write, the, letter]).
test(perfect)         :- ok([she, has, written, the, letter]).
test(progressive)     :- ok([she, is, writing, the, letter]).
test(mod_perf_prog)   :- ok([she, could, have, been, writing, the, letter]).
test(form_mismatch)   :- bad([she, has, writing, the, letter]).
test(modal_stacking)  :- bad([she, can, has, written, the, letter]).
test(aux_order)       :- bad([she, is, have, written, the, letter]).

% --- Ch. 6: passive as a parallel rule set ------------------
test(passive_short)   :- ok([the, letter, was, written]).
test(passive_by)      :- ok([the, letter, was, written, by, kim]).
test(passive_perf)    :- ok([the, letter, has, been, written]).
test(passive_no_obj)  :- bad([the, letter, was, written, the, story]).

% --- Termination: bounded generation must not loop ----------
test(generation_terminates, [true(N > 0)]) :-
    findall(W, generate(3, W), Ws), length(Ws, N).

:- end_tests(baseline).
