# module for fast macro_atom calculations

# cython: profile=False
# cython: boundscheck=False
# cython: cdivision=True
# cython: wraparound=False

import numpy as np
cimport numpy as np

ctypedef np.int64_t int_type_t

from astropy.constants import cgs

cdef extern from "math.h":
    double exp(double)


cdef float h_cgs = cgs.h.value
cdef float c = cgs.c.value
cdef float inv_c2 = 1/(c**2)



# DEPRECATED doing with numpy seems to be faster.
def intensity_black_body(np.ndarray[double, ndim=1] nus, double beta_rad, np.ndarray[double, ndim=1] j_nus):
    cdef c1 = h_cgs * inv_c2
    cdef float j_nu, nu

    for i in range(len(nus)):
        nu = nus[i]

        j_nus[i] = (c1 * nu**3) / (exp(h_cgs * nu * beta_rad) - 1)




def calculate_beta_sobolev(np.ndarray[double, ndim=1] tau_sobolevs, np.ndarray[double, ndim=1] beta_sobolevs):
    cdef double beta_sobolev
    cdef double tau_sobolev
    cdef int i

    for i in range(len(tau_sobolevs)):
        tau_sobolev = tau_sobolevs[i]

        if tau_sobolev > 1e3:
            beta_sobolev = 1 / tau_sobolev
        elif tau_sobolev < 1e-4:
            beta_sobolev = 1 - 0.5 * tau_sobolev
        else:
            beta_sobolev = (1 - exp(-tau_sobolev)) / tau_sobolev
        beta_sobolevs[i] = beta_sobolev


def normalize_transition_probabilities(np.ndarray[double, ndim=1] p_transition,
                                       np.ndarray[int_type_t, ndim=1] reference_levels):
    cdef int i, j
    cdef double norm_factor = 0.0
    cdef int start_id = 0
    cdef  end_id = 0
    for i in range(len(reference_levels)-1):
        norm_factor = 0.0
        for j in range(reference_levels[i], reference_levels[i+1]):
            norm_factor += p_transition[j]
        if norm_factor == 0.0:
            continue
        for j in range(reference_levels[i], reference_levels[i+1]):
            p_transition[j] /= norm_factor
