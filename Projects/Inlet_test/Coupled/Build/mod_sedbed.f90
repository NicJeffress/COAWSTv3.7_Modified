      MODULE mod_sedbed
!
!svn $Id: sedbed_mod.h 1054 2021-03-06 19:47:12Z arango $
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2021 The ROMS/TOMS Group        John C. Warner   !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  Sediment Model Kernel Variables:                                    !
!                                                                      !
! avgbedldu       Time-averaged Bed load u-transport (kg/m/s).         !
! avgbedldv       Time-averaged Bed load v-transport (kg/m/s).         !
!  bed            Sediment properties in each bed layer:               !
!                   bed(:,:,:,ithck) => layer thickness                !
!                   bed(:,:,:,iaged) => layer age                      !
!                   bed(:,:,:,iporo) => layer porosity                 !
!                   bed(:,:,:,idiff) => layer bio-diffusivity          !
!  bed_frac       Sediment fraction of each size class in each bed     !
!                   layer(nondimensional: 0-1.0).  Sum of              !
!                   bed_frac = 1.0.                                    !
!  bed_mass       Sediment mass of each size class in each bed layer   !
!                   (kg/m2).
!  bed_thick0     Sum all initial bed layer thicknesses (m).           !
!  bed_thick      Instantaneous total bed thickness (m).               !
!  bedldu         Bed load u-transport (kg/m/s).                       !
!  bedldv         Bed load v-transport (kg/m/s).                       !
!  ursell_no      Ursell number of the asymmetric wave.                !
!  RR_asymwave    Velocity skewness parameter of the asymmetric wave.  !
!  beta_asymwave  Accleration assymetry parameter.                     !
!  ucrest_r       Crest velocity of the asymmetric wave form (m/s).    !
!  utrough_r      Trough velocity of the asymmetric wave form (m/s).   !
!  T_crest        Crest time period of the asymmetric wave form (s).   !
!  T_trough       Trough time period of the asymmetric wave form (s).  !
!
!  bottom         Exposed sediment layer properties:                   !
!                   bottom(:,:,isd50) => mean grain diameter           !
!                   bottom(:,:,idens) => mean grain density            !
!                   bottom(:,:,iwsed) => mean settling velocity        !
!                   bottom(:,:,itauc) => mean critical erosion stress  !
!                   bottom(:,:,irlen) => ripple length                 !
!                   bottom(:,:,irhgt) => ripple height                 !
!                   bottom(:,:,ibwav) => bed wave excursion amplitude  !
!                   bottom(:,:,izdef) => default bottom roughness      !
!                   bottom(:,:,izapp) => apparent bottom roughness     !
!                   bottom(:,:,izNik) => Nikuradse bottom roughness    !
!                   bottom(:,:,izbio) => biological bottom roughness   !
!                   bottom(:,:,izbfm) => bed form bottom roughness     !
!                   bottom(:,:,izbld) => bed load bottom roughness     !
!                   bottom(:,:,izwbl) => wave bottom roughness         !
!                   bottom(:,:,iactv) => active layer thickness        !
!                   bottom(:,:,ishgt) => saltation height              !
!                   bottom(:,:,imaxD) => maximum inundation depth      !
!                   bottom(:,:,idnet) => Erosion or deposition         !
!                   bottom(:,:,idtbl) => Thickness of wbl              !
!                   bottom(:,:,idubl) => Current velocity at wbl       !
!                   bottom(:,:,idfdw) => Friction factor from currents !
!                   bottom(:,:,idzrw) => Ref height for near bottom vel!
!                   bottom(:,:,idksd) => Bed roughness for wbl         !
!                   bottom(:,:,idusc) => Current friction velocity wbl !
!                   bottom(:,:,idpcx) => Angle between currents and xi !
!                   bottom(:,:,idpwc) => Angle between waves / currents!
!  ero_flux       Flux from erosion.                                   !
!  settling_flux  Flux from settling.                                  !
!                                                                      !
!=======================================================================
!
      USE mod_kinds
!
      implicit none
!
      TYPE T_SEDBED
!
!  Nonlinear model state.
!
        real(r8), pointer :: avgbedldu(:,:,:)
        real(r8), pointer :: avgbedldv(:,:,:)
        real(r8), pointer :: bed(:,:,:,:)
        real(r8), pointer :: bed_frac(:,:,:,:)
        real(r8), pointer :: bed_mass(:,:,:,:,:)
        real(r8), pointer :: bed_thick0(:,:)
        real(r8), pointer :: bed_thick(:,:,:)
        real(r8), pointer :: bedldu(:,:,:)
        real(r8), pointer :: bedldv(:,:,:)
        real(r8), pointer :: ursell_no(:,:)
        real(r8), pointer :: RR_asymwave(:,:)
        real(r8), pointer :: beta_asymwave(:,:)
        real(r8), pointer :: ucrest_r(:,:)
        real(r8), pointer :: utrough_r(:,:)
        real(r8), pointer :: T_crest(:,:)
        real(r8), pointer :: T_trough(:,:)
        real(r8), pointer :: bottom(:,:,:)
        real(r8), pointer :: ero_flux(:,:,:)
        real(r8), pointer :: settling_flux(:,:,:)
      END TYPE T_SEDBED
      TYPE (T_SEDBED), allocatable :: SEDBED(:)
      CONTAINS
      SUBROUTINE allocate_sedbed (ng, LBi, UBi, LBj, UBj)
!
!=======================================================================
!                                                                      !
!  This routine allocates all variables in the module for all nested   !
!  grids.                                                              !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_ncparam
      USE mod_sediment
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, LBi, UBi, LBj, UBj
!
!-----------------------------------------------------------------------
!  Allocate structure variables.
!-----------------------------------------------------------------------
!
      IF (ng.eq.1) allocate ( SEDBED(Ngrids) )
!
!  Nonlinear model state.
!
      IF (ANY(Aout(idUbld(:),ng))) THEN
        allocate ( SEDBED(ng) % avgbedldu(LBi:UBi,LBj:UBj,NST) )
      END IF
      IF (ANY(Aout(idVbld(:),ng))) THEN
        allocate ( SEDBED(ng) % avgbedldv(LBi:UBi,LBj:UBj,NST) )
      END IF
      allocate ( SEDBED(ng) % bed(LBi:UBi,LBj:UBj,Nbed,MBEDP) )
      allocate ( SEDBED(ng) % bed_frac(LBi:UBi,LBj:UBj,Nbed,NST) )
      allocate ( SEDBED(ng) % bed_mass(LBi:UBi,LBj:UBj,Nbed,2,NST) )
      allocate ( SEDBED(ng) % bed_thick0(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % bed_thick(LBi:UBi,LBj:UBj,1:3) )
      allocate ( SEDBED(ng) % bedldu(LBi:UBi,LBj:UBj,NST) )
      allocate ( SEDBED(ng) % bedldv(LBi:UBi,LBj:UBj,NST) )
      allocate ( SEDBED(ng) % ursell_no(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % RR_asymwave(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % beta_asymwave(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % ucrest_r(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % utrough_r(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % T_crest(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % T_trough(LBi:UBi,LBj:UBj) )
      allocate ( SEDBED(ng) % bottom(LBi:UBi,LBj:UBj,MBOTP) )
      allocate ( SEDBED(ng) % ero_flux(LBi:UBi,LBj:UBj,NST) )
      allocate ( SEDBED(ng) % settling_flux(LBi:UBi,LBj:UBj,NST) )
      RETURN
      END SUBROUTINE allocate_sedbed
      SUBROUTINE initialize_sedbed (ng, tile, model)
!
!=======================================================================
!                                                                      !
!  This routine initialize structure variables in the module using     !
!  first touch distribution policy. In shared-memory configuration,    !
!  this operation actually performs the propagation of the  shared     !
!  arrays  across the cluster,  unless another policy is specified     !
!  to  override the default.                                           !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_ncparam
      USE mod_sediment
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
!
!  Local variable declarations.
!
      integer :: Imin, Imax, Jmin, Jmax
      integer :: i, itrc, j, k
      real(r8), parameter :: IniVal = 0.0_r8
!
!-----------------------------------------------------------------------
!  Set lower and upper tile bounds and staggered variables bounds for
!  this horizontal domain partition.  Notice that if tile=-1, it will
!  set the values for the global grid.
!-----------------------------------------------------------------------
!
      integer :: Istr, IstrB, IstrP, IstrR, IstrT, IstrM, IstrU
      integer :: Iend, IendB, IendP, IendR, IendT
      integer :: Jstr, JstrB, JstrP, JstrR, JstrT, JstrM, JstrV
      integer :: Jend, JendB, JendP, JendR, JendT
      integer :: Istrm3, Istrm2, Istrm1, IstrUm2, IstrUm1
      integer :: Iendp1, Iendp2, Iendp2i, Iendp3
      integer :: Jstrm3, Jstrm2, Jstrm1, JstrVm2, JstrVm1
      integer :: Jendp1, Jendp2, Jendp2i, Jendp3
!
      Istr   =BOUNDS(ng) % Istr   (tile)
      IstrB  =BOUNDS(ng) % IstrB  (tile)
      IstrM  =BOUNDS(ng) % IstrM  (tile)
      IstrP  =BOUNDS(ng) % IstrP  (tile)
      IstrR  =BOUNDS(ng) % IstrR  (tile)
      IstrT  =BOUNDS(ng) % IstrT  (tile)
      IstrU  =BOUNDS(ng) % IstrU  (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
      IendB  =BOUNDS(ng) % IendB  (tile)
      IendP  =BOUNDS(ng) % IendP  (tile)
      IendR  =BOUNDS(ng) % IendR  (tile)
      IendT  =BOUNDS(ng) % IendT  (tile)
      Jstr   =BOUNDS(ng) % Jstr   (tile)
      JstrB  =BOUNDS(ng) % JstrB  (tile)
      JstrM  =BOUNDS(ng) % JstrM  (tile)
      JstrP  =BOUNDS(ng) % JstrP  (tile)
      JstrR  =BOUNDS(ng) % JstrR  (tile)
      JstrT  =BOUNDS(ng) % JstrT  (tile)
      JstrV  =BOUNDS(ng) % JstrV  (tile)
      Jend   =BOUNDS(ng) % Jend   (tile)
      JendB  =BOUNDS(ng) % JendB  (tile)
      JendP  =BOUNDS(ng) % JendP  (tile)
      JendR  =BOUNDS(ng) % JendR  (tile)
      JendT  =BOUNDS(ng) % JendT  (tile)
!
      Istrm3 =BOUNDS(ng) % Istrm3 (tile)            ! Istr-3
      Istrm2 =BOUNDS(ng) % Istrm2 (tile)            ! Istr-2
      Istrm1 =BOUNDS(ng) % Istrm1 (tile)            ! Istr-1
      IstrUm2=BOUNDS(ng) % IstrUm2(tile)            ! IstrU-2
      IstrUm1=BOUNDS(ng) % IstrUm1(tile)            ! IstrU-1
      Iendp1 =BOUNDS(ng) % Iendp1 (tile)            ! Iend+1
      Iendp2 =BOUNDS(ng) % Iendp2 (tile)            ! Iend+2
      Iendp2i=BOUNDS(ng) % Iendp2i(tile)            ! Iend+2 interior
      Iendp3 =BOUNDS(ng) % Iendp3 (tile)            ! Iend+3
      Jstrm3 =BOUNDS(ng) % Jstrm3 (tile)            ! Jstr-3
      Jstrm2 =BOUNDS(ng) % Jstrm2 (tile)            ! Jstr-2
      Jstrm1 =BOUNDS(ng) % Jstrm1 (tile)            ! Jstr-1
      JstrVm2=BOUNDS(ng) % JstrVm2(tile)            ! JstrV-2
      JstrVm1=BOUNDS(ng) % JstrVm1(tile)            ! JstrV-1
      Jendp1 =BOUNDS(ng) % Jendp1 (tile)            ! Jend+1
      Jendp2 =BOUNDS(ng) % Jendp2 (tile)            ! Jend+2
      Jendp2i=BOUNDS(ng) % Jendp2i(tile)            ! Jend+2 interior
      Jendp3 =BOUNDS(ng) % Jendp3 (tile)            ! Jend+3
!
!  Set array initialization range.
!
      Imin=BOUNDS(ng)%LBi(tile)
      Imax=BOUNDS(ng)%UBi(tile)
      Jmin=BOUNDS(ng)%LBj(tile)
      Jmax=BOUNDS(ng)%UBj(tile)
!
!-----------------------------------------------------------------------
!  Initialize sediment structure variables.
!-----------------------------------------------------------------------
!
!  Nonlinear model state.
!
      IF ((model.eq.0).or.(model.eq.iNLM)) THEN
        IF (ANY(Aout(idUbld(:),ng))) THEN
          DO itrc=1,NST
            DO j=Jmin, Jmax
              DO i=Imin,Imax
                SEDBED(ng) % avgbedldu(i,j,itrc) = IniVal
              END DO
            END DO
          END DO
        END IF
        IF (ANY(Aout(idVbld(:),ng))) THEN
          DO itrc=1,NST
            DO j=Jmin, Jmax
              DO i=Imin,Imax
                SEDBED(ng) % avgbedldv(i,j,itrc) = IniVal
              END DO
            END DO
          END DO
        END IF
        DO j=Jmin,Jmax
          DO itrc=1,MBEDP
            DO k=1,Nbed
              DO i=Imin,Imax
                SEDBED(ng) % bed(i,j,k,itrc) = IniVal
              END DO
            END DO
          END DO
          DO itrc=1,NST
            DO k=1,Nbed
              DO i=Imin,Imax
                SEDBED(ng) % bed_frac(i,j,k,itrc) = IniVal
                SEDBED(ng) % bed_mass(i,j,k,1,itrc) = IniVal
                SEDBED(ng) % bed_mass(i,j,k,2,itrc) = IniVal
              END DO
            END DO
          END DO
          DO i=Imin,Imax
            SEDBED(ng) % bed_thick0(i,j) = IniVal
            SEDBED(ng) % bed_thick(i,j,1) = IniVal
            SEDBED(ng) % bed_thick(i,j,2) = IniVal
            SEDBED(ng) % bed_thick(i,j,3) = IniVal
          END DO
          DO itrc=1,NST
            DO i=Imin,Imax
              SEDBED(ng) % bedldu(i,j,itrc) = IniVal
              SEDBED(ng) % bedldv(i,j,itrc) = IniVal
            END DO
          END DO
          DO i=Imin,Imax
            SEDBED(ng) % ursell_no(i,j)    = IniVal
            SEDBED(ng) % RR_asymwave(i,j)  = IniVal
            SEDBED(ng) % beta_asymwave(i,j)= IniVal
            SEDBED(ng) % ucrest_r(i,j)     = IniVal
            SEDBED(ng) % utrough_r(i,j)    = IniVal
            SEDBED(ng) % T_crest(i,j)      = IniVal
            SEDBED(ng) % T_trough(i,j)     = IniVal
          END DO
          DO itrc=1,MBOTP
            DO i=Imin,Imax
              SEDBED(ng) % bottom(i,j,itrc) = IniVal
            END DO
          END DO
          DO itrc=1,NST
            DO i=Imin,Imax
              SEDBED(ng) % ero_flux(i,j,itrc) = IniVal
              SEDBED(ng) % settling_flux(i,j,itrc) = IniVal
            END DO
          END DO
        END DO
      END IF
      RETURN
      END SUBROUTINE initialize_sedbed
      END MODULE mod_sedbed