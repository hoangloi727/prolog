:- use_module(library(plunit)).
:- use_module(library(lists), [member/2]).
:- use_module(harness).

% C1 evaluation inventory: 40 grammatical sentences.
% Distribution: baseline 6, B1 8, B2 8, B3 10, B4 8.

good_item(baseline, intransitive, [kim,slept]).
good_item(baseline, transitive, [kim,wrote,the,letter]).
good_item(baseline, ditransitive, [they,give,her,a,story]).
good_item(baseline, perfect, [she,has,written,the,letter]).
good_item(baseline, passive, [the,letter,was,written]).
good_item(baseline, modal, [she,can,write,the,letter]).

good_item(b1, pp_complement, [a,writer,of,novels,sleeps]).
good_item(b1, pp_adjunct, [the,student,with,long,hair,sleeps]).
good_item(b1, predeterminer, [all,the,old,books,sleep]).
good_item(b1, complement_and_adjunct, [a,writer,of,novels,with,a,beard,sleeps]).
good_item(b1, stacked_postmodifiers, [the,student,with,long,hair,in,the,garden,sleeps]).
good_item(b1, bare_plural_complement, [a,writer,of,books,sleeps]).
good_item(b1, selected_with_complement, [a,friend,with,the,garden,sleeps]).
good_item(b1, adjective_before_adjunct, [the,old,student,with,long,hair,sleeps]).

good_item(b2, that_object, [she,said,that,he,left]).
good_item(b2, whether_object, [she,asked,whether,he,left]).
good_item(b2, because_adjunct, [she,left,because,he,arrived]).
good_item(b2, present_that_object, [she,says,that,they,leave]).
good_item(b2, nested_that_object, [she,said,that,he,said,that,they,left]).
good_item(b2, transitive_because_adjunct, [she,wrote,the,letter,because,he,arrived]).
good_item(b2, stacked_vp_adjuncts, [she,left,quickly,because,he,arrived]).
good_item(b2, embedded_transitive_clause, [she,said,that,he,wrote,the,letter]).

good_item(b3, wh_question, [what,did,she,write]).
good_item(b3, wh_question_plural, [what,did,they,admire]).
good_item(b3, which_relative, [the,book,which,she,wrote,sleeps]).
good_item(b3, that_relative, [the,book,that,she,wrote,sleeps]).
good_item(b3, zero_relative, [the,book,she,wrote,sleeps]).
good_item(b3, adjectival_relative_head, [the,old,book,which,she,wrote,sleeps]).
good_item(b3, predeterminer_relative_head, [all,the,books,that,she,wrote,sleep]).
good_item(b3, relative_with_vp_adjunct, [the,book,which,she,wrote,quickly,sleeps]).
good_item(b3, relative_on_complement_head, [a,writer,of,books,which,she,admired,sleeps]).
good_item(b3, wh_question_with_adjunct, [what,did,she,write,quickly]).

good_item(b4, type_1_covert_subject, [she,wants,to,leave]).
good_item(b4, type_1_overt_subject, [she,wants,him,to,leave]).
good_item(b4, type_2_matrix_object, [she,persuaded,him,to,leave]).
good_item(b4, type_1_plural_subject, [they,want,to,leave]).
good_item(b4, type_1_overt_plural_subject, [they,want,her,to,leave]).
good_item(b4, type_2_plural_subject, [they,persuaded,her,to,leave]).
good_item(b4, type_1_past, [she,wanted,him,to,leave]).
good_item(b4, type_1_perfect, [she,has,wanted,to,leave]).

% C1 challenge set: 20 ungrammatical sentences.
% Distribution: baseline 3, B1 4, B2 4, B3 5, B4 4.

bad_item(baseline, agreement, [she,write,the,letter],
         'third-person singular subject requires writes').
bad_item(baseline, case, [them,give,her,a,story],
         'them is accusative and cannot be the subject').
bad_item(baseline, auxiliary_form, [she,has,writing,the,letter],
         'perfect have selects the en form, not ing').

bad_item(b1, bare_count_noun, [student,sleeps],
         'a singular count noun requires a determiner').
bad_item(b1, writer_pp_selection, [a,writer,with,novels,sleeps],
         'writer selects an of PP complement').
bad_item(b1, friend_pp_selection, [a,friend,of,novels,sleeps],
         'friend selects a with PP complement').
bad_item(b1, predeterminer_order, [the,all,books,sleep],
         'the predeterminer must precede the determiner').

bad_item(b2, say_complementiser, [she,said,whether,he,left],
         'say selects that, not whether').
bad_item(b2, ask_complementiser, [she,asked,that,he,left],
         'ask selects whether, not that').
bad_item(b2, embedded_form, [she,said,that,he,leave],
         'the embedded clause must be finite').
bad_item(b2, missing_subordinator, [she,left,he,arrived],
         'an adverbial subordinate clause requires because').

bad_item(b3, double_gap_fill, [what,did,she,write,the,letter],
         'the object gap introduced by what is filled twice').
bad_item(b3, do_form, [what,did,she,wrote],
         'did selects a bare VP').
bad_item(b3, missing_do_support, [what,she,wrote],
         'this grammar licenses root wh inversion with did').
bad_item(b3, relative_double_gap_fill,
         [the,book,which,she,wrote,the,letter,sleeps],
         'the relative object gap is filled twice').
bad_item(b3, relative_nonfinite, [the,book,which,she,write,sleeps],
         'the relative clause must be finite').

bad_item(b4, type_1_missing_to, [she,wants,him,leave],
         'the infinitival VP requires to').
bad_item(b4, type_2_missing_object, [she,persuaded,to,leave],
         'Type II persuade requires a matrix direct object').
bad_item(b4, type_2_missing_to, [she,persuaded,him,leave],
         'the infinitival VP requires to').
bad_item(b4, infinitival_form, [she,wants,him,to,left],
         'to selects the bare form leave').

evaluation_sets(Good, Bad) :-
    findall(Words, good_item(_, _, Words), Good),
    findall(Words, bad_item(_, _, Words, _), Bad).

% Each pair differs in one constructionally relevant respect.
minimal_pair(perfect_form,
             [she,has,written,the,letter],
             [she,has,writing,the,letter],
             'perfect have selects en').
minimal_pair(subject_case,
             [they,give,her,a,story],
             [them,give,her,a,story],
             'subject position requires nominative case').
minimal_pair(writer_pp_selection,
             [a,writer,of,novels,sleeps],
             [a,writer,with,novels,sleeps],
             'writer selects of').
minimal_pair(say_complementiser,
             [she,said,that,he,left],
             [she,said,whether,he,left],
             'say selects that').
minimal_pair(ask_complementiser,
             [she,asked,whether,he,left],
             [she,asked,that,he,left],
             'ask selects whether').
minimal_pair(wh_do_form,
             [what,did,she,write],
             [what,did,she,wrote],
             'did selects bare').
minimal_pair(wh_gap_linearity,
             [what,did,she,write],
             [what,did,she,write,the,letter],
             'the wh object gap is discharged once').
minimal_pair(infinitival_form,
             [she,wants,him,to,leave],
             [she,wants,him,to,left],
             'to selects bare').

% Class is genuine when both phrase markers reflect a plausible attachment;
% it is spurious when the same by-phrase is licensed by duplicate rule paths.
ambiguity_item(passive_by,
               [the,letter,was,written,by,kim], 2, spurious,
               'vp_passive and generic VP adjunct rules both license by kim').
ambiguity_item(perfect_passive_by,
               [the,letter,has,been,written,by,kim], 3, spurious,
               'by kim is licensed in the passive and as adjuncts at two VP levels').
ambiguity_item(writer_pp_attachment,
               [a,writer,of,novels,with,a,beard,sleeps], 2, genuine,
               'with a beard can modify writer or the embedded novels NP').
ambiguity_item(nominal_pp_attachment,
               [the,student,with,long,hair,in,the,garden,sleeps], 2, genuine,
               'in the garden can modify the student NOM or the embedded hair NP').

:- begin_tests(own_test).

test(good_distribution, true(Counts == [baseline-6,b1-8,b2-8,b3-10,b4-8])) :-
    findall(Section-Words, good_item(Section, _, Words), Items),
    section_counts(Items, Counts).

test(bad_distribution, true(Counts == [baseline-3,b1-4,b2-4,b3-5,b4-4])) :-
    findall(Section-Words, bad_item(Section, _, Words, _), Items),
    section_counts(Items, Counts).

test(evaluation_set_sizes, true(GoodCount-BadCount == 40-20)) :-
    evaluation_sets(Good, Bad),
    length(Good, GoodCount),
    length(Bad, BadCount).

test(good_items_are_accepted) :-
    evaluation_sets(Good, _),
    forall(member(Words, Good), assertion(accepts(Words))).

test(bad_items_are_rejected) :-
    evaluation_sets(_, Bad),
    forall(member(Words, Bad), assertion(rejects(Words))).

test(minimal_pair_count, true(Count =:= 8)) :-
    findall(Name, minimal_pair(Name, _, _, _), Pairs),
    length(Pairs, Count).

test(minimal_pairs_isolate_rejection) :-
    forall(minimal_pair(_, Good, Bad, _),
           ( assertion(accepts(Good)), assertion(rejects(Bad)) )).

test(ambiguity_inventory, true(Count =:= 4)) :-
    findall(Name, ambiguity_item(Name, _, _, _, _), Items),
    length(Items, Count).

test(ambiguity_counts) :-
    forall(ambiguity_item(_, Words, Expected, _, _),
           ( n_parses(Words, Actual), assertion(Actual =:= Expected) )).

% Phrase-marker checks for the structural claims made by B1-B4.
test(b1_complement_pp_is_inside_nominal_base) :-
    once(( phrase(grammar_core:np(Tree, np_feat(_, _)), [a,writer,of,novels]),
           assertion(Tree = np(det(a), nom(n(writer), _))) )).

test(b1_adjunct_pp_wraps_nominal_base) :-
    once(( phrase(grammar_core:np(Tree, np_feat(_, _)), [the,student,with,long,hair]),
           assertion(Tree = np(det(the), nom(nom(n(student)), _))) )).

test(b2_selected_sbar_is_vp_complement) :-
    once(( parse([she,said,that,he,left], Tree),
           assertion(Tree = s(pro(she), vp(v(said), sbar(that, _)))) )).

test(b3_question_contains_object_gap_clause) :-
    once(( parse([what,did,she,write], Tree),
           assertion(Tree = q(wh(what), aux(did), s(pro(she), vp(v(write))))) )).

test(b3_relative_is_nominal_postmodifier) :-
    once(( parse([the,book,which,she,wrote,sleeps], Tree),
           assertion(Tree = s(np(det(the), nom(nom(n(book)), rel_clause(_, _))), _)) )).

test(b4_type_1_embeds_overt_subject) :-
    once(( parse([she,wants,him,to,leave], Tree),
           assertion(Tree = s(pro(she), vp(v(wants), inf_clause(pro(him), to(inf), _)))) )).

test(b4_type_2_has_matrix_object) :-
    once(( parse([she,persuaded,him,to,leave], Tree),
           assertion(Tree = s(pro(she), vp(v(persuaded), pro(him), inf_clause(pro, to(inf), _)))) )).

:- end_tests(own_test).

section_counts(Items, Counts) :-
    section_count(baseline, Items, Baseline),
    section_count(b1, Items, B1),
    section_count(b2, Items, B2),
    section_count(b3, Items, B3),
    section_count(b4, Items, B4),
    Counts = [baseline-Baseline,b1-B1,b2-B2,b3-B3,b4-B4].

section_count(Section, Items, Count) :-
    findall(Words, member(Section-Words, Items), Matches),
    length(Matches, Count).
