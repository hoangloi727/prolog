# 5 Part B: Extensions (Weeks 1-2)

All four extensions are required. The rule fragments in the brief are targets, not solutions: derive the feature threading yourself. Mark extension code in `grammar_core.pl` as `% [B1]` through `% [B4]`.

## 5.1 B1: Internal Structure of NP (Chapter 7)

Implement the three-level `NP - NOM - N` structure, complement PPs as sisters of N versus adjunct PPs as sisters of NOM, predeterminers, and stacked post-modifying PPs.

Required coverage:

- `[a,writer,of,novels]`: PP complement, sister of N.
- `[the,student,with,long,hair]`: PP adjunct, sister of NOM.
- `[all,the,old,books]`: predeterminer.
- Stacked post-modifiers without left recursion.

For `[a,writer,of,novels,with,a,beard]`, draw relevant phrase markers, identify spans predicted to be replaceable by pro-NOM `one`, and add at least two tests distinguishing complement PPs from adjunct PPs. A general substring-enumeration predicate is not required.

Do not use the left-recursive rule `nominal(nom(Nom,PP)) --> nominal(Nom), pp(PP,_)`. Use a `nominal_base` plus `nom_post_mods` accumulator like `basic_vp`/`post_adjuncts`. The complement PP attaches inside the base and adjunct PPs outside it, so the structural distinction remains visible in the tree.

## 5.2 B2: Sentences Within Sentences (Chapter 8)

Implement S-bar with an overt complementiser, `that`-clauses as direct objects, `whether` interrogative clauses, adverbial subordinate clauses, and lexical selection of the complementiser.

Required coverage:

- `[she,said,that,he,left]`: S-bar as direct object.
- `[she,asked,whether,he,left]`: selected complementiser.
- `[she,left,because,he,arrived]`: adverbial clause as sister of VP.
- Reject `[she,said,whether,he,left]` and `[she,asked,that,he,left]`: verbs select their complementiser.

Choose which node a subordinate clause is sister to using constituency evidence; the phrase marker must reflect that decision.

## 5.3 B3: Wh-Clauses and Relative Clauses (Chapter 9)

Implement object wh-questions with an NP gap, a threaded gap feature, and restrictive object relative clauses with `which`, `that`, and zero relativisers. PP gaps, preposition stranding, pied-piping, subject gaps, and island constraints are outside scope.

Required coverage:

- `[what,did,she,write]`: object gap.
- `[the,book,which,she,wrote]`: wh-relative.
- `[the,book,that,she,wrote]` and `[the,book,she,wrote]`: `that` and zero relatives.
- Reject `[what,did,she,write,the,letter]`: the gap must be filled exactly once.

Thread a gap feature through the clause, e.g. `gap(np)` or `nogap`. The gap introduced at the top must be discharged at exactly one site. Unification alone does not guarantee this linearity: zero discharge overgenerates the starred question and two discharges overgenerate more severely. Document how the grammar guarantees unique discharge.

## 5.4 B4: Non-Finite Clauses (Chapter 10)

Implement `to`-infinitive clauses with overt and covert subjects, including the Type I/Type II contrast. `for`-clauses and `-ing` clauses are optional, not required.

Required coverage:

- `[she,wants,to,leave]`: covert subject.
- `[she,wants,him,to,leave]`: Type I, where the NP is subject of the subordinate clause.
- `[she,persuaded,him,to,leave]`: Type II, where the NP is direct object of the matrix verb and the subordinate subject is covert.

Types I and II have the same surface sequence, `V + NP + to-VP`, but require different phrase markers. Make the difference follow from a lexical feature on the verb, not a rule that inspects words. Cite a Chapter 10 constituency diagnostic supporting the analysis.
