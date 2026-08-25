# unijacprym

This repository contains the bounded computational certificates for the explicit algebraic calculations used in the local part of the thesis *Canonical Rings of Compactified Universal Jacobians and Local Prym Boundary Geometry*.

## Contents

The four Lean modules verify:

- the universal-node matrix factorization and first Fitting ideal;
- the contact-defect relation, the identity $I_m^2=a\mathfrak d_m$, and the even powers of $I_m$;
- the two Euler-characteristic congruences;
- the Schur-complement calculations for the central and general retained curves.

The Singular script verifies the saturation and elimination calculations on the contact--Fitting blow-up charts for contact orders 1 through 6.

## Software

- Lean 4.32.2, pinned by `lean-toolchain`;
- Mathlib 4.32.2, with the exact dependency graph recorded in `lake-manifest.json`;
- Singular 4.4.1.

## Verification

After installing Lean through Elan and Singular, run:

```sh
lake update
lake exe cache get
./verify.sh
```

Equivalently, the individual checks are:

```sh
lake build
lake env lean verification/AxiomScan.lean
Singular singular/contact_fitting_blowup_checks.sing
```

The expected Lean axiom output is recorded in `verification/AXIOM_REPORT.txt`.

## Scope

These files verify the displayed matrix, ideal, congruence, Rees-power, intersection, saturation, and elimination identities. They do not constitute a formal proof of stack algebraicity, good-moduli-space descent, scheme-theoretic images, algebraization, or the complete geometric main theorems.
