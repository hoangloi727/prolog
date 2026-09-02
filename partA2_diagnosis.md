# Part A2: Seeded-Defect Diagnosis

This is a diagnosis of the baseline only. No source files were changed.

## Evidence

The following harness checks were run against the supplied grammar:

```text
n_parses([the,letter,was,written,by,kim], N)       => N = 2
n_parses([the,letter,has,been,written,by,kim], N) => N = 3
accepts([the,letter,sleeps])                       => true
accepts([kim,wrote,the,letter])                    => true
rejects([them,sleep])                              => true
rejects([kim,read,the,letter])                     => true
rejects([kim,considered,lucy])                     => true
```

## 1. Spurious Passive `by`-Phrase Ambiguity

**Failure mode:** spurious ambiguity.

**Responsible rules:** `vp_passive//1` in `grammar_core.pl:128-130`, `vp//2` and `post_adjuncts//2` in `grammar_core.pl:72-75`, and `adjunct//1` in `grammar_core.pl:77-78`.

`vp_passive//1` directly licenses a selected `by`-PP:

```prolog
vp_passive(vp(V,PP)) --> lexical_verb(V, lex_feat(_, en, trans)),
                         pp(PP, pp_feat(by)).
```

However, every VP can also acquire an arbitrary PP through `post_adjuncts//2`, because `adjunct(PP) --> pp(PP, _)` leaves the preposition form unrestricted. Therefore, `[by,kim]` can be analysed both as the passive VP's explicit PP and as a VP adjunct. In a perfect passive, the same adjunct can additionally attach outside the perfect VP, producing three derivations.

**Minimal repair, if the `by`-phrase is analysed as a passive complement:** retain the explicit passive PP rule and prevent generic VP adjuncts from using `by`.

**Alternative repair, if it is analysed as an adjunct:** remove the explicit `vp_passive(vp(V,PP))` alternative and license the phrase only through the adjunct mechanism.

The defect is not acceptance of the string but multiple incompatible structures for the same intended analysis. The chosen repair must follow the project's constituency argument about whether passive `by`-phrases are complements or adjuncts.

## 2. Case on Full NPs

**Status:** intended morphological underspecification, not an agreement/case bug in the baseline.

**Responsible rules:** the full-NP rules in `grammar_core.pl:48-51`; the subject and object requirements in `grammar_core.pl:38-40`, `85-105`; and lexical pronouns in `grammar_core.pl:144-151`.

Proper names and determiner-nominal NPs use an unbound case argument:

```prolog
np(np(PN), np_feat(agr(3,Num), _Case)) --> proper_name(PN, Num).
np(np(Det,Nom), np_feat(agr(3,Num), _Case)) -->
    determiner(Det, Num),
    nominal(Nom, Num).
```

They can unify with `nom` as sentence subjects and `acc` as objects. This is appropriate for ordinary English full NPs, whose overt form normally does not distinguish nominative from accusative. Pronouns are different: their lexical entries specify `nom` or `acc`, so `them` cannot occupy the subject position.

The grammar does not represent abstract syntactic case independently of morphology for full NPs. That is a deliberate simplification and a limitation only if later phenomena require case distinctions that are not morphologically visible.

## 3. Lexical Gaps Versus Grammatical Constraints

### `[kim,read,the,letter]`

**Failure mode:** undergeneration caused by a lexical-coverage gap.

**Responsible entries:** the `read` entries at `grammar_core.pl:208-213`.

The lexicon has present-tense `read`, bare `read`, participial `read`, and progressive `reading`, but no `lex_feat(_, fin(past), trans)` entry. The intended past form is orthographically identical to the present/bare form, but it still needs a separate lexical entry with `fin(past)`. The grammar's transitive VP rule is not at fault.

### `[kim,considered,lucy]`

**Status:** correct rejection under the stated lexicon.

**Responsible rules:** the complex-transitive VP rule at `grammar_core.pl:98-101` and `consider` entries at `grammar_core.pl:241-247`.

`consider` is declared `complex`, so it must combine with an accusative object NP and a following predicative complement:

```prolog
basic_vp(vp(V,DO,OP), vp_feat(Agr,Form)) -->
    lexical_verb(V, lex_feat(Agr, Form, complex)),
    np(DO, np_feat(_, acc)),
    predicative(OP).
```

The sentence supplies the object `lucy` but no object predicative such as an AP or NP. Its rejection therefore demonstrates a subcategorisation constraint, not a missing inflectional form.
