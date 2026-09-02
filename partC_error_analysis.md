# Part C3 Error Analysis

The C1 evaluation set has no undergenerated items and no false acceptances: coverage is 40/40 and challenge error is 0/20. The residual issues below were found through ambiguity measurement and the documented A2 diagnostic.

## Residual 1: Passive `by`-Phrase Ambiguity

- **Strings:** `[the,letter,was,written,by,kim]` has 2 parses; `[the,letter,has,been,written,by,kim]` has 3 parses.
- **Failure mode:** spurious ambiguity.
- **Responsible rules:** `vp_passive//1` (`grammar_core.pl:234-236`), `post_adjuncts//2` (`grammar_core.pl:113-116`), and generic PP `adjunct//1` (`grammar_core.pl:118-121`).
- **Cause:** `vp_passive//1` licenses a `by`-PP explicitly, while generic VP post-adjunction licenses the same PP again. Perfect structure provides an additional VP attachment site.
- **Minimal fix:** if the `by`-phrase is a passive complement, retain `vp_passive//1` and exclude `by` from generic VP adjuncts. If it is an adjunct, remove the explicit passive PP alternative.
- **Decision:** not applied. The implementation must follow a constituency-based complement-versus-adjunct analysis; suppressing a rule without that analysis would hide rather than diagnose the error.

## Residual 2: Missing Past-Tense `read`

- **String:** `[kim,read,the,letter]` is rejected for the intended past-tense reading.
- **Failure mode:** undergeneration from a lexical gap.
- **Responsible entries:** `read` is listed only as finite present, bare, `en`, and `ing` in `grammar_core.pl:345-350`; it lacks `lex_feat(_, fin(past), trans)`.
- **Cause:** the past form is orthographically `read`, but it needs a separate lexical entry to unify with `fin(past)`.
- **Minimal fix:** add `lexical_verb(v(read), lex_feat(_, fin(past), trans)) --> [read].`.
- **Decision:** not applied. The declared C1 inventory does not require past `read`; the omission is retained as the explicit A2 lexical-coverage diagnostic. It is not evidence for a transitivity or case constraint.

## Termination

No non-termination was observed. `sample/2` terminated for lengths 3, 4, and 5, producing 3,125, 78,981, and 1,730,607 distinct strings respectively.

The grammar has no left-recursive DCG rules. `post_adjuncts//2` and `nom_post_mods//2` recurse rightward after consuming an adjunct or PP; S-bar rules consume their introducer before the embedded sentence; zero relatives still consume a finite gap clause; and infinitival clauses consume `to` before their bare VP. These properties prevent recursive calls from re-entering with unchanged input.

## Declared Boundary Cases

- `[what,did,she,say,that,he,wrote]` is rejected: long-distance extraction across an S-bar is outside the B3 object-gap scope.
- `[what,did,she,rely,on]` is rejected: PP gaps and preposition stranding are outside the B3 scope.
- `[she,wants,for,him,to,leave]` is rejected: `for`-infinitives are an optional B4 extension and are not implemented.
