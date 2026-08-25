import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic

namespace PrymLean

/-- The universal-node matrices factor the equation `ξ * η - p * q` over any
commutative coefficient ring. -/
theorem universalNode_matrixFactorization
    (A : Type*) [CommRing A] (ξ η p q : A) :
    let Φ : Matrix (Fin 2) (Fin 2) A := !![η, q; p, ξ]
    let Ψ : Matrix (Fin 2) (Fin 2) A := !![ξ, -q; -p, η]
    Φ * Ψ = (ξ * η - p * q) • (1 : Matrix (Fin 2) (Fin 2) A) ∧
      Ψ * Φ = (ξ * η - p * q) • (1 : Matrix (Fin 2) (Fin 2) A) := by
  dsimp
  constructor <;> ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply] <;> ring

end PrymLean
