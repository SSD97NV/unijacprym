# unijacprym v1.0.0

This release freezes the bounded computational supplement to Junming Gao's
master's thesis *Canonical Rings of Compactified Universal Jacobians and a
Contact–Fitting Modification at a Genus-13 Prym-Torsor Boundary*.

The release contains four Lean modules and one Singular script. Together they
check the explicit matrix, presentation-ideal, contact-ideal, congruence,
power, and intersection identities listed in `THESIS_MAP.md`. The Singular
certificate evaluates the displayed contact formulas for
$1\leq m\leq 6$; the theorem for arbitrary contact order remains a
mathematical proof in the thesis.

The release does not formalize the geometric main theorems. In particular, it
does not prove stack algebraicity, good-moduli-space existence, fixed-stack
descent, algebraization, component incidence, scalar-gerbe descent, or the
canonical-ring results.

## Verification

From a checkout of tag `v1.0.0`, run:

```sh
lake exe cache get
sh verify.sh
git diff --exit-code
shasum -a 256 -c MANIFEST.sha256
```

The release assets are:

- `MANIFEST.sha256` — checksums for the curated source and report files;
- `AXIOM_REPORT.txt` — the Lean axiom report for the nine thesis-facing
  declarations;
- `SINGULAR_REPORT.txt` — the deterministic Singular 4.4.1 report.

The source-to-thesis concordance and the limitations of each certificate are
recorded in `THESIS_MAP.md`.
