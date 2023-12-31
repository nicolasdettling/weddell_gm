#include "AUTODIFF_OPTIONS.h"

C     ==================================================================
C     active_file_gen_g.F: Routines to handle the I/O of the active file
C                          for the tangent linear calculations.
C     Routines
C    o  g_ACTIVE_READ_GEN_RL    - Read  an active RL variable from file.
C    o  g_ACTIVE_READ_GEN_RS    - Read  an active RS variable from file.
C
C    o  g_ACTIVE_WRITE_GEN_RL   - Write an active RL variable to a file.
C    o  g_ACTIVE_WRITE_GEN_RS   - Write an active RS variable to a file.
C
C     Generic version for each array type (_RL or _RS).
C     Note: the _RL version can replace the 4 x 2 shape-specific
C           (_xy,_xyz,_xz,_yz) and standard or "_loc" routines.
C     ==================================================================

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: g_ACTIVE_READ_GEN_RL
C     !INTERFACE:
      SUBROUTINE g_ACTIVE_READ_GEN_RL(
     I                               activeVar_file,
     O                               active_var,
     O                               g_active_var,
     I                               arrShape, myNr,
     I                               iRec,
     I                               globalFile,
     I                               useCurrentDir,
     I                               lAdInit,
     I                               myOptimIter,
     I                               myThid,
     I                               dummy, g_dummy )

C     !DESCRIPTION: \bv
C     ==================================================================
C     SUBROUTINE g_ACTIVE_READ_GEN_RL
C     ==================================================================
C     o Read an active (_RL) variable from file (generic version).
C     Accept active variable of various (XY,XZ,YZ) shape and level
C     number, according to arguments arrShape and myNr.
C     ==================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     activeVar_file :: filename
C     active_var     :: active variable array
C     arrShape       :: shape of active-var array ('XY','XZ' or 'YZ')
C     myNr           :: number of vertical-levels in active-var array
C     iRec           :: record number in file
C     globalFile     :: used for writing global (if =T) or tiled files
C     useCurrentDir  :: always read from the current directory
C                        (even if "mdsioLocalDir" is set)
C     lAdInit        :: initialisation of corresponding adjoint variable
C                        and write to active file
C     myOptimIter    :: number of optimization iteration (default: 0)
C     myThid         :: my Thread Id number
C     dummy          :: (needed for 2nd derivative code)
      CHARACTER*(*) activeVar_file
      _RL     active_var(*)
      _RL     g_active_var(*)
      CHARACTER*(2) arrShape
      INTEGER myNr
      INTEGER iRec
      LOGICAL globalFile
      LOGICAL useCurrentDir
      LOGICAL lAdInit
      INTEGER myOptimIter
      INTEGER myThid
      _RL     dummy, g_dummy

C     !LOCAL VARIABLES:
      CHARACTER*(2)  pref
      CHARACTER*(MAX_LEN_FNAM) fName
CEOP

      pref = 'g_'
      CALL ADD_PREFIX( pref, activeVar_file, fName )

      IF ( arrShape.EQ.'XY' ) THEN

        CALL ACTIVE_READ_3D_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_3D_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'XZ' ) THEN

        CALL ACTIVE_READ_XZ_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_XZ_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'YZ' ) THEN

        CALL ACTIVE_READ_YZ_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_YZ_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSE
        STOP
     &   'ABNORMAL END: S/R g_ACTIVE_READ_GEN_RL: invalid arrShape'
      ENDIF

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: g_ACTIVE_READ_GEN_RS
C     !INTERFACE:
      SUBROUTINE g_ACTIVE_READ_GEN_RS(
     I                               activeVar_file,
     O                               active_var,
     O                               g_active_var,
     I                               arrShape, myNr,
     I                               iRec,
     I                               globalFile,
     I                               useCurrentDir,
     I                               lAdInit,
     I                               myOptimIter,
     I                               myThid,
     I                               dummy, g_dummy )

C     !DESCRIPTION: \bv
C     ==================================================================
C     SUBROUTINE g_ACTIVE_READ_GEN_RS
C     ==================================================================
C     o Read an active (_RS) variable from file (generic version).
C     Accept active variable of various (XY,XZ,YZ) shape and level
C     number, according to arguments arrShape and myNr.
C     ==================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     activeVar_file :: filename
C     active_var     :: active variable array
C     arrShape       :: shape of active-var array ('XY','XZ' or 'YZ')
C     myNr           :: number of vertical-levels in active-var array
C     iRec           :: record number in file
C     globalFile     :: used for writing global (if =T) or tiled files
C     useCurrentDir  :: always read from the current directory
C                        (even if "mdsioLocalDir" is set)
C     lAdInit        :: initialisation of corresponding adjoint variable
C                        and write to active file
C     myOptimIter    :: number of optimization iteration (default: 0)
C     myThid         :: my Thread Id number
C     dummy          :: (needed for 2nd derivative code)
      CHARACTER*(*) activeVar_file
      _RS     active_var(*)
      _RS     g_active_var(*)
      CHARACTER*(2) arrShape
      INTEGER myNr
      INTEGER iRec
      LOGICAL globalFile
      LOGICAL useCurrentDir
      LOGICAL lAdInit
      INTEGER myOptimIter
      INTEGER myThid
      _RS     dummy, g_dummy

C     !LOCAL VARIABLES:
      CHARACTER*(2)  pref
      CHARACTER*(MAX_LEN_FNAM) fName
CEOP

      pref = 'g_'
      CALL ADD_PREFIX( pref, activeVar_file, fName )

      IF ( arrShape.EQ.'XY' ) THEN

        CALL ACTIVE_READ_3D_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_3D_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'XZ' ) THEN

        CALL ACTIVE_READ_XZ_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_XZ_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'YZ' ) THEN

        CALL ACTIVE_READ_YZ_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_READ_YZ_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, lAdInit, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSE
        STOP
     &   'ABNORMAL END: S/R g_ACTIVE_READ_GEN_RS: invalid arrShape'
      ENDIF

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: g_ACTIVE_WRITE_GEN_RL
C     !INTERFACE:
      SUBROUTINE g_ACTIVE_WRITE_GEN_RL(
     I                               activeVar_file,
     I                               active_var,
     I                               g_active_var,
     I                               arrShape, myNr,
     I                               iRec,
     I                               useCurrentDir,
     I                               myOptimIter,
     I                               myThid,
     I                               dummy, g_dummy )

C     !DESCRIPTION: \bv
C     ==================================================================
C     SUBROUTINE g_ACTIVE_WRITE_GEN_RL
C     ==================================================================
C     o Write an active (_RL) variable from file (generic version).
C     Accept active variable of various (XY,XZ,YZ) shape and level
C     number, according to arguments arrShape and myNr.
C     ==================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     activeVar_file :: filename
C     active_var     :: active variable array
C     arrShape       :: shape of active-var array ('XY','XZ' or 'YZ')
C     myNr           :: number of vertical-levels in active-var array
C     iRec           :: record number in file
C     useCurrentDir  :: always write to the current directory
C                        (even if "mdsioLocalDir" is set)
C     myOptimIter    :: number of optimization iteration (default: 0)
C     myThid         :: my Thread Id number
C     dummy          :: (needed for 2nd derivative code)
      CHARACTER*(*) activeVar_file
      _RL     active_var(*)
      _RL     g_active_var(*)
      CHARACTER*(2) arrShape
      INTEGER myNr
      INTEGER iRec
      LOGICAL useCurrentDir
      INTEGER myOptimIter
      INTEGER myThid
      _RL     dummy, g_dummy

C     !LOCAL VARIABLES:
C     globalFile     :: used for writing global (if =T) or tiled files
      CHARACTER*(2)  pref
      CHARACTER*(MAX_LEN_FNAM) fName
      LOGICAL globalFile
CEOP

      pref = 'g_'
      CALL ADD_PREFIX( pref, activeVar_file, fName )
      globalFile = .FALSE.

      IF ( arrShape.EQ.'XY' ) THEN

        CALL ACTIVE_WRITE_3D_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_3D_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'XZ' ) THEN

        CALL ACTIVE_WRITE_XZ_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_XZ_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'YZ' ) THEN

        CALL ACTIVE_WRITE_YZ_RL(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_YZ_RL(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSE
        STOP
     &   'ABNORMAL END: S/R g_ACTIVE_WRITE_GEN_RL: invalid arrShape'
      ENDIF

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: g_ACTIVE_WRITE_GEN_RS
C     !INTERFACE:
      SUBROUTINE g_ACTIVE_WRITE_GEN_RS(
     I                               activeVar_file,
     I                               active_var,
     I                               g_active_var,
     I                               arrShape, myNr,
     I                               iRec,
     I                               useCurrentDir,
     I                               myOptimIter,
     I                               myThid,
     I                               dummy, g_dummy )

C     !DESCRIPTION: \bv
C     ==================================================================
C     SUBROUTINE g_ACTIVE_WRITE_GEN_RS
C     ==================================================================
C     o Write an active (_RS) variable from file (generic version).
C     Accept active variable of various (XY,XZ,YZ) shape and level
C     number, according to arguments arrShape and myNr.
C     ==================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     activeVar_file :: filename
C     active_var     :: active variable array
C     arrShape       :: shape of active-var array ('XY','XZ' or 'YZ')
C     myNr           :: number of vertical-levels in active-var array
C     iRec           :: record number in file
C     useCurrentDir  :: always write to the current directory
C                        (even if "mdsioLocalDir" is set)
C     myOptimIter    :: number of optimization iteration (default: 0)
C     myThid         :: my Thread Id number
C     dummy          :: (needed for 2nd derivative code)
      CHARACTER*(*) activeVar_file
      _RS     active_var(*)
      _RS     g_active_var(*)
      CHARACTER*(2) arrShape
      INTEGER myNr
      INTEGER iRec
      LOGICAL useCurrentDir
      INTEGER myOptimIter
      INTEGER myThid
      _RS     dummy, g_dummy

C     !LOCAL VARIABLES:
C     globalFile     :: used for writing global (if =T) or tiled files
      CHARACTER*(2)  pref
      CHARACTER*(MAX_LEN_FNAM) fName
      LOGICAL globalFile
CEOP

      pref = 'g_'
      CALL ADD_PREFIX( pref, activeVar_file, fName )
      globalFile = .FALSE.

      IF ( arrShape.EQ.'XY' ) THEN

        CALL ACTIVE_WRITE_3D_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_3D_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'XZ' ) THEN

        CALL ACTIVE_WRITE_XZ_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_XZ_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSEIF ( arrShape.EQ.'YZ' ) THEN

        CALL ACTIVE_WRITE_YZ_RS(
     &                 activeVar_file, active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 FORWARD_SIMULATION, myOptimIter, myThid )
        CALL ACTIVE_WRITE_YZ_RS(
     &                 fName, g_active_var, globalFile,
     &                 useCurrentDir, iRec, myNr,
     &                 TANGENT_SIMULATION, myOptimIter, myThid )

      ELSE
        STOP
     &   'ABNORMAL END: S/R g_ACTIVE_WRITE_GEN_RS: invalid arrShape'
      ENDIF

      RETURN
      END
