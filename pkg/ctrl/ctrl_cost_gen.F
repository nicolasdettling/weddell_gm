C $Header: /u/gcmpack/MITgcm/pkg/ctrl/ctrl_cost_gen.F,v 1.3 2014/09/19 17:47:58 gforget Exp $
C $Name:  $

c ----------------------------------------------------------------
c --- ctrl_cost_gen2d
c --- ctrl_cost_gen3d
c ----------------------------------------------------------------

c ----------------------------------------------------------------

#include "CTRL_OPTIONS.h"


      subroutine ctrl_cost_gen2d(
     I                       startrec,
     I                       endrec,
     I                       xx_gen_file,
     I                       xx_gen_dummy,
     I                       xx_gen_period,
     I                       xx_gen_wmean,
     I                       xx_gen_weight,
     O                       num_gen_anom,
     O                       num_gen_mean,
     O                       objf_gen_anom,
     O                       objf_gen_mean,
     O                       objf_gen_smoo,
     I                       xx_gen_remo_intercept,
     I                       xx_gen_remo_slope,
     I                       xx_gen_mask,
     I                       myThid
     &                         )

c     ==================================================================
c     SUBROUTINE ctrl_cost_gen2d
c     ==================================================================
c
c     o Generic routine for all 2D control penalty terms
c
c     ==================================================================
c     SUBROUTINE ctrl_cost_gen2d
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"

#ifdef ALLOW_ECCO
#  include "ecco_cost.h"
#endif
#ifdef ALLOW_CTRL
# include "ctrl.h"
# include "optim.h"
#endif

c     == routine arguments ==

      integer startrec
      integer endrec
      character*(MAX_LEN_FNAM) xx_gen_file
      _RL xx_gen_dummy
      _RL xx_gen_period
      _RL xx_gen_wmean
      _RL xx_gen_weight(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL num_gen_anom(nsx,nsy)
      _RL num_gen_mean(nsx,nsy)
      _RL num_gen_smoo(nsx,nsy)
      _RL objf_gen_anom(nsx,nsy)
      _RL objf_gen_mean(nsx,nsy)
      _RL objf_gen_smoo(nsx,nsy)
      _RL xx_gen_remo_intercept
      _RL xx_gen_remo_slope
      _RS xx_gen_mask(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      integer myThid

#ifdef ALLOW_CTRL

c     == local variables ==

      integer bi,bj
      integer i,j,kk
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax
      integer nrec
      integer irec
      integer ilfld

      _RL fctile
      _RL fctilem
      _RL fctilemm
      _RL tmpx
      _RL sumcos
      _RL lengthscale

      _RL xx_mean(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)

      logical doglobalread
      logical ladinit

      character*(80) fnamefld

      character*(MAX_LEN_MBUF) msgbuf

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      jtlo = mybylo(myThid)
      jthi = mybyhi(myThid)
      itlo = mybxlo(myThid)
      ithi = mybxhi(myThid)
      jmin = 1
      jmax = sny
      imin = 1
      imax = snx

      lengthscale = 1. _d 0

c--   Read state record from global file.
      doglobalread = .false.
      ladinit      = .false.

c     Number of records to be used.
      nrec = endrec-startrec+1

      if (optimcycle .ge. 0) then
        ilfld=ilnblnk( xx_gen_file )
        write(fnamefld(1:80),'(2a,i10.10)')
     &       xx_gen_file(1:ilfld),'.',optimcycle
      endif

c--   >>> Loop 1 to compute mean forcing:
      do bj = jtlo,jthi
        do bi = itlo,ithi
          do j = jmin,jmax
            do i = imin,imax
              xx_mean(i,j,bi,bj)   = 0. _d 0
            enddo
          enddo
          num_gen_anom(bi,bj)  = 0. _d 0
          num_gen_mean(bi,bj)  = 0. _d 0
          num_gen_smoo(bi,bj)  = 0. _d 0
          objf_gen_anom(bi,bj) = 0. _d 0
          objf_gen_mean(bi,bj) = 0. _d 0
          objf_gen_smoo(bi,bj) = 0. _d 0
        enddo
      enddo

      IF ( .NOT.ctrlSmoothCorrel2D ) THEN
      do irec = 1,nrec

        call active_read_xy(
     &        fnamefld, tmpfld2d, irec, doglobalread,
     &        ladinit, optimcycle, myThid, xx_gen_dummy )

c--     Loop over this thread tiles.
        do bj = jtlo,jthi
          do bi = itlo,ithi
            do j = jmin,jmax
              do i = imin,imax
                xx_mean(i,j,bi,bj) = xx_mean(i,j,bi,bj)
     &                + tmpfld2d(i,j,bi,bj)
     &                - ( xx_gen_remo_intercept +
     &                    xx_gen_remo_slope*(irec-1)*xx_gen_period )
              enddo
            enddo
          enddo
        enddo

      enddo

      if ( xx_gen_wmean .NE. 0. ) then
       do bj = jtlo,jthi
        do bi = itlo,ithi
c--     Determine the weights to be used.
        kk = 1
        fctilem = 0. _d 0
        do j = jmin,jmax
          do i = imin,imax
            xx_mean(i,j,bi,bj)
     &            = xx_mean(i,j,bi,bj)/float(nrec)
            tmpx = xx_mean(i,j,bi,bj)/xx_gen_wmean
            if (xx_gen_mask(i,j,kk,bi,bj) .ne. 0.) then
#ifdef ALLOW_ECCO
              if ( ABS(R_low(i,j,bi,bj)) .LT. 100. )
     &              tmpx = tmpx*ABS(R_low(i,j,bi,bj))/100.
              fctilem = fctilem + cosphi(i,j,bi,bj)*tmpx*tmpx
              if ( cosphi(i,j,bi,bj) .ne. 0. )
     &             num_gen_mean(bi,bj) = num_gen_mean(bi,bj) + 1. _d 0
#else
              fctilem = fctilem + tmpx*tmpx
                   num_gen_mean(bi,bj) = num_gen_mean(bi,bj) + 1. _d 0
#endif
            endif
          enddo
        enddo
        objf_gen_mean(bi,bj) = objf_gen_mean(bi,bj) + fctilem
        enddo
       enddo
      endif
      ENDIF !IF ( .NOT.ctrlSmoothCorrel2D ) THEN

c--   >>> Loop 2 over records.
      do irec = 1,nrec

        call active_read_xy(
     &        fnamefld, tmpfld2d, irec, doglobalread,
     &        ladinit, optimcycle, myThid, xx_gen_dummy )

c--     Loop over this thread tiles.
        do bj = jtlo,jthi
          do bi = itlo,ithi

c--         Determine the weights to be used.
            kk = 1
            fctile = 0. _d 0
            do j = jmin,jmax
              do i = imin,imax
                if (xx_gen_mask(i,j,kk,bi,bj) .ne. 0.) then
                IF ( .NOT.ctrlSmoothCorrel2D ) THEN
                  tmpx = tmpfld2d(i,j,bi,bj)-xx_mean(i,j,bi,bj)
     &                   - ( xx_gen_remo_intercept +
     &                       xx_gen_remo_slope*(irec-1)*xx_gen_period )
#ifdef ALLOW_ECCO
                  if ( ABS(R_low(i,j,bi,bj)) .LT. 100. )
     &              tmpx = tmpx*ABS(R_low(i,j,bi,bj))/100.
                  fctile = fctile + xx_gen_weight(i,j,bi,bj)*tmpx*tmpx
     &                   * cosphi(i,j,bi,bj)
#else
                  fctile = fctile + xx_gen_weight(i,j,bi,bj)*tmpx*tmpx
#endif
                ELSE !IF ( .NOT.ctrlSmoothCorrel2D ) THEN
                  tmpx = tmpfld2d(i,j,bi,bj)
                  fctile = fctile + tmpx*tmpx
                ENDIF !IF ( .NOT.ctrlSmoothCorrel2D ) THEN
#ifdef ALLOW_ECCO
                  if ( xx_gen_weight(i,j,bi,bj)
     &                *cosphi(i,j,bi,bj) .ne. 0. )
#else
                  if ( xx_gen_weight(i,j,bi,bj) .ne. 0. )
#endif
     &                 num_gen_anom(bi,bj) = num_gen_anom(bi,bj)
     &                 + 1. _d 0
                endif
              enddo
            enddo

            objf_gen_anom(bi,bj) = objf_gen_anom(bi,bj) + fctile

          enddo
        enddo

c--   End of loop over records.
      enddo

      IF ( .NOT.ctrlSmoothCorrel2D ) THEN
#ifdef ALLOW_SMOOTH_BC_COST_CONTRIBUTION

c--   >>> Loop 2 over records.
      do irec = 1,nrec

        call active_read_xy(
     &        fnamefld, tmpfld2d, irec, doglobalread,
     &        ladinit, optimcycle, myThid, xx_gen_dummy )

        _EXCH_XY_RL(tmpfld2d, myThid)

c--     Loop over this thread tiles.
        do bj = jtlo,jthi
          do bi = itlo,ithi

c--         Determine the weights to be used.
            kk = 1
            fctile = 0. _d 0
            do j = jmin,jmax
              do i = imin,imax
                if (xx_gen_mask(i,j,kk,bi,bj) .ne. 0.) then
                  tmpx =
     &                 ( tmpfld2d(i+2,j,bi,bj)-tmpfld2d(i+1,j,bi,bj) )
     &                   *maskW(i+1,j,kk,bi,bj)*maskW(i+2,j,kk,bi,bj)
     &               + ( tmpfld2d(i+1,j,bi,bj)-tmpfld2d(i,j,bi,bj) )
     &                   *maskW(i+1,j,kk,bi,bj)
     &               + ( tmpfld2d(i,j+2,bi,bj)-tmpfld2d(i,j+1,bi,bj) )
     &                   *maskS(i,j+1,kk,bi,bj)*maskS(i,j+2,kk,bi,bj)
     &               + ( tmpfld2d(i,j+1,bi,bj)-tmpfld2d(i,j,bi,bj) )
     &                   *maskS(i,j+1,kk,bi,bj)
#ifdef ALLOW_ECCO
                  if ( ABS(R_low(i,j,bi,bj)) .LT. 100. )
     &              tmpx = tmpx*ABS(R_low(i,j,bi,bj))/100.
                  fctile = fctile
     &               + xx_gen_weight(i,j,bi,bj)*cosphi(i,j,bi,bj)
#else
                  fctile = fctile
     &               + xx_gen_weight(i,j,bi,bj)
#endif
     *                 *0.0161*lengthscale/4.0
     &                 *tmpx*tmpx
#ifdef ALLOW_ECCO
                  if ( xx_gen_weight(i,j,bi,bj)*cosphi(i,j,bi,bj) .ne. 0. )
#else
                  if ( xx_gen_weight(i,j,bi,bj) .ne. 0. )
#endif
     &                 num_gen_smoo(bi,bj) = num_gen_smoo(bi,bj)
     &                 + 1. _d 0
                endif
              enddo
            enddo

            objf_gen_smoo(bi,bj) = objf_gen_smoo(bi,bj) + fctile

          enddo
        enddo

c--   End of loop over records.
      enddo

#endif
      ENDIF !IF ( .NOT.ctrlSmoothCorrel2D ) THEN

#endif

      return
      end

c ----------------------------------------------------------------

      subroutine ctrl_cost_gen3d(
     I                       xx_gen_file,
     I                       xx_gen_dummy,
     I                       xx_gen_weight,
     O                       num_gen,
     O                       objf_gen,
     I                       xx_gen_mask,
     I                       myThid
     &                         )

C     o==========================================================o
C     | subroutine ctrl_cost_gen3d                                    |
C     | o GM coefficient adjustment penalization                 |
C     o==========================================================o

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"

#ifdef ALLOW_ECCO
#  include "ecco_cost.h"
#endif
#ifdef ALLOW_CTRL
# include "ctrl.h"
# include "optim.h"
#endif

c     == routine arguments ==

      character*(MAX_LEN_FNAM) xx_gen_file
      _RL xx_gen_dummy
      _RL xx_gen_weight(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL num_gen(nsx,nsy)
      _RL objf_gen(nsx,nsy)
      _RS xx_gen_mask(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      INTEGER myThid

#ifdef ALLOW_CTRL

c     == local variables ==

      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer jmin,jmax
      integer imin,imax
      integer irec
      integer ilfld

      _RL fcthread
      _RL tmpx

      logical doglobalread
      logical ladinit

      character*(80) fnamefld

      character*(MAX_LEN_MBUF) msgbuf

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      jtlo = mybylo(myThid)
      jthi = mybyhi(myThid)
      itlo = mybxlo(myThid)
      ithi = mybxhi(myThid)
      jmin = 1
      jmax = sny
      imin = 1
      imax = snx

c--   Read state record from global file.
      doglobalread = .false.
      ladinit      = .false.

      irec = 1

      if (optimcycle .ge. 0) then
        ilfld = ilnblnk( xx_gen_file )
        write(fnamefld(1:80),'(2a,i10.10)')
     &       xx_gen_file(1:ilfld),'.',optimcycle
      endif


c--   >>> Loop 1 to compute mean forcing:
      do bj = jtlo,jthi
        do bi = itlo,ithi
          num_gen(bi,bj)  = 0. _d 0
          objf_gen(bi,bj) = 0. _d 0
        enddo
      enddo

      call active_read_xyz( fnamefld, tmpfld3d, irec, doglobalread,
     &                       ladinit, optimcycle, myThid
     &        , xx_gen_dummy )

c--     Loop over this thread tiles.
        do bj = jtlo,jthi
          do bi = itlo,ithi

            num_gen(bi,bj)  = 0. _d 0
            objf_gen(bi,bj) = 0. _d 0

            do k = 1,nr
            do j = jmin,jmax
              do i = imin,imax
                if (xx_gen_mask(i,j,k,bi,bj) .ne. 0.) then
                  tmpx = tmpfld3d(i,j,k,bi,bj)
                IF ( .NOT.ctrlSmoothCorrel3D ) THEN
                  objf_gen(bi,bj) = objf_gen(bi,bj)
     &                 + xx_gen_weight(i,j,k,bi,bj)
     &                 *tmpx*tmpx
                ELSE !IF ( .NOT.ctrlSmoothCorrel3D ) THEN
                  objf_gen(bi,bj) = objf_gen(bi,bj) + tmpx*tmpx
                ENDIF !IF ( .NOT.ctrlSmoothCorrel3D ) THEN
                num_gen(bi,bj) = num_gen(bi,bj) + 1. _d 0
                endif
              enddo
            enddo
            enddo

          enddo
        enddo

#endif

      return
      end
