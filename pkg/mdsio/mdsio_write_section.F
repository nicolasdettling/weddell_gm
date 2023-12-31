#include "MDSIO_OPTIONS.h"

C--  File mdsio_read_section.F: Routines to handle mid-level I/O interface.
C--   Contents
C--   o MDS_WRITE_SEC_XZ
C--   o MDS_WRITE_SEC_YZ

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

CBOP
C !ROUTINE: MDS_WRITE_SEC_XZ
C !INTERFACE:
      SUBROUTINE MDS_WRITE_SEC_XZ(
     I   fName,
     I   filePrec,
     I   globalFile,
     I   useCurrentDir,
     I   arrType,
     I   kSize, kLo, kHi,
     I   fldRL, fldRS,
     I   irecord,
     I   myIter,
     I   myThid )

C !DESCRIPTION
C Arguments:
C
C fName       string  :: base name for file to read
C filePrec    integer :: number of bits per word in file (32 or 64)
C globalFile  logical :: selects between writing a global or tiled file
C useCurrentDir logic :: always write to the current directory (even if
C                        "mdsioLocalDir" is set)
C arrType     char(2) :: which array (fldRL/RS) to write, either "RL" or "RS"
C kSize       integer :: size of second dimension: normally either 1 or Nr
C kLo         integer :: 1rst vertical level (of array fldRL/RS) to write
C kHi         integer :: last vertical level (of array fldRL/RS) to write
C fldRL         RL    :: array to write if arrType="RL", fldRL(:,kSize,:,:)
C fldRS         RS    :: array to write if arrType="RS", fldRS(:,kSize,:,:)
C irecord     integer :: record number to read
C myIter      integer :: time step number
C myThid      integer :: thread identifier
C
C MDS_WRITE_SEC_XZ creates either a file of the form "fName.data"
C if the logical flag "globalFile" is set true. Otherwise
C it creates MDS tiled files of the form "fName.xxx.yyy.data".
C The precision of the file is decsribed by filePrec, set either
C  to floatPrec32 or floatPrec64. The char*(2) string arrType, either "RL"
C  or "RS", selects which array is written, either fldRL or fldRS.
C This routine writes vertical slices (X-Z) including overlap regions.
C irecord is the record number to be read and must be >= 1.
C NOTE: It is currently assumed that
C the highest record number in the file was the last record written.
C
C Modified: 06/02/00 spk@ocean.mit.edu
CEOP

C !USES:
      IMPLICIT NONE
C Global variables / common blocks
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXCH2
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_TOPOLOGY.h"
#include "W2_EXCH2_PARAMS.h"
#endif /* ALLOW_EXCH2 */

C !INPUT PARAMETERS:
      CHARACTER*(*) fName
      INTEGER filePrec
      LOGICAL globalFile
      LOGICAL useCurrentDir
      CHARACTER*(2) arrType
      INTEGER kSize, kLo, kHi
      _RL  fldRL(*)
      _RS  fldRS(*)
      INTEGER irecord
      INTEGER myIter
      INTEGER myThid
C !OUTPUT PARAMETERS:

C !FUNCTIONS:
      INTEGER ILNBLNK
      INTEGER MDS_RECLEN
      EXTERNAL ILNBLNK, MDS_RECLEN

C !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_FNAM) dataFName, pfName
      INTEGER IL, pIL, dUnit, nLev, irec
      INTEGER iG, jG, bi, bj, k, kL
      Real*4 r4seg(sNx)
      Real*8 r8seg(sNx)
      INTEGER length_of_rec
      LOGICAL fileIsOpen
      CHARACTER*(MAX_LEN_MBUF) msgBuf
#ifdef ALLOW_EXCH2
      INTEGER tGx, tNx, tN
#endif /* ALLOW_EXCH2 */

C     ------------------------------------------------------------------

C Only do I/O if I am the master thread
      _BEGIN_MASTER( myThid )

C Record number must be >= 1
      IF (irecord .LT. 1) THEN
       WRITE(msgBuf,'(A,I9.8)')
     &   ' MDS_WRITE_SEC_XZ: argument irecord = ',irecord
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A)')
     &   ' MDS_WRITE_SEC_XZ: invalid value for irecord'
       CALL PRINT_ERROR( msgBuf, myThid )
       STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_XZ'
      ENDIF

C Assume nothing
      fileIsOpen=.FALSE.
      IL  = ILNBLNK( fName )
      pIL = ILNBLNK( mdsioLocalDir )

C Assign special directory
      IF ( useCurrentDir .OR. pIL.EQ.0 ) THEN
       pfName= fName
      ELSE
       WRITE(pfName,'(2A)') mdsioLocalDir(1:pIL), fName(1:IL)
      ENDIF
      pIL=ILNBLNK( pfName )

C Set number of levels to write:
      nLev = kHi - kLo + 1

C Assign a free unit number as the I/O channel for this routine
      CALL MDSFINDUNIT( dUnit, myThid )

C If we are writing to a global file then we open it here
      IF (globalFile) THEN
       WRITE(dataFName,'(2A)') fName(1:IL),'.data'
       IF (irecord .EQ. 1) THEN
        length_of_rec = MDS_RECLEN( filePrec, sNx, myThid )
        OPEN( dUnit, file=dataFName, status=_NEW_STATUS,
     &        access='direct', recl=length_of_rec )
        fileIsOpen=.TRUE.
       ELSE
        length_of_rec = MDS_RECLEN( filePrec, sNx, myThid )
        OPEN( dUnit, file=dataFName, status='old',
     &        access='direct', recl=length_of_rec )
        fileIsOpen=.TRUE.
       ENDIF
      ENDIF

C Loop over all tiles
      DO bj=1,nSy
       DO bi=1,nSx
C If we are writing to a tiled MDS file then we open each one here
        IF (.NOT. globalFile) THEN
         iG=bi+(myXGlobalLo-1)/sNx
         jG=bj+(myYGlobalLo-1)/sNy
         WRITE(dataFName,'(2A,I3.3,A,I3.3,A)')
     &              pfName(1:pIL),'.',iG,'.',jG,'.data'
         IF (irecord .EQ. 1) THEN
          length_of_rec = MDS_RECLEN( filePrec, sNx, myThid )
          OPEN( dUnit, file=dataFName, status=_NEW_STATUS,
     &          access='direct', recl=length_of_rec )
          fileIsOpen=.TRUE.
         ELSE
          length_of_rec = MDS_RECLEN( filePrec, sNx, myThid )
          OPEN( dUnit, file=dataFName, status='old',
     &          access='direct', recl=length_of_rec )
          fileIsOpen=.TRUE.
         ENDIF
        ENDIF
        IF (fileIsOpen) THEN
#ifdef ALLOW_EXCH2
C layout of global x-z section files is "xStack"
         tN = W2_myTileList(bi,bj)
         tGx = exch2_txXStackLo(tN)
         tNx = exch2_tNx(tN)
#endif /* ALLOW_EXCH2 */
         DO k=1,nLev
           kL = k + kLo - 1
           IF (globalFile) THEN
#ifdef ALLOW_EXCH2
C record length is sNx==tNx
            irec = 1 + ( tGx-1
     &                   + ( k-1 + (irecord-1)*nLev )*exch2_xStack_Nx
     &                 )/tNx
#else /* ALLOW_EXCH2 */
            iG = myXGlobalLo-1 + (bi-1)*sNx
            jG = (myYGlobalLo-1)/sNy + (bj-1)
            irec = 1 + INT(iG/sNx) + nSx*nPx*(k-1)
     &           + nSx*nPx*nLev*(irecord-1)
#endif /* ALLOW_EXCH2 */
           ELSE
            iG = 0
            jG = 0
            irec = k + nLev*(irecord-1)
           ENDIF
           IF (filePrec .EQ. precFloat32) THEN
            IF (arrType .EQ. 'RS') THEN
             CALL MDS_SEG4toRS_2D( sNx,OLx,kSize,bi,bj,kL,.FALSE.,
     &                             r4seg,fldRS )
            ELSEIF (arrType .EQ. 'RL') THEN
             CALL MDS_SEG4toRL_2D( sNx,OLx,kSize,bi,bj,kL,.FALSE.,
     &                             r4seg,fldRL )
            ELSE
             WRITE(msgBuf,'(A)')
     &         ' MDS_WRITE_SEC_XZ: illegal value for arrType'
             CALL PRINT_ERROR( msgBuf, myThid )
             STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_XZ'
            ENDIF
#ifdef _BYTESWAPIO
            CALL MDS_BYTESWAPR4(sNx,r4seg)
#endif
            WRITE(dUnit,rec=irec) r4seg
           ELSEIF (filePrec .EQ. precFloat64) THEN
            IF (arrType .EQ. 'RS') THEN
             CALL MDS_SEG8toRS_2D( sNx,OLx,kSize,bi,bj,kL,.FALSE.,
     &                             r8seg,fldRS )
            ELSEIF (arrType .EQ. 'RL') THEN
             CALL MDS_SEG8toRL_2D( sNx,OLx,kSize,bi,bj,kL,.FALSE.,
     &                             r8seg,fldRL )
            ELSE
             WRITE(msgBuf,'(A)')
     &         ' MDS_WRITE_SEC_XZ: illegal value for arrType'
             CALL PRINT_ERROR( msgBuf, myThid )
             STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_XZ'
            ENDIF
#ifdef _BYTESWAPIO
            CALL MDS_BYTESWAPR8( sNx, r8seg )
#endif
            WRITE(dUnit,rec=irec) r8seg
           ELSE
            WRITE(msgBuf,'(A)')
     &        ' MDS_WRITE_SEC_XZ: illegal value for filePrec'
            CALL PRINT_ERROR( msgBuf, myThid )
            STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_XZ'
           ENDIF
C End of k loop
         ENDDO
        ELSE
         WRITE(msgBuf,'(A)')
     &     ' MDS_WRITE_SEC_XZ: I should never get to this point'
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_XZ'
        ENDIF
C If we were writing to a tiled MDS file then we close it here
        IF (fileIsOpen .AND. (.NOT. globalFile)) THEN
         CLOSE( dUnit )
         fileIsOpen = .FALSE.
        ENDIF
C End of bi,bj loops
       ENDDO
      ENDDO

C If global file was opened then close it
      IF (fileIsOpen .AND. globalFile) THEN
       CLOSE( dUnit )
       fileIsOpen = .FALSE.
      ENDIF

      _END_MASTER( myThid )

C     ------------------------------------------------------------------
      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

CBOP
C !ROUTINE: MDS_WRITE_SEC_YZ
C !INTERFACE:
      SUBROUTINE MDS_WRITE_SEC_YZ(
     I   fName,
     I   filePrec,
     I   globalFile,
     I   useCurrentDir,
     I   arrType,
     I   kSize, kLo, kHi,
     I   fldRL, fldRS,
     I   irecord,
     I   myIter,
     I   myThid )

C !DESCRIPTION
C Arguments:
C
C fName       string  :: base name for file to read
C filePrec    integer :: number of bits per word in file (32 or 64)
C globalFile  logical :: selects between writing a global or tiled file
C useCurrentDir logic :: always write to the current directory (even if
C                        "mdsioLocalDir" is set)
C arrType     char(2) :: which array (fldRL/RS) to write, either "RL" or "RS"
C kSize       integer :: size of second dimension: normally either 1 or Nr
C kLo         integer :: 1rst vertical level (of array fldRL/RS) to write
C kHi         integer :: last vertical level (of array fldRL/RS) to write
C fldRL         RL    :: array to write if arrType="RL", fldRL(:,kSize,:,:)
C fldRS         RS    :: array to write if arrType="RS", fldRS(:,kSize,:,:)
C irecord     integer :: record number to read
C myIter      integer :: time step number
C myThid      integer :: thread identifier
C
C MDS_WRITE_SEC_YZ creates either a file of the form "fName.data"
C if the logical flag "globalFile" is set true. Otherwise
C it creates MDS tiled files of the form "fName.xxx.yyy.data".
C The precision of the file is decsribed by filePrec, set either
C  to floatPrec32 or floatPrec64. The char*(2) string arrType, either "RL"
C  or "RS", selects which array is written, either fldRL or fldRS.
C This routine writes vertical slices (Y-Z) including overlap regions.
C irecord is the record number to be read and must be >= 1.
C NOTE: It is currently assumed that
C the highest record number in the file was the last record written.
C
C Modified: 06/02/00 spk@ocean.mit.edu
CEOP

C !USES:
      IMPLICIT NONE
C Global variables / common blocks
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXCH2
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_TOPOLOGY.h"
#include "W2_EXCH2_PARAMS.h"
#endif /* ALLOW_EXCH2 */

C !INPUT PARAMETERS:
      CHARACTER*(*) fName
      INTEGER filePrec
      LOGICAL globalFile
      LOGICAL useCurrentDir
      CHARACTER*(2) arrType
      INTEGER kSize, kLo, kHi
      _RL  fldRL(*)
      _RS  fldRS(*)
      INTEGER irecord
      INTEGER myIter
      INTEGER myThid
C !OUTPUT PARAMETERS:

C !FUNCTIONS:
      INTEGER ILNBLNK
      INTEGER MDS_RECLEN
      EXTERNAL ILNBLNK, MDS_RECLEN

C !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_FNAM) dataFName, pfName
      INTEGER IL, pIL, dUnit, nLev, irec
      INTEGER iG, jG, bi, bj, k, kL
      Real*4 r4seg(sNy)
      Real*8 r8seg(sNy)
      INTEGER length_of_rec
      LOGICAL fileIsOpen
      CHARACTER*(MAX_LEN_MBUF) msgBuf
#ifdef ALLOW_EXCH2
      INTEGER tGy, tNy, tN
#endif /* ALLOW_EXCH2 */
C     ------------------------------------------------------------------

C Only do I/O if I am the master thread
      _BEGIN_MASTER( myThid )

C Record number must be >= 1
      IF (irecord .LT. 1) THEN
       WRITE(msgBuf,'(A,I9.8)')
     &   ' MDS_WRITE_SEC_YZ: argument irecord = ',irecord
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       WRITE(msgBuf,'(A)')
     &   ' MDS_WRITE_SEC_YZ: invalid value for irecord'
       CALL PRINT_ERROR( msgBuf, myThid )
       STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_YZ'
      ENDIF

C Assume nothing
      fileIsOpen=.FALSE.
      IL  = ILNBLNK( fName )
      pIL = ILNBLNK( mdsioLocalDir )

C Assign special directory
      IF ( useCurrentDir .OR. pIL.EQ.0 ) THEN
       pfName= fName
      ELSE
       WRITE(pfName,'(2a)') mdsioLocalDir(1:pIL), fName(1:IL)
      ENDIF
      pIL=ILNBLNK( pfName )

C Set number of levels to write:
      nLev = kHi - kLo + 1

C Assign a free unit number as the I/O channel for this routine
      CALL MDSFINDUNIT( dUnit, myThid )

C If we are writing to a global file then we open it here
      IF (globalFile) THEN
       WRITE(dataFName,'(2A)') fName(1:IL),'.data'
       IF (irecord .EQ. 1) THEN
        length_of_rec = MDS_RECLEN( filePrec, sNy, myThid )
        OPEN( dUnit, file=dataFName, status=_NEW_STATUS,
     &        access='direct', recl=length_of_rec )
        fileIsOpen=.TRUE.
       ELSE
        length_of_rec = MDS_RECLEN( filePrec, sNy, myThid )
        OPEN( dUnit, file=dataFName, status='old',
     &        access='direct', recl=length_of_rec )
        fileIsOpen=.TRUE.
       ENDIF
      ENDIF

C Loop over all tiles
      DO bj=1,nSy
       DO bi=1,nSx
C If we are writing to a tiled MDS file then we open each one here
        IF (.NOT. globalFile) THEN
         iG=bi+(myXGlobalLo-1)/sNx
         jG=bj+(myYGlobalLo-1)/sNy
         WRITE(dataFName,'(2A,I3.3,A,I3.3,A)')
     &              pfName(1:pIL),'.',iG,'.',jG,'.data'
         IF (irecord .EQ. 1) THEN
          length_of_rec = MDS_RECLEN( filePrec, sNy, myThid )
          OPEN( dUnit, file=dataFName, status=_NEW_STATUS,
     &          access='direct', recl=length_of_rec )
          fileIsOpen=.TRUE.
         ELSE
          length_of_rec = MDS_RECLEN( filePrec, sNy, myThid )
          OPEN( dUnit, file=dataFName, status='old',
     &          access='direct', recl=length_of_rec )
          fileIsOpen=.TRUE.
         ENDIF
        ENDIF
        IF (fileIsOpen) THEN
#ifdef ALLOW_EXCH2
C layout of global y-z section files is "yStack"
         tN = W2_myTileList(bi,bj)
         tGy = exch2_tyYStackLo(tN)
         tNy = exch2_tNy(tN)
#endif /* ALLOW_EXCH2 */
         DO k=1,nLev
           kL = k + kLo - 1
           IF (globalFile) THEN
#ifdef ALLOW_EXCH2
C record length is sNy==tNy
            irec = 1 + ( tGy-1
     &                   + ( k-1 + (irecord-1)*nLev )*exch2_yStack_Ny
     &                 )/tNy
#else /* ALLOW_EXCH2 */
            iG = (myXGlobalLo-1)/sNx + (bi-1)
            jG = myYGlobalLo-1 + (bj-1)*sNy
            irec = 1 + INT(jG/sNy) + nSy*nPy*(k-1)
     &           + nSy*nPy*nLev*(irecord-1)
#endif /* ALLOW_EXCH2 */
           ELSE
            iG = 0
            jG = 0
            irec = k + nLev*(irecord-1)
           ENDIF
           IF (filePrec .EQ. precFloat32) THEN
            IF (arrType .EQ. 'RS') THEN
             CALL MDS_SEG4toRS_2D( sNy,OLy,kSize,bi,bj,kL,.FALSE.,
     &                             r4seg,fldRS )
            ELSEIF (arrType .EQ. 'RL') THEN
             CALL MDS_SEG4toRL_2D( sNy,OLy,kSize,bi,bj,kL,.FALSE.,
     &                             r4seg,fldRL )
            ELSE
             WRITE(msgBuf,'(A)')
     &         ' MDS_WRITE_SEC_YZ: illegal value for arrType'
             CALL PRINT_ERROR( msgBuf, myThid )
             STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_YZ'
            ENDIF
#ifdef _BYTESWAPIO
            CALL MDS_BYTESWAPR4(sNy,r4seg)
#endif
            WRITE(dUnit,rec=irec) r4seg
           ELSEIF (filePrec .EQ. precFloat64) THEN
            IF (arrType .EQ. 'RS') THEN
             CALL MDS_SEG8toRS_2D( sNy,OLy,kSize,bi,bj,kL,.FALSE.,
     &                             r8seg,fldRS )
            ELSEIF (arrType .EQ. 'RL') THEN
             CALL MDS_SEG8toRL_2D( sNy,OLy,kSize,bi,bj,kL,.FALSE.,
     &                             r8seg,fldRL )
            ELSE
             WRITE(msgBuf,'(A)')
     &         ' MDS_WRITE_SEC_YZ: illegal value for arrType'
             CALL PRINT_ERROR( msgBuf, myThid )
             STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_YZ'
            ENDIF
#ifdef _BYTESWAPIO
            CALL MDS_BYTESWAPR8( sNy, r8seg )
#endif
            WRITE(dUnit,rec=irec) r8seg
           ELSE
            WRITE(msgBuf,'(A)')
     &        ' MDS_WRITE_SEC_YZ: illegal value for filePrec'
            CALL PRINT_ERROR( msgBuf, myThid )
            STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_YZ'
           ENDIF
C End of k loop
         ENDDO
        ELSE
         WRITE(msgBuf,'(A)')
     &     ' MDS_WRITE_SEC_YZ: I should never get to this point'
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R MDS_WRITE_SEC_YZ'
        ENDIF
C If we were writing to a tiled MDS file then we close it here
        IF (fileIsOpen .AND. (.NOT. globalFile)) THEN
         CLOSE( dUnit )
         fileIsOpen = .FALSE.
        ENDIF
C End of bi,bj loops
       ENDDO
      ENDDO

C If global file was opened then close it
      IF (fileIsOpen .AND. globalFile) THEN
       CLOSE( dUnit )
       fileIsOpen = .FALSE.
      ENDIF

      _END_MASTER( myThid )

C     ------------------------------------------------------------------
      RETURN
      END
