% ============================================================
%  grammar_core.pl  --  BASELINE GRAMMAR
%  Selected constructions from Chapters 2-6; not full chapter coverage.
%  Final Project starter kit
%  Computational Linguistics
%  Student release: 2026-08-25
%
%  Reference: Burton-Roberts, Analysing Sentences (5th ed.), 2022.
%
%  IDIOM (preserve the exported interface; mark extensions [B1]-[B4]):
%    * Feature records are COMPOUND TERMS, never feature lists.
%         np_feat(Agr, Case)              Agr = agr(Person, Num)
%         vp_feat(Agr, Form)
%         lex_feat(Agr, Form, Subcat)
%         aux_feat(Agr, Form, Function, SelectedForm)
%         pp_feat(PForm)
%    * Every rule builds a phrase marker in its FIRST argument.
%    * Form values: fin(pres), fin(past), bare, en, ing
%    * Agreement is threaded by SHARING the variable Agr.
%    * No assert/1, no cut in the grammar, no left recursion.
% ============================================================

:- module(grammar_core, [ sentence//1,
                          np//2, nominal//2, vp//2, basic_vp//2,
                          pp//2, ap//1,
                          lexical_verb//2, auxiliary//2, noun//2,
                          determiner//2, pronoun//2, proper_name//2,
                          preposition//2, adverb//1, adjective//1,
                          pres_nonsg3/1 ]).

:- discontiguous basic_vp//2.
:- discontiguous noun//2, noun_c//3, mass_noun//1, adjective//1, adverb//1, preposition//2.

% ============================================================
%  1. SENTENCE  (Ch. 2, 6)
%     S -> NP[nom] + VP[finite],  agreement via shared Agr
% ============================================================

sentence(s(NP, VP)) -->
    np(NP, np_feat(Agr, nom)),
    vp(VP, vp_feat(Agr, fin(_))).

% ============================================================
%  2. NOUN PHRASE  (Ch. 3)
%     NP -> (DET) + NOM ;  NOM -> (AP) + N
% ============================================================

np(NP, F)                              --> pronoun(NP, F).
np(np(PN), np_feat(agr(3,Num), _Case)) --> proper_name(PN, Num).
np(np(Det,Nom), np_feat(agr(3,Num), _Case)) -->
    determiner(Det, Num),
    nominal(Nom, Num).

% [B1] Bare plurals and mass nouns are lexically licensed without a determiner.
np(np(Nom), np_feat(agr(3,pl), _Case)) --> nominal(Nom, pl).
np(np(Nom), np_feat(agr(3,sg), _Case)) --> mass_nominal(Nom).
np(np(Predet,Det,Nom), np_feat(agr(3,Num), _Case)) -->
    predeterminer(Predet),
    determiner(Det, Num),
    nominal(Nom, Num).
np(np(Predet,Det,Nom), np_feat(agr(3,sg), _Case)) -->
    predeterminer(Predet),
    determiner(Det, sg),
    mass_nominal(Nom).

% [B1] NOM -> base (+ PP adjuncts). Selected PP complements stay inside Base.
nominal(Nom, Num) -->
    nominal_base(Base, Num),
    nom_post_mods(Base, Nom).

nominal_base(nom(N,PP), Num) -->
    noun_c(N, Num, PForm),
    pp(PP, pp_feat(PForm)).
nominal_base(nom(N), Num) --> noun(N, Num).
nominal_base(nom(AP,Nom), Num) --> ap(AP), nominal_base(Nom, Num).

mass_nominal(Nom) -->
    mass_nominal_base(Base),
    nom_post_mods(Base, Nom).

mass_nominal_base(nom(N)) --> mass_noun(N).
mass_nominal_base(nom(AP,Nom)) --> ap(AP), mass_nominal_base(Nom).

nom_post_mods(Nom, Nom) --> [].
nom_post_mods(Acc, Nom) -->
    pp(PP, _),
    nom_post_mods(nom(Acc,PP), Nom).

% ============================================================
%  3. ADJECTIVE PHRASE / PREPOSITIONAL PHRASE  (Ch. 3)
% ============================================================

ap(ap(A)) --> adjective(A).

pp(pp(P,NP), pp_feat(PForm)) -->
    preposition(P, PForm),
    np(NP, np_feat(_, acc)).

% ============================================================
%  4. VERB PHRASE  (Ch. 4, 5, 6)
%     VP -> basic_vp + accumulated adjuncts (sister-of-VP)
%     The accumulator avoids the left recursion of vp --> vp, adjunct
% ============================================================

vp(VP, F) --> basic_vp(Base, F), post_adjuncts(Base, VP).

post_adjuncts(VP, VP)  --> [].
post_adjuncts(Acc, VP) --> adjunct(Adj), post_adjuncts(vp(Acc,Adj), VP).

adjunct(adv(A)) --> adverb(A).
adjunct(PP)     --> pp(PP, _).

% --- 4.1 Lexical verbs: the six subcategories of Ch. 4 -------

basic_vp(vp(V), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, intrans)).

basic_vp(vp(V,DO), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, trans)),
    np(DO, np_feat(_, acc)).

basic_vp(vp(V,IO,DO), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, ditrans)),
    np(IO, np_feat(_, acc)),
    np(DO, np_feat(_, acc)).

basic_vp(vp(V,SP), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, intens)),
    predicative(SP).

basic_vp(vp(V,DO,OP), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, complex)),
    np(DO, np_feat(_, acc)),
    predicative(OP).

basic_vp(vp(V,PP), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, prep(PForm))),
    pp(PP, pp_feat(PForm)).

predicative(AP) --> ap(AP).
predicative(NP) --> np(NP, np_feat(_, acc)).

% --- 4.2 Auxiliary verbs: MOD > PERF > PROG > PASS  (Ch. 6) ---
%     Ordering is enforced by FORM SELECTION, not by a list.

basic_vp(vp(Aux,VP), vp_feat(Agr,Form)) -->
    auxiliary(Aux, aux_feat(Agr, Form, Function, Selected)),
    { active_function(Function) },
    vp(VP, vp_feat(_, Selected)).

active_function(mod).
active_function(perf).
active_function(prog).

% --- 4.3 Passive: PARALLEL RULE SET, not a [voice] feature ---

basic_vp(vp(Aux,VPp), vp_feat(Agr,Form)) -->
    auxiliary(Aux, aux_feat(Agr, Form, pass, en)),
    vp_passive(VPp).

vp_passive(vp(V))    --> lexical_verb(V, lex_feat(_, en, trans)).
vp_passive(vp(V,PP)) --> lexical_verb(V, lex_feat(_, en, trans)),
                         pp(PP, pp_feat(by)).

% ============================================================
%  5. LEXICON
% ============================================================

% --- 5.1 Present-tense agreement helper ---------------------
pres_nonsg3(agr(1,sg)).
pres_nonsg3(agr(2,sg)).
pres_nonsg3(agr(1,pl)).
pres_nonsg3(agr(2,pl)).
pres_nonsg3(agr(3,pl)).

% --- 5.2 Pronouns -------------------------------------------
pronoun(pro(i),    np_feat(agr(1,sg), nom)) --> [i].
pronoun(pro(me),   np_feat(agr(1,sg), acc)) --> [me].
pronoun(pro(she),  np_feat(agr(3,sg), nom)) --> [she].
pronoun(pro(her),  np_feat(agr(3,sg), acc)) --> [her].
pronoun(pro(he),   np_feat(agr(3,sg), nom)) --> [he].
pronoun(pro(him),  np_feat(agr(3,sg), acc)) --> [him].
pronoun(pro(they), np_feat(agr(3,pl), nom)) --> [they].
pronoun(pro(them), np_feat(agr(3,pl), acc)) --> [them].

% --- 5.3 Proper names ---------------------------------------
proper_name(name(kim),   sg) --> [kim].
proper_name(name(lucy),  sg) --> [lucy].
proper_name(name(max),   sg) --> [max].

% --- 5.4 Determiners ----------------------------------------
determiner(det(the),  _)  --> [the].
determiner(det(a),    sg) --> [a].
determiner(det(this), sg) --> [this].
determiner(det(these),pl) --> [these].
determiner(det(some), pl) --> [some].

% --- 5.5 Nouns ----------------------------------------------
noun(n(student),  sg) --> [student].
noun(n(students), pl) --> [students].
noun(n(letter),   sg) --> [letter].
noun(n(letters),  pl) --> [letters].
noun(n(book),     sg) --> [book].
noun(n(books),    pl) --> [books].
noun(n(cat),      sg) --> [cat].
noun(n(cats),     pl) --> [cats].
noun(n(nurse),    sg) --> [nurse].
noun(n(story),    sg) --> [story].
noun(n(stories),  pl) --> [stories].

% --- 5.6 Adjectives, adverbs, prepositions ------------------
adjective(adj(old))     --> [old].
adjective(adj(clever))  --> [clever].
adjective(adj(happy))   --> [happy].
adjective(adj(long))    --> [long].

adverb(adv(yesterday))  --> [yesterday].
adverb(adv(quickly))    --> [quickly].
adverb(adv(often))      --> [often].

preposition(p(on),   on)   --> [on].
preposition(p(in),   in)   --> [in].
preposition(p(to),   to)   --> [to].
preposition(p(by),   by)   --> [by].
preposition(p(at),   at)   --> [at].
preposition(p(with), with) --> [with].

% [B1] Required NP vocabulary; noun_c/3 records PP selection for B1.
noun_c(n(writer), sg, of) --> [writer].
noun(n(novel),    sg)     --> [novel].
noun(n(novels),   pl)     --> [novels].
noun(n(beard),    sg)     --> [beard].
mass_noun(n(hair))        --> [hair].
predeterminer(predet(all)) --> [all].
preposition(p(of), of)    --> [of].

% [B1] Project additions: friend selects [with]; garden, green, and quietly
% provide additional nominal and modifier vocabulary for the declared tests.
noun_c(n(friend), sg, with) --> [friend].
noun(n(garden),   sg)       --> [garden].
adjective(adj(green))       --> [green].
adverb(adv(quietly))        --> [quietly].
preposition(p(near), near)  --> [near].

% [B2] Complementisers and subordinator; selection is encoded on the verb.
complementiser(comp(that))       --> [that].
complementiser(comp(whether))    --> [whether].
subordinator(subordinator(because)) --> [because].

% [B3] Wh and relative-clause vocabulary. The zero relativiser consumes no input.
wh_pronoun(wh(what), np)         --> [what].
relativiser(rel(which))           --> [which].
relativiser(rel(that))            --> [that].
relativiser(rel(zero))            --> [].

% [B4] Infinitival to is distinct from the lexical preposition [to].
infinitival_marker(to(inf)) --> [to].

% --- 5.7 Lexical verbs --------------------------------------
%     Each entry: word / agreement / form / subcategory

% write (trans)
lexical_verb(v(writes),  lex_feat(agr(3,sg), fin(pres), trans)) --> [writes].
lexical_verb(v(write),   lex_feat(Agr, fin(pres), trans)) --> [write],
    { pres_nonsg3(Agr) }.
lexical_verb(v(wrote),   lex_feat(_, fin(past), trans)) --> [wrote].
lexical_verb(v(write),   lex_feat(_, bare, trans))      --> [write].
lexical_verb(v(written), lex_feat(_, en,   trans))      --> [written].
lexical_verb(v(writing), lex_feat(_, ing,  trans))      --> [writing].

% read (trans)
lexical_verb(v(reads),   lex_feat(agr(3,sg), fin(pres), trans)) --> [reads].
lexical_verb(v(read),    lex_feat(Agr, fin(pres), trans)) --> [read],
    { pres_nonsg3(Agr) }.
lexical_verb(v(read),    lex_feat(_, bare, trans)) --> [read].
lexical_verb(v(read),    lex_feat(_, en,   trans)) --> [read].
lexical_verb(v(reading), lex_feat(_, ing,  trans)) --> [reading].

% sleep (intrans)
lexical_verb(v(sleeps),   lex_feat(agr(3,sg), fin(pres), intrans)) --> [sleeps].
lexical_verb(v(sleep),    lex_feat(Agr, fin(pres), intrans)) --> [sleep],
    { pres_nonsg3(Agr) }.
lexical_verb(v(slept),    lex_feat(_, fin(past), intrans)) --> [slept].
lexical_verb(v(sleep),    lex_feat(_, bare, intrans))      --> [sleep].
lexical_verb(v(slept),    lex_feat(_, en,   intrans))      --> [slept].
lexical_verb(v(sleeping), lex_feat(_, ing,  intrans))      --> [sleeping].

% give (ditrans)
lexical_verb(v(gives),  lex_feat(agr(3,sg), fin(pres), ditrans)) --> [gives].
lexical_verb(v(give),   lex_feat(Agr, fin(pres), ditrans)) --> [give],
    { pres_nonsg3(Agr) }.
lexical_verb(v(gave),   lex_feat(_, fin(past), ditrans)) --> [gave].
lexical_verb(v(give),   lex_feat(_, bare, ditrans))      --> [give].
lexical_verb(v(given),  lex_feat(_, en,   ditrans))      --> [given].
lexical_verb(v(giving), lex_feat(_, ing,  ditrans))      --> [giving].

% seem (intensive)
lexical_verb(v(seems),   lex_feat(agr(3,sg), fin(pres), intens)) --> [seems].
lexical_verb(v(seem),    lex_feat(Agr, fin(pres), intens)) --> [seem],
    { pres_nonsg3(Agr) }.
lexical_verb(v(seemed),  lex_feat(_, fin(past), intens)) --> [seemed].
lexical_verb(v(seem),    lex_feat(_, bare, intens))      --> [seem].
lexical_verb(v(seeming), lex_feat(_, ing,  intens))      --> [seeming].

% consider (complex transitive)
lexical_verb(v(considers), lex_feat(agr(3,sg), fin(pres), complex)) --> [considers].
lexical_verb(v(consider),  lex_feat(Agr, fin(pres), complex)) --> [consider],
    { pres_nonsg3(Agr) }.
lexical_verb(v(considered),lex_feat(_, fin(past), complex)) --> [considered].
lexical_verb(v(consider),  lex_feat(_, bare, complex))      --> [consider].
lexical_verb(v(considered),lex_feat(_, en,   complex))      --> [considered].

% rely (prepositional, selects [on])
lexical_verb(v(relies), lex_feat(agr(3,sg), fin(pres), prep(on))) --> [relies].
lexical_verb(v(rely),   lex_feat(Agr, fin(pres), prep(on))) --> [rely],
    { pres_nonsg3(Agr) }.
lexical_verb(v(relied), lex_feat(_, fin(past), prep(on))) --> [relied].
lexical_verb(v(rely),   lex_feat(_, bare, prep(on)))      --> [rely].

% [B2] say selects a that-clause; forms supplied for finite and auxiliary use.
lexical_verb(v(says),   lex_feat(agr(3,sg), fin(pres), scomp(that))) --> [says].
lexical_verb(v(say),    lex_feat(Agr, fin(pres), scomp(that))) --> [say],
    { pres_nonsg3(Agr) }.
lexical_verb(v(said),   lex_feat(_, fin(past), scomp(that))) --> [said].
lexical_verb(v(say),    lex_feat(_, bare, scomp(that)))      --> [say].
lexical_verb(v(said),   lex_feat(_, en, scomp(that)))        --> [said].
lexical_verb(v(saying), lex_feat(_, ing, scomp(that)))       --> [saying].

% [B2] ask selects a whether-clause.
lexical_verb(v(asks),   lex_feat(agr(3,sg), fin(pres), scomp(whether))) --> [asks].
lexical_verb(v(ask),    lex_feat(Agr, fin(pres), scomp(whether))) --> [ask],
    { pres_nonsg3(Agr) }.
lexical_verb(v(asked),  lex_feat(_, fin(past), scomp(whether))) --> [asked].
lexical_verb(v(ask),    lex_feat(_, bare, scomp(whether)))      --> [ask].
lexical_verb(v(asked),  lex_feat(_, en, scomp(whether)))        --> [asked].
lexical_verb(v(asking), lex_feat(_, ing, scomp(whether)))       --> [asking].

% [B2] arrive is needed by adverbial subordinate clauses.
lexical_verb(v(arrives),  lex_feat(agr(3,sg), fin(pres), intrans)) --> [arrives].
lexical_verb(v(arrive),   lex_feat(Agr, fin(pres), intrans)) --> [arrive],
    { pres_nonsg3(Agr) }.
lexical_verb(v(arrived),  lex_feat(_, fin(past), intrans)) --> [arrived].
lexical_verb(v(arrive),   lex_feat(_, bare, intrans))      --> [arrive].
lexical_verb(v(arrived),  lex_feat(_, en, intrans))        --> [arrived].
lexical_verb(v(arriving), lex_feat(_, ing, intrans))       --> [arriving].

% [B4] Non-finite-clause selection is lexical: want is Type I; persuade is Type II.
lexical_verb(v(wants),   lex_feat(agr(3,sg), fin(pres), infinitive(type_1))) --> [wants].
lexical_verb(v(want),    lex_feat(Agr, fin(pres), infinitive(type_1))) --> [want],
    { pres_nonsg3(Agr) }.
lexical_verb(v(wanted),  lex_feat(_, fin(past), infinitive(type_1))) --> [wanted].
lexical_verb(v(want),    lex_feat(_, bare, infinitive(type_1)))      --> [want].
lexical_verb(v(wanted),  lex_feat(_, en, infinitive(type_1)))        --> [wanted].
lexical_verb(v(wanting), lex_feat(_, ing, infinitive(type_1)))       --> [wanting].

lexical_verb(v(persuades),  lex_feat(agr(3,sg), fin(pres), infinitive(type_2))) --> [persuades].
lexical_verb(v(persuade),   lex_feat(Agr, fin(pres), infinitive(type_2))) --> [persuade],
    { pres_nonsg3(Agr) }.
lexical_verb(v(persuaded),  lex_feat(_, fin(past), infinitive(type_2))) --> [persuaded].
lexical_verb(v(persuade),   lex_feat(_, bare, infinitive(type_2)))      --> [persuade].
lexical_verb(v(persuaded),  lex_feat(_, en, infinitive(type_2)))        --> [persuaded].
lexical_verb(v(persuading), lex_feat(_, ing, infinitive(type_2)))       --> [persuading].

% [B4] leave supplies the lexical VP required by the infinitival examples.
lexical_verb(v(leaves),   lex_feat(agr(3,sg), fin(pres), intrans)) --> [leaves].
lexical_verb(v(leave),    lex_feat(Agr, fin(pres), intrans)) --> [leave],
    { pres_nonsg3(Agr) }.
lexical_verb(v(left),     lex_feat(_, fin(past), intrans)) --> [left].
lexical_verb(v(leave),    lex_feat(_, bare, intrans))      --> [leave].
lexical_verb(v(left),     lex_feat(_, en, intrans))        --> [left].
lexical_verb(v(leaving),  lex_feat(_, ing, intrans))       --> [leaving].

% [B1] Project additions: admire (transitive) and travel (intransitive).
lexical_verb(v(admires),  lex_feat(agr(3,sg), fin(pres), trans)) --> [admires].
lexical_verb(v(admire),   lex_feat(Agr, fin(pres), trans)) --> [admire],
    { pres_nonsg3(Agr) }.
lexical_verb(v(admired),  lex_feat(_, fin(past), trans)) --> [admired].
lexical_verb(v(admire),   lex_feat(_, bare, trans))      --> [admire].
lexical_verb(v(admired),  lex_feat(_, en, trans))        --> [admired].
lexical_verb(v(admiring), lex_feat(_, ing, trans))       --> [admiring].

lexical_verb(v(travels),  lex_feat(agr(3,sg), fin(pres), intrans)) --> [travels].
lexical_verb(v(travel),   lex_feat(Agr, fin(pres), intrans)) --> [travel],
    { pres_nonsg3(Agr) }.
lexical_verb(v(travelled),lex_feat(_, fin(past), intrans)) --> [travelled].
lexical_verb(v(travel),   lex_feat(_, bare, intrans))      --> [travel].
lexical_verb(v(travelled),lex_feat(_, en, intrans))        --> [travelled].
lexical_verb(v(travelling),lex_feat(_, ing, intrans))      --> [travelling].

% --- 5.8 Auxiliary verbs ------------------------------------
%     aux_feat(Agr, OwnForm, Function, FormSelectedFromComplement)

% Modals: finite only, no agreement contrast, select [bare]
auxiliary(aux(can),   aux_feat(_, fin(pres), mod, bare)) --> [can].
auxiliary(aux(could), aux_feat(_, fin(past), mod, bare)) --> [could].
auxiliary(aux(will),  aux_feat(_, fin(pres), mod, bare)) --> [will].
auxiliary(aux(would), aux_feat(_, fin(past), mod, bare)) --> [would].

% Perfect HAVE: selects [en]
auxiliary(aux(has),   aux_feat(agr(3,sg), fin(pres), perf, en)) --> [has].
auxiliary(aux(have),  aux_feat(Agr, fin(pres), perf, en)) --> [have],
    { pres_nonsg3(Agr) }.
auxiliary(aux(had),   aux_feat(_, fin(past), perf, en)) --> [had].
auxiliary(aux(have),  aux_feat(_, bare, perf, en))      --> [have].
auxiliary(aux(having),aux_feat(_, ing,  perf, en))      --> [having].

% [B3] DO support selects a bare VP; its active grammar rule is added in B3.
auxiliary(aux(did), aux_feat(_, fin(past), do, bare)) --> [did].

% Progressive BE: selects [ing]
auxiliary(aux(is),    aux_feat(agr(3,sg), fin(pres), prog, ing)) --> [is].
auxiliary(aux(are),   aux_feat(agr(3,pl), fin(pres), prog, ing)) --> [are].
auxiliary(aux(am),    aux_feat(agr(1,sg), fin(pres), prog, ing)) --> [am].
auxiliary(aux(was),   aux_feat(agr(3,sg), fin(past), prog, ing)) --> [was].
auxiliary(aux(were),  aux_feat(agr(3,pl), fin(past), prog, ing)) --> [were].
auxiliary(aux(be),    aux_feat(_, bare, prog, ing))              --> [be].
auxiliary(aux(been),  aux_feat(_, en,   prog, ing))              --> [been].

% Passive BE: selects [en]  (same forms, different Function)
auxiliary(aux(is),    aux_feat(agr(3,sg), fin(pres), pass, en)) --> [is].
auxiliary(aux(are),   aux_feat(agr(3,pl), fin(pres), pass, en)) --> [are].
auxiliary(aux(am),    aux_feat(agr(1,sg), fin(pres), pass, en)) --> [am].
auxiliary(aux(was),   aux_feat(agr(3,sg), fin(past), pass, en)) --> [was].
auxiliary(aux(were),  aux_feat(agr(3,pl), fin(past), pass, en)) --> [were].
auxiliary(aux(be),    aux_feat(_, bare, pass, en))              --> [be].
auxiliary(aux(been),  aux_feat(_, en,   pass, en))              --> [been].
