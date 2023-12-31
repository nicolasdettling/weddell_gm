#include "RW_OPTIONS.h"

C--  File read_write_rec.F: Routines to handle mid-level I/O interface.
C--   Contents
C--   o SET_WRITE_GLOBAL_REC
C--   o SET_WRITE_GLOBAL_SEC
C--   o WRITE_REC_XY_RS
C--   o WRITE_REC_XY_RL
C--   o WRITE_REC_XYZ_RS
C--   o WRITE_REC_XYZ_RL
C--   o WRITE_REC_3D_RS
C--   o WRITE_REC_3D_RL
C--   o WRITE_REC_LEV_RS
C--   o WRITE_REC_LEV_RL
C--   o WRITE_REC_XZ_RS
C--   o WRITE_REC_XZ_RL
C--   o WRITE_REC_YZ_RS
C--   o WRITE_REC_YZ_RL

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: SET_WRITE_GLOBAL_REC
C     !INTERFACE:
      SUBROUTINE SET_WRITE_GLOBAL_REC ( flag )
      IMPLICIT NONE

C     !DESCRIPTION: \bv
C SET_WRITE_GLOBAL_REC( flag ) sets an internal logical state to
C indicate whether Record files written by subsequent call to the
C READ-WRITE package should create "global" or "tiled" files.
C   flag = .TRUE.  indicates "global" files
C   flag = .FALSE. indicates "tiled" files
C     \ev

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      LOGICAL flag
C     !USES:
C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile
CEOP

      globalFile=flag

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: SET_WRITE_GLOBAL_SEC
C     !INTERFACE:
      SUBROUTINE SET_WRITE_GLOBAL_SEC ( flag )
      IMPLICIT NONE

C     !DESCRIPTION: \bv
C SET_WRITE_GLOBAL_SEC( flag ) sets an internal logical state to
C indicate whether files containing vertical Sections written by subsequent
C call to the READ-WRITE package should create "global" or "tiled" files.
C   flag = .TRUE.  indicates "global" files
C   flag = .FALSE. indicates "tiled" files
C     \ev

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      LOGICAL flag
C     !USES:
C Common
      COMMON /RD_WR_SEC/ globalFile
      LOGICAL globalFile
CEOP

      globalFile=flag

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XY_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XY_RS( fName,field,iRec,myIter,myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XY_RS is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      _RS field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
      INTEGER nNz
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
      nNz=1
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, writeBinaryPrec,
     I                      globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, dummyRL, field,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XY_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XY_RL( fName,field,iRec,myIter,myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XY_RL is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      _RL field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
      INTEGER nNz
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
      nNz=1
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, writeBinaryPrec,
     I                      globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, field, dummyRS,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XYZ_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XYZ_RS( fName,field,iRec,myIter,myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XYZ_RS is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      _RS field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
      INTEGER nNz
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
      nNz=Nr
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, writeBinaryPrec,
     I                      globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, dummyRL, field,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XYZ_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XYZ_RL( fName,field,iRec,myIter,myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XYZ_RL is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      _RL field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
      INTEGER nNz
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
      nNz=Nr
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, writeBinaryPrec,
     I                      globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, field, dummyRS,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_3D_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_3D_RS(
     I                            fName, fPrec, nNz, field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_3D_RS is a "front-end" interface to the low-level I/O routines.
C  write a full 3D field (nNz levels) to record number "iRec"
C   in binary file "fName" (precision "fPrec", generally =32 or 64).
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RS field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, fPrec, globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, dummyRL, field,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_3D_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_3D_RL(
     I                            fName, fPrec, nNz, field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_3D_RL is a "front-end" interface to the low-level I/O routines.
C  write a full 3D field (nNz levels) to record number "iRec"
C   in binary file "fName" (precision "fPrec", generally =32 or 64).
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RL field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, fPrec, globalFile, useCurrentDir,
     I                      fType, nNz, 1, nNz, field, dummyRS,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_LEV_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_LEV_RS(
     I                            fName, fPrec, kSiz, kLo, kHi, field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_LEV_RS is a "front-end" interface to the low-level I/O routines.
C  Write a set a consecutive levels (from kLo to kHi) from 3D array (size: kSiz)
C  to record number "iRec" in binary file "fName" (precision "fPrec",
C  generally =32 or 64).
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER kSiz, kLo, kHi
      _RS field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,kSiz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, fPrec, globalFile, useCurrentDir,
     I                      fType, kSiz, kLo, kHi, dummyRL, field,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_LEV_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_LEV_RL(
     I                            fName, fPrec, kSiz, kLo, kHi, field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_LEV_RL is a "front-end" interface to the low-level I/O routines.
C  Write a set a consecutive levels (from kLo to kHi) from 3D array (size: kSiz)
C  to record number "iRec" in binary file "fName" (precision "fPrec",
C  generally =32 or 64).
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER kSiz, kLo, kHi
      _RL field(1-OLx:sNx+OLx,1-OLy:sNy+OLy,kSiz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_REC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_FIELD(
     I                      fName, fPrec, globalFile, useCurrentDir,
     I                      fType, kSiz, kLo, kHi, field, dummyRS,
     I                      iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XZ_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XZ_RS(
     I                            fName, fPrec, nNz,
     I                            field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XZ_RS is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RS field(1-OLx:sNx+OLx,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_SEC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_SEC_XZ(
     I                       fName, fPrec, globalFile, useCurrentDir,
     I                       fType, nNz, 1, nNz,
     I                       dummyRL, field,
     I                       iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_XZ_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_XZ_RL(
     I                            fName, fPrec, nNz,
     I                            field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_XZ_RL is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RL field(1-OLx:sNx+OLx,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_SEC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_SEC_XZ(
     I                       fName, fPrec, globalFile, useCurrentDir,
     I                       fType, nNz, 1, nNz,
     I                       field, dummyRS,
     I                       iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_YZ_RS
C     !INTERFACE:
      SUBROUTINE WRITE_REC_YZ_RS(
     I                           fName, fPrec, nNz,
     I                           field,
     I                           iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_YZ_RS is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RS field(1-OLy:sNy+OLy,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_SEC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_SEC_YZ(
     I                       fName, fPrec, globalFile, useCurrentDir,
     I                       fType, nNz, 1, nNz,
     I                       dummyRL, field,
     I                       iRec, myIter, myThid )
#endif
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_REC_YZ_RL
C     !INTERFACE:
      SUBROUTINE WRITE_REC_YZ_RL(
     I                            fName, fPrec, nNz,
     I                            field,
     I                            iRec, myIter, myThid )

C     !DESCRIPTION: \bv
C WRITE_REC_YZ_RL is a "front-end" interface to the low-level I/O
C routines.
C     \ev

C     !USES:
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C Arguments
      CHARACTER*(*) fName
      INTEGER fPrec
      INTEGER nNz
      _RL field(1-OLy:sNy+OLy,nNz,nSx,nSy)
      INTEGER iRec
      INTEGER myIter
      INTEGER myThid

C Functions
c     INTEGER ILNBLNK

C Common
      COMMON /RD_WR_SEC/ globalFile
      LOGICAL globalFile

C     !LOCAL VARIABLES:
C Local
      LOGICAL useCurrentDir
      _RS dummyRS(1)
      CHARACTER*(2) fType
c     INTEGER IL
c     CHARACTER*(MAX_LEN_FNAM) fullName
CEOP

c     IF (myIter.GE.0) THEN
c      IL=ILNBLNK( fName )
c      WRITE(fullName,'(2a,i10.10)') fName(1:IL),'.',myIter
c     ELSE
c      fullName=fName
c     ENDIF

      useCurrentDir = .FALSE.
      fType='RL'
#ifdef ALLOW_MDSIO
      CALL MDS_WRITE_SEC_YZ(
     I                       fName, fPrec, globalFile, useCurrentDir,
     I                       fType, nNz, 1, nNz,
     I                       field, dummyRS,
     I                       iRec, myIter, myThid )
#endif
      RETURN
      END
