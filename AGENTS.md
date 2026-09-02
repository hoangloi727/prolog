# Agent Instructions

## Repository

- This is a SWI-Prolog 9.0+ feature-based DCG grammar project; use the standard library only (`plunit`, `lists`, `apply`), with no external parsing toolkit.
- `grammar_core.pl` is the grammar and lexicon; `harness.pl` is the supplied measurement API; `tests_public.pl` is the 36-test acceptance suite.

## Verify

- Run the public suite from the repository root with `swipl -g "run_tests, halt(0)" -g "halt(1)" tests_public.pl`.
- Exercise the harness by loading `harness.pl` and querying `parse/2`, `accepts/1`, `rejects/1`, `parses/2`, `n_parses/2`, `generate/2`, `sample/2`, `evaluate/2`, and `show_tree/1`.
- `generate/2` is deliberately bounded by sentence length; do not use unbounded generation as a termination test.

## Grammar Contract


- Preserve the exported DCG interface in `grammar_core.pl`; mark extension changes with `% [B1]` through `% [B4]` comments.
- Encode features as the specified compound terms (`np_feat/2`, `vp_feat/2`, `lex_feat/3`, `aux_feat/4`, `pp_feat/1`), never feature lists or accessor predicates, never val/3-style accessor.
- Every nonterminal must construct its phrase marker in its first argument; acceptance without a tree is incomplete.
- Thread agreement by sharing the `Agr` variable and enforce selection through unification, not procedural tests or word inspection.
- Keep the grammar pure and terminating: no `assert/1`, `retract/1`, cuts, input preprocessing/reordering, or left-recursive DCG rules. Use accumulator rules for stacked adjuncts/modifiers.
- Preserve the baseline auxiliary order `mod > perf > prog > pass` through form selection; passive remains a parallel rule set, not a `voice` feature.

## Changes And Tests

- Do not modify `harness.pl` or `tests_public.pl`; extend the single `grammar_core.pl` module and preserve its public predicates.
- Keep required vocabulary and all inflectional forms needed by the declared tests; distinguish lexical gaps from grammatical constraints when diagnosing failures.
- Add project tests in `tests_own.pl` with at least 40 grammatical and 20 ungrammatical strings, at least 8 minimal pairs, and at least 4 ambiguity items; mark negative examples with their reason.
- Before considering an extension complete, check positive coverage, rejection of starred negatives, phrase-marker structure, ambiguity, and termination, then rerun the public suite.
