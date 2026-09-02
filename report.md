# D1 Report: Feature-Based English DCG Grammar

## Abstract

This project implements a pure, feature-based definite-clause grammar (DCG) for selected English constructions from Chapters 2-10 of Burton-Roberts (2022). The supplied Chapters 2-6 baseline was retained and extended in four components: internal NP structure and PP attachment (B1), finite S-bar complements and adverbial clauses (B2), object wh-questions and restrictive object relatives (B3), and `to`-infinitival clauses (B4). Phrase markers are constructed during parsing, while compound feature records enforce agreement, case, verbal form, and lexical selection by unification. The submitted evaluation set has 40 grammatical and 20 ungrammatical complete sentences. It achieved 40/40 coverage and 0/20 false acceptances; mean ambiguity is 1.07 parses per accepted sentence. Residual issues are spurious passive `by`-phrase ambiguity and a deliberately retained lexical gap for past-tense *read*.

## Introduction And Scope

The grammar is implemented in SWI-Prolog 10.0.2 in `grammar_core.pl`. It recognises word-token lists and simultaneously constructs phrase markers. It is deliberately a grammar fragment, rather than an attempted full grammar of English.

The retained baseline covers selected material from Chapters 2-6: finite subject-predicate clauses; determiner, adjective, nominal, pronoun, and proper-name NPs; the six declared verbal subcategories; VP adverb and PP adjuncts; agreement and pronoun case; and the auxiliary sequence `mod > perf > prog > pass`. Passive is implemented through a parallel rule set, not an added voice feature.

The extensions cover Chapter 7 NP-internal constituency (B1), Chapter 8 subordinate clauses (B2), Chapter 9 object extraction and object relatives (B3), and Chapter 10 `to`-infinitives (B4). The declared vocabulary is deliberately finite. Additional project vocabulary is `friend`, `garden`, `green`, `quietly`, `near`, `admire`, and `travel`.

The principal exclusions are sentence adverbials, phrasal verbs, ellipsis, negation, general do-support and inversion, subject wh-extraction, PP gaps, preposition stranding, pied-piping, island constraints, long-distance extraction, `for`-infinitives, and `-ing` clauses. These are exclusions of constructional coverage, not claims that the excluded strings are ungrammatical English.

## Feature System

### Feature Records

The grammar uses fixed-arity compound terms as attribute-value records. In linguistic notation, the five records are:

| Record | Attribute-value presentation | Purpose |
| --- | --- | --- |
| `np_feat(Agr, Case)` | `[AGR Agr, CASE Case]` | NP agreement and morphological case |
| `vp_feat(Agr, Form)` | `[AGR Agr, FORM Form]` | VP agreement and verbal form |
| `lex_feat(Agr, Form, Subcat)` | `[AGR Agr, FORM Form, SUBCAT Subcat]` | Lexical verb inflection and complement selection |
| `aux_feat(Agr, Form, Function, Selected)` | `[AGR Agr, FORM Form, FUNCTION Function, SELECTED Selected]` | Auxiliary form and the form it selects |
| `pp_feat(PForm)` | `[PFORM PForm]` | Preposition identity/selection |

`Agr` has the shape `agr(Person, Number)`. Relevant form values are `fin(pres)`, `fin(past)`, `bare`, `en`, and `ing`; `Case` is `nom` or `acc`. Subcategorisation values include `trans`, `scomp(that)`, `scomp(whether)`, `infinitive(type_1)`, and `infinitive(type_2)`.

### What Unification Enforces

Unification is equality of compatible feature descriptions. In a finite clause, the subject and VP share the same agreement variable:

```prolog
finite_sentence(s(NP, VP)) -->
    np(NP, np_feat(Agr, nom)),
    vp(VP, vp_feat(Agr, fin(_))).
```

For `she writes the letter`, the pronoun fixes `Agr` to `agr(3,sg)` and the lexical verb must therefore have the same agreement and finite present form. `she write the letter` fails because the non-third-singular present entry cannot unify with that value. The subject position likewise requests nominative case; `them` is lexically accusative and cannot unify there.

Unification also enforces form selection. For example, `has` selects `en`, and `did` selects `bare`. Lexical selection is encoded in a verb's subcategorisation value: `said` has `scomp(that)`, which must unify with the complementiser expected by the S-bar rule.

Unification does not encode all linguistic facts automatically. Full NPs carry unspecified morphological case because English articles and common nouns generally do not overtly distinguish nominative from accusative. It also does not by itself guarantee that a gap is discharged exactly once. B3 therefore supplies a separate gap-bearing VP rule with precisely one gap site. Semantic plausibility is also outside the feature system: it cannot, for example, prefer the likely attachment of `with a beard` over a semantically odd alternative.

## Implementation

### B1: NP Internal Structure

**Phenomenon.** B1 implements the hierarchy `NP -> NOM -> N`, predeterminers, selected PP complements of nouns, NOM-level PP adjuncts, and arbitrarily stacked post-modifiers. A noun's complement PP is a sister of N inside the base nominal; an adjunct PP is attached outside that base, as a sister of NOM.

**Phrase marker.** The required string `[a,writer,of,novels,with,a,beard]` has the relevant structure below. The inner `nom(n(writer), PP)` is the base constituent; the outer `nom(Base, PP)` adds an adjunct.

```text
np(det(a),
   nom(nom(n(writer), pp(p(of), np(nom(n(novels))))),
       pp(p(with), np(det(a), nom(n(beard))))))
```

This predicts that the constituent `writer of novels` is a NOM-sized unit, while `writer of novels with a beard` is the larger NOM after adjunct attachment. Thus both spans, in their corresponding contexts, are candidates for pro-NOM *one* replacement; `of novels` alone is not a NOM and is not predicted to be replaceable by *one*.

**Feature structure.** `writer` is encoded as `noun_c(n(writer), sg, of)`, so it selects a PP with `[PFORM of]`. The entire NP has `[AGR agr(3,sg), CASE Case]`; `a` supplies singular number. In contrast, the adjunct rule passes an unconstrained PP feature because adjunct PPs are not selected by the noun.

**Key rule.**

```prolog
nominal(Nom, Num) -->
    nominal_base(Base, Num),
    nom_post_mods(Base, Nom).

nominal_base(nom(N,PP), Num) -->
    noun_c(N, Num, PForm), pp(PP, pp_feat(PForm)).
nominal_base(nom(N), Num) --> noun(N, Num).

nom_post_mods(Nom, Nom) --> [].
nom_post_mods(Acc, Nom) -->
    pp(PP, _), nom_post_mods(nom(Acc,PP), Nom).
```

**Variable sharing.** `Num` is shared from determiner through nominal base to noun, so `a writer` is singular. `PForm` is shared only between `noun_c/3` and its complement PP, so `writer` accepts `of novels` but not `with novels`; `friend` conversely selects `with`. No procedural inspection of a word is used.

**Minimal pair.** `[a,writer,of,novels,sleeps]` is accepted, whereas `[a,writer,with,novels,sleeps]` is rejected because the selected `[PFORM of]` and supplied `[PFORM with]` do not unify. The complementary `friend with` / `friend of` pair is also in the negative inventory.

**Error analysis.** `[a,writer,of,novels,with,a,beard,sleeps]` has two parses. The `of` PP is fixed as the writer's complement, but `with a beard` can modify the writer NOM or the embedded `novels` NP. This is retained as genuine structural ambiguity: semantic selection would disprefer the latter reading, but is not represented. The similar `student with long hair in the garden` item has two genuine attachment analyses.

**Rejected alternative.** The left-recursive rule `nominal(Nom, PP) --> nominal(Nom), pp(PP, _)` was rejected. In top-down DCG execution it would call `nominal` again before consuming input, which can diverge. The accumulator instead consumes a PP before recurring, and retains the structural distinction between complement and adjunct in the tree.

### B2: Sentences Within Sentences

**Phenomenon.** B2 implements overt-complementiser S-bars as direct objects and adverbial subordinate clauses. Declarative `that` and interrogative `whether` are lexically selected by the matrix verb. `because` clauses are VP sisters, because they modify the event denoted by the VP rather than fill the matrix verb's object position.

**Phrase marker.** `[she,said,that,he,left]` produces the following object-complement structure:

```text
s(pro(she),
  vp(v(said), sbar(that, s(pro(he), vp(v(left))))))
```

In `[she,left,because,he,arrived]`, the S-bar is instead wrapped around a completed VP by the VP-adjunct accumulator: `vp(vp(v(left)), sbar(subordinator(because), ...))`.

**Feature structure.** `said` has `[AGR _, FORM fin(past), SUBCAT scomp(that)]`; `asked` has the corresponding `scomp(whether)` value. The S-bar argument is the expected complementiser, and the embedded clause is independently finite: `[FORM fin(_)]`.

**Key rule.**

```prolog
basic_vp(vp(V,SBar), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, scomp(Comp))),
    sbar(SBar, Comp).

sbar(sbar(Comp,S), Comp) -->
    complementiser(comp(Comp)), finite_sentence(S).

adverbial_sbar(sbar(Sub,S)) -->
    subordinator(Sub), finite_sentence(S).
```

**Variable sharing.** `Comp` occurs in the verb's lexical feature, the `sbar/2` call, and the complementiser entry. It therefore unifies `said` with `that`, and `asked` with `whether`, without a predicate that tests the lexical item. `Agr` still links the matrix subject and matrix finite verb; the embedded finite sentence introduces its own agreement variable.

**Minimal pair.** `[she,said,that,he,left]` is accepted and `[she,said,whether,he,left]` is rejected. The one-token replacement makes `scomp(that)` incompatible with `whether`. The parallel `asked whether` / `asked that` pair tests the reverse selection.

**Error analysis.** No B2 item failed in the C1 set. The negative `[she,said,that,he,leave]` is correctly rejected because the embedded sentence requires a finite VP. A boundary case is long-distance extraction, `[what,did,she,say,that,he,wrote]`, which is rejected because the gap mechanism is deliberately limited to one clause.

**Rejected alternative.** Treating every S-bar as a generic VP adjunct was rejected because it would lose the direct-object relation and allow the wrong complementiser after a selecting verb. Conversely, treating `because` as a lexical object of `leave` would wrongly make an optional event modifier an obligatory verb complement.

### B3: Wh-Clauses And Relative Clauses

**Phenomenon.** B3 implements root object wh-questions with `did`, and restrictive object relative clauses introduced by `which`, `that`, or a zero relativiser. The construction is limited to NP object gaps. A relative is a NOM-level post-modifier, allowing it to combine with a nominal head.

**Phrase markers.** The question and a relative have the following markers:

```text
q(wh(what), aux(did), s(pro(she), vp(v(write))))

s(np(det(the), nom(nom(n(book)),
  rel_clause(rel(which), s(pro(she), vp(v(wrote)))))),
  vp(v(sleeps)))
```

The absent object is represented by selecting the gap-specific transitive VP rule rather than by inserting an unpronounced NP tree node.

**Feature structure.** The wh-pronoun establishes `gap(np)`. The subject of the gap clause has `[CASE nom, AGR Agr]`; the VP has `[AGR Agr, FORM bare]` under `did` or `[FORM fin(_)]` in a relative. `did` has `[FUNCTION do, SELECTED bare]`. The gap value is a constructional feature outside the five baseline records, carried as the third argument of the special gap-clause predicates.

**Key rule.**

```prolog
wh_question(q(Wh,Aux,S)) -->
    wh_pronoun(Wh, np),
    auxiliary(Aux, aux_feat(_, fin(past), do, bare)),
    s_with_gap(S, vp_feat(_, bare), gap(np)).

s_with_gap(s(NP,VP), vp_feat(Agr,Form), Gap) -->
    np(NP, np_feat(Agr, nom)), vp_with_gap(VP, vp_feat(Agr, Form), Gap).

basic_vp_with_gap(vp(V), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, trans)).
```

**Variable sharing and unique discharge.** `Agr` is shared across the gap-clause subject, VP, and lexical verb. The `gap(np)` value selects only `basic_vp_with_gap/2`, whose single transitive-verb rule contains no overt object NP. Thus the object requirement is discharged once at that rule. A normal transitive VP is not available on this path, so `what did she write the letter` cannot fill the gap a second time. Unification names the required gap, but the dedicated grammar path supplies the linearity condition that unification alone cannot provide.

**Minimal pair.** `[what,did,she,write]` is accepted; `[what,did,she,write,the,letter]` is rejected. The latter tries to realise the object both as the wh-gap and as an overt NP. `[what,did,she,wrote]` likewise fails because `did` selects a bare form, not a past finite form.

**Error analysis.** No B3 C1 item is undergenerated or falsely accepted. The grammar intentionally rejects PP extraction and stranding (`what did she rely on`) and long-distance extraction. These require PP-gap representations or gap propagation through S-bars, respectively, neither of which is in scope. The zero relative is safe because it consumes a finite gap clause; it does not recurse without consuming a verb-bearing clause.

**Rejected alternative.** A rule that used an ordinary transitive VP with an optional object would incorrectly license both no discharge and double discharge. It would accept the starred question above. A general optional-gap mechanism was therefore rejected in favour of a distinct gap-bearing transitive rule with exactly one gap position.

### B4: Non-Finite Clauses

**Phenomenon.** B4 implements `to`-infinitival complements with a covert subject, a Type I overt embedded subject, and Type II matrix object control. The sequence `V NP to VP` is structurally ambiguous in ordinary English, but the grammar makes the Type I/Type II distinction lexical: `want` is Type I, while `persuade` is Type II.

**Phrase markers.** The same surface NP has distinct structures:

```text
s(pro(she), vp(v(wants),
  inf_clause(pro(him), to(inf), vp(v(leave)))))

s(pro(she), vp(v(persuaded), pro(him),
  inf_clause(pro, to(inf), vp(v(leave)))))
```

In the first, `him` is the subject of the infinitival clause. In the second, `him` is a direct object of `persuaded`; the infinitival subject is the covert `pro` node. This follows the Chapter 10 constituency contrast: the Type II NP patterns as the matrix verb's object, whereas the Type I NP belongs to the subordinate clause.

**Feature structure.** `wants` has `[SUBCAT infinitive(type_1)]`; `persuaded` has `[SUBCAT infinitive(type_2)]`. Both matrix verbs share `[AGR Agr, FORM Form]` with the matrix VP. The infinitival VP is explicitly `[FORM bare]`; `to` is an infinitival marker distinct from the lexical preposition `to`.

**Key rule.**

```prolog
basic_vp(vp(V,Inf), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, infinitive(type_1))),
    infinitival_clause(Inf, type_1).
basic_vp(vp(V,DO,Inf), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, infinitive(type_2))),
    np(DO, np_feat(_, acc)), infinitival_clause(Inf, type_2).
infinitival_clause(inf_clause(NP,To,VP), type_1) -->
    np(NP, np_feat(_, acc)), infinitival_marker(To), vp(VP, vp_feat(_, bare)).
```

**Variable sharing.** `Agr` forces finite matrix agreement in exactly the same way as other VPs. The `type_1` or `type_2` atom is shared between the lexical subcategorisation value and `infinitival_clause/2`; it selects which phrase-marker configuration can be built. The bare form is passed directly to the embedded VP, so `to left` fails without inspecting the spelling of `left`.

**Minimal pair.** `[she,wants,him,to,leave]` is accepted, while `[she,wants,him,to,left]` is rejected because the marker selects `[FORM bare]`. The Type II negative `[she,persuaded,to,leave]` is rejected because the lexical Type II rule requires a matrix accusative object.

**Error analysis.** The C1 B4 inventory has no residual failures. `[she,wants,for,him,to,leave]` is rejected as a declared boundary case: `for`-infinitives were optional and are not implemented. No claim is made about the grammaticality of that English sentence outside this fragment.

**Rejected alternative.** A single `V + NP + to-VP` rule was rejected because it would assign the same constituent structure to Type I and Type II verbs. It would erase the distinction between an embedded subject and a matrix object. A lexical `infinitive(Type)` subcategorisation value preserves the distinction declaratively.

## Evaluation

### Test Design

`tests_own.pl` contains 40 grammatical and 20 ungrammatical complete sentences. The positive distribution is baseline 6, B1 8, B2 8, B3 10, and B4 8; the negative distribution is baseline 3, B1 4, B2 4, B3 5, and B4 4. Every negative test carries a stated reason. The suite declares eight minimal pairs and four ambiguity items, and includes phrase-marker assertions for every extension.

The minimal pairs isolate perfect participle selection, subject case, noun PP selection, `say` complementiser selection, `ask` complementiser selection, do-support form selection, gap linearity, and infinitival bare-form selection. This tests rejection as well as acceptance, avoiding the misleading result obtained by a grammar that accepts every string.

### Quantitative Results

Measurements were run on Linux 6.18.33.2-microsoft-standard-WSL2 x86_64 with SWI-Prolog 10.0.2.

| Metric | Result |
| --- | --- |
| Coverage | 40/40 = 1.00 |
| Challenge error | 0/20 = 0.00 |
| Mean ambiguity | 1.07 parses per accepted sentence |
| Public acceptance suite | 36/36 passed |
| Project test suite | 16/16 passed |

The challenge-error result is a false-acceptance rate for this finite negative set, not an estimate of all possible English strings. The mean includes known ambiguity items and is therefore not a claim that all accepted sentences have one analysis.

### Generation And Runtime

`harness:sample/2` was used for bounded generation only. It found 3,125 distinct strings at length 3, 78,981 at length 4, and 1,730,607 at length 5. The rapid growth is expected from the finite lexicon, recursive modifiers, and multiple structural analyses; it makes bounded sampling more informative than isolated acceptance checks for detecting ambiguity.

The slowest fixed evaluation item was the rejected `[the,book,which,she,wrote,the,letter,sleeps]`. Across five `rejects/1` runs, its mean was 0.000026464 seconds and its maximum was 0.000065804 seconds. All public and project fixed tests terminated.

### Ambiguity Analysis

| Item | Parses | Classification | Explanation |
| --- | ---: | --- | --- |
| `the letter was written by kim` | 2 | Spurious | The `by` PP is licensed by both passive-VP and generic VP-adjunct rules. |
| `the letter has been written by kim` | 3 | Spurious | The explicit passive path remains, and generic adjunct attachment has two VP levels. |
| `a writer of novels with a beard sleeps` | 2 | Genuine | `with a beard` can attach to writer NOM or embedded `novels` NP. |
| `the student with long hair in the garden sleeps` | 2 | Genuine | `in the garden` can attach to student NOM or embedded `hair` NP. |

The nominal cases are retained because the phrase markers express distinct syntactic attachment structures. The passive cases are a residual rule artefact, not a desired ambiguity.

## Error Analysis

### Spurious Passive `by`-Phrase Ambiguity

The strings `[the,letter,was,written,by,kim]` and `[the,letter,has,been,written,by,kim]` have two and three parses respectively. This is spurious ambiguity, not false acceptance. `vp_passive//1` explicitly permits a `by` PP, while `post_adjuncts//2` permits any PP as a generic adjunct through `adjunct//1`. In the perfect passive, a generic adjunct can attach at another VP level.

The minimal fix depends on the intended constituency analysis: treat passive `by` phrases as complements and prevent generic VP adjuncts from being `by` PPs, or treat them as adjuncts and remove the explicit passive PP rule. The fix was not applied because choosing one needs the required complement-versus-adjunct constituency justification; suppressing a derivation merely to improve the count would hide the analytic decision.

### Missing Past-Tense `read`

`[kim,read,the,letter]` is rejected for the intended past reading. This is undergeneration caused by a lexical gap: the lexicon supplies present, bare, `en`, and `ing` entries for orthographic `read`, but no entry with `[FORM fin(past)]`. The transitive VP rule is not responsible. The minimal fix is a lexical entry mapping `[read]` to `lex_feat(_, fin(past), trans)`. It was not applied because the declared C1 inventory does not require it and the omission is retained as the explicit lexical-coverage diagnostic. It must not be misdiagnosed as a transitivity or case constraint.

### Termination

No non-termination was observed. The grammar contains no left-recursive DCG rules. `post_adjuncts//2` and `nom_post_mods//2` recurse only after consuming an adjunct or PP. S-bar rules consume a complementiser or subordinator before their finite clause; infinitival rules consume `to` before the bare VP. In every recursive case, the remaining input is shorter before the same recursive predicate is called. This is why the accumulator formulation terminates where `vp --> vp, adjunct` or `nominal --> nominal, pp` would re-enter with unchanged input and can diverge under top-down resolution.

## Limitations And Future Work

1. Passive `by` phrases have an unresolved duplicate derivation. A future revision should decide whether they are selected complements or adjuncts using constituency evidence, then retain exactly one licensing route.
2. The lexicon is intentionally small and lacks a past-tense lexical entry for *read*. Lexical paradigms are supplied only where the test inventory requires them.
3. Gap threading covers one local NP object gap only. It cannot derive subject extraction, PP extraction, stranding, pied-piping, multiple gaps, islands, or extraction across S-bars.
4. Root wh-questions are restricted to the `what did NP bare-V` pattern. General auxiliary inversion, negative questions, and other wh-phrases remain outside the grammar.
5. The grammar models two `to`-infinitival patterns only. It omits `for`-infinitives, gerund clauses, raising/control distinctions beyond the declared Type I/II contrast, and agreement or case theory for silent subjects.
6. Full noun phrases are morphologically case-neutral. This matches ordinary English surface morphology but cannot model syntactic case distinctions that have no overt reflex.
7. Semantic selection is not modelled. Consequently, syntactically valid but pragmatically unlikely PP attachments remain available.

## Contribution Statement

The available version history records every commit under the author name `Your Name` on 2026-09-02, including commits labelled B1 through B4, test construction, ambiguity documentation, C2 measurements, and C3 error analysis. It contains no second author identity or cross-review record. The table therefore reports the evidence truthfully rather than inventing a reviewer. Before submission, replace `Not evidenced` with the team member's name only if supported by the dated journal and review evidence required by D3.

| Area | Primary author (version history) | Cross-reviewer | Evidence |
| --- | --- | --- | --- |
| B1 | Your Name | Not evidenced | `54aceef`, “finish part B1” |
| B2 | Your Name | Not evidenced | `61d1def`, “finish part B2” |
| B3 | Your Name | Not evidenced | `50381ca`, “finish part B3” |
| B4 | Your Name | Not evidenced | `f839a65`, “finish part B4” |
| Test suite and minimal pairs | Your Name | Not evidenced | `0afdea6`, `4bdbe11` |
| Integration and public regression testing | Your Name | Not evidenced | baseline and final test runs; repository history |
| Evaluation and ambiguity analysis | Your Name | Not evidenced | `19efdd9`, `19f3c05` |
| Error analysis | Your Name | Not evidenced | `f5d6dba` |
| Report sections | Your Name | Not evidenced | this report; complete with dated D3 journal before submission |

## References

Burton-Roberts, N. (2022). *Analysing Sentences: An Introduction to English Syntax* (5th ed.). Routledge.

SWI-Prolog. (2026). *SWI-Prolog 10.0.2*. https://www.swi-prolog.org/
