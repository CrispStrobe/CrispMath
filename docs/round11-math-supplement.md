# Round 11: two independently referenced supplemental questions

The original fifty references remain frozen at `7a758f5`. Later static semantic
review identified two algebra questions already covered by an earlier audit:
reversing the factors of a principal-root product, and spelling `ln(-I)` as
`log(-I)`. They remain useful parser checks and are not removed or reinterpreted.
These two further questions give fifty new mathematical stimuli alongside those
two repeated checks. Their references are frozen separately before observing
their application outputs. The complete audit therefore contains 52 questions,
and the accumulated runtime corpus grows from 737 to 789.

| ID | Independent problem | Reference and derivation |
| --- | --- | --- |
| round11-supplement-01 | `sqrt(-25)*sqrt(-49)` with principal complex roots | `-35`. The roots are `5I` and `7I`; their product is `35I²=-35`. Multiplying the radicands before taking a square root would incorrectly give positive 35. |
| round11-supplement-02 | `ln(-2*I)` on the principal branch | `ln(2)-I*pi/2`. Modulus is two and principal argument is `-pi/2`. Both the nonzero real logarithmic magnitude and imaginary phase must be checked. |

Only static stimulus normalization and mathematical derivation precede this
freeze. The original 25+25 CLI reports and any initial failures remain intact;
the two supplemental questions receive their own two-case reports.
