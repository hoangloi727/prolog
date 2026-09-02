:- use_module(library(plunit)).
:- use_module(harness).

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
