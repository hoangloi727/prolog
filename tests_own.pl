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
