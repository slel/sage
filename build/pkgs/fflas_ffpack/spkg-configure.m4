SAGE_SPKG_CONFIGURE([fflas_ffpack], [
  # fflas-lapack uses whatever multi-precision library givaro uses,
  # either gmp or mpir.
  SAGE_SPKG_DEPCHECK([atlas givaro gmp mpir openblas], [
    # If our dependencies come from the system, then we can use
    # the system fflas-ffpack, too. Use pkg-config to find a
    # recentish version, if there is one.
    PKG_CHECK_MODULES([FFLAS_FFPACK],
                      [fflas-ffpack >= 2.3.2],
                      [sage_spkg_install_fflas_ffpack=no],
                      [sage_spkg_install_fflas_ffpack=yes])
  ],
  [ # Some of its dependencies are installed as SPKGs, so install the
    # fflas-ffpack SPKG as well.
    sage_spkg_install_fflas_ffpack=yes
  ])

  # Warning: this doesn't get executed with --without-system-fflas-ffpack
  AS_IF([test "x$sage_spkg_install_fflas_ffpack" = "xyes"],[
    dnl https://github.com/linbox-team/fflas-ffpack/blob/master/macros/instr_set.m4
    dnl discovers these flags from the processor but fails to check whether
    dnl compiler (and assembler) actually support these instruction sets.

    AX_CHECK_COMPILE_FLAG([-mavx512f -mavx512vl -mavx512dq], [], [
      AS_VAR_APPEND([SAGE_CONFIGURE_FFLAS_FFPACK], [" --disable-avx512f --disable-avx512vl --disable-avx512dq"])
    ])
    m4_foreach([ISFLAG], [fma, fma4], [
      AX_CHECK_COMPILE_FLAG([-m]ISFLAG, [], [AS_VAR_APPEND]([SAGE_CONFIGURE_FFLAS_FFPACK], [" --disable-]ISFLAG[ "]))
    ])
    AC_SUBST([SAGE_CONFIGURE_FFLAS_FFPACK])
  ])
])
