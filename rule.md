# 3 The Formal Idiom (Non-Negotiable)

Every rule you write must conform to the idiom of the baseline. This is not a stylistic preference: the grading harness, the public tests and the reference solutions all assume it, and a grammar written in a different idiom cannot be composed with the baseline you were given.

## 3.1 Feature Records Are Compound Terms

Features are carried in Prolog compound terms whose argument positions are fixed by the record's functor:

```prolog
np_feat(Agr, Case)                 % Agr = agr(Person, Num)
vp_feat(Agr, Form)
lex_feat(Agr, Form, Subcat)
aux_feat(Agr, Form, Function, Selected)
pp_feat(PForm)
```

`Form` is one of `fin(pres)`, `fin(past)`, `bare`, `en`, or `ing`; `Case` is one of `nom` or `acc`.

Read a record as an attribute-value matrix in which the attribute is the argument position. Agreement is enforced by a shared Prolog variable and unification alone:

```prolog
sentence(s(NP, VP)) -->
    np(NP, np_feat(Agr, nom)),
    vp(VP, vp_feat(Agr, fin(_))).
```

Feature lists such as `[cat:verb, subcat:trans|_]` are prohibited, as is any `val/3`-style accessor. Constraint satisfaction is pattern matching; if you find yourself writing a predicate that looks up a feature, you have left the idiom.

## 3.2 Every Rule Builds a Phrase Marker

The first argument of every non-terminal is its tree. A rule that recognises without constructing is incomplete, because Chapter 2's claim is precisely that a sentence has a structure, and you cannot evaluate a structural claim you never computed.

## 3.3 Prohibited Constructs

- `assert/1`, `retract/1`: the grammar must be a pure, declarative object.
- Cuts inside grammar rules. Cuts are permitted in the harness and in auxiliary arithmetic predicates only.
- Left recursion such as `vp --> vp, adjunct` or `nominal --> nominal, pp`. Handle post-modification with the accumulator technique already used in the baseline:

```prolog
vp(VP, F) --> basic_vp(Base, F), post_adjuncts(Base, VP).

post_adjuncts(VP, VP) --> [].
post_adjuncts(Acc, VP) --> adjunct(Adj), post_adjuncts(vp(Acc,Adj), VP).
```

- Any transformation of the string before parsing: no pre-processing and no word re-ordering.

### Why Left Recursion Is Fatal Here

A DCG is executed by SWI-Prolog's top-down, depth-first resolution strategy. A rule whose leftmost daughter is its own mother re-enters itself with an unchanged goal and unchanged input list. The derivation does not terminate: in parsing mode only if the string fails, but in generation mode always.

The accumulator formulation licenses the same set of strings, but makes the recursion right-branching, so each recursive call consumes at least one terminal. State this argument in your own words, applied to your own rules, in the report.
