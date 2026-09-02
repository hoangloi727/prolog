# 4 Part A: Baseline Consolidation (Week 1)

## 4.1 What You Are Given

`grammar_core.pl` implements selected constructions from Chapters 2-6:

- An `S` rule with subject-verb agreement and nominative case on the subject.
- NP with a determiner and a NOM level with stacked adjectival phrases.
- The six Chapter 4 verb subcategories: `intrans`, `trans`, `ditrans`, `intens`, `complex`, and `prep(PForm)`.
- VP-level adjuncts using an accumulator.
- The auxiliary sequence `mod > perf > prog > pass`, enforced by form selection rather than an ordering list.
- Passive as a parallel rule set, rather than a `voice` feature.

`harness.pl` supplies the Part C measurement apparatus. `tests_public.pl` contains the 36 public `plunit` acceptance tests, which must still pass at the end of the project.

The baseline is not full coverage of Chapters 2-6. Sentence adverbials, phrasal verbs, ellipsis, negation, do-support, and subject-auxiliary inversion are outside the baseline unless a later task explicitly requires them. Do not mistake lexical or constructional gaps for theoretical constraints.

## 4.2 A1: Get It Running and Understand It

Run the public suite from the project root:

```sh
swipl -g "run_tests, halt(0)" -g "halt(1)" tests_public.pl
```

The starter kit is verified with SWI-Prolog 9.0.4 and should report all 36 tests passing.

## 4.3 A2: Diagnose the Seeded Defects

The baseline has documented limitations. Analyse these precisely; undisclosed defect hunting is not required.

1. **Spurious ambiguity in the passive.** The `by`-phrase is licensed both as sister-of-V in `vp_passive` and as a sister-of-VP adjunct through `post_adjuncts`. For example, `n_parses([the,letter,was,written,by,kim], N)` yields `N = 2`; adding perfect aspect yields three parses. Decide whether a `by`-phrase is a complement or adjunct and justify the decision from Chapter 5 constituency evidence, rather than merely patching the symptom.
2. **Case on full NPs.** Full NPs carry an unbound case, so `the letter` is possible in subject and object position, while pronouns are lexically case-specified. Decide whether this is an error or an accurate property of English morphology; do not assume.
3. **Lexical gaps masquerading as grammatical constraints.** `[kim,read,the,letter]` is rejected in a past-tense reading because the irregular past-tense lexical entry is absent: this is a lexical-coverage failure. In contrast, `[kim,considered,lucy]` is rejected because `consider` is complex-transitive and selects an object predicate: this is a subcategorisation constraint. Keep these diagnoses separate.

## 4.4 A3: Extend the Lexicon

- Add 6-8 lexical items of your own, including at least two verbs, one noun selecting a PP, and one preposition.
- For each added verb, supply only the forms required by the declared test suite and state which paradigm cells remain out of scope.
- Required project vocabulary, not counted toward the team additions: `say`, `ask`, `leave`, `arrive`, `want`, `persuade`, `writer`, `novel`, `beard`, `hair`, `all`, `of`, `because`, `that`, `whether`, `what`, `which`, `did`, `to`, and the zero relativiser.
- Add every inflectional form required by the listed constructions. Hidden tests use only this announced vocabulary.
