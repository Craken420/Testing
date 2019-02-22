SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[spContSATGenerarXml]
	@Estacion	int,
	@xml		varchar(max)= NULL OUTPUT,
	@Ok         int = NULL OUTPUT, 
	@OkRef      varchar(255) = NULL OUTPUT		
AS
BEGIN
DECLARE
---------------     ENCABEZADO     ---------------
	@Version			varchar(5),
	@RFCEmpresa			varchar(13),
	@TipoSolicitud		varchar(2),
	@NumeroSolicitud	varchar(50),
--------------------------------------------------
	@vPolizas		varchar(max),
	@vPoliza		varchar(max),
	@vTransaccion	varchar(max),
--------------------------------------------------
	@Empresa		varchar(5),
	@Ejercicio		int,
	@Periodo		int,
	@TipoArchivo	int,
	@CuentaD		varchar(20),
	@CuentaA		varchar(20),
	@ProvD			varchar(10),
	@ProvA			varchar(10),
	@CteD			varchar(10),
	@CteA			varchar(10),
	@AcreedorD		varchar(10),
	@AcreedorA		varchar(10),
	@CasatD			varchar(40),
	@CasatA			varchar(40),
	@Usuario		varchar(10),
--------------------------------------------------
	@AnexoContaSAT	int,
	@Schema			xml(Poliza),
	@SchemaFolios	xml(RepAuxFolios),
	@cID			int,
	@cFormaPago		varchar(20),	
----------------------------------------------------------------------------------------------------------------------
	@NivelCta       varchar(25),
	@SchemaCuentas	xml(AuxiliarCtas),
	@InfoTipo       int
 ----------------------------------------------------------------------------------------------------------------------   

    CREATE TABLE #EncabezadoPolizas(
                                  [Version]		varchar(3)   COLLATE Database_Default, 
								  RFC			varchar(13)  COLLATE Database_Default, 
								  Mes			varchar(2)   COLLATE Database_Default, 
								  Anio			varchar(4)   COLLATE Database_Default, 
								  TipoSolicitud varchar(2)   COLLATE Database_Default,
								  NumOrden		varchar(20)  COLLATE Database_Default  null,
								  NumTramite	varchar(20)  COLLATE Database_Default  null,
								  Sello			varchar(max) COLLATE Database_Default null,
								  NoCertificado	varchar(20)  COLLATE Database_Default null,
								  Certificado	varchar(max) COLLATE Database_Default null
								  )
----------------------------------------------------------------------------------------------------------------------
								  
    CREATE TABLE #Polizas (
                           ID				int,
					       NumUnIdenPol		varchar(255) COLLATE Database_Default	null,
					       Fecha			varchar(11)	 COLLATE Database_Default	null,
					       Concepto			varchar(255) COLLATE Database_Default	null,
					       ContactoTipo		varchar(20)  COLLATE Database_Default	null,
					       Empresa			varchar(5)   COLLATE Database_Default	null,
					       Cuenta			varchar(20)  COLLATE Database_Default	null,
					       Anio				int,
					       Periodo			int,
					       IDUnico          int identity(1,1)					   
					       PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #Polizas (ID) 
    CREATE INDEX TempEmpresa ON #Polizas (ID,Periodo,Anio,Empresa)
    CREATE INDEX TempPeriodo ON #Polizas (Periodo,Anio,Empresa)
    CREATE INDEX TempCuenta ON #Polizas (ID,Cuenta)
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #Transaccion(
                           ID			int,
						   NumCta		varchar(20)  COLLATE Database_Default	null,
						   DesCta		varchar(100) COLLATE Database_Default	null,
					       Concepto		varchar(255) COLLATE Database_Default	null,
					       Debe			varchar(15)  COLLATE Database_Default	null,
					       Haber		varchar(15)  COLLATE Database_Default	null,
						   Renglon      int,
						   RenglonSub   int,
						   IDUnico      int identity
					       PRIMARY KEY (ID, Renglon, RenglonSub,IDUnico))
    CREATE INDEX TempID ON #Transaccion (ID) 					       
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #CompNal(
                       ID			int,
					   UUID_CFDI	varchar(255) COLLATE Database_Default	null,
					   RFC			varchar(13)  COLLATE Database_Default	null,
					   MontoTotal	float									null,
					   Moneda		varchar(5)	 COLLATE Database_Default	null,
					   TipCamb		float									null,
					   FormaPago	int										null,
					   IDUnico      int identity
					   PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #CompNal (ID) 
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #CompNalOtr(
                          ID				int,
						  CFD_CBB_Serie		varchar(255) COLLATE Database_Default	null,
						  CFD_CBB_NumFol	varchar(255) COLLATE Database_Default	null,
						  RFC				varchar(13)  COLLATE Database_Default	null,
					      MontoTotal		float									null,
					      Moneda			varchar(5)   COLLATE Database_Default	null,
					      TipCamb			float									null,
					      FormaPago			int										null,
						  IDUnico           int identity
					      PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #CompNalOtr (ID)
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #CompExt(
                       ID				int,
					   NumFactExt		varchar(255) COLLATE Database_Default	null,
					   TaxID			varchar(255) COLLATE Database_Default	null,
					   MontoTotal		float									null,
					   Moneda			varchar(5)   COLLATE Database_Default	null,
					   TipCamb			float									null,
					   FormaPago		int										null,
					   IDUnico          int identity
					   PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #CompExt (ID)
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #Cheque(
                       ID				int,
					   Num				varchar(255) COLLATE Database_Default	null,
					   BanEmisNal		varchar(255) COLLATE Database_Default	null,
					   BanEmisExt		varchar(255) COLLATE Database_Default	null,
					   CtaOri			varchar(255) COLLATE Database_Default	null,
					   Fecha			varchar(255) COLLATE Database_Default	null,
					   Benef			varchar(255) COLLATE Database_Default	null,
					   RFC				varchar(13)  COLLATE Database_Default	null,
					   Monto			float			null,
					   Moneda			varchar(5)		null,
					   TipCamb			float			null,
					   IDUnico          int identity
					   PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #Cheque (ID)
----------------------------------------------------------------------------------------------------------------------

    CREATE TABLE #Transferencia(
                              ID				int,
							  CtaOri			varchar(255) COLLATE Database_Default	null,
							  BancoOriNal		varchar(255) COLLATE Database_Default	null,
							  BancoOriExt		varchar(255) COLLATE Database_Default	null,
							  CtaDest			varchar(255) COLLATE Database_Default	null,
							  BancoDestNal		varchar(255) COLLATE Database_Default	null,
							  BancoDestExt		varchar(255) COLLATE Database_Default	null,
							  Fecha				varchar(15)  COLLATE Database_Default	null,
							  Benef				varchar(255) COLLATE Database_Default	null,
							  RFC				varchar(13)  COLLATE Database_Default	null,
							  Monto				float			null,
							  Moneda			varchar(5)   COLLATE Database_Default	null,
							  TipCamb			float			null,
							  IDUnico           int identity
							  PRIMARY KEY (ID,IDUnico))
    CREATE INDEX TempID ON #Transferencia (ID)
----------------------------------------------------------------------------------------------------------------------
							  
    CREATE TABLE #OtrMetodoPago(
                              ID			int,
							  MetPagoPol	varchar(255) COLLATE Database_Default null,
							  Fecha			varchar(13)  COLLATE Database_Default null,
							  Benef			varchar(255) COLLATE Database_Default null,
							  RFC			varchar(13)  COLLATE Database_Default null,
							  Monto			float								  null,
							  Moneda		varchar(5)	 COLLATE Database_Default null,
							  TipCamb		float			null,
							  IDUnico       int identity
							  PRIMARY KEY (ID,IDUnico))	
    CREATE INDEX TempID ON #OtrMetodoPago (ID)						  
-------------------------------------------------Auxiliar cuentas------------------------------------------------------
    CREATE TABLE #Cuenta(
					   NumCta   		varchar(20)  COLLATE Database_Default null,
					   DesCta			varchar(100) COLLATE Database_Default null,
					   SaldoIni			money null,
					   SaldoFin 		money null					   
					   )
    CREATE INDEX TempID ON #Cuenta (NumCta)
    
    CREATE TABLE #DetalleAux(
                             Cuenta		  varchar(20)  COLLATE Database_Default null,
						     Fecha		  varchar(11)  COLLATE Database_Default null,
						     NumUnIdenPol varchar(100) COLLATE Database_Default null,
					         Concepto	  varchar(255) COLLATE Database_Default null,
					         Debe   	  varchar(15)  COLLATE Database_Default null,
					         Haber        varchar(15)  COLLATE Database_Default null
					        )
    CREATE INDEX TempID ON #DetalleAux (Cuenta)
    
    CREATE TABLE #AuxCuentas(
							[Tag]							    int null,
							[Parent]							int null,
							[AuxiliarCtas!1!]					varchar(255) COLLATE Database_Default null,
							[AuxiliarCtas!2!]					varchar(255) COLLATE Database_Default null,
							[AuxiliarCtas!2!NumCta]            	varchar(255) COLLATE Database_Default null,
							[AuxiliarCtas!2!DesCta]            	varchar(255) COLLATE Database_Default null,
							[AuxiliarCtas!2!SaldoIni]          	varchar(255) COLLATE Database_Default null,
							[AuxiliarCtas!2!SaldoFin]          	varchar(255) COLLATE Database_Default null,												
							[Transaccion!3!Fecha]               varchar(255) COLLATE Database_Default null,
							[Transaccion!3!NumUnIdenPol]        varchar(255) COLLATE Database_Default null,
							[Transaccion!3!Concepto]            varchar(255) COLLATE Database_Default null,
							[Transaccion!3!Debe]                varchar(255) COLLATE Database_Default null,
							[Transaccion!3!Haber]               varchar(255) COLLATE Database_Default null											
						  )
						
    CREATE TABLE #Balanza(
                       Cuenta        varchar(20)  COLLATE Database_Default null, 
                       Descripcion   varchar(100) COLLATE Database_Default null, 
                       Tipo          varchar(15)  COLLATE Database_Default null, 
                       EsAcumulativa bit null, 
                       EsAcreedora   bit null, 
                       Inicio        money null, 
                       Cargos        money null, 
                       Abonos        money null
                       )
------------------------------------------------------------------------------------------------------------------------
	SELECT  @Version = Version FROM	EmpresaCfgContaSAT WITH(NOLOCK)
	
	SELECT	@Empresa = Empresa,
			@Ejercicio = Ejercicio,
			@Periodo = Periodo,
			@TipoSolicitud = CASE TipoSolicitud WHEN 1 THEN 'AF'
												WHEN 2 THEN 'FC'
												WHEN 3 THEN 'DE'
												WHEN 4 THEN 'CO'
												ELSE NULL
							 END,
			@TipoArchivo = TipoArchivo,
			@NumeroSolicitud = NoSolicitud,
			@CuentaD = CuentaD,
			@CuentaA = CuentaA,
			@ProvD = ProvD,
			@ProvA = ProvA,
			@CteD = CteD,
			@CteA = CteA,
			@AcreedorD = AcreedorD,
			@AcreedorA = AcreedorA,
			@CasatD = CasatD,
			@CasatA = CasatA,
			@Usuario = Usuario
	  FROM	ParPolizasSAT WITH(NOLOCK)
	 WHERE	Estacion = @Estacion
	 
	 SELECT	@RFCEmpresa = ISNULL(RFC,'')  FROM Empresa WITH(NOLOCK) WHERE Empresa = @Empresa

----------------------------------------------------------------------------------------------------------------------
	 
	IF EXISTS(SELECT * FROM AnexoContaSAT WITH(NOLOCK) WHERE Empresa = @Empresa 
											AND Ejercicio = @Ejercicio 
											AND Periodo = @Periodo
											AND Acuse IS NOT NULL 
											AND Tipo = 'Polizas')
	BEGIN
		SET @AnexoContaSAT = 1
		SET @InfoTipo = 2
	END
	
	IF EXISTS(SELECT * FROM AnexoContaSAT WITH(NOLOCK) WHERE Empresa = @Empresa 
											AND Ejercicio = @Ejercicio 
											AND Periodo = @Periodo
											AND Acuse IS NULL 
											AND Tipo = 'Polizas')
	BEGIN
		SET @AnexoContaSAT = 2
	END
	
	IF NOT EXISTS(SELECT * FROM AnexoContaSAT WITH(NOLOCK) WHERE Empresa = @Empresa 
												AND Ejercicio = @Ejercicio 
												AND Periodo = @Periodo
												AND Tipo = 'Polizas')
	BEGIN
		SET @AnexoContaSAT = 3
		SET @InfoTipo = 1
	END
	
----------------------------------------------------------------------------------------------------------------------

	INSERT INTO #EncabezadoPolizas([Version], RFC, Mes, Anio, TipoSolicitud, 
									NumOrden, 
									NumTramite, 
									Sello, NoCertificado, Certificado)	
							VALUES(@Version, @RFCEmpresa, @Periodo, @Ejercicio, @TipoSolicitud, 
							        CASE WHEN @TipoSolicitud IN ('AF','FC') THEN @NumeroSolicitud ELSE NULL END,
							        CASE WHEN @TipoSolicitud IN ('DE','CO') THEN @NumeroSolicitud ELSE NULL END,
							        NULL, NULL, NULL)
----------------------------------------------------------------------------------------------------------------------
	IF @AnexoContaSAT = 3
	BEGIN
		INSERT INTO #Polizas(ID, NumUnIdenPol, Fecha,        Concepto, Empresa, Anio, Periodo)
					 SELECT A.ID, A.Mov+' '+A.MovID, CONVERT(varchar(10), A.FechaEmision, 126)+'Z', ISNULL(A.Concepto,'N/A'), A.Empresa, A.Ejercicio, A.Periodo
						FROM Cont A WITH(NOLOCK)
				  INNER JOIN MovTipo B WITH(NOLOCK) ON A.Mov = B.Mov AND B.Modulo = 'CONT' 
					   WHERE A.Ejercicio = @Ejercicio
						 AND A.Periodo = @Periodo
						 AND A.Empresa = @Empresa
						 AND A.Estatus = 'CONCLUIDO'
						 AND B.Clave <> 'CONT.PR'
						 AND A.OrigenTipo <> 'FIS' 
						 
	END
	/**********************************************************************/
	IF @AnexoContaSAT = 2 AND EXISTS(SELECT * 
									   FROM ParPolizasSAT 
									  WHERE Estacion = @Estacion
										AND CuentaD IS NULL
										AND CuentaA IS NULL
										AND ProvD IS NULL
										AND ProvA IS NULL
										AND CteD IS NULL
										AND CteA IS NULL
										AND AcreedorD IS NULL
										AND AcreedorA IS NULL
										AND CasatD IS NULL
										AND CasatA IS NULL)
	BEGIN
		SET @InfoTipo = 1
		
		INSERT INTO #Polizas(ID, NumUnIdenPol, Fecha,        Concepto, Empresa, Anio, Periodo)
					  SELECT C.ID, C.Mov+' '+C.MovID, CONVERT(varchar(10), C.FechaEmision, 126)+'Z', ISNULL(C.Concepto,'N/A'), C.Empresa, C.Ejercicio, C.Periodo
						FROM Cont C WITH(NOLOCK)
			      INNER JOIN MovTipo B WITH(NOLOCK) ON C.Mov = B.Mov AND B.Modulo = 'CONT' 
					   WHERE C.Ejercicio = @Ejercicio
						 AND C.Periodo = @Periodo
						 AND C.Empresa = @Empresa					 
						 AND C.Estatus = 'CONCLUIDO'
						 AND B.Clave <> 'CONT.PR'
						 AND C.OrigenTipo <> 'FIS' 
	END
	ELSE
	BEGIN	
			IF @AnexoContaSAT <> 3
            BEGIN
					SET @InfoTipo = 2
					
					INSERT INTO #Polizas(ID, NumUnIdenPol, Fecha,        Concepto, ContactoTipo, Empresa, Cuenta, Anio, Periodo)
							  SELECT C.ID, C.Mov+' '+C.MovID, CONVERT(varchar(10), C.FechaEmision, 126)+'Z', ISNULL(C.Concepto,'N/A'), C.ContactoTipo, C.Empresa, Cta.Cuenta, C.Ejercicio, C.Periodo
								FROM Cont C WITH(NOLOCK)
								JOIN ContD CD WITH(NOLOCK) ON C.ID = CD.ID
						  INNER JOIN MovTipo B WITH(NOLOCK) ON C.Mov = B.Mov AND B.Modulo = 'CONT' 
								JOIN Cta Cta WITH(NOLOCK) ON CD.Cuenta = Cta.Cuenta
							   WHERE C.Ejercicio = @Ejercicio
								 AND C.Periodo = @Periodo
								 AND C.Empresa = @Empresa
								 AND ((Cta.Cuenta BETWEEN @CuentaD AND ISNULL(@CuentaA,@CuentaD)) OR @CuentaD IS NULL)
								 AND ((Cta.ClaveSAT BETWEEN @CasatD AND ISNULL(@CasatA,@CasatD)) OR @CasatD IS NULL)
								 AND ((C.Contacto BETWEEN @ProvD AND ISNULL(@ProvA,@ProvD) AND C.ContactoTipo = 'Proveedor') OR @ProvD IS NULL)
								 AND ((C.Contacto BETWEEN @CteD AND ISNULL(@CteA,@CteD) AND C.ContactoTipo = 'Cliente') OR @CteD IS NULL)
								 AND ((C.Contacto BETWEEN @AcreedorD AND ISNULL(@AcreedorA,@AcreedorD) AND C.ContactoTipo = 'Proveedor') OR @AcreedorD IS NULL)
							     AND C.Estatus = 'CONCLUIDO'
							     AND B.Clave <> 'CONT.PR'
						         AND C.OrigenTipo <> 'FIS' 
							 
							 
				IF NOT EXISTS(SELECT * 
								FROM ParPolizasSAT WITH(NOLOCK) 
							   WHERE Estacion = @Estacion
								 AND CuentaD IS NULL
								 AND CuentaA IS NULL
								 AND ProvD IS NULL
								 AND ProvA IS NULL
								 AND CteD IS NULL
								 AND CteA IS NULL
								 AND AcreedorD IS NULL
								 AND AcreedorA IS NULL
								 AND CasatD IS NULL
								 AND CasatA IS NULL
							 )
				BEGIN
					DELETE FROM #Polizas WHERE ContactoTipo IS NULL
				END	
            END
	END
	/**********************************************************************/
	IF @AnexoContaSAT = 1
	BEGIN
		INSERT INTO #Polizas(ID, NumUnIdenPol, Fecha,        Concepto, ContactoTipo, Empresa, Anio, Periodo)
					  SELECT C.ID, C.Mov+' '+C.MovID, CONVERT(varchar(10), C.FechaEmision, 126)+'Z', ISNULL(C.Concepto,'N/A'), C.ContactoTipo, C.Empresa, C.Ejercicio, C.Periodo 
						FROM Cont C WITH(NOLOCK)
						JOIN ContD CD WITH(NOLOCK) ON C.ID = CD.ID
				  INNER JOIN MovTipo B WITH(NOLOCK) ON C.Mov = B.Mov AND B.Modulo = 'CONT' 
						JOIN Cta Cta WITH(NOLOCK) ON CD.Cuenta = Cta.Cuenta
					   WHERE C.Ejercicio = @Ejercicio
						 AND C.Periodo = @Periodo
						 AND C.Empresa = @Empresa
						 AND ((Cta.Cuenta BETWEEN @CuentaD AND ISNULL(@CuentaA,@CuentaD)) OR @CuentaD IS NULL)
						 AND ((Cta.ClaveSAT BETWEEN @CasatD AND ISNULL(@CasatA,@CasatD)) OR @CasatD IS NULL)
						 AND ((C.Contacto BETWEEN @ProvD AND ISNULL(@ProvA,@ProvD) AND C.ContactoTipo = 'Proveedor') OR @ProvD IS NULL)
						 AND ((C.Contacto BETWEEN @CteD AND ISNULL(@CteA,@CteD) AND C.ContactoTipo = 'Cliente') OR @CteD IS NULL)
						 AND ((C.Contacto BETWEEN @AcreedorD AND ISNULL(@AcreedorA,@AcreedorD) AND C.ContactoTipo = 'Proveedor') OR @AcreedorD IS NULL)		
						 AND C.Estatus = 'CONCLUIDO'
						 AND B.Clave <> 'CONT.PR'
						 AND C.OrigenTipo <> 'FIS' 
		
		IF NOT EXISTS(SELECT * 
					FROM ParPolizasSAT WITH(NOLOCK) 
				   WHERE Estacion = @Estacion
					 AND CuentaD IS NULL
					 AND CuentaA IS NULL
					 AND ProvD IS NULL
					 AND ProvA IS NULL
					 AND CteD IS NULL
					 AND CteA IS NULL
					 AND AcreedorD IS NULL
					 AND AcreedorA IS NULL
					 AND CasatD IS NULL
					 AND CasatA IS NULL)
		BEGIN
			DELETE FROM #Polizas WHERE ContactoTipo IS NULL
		END
 
	END

	----------------------------------------------------------------------------------------------------------------------
	                 
	INSERT INTO #Transaccion(ID,Renglon,RenglonSub,NumCta, DesCta, Concepto, Debe, Haber)
					  SELECT ContD.ID,ContD.Renglon,ContD.RenglonSub, ContD.Cuenta, Cta.Descripcion, ISNULL(Cont.Concepto,'N/A'), ISNULL(ROUND(ContD.Debe,4),'0.00') Debe, ISNULL(ROUND(ContD.Haber,4),'0.00') Haber
					    FROM #Polizas Cont 
						JOIN ContD WITH(NOLOCK) ON Cont.ID = ContD.ID AND ISNULL(Cont.Cuenta,ContD.Cuenta) = ContD.Cuenta
						JOIN Cta WITH(NOLOCK) ON ContD.Cuenta = Cta.Cuenta
					   WHERE Cont.Anio = @Ejercicio
						 AND Cont.Periodo = @Periodo
						 AND Cont.Empresa = @Empresa	

----------------------------------------------------------------------------------------------------------------------
	
	INSERT INTO #CompNal(ID, UUID_CFDI, RFC, MontoTotal, Moneda, TipCamb)
				  SELECT Comp.ContID, Comp.UUID, Comp.RFC, ISNULL(ROUND(Comp.Monto,4),'0.00'), NULLIF(Comp.Moneda,'MXN'), CASE WHEN Comp.Moneda = 'MXN' THEN NULL ELSE Comp.TipoCambio END
					FROM ContSATComprobante Comp WITH(NOLOCK)
					JOIN #Polizas C ON Comp.ContID = C.ID
				   WHERE C.Anio = @Ejercicio
					 AND C.Periodo = @Periodo
					 AND C.Empresa = @Empresa
					 AND Comp.UUID IS NOT NULL
					 AND Comp.ContID IS NOT NULL
------------------------------------------------------------------

	INSERT INTO #CompNalOtr(ID, CFD_CBB_Serie, CFD_CBB_NumFol, RFC, MontoTotal, Moneda, TipCamb)
				  SELECT CFDCBB.ContID, CFDCBB.SerieCFDCBB, CFDCBB.NumFolCFDCBB, CFDCBB.RFCBeneficiario, ISNULL(ROUND(CFDCBB.MontoTotal,4),'0.00'), NULLIF(CFDCBB.Moneda,'MXN'), CASE WHEN CFDCBB.Moneda = 'MXN' THEN NULL ELSE CFDCBB.TipoCambio END
					FROM ContSATCFDCBB CFDCBB WITH(NOLOCK)
					JOIN #Polizas C ON CFDCBB.ContID = C.ID
				   WHERE C.Anio = @Ejercicio
					 AND C.Periodo = @Periodo
					 AND C.Empresa = @Empresa
----------------------------------------------------------------------------------------------------------------------

	INSERT INTO #CompExt(ID, NumFactExt, TaxID, MontoTotal, Moneda, TipCamb)
				  SELECT CompExt.ContID, CompExt.NumFactExt, CompExt.TaxID, ISNULL(ROUND(CompExt.MontoTotal,4),'0.00'), NULLIF(CompExt.Moneda,'MXN'), CASE WHEN CompExt.Moneda = 'MXN' THEN NULL ELSE CompExt.TipoCambio END
					FROM ContSATExtranjero CompExt WITH(NOLOCK)
					JOIN #Polizas C ON CompExt.ContID = C.ID
				   WHERE C.Anio = @Ejercicio
					 AND C.Periodo = @Periodo
					 AND C.Empresa = @Empresa
----------------------------------------------------------------------------------------------------------------------

	INSERT INTO #Cheque (ID, Num, 
						 BanEmisNal, 
						 BanEmisExt, 
						 CtaOri, Fecha, 
						 Benef, RFC, Monto, Moneda,	TipCamb)	
				  SELECT Cheque.ContID, Cheque.NumeroCheque, 
						 CASE WHEN Cta.ClaveSAT = '102.02' THEN NULL ELSE REPLICATE('0',(3-LEN(InstFin.ClaveSAT)))+CAST(InstFin.ClaveSAT as varchar(3)) END, 
						 CASE WHEN Cta.ClaveSAT = '102.02' THEN REPLICATE('0',(3-LEN(InstFin.ClaveSAT)))+CAST(InstFin.ClaveSAT as varchar(3)) ELSE NULL END, 
						 CD.NumeroCta, CONVERT(varchar(10),Cheque.Fecha, 126)+'Z', 
						 Cheque.Beneficiario, Cheque.RFC, ISNULL(ROUND(Cheque.Monto,4),'0.00'), Cheque.Moneda, Cheque.TipoCambio
					FROM ContSATCheque Cheque WITH(NOLOCK)
					JOIN #Polizas C ON Cheque.ContID = C.ID
					JOIN CtaDinero CD WITH(NOLOCK) ON Cheque.CtaOrigen = CD.CtaDinero
					JOIN CFDINominaInstitucionFin InstFin WITH(NOLOCK) ON Cheque.BancoOrigen = InstFin.Institucion
			   LEFT JOIN Cta WITH(NOLOCK) ON CD.Cuenta = Cta.Cuenta
				   WHERE C.Anio = @Ejercicio
					 AND C.Periodo = @Periodo
					 AND C.Empresa = @Empresa
----------------------------------------------------------------------------------------------------------------------

	INSERT INTO #Transferencia (ID, 
								CtaOri,
								BancoOriNal,
								BancoOriExt,
								CtaDest,
								BancoDestNal,
								BancoDestExt,
								Fecha,
								Benef,
								RFC,
								Monto,
								Moneda,
								TipCamb
								)	
						 SELECT Trans.ContID,
								CD.NumeroCta,
								CASE WHEN Cta.ClaveSAT = '102.02' THEN NULL ELSE REPLICATE('0',(3-LEN(InstFin.ClaveSAT)))+CAST(InstFin.ClaveSAT as varchar(3)) END,
								CASE WHEN Cta.ClaveSAT = '102.02' THEN REPLICATE('0',(3-LEN(InstFin.ClaveSAT)))+CAST(InstFin.ClaveSAT as varchar(3)) ELSE NULL END,
								CD2.NumeroCta,
								CASE WHEN Cta2.ClaveSAT = '102.02' THEN NULL ELSE REPLICATE('0',(3-LEN(InstFin2.ClaveSAT)))+CAST(InstFin2.ClaveSAT as varchar(3)) END,
								CASE WHEN Cta2.ClaveSAT = '102.02' THEN REPLICATE('0',(3-LEN(InstFin2.ClaveSAT)))+CAST(InstFin2.ClaveSAT as varchar(3)) ELSE NULL END,
								CONVERT(varchar(10),Trans.Fecha, 126)+'Z',
								Trans.Beneficiario,
								Trans.RFC,
								ISNULL(ROUND(Trans.Monto,4),'0.00'),
								NULLIF(Trans.Moneda,'MXN'),
								CASE WHEN NULLIF(Trans.Moneda,'MXN') = 'MXN' THEN NULL ELSE Trans.TipoCambio END
						   FROM ContSATTranferencia Trans WITH(NOLOCK)
						   JOIN #Polizas C ON Trans.ContID = C.ID
						   JOIN CtaDinero CD WITH(NOLOCK)  ON Trans.CtaOrigen = CD.CtaDinero
						   JOIN CtaDinero CD2 WITH(NOLOCK) ON Trans.CtaDestino = CD2.CtaDinero
						   JOIN CFDINominaInstitucionFin InstFin WITH(NOLOCK)  ON Trans.BancoOrigen = InstFin.Institucion
						   JOIN CFDINominaInstitucionFin InstFin2 WITH(NOLOCK) ON Trans.BancoDestino = InstFin2.Institucion
					  LEFT JOIN Cta WITH(NOLOCK) ON CD.Cuenta = Cta.Cuenta
					  LEFT JOIN Cta Cta2 WITH(NOLOCK) ON CD2.Cuenta = Cta2.Cuenta
					      WHERE C.Anio = @Ejercicio
							AND C.Periodo = @Periodo
							AND C.Empresa = @Empresa
----------------------------------------------------------------------------------------------------------------------

	INSERT INTO #OtrMetodoPago (ID, 
								MetPagoPol,
								Fecha,
								Benef,
								RFC,
								Monto,
								Moneda,
								TipCamb
								)	
						 SELECT OtrMetodoPago.ContID,
								REPLICATE('0',(2-LEN(OtrMetodoPago.ClaveMetPago)))+CAST(OtrMetodoPago.ClaveMetPago AS varchar(2)),
								CONVERT(varchar(10),OtrMetodoPago.Fecha,126)+'Z',
								OtrMetodoPago.Beneficiario,
								OtrMetodoPago.RFC,
								ISNULL(ROUND(OtrMetodoPago.Monto,4),'0.00'),
								OtrMetodoPago.Moneda,
								OtrMetodoPago.TipoCambio
						   FROM ContSATOtroMetodoPago OtrMetodoPago WITH(NOLOCK)
						   JOIN #Polizas C ON OtrMetodoPago.ContID = C.ID
						  WHERE C.Anio = @Ejercicio
							AND C.Periodo = @Periodo
							AND C.Empresa = @Empresa
----------------------------------------------------------------------------------------------------------------------


	IF @TipoArchivo = 1
	BEGIN
	
	----------------------------------------------------------------------------------------------------------------------
	CREATE TABLE #General  ([Tag]								int null,
							[Parent]							int null,
							[Polizas!1!]						varchar(255) null,
							[Poliza!2!]							varchar(255) null,
							[Poliza!2!NumUnIdenPol]           	varchar(255) null,
							[Poliza!2!Fecha]                  	varchar(255) null,
							[Poliza!2!Concepto]               	varchar(255) null,
							[Transaccion!3!NumCta]            	varchar(255) null,
							[Transaccion!3!DesCta]            	varchar(255) null,
							[Transaccion!3!Concepto]          	varchar(255) null,
							[Transaccion!3!Debe]              	varchar(255) null,
							[Transaccion!3!Haber]             	varchar(255) null,
							[CompNal!4!UUID_CFDI]             	varchar(255) null,
							[CompNal!4!RFC]                   	varchar(255) null,
							[CompNal!4!MontoTotal]            	varchar(255) null,
							[CompNal!4!Moneda]                	varchar(255) null,
							[CompNal!4!TipCamb]               	varchar(255) null,
							[CompNalOtr!5!CFD_CBB_Serie]      	varchar(255) null,
							[CompNalOtr!5!CFD_CBB_NumFol]     	varchar(255) null,
							[CompNalOtr!5!RFC]                	varchar(255) null,
							[CompNalOtr!5!MontoTotal]         	varchar(255) null,
							[CompNalOtr!5!Moneda]             	varchar(255) null,
							[CompNalOtr!5!TipCamb]            	varchar(255) null,
							[CompExt!6!NumFactExt]            	varchar(255) null,
							[CompExt!6!TaxID]                 	varchar(255) null,
							[CompExt!6!MontoTotal]            	varchar(255) null,
							[CompExt!6!Moneda]                	varchar(255) null,
							[CompExt!6!TipCamb]               	varchar(255) null,
							[Cheque!7!Num]						varchar(255) null,
							[Cheque!7!BanEmisNal]				varchar(255) null,
							[Cheque!7!BanEmisExt]				varchar(255) null,
							[Cheque!7!CtaOri]					varchar(255) null,
							[Cheque!7!Fecha]					varchar(255) null,
							[Cheque!7!Benef]					varchar(255) null,
							[Cheque!7!RFC]						varchar(255) null,
							[Cheque!7!Monto]					varchar(255) null,
							[Cheque!7!Moneda]					varchar(255) null,
							[Cheque!7!TipCamb]					varchar(255) null,
							[Transferencia!8!CtaOri]			varchar(255) null,
							[Transferencia!8!BancoOriNal]		varchar(255) null,
							[Transferencia!8!BancoOriExt]		varchar(255) null,
							[Transferencia!8!CtaDest]			varchar(255) null,
							[Transferencia!8!BancoDestNal]		varchar(255) null,
							[Transferencia!8!BancoDestExt]		varchar(255) null,
							[Transferencia!8!Fecha]				varchar(255) null,
							[Transferencia!8!Benef]				varchar(255) null,
							[Transferencia!8!RFC]				varchar(255) null,
							[Transferencia!8!Monto]				varchar(255) null,
							[Transferencia!8!Moneda]			varchar(255) null,
							[Transferencia!8!TipCamb]			varchar(255) null,
							[OtrMetodoPago!9!MetPagoPol]		varchar(255) null,
							[OtrMetodoPago!9!Fecha]				varchar(255) null,
							[OtrMetodoPago!9!Benef]				varchar(255) null,
							[OtrMetodoPago!9!RFC]				varchar(255) null,
							[OtrMetodoPago!9!Monto]				varchar(255) null,
							[OtrMetodoPago!9!Moneda]            varchar(255) null,
							[OtrMetodoPago!9!TipCamb]			varchar(255) null
							)

----------------------------------------------------------------------------------------------------------------------
	SELECT @vPoliza = (
						SELECT DISTINCT * 
				         FROM (
	                       SELECT  1 AS Tag,
								   NULL AS Parent,
								   NULL AS 'Polizas!1!',
								   NULL AS 'Poliza!2!',
								   NULL AS 'Poliza!2!NumUnIdenPol',
								   NULL AS 'Poliza!2!Fecha',
								   NULL AS 'Poliza!2!Concepto',
								   ---------------------------------------------
								   NULL AS 'Transaccion!3!NumCta',
								   NULL AS 'Transaccion!3!DesCta',
								   NULL AS 'Transaccion!3!Concepto',
								   NULL AS 'Transaccion!3!Debe',
								   NULL AS 'Transaccion!3!Haber',
								   ---------------------------------------------
								   NULL AS 'CompNal!4!UUID_CFDI',
								   NULL AS 'CompNal!4!RFC',
								   NULL AS 'CompNal!4!MontoTotal',
								   NULL AS 'CompNal!4!Moneda',
								   NULL AS 'CompNal!4!TipCamb',
								   ---------------------------------------------
								   NULL AS 'CompNalOtr!5!CFD_CBB_Serie',
								   NULL AS 'CompNalOtr!5!CFD_CBB_NumFol',
								   NULL AS 'CompNalOtr!5!RFC',
								   NULL AS 'CompNalOtr!5!MontoTotal',
								   NULL AS 'CompNalOtr!5!Moneda',
								   NULL AS 'CompNalOtr!5!TipCamb',
								   ---------------------------------------------
								   NULL AS 'CompExt!6!NumFactExt',
								   NULL AS 'CompExt!6!TaxID',
								   NULL AS 'CompExt!6!MontoTotal',
								   NULL AS 'CompExt!6!Moneda',
								   NULL AS 'CompExt!6!TipCamb',
								   ---------------------------------------------
								   NULL AS 'Cheque!7!Num',
								   NULL AS 'Cheque!7!BanEmisNal',
								   NULL AS 'Cheque!7!BanEmisExt',
								   NULL AS 'Cheque!7!CtaOri',
								   NULL AS 'Cheque!7!Fecha',
								   NULL AS 'Cheque!7!Benef',
								   NULL AS 'Cheque!7!RFC',
								   NULL AS 'Cheque!7!Monto',
								   NULL AS 'Cheque!7!Moneda',
								   NULL AS 'Cheque!7!TipCamb',
								   ---------------------------------------------
								   NULL AS 'Transferencia!8!CtaOri',
								   NULL AS 'Transferencia!8!BancoOriNal',
								   NULL AS 'Transferencia!8!BancoOriExt',
								   NULL AS 'Transferencia!8!CtaDest',
								   NULL AS 'Transferencia!8!BancoDestNal',
								   NULL AS 'Transferencia!8!BancoDestExt',
								   NULL AS 'Transferencia!8!Fecha',
								   NULL AS 'Transferencia!8!Benef',
								   NULL AS 'Transferencia!8!RFC',
								   NULL AS 'Transferencia!8!Monto',
								   NULL AS 'Transferencia!8!Moneda',
								   NULL AS 'Transferencia!8!TipCamb',
								   ---------------------------------------------
								   NULL AS 'OtrMetodoPago!9!MetPagoPol',
								   NULL AS 'OtrMetodoPago!9!Fecha',
								   NULL AS 'OtrMetodoPago!9!Benef',
								   NULL AS 'OtrMetodoPago!9!RFC',
								   NULL AS 'OtrMetodoPago!9!Monto',
								   NULL AS 'OtrMetodoPago!9!Moneda',
								   NULL AS 'OtrMetodoPago!9!TipCamb'
                         UNION ALL
	                        SELECT 2 AS Tag,
								   1 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha			as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas	as Poliza 
                         UNION ALL
	                        SELECT 3 AS Tag,
								   2 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha			as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
                         UNION ALL
	                        SELECT 4 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha			as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   CompNal.UUID_CFDI										                as "UUID_CFDI",
								   CompNal.RFC												                as "RFC",
								   CAST(ROUND(CAST(CompNal.MontoTotal as money),2) as varchar(15))			as "MontoTotal",
								   CompNal.Moneda											                as "Moneda",
								   CAST(ROUND(CAST(CompNal.TipCamb as money),2) as varchar(15))			    as "TipCamb",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   --------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   --------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						 LEFT JOIN #CompNal		as CompNal
							    ON Transaccion.ID = CompNal.ID							    
                         UNION ALL
	                        SELECT 5 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha			as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   CompNalOtr.CFD_CBB_Serie								                as "CFD_CBB_Serie",
								   CompNalOtr.CFD_CBB_NumFol							                as "CFD_CBB_NumFol",
								   CompNalOtr.RFC										                as "RFC",
								   CAST(ROUND(CAST(CompNalOtr.MontoTotal as money),2) as varchar(15))	as "MontoTotal",
								   CompNalOtr.Moneda									                as "Moneda",
								   CAST(ROUND(CAST(CompNalOtr.TipCamb as money),2) as varchar(15))		as "TipCamb",
								   --------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   --------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						      JOIN #CompNalOtr	as CompNalOtr
								ON Transaccion.ID = CompNalOtr.ID
                         UNION ALL
	                        SELECT 6 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha  		as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   --------------------------------------------
								   CompExt.NumFactExt									as "NumFactExt",
								   CompExt.TaxID										as "TaxID",
								   CAST(ROUND(CAST(CompExt.MontoTotal as money),2) as varchar(15))		as "MontoTotal",
								   CompExt.Moneda										as "Moneda",
								   CAST(ROUND(CAST(CompExt.TipCamb as money),2) as varchar(15))		as "TipCamb",
								   --------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						      JOIN #CompExt	as CompExt
								ON Transaccion.ID = CompExt.ID
                         UNION ALL
	                        SELECT 7 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha      	as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   Cheque.Num									as "Num",
								   Cheque.BanEmisNal							as "BanEmisNal",
								   Cheque.BanEmisExt							as "BanEmisExt",
								   Cheque.CtaOri								as "CtaOri",
								   Cheque.Fecha								    as "Fecha",
								   Cheque.Benef									as "Benef",
								   Cheque.RFC									as "RFC",
								   CAST(ROUND(CAST(Cheque.Monto as money),2) as varchar(15))	as "Monto",
								   Cheque.Moneda								as "Moneda",
								   CAST(ROUND(CAST(Cheque.TipCamb as money),2) as varchar(15))	as "TipCamb",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						      JOIN #Cheque	as Cheque
								ON Transaccion.ID = Cheque.ID
                         UNION ALL
	                        SELECT 8 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha		    as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   Transferencia.CtaOri									as "CtaOri",
								   Transferencia.BancoOriNal							as "BancoOriNal",
								   Transferencia.BancoOriExt							as "BancoOriExt",
								   Transferencia.CtaDest								as "CtaDest",
								   Transferencia.BancoDestNal							as "BancoDestNal",
								   Transferencia.BancoDestExt							as "BancoDestExt",
								   Transferencia.Fecha							        as "Fecha",
								   Transferencia.Benef									as "Benef",
								   Transferencia.RFC									as "RFC",
								   CAST(ROUND(CAST(Transferencia.Monto as money),2) as varchar(15))	as "Monto",
								   Transferencia.Moneda									as "Moneda",
								   CAST(ROUND(CAST(Transferencia.TipCamb as money),2) as varchar(15))	as "TipCamb",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						      JOIN #Transferencia as Transferencia
								ON Transaccion.ID = Transferencia.ID
                         UNION ALL
	                        SELECT 9 AS Tag,
								   3 AS Parent,
								   NULL,
								   NULL,
								   Poliza.NumUnIdenPol  as "NumUnIdenPol",
								   Poliza.Fecha 		as "Fecha",
								   Poliza.Concepto		as "Concepto",
								   ---------------------------------------------
								   Transaccion.NumCta	as "NumCta",
								   Transaccion.DesCta	as "DesCta",
								   Transaccion.Concepto as "Concepto",
								   Transaccion.Debe		as "Debe",
								   Transaccion.Haber	as "Haber",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
								   ---------------------------------------------
								   OtrMetodoPago.MetPagoPol								as "MetPagoPol",
								   OtrMetodoPago.Fecha   								as "Fecha",
								   OtrMetodoPago.Benef									as "Benef",
								   OtrMetodoPago.RFC									as "RFC",
								   CAST(ROUND(CAST(OtrMetodoPago.Monto as money),2) as varchar(15))	as "Monto",
								   OtrMetodoPago.Moneda									as "Moneda",
								   CAST(ROUND(CAST(OtrMetodoPago.TipCamb as money),2) as varchar(15))	as "TipCamb"
							  FROM #Polizas		as Poliza
							  JOIN #Transaccion as Transaccion
							    ON Poliza.ID = Transaccion.ID
						      JOIN #OtrMetodoPago as OtrMetodoPago
								ON Transaccion.ID = OtrMetodoPago.ID	
				         )General 
				     ORDER BY [Poliza!2!NumUnIdenPol], 
							  [Transaccion!3!NumCta], 
							  [Tag]
						FOR XML EXPLICIT
					  )
----------------------------------------------------------------------------------------------------------------------		
	  IF @vPoliza = '<Polizas/>'
	  BEGIN
	  	SET @OkRef = 'No existe información con los filtros seleccionados'
		SET @Ok = 1
		RETURN	  
	  END

	SELECT @vPoliza = REPLACE(@vPoliza,'<Polizas>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'</Polizas>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<CompNal/>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<CompNalOtr/>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<CompExt/>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<Cheque/>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<Transferencia/>','')
	SELECT @vPoliza = REPLACE(@vPoliza,'<OtrMetodoPago/>','')

----------------------------------------------------------------------------------------------------------------------

	SELECT @vPolizas = CAST((SELECT [Version] as '@Version', 
								    RFC as '@RFC', 
									REPLICATE('0',(2-LEN(Mes)))+CAST(Mes as varchar(2)) as '@Mes', 
									Anio as '@Anio', 
									TipoSolicitud as '@TipoSolicitud',
									NumOrden as '@NumOrden',
									NumTramite as '@NumTramite',
									CAST(@vPoliza as xml)
							   FROM #EncabezadoPolizas
								FOR XML PATH ('Polizas')) as varchar(max))
----------------------------------------------------------------------------------------------------------------------
																																											    
	SELECT @vPolizas = REPLACE(@vPolizas,'<Polizas','<?xml version="1.0" encoding="windows-1252"?><PLZ:Polizas xmlns:PLZ="www.sat.gob.mx/esquemas/ContabilidadE/1_1/PolizasPeriodo" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="www.sat.gob.mx/esquemas/ContabilidadE/1_1/PolizasPeriodo http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/PolizasPeriodo/PolizasPeriodo_1_1.xsd"')
	SELECT @vPolizas = REPLACE(@vPolizas,'</Polizas>','</PLZ:Polizas>')
	SELECT @vPolizas = REPLACE(@vPolizas,'<Poliza','<PLZ:Poliza')
	SELECT @vPolizas = REPLACE(@vPolizas,'</Poliza','</PLZ:Poliza')
	SELECT @vPolizas = REPLACE(@vPolizas,'<Transaccion','<PLZ:Transaccion')
	SELECT @vPolizas = REPLACE(@vPolizas,'</Transaccion','</PLZ:Transaccion')
	SELECT @vPolizas = REPLACE(@vPolizas,'<CompNal','<PLZ:CompNal')
	SELECT @vPolizas = REPLACE(@vPolizas,'</CompNal','</PLZ:CompNal')
	SELECT @vPolizas = REPLACE(@vPolizas,'<CompNalOtr','<PLZ:CompNalOtr')
	SELECT @vPolizas = REPLACE(@vPolizas,'</CompNalOtr','</PLZ:CompNalOtr')
	SELECT @vPolizas = REPLACE(@vPolizas,'<CompExt','<PLZ:CompExt')
	SELECT @vPolizas = REPLACE(@vPolizas,'</CompNalOtr','</PLZ:CompNalOtr')
	SELECT @vPolizas = REPLACE(@vPolizas,'<Cheque','<PLZ:Cheque')
	SELECT @vPolizas = REPLACE(@vPolizas,'</Cheque','</PLZ:Cheque')
	SELECT @vPolizas = REPLACE(@vPolizas,'<Transferencia','<PLZ:Transferencia')
	SELECT @vPolizas = REPLACE(@vPolizas,'</Transferencia','</PLZ:Transferencia')
	SELECT @vPolizas = REPLACE(@vPolizas,'<OtrMetodoPago','<PLZ:OtrMetodoPago')
	SELECT @vPolizas = REPLACE(@vPolizas,'</OtrMetodoPago','</PLZ:OtrMetodoPago')
	
	BEGIN TRY
		--SELECT CAST(@vPolizas AS XML)
		SELECT @Schema = CAST(@vPolizas as XML)
		SELECT @xml = CAST(@Schema as varchar(max))
	END TRY
	BEGIN CATCH
		SET @OkRef = ERROR_MESSAGE()
		SET @Ok = 1

		RETURN
	END CATCH

	EXEC spGenerarArchivoXmlPolizas @XML, @Estacion, @InfoTipo, @Ok OUTPUT, @OkRef OUTPUT

	IF @Ok IS NOT NULL
	BEGIN
		SELECT @Ok, @OkRef
		RETURN
	END
	
	END

/******************************     AUXILIAR DE FOLIOS     ******************************/
	IF @TipoArchivo = 2
	BEGIN
	DECLARE @Origen TABLE(Num int, ID Int, Modulo varchar(20))

----------------------------------------------------------------------------------------------------------------------
		DECLARE cCompNal CURSOR FOR
		SELECT DISTINCT ID FROM #CompNal
		
		OPEN cCompNal
		FETCH NEXT FROM cCompNal INTO @cID
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @Origen
			SELECT Num, ID, Modulo FROM dbo.fnBuscaOrigen('Cont',@cID,@Empresa) fnBO
			
			SELECT @cFormaPago = (SELECT TOP 1 FormaPago 
								    FROM Dinero WITH(NOLOCK) 
								   WHERE ID IN (SELECT TOP 1 ID 
												  FROM @Origen 
												 WHERE Modulo IN ('DIN','CXP') 
											  ORDER BY 1 ASC)
									 AND FormaPago IS NOT NULL)
			
			UPDATE #CompNal SET FormaPago = (SELECT ISNULL(MetodoPagoSAT,98) FROM FormaPago WITH(NOLOCK) WHERE FormaPago = @cFormaPago)
			WHERE ID = @cID
			
			SET @cFormaPago = NULL
			DELETE FROM @Origen
			FETCH NEXT FROM cCompNal INTO @cID
			
		END

		CLOSE cCompNal
		DEALLOCATE cCompNal
----------------------------------------------------------------------------------------------------------------------

		DECLARE cCompNalOtro CURSOR FOR
		SELECT DISTINCT ID FROM #CompNalOtr
		
		OPEN cCompNalOtro
		FETCH NEXT FROM cCompNalOtro INTO @cID
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @Origen
			SELECT Num, ID, Modulo FROM dbo.fnBuscaOrigen('Cont',@cID,@Empresa) fnBO
			
			SELECT @cFormaPago = (SELECT TOP 1 FormaPago 
								    FROM Dinero WITH(NOLOCK) 
								   WHERE ID IN (SELECT TOP 1 ID 
												  FROM @Origen 
												 WHERE Modulo IN ('DIN','CXP') 
											  ORDER BY 1 ASC)
									 AND FormaPago IS NOT NULL)
			
			UPDATE #CompNalOtr SET FormaPago = (SELECT ISNULL(MetodoPagoSAT,98) FROM FormaPago WITH(NOLOCK) WHERE FormaPago = @cFormaPago)
			WHERE ID = @cID
			
			SET @cFormaPago = NULL
			DELETE FROM @Origen
			FETCH NEXT FROM cCompNalOtro INTO @cID
			
		END

		CLOSE cCompNalOtro
		DEALLOCATE cCompNalOtro	
----------------------------------------------------------------------------------------------------------------------

		DECLARE cCompExt CURSOR FOR
		SELECT DISTINCT ID FROM #CompExt
		
		OPEN cCompExt
		FETCH NEXT FROM cCompExt INTO @cID
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @Origen
			SELECT Num, ID, Modulo FROM dbo.fnBuscaOrigen('Cont',@cID,@Empresa) fnBO
			
			SELECT @cFormaPago = (SELECT TOP 1 FormaPago 
								    FROM Dinero WITH(NOLOCK) 
								   WHERE ID IN (SELECT TOP 1 ID 
												  FROM @Origen 
												 WHERE Modulo IN ('DIN','CXP') 
											  ORDER BY 1 ASC)
									 AND FormaPago IS NOT NULL)
			
			UPDATE #CompExt SET FormaPago = (SELECT ISNULL(MetodoPagoSAT,98) FROM FormaPago WITH(NOLOCK) WHERE FormaPago = @cFormaPago)
			WHERE ID = @cID
			
			SET @cFormaPago = NULL
			DELETE FROM @Origen
			FETCH NEXT FROM cCompExt INTO @cID
			
		END

		CLOSE cCompExt
		DEALLOCATE cCompExt	
----------------------------------------------------------------------------------------------------------------------
		DECLARE @AuxFolio TABLE([Tag]								int null,
								[Parent]							int null,
								[RepAuxFol!1!]						varchar(255) null,
								[DetAuxFol!2!]						varchar(255) null,
								[DetAuxFol!2!NumUnIdenPol]         	varchar(255) null,
								[DetAuxFol!2!Fecha]                	varchar(255) null,

								[ComprNal!3!UUID_CFDI]             	varchar(255) null,
								[ComprNal!3!MontoTotal]            	varchar(255) null,
								[ComprNal!3!RFC]                   	varchar(255) null,
								[ComprNal!3!MetPagoAux]            	varchar(255) null,
								[ComprNal!3!Moneda]                	varchar(255) null,
								[ComprNal!3!TipCamb]               	varchar(255) null,

								[ComprNalOtr!4!CFD_CBB_Serie]      	varchar(255) null,
								[ComprNalOtr!4!CFD_CBB_NumFol]     	varchar(255) null,
								[ComprNalOtr!4!MontoTotal]         	varchar(255) null,
								[ComprNalOtr!4!RFC]                	varchar(255) null,
								[ComprNalOtr!4!MetPagoAux]         	varchar(255) null,
								[ComprNalOtr!4!Moneda]             	varchar(255) null,
								[ComprNalOtr!4!TipCamb]            	varchar(255) null,

								[ComprExt!5!NumFactExt]            	varchar(255) null,
								[ComprExt!5!TaxID]                 	varchar(255) null,
								[ComprExt!5!MontoTotal]            	varchar(255) null,
								[ComprExt!5!MetPagoAux]         	varchar(255) null,
								[ComprExt!5!Moneda]                	varchar(255) null,
								[ComprExt!5!TipCamb]               	varchar(255) null
								)
----------------------------------------------------------------------------------------------------------------------
		
		INSERT INTO @AuxFolio  SELECT  1 AS Tag,
									   NULL AS Parent,
									   NULL AS 'RepAuxFol!1!',
									   NULL AS 'DetAuxFol!2!',
									   NULL AS 'DetAuxFol!2!NumUnIdenPol',
									   NULL AS 'DetAuxFol!2!Fecha',
									   ---------------------------------------------
									   NULL AS 'ComprNal!3!UUID_CFDI',
									   NULL AS 'ComprNal!3!MontoTotal',
									   NULL AS 'ComprNal!3!RFC',
									   NULL AS 'ComprNal!3!MetPagoAux',
									   NULL AS 'ComprNal!3!Moneda',
									   NULL AS 'ComprNal!3!TipCamb',
									   ---------------------------------------------
									   NULL AS 'ComprNalOtr!4!CFD_CBB_Serie',
									   NULL AS 'ComprNalOtr!4!CFD_CBB_NumFol',
									   NULL AS 'ComprNalOtr!4!MontoTotal',
									   NULL AS 'ComprNalOtr!4!RFC',
									   NULL AS 'ComprNalOtr!4!MetPagoAux',
									   NULL AS 'ComprNalOtr!4!Moneda',
									   NULL AS 'ComprNalOtr!4!TipCamb',
									   ---------------------------------------------
									   NULL AS 'ComprExt!5!NumFactExt',
									   NULL AS 'ComprExt!5!TaxID',
									   NULL AS 'ComprExt!5!MontoTotal',
									   NULL AS 'ComprExt!5!MetPagoAux',
									   NULL AS 'ComprExt!5!Moneda',
									   NULL AS 'ComprExt!5!TipCamb'
									   ---------------------------------------------
								UNION ALL
								SELECT 2 AS Tag,
									   1 AS Parent,
									   NULL,
									   NULL,
									   Poliza.NumUnIdenPol  as "NumUnIdenPol",
									   Poliza.Fecha			as "Fecha",
									   --Poliza.Concepto		as "Concepto",
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL,
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL
								  FROM #Polizas		as Poliza
								 UNION ALL
								SELECT 3 AS Tag,
									   2 AS Parent,
									   NULL,
									   NULL,
									   Poliza.NumUnIdenPol  as "NumUnIdenPol",
									   Poliza.Fecha			as "Fecha",
									   ---------------------------------------------
									   CompNal.UUID_CFDI										as "UUID_CFDI",
									   CAST(ROUND(CAST(CompNal.MontoTotal as money),2) as varchar(15))			as "MontoTotal",
									   CompNal.RFC												as "RFC",
									   REPLICATE('0',2-LEN(CompNal.FormaPago))+
									   CAST(CompNal.FormaPago as varchar(2))					as "MetPagoAux",
									   CompNal.Moneda											as "Moneda",
									   CAST(ROUND(CAST(CompNal.TipCamb as money),2) as varchar(15))			as "TipCamb",
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
									   --------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL
								  FROM #Polizas		as Poliza
							 LEFT JOIN #CompNal		as CompNal
									ON Poliza.ID = CompNal.ID							    
								 UNION ALL
								SELECT 4 AS Tag,
									   2 AS Parent,
									   NULL,
									   NULL,
									   Poliza.NumUnIdenPol  as "NumUnIdenPol",
									   Poliza.Fecha			as "Fecha",
									   --Poliza.Concepto		as "Concepto",
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL,
									   ---------------------------------------------
									   CompNalOtr.CFD_CBB_Serie								as "CFD_CBB_Serie",
									   CompNalOtr.CFD_CBB_NumFol							as "CFD_CBB_NumFol",
									   CAST(ROUND(CAST(CompNalOtr.MontoTotal as money),2) as varchar(15))	as "MontoTotal",
									   CompNalOtr.RFC										as "RFC",
									   CompNalOtr.FormaPago									as "MetPagoAux",
									   CompNalOtr.Moneda									as "Moneda",
									   CAST(ROUND(CAST(CompNalOtr.TipCamb as money),2) as varchar(15))		as "TipCamb",
									   --------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL
								  FROM #Polizas		as Poliza
							 LEFT JOIN #CompNalOtr	as CompNalOtr
									ON Poliza.ID = CompNalOtr.ID
								 UNION ALL
								SELECT 5 AS Tag,
									   2 AS Parent,
									   NULL,
									   NULL,
									   Poliza.NumUnIdenPol  as "NumUnIdenPol",
									   Poliza.Fecha			as "Fecha",
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL,
									   ---------------------------------------------
									   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
									   --------------------------------------------
									   CompExt.NumFactExt									as "NumFactExt",
									   CompExt.TaxID										as "TaxID",
									   CAST(ROUND(CAST(CompExt.MontoTotal as money),2) as varchar(15))		as "MontoTotal",
									   CompExt.FormaPago									as "MetPagoAux",
									   CompExt.Moneda										as "Moneda",
									   CAST(ROUND(CAST(CompExt.TipCamb as money),2) as varchar(15))		as "TipCamb"
								  FROM #Polizas		as Poliza
							 LEFT JOIN #CompExt	as CompExt
									ON Poliza.ID = CompExt.ID
----------------------------------------------------------------------------------------------------------------------
	  IF ((SELECT COUNT(*) FROM @AuxFolio) = 1)
	  BEGIN
	  	SET @OkRef = 'No existe información con los filtros seleccionados'
		SET @Ok = 1
		RETURN	  
	  END

		SELECT @vPoliza = (SELECT * 
							 FROM @AuxFolio 
						 ORDER BY [DetAuxFol!2!NumUnIdenPol], 
								  [Tag]
						  FOR XML EXPLICIT)
						  
		SELECT @vPoliza = REPLACE(@vPoliza,'<RepAuxFol>','')
		SELECT @vPoliza = REPLACE(@vPoliza,'</RepAuxFol>','')
		SELECT @vPoliza = REPLACE(@vPoliza,'<ComprNal/>','')
		SELECT @vPoliza = REPLACE(@vPoliza,'<ComprNalOtr/>','')
		SELECT @vPoliza = REPLACE(@vPoliza,'<ComprExt/>','')
----------------------------------------------------------------------------------------------------------------------

		SELECT @vPolizas = CAST((SELECT '1.2' as '@Version', 
										RFC as '@RFC', 
										REPLICATE('0',(2-LEN(Mes)))+CAST(Mes as varchar(2)) as '@Mes', 
										Anio as '@Anio', 
										TipoSolicitud as '@TipoSolicitud',
										NumOrden as '@NumOrden',
										NumTramite as '@NumTramite',
										CAST(@vPoliza as xml)
								   FROM #EncabezadoPolizas
									FOR XML PATH ('RepAuxFol')) as varchar(max))		
	
		SELECT @vPolizas = REPLACE(@vPolizas,'<RepAuxFol','<?xml version="1.0" encoding="windows-1252"?><RepAux:RepAuxFol xmlns:RepAux="www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarFolios" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarFolios http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarFolios/AuxiliarFolios_1_2.xsd"')
		SELECT @vPolizas = REPLACE(@vPolizas,'</RepAuxFol>','</RepAux:RepAuxFol>')
		SELECT @vPolizas = REPLACE(@vPolizas,'<DetAuxFol','<RepAux:DetAuxFol')
		SELECT @vPolizas = REPLACE(@vPolizas,'</DetAuxFol','</RepAux:DetAuxFol')
		SELECT @vPolizas = REPLACE(@vPolizas,'<ComprNal','<RepAux:ComprNal')
		SELECT @vPolizas = REPLACE(@vPolizas,'</ComprNal','</RepAux:ComprNal')
		SELECT @vPolizas = REPLACE(@vPolizas,'<ComprNalOtr','<RepAux:ComprNalOtr')
		SELECT @vPolizas = REPLACE(@vPolizas,'</ComprNalOtr','</RepAux:ComprNalOtr')
		SELECT @vPolizas = REPLACE(@vPolizas,'<ComprExt','<RepAux:ComprExt')
		SELECT @vPolizas = REPLACE(@vPolizas,'</ComprExt','</RepAux:ComprExt')
		--SELECT CAST(@vPolizas as xml)
		--SELECT @SchemaFolios = CAST(@vPolizas as XML)
		
		BEGIN TRY			
			--SELECT CAST(@vPolizas AS XML)
			SELECT @SchemaFolios = CAST(@vPolizas as XML)
			SELECT @xml = CAST(@SchemaFolios as varchar(max))
		END TRY
	    BEGIN CATCH
			SET @OkRef = ERROR_MESSAGE()
			SET @Ok = 1
			RETURN
		END CATCH
		
		SET @InfoTipo = 2
		EXEC spGenerarArchivoXmlPolizas @xml, @Estacion, @InfoTipo, @Ok OUTPUT, @OkRef OUTPUT
		
		IF @Ok IS NOT NULL
		BEGIN
			--SELECT @Ok, @OkRef
			RETURN
		END
	END
	
----------------------------------------------------------------------------------------------------------------------	
	IF @TipoArchivo = 3
	BEGIN
		
		SET @NivelCta = 'Mayor'
		   
		INSERT INTO #Balanza 
		EXEC spVerContBalanza @Empresa, @Ejercicio, @Periodo, @Periodo, 'SI', @NivelCta  
		
			IF((@InfoTipo = 1 AND @AnexoContaSAT = 2) OR @AnexoContaSAT = 3)
			BEGIN
				INSERT INTO #Cuenta(NumCta, DesCta, SaldoIni, SaldoFin)	
							SELECT DISTINCT Cta.Cuenta, Cta.Descripcion, ISNULL(B.Inicio,0) AS SaldoIni, ((ISNULL(B.Inicio,0) + ISNULL(B.Cargos,0)) - ISNULL(B.Abonos,0)) SaldoFin
							  FROM #Polizas P
							  JOIN ContD CD WITH(NOLOCK) ON CD.ID = P.ID
							  JOIN #Balanza B ON B.Cuenta = dbo.fnBuscaCtaMayor(CD.Cuenta)
							  JOIN Cta WITH(NOLOCK) ON Cta.Cuenta = B.Cuenta
			
				INSERT INTO #DetalleAux(Cuenta, Fecha, NumUnIdenPol, Concepto, Debe, Haber)
						  SELECT DISTINCT dbo.fnBuscaCtaMayor(Cta.CUENTA), CONVERT(varchar(10), P.Fecha, 126)+'Z', P.NumUnIdenPol, ISNULL(P.Concepto,'N/A'), ISNULL(ContD.Debe,'0.00') Debe, ISNULL(ContD.Haber,'0.00') Haber
							FROM #Polizas P
							JOIN ContD WITH(NOLOCK) ON P.ID = ContD.ID 
							JOIN Cta WITH(NOLOCK) ON ContD.Cuenta = Cta.Cuenta
		    END
				INSERT INTO #Cuenta(NumCta, DesCta, SaldoIni, SaldoFin)	
							SELECT DISTINCT Cta.Cuenta, Cta.Descripcion, ISNULL(B.Inicio,0) AS SaldoIni, ((ISNULL(B.Inicio,0) + ISNULL(B.Cargos,0)) - ISNULL(B.Abonos,0)) SaldoFin
							  FROM #Polizas P
							  JOIN ContD CD WITH(NOLOCK) ON CD.ID = P.ID
							  AND CD.Cuenta = P.Cuenta
							  JOIN #Balanza B ON B.Cuenta = dbo.fnBuscaCtaMayor(CD.Cuenta)
							  JOIN Cta WITH(NOLOCK) ON Cta.Cuenta = B.Cuenta
			
				INSERT INTO #DetalleAux(Cuenta, Fecha, NumUnIdenPol, Concepto, Debe, Haber)
						  SELECT DISTINCT dbo.fnBuscaCtaMayor(Cta.CUENTA), CONVERT(varchar(10), P.Fecha, 126)+'Z', P.NumUnIdenPol, ISNULL(P.Concepto,'N/A'), ISNULL(ContD.Debe,'0.00') Debe, ISNULL(ContD.Haber,'0.00') Haber
							FROM #Polizas P
							JOIN ContD WITH(NOLOCK) ON P.ID = ContD.ID 
							AND ContD.Cuenta = P.Cuenta
							JOIN Cta WITH(NOLOCK) ON ContD.Cuenta = Cta.Cuenta
		    
			--SELECT * FROM #Cuenta
			--SELECT * FROM #DetalleAux
			--SELECT * FROM #Polizas
			--RETURN
						
	
		INSERT INTO #AuxCuentas  SELECT  1 AS Tag,
								   NULL AS Parent,
								   NULL AS 'AuxiliarCtas!1!',
								   NULL AS 'AuxiliarCtas!2!',
								   NULL AS 'AuxiliarCtas!2!NumCta',
								   NULL AS 'AuxiliarCtas!2!DesCta',
								   NULL AS 'AuxiliarCtas!2!SaldoIni',
								   NULL AS 'AuxiliarCtas!2!SaldoFin',
								   ---------------------------------------------
								   NULL AS 'DetalleAux!3!Fecha',
								   NULL AS 'DetalleAux!3!NumUnIdenPol',
								   NULL AS 'DetalleAux!3!Concepto',
								   NULL AS 'DetalleAux!3!Debe',
								   NULL AS 'DetalleAux!3!Haber'
								   ---------------------------------------------
								  
							UNION ALL
							SELECT 2 AS Tag,
								   1 AS Parent,
								   NULL,
								   NULL,
								   Cuenta.NumCta    as "NumCta",
								   Cuenta.DesCta	as "DesCta",
								   Cuenta.SaldoIni	as "SaldoIni",
								   Cuenta.SaldoFin  as "SaldoFin",
								   ---------------------------------------------
								   NULL, NULL, NULL, NULL, NULL
								   ---------------------------------------------
								 
							  FROM #Cuenta as Cuenta 
							 UNION ALL
							SELECT 3 AS Tag,
								   2 AS Parent,
								   NULL,
								   NULL,
								   Cuenta.NumCta    as "NumCta",
								   Cuenta.DesCta	as "DesCta",
								   Cuenta.SaldoIni	as "SaldoIni",
								   Cuenta.SaldoFin  as "SaldoFin",
								   ---------------------------------------------
								   DetalleAux.Fecha		    as "Fecha",
								   DetalleAux.NumUnIdenPol	as "NumUnIdenPol",
								   DetalleAux.Concepto      as "Concepto",
								   DetalleAux.Debe	        as "Debe",
								   DetalleAux.Haber	        as "Haber"						   
								   ---------------------------------------------
								  
							  FROM #Cuenta	as Cuenta
							  JOIN #DetalleAux as DetalleAux
								ON Cuenta.NumCta = DetalleAux.cuenta
		---------------------------------------------------------------------------------------------------------------------
		
		  IF ((SELECT COUNT(*) FROM #AuxCuentas) = 1)
		  BEGIN
	  		SET @OkRef = 'No existe información con los filtros seleccionados'
			SET @Ok = 1
			RETURN	  
		  END
				
		SELECT @vPoliza = (
					   SELECT * 
						 FROM #AuxCuentas 
					 ORDER BY [AuxiliarCtas!2!NumCta],							  
							  [Tag]
					 FOR XML EXPLICIT)	
					 
		-------------------------------------------------------------------------------------------------------------------

		SELECT @vPolizas = CAST((SELECT [Version] as '@Version', 
										RFC as '@RFC', 
										REPLICATE('0',(2-LEN(Mes)))+CAST(Mes as varchar(2)) as '@Mes', 
										Anio as '@Anio', 
										TipoSolicitud as '@TipoSolicitud',
										NumOrden as '@NumOrden',
										NumTramite as '@NumTramite',
										CAST(@vPoliza as xml)
								   FROM #EncabezadoPolizas
									FOR XML PATH ('AuxiliarCtas')) as varchar(max))
----------------------------------------------------------------------------------------------------------------------
																																									    
		SELECT @vPolizas = REPLACE(@vPolizas,'<AuxiliarCtas Version','<?xml version="1.0" encoding="windows-1252"?><AuxiliarCtas xmlns:AuxiliarCtas="www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarCtas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarCtas http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/AuxiliarCtas/AuxiliarCtas_1_1.xsd" Version')
		SELECT @vPolizas = REPLACE(@vPolizas,'<AuxiliarCtas','<AuxiliarCtas:Cuenta')
		SELECT @vPolizas = REPLACE(@vPolizas,'</AuxiliarCtas','</AuxiliarCtas:Cuenta')	
		SELECT @vPolizas = REPLACE(@vPolizas,'<AuxiliarCtas:Cuenta xmlns:','<AuxiliarCtas:AuxiliarCtas xmlns:')
		SELECT @vPolizas = REPLACE(@vPolizas,'<AuxiliarCtas:Cuenta>','')
		SELECT @vPolizas = REPLACE(@vPolizas,'<AuxiliarCtas:Cuenta>','')
		SELECT @vPolizas = REPLACE(@vPolizas,'</AuxiliarCtas:Cuenta></AuxiliarCtas:Cuenta></AuxiliarCtas:Cuenta>','</AuxiliarCtas:Cuenta></AuxiliarCtas:AuxiliarCtas>')	
		SELECT @vPolizas = REPLACE(@vPolizas,'<Transaccion','<AuxiliarCtas:DetalleAux')
		SELECT @vPolizas = REPLACE(@vPolizas,'<DetalleAux','<AuxiliarCtas:DetalleAux')
		SELECT @vPolizas = REPLACE(@vPolizas,'</DetalleAux','</AuxiliarCtas:DetalleAux')	
----------------------------------------------------------------------------------------------------------------------
		--SELECT CAST(@vPolizas AS XML)
		--SELECT @SchemaCuentas = CAST(@vPolizas as XML)	
		BEGIN TRY			
			--SELECT CAST(@vPolizas AS XML)
			SELECT @SchemaCuentas = CAST(@vPolizas as XML)
			SELECT @xml = CAST(@SchemaCuentas as varchar(max))
		END TRY
		BEGIN CATCH
			SET @OkRef = ERROR_MESSAGE()
			SET @Ok = 1
			RETURN
		END CATCH
			
		SET @InfoTipo = 2
		EXEC spGenerarArchivoXmlPolizas @xml, @Estacion, @InfoTipo, @Ok OUTPUT, @OkRef OUTPUT
		
		IF @Ok IS NOT NULL
		BEGIN
			--SELECT @Ok, @OkRef
			RETURN
		END	
	END	
END
GO
