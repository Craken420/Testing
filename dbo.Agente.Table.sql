SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agente](
	[Agente] [varchar](10) NOT NULL,
	[Nombre] [varchar](100) NULL,
	[Tipo] [varchar](15) NULL,
	[Moneda] [varchar](10) NULL,
	[Telefonos] [varchar](100) NULL,
	[Extencion] [varchar](10) NULL,
	[Categoria] [varchar](50) NULL,
	[Familia] [varchar](50) NULL,
	[Zona] [varchar](30) NULL,
	[Grupo] [varchar](50) NULL,
	[Estatus] [varchar](15) NOT NULL,
	[UltimoCambio] [datetime] NULL,
	[Clase] [varchar](15) NULL,
	[Alta] [datetime] NULL,
	[Baja] [datetime] NULL,
	[Conciliar] [bit] NOT NULL,
	[Mensaje] [varchar](50) NULL,
	[BeneficiarioNombre] [varchar](100) NULL,
	[CostoHora] [money] NULL,
	[TipoComision] [varchar](20) NULL,
	[Porcentaje] [float] NULL,
	[Nomina] [bit] NOT NULL,
	[Personal] [varchar](10) NULL,
	[NominaMov] [varchar](20) NULL,
	[NominaConcepto] [varchar](50) NULL,
	[Direccion] [varchar](100) NULL,
	[Colonia] [varchar](30) NULL,
	[Poblacion] [varchar](30) NULL,
	[Estado] [varchar](30) NULL,
	[Pais] [varchar](30) NULL,
	[CodigoPostal] [varchar](15) NULL,
	[RFC] [varchar](20) NULL,
	[CURP] [varchar](30) NULL,
	[TieneMovimientos] [bit] NULL,
	[NivelAcceso] [varchar](50) NULL,
	[SucursalEmpresa] [int] NULL,
	[Logico1] [bit] NOT NULL,
	[Logico2] [bit] NOT NULL,
	[Equipo] [bit] NOT NULL,
	[Cuota] [money] NULL,
	[ArticuloDef] [varchar](20) NULL,
	[AlmacenDef] [varchar](10) NULL,
	[Acreedor] [varchar](10) NULL,
	[eMail] [varchar](50) NULL,
	[eMailAuto] [bit] NULL,
	[VentasCasa] [bit] NULL,
	[ReportaA] [varchar](10) NULL,
	[Jornada] [varchar](20) NULL,
	[Licencia] [varchar](20) NULL,
	[RutaAgenteMAVI] [varchar](50) NULL,
	[UENMAVI] [int] NULL,
	[NivelCobranzaMAVI] [varchar](100) NULL,
	[MaximoCuentas] [int] NULL,
	[NivelCobTelefonicaMavi] [varchar](15) NULL,
	[NoAgentesInicio] [int] NULL,
 CONSTRAINT [priAgente] PRIMARY KEY CLUSTERED 
(
	[Agente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ('Agente') FOR [Tipo]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [Conciliar]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [Nomina]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [TieneMovimientos]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [Logico1]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [Logico2]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [Equipo]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [eMailAuto]
GO
ALTER TABLE [dbo].[Agente] ADD  DEFAULT ((0)) FOR [VentasCasa]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================
-- NOMBRE			: DM0021TriggerComisionChoferes
-- AUTOR			: Noe de Jesus Ibarra Cardona
-- FECHA CREACION	: 14/05/2013
-- DESARROLLO		: DM0021 Comisiones Choferes
-- MODULO			: 
-- DESCRIPCION		: TRIGER PARA INSERTAR EN LA TABLA DE DM0021TriggerComisionChoferes PARA OBTENER LOS SUELDOS GARANTIA DE LOS CHOFERES.
--						Y actualizar el estatus del chofer.
--========================================================================================================================================
--	FECHA Y AUTOR MODIFICACION:		14/05/2013		Por: NOMBRE COMPLETO, ASI COMO TAMBIEN SE DEBE DOCUMENTAR LA MODIFICACION REALIZADA.
--========================================================================================================================================
--	FECHA Y AUTOR MODIFICACION:		18/11/2014		Por: MIGUEL ALONSO RAMOS MICHEL
--	Se agrega 'FOR UPDATE' para actualizar el estatus de los choferes
--========================================================================================================================================

CREATE TRIGGER [dbo].[DM0021TriggerComisionChoferes] ON [dbo].[Agente]
	FOR INSERT, UPDATE
AS BEGIN

IF (Select COUNT(Agente) From Deleted D WITH(NOLOCK)) > 0
	BEGIN
	DECLARE @FechaUp	DATETIME
	IF UPDATE(Categoria) OR UPDATE(Tipo) OR UPDATE(Estatus)
		UPDATE DM0021ComisionChoferSGarantia WITH (ROWLOCK) SET Estatus = 'BAJA'
		WHERE Tipo = 'CHOFER' and Categoria = 'REPARTO' and Estatus = 'ALTA' AND IdAgente IN (
														SELECT D.Agente
														FROM Deleted D
														JOIN Inserted I ON I.Agente = D.Agente
														WHERE D.Estatus = 'ALTA' and D.Categoria = 'REPARTO' and D.Tipo = 'CHOFER'
														)
	ELSE
		SELECT @FechaUp = GETDATE()
	END
ELSE
	BEGIN
	DECLARE
		@FechaA				DATETIME,
		@FechaAD			VARCHAR (2),
		@FechaAM			VARCHAR (2),
		@FechaAA			VARCHAR (4),
		@NoQuincena			INT,
		@ParOImpar			INT,
		@Saberpar			VARCHAR(2),
		@Calculado			VARCHAR(2),
		@CalculadoM			VARCHAR (2),
		@CalculadoA			VARCHAR (4),
		@CantidaddeMeses	INT,
		@UltimoDiaMes		INT,
		@Bisiesto			VARCHAR (2),
		@FechaG				DATETIME,
		@IDagente			VARCHAR (10),
		@NombreAgente		VARCHAR (50),
		@TipoAgenta			VARCHAR (20),
		@CategoriaAgente	VARCHAR(15),
		@EstatusAgente		VARCHAR(15),
		@FechaMCalcula		INT 

		SET @FechaA        = Getdate()
		SET @FechaAD       = DATEPART (DAY,@FechaA)
		SET @FechaAM       = DATEPART (MONTH,@FechaA)
		SET @FechaAA       = DATEPART (YEAR,@FechaA)
		SELECT @NoQuincena = NoDquincena FROM DM0021SueldoGarantia WITH (NOLOCK) WHERE ID=1		
		IF (@NoQuincena >=0)
			BEGIN
			IF (@NoQuincena > 0 )
				BEGIN 
				SET @ParOImpar	= @NoQuincena%2
				IF (@FechaAM=2)
					BEGIN
					IF (@FechaAA % 4 = 0 AND (@FechaAA % 100 <> 0 OR @FechaAA % 400 = 0))
						BEGIN 
						SET @Bisiesto='SI'
						END
					ELSE
						BEGIN
						SET @Bisiesto='NO'
						END
					END
				IF  (@ParOImpar = 0)
					BEGIN 
					SET @Saberpar='SI'
					END
				ELSE
					BEGIN
					SET @Saberpar='NO'
					END
				IF (@FechaAM =12 AND (@NoQuincena > 1 OR @FechaAD>17 ))
					BEGIN
					SET @FechaAM=0
					SET @FechaAA=@FechaAA+1
					END
				IF (@Saberpar = 'NO' AND (@NoQuincena>=3 OR (@FechaAD > 16 AND (
																				@FechaAM = 3 OR
																				@FechaAM = 5 OR
																				@FechaAM = 7 OR
																				@FechaAM = 8 OR
																				@FechaAM = 10  ))) )
					BEGIN
					SET @FechaMCalcula = @FechaAM + 1 
					END
				ELSE
					BEGIN 
					SET @FechaMCalcula = @FechaAM
					END
				SET @UltimoDiaMes= CASE(@FechaMCalcula)
						WHEN 1 THEN 31
						WHEN 2 THEN CASE ISNULL(@Bisiesto,'NO') WHEN 'SI' THEN 29
																WHEN 'NO' THEN 28
									END
						WHEN 3  THEN 31
						WHEN 4  THEN 30
						WHEN 5  THEN 31
						WHEN 6  THEN 30	
						WHEN 7  THEN 31
						WHEN 8  THEN 31	
						WHEN 9  THEN 30	
						WHEN 10 THEN 31
						WHEN 11 THEN 30
						WHEN 12 THEN 31
					END
				IF (@Saberpar = 'SI' )
					BEGIN
					SET @CantidaddeMeses = @NoQuincena/2
					SET @CalculadoM =@FechaAM +@CantidaddeMeses	
					SET @FechaG= @FechaAA + '-'+ @CalculadoM + '-' +	@FechaAD 
					END 
				ELSE IF(@Saberpar = 'NO')
					BEGIN
					SET @CantidaddeMeses = (@NoQuincena/2)
					SET @CalculadoM =@FechaAM + @CantidaddeMeses
					IF (@FechaAD > 16 OR (@FechaAD>16 AND (@NoQuincena>=3 
													OR @FechaMCalcula = 2 
													OR @FechaMCalcula = 4 
													OR @FechaMCalcula = 6
													OR @FechaMCalcula = 9 
													OR @FechaMCalcula = 11)))
						BEGIN
						if (@FechaAD = 17 AND (@FechaAM = 1 OR @FechaAM = 12 OR @FechaAM = 7))
							BEGIN
							SET @Calculado = @UltimoDiaMes
							END
						ELSE
							BEGIN
							SET @Calculado = @FechaAD + 15 - @UltimoDiaMes - 1
							SET @CalculadoM =@CalculadoM +1
							END
						END
					ELSE
						BEGIN
						IF (@CalculadoM = 2 AND (@FechaAD = 15 OR @FechaAD = 16 OR @FechaAD = 14))
							BEGIN
							IF (ISNULL(@Bisiesto,'NO') ='SI' AND (@FechaAD = 15 OR @FechaAD = 16))
								SET @Calculado = 29
							ELSE
								SET @Calculado = 28
							END
						ELSE
							BEGIN
							SET @Calculado = @FechaAD + 15 - 1
							END
						END
					SET @FechaG= @FechaAA + '-'+ @CalculadoM + '-' +@Calculado 	
					END			
				END
			ELSE 
				BEGIN
				SET @FechaG = @FechaA	 
				END
			SELECT @IDagente=I.Agente, @NombreAgente=I.Nombre,@TipoAgenta=I.Tipo,@CategoriaAgente=I.Categoria,@EstatusAgente=I.Estatus FROM Inserted I where I.Tipo='Chofer' and I.Categoria='Reparto' and I.Estatus='Alta' 
			IF (@IDagente IS NOT NULL)
				BEGIN 
				INSERT INTO DM0021ComisionChoferSGarantia (IdAgente,Nombre,Tipo,FechaAlta,NoQuincenas,FechaPago,Categoria,Estatus) VALUES (@IDagente,@NombreAgente,@TipoAgenta,@FechaA,@NoQuincena,@FechaG,@CategoriaAgente,@EstatusAgente)
				END
			END
	END
END
GO
ALTER TABLE [dbo].[Agente] ENABLE TRIGGER [DM0021TriggerComisionChoferes]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================
-- NOMBRE   : tg_LocCiudadAgte
-- AUTOR	: Marco Valdovinos
-- FECHA CREACION : 22/05/2014
-- DESARROLLO  : Comisiones Cobranza Campo
-- MODULO   : Comis
-- DESCRIPCION  : Trigger para guardar historico de la ciudad donde labora un agente foraneo
-- EJEMPLO   : 
-- ========================================================================================================================================

CREATE TRIGGER [dbo].[tg_LocCiudadAgte] ON [dbo].[Agente]
FOR INSERT, UPDATE
AS BEGIN

Declare @Agente varchar(10), @Poblacionant VARCHAR(30),@poblacionact VARCHAR(30),@tipo varchar(15)

Select @Poblacionant = Poblacion From Deleted WITH(NOLOCK)
Select @Agente = Agente ,@poblacionact = Poblacion ,@tipo = tipo From inserted WITH(NOLOCK)


IF (@Poblacionant !=  @poblacionact AND @Tipo='Cobrador')   
    INSERT INTO LocCiudadAgteHist (Agente, UbicacionLaboral, Fechacambio) VALUES (@Agente, @poblacionact,getdate())  
   

END
GO
ALTER TABLE [dbo].[Agente] ENABLE TRIGGER [tg_LocCiudadAgte]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE TRIGGER [dbo].[tgAgenteBC] ON [dbo].[Agente]
--//WITH ENCRYPTION
FOR UPDATE, DELETE
AS BEGIN
  DECLARE
    @ClaveNueva  	varchar(10),
    @ClaveAnterior	varchar(10),
    @NombreNuevo	varchar(100),
    @NombreAnterior	varchar(100),
    @RFCNuevo		varchar(20),
    @RFCAnterior	varchar(20),
    @CURPNuevo		varchar(30),
    @CURPAnterior	varchar(30),
    @Mensaje 		varchar(255)

  SELECT @ClaveNueva    = Agente, @NombreNuevo    = Nombre, @RFCNuevo    = RFC, @CURPNuevo    = CURP FROM Inserted
  SELECT @ClaveAnterior = Agente, @NombreAnterior = Nombre, @RFCAnterior = RFC, @CURPAnterior = CURP FROM Deleted

  /*IF @NombreNuevo <> @NombreAnterior OR @RFCNuevo <> @RFCAnterior OR @CURPNuevo <> @CURPAnterior*/

  IF @ClaveNueva=@ClaveAnterior RETURN

  IF @ClaveNueva IS NULL 
  BEGIN
    DELETE AgenteActividad WHERE Agente = @ClaveAnterior
    DELETE AgenteCte       WHERE Agente = @ClaveAnterior
    DELETE AgentePersonal  WHERE Agente = @ClaveAnterior
    DELETE AgenteAgenda    WHERE Agente = @ClaveAnterior
    DELETE EquipoAgente    WHERE Equipo = @ClaveAnterior OR Agente = @ClaveAnterior
    DELETE AgenteComisionTipoFactura WHERE Agente = @ClaveAnterior

    DELETE Prop            WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    DELETE ListaD	   WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    DELETE AnexoCta        WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    DELETE CuentaTarea     WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
	  DELETE CtoCampoExtra WHERE Tipo = 'Agente' AND Clave = @ClaveAnterior
	  DELETE FormaExtraValor WHERE Aplica = 'Agente' AND AplicaClave = @ClaveAnterior
	  DELETE FormaExtraD WHERE Aplica = 'Agente' AND AplicaClave = @ClaveAnterior
  END ELSE 
  IF @ClaveNueva <> @ClaveAnterior
  BEGIN
    UPDATE AgenteActividad WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior
    UPDATE AgenteCte       WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior
    UPDATE AgentePersonal  WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior
    UPDATE AgenteAgenda    WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior
    UPDATE EquipoAgente    WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior
    UPDATE EquipoAgente    WITH(ROWLOCK) SET Equipo = @ClaveNueva WHERE Equipo = @ClaveAnterior
    UPDATE AgenteComisionTipoFactura WITH(ROWLOCK) SET Agente = @ClaveNueva WHERE Agente = @ClaveAnterior

    UPDATE Prop            WITH(ROWLOCK) SET Cuenta		= @ClaveNueva WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    UPDATE ListaD          WITH(ROWLOCK) SET Cuenta		= @ClaveNueva WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    UPDATE AnexoCta        WITH(ROWLOCK) SET Cuenta		= @ClaveNueva WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
    UPDATE CuentaTarea     WITH(ROWLOCK) SET Cuenta		= @ClaveNueva WHERE Cuenta = @ClaveAnterior AND Rama='AGENT'
	UPDATE CtoCampoExtra   WITH(ROWLOCK) SET Clave		= @ClaveNueva WHERE Clave   = @ClaveAnterior AND Tipo='Agente'
	UPDATE FormaExtraValor WITH(ROWLOCK) SET AplicaClave  = @ClaveNueva WHERE AplicaClave   = @ClaveAnterior AND Aplica='Agente'
	UPDATE FormaExtraD	   WITH(ROWLOCK) SET AplicaClave  = @ClaveNueva WHERE AplicaClave   = @ClaveAnterior AND Aplica='Agente'
  END
END
GO
ALTER TABLE [dbo].[Agente] ENABLE TRIGGER [tgAgenteBC]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* trigger para guardar los historicos del campo ReportaA  ARC 28-May-09 - Desarrollo de comisiones */
-- ========================================================================================================================================
-- NOMBRE   : tgAgenteReportaA
-- AUTOR	: 
-- FECHA CREACION : 
-- DESARROLLO  : 
-- MODULO   : 
-- DESCRIPCION  : Trigger para guardar historico de Jefes(ReportaA) en Celulas.
-- EJEMPLO   :  tgAgenteReportaA
-- MODIFICACION	: JRV - Se agrego para que tambien guarde el historico de Familia (Tipo Vendedores Instituciones)
-- ========================================================================================================================================
-- MODIFICACION : EF.MARTINEZ 2014sep30- Se agrega en para que guarde los cambios de nivel de cobranza de los agentes 'AgenteNivelHistMAVI'
CREATE TRIGGER [dbo].[tgAgenteReportaA] ON [dbo].[Agente]
FOR INSERT, UPDATE
AS BEGIN
	DECLARE
	    @Agente				Varchar(10),
		@AgenteAnt			Varchar(10),
		@Reporta			Varchar(10),
	    @ReportaAnt			Varchar(10),
		@Familia			Varchar(50),
		@FamiliaAnt			Varchar(50),
		@Tipo				Varchar(15),
		@TipoAnt			Varchar(15),
		@Sucursal			Int,
		@SucursalAnt		Int,
		@Fecha				Datetime,
		@CantIns			Int,
		@CantDel			Int,
		@FamCant			Int,
		@RepCant			Int,
		@Nivel				VARCHAR(60),
		@NivelAnt			VARCHAR(60),
		@Penultima			VARCHAR(60)


	SELECT @CantIns = COUNT(*) from Inserted 
	SELECT @CantDel = COUNT(*) FROM Deleted

	SELECT @FamCant = COUNT(*) 
	FROM Inserted I
		INNER JOIN Deleted D ON I.Agente=D.Agente AND ISNULL(I.Familia,'S/F') <> ISNULL(D.Familia,'S/F')

	SELECT @RepCant = COUNT(*) 
	FROM Inserted I
		INNER JOIN Deleted D ON I.Agente=D.Agente AND ISNULL(I.ReportaA,'S/RA') <> ISNULL(D.ReportaA,'S/RA')

	SELECT @Fecha = GETDATE()
	SELECT @Agente = NULL, @Reporta = NULL, @AgenteAnt = NULL, @ReportaAnt = NULL, @Familia=NULL, @FamiliaAnt=NULL, @Tipo=NULL, @TipoAnt=NULL, @Sucursal=NULL, @SucursalAnt=NULL

	SELECT @Agente = Agente, @Reporta = ReportaA, @Familia=Familia, @Tipo=Tipo, @Sucursal=SucursalEmpresa,@Nivel=NivelCobranzaMAVI FROM Inserted
	SELECT @AgenteAnt = Agente, @ReportaAnt = ReportaA, @FamiliaAnt=Familia, @TipoAnt=Tipo, @SucursalAnt=SucursalEmpresa,@NivelAnt=NivelCobranzaMAVI FROM Deleted


	IF ((@CantIns>1 AND @CantDel>1) AND @RepCant>1)
		INSERT INTO AgenteReportaHistMAVI (Agente, ReportaA, Fecha)
			SELECT Agente, ReportaA, @Fecha FROM Inserted
	ELSE
		IF (((@Agente <> @AgenteAnt) OR (@Reporta <> @ReportaAnt)) AND @CantIns=1)
			INSERT INTO AgenteReportaHistMAVI (Agente, ReportaA, Fecha) VALUES (@Agente, @Reporta, @Fecha)

	
	--SACAR AL ReportaA
	IF @CantIns = 1
		BEGIN
			--Guardar el Penultimo Equipo/Division donde estuvo el Reporta A
			SET @Penultima = (SELECT Agente FROM (Select ROW_NUMBER() OVER(ORDER BY fecha DESC) AS Row, Agente,ReportaA from AgenteReportaHistMAVI With (NoLock)
			where ReportaA=@Reporta) AS Penultimo WHERE Row=2)
			
			IF(@Penultima <> @Agente)
			BEGIN
			--Si el reporta A esta en mas de 1 equipo (contando el que entró recientemente)
				IF (select top 1 ReportaA from AgenteReportaHistMAVI With (NoLock) Where Agente=@Penultima and ReportaA=@Reporta order by Fecha desc) = @Reporta
					BEGIN
						--Si No es Cobranza Menudeo
						IF(Select dbo.FN_DM0237VERIFICACOBRANZA(@Agente,@Reporta))<>0 
						  BEGIN
							--Actualizar El Equipo anterior, quitando el Reporta A que tenía
							update Agente WITH(ROWLOCK) SET ReportaA='' where Agente=@Penultima
						  END
					END
			END
		END
	

	IF ((@CantIns>1 AND @CantDel>1) AND @FamCant>1)
		INSERT INTO AgenteFamiliaHistMAVI (Agente, Familia, Fecha)
			SELECT Agente, Familia, @Fecha FROM Inserted
	ELSE
		IF (((@Agente <> @AgenteAnt) OR (@Familia <> @FamiliaAnt)) AND @CantIns=1)
			INSERT INTO AgenteFamiliaHistMAVI (Agente, Familia, Fecha) VALUES (@Agente, @Familia, @Fecha)


	IF (((@Agente <> @AgenteAnt) OR (@Tipo <> @TipoAnt)) AND @CantIns=1)
		INSERT INTO AgenteTipoHistMAVI (Agente, Tipo, Fecha) VALUES (@Agente, @Tipo, @Fecha)
		
	
	IF (((@Agente <> @AgenteAnt) OR (@Nivel <> @NivelAnt)) AND @CantIns=1)
		INSERT INTO AgenteNivelHistMAVI (Agente, Nivel, Fecha) VALUES (@Agente, @Nivel, @Fecha)

	
	IF (((@Sucursal <> @SucursalAnt) OR (@Agente <> @AgenteAnt) OR (@Tipo <> @TipoAnt) OR (@Familia <> @FamiliaAnt)) AND @CantIns=1)
		INSERT INTO SucursalEstHistMAVI (Sucursal, Agente, Tipo, Familia, Fecha) VALUES (@Sucursal, @Agente, @Tipo, @Familia, @Fecha)

END
GO
ALTER TABLE [dbo].[Agente] ENABLE TRIGGER [tgAgenteReportaA]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE TRIGGER [dbo].[tgReportaA] ON [dbo].[Agente]
--//WITH ENCRYPTION
FOR UPDATE
AS BEGIN
   Declare 
     @reportaA Varchar(15)

	 Select @reportaA=@reportaA From inserted 
  IF Update(ReportaA)  Or  @reportaA ='' or @reportaA=' '
      insert into ReortaA (Fechamod) Values (GETDATE())
     
   
END
GO
ALTER TABLE [dbo].[Agente] ENABLE TRIGGER [tgReportaA]
GO
