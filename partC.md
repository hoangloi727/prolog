# 6 Part C: Evaluation and Error Analysis

## 6.1 C1: Build the Test Suite

Deliver `tests_own.pl` containing:

- At least 40 grammatical strings: baseline 6, B1 8, B2 8, B3 10, B4 8.
- At least 20 ungrammatical strings: approximately baseline 3, B1 4, B2 4, B3 5, B4 4. Mark every negative with its reason.
- At least 8 minimal pairs, each differing in exactly one respect and isolating one constraint.
- At least 4 ambiguity items, with expected parse count and a note saying whether each ambiguity is genuine or a spurious rule artefact.

Use book examples where possible and cite chapter and page. Positive-only testing is insufficient because a grammar that accepts every string passes it perfectly.

## 6.2 C2: Measure

Run `evaluate(GoodList, BadList)` from `harness.pl` and report:

```text
Coverage       = |acc(Good)| / |Good|
ChallengeError = |acc(Bad)| / |Bad|
MeanAmbiguity  = sum(n(s) for s in acc(Good)) / |acc(Good)|
```

`ChallengeError` is false acceptance over the submitted finite negative set, not an estimate of overgeneration over all strings.

Also report:

- Bounded generation counts for strings of lengths 3, 4, and 5.
- The wall-clock time of the slowest fixed-test-suite item, measured across five runs on the same stated machine.

Generation counts that grow combinatorially at length 5 expose ambiguity not visible in parse counts. Perfect scores are allowed but do not independently demonstrate test-suite quality; include at least three plausible boundary cases and state why they are outside scope or how the grammar handles them.

## 6.3 C3: Analyse

For every residual failure, record:

- The string.
- Failure mode: undergeneration, false acceptance, non-termination, or spurious ambiguity.
- The responsible rule, identified by name.
- The minimal fix.
- Why the fix was or was not applied.

A correct diagnosis is more important than eliminating every defect. For non-termination, characterise the input class on which the query diverges, identify the recursion that fails to consume input, and show its accumulator reformulation; do not simply remove the rule.
