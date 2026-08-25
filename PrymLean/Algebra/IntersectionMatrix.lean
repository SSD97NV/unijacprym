import Mathlib.Tactic

namespace PrymLean

/-- A finite rational certificate for the two `A_{m-1}` arm corrections in
the Schur-complement computation of the surviving central curve.  The first
conjunct checks the affine-linear arm weights, and the last two identities
give `C_m^2 = -2 / m` and `(m C_m) · C_m = -2`.  This declaration does not
formalize intersection theory on normal surfaces. -/
theorem centralCurve_schurComplement_certificate
    (m : ℕ) (hm : 0 < m) :
    (∀ i : ℕ, 0 < i → i < m →
      (-2 : ℚ) * (i : ℚ) / m + ((i - 1 : ℕ) : ℚ) / m + ((i + 1 : ℕ) : ℚ) / m = 0) ∧
    (((m - 1 : ℕ) : ℚ) / m = ((m : ℚ) - 1) / m) ∧
    ((-2 : ℚ) + 2 * (((m : ℚ) - 1) / m) = -2 / m) ∧
    ((m : ℚ) * (-2 / m) = -2) := by
  have hm0 : (m : ℚ) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt hm)
  constructor
  · intro i hi him
    have hi1 : 1 ≤ i := hi
    rw [Nat.cast_sub hi1]
    norm_num
    ring
  have hm1 : 1 ≤ m := hm
  constructor
  · rw [Nat.cast_sub hm1]
    norm_num
  constructor
  · field_simp [hm0]
    ring
  · field_simp [hm0]

/-- The asymmetric Schur-complement correction for the curve retained by the
blow-up of the rank-one module `I_j` on an `A_{N-1}` surface.  The second
conjunct records the symmetry under `j ↔ N - j`. -/
theorem moduleCurve_schurComplement_certificate
    (N j : ℕ) (hj : 0 < j) (hjN : j < N) :
    ((-2 : ℚ) + ((j : ℚ) - 1) / j +
      (((N - j : ℕ) : ℚ) - 1) / ((N - j : ℕ) : ℚ) =
        -(N : ℚ) / ((j : ℚ) * ((N - j : ℕ) : ℚ))) ∧
    (-(N : ℚ) / ((j : ℚ) * ((N - j : ℕ) : ℚ)) =
      -(N : ℚ) / (((N - j : ℕ) : ℚ) * j)) := by
  have hj0 : (j : ℚ) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt hj)
  have hNj0 : ((N - j : ℕ) : ℚ) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt (Nat.sub_pos_of_lt hjN))
  constructor
  · field_simp [hj0, hNj0]
    rw [Nat.cast_sub (Nat.le_of_lt hjN)]
    ring
  · rw [mul_comm]

end PrymLean
