#!/bin/sh
set -eu

lake build
lake env lean verification/AxiomScan.lean
Singular singular/contact_fitting_blowup_checks.sing
