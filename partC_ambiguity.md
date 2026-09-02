# Part C Ambiguity Inventory

Measured with `harness:n_parses/2` against the C1 inventory. Every observed count matches the expected count asserted in `tests_own.pl`.

| Item | String | Expected / observed | Classification | Analysis |
| --- | --- | --- | --- | --- |
| Passive `by` phrase | `[the,letter,was,written,by,kim]` | 2 / 2 | Spurious | `vp_passive//1` licenses `by kim` as the selected passive PP, while `post_adjuncts//2` also licenses it as a generic VP PP adjunct. |
| Perfect passive `by` phrase | `[the,letter,has,been,written,by,kim]` | 3 / 3 | Spurious | The explicit passive PP route remains available, and the generic adjunct route can attach at two VP levels. |
| Writer PP attachment | `[a,writer,of,novels,with,a,beard,sleeps]` | 2 / 2 | Genuine structural ambiguity | `of novels` is fixed as the `writer` complement. The following `with a beard` can attach to the writer NOM or to the embedded `novels` NP. Lexical semantics disfavour the latter reading but the grammar does not encode semantic selection. |
| Nominal PP attachment | `[the,student,with,long,hair,in,the,garden,sleeps]` | 2 / 2 | Genuine structural ambiguity | `in the garden` can modify the student NOM or the embedded `hair` NP; both are licensed by the B1 NOM post-modifier accumulator. |

## Residual Error

The two passive items are one residual error family: duplicate derivational paths for the same `by`-phrase analysis. The responsible rules are `vp_passive//1`, `post_adjuncts//2`, and `adjunct//1`.

The minimal repair depends on the chosen analysis. Treating the passive `by`-phrase as a complement retains the explicit `vp_passive//1` rule and excludes `by` from generic VP adjuncts. Treating it as an adjunct removes the explicit passive PP alternative. The grammar leaves this unresolved pending the required constituency-based analysis; the ambiguity is documented rather than hidden.

The two nominal items are retained as expected attachment ambiguities, not implementation defects.
