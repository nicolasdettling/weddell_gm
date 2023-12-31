#include "CPP_OPTIONS.h"
#include "STREAMICE_OPTIONS.h"

      SUBROUTINE STREAMICE_INVERT_SURF_FORTHICK (
     O            H,
     I            S,
     I            R,
     I            delta,
     I            myThid)

c      This S/R finds a thickness (H) that gives surf elev S with bed R

#include "SIZE.h"
#include "GRID.h"
#include "SET_GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "STREAMICE.h"

#ifdef ALLOW_OPENAD
      use OAD_tape
      use OAD_rev
      use OAD_cp
#endif

      _RL H(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL S(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL R(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DELTA
      INTEGER myThid
#ifdef ALLOW_OPENAD
      type(active) :: ETA_GL_STREAMICE
      type(active) :: X,Y0
      type(modeType) :: our_orig_mode
#endif

#ifdef ALLOW_STREAMICE

      _RL resid, fp, hf, htmp
      INTEGER  i, j, bi, bj, ITER
      _RL ETA_GL_PRIME_STREAMICE
#ifndef ALLOW_OPENAD
      _RL ETA_GL_STREAMICE
      EXTERNAL ETA_GL_STREAMICE
#endif
c      EXTERNAL PHI_GL_STREAMICE_PRIME

        DO bj=myByLo(myThid), myByHi(myThid)
         DO bi=myBxLo(myThid), myBxHi(myThid)
          DO j = 1,sNy
           DO i = 1,sNx
            IF (STREAMICE_hmask(i,j,bi,bj).eq.1.0) THEN
             hf = (-1. _d 0) * R(i,j,bi,bj) /
     &           (1. _d 0 - delta)

             IF (S(i,j,bi,bj) .gt. delta*HF) THEN
              htmp = S(i,j,bi,bj)-R(i,j,bi,bj)
             ELSE
              htmp = S(i,j,bi,bj)/delta
             ENDIF

             IF (streamice_smooth_gl_width.gt.0.) THEN

              RESID=1. _d 0

              DO ITER=1,20
               IF ((RESID .gt. .005) .and.
     &           ( STREAMICE_hmask(i,j,bi,bj).eq.1.0)) THEN

                hf = (-1. _d 0) * R(i,j,bi,bj) /
     &           (1. _d 0 - delta)

                IF (S(i,j,bi,bj) .gt. delta*HF) THEN
                 htmp = S(i,j,bi,bj)-R(i,j,bi,bj)
                ELSE
                 htmp = S(i,j,bi,bj)/delta
                ENDIF

#ifdef ALLOW_OPENAD

                our_orig_mode = our_rev_mode
                our_rev_mode%arg_store=.FALSE.
                our_rev_mode%arg_restore=.FALSE.
                our_rev_mode%plain=.TRUE.
                our_rev_mode%tape=.FALSE.
                our_rev_mode%adjoint=.FALSE.

                X%v = htmp-HF
                Y0%v = delta*HF

                CALL OpenAD_oad_s_eta_gl_streamice(
     &             X,
     &             delta,
     &             1. _d 0,
     &             Y0,
     &             streamice_smooth_gl_width,
     &             ETA_GL_STREAMICE)

                RESID = ETA_GL_STREAMICE%v
                our_rev_mode = our_orig_mode

#else
                RESID = ETA_GL_STREAMICE (
     &             htmp-HF,
     &             delta,
     &             1. _d 0,
     &             delta*HF,
     &             streamice_smooth_gl_width)
#endif
                RESID = RESID - S(i,j,bi,bj)
                FP = ETA_GL_PRIME_STREAMICE (
     &             htmp-HF,
     &             delta,
     &             1. _d 0,
     &             delta*HF,
     &             streamice_smooth_gl_width)
                Htmp = HTMP-RESID/FP
               ENDIF
              ENDDO
             ENDIF
             H(i,j,bi,bj) = Htmp
            ENDIF
           ENDDO
          ENDDO
         ENDDO
        ENDDO

#endif
      RETURN
      END
