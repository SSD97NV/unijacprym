import Mathlib.RingTheory.Ideal.Operations
import Mathlib.Tactic

namespace PrymLean

/-- After imposing `(a,b,u^m)`, the contact hypersurface relation is
redundant.  This is a presentation-ideal certificate; it does not construct
the corresponding quotient-ring equivalence or a blow-up. -/
theorem contactDefect_relation_redundant
    (A : Type*) [CommRing A] (a b u : A) (m : ℕ) :
    Ideal.span ({a * b - u ^ (2 * m), a, b, u ^ m} : Set A) =
      Ideal.span ({a, b, u ^ m} : Set A) := by
  apply le_antisymm
  · apply Ideal.span_le.2
    intro x hx
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx
    rcases hx with rfl | rfl | rfl | rfl
    · apply Ideal.sub_mem
      · exact (Ideal.span ({a, b, u ^ m} : Set A)).mul_mem_right b
          (Ideal.subset_span (by simp))
      · rw [show 2 * m = m + m by omega, pow_add]
        exact (Ideal.span ({a, b, u ^ m} : Set A)).mul_mem_right (u ^ m)
          (Ideal.subset_span (by simp))
    · exact Ideal.subset_span (by simp)
    · exact Ideal.subset_span (by simp)
    · exact Ideal.subset_span (by simp)
  · apply Ideal.span_mono
    intro x hx
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx ⊢
    rcases hx with rfl | rfl | rfl <;> simp

/-- If `c ^ 2 = a * b`, then the square of `(a,c)` is `(a) * (a,b,c)`.
This is the ideal identity behind the contact module-blow-up comparison. -/
theorem contactOdd_square_eq_principal_mul_defect
    (A : Type*) [CommRing A] (a b c : A) (hc : c * c = a * b) :
    Ideal.span ({a, c} : Set A) * Ideal.span ({a, c} : Set A) =
      Ideal.span ({a} : Set A) * Ideal.span ({a, b, c} : Set A) := by
  rw [Ideal.span_pair_mul_span_pair]
  rw [Ideal.span_mul_span']
  simp [hc, mul_comm]
  rw [Set.image_insert_eq, Set.image_insert_eq, Set.image_singleton]
  congr 1
  ext x
  simp [or_comm]

/-- The even-power consequence of `I ^ 2 = (a) * D`, stated for arbitrary
ideals in a commutative ring. -/
theorem contactOdd_even_powers
    (A : Type*) [CommRing A] (I D : Ideal A) (a : A)
    (h : I ^ 2 = Ideal.span ({a} : Set A) * D) (n : ℕ) :
    I ^ (2 * n) = Ideal.span ({a ^ n} : Set A) * D ^ n := by
  rw [pow_mul, h, mul_pow, Ideal.span_singleton_pow]

/-- Translating degree to Euler characteristic preserves the plus congruence. -/
theorem eulerCharacteristic_plus_modEq_iff (n d d' g : ℤ) :
    d' + 1 - g ≡ d + 1 - g [ZMOD n] ↔ d' ≡ d [ZMOD n] := by
  rw [Int.modEq_iff_dvd, Int.modEq_iff_dvd]
  ring_nf

/-- For modulus `2g-2`, the minus Euler-characteristic congruence is exactly
the minus degree congruence. -/
theorem eulerCharacteristic_minus_modEq_iff (d d' g : ℤ) :
    d' + 1 - g ≡ -(d + 1 - g) [ZMOD 2 * g - 2] ↔
      d' ≡ -d [ZMOD 2 * g - 2] := by
  rw [Int.modEq_iff_dvd, Int.modEq_iff_dvd]
  ring_nf
  constructor
  all_goals intro h
  case mp =>
    rcases h with ⟨k, hk⟩
    refine ⟨k - 1, ?_⟩
    linear_combination hk
  case mpr =>
    rcases h with ⟨k, hk⟩
    refine ⟨k + 1, ?_⟩
    linear_combination hk

end PrymLean
