:- use_module(library(plunit)).
:- use_module(harness).

:- begin_tests(baseline_coverage).

ok(Words)  :- assertion(accepts(Words)).
bad(Words) :- assertion(rejects(Words)).

% Baseline positive coverage.
test(baseline_intransitive) :- ok([kim,slept]).
test(baseline_transitive) :- ok([kim,wrote,the,letter]).
test(baseline_ditransitive) :- ok([they,give,her,a,story]).
test(baseline_perfect) :- ok([she,has,written,the,letter]).
test(baseline_passive) :- ok([the,letter,was,written]).
test(baseline_modal) :- ok([she,can,write,the,letter]).

% Baseline negatives: agreement, case, and auxiliary-form selection.
test(baseline_agreement_violation, [true]) :- bad([she,write,the,letter]).
test(baseline_case_violation, [true]) :- bad([them,write,the,letter]).
test(baseline_aux_form_violation, [true]) :- bad([she,has,writing,the,letter]).

% Ambiguity inventory: both are known spurious passive by-phrase analyses.
test(ambiguity_passive_by, [true(N =:= 2)]) :-
    n_parses([the,letter,was,written,by,kim], N).
test(ambiguity_perfect_passive_by, [true(N =:= 3)]) :-
    n_parses([the,letter,has,been,written,by,kim], N).

:- end_tests(baseline_coverage).

:- begin_tests(b1_np_structure).

ok(Words)  :- assertion(accepts(Words)).
bad(Words) :- assertion(rejects(Words)).

% B1: selected PP complement is sister of N.
test(writer_of_novels) :- ok([a,writer,of,novels,sleeps]).
% B1: PP adjunct is sister of NOM.
test(student_with_hair) :- ok([the,student,with,long,hair,sleeps]).
% B1: pre-determiner precedes the determiner.
test(predeterminer) :- ok([all,the,old,books,sleep]).
% B1: the complement and following adjunct occupy distinct attachment sites.
test(writer_complement_and_adjunct) :-
    ok([a,writer,of,novels,with,a,beard,sleeps]).
% B1: stacked post-modifying PPs terminate and preserve input order.
test(stacked_nominal_pps) :-
    ok([the,student,with,long,hair,in,the,garden,sleeps]).
% B1: bare plural NP is available inside the selected of-PP.
test(bare_plural_complement) :- ok([a,writer,of,books,sleeps]).
% B1: an added PP-selecting noun uses its selected with-PP.
test(friend_with_garden) :- ok([a,friend,with,the,garden,sleeps]).
% B1: adjectival modification remains inside NOM before post-modification.
test(adjective_then_pp) :- ok([the,old,student,with,long,hair,sleeps]).
% B1 ambiguity: the final PP can modify writer or the embedded novels NP.
test(complement_adjunct_attachment_ambiguity, [true(N =:= 2)]) :-
    n_parses([a,writer,of,novels,with,a,beard,sleeps], N).
% B1 ambiguity: the final PP can modify hair or the containing student NOM.
test(nominal_pp_attachment_ambiguity, [true(N =:= 2)]) :-
    n_parses([the,student,with,long,hair,in,the,garden,sleeps], N).

% B1 negative: singular count nouns remain unavailable as bare NPs.
test(bare_singular_count, [true]) :- bad([student,sleeps]).
% B1 negative: writer selects [of], not an arbitrary PP complement.
test(writer_wrong_selected_pp, [true]) :- bad([a,writer,with,a,beard,sleeps]).
% B1 negative: friend selects [with], not an arbitrary PP complement.
test(friend_wrong_selected_pp, [true]) :- bad([a,friend,of,novels,sleeps]).
% B1 negative: a pre-determiner cannot appear after a determiner.
test(predeterminer_order, [true]) :- bad([the,all,books,sleep]).

:- end_tests(b1_np_structure).

:- begin_tests(b2_subordinate_clauses).

ok(Words)  :- assertion(accepts(Words)).
bad(Words) :- assertion(rejects(Words)).

% B2: S-bar direct object selected by say.
test(say_that) :- ok([she,said,that,he,left]).
% B2: interrogative S-bar selected by ask.
test(ask_whether) :- ok([she,asked,whether,he,left]).
% B2: adverbial subordinate clause is a VP adjunct.
test(because_clause) :- ok([she,left,because,he,arrived]).
% B2: present-tense complement selection retains agreement.
test(says_that) :- ok([she,says,that,they,leave]).
% B2: selected S-bars can embed recursively after consuming a complementiser.
test(nested_that_clause) :- ok([she,said,that,he,said,that,they,left]).
% B2: adverbial clauses combine with a transitive matrix VP.
test(transitive_because_clause) :-
    ok([she,wrote,the,letter,because,he,arrived]).
% B2: a VP may carry an adverb and an adverbial S-bar.
test(stacked_vp_adjuncts) :- ok([she,left,quickly,because,he,arrived]).
% B2: the embedded sentence remains a normal finite clause.
test(embedded_transitive_clause) :-
    ok([she,said,that,he,wrote,the,letter]).

% B2 negative: say selects [that], not [whether].
test(say_wrong_complementiser, [true]) :-
    bad([she,said,whether,he,left]).
% B2 negative: ask selects [whether], not [that].
test(ask_wrong_complementiser, [true]) :-
    bad([she,asked,that,he,left]).
% B2 negative: the embedded clause must be finite.
test(embedded_nonfinite, [true]) :- bad([she,said,that,he,leave]).
% B2 negative: an adverbial subordinate clause requires its subordinator.
test(missing_subordinator, [true]) :- bad([she,left,he,arrived]).

:- end_tests(b2_subordinate_clauses).

:- begin_tests(b3_wh_and_relatives).

ok(Words)     :- assertion(accepts(Words)).
bad(Words)    :- assertion(rejects(Words)).
np_ok(Words)  :- assertion(phrase(grammar_core:np(_, np_feat(_, _)), Words)).
np_bad(Words) :- assertion(\+ phrase(grammar_core:np(_, np_feat(_, _)), Words)).

% B3: object wh-questions introduce and discharge one NP gap.
test(what_did_she_write) :- ok([what,did,she,write]).
test(what_did_they_admire) :- ok([what,did,they,admire]).
% B3: restrictive relative clauses may use which, that, or zero.
test(which_relative) :- np_ok([the,book,which,she,wrote]).
test(that_relative) :- np_ok([the,book,that,she,wrote]).
test(zero_relative) :- np_ok([the,book,she,wrote]).
% B3: relatives attach at NOM alongside B1 modifiers.
test(adjectival_head_relative) :- np_ok([the,old,book,which,she,wrote]).
test(predeterminer_head_relative) :- np_ok([all,the,books,that,she,wrote]).
test(relative_with_vp_adjunct) :- np_ok([the,book,which,she,wrote,quickly]).
test(complement_head_relative) :-
    np_ok([a,writer,of,books,which,she,admired]).
test(question_with_vp_adjunct) :- ok([what,did,she,write,quickly]).

% B3 negative: the object position introduced by what cannot also be overt.
test(question_gap_filled_twice, [true]) :-
    bad([what,did,she,write,the,letter]).
% B3 negative: did selects a bare VP, not a past finite VP.
test(question_form_mismatch, [true]) :- bad([what,did,she,wrote]).
% B3 negative: this grammar licenses wh inversion only with do support.
test(question_missing_do_support, [true]) :- bad([what,she,wrote]).
% B3 negative: a relative must contain the object gap, not another object NP.
test(relative_gap_filled_twice, [true]) :-
    np_bad([the,book,which,she,wrote,the,letter]).
% B3 negative: the relative clause must contain a finite VP.
test(relative_nonfinite, [true]) :- np_bad([the,book,which,she,write]).

:- end_tests(b3_wh_and_relatives).

:- begin_tests(b4_nonfinite_clauses).

ok(Words)  :- assertion(accepts(Words)).
bad(Words) :- assertion(rejects(Words)).

% B4: Type I supports covert and overt subjects in the infinitival clause.
test(type_i_covert_subject) :-
    ok([she,wants,to,leave]).
test(type_i_overt_subject) :-
    ok([she,wants,him,to,leave]).
% B4: Type II keeps the NP as the matrix direct object.
test(type_ii_matrix_object) :-
    ok([she,persuaded,him,to,leave]).
test(type_i_plural_subject) :-
    ok([they,want,to,leave]).
test(type_i_overt_plural_matrix_subject) :-
    ok([they,want,her,to,leave]).
test(type_ii_plural_subject) :-
    ok([they,persuaded,her,to,leave]).
test(type_i_past) :-
    ok([she,wanted,him,to,leave]).
test(type_i_perfect) :-
    ok([she,has,wanted,to,leave]).

% B4 negative: an infinitival VP requires the overt marker [to].
test(type_i_missing_to, [true]) :- bad([she,wants,him,leave]).
% B4 negative: Type II requires its matrix direct object.
test(type_ii_missing_object, [true]) :- bad([she,persuaded,to,leave]).
% B4 negative: Type II cannot omit the infinitival marker.
test(type_ii_missing_to, [true]) :- bad([she,persuaded,him,leave]).
% B4 negative: [to] selects the bare form, not the past form.
test(infinitival_form_mismatch, [true]) :- bad([she,wants,him,to,left]).

:- end_tests(b4_nonfinite_clauses).
