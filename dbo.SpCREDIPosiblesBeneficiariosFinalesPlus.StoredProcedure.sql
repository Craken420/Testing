SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ========================================================================================================================================
-- NOMBRE           : SpCREDIPosiblesBeneficiariosFinalesPlus
-- AUTOR            : Hector Rafael Garcia Santoyo  
-- FECHA CREACION   : 30-07-2018
-- DESARROLLO       : RM1132A          
-- MODULO           : CREDITO    
-- DESCRIPCION      : Genera el reporte para la herramienta RM1132A <Posibles Beneficiarios Finales Plus>
-- EJEMPLO          : EXEC dbo.SpCREDIPosiblesBeneficiariosFinalesPlus @Opcion,@Spid,'@Saldo|@NumeroFacturas|@Meses|@ImporteMinimoAbonos|@MenorANDvActual|@MHDV|@MHDVXPeriodo|@ApoyoCobranza|@FechaD|@FechaA'
-- EJEMPLO          : EXEC dbo.SpCREDIPosiblesBeneficiariosFinalesPlus 1,18,'Todos|2|4|6000|0|0|7|Si|20180715|20180730'
-- ========================================================================================================================================
-- FECHA Y AUTOR MODIFICACION: 
-- ========================================================================================================================================

CREATE PROCEDURE [dbo].[SpCREDIPosiblesBeneficiariosFinalesPlus] (@Opcion int, @Spid int, @Argumentos varchar(max))
AS
BEGIN

  IF @Opcion = 1
  BEGIN
    DELETE FROM CREDIDTablaPasoConfiguracionBF
    WHERE Spid = @Spid
  END--FIN DEL IF @OPCION = 1


  IF @Opcion = 2
  BEGIN
    DECLARE @Saldo varchar(20),
            @NumeroFacturas int,
            @Meses int,
            @ImporteMinimoAbonos int,
            @MenorANDvActual int,
            @MHDV int,
            @MHDXPeriodo int,
            @ApoyoCobranza varchar(10),
            @FechaD datetime,
            @FechaA datetime

    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#Parametros')
      AND type = 'U')
      DROP TABLE #Parametros

    CREATE TABLE #Parametros (
      ID int IDENTITY (1, 1),
      Parametro varchar(20)
    )

    INSERT INTO #Parametros (Parametro)
      SELECT
        item
      FROM fnSplit(@Argumentos, '|')

    SELECT
      @Saldo = Parametro
    FROM #Parametros
    WHERE ID = 1

    SELECT
      @NumeroFacturas = CAST(Parametro AS int)
    FROM #Parametros
    WHERE ID = 2

    SELECT
      @Meses = CAST(Parametro AS int)
    FROM #Parametros
    WHERE ID = 3

    SELECT
      @ImporteMinimoAbonos = CAST(Parametro AS int)
    FROM #Parametros
    WHERE ID = 4

    SELECT
      @MenorANDvActual = CAST(Parametro AS int)
    FROM #Parametros
    WHERE ID = 5

    SELECT
      @MHDV = CAST(Parametro AS int)
    FROM #Parametros
    WHERE ID = 6

    SELECT
      @MHDXPeriodo = CAST(Parametro AS int) * 30
    FROM #Parametros
    WHERE ID = 7

    SELECT
      @ApoyoCobranza = CAST(Parametro AS varchar)
    FROM #Parametros
    WHERE ID = 8

    SELECT
      @FechaD = CAST(Parametro AS datetime)
    FROM #Parametros
    WHERE ID = 9

    SELECT
      @FechaA = CAST(Parametro AS datetime)
    FROM #Parametros
    WHERE ID = 10

    -- ========================================================================================================================================
    -- OBTENER LOS CLIENTES VALIDOS SEGUN LOS FILTROS DE MOVIMIENTO Y MESES
    -- ========================================================================================================================================  
    DECLARE @Dias int = @Meses * 30

    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#ClientesValidos')
      AND type = 'U')
      DROP TABLE #ClientesValidos

    SELECT
      CteFinal,
      COUNT(*) NumeroFacturas INTO #ClientesValidos
    FROM Venta V
    JOIN Cte_Final C
      ON C.ClienteF = V.CteFinal
    WHERE Mov IN ('FACTURA', 'CREDILANA')
    AND V.Estatus = 'CONCLUIDO'
    AND C.Estatus = 'ALTA'
    AND LEFT(CteFinal, 1) = 'F'
    AND DATEADD(dd, 0, DATEDIFF(dd, 0, V.FechaEmision)) BETWEEN DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE() - @Dias)) AND DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
    GROUP BY CteFinal
    HAVING COUNT(*) >= @NumeroFacturas

    CREATE CLUSTERED INDEX IndiceTemporal ON #ClientesValidos (CteFinal)


    -- ========================================================================================================================================
    -- OBTENER LA SUCURSAL EN DONDE EL CLIENTE FUE DADO DE ALTA POR PRIMERA VEZ
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#CteSucursal')
      AND type = 'U')
      DROP TABLE #CteSucursal


    CREATE TABLE #CteSucursal (
      Cliente varchar(10),
      SucursalVenta int
    )

    IF @NumeroFacturas > 0
    BEGIN
      INSERT INTO #CteSucursal (Cliente, SucursalVenta)
        SELECT DISTINCT
          X.CteFinal,
          X.SucursalVenta
        FROM (SELECT
          T.CteFinal,
          T.SucursalVenta
        FROM (SELECT DISTINCT
          V.CteFinal,
          SucursalVenta,
          ROW_NUMBER() OVER (PARTITION BY V.CteFinal ORDER BY FechaEmision) R
        FROM Cte_Final C
        JOIN #ClientesValidos CV
          ON CV.CteFinal = C.ClienteF
        LEFT JOIN Venta V
          ON C.ClienteF = V.CteFinal
        INNER JOIN VentaD D
          ON V.ID = D.ID
        LEFT JOIN MovBitacora M
          ON M.ID = V.ID
        WHERE C.ClienteF IS NOT NULL
        OR ((V.Mov = 'Analisis Credito'
        AND V.situacion = 'CONDICIONADO'
        AND D.Articulo LIKE 'VALR00%')
        OR (V.Mov = 'Solicitud Credito'
        AND V.MaviTipoVenta = 'Nuevo'
        AND V.EnviarA = 76
        AND M.Clave IN ('VTA00105', 'VTA00110', 'VTA00120', 'VTA00130', 'VTA00140')
        AND V.Estatus = 'CONCLUIDO'))) T
        WHERE T.R = 1
        AND LEFT(T.CteFinal, 1) = 'F') X
        GROUP BY X.CteFinal,
                 X.SucursalVenta
    END--FIN DEL IF @NumeroFacturas > 0

    ELSE
    BEGIN

      IF EXISTS (SELECT
          id
        FROM tempdb.sys.sysobjects
        WHERE id = OBJECT_ID('tempdb.dbo.#Faccero')
        AND type = 'U')
        DROP TABLE #Faccero

      SELECT DISTINCT
        V.CteFinal INTO #Faccero
      FROM Venta V
      JOIN #ClientesValidos CV
        ON CV.CteFinal = V.CteFinal
      LEFT JOIN (SELECT DISTINCT
        CteFinal,
        EnviarA
      FROM Venta
      WHERE Mov IN ('Factura', 'Credilana')
      AND Estatus = 'CONCLUIDO'
      AND EnviarA = 76
      AND LEFT(CteFinal, 1) = 'F') C--Obtener ventas con movimiento Factura/Credilana
        ON V.CteFinal = C.CteFinal
        AND C.EnviarA = V.EnviarA
      WHERE V.EnviarA = 76
      AND LEFT(V.CteFinal, 1) = 'F'
      AND C.CteFinal IS NULL


      INSERT INTO #CteSucursal (Cliente, SucursalVenta)
        SELECT
          X.CteFinal,
          X.SucursalVenta
        FROM (SELECT
          T.CteFinal,
          T.SucursalVenta
        FROM (SELECT DISTINCT
          V.CteFinal,
          V.SucursalVenta,
          ROW_NUMBER() OVER (PARTITION BY V.CteFinal ORDER BY V.FechaEmision) R
        FROM #Faccero CE
        INNER JOIN Venta V
          ON CE.CteFinal = V.Cliente
        INNER JOIN VentaD D
          ON V.ID = D.ID
        INNER JOIN MovBitacora M
          ON M.ID = V.ID
        LEFT JOIN Venta V1
          ON V1.Origen = V.Mov
          AND V1.OrigenID = V.MovID
          AND V.Mov = 'Solicitud Credito'
        WHERE CE.CteFinal IS NOT NULL
        AND ((V.Mov = 'Analisis Credito'
        AND V.situacion = 'CONDICIONADO'
        AND D.Articulo LIKE 'VALR00%'
        AND V.Estatus = 'PENDIENTE')
        OR (V.Mov = 'Solicitud Credito'
        AND V.MaviTipoVenta = 'Nuevo'
        AND V.EnviarA = 76
        AND M.Clave IN ('VTA00105', 'VTA00110', 'VTA00120', 'VTA00130', 'VTA00140')
        AND V.Estatus = 'CONCLUIDO'
        AND V1.Estatus NOT IN ('CANCELADO', 'SINAFECTAR')))) T
        WHERE T.R = 1
        AND LEFT(T.CteFinal, 1) = 'F') X
        GROUP BY X.CteFinal,
                 X.SucursalVenta

    END--FIN DEL ELSE EN CASO DE QUE EL NUMERO DE MOVIMIENTOS SOLICITADOS NO SEA MAYOR A 0

    CREATE CLUSTERED INDEX IndiceTemporal ON #CteSucursal (Cliente)


    -- ========================================================================================================================================
    -- OBTENER LOS DATOS SOBRE LAS COMPRAS DE LOS BF
    -- ======================================================================================================================================== 
    IF EXISTS (SELECT
        ID
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#Cxc')
      AND TYPE = 'U')
      DROP TABLE #Cxc

    CREATE TABLE #Cxc (
      id int NULL,
      fechaemision datetime NULL,
      Cliente varchar(15) NULL,
      ClienteEnviarA int NULL,
      Mov varchar(25) NULL,
      MovID varchar(25) NULL,
      Concepto varchar(50) NULL,
      PadreIDMAVI varchar(25) NULL,
      PadreMAVI varchar(25) NULL,
      Estatus varchar(25) NULL,
      Importe money NULL,
      Impuestos money NULL,
      Vencimiento datetime NULL,
      Saldo money NULL,
      ApoyoCobranza int NULL
    )

    IF @NumeroFacturas > 0
    BEGIN
      INSERT INTO #Cxc (id, fechaemision, Cliente, ClienteEnviarA, Mov, MovID, Concepto, PadreIDMAVI, PadreMAVI, Estatus, Importe, Impuestos, Vencimiento, Saldo, ApoyoCobranza)
        SELECT
          Id,
          FechaEmision,
          Cxc.CteFinal,
          ClienteEnviarA,
          Mov,
          MovId,
          Concepto,
          PadreIDMAVI,
          PadreMAVI,
          Cxc.Estatus,
          Importe,
          Impuestos,
          Vencimiento,
          Saldo,
          CobroCteFinal
        FROM Cxc
        JOIN #ClientesValidos CV
          ON CV.CteFinal = Cxc.CteFinal
        WHERE LEFT(Cxc.CteFinal, 1) = 'F'
        AND ClienteEnviarA = 76
    END--FIN DEL IF @NumeroFacturas > 0

    ELSE
    BEGIN
      INSERT INTO #Cxc (id, fechaemision, Cliente, ClienteEnviarA, Mov, MovID, Concepto, PadreIDMAVI, PadreMAVI, Estatus, Importe, Impuestos, Vencimiento, Saldo, ApoyoCobranza)
        SELECT DISTINCT
          c.id,
          c.fechaemision,
          c.CteFinal,
          c.EnviarA,
          c.Mov,
          c.MovID,
          c.Concepto,
          c.Mov,
          c.MovID,
          C.Estatus,
          C.Importe,
          C.Impuestos,
          C.Vencimiento,
          c.Saldo,
          NULL
        FROM Venta C
        JOIN #ClientesValidos CV
          ON CV.CteFinal = C.CteFinal
        WHERE LEFT(C.CteFinal, 1) = 'F'
        AND EnviarA = 76
    END--FIN DEL ELSE EN CASO DE QUE EL NUMERO DE MOVIMIENTOS SOLICITADOS NO SEA MAYOR A 0

    CREATE NONCLUSTERED INDEX MovEstatus ON #Cxc (Mov, Estatus)
    CREATE NONCLUSTERED INDEX Fecha ON #Cxc (fechaemision)

    -- ========================================================================================================================================
    -- OBTENER SALDO VENCIDO
    -- ========================================================================================================================================  
    IF EXISTS (SELECT
        ID
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#SaldoVen')
      AND TYPE = 'U')
      DROP TABLE #SaldoVen


    SELECT
      Cliente,
      SaldoVencido INTO #SaldoVen
    FROM (SELECT
      C2.Cliente,
      SUM(C2.Saldo) AS SaldoVencido
    FROM #Cxc c
    JOIN #Cxc c2
      ON c.Mov = c2.PadreMAVI
      AND c.MovID = c2.PadreIDMAVI
    WHERE LEFT(C2.Cliente, 1) = 'F'
    AND C.Mov IN ('FACTURA', 'CREDILANA')
    AND C2.Estatus = 'PENDIENTE'
    AND C2.ClienteEnviarA = 76
    AND DATEADD(dd, 0, DATEDIFF(dd, 0, C2.Vencimiento)) <= DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
    GROUP BY C2.Cliente) SubQuery

    CREATE CLUSTERED INDEX IndiceTemporal ON #SaldoVen (Cliente)

    -- ========================================================================================================================================
    -- OBTENER DATOS GENERALES DEL CLIENTE
    -- ========================================================================================================================================         
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#CteDatos')
      AND type = 'U')
      DROP TABLE #CteDatos


    CREATE TABLE #CteDatos (
      Cliente varchar(10) NULL,
      Nombre varchar(150) NULL,
      Domicilio varchar(200) NULL,
      Colonia varchar(100) NULL,
      CodigoPostal varchar(15) NULL,
      Poblacion varchar(100) NULL,
      Estado varchar(30) NULL,
      LimiteCredito money NULL,
      DomValidado varchar(10) NULL,
      TipoBF varchar(10) NULL
    )

    INSERT INTO #CteDatos (Cliente, Nombre, Domicilio, Colonia, CodigoPostal, Poblacion, Estado, LimiteCredito, DomValidado, TipoBF)
      SELECT
        Cte_Final.ClienteF,
        Nombre = Nombre + ' ' + ApellidoPaterno + ' ' + ApellidoMaterno,
        Domicilio =
                   CASE
                     WHEN DireccionNumeroInt IS NULL OR
                       DireccionNumeroInt = '' THEN UPPER(Direccion + ' ' + DireccionNumero)
                     ELSE UPPER(Direccion + ' ' + DireccionNumero + ' Interior ' + DireccionNumeroInt)
                   END,
        Colonia,
        CodigoPostal,
        Poblacion,
        Estado,
        Cred.LimiteCredito,
        DomValidado =
                     CASE Cte_Final.ValidacionTel
                       WHEN 1 THEN 'Positivo'
                       ELSE 'Negativo'
                     END,
        Cred.TipoBF
      FROM Cte_Final
      JOIN VTASCTipoBF Cred
        ON Cred.IdTipoBF = Cte_Final.IdTipoBF
      WHERE LEFT(Cte_Final.ClienteF, 1) = 'F'
      AND Cte_Final.Estatus = 'ALTA'

    CREATE CLUSTERED INDEX IndiceTemporal ON #CteDatos (Cliente)

    -- ========================================================================================================================================
    -- OBTENER CUENTAS DIMAS ASOCIADAS A UN BENEFICIARIO FINAL
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#CuentaDima')
      AND type = 'U')
      DROP TABLE #CuentaDima

    SELECT
      ClienteF,
      C.Cliente INTO #CuentaDima
    FROM (SELECT
      ClienteF,
      Nombre = ApellidoPaterno + ' ' + ApellidoMaterno + ' ' + Nombre,
      RFC
    FROM Cte_Final
    WHERE Estatus = 'ALTA') CteFinal
    JOIN Cte C
      ON C.Nombre = CteFinal.Nombre
      AND SUBSTRING(C.RFC, 1, 10) = SUBSTRING(CteFinal.RFC, 1, 10)
      AND LEFT(C.Cliente, 1) = 'C'
    JOIN (SELECT DISTINCT
      Cliente
    FROM Venta
    WHERE Mov IN ('Factura', 'Credilana')
    AND Estatus = 'CONCLUIDO'
    AND EnviarA = 76) Dimas
      ON Dimas.Cliente = C.Cliente

    -- ========================================================================================================================================
    -- OBTENER SALDOS
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#Saldos')
      AND type = 'U')
      DROP TABLE #Saldos

    SELECT
      Cliente,
      SaldoCredilana,
      SaldoFactura,
      SaldoTotal = SaldoCredilana + SaldoFactura INTO #Saldos
    FROM (SELECT
      Cliente,
      SUM(ISNULL(SaldoCredilana, 0)) AS SaldoCredilana,
      SUM(ISNULL(SaldoFactura, 0)) AS SaldoFactura
    FROM (SELECT
      C2.Cliente AS Cliente,
      SaldoCredilana =
                      CASE C.Mov
                        WHEN 'CREDILANA' THEN SUM(C2.Saldo)
                      END,
      SaldoFactura =
                    CASE C.Mov
                      WHEN 'FACTURA' THEN SUM(C2.Saldo)
                    END
    FROM #Cxc c
    JOIN #Cxc c2
      ON c.Mov = c2.PadreMAVI
      AND c.MovID = c2.PadreIDMAVI
    WHERE LEFT(C2.Cliente, 1) = 'F'
    AND C.Mov IN ('CREDILANA', 'FACTURA')
    AND C2.Estatus = 'PENDIENTE'
    GROUP BY C2.Cliente,
             C.Mov) t
    GROUP BY Cliente) tt

    CREATE CLUSTERED INDEX IndiceTemporal ON #Saldos (Cliente)

    -- ========================================================================================================================================
    -- OBTENER ULTIMA FECHA DE COMPRA
    -- ========================================================================================================================================  
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#FechaUltimaCompra')
      AND type = 'U')
      DROP TABLE #FechaUltimaCompra

    SELECT
      Cliente,
      FechaUltimaCompra,
      Mov INTO #FechaUltimaCompra
    FROM (SELECT
      CteFinal AS Cliente,
      FechaEmision AS FechaUltimaCompra,
      Mov,
      ROW_NUMBER() OVER (PARTITION BY CteFinal ORDER BY FechaEmision DESC) AS Fila
    FROM Venta
    WHERE LEFT(CteFinal, 1) = 'F'
    AND Mov IN ('FACTURA', 'CREDILANA')) t
    WHERE Fila = 1

    CREATE CLUSTERED INDEX IndiceTemporal ON #FechaUltimaCompra (Cliente)

    -- ========================================================================================================================================
    -- OBTENER ULTIMA FECHA DE PAGO
    -- ========================================================================================================================================  
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#FechaUltimoPago')
      AND type = 'U')
      DROP TABLE #FechaUltimoPago

    SELECT
      Cliente,
      FechaUltimoPago INTO #FechaUltimoPago
    FROM (SELECT
      c2.CteFinal AS Cliente,
      C.FechaEmision AS FechaUltimoPago,
      ROW_NUMBER() OVER (PARTITION BY c2.CteFinal ORDER BY c.fechaemision DESC) fila
    FROM CXC c
    INNER JOIN cxcd d
      ON c.id = d.id
    INNER JOIN cxc c2
      ON d.Aplica = c2.Mov
      AND d.AplicaID = c2.MovID
    INNER JOIN Cte_Final Cte
      ON Cte.ClienteF = c2.CteFinal
    WHERE c2.ClienteEnviarA = 76
    AND c.Mov = 'Cobro'
    AND c.Estatus = 'concluido'
    AND LEFT(C2.CteFinal, 1) = 'F'
    AND Cte.Estatus = 'ALTA') UltimoPago
    WHERE UltimoPago.fila = 1

    CREATE CLUSTERED INDEX IndiceTemporal ON #FechaUltimoPago (Cliente)

    -- ========================================================================================================================================
    -- OBTENER MONTOS
    -- ========================================================================================================================================    
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#Montos')
      AND type = 'U')
      DROP TABLE #Montos

    SELECT
      SUM(D.Importe) AS Monto,
      C.Cliente,
      MAX(C1.FechaEmision) FechaEmi INTO #Montos
    FROM #Cxc C
    INNER JOIN CxcD D
      ON D.Aplica = C.Mov
      AND C.MovID = D.AplicaID
    INNER JOIN Cxc C1
      ON C1.ID = D.ID
      AND C.ClienteEnviarA = 76
      AND C.Mov = 'Documento'
      AND C1.Mov IN ('Cobro')
      AND C1.Estatus = 'CONCLUIDO'
    GROUP BY C.cliente

    CREATE CLUSTERED INDEX IndiceTemporal ON #Montos (Cliente)

    -- ========================================================================================================================================
    -- OBTENER MAXIMO HISTORICO DE DIAS VENCIDOS
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#MHDV')
      AND type = 'U')
      DROP TABLE #MHDV

    SELECT
      Cliente AS Cliente,
      MHDV = MAX(ISNULL(M.MaxDiasVencidosMAVI, 0)) INTO #MHDV
    FROM #Cxc C
    JOIN CxcMavi M
      ON M.ID = C.ID
    WHERE ((C.Mov IN ('Factura', 'Credilana')
    OR (C.Mov = 'Nota Cargo'
    AND C.Concepto = 'MONEDERO ELECTRONICO')))
    AND LEFT(Cliente, 1) = 'F'
    AND ClienteEnviarA = 76
    GROUP BY Cliente

    CREATE CLUSTERED INDEX IndiceTemporal ON #MHDV (Cliente)

    -- ========================================================================================================================================
    -- OBTENER LOS DIAS VENCIDOS
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#DV')
      AND type = 'U')
      DROP TABLE #DV

    SELECT
      C1.Cliente AS Cliente,
      DV = MAX(ISNULL(M.DiasVencActMAVI, 0)),
      MAX(M.DiasInacActMAVI) MaxDiasInactivosMAVI INTO #DV
    FROM #Cxc C
    JOIN CxcMavi M
      ON M.ID = C.ID
    JOIN #Cxc C1
      ON C.Mov = C1.PAdremavi
      AND C1.PAdreidmavi = C.Movid
    WHERE (C.Mov IN ('Factura', 'Credilana')
    AND C1.Estatus = 'PENDIENTE')
    OR (C.Mov = 'Nota Cargo'
    AND C.Estatus = 'PENDIENTE')
    GROUP BY C1.Cliente

    CREATE CLUSTERED INDEX IndiceTemporal ON #DV (Cliente)

    -- ========================================================================================================================================
    -- OBTENER EL MAXIMO HISTORICO POR PERIODO
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#MHDVXPeriodo')
      AND type = 'U')
      DROP TABLE #MHDVXPeriodo

    IF EXISTS (SELECT
        ID
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#finalV')
      AND type = 'U')
      DROP TABLE #finalV

    DECLARE @FechaDH datetime,
            @FechaAH datetime

    SELECT
      @FechaDH = DATEADD(DD, 0, DATEADD(dd, 0, DATEDIFF(dd, @MHDXPeriodo, GETDATE()))),
      @FechaAH = DATEADD(DD, 0, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))


    SET @FechaDH = DATEADD(DD, @Dias, @FechaDH)
    SET @FechaDH = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FechaDH), 0)

    SELECT
      *,

      ROW_NUMBER() OVER (PARTITION BY Movid ORDER BY Vencimiento) r INTO #FinalV
    FROM (SELECT
      C.Mov,
      C.MovID,
      C.Saldo,
      C.Vencimiento,
      C.Estatus,
      D.Importe,
      C1.Mov cobro,
      C1.MovID cobroid,
      C1.FechaEmision,
      C.CteFinal,
      C1.Estatus Estcobro,
      C.Cliente,
      Total = C.Importe + C.Impuestos,
      RestDias =
                CASE
                  WHEN C1.FechaEmision <= C.Vencimiento AND
                    C.Estatus = 'CONCLUIDO' THEN 0
                  WHEN C.Estatus = 'PENDIENTE' AND
                    C1.FechaEmision <= C.Vencimiento THEN DATEDIFF(DD, C.Vencimiento, GETDATE())
                  WHEN C.Estatus = 'PENDIENTE' AND
                    C1.FechaEmision >= C.Vencimiento THEN DATEDIFF(DD, C.Vencimiento, GETDATE())
                  WHEN C.Estatus = 'CONCLUIDO' AND
                    C1.FechaEmision > C.Vencimiento THEN DATEDIFF(DD, C.Vencimiento, ISNULL(C1.FechaEmision, GETDATE()))
                  ELSE DATEDIFF(DD, C.Vencimiento, GETDATE())
                END,
      Diastrans = DATEDIFF(DD, C.Vencimiento, CASE
        WHEN DAY(C.Vencimiento) = 2 THEN DATEADD(DD, 15, C.Vencimiento)
        ELSE DATEADD(DD, -15, DATEADD(MM, 1, C.Vencimiento))
      END),
      Monedero =
                CASE
                  WHEN Con.DA = 1 THEN P.Abono / con.DANumeroDocumentos
                  ELSE 0
                END,
      Ban =
           CASE
             WHEN C1.FechaEmision > C.Vencimiento THEN 'V'
             ELSE 'P'
           END
    FROM Cxc C 
    LEFT JOIN CxcD D 
      ON C.Mov = D.Aplica
      AND C.MovID = D.AplicaID
    LEFT JOIN Cxc C1 
      ON D.ID = C1.ID
    LEFT JOIN Venta V 
      ON V.Mov = C.PadreMAVI
      AND V.MovID = C.PadreIDMAVI
    LEFT JOIN AuxiliarP P 
      ON P.Mov = C.PadreMAVI
      AND P.MovID = C.PadreIDMAVI
      AND P.Abono IS NOT NULL
    LEFT JOIN Condicion con 
      ON Con.Condicion = V.Condicion
    WHERE (C.Mov = 'Documento'
    OR (C.Mov = 'Nota Cargo'
    AND C.Concepto IN ('CANC COBRO FACTURA', 'CANC COBRO CRED Y PP', 'CANC COBRO BONIF CRED Y PP', 'CANC COBRO BONIF MENUDEO')
    AND C.ClienteEnviarA = 76))
    AND C.ClienteEnviarA = 76
    AND (C1.FechaEmision BETWEEN @FechaDH AND @FechaAH
    OR C1.FechaEmision IS NULL)
    AND (C1.Estatus NOT IN ('CANCELADO', 'SINAFECTAR')
    OR C1.Estatus IS NULL)
    AND C1.Mov NOT IN ('Ajuste')
    AND C.Vencimiento <= DATEADD(DD, 0, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
    OR ((C.Mov = 'Documento'
    AND C.Estatus = 'PENDIENTE'
    AND C.ClienteEnviarA = 76
    AND C.Vencimiento <= DATEADD(DD, 0, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
    AND C.ClienteEnviarA = 76)
    OR (C.Mov = 'Nota Cargo'
    AND C.Concepto IN ('CANC COBRO FACTURA', 'CANC COBRO CRED Y PP', 'CANC COBRO BONIF CRED Y PP', 'CANC COBRO BONIF MENUDEO')
    AND C.ClienteEnviarA = 76
    AND C.Vencimiento <= DATEADD(DD, 0, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
    AND C.ClienteEnviarA = 76
    AND C.CteFinal IS NOT NULL))
    AND C.CteFinal IS NOT NULL) T

    CREATE TABLE #MHDVXPeriodo (
      CteFinal varchar(10) NULL,
      MHDVXP int NULL,
      Cliente varchar(200) NULL,
      R int IDENTITY (1, 1)
    )

    INSERT INTO #MHDVXPeriodo (MHDVXP, CteFinal, Cliente)

      SELECT
        MAX(Resul) MHDV90,
        Ctefinal,
        Cliente
      FROM (SELECT
        Resul =
               CASE
                 WHEN ABS(RestDias) <= ABS(Diastrans) THEN ROUND(RestDias * ((CASE
                     WHEN Estatus = 'PENDIENTE' THEN Saldo
                     ELSE SUM(Importe)
                   END / (CASE
                     WHEN Total = Monedero THEN 1
                     ELSE Total - ISNULL(Monedero, 0)
                   END))), 0)
                 ELSE ROUND(ABS(RestDias) - ABS(Diastrans) + (ABS(Diastrans) * (CASE
                     WHEN Estatus = 'PENDIENTE' THEN Saldo
                     ELSE SUM(Importe)
                   END / (CASE
                     WHEN Total = Monedero THEN 1
                     ELSE Total - ISNULL(Monedero, 0)
                   END))), 0)
               END,
        Mov,
        MovID,
        saldo,
        Vencimiento,
        Estatus,
        CteFinal,
        Estcobro,
        Cliente,
        Total,
        RestDias,
        Diastrans
      FROM #FinalV R
      WHERE CteFinal IS NOT NULL
      AND CteFinal <> '0'
      GROUP BY Mov,
               MovID,
               Saldo,
               Vencimiento,
               Estatus,
               CteFinal,
               Estcobro,
               Cliente,
               Total,
               RestDias,
               Diastrans,
               Monedero) T
      GROUP BY CteFinal,
               T.Cliente


    DECLARE @min int,
            @max int,
            @ctefinal varchar(10),
            @cliente varchar(200),
            @MHDVP int,
            @idmax int

    DECLARE @ctefinaltab AS TABLE (
      ID int IDENTITY (1, 1),
      Ctefinal varchar(10)
    )
    INSERT INTO @ctefinaltab
      SELECT
        CteFinal
      FROM #MHDVXPeriodo
      WHERE CteFinal IS NOT NULL
      AND CteFinal <> '0'
      GROUP BY CteFinal
      HAVING COUNT(Ctefinal) > 1


    SELECT
      @min = MIN(ID),
      @max = MAX(ID)
    FROM @ctefinaltab
    WHILE @min <= @max
    BEGIN

      SELECT
        @ctefinal = Ctefinal
      FROM @ctefinaltab
      WHERE ID = @min
      SELECT
        @MHDVP = MAX(MHDVXP),
        @idmax = MIN(R)
      FROM #MHDVXPeriodo
      WHERE CteFinal = @ctefinal
      SET @cliente = (SELECT
        STUFF((SELECT
          ', ' + T.Cliente
        FROM #MHDVXPeriodo T
        WHERE CteFinal = @ctefinal
        FOR xml PATH (''))
        , 1, 2, ''))



      UPDATE #MHDVXPeriodo
      SET Cliente = @cliente,
          MHDVXP = @MHDVP
      WHERE CteFinal = @ctefinal
      DELETE #MHDVXPeriodo
      WHERE CteFinal = @ctefinal
        AND R <> @idmax

      SET @min = @min + 1
    END

    /*
  
	Calculo de campo en espera
	*/

    CREATE CLUSTERED INDEX IndiceTemporal ON #MHDVXPeriodo (Ctefinal)

    -- ========================================================================================================================================
    -- OBTENER COMPRAS POR PERIODO
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#ComprasxPeriodo')
      AND type = 'U')
      DROP TABLE #ComprasxPeriodo

    SELECT
      Cliente,
      SUM(Importe + Impuestos) AS Monto INTO #ComprasxPeriodo
    FROM (SELECT DISTINCT
      C2.Cliente,
      C.Mov,
      C.MovID,
      C.Importe,
      C.Impuestos
    FROM #Cxc c
    JOIN #Cxc c2
      ON c.Mov = c2.PadreMAVI
      AND c.MovID = c2.PadreIDMAVI
    WHERE LEFT(C2.Cliente, 1) = 'F'
    AND C.Mov IN ('CREDILANA', 'FACTURA')
    AND C.Estatus = 'CONCLUIDO'
    AND DATEADD(dd, 0, DATEDIFF(dd, 0, C.FechaEmision)) BETWEEN @FechaD AND @FechaA) t
    GROUP BY Cliente

    CREATE CLUSTERED INDEX IndiceTemporal ON #ComprasxPeriodo (Cliente)


    -- ========================================================================================================================================
    -- ALMACENAR REPORTE
    -- ========================================================================================================================================
    IF EXISTS (SELECT
        id
      FROM tempdb.sys.sysobjects
      WHERE id = OBJECT_ID('tempdb.dbo.#Reporte')
      AND type = 'U')
      DROP TABLE #Reporte

    SELECT
      Suc.SucursalVenta,
      Dat.Cliente,
      Dat.TipoBF,
      Nombre = UPPER(Dat.Nombre),
      Dat.Domicilio,
      Dat.Colonia,
      Dat.CodigoPostal,
      Dat.Poblacion,
      Dat.Estado,
      CtaDima =
               CASE
                 WHEN MXP.Cliente IS NULL THEN CDima.Cliente
                 ELSE MXP.Cliente
               END,
      DV = ISNULL(DV.DV, 0),
      MHDV = ISNULL(MHDV.MHDV, 0),
      MHDVPeriodo = ISNULL(MXP.MHDVXP, 0),--En espera de ser calculado
      ComprasPeriodo = ISNULL(CP.Monto, 0),
      UCompra.FechaUltimaCompra,
      Dat.LimiteCredito,
      Monto = ISNULL(Mon.Monto, 0),
      UPago.FechaUltimoPago,
      SaldoFactura = ISNULL(Sal.SaldoFactura, 0),
      SaldoCredilana = ISNULL(Sal.SaldoCredilana, 0),
      SaldoTotal = ISNULL(Sal.SaldoTotal, 0),
      SaldoVencido = ISNULL(SdoVen.SaldoVencido, 0),
      PorcentajeSaldoVencido = ISNULL((CAST(SdoVen.SaldoVencido AS float) / CAST(Sal.SaldoTotal AS float) * 100), 0),
      ApoyoCobranza =
                     CASE
                       WHEN ApoyoCobranza.Cliente IS NOT NULL THEN 'Si'
                       ELSE ''
                     END,
      Dat.DomValidado INTO #Reporte
    FROM #CteDatos Dat
    LEFT JOIN #CteSucursal Suc
      ON Dat.Cliente = Suc.Cliente
    LEFT JOIN #CuentaDima CDima
      ON Dat.Cliente = CDima.ClienteF
    LEFT JOIN #Saldos Sal
      ON Dat.Cliente = Sal.Cliente
    LEFT JOIN #FechaUltimaCompra UCompra
      ON Dat.Cliente = UCompra.Cliente
    LEFT JOIN #FechaUltimoPago UPago
      ON Dat.Cliente = UPago.Cliente
    LEFT JOIN #Montos Mon
      ON Dat.Cliente = Mon.Cliente
    LEFT JOIN #MHDV MHDV
      ON Dat.Cliente = MHDV.Cliente
    LEFT JOIN #DV DV
      ON Dat.Cliente = DV.Cliente
    LEFT JOIN #MHDVXPeriodo MXP
      ON Dat.Cliente = MXP.Ctefinal
    LEFT JOIN (SELECT DISTINCT
      Cliente
    FROM #Cxc
    WHERE ApoyoCobranza IS NOT NULL
    AND ApoyoCobranza NOT IN (3, 6)) ApoyoCobranza
      ON Dat.Cliente = ApoyoCobranza.Cliente
    LEFT JOIN #SaldoVen SdoVen
      ON Dat.Cliente = SdoVen.Cliente
    LEFT JOIN #ComprasxPeriodo CP
      ON Dat.Cliente = CP.Cliente

    -- ========================================================================================================================================
    -- GENERACION DE FILTROS PARA CONSULTAS DINAMICAS
    -- ========================================================================================================================================
    DECLARE @FiltroSaldo varchar(200),
            @FiltroMinimoAbonos varchar(200),
            @FiltroMenorANDvActual varchar(200),
            @FiltroMHDV varchar(200),
            @FiltroMHDXPeriodo varchar(200),
            @FiltroApoyoCobranza varchar(200),
            @IdConsulta int,
            @Valor int

    SET @FiltroSaldo =
                      CASE
                        WHEN @Saldo = 'Con Saldo' THEN ' AND SaldoTotal <> 0 '
                        WHEN @Saldo = 'Sin Saldo' THEN ' AND SaldoTotal = 0 '
                        ELSE ' '
                      END

    SET @FiltroMinimoAbonos =
                             CASE
                               WHEN @ImporteMinimoAbonos >= 0 THEN ' AND Monto >= ' + CAST(@ImporteMinimoAbonos AS varchar(30)) + ' '
                               ELSE ' '
                             END


    SET @FiltroMenorANDvActual =
                                CASE
                                  WHEN @MenorANDvActual >= 0 THEN ' AND DV <= ' + CAST(@MenorANDvActual AS varchar(30)) + ' '
                                  ELSE ' '
                                END


    SET @FiltroMHDV =
                     CASE
                       WHEN @MHDV >= 0 THEN ' AND MHDV <= ' + CAST(@MHDV AS varchar(30)) + ' '
                       ELSE ' '
                     END


    SET @FiltroApoyoCobranza =
                              CASE @ApoyoCobranza
                                WHEN 'Si' THEN ' AND  ApoyoCobranza = ''Si'' '
                                WHEN 'No' THEN ' AND ApoyoCobranza = '''' '
                                ELSE ' '
                              END


    -- ========================================================================================================================================
    -- OBTENER EL NUMERO DE REGISTROS DEL REPORTE
    -- ========================================================================================================================================

    DECLARE @NumeroRegistros TABLE (
      cantidad int
    )

    DECLARE @CantidadRegistros int

    INSERT INTO @NumeroRegistros EXEC ('SELECT COUNT(*)
     FROM #Reporte R
	 WHERE 1=1' + @FiltroSaldo + @FiltroMinimoAbonos + @FiltroMenorANDvActual + @FiltroMHDV + @FiltroApoyoCobranza)

    SELECT
      @CantidadRegistros = cantidad
    FROM @NumeroRegistros

    -- ========================================================================================================================================
    -- GENERAR REPORTE
    -- ========================================================================================================================================	
    EXEC (
    'SELECT R.*, NumeroRegistros = ' + @CantidadRegistros + '
	 FROM #Reporte R
	 WHERE 1=1' + @FiltroSaldo + @FiltroMinimoAbonos + @FiltroMenorANDvActual + @FiltroMHDV + @FiltroApoyoCobranza +
    ' ORDER BY R.Cliente')

  END--FIN DEL IF @OPCION = 2

  -- ========================================================================================================================================
  -- DESTRUCCION DE TABLAS TEMPORALES
  -- ========================================================================================================================================
  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Parametros')
    AND type = 'U')
    DROP TABLE #Parametros

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#CteSucursal')
    AND type = 'U')
    DROP TABLE #CteSucursal

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#CteDatos')
    AND type = 'U')
    DROP TABLE #CteDatos

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Faccero')
    AND type = 'U')
    DROP TABLE #Faccero

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Cxc')
    AND TYPE = 'U')
    DROP TABLE #Cxc

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#SaldoVen')
    AND TYPE = 'U')
    DROP TABLE #SaldoVen

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#CuentaDima')
    AND type = 'U')
    DROP TABLE #CuentaDima

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Saldos')
    AND type = 'U')
    DROP TABLE #Saldos

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#FechaUltimaCompra')
    AND type = 'U')
    DROP TABLE #FechaUltimaCompra

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#FechaUltimoPago')
    AND type = 'U')
    DROP TABLE #FechaUltimoPago

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Montos')
    AND type = 'U')
    DROP TABLE #Montos

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#MHDV')
    AND type = 'U')
    DROP TABLE #MHDV

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#DV')
    AND type = 'U')
    DROP TABLE #DV

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#ComprasxPeriodo')
    AND type = 'U')
    DROP TABLE #ComprasxPeriodo

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#MHDVXPeriodo')
    AND type = 'U')
    DROP TABLE #MHDVXPeriodo

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#Reporte')
    AND type = 'U')
    DROP TABLE #Reporte

  IF EXISTS (SELECT
      id
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#ClientesValidos')
    AND type = 'U')
    DROP TABLE #ClientesValidos

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#finalV')
    AND type = 'U')
    DROP TABLE #finalV


END--FIN DEL PROCEDIMIENTO ALMACENADO
GO
