SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agent](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Empresa] [char](5) NOT NULL,
	[Mov] [char](20) NOT NULL,
	[MovID] [varchar](20) NULL,
	[FechaEmision] [datetime] NULL,
	[UltimoCambio] [datetime] NULL,
	[Concepto] [varchar](50) NULL,
	[Proyecto] [varchar](50) NULL,
	[UEN] [int] NULL,
	[Moneda] [char](10) NOT NULL,
	[TipoCambio] [float] NULL,
	[Usuario] [char](10) NULL,
	[Autorizacion] [char](10) NULL,
	[Referencia] [varchar](50) NULL,
	[DocFuente] [int] NULL,
	[Observaciones] [varchar](100) NULL,
	[Estatus] [char](15) NULL,
	[Situacion] [varchar](50) NULL,
	[SituacionFecha] [datetime] NULL,
	[SituacionUsuario] [varchar](10) NULL,
	[SituacionNota] [varchar](100) NULL,
	[Agente] [char](10) NOT NULL,
	[CtaDinero] [char](10) NULL,
	[FormaPago] [varchar](50) NULL,
	[Importe] [money] NULL,
	[Retencion] [money] NULL,
	[RetencionPorcentaje] [money] NULL,
	[Impuestos] [money] NULL,
	[ImpuestosPorcentaje] [money] NULL,
	[Saldo] [money] NULL,
	[AutoAjuste] [money] NULL,
	[OrigenTipo] [varchar](10) NULL,
	[Origen] [varchar](20) NULL,
	[OrigenID] [varchar](20) NULL,
	[Poliza] [varchar](20) NULL,
	[PolizaID] [varchar](20) NULL,
	[GenerarPoliza] [bit] NOT NULL,
	[ContID] [int] NULL,
	[Ejercicio] [int] NULL,
	[Periodo] [int] NULL,
	[FechaRegistro] [datetime] NULL,
	[FechaConclusion] [datetime] NULL,
	[FechaCancelacion] [datetime] NULL,
	[Sucursal] [int] NOT NULL,
	[Logico1] [bit] NOT NULL,
	[Logico2] [bit] NOT NULL,
	[Logico3] [bit] NOT NULL,
	[Logico4] [bit] NOT NULL,
	[Logico5] [bit] NOT NULL,
	[Logico6] [bit] NOT NULL,
	[Logico7] [bit] NOT NULL,
	[Logico8] [bit] NOT NULL,
	[Logico9] [bit] NOT NULL,
	[SincroID] [timestamp] NULL,
	[SincroC] [int] NULL,
	[SucursalOrigen] [int] NOT NULL,
	[SucursalDestino] [int] NULL,
 CONSTRAINT [priAgent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [GenerarPoliza]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico1]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico2]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico3]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico4]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico5]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico6]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico7]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico8]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [Logico9]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((1)) FOR [SincroC]
GO
ALTER TABLE [dbo].[Agent] ADD  DEFAULT ((0)) FOR [SucursalOrigen]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[tgAgentB] ON [dbo].[Agent]

FOR DELETE
AS BEGIN
DECLARE
@ID		int,
@Estatus 	char(15),
@Mensaje	char(255)
SELECT @ID = ID, @Estatus = Estatus FROM Deleted
IF @Estatus IS NOT NULL AND @Estatus NOT IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
SELECT @Mensaje = Descripcion FROM MensajeLista WITH(NOLOCK) WHERE Mensaje = 60090
RAISERROR (@Mensaje,16,-1)
END ELSE
EXEC spMovAlEliminar 'AGENT', @ID
END


GO
ALTER TABLE [dbo].[Agent] ENABLE TRIGGER [tgAgentB]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[tgAgentC] ON [dbo].[Agent]

FOR UPDATE
AS BEGIN
DECLARE
@Modulo 		char(5),
@Mov		char(20),
@Sucursal		int,
@ID			int,
@FechaInicio	datetime,
@Ahora 		datetime,
@FechaAnterior	datetime,
@EstatusNuevo 	char(15),
@EstatusAnterior 	char(15),
@SituacionNueva 	varchar(50),
@SituacionAnterior 	varchar(50),
@Usuario		char(10),
@Mensaje		char(255)
SELECT @Modulo = 'AGENT'
SELECT @EstatusAnterior = NULLIF(RTRIM(Estatus), ''), @SituacionAnterior = NULLIF(RTRIM(Situacion), '') FROM Deleted
SELECT @EstatusNuevo    = NULLIF(RTRIM(Estatus), ''), @SituacionNueva    = NULLIF(RTRIM(Situacion), ''), @Sucursal = Sucursal, @ID = ID, @Mov = NULLIF(RTRIM(Mov), ''), @Usuario = Usuario FROM Inserted
IF @EstatusNuevo <> @EstatusAnterior AND
((@EstatusNuevo = 'SINAFECTAR' AND @EstatusAnterior IN ('CONFIRMAR', 'PENDIENTE', 'CONCLUIDO', 'CANCELADO') AND @EstatusAnterior NOT IN (NULL, 'AFECTANDO')) OR
(@EstatusNuevo = 'CONFIRMAR'  AND @EstatusAnterior IN ('PENDIENTE', 'CONCLUIDO', 'CANCELADO')) OR
(@EstatusNuevo IN ('PENDIENTE', 'CONCLUIDO') AND @EstatusAnterior = 'CANCELADO'))
BEGIN
SELECT @Mensaje = Descripcion FROM MensajeLista WITH(NOLOCK) WHERE Mensaje = 60090
RAISERROR (@Mensaje,16,-1)
END
ELSE BEGIN
IF @EstatusNuevo NOT IN (NULL, 'AFECTANDO') AND (@EstatusAnterior <> @EstatusNuevo OR @SituacionAnterior <> @SituacionNueva)
BEGIN
IF @EstatusAnterior <> @EstatusNuevo AND (@EstatusAnterior <> 'AFECTANDO' OR @SituacionAnterior IS NULL OR @SituacionNueva IS NULL)
BEGIN
EXEC spMovSituacionNueva @Modulo, @Mov, @EstatusNuevo, @EstatusAnterior, @SituacionNueva OUTPUT, @ID = @ID
END
SELECT @Ahora = GETDATE(), @FechaInicio = NULL
SELECT @FechaInicio = MIN(FechaInicio), @FechaAnterior = MAX(FechaComenzo) FROM MovTiempo WITH(NOLOCK) WHERE Modulo = @Modulo AND ID = @ID
IF @FechaInicio IS NOT NULL AND @FechaAnterior IS NOT NULL
UPDATE MovTiempo WITH(ROWLOCK) SET FechaTermino = @Ahora WHERE Modulo = @Modulo AND ID = @ID AND FechaComenzo = @FechaAnterior
IF @FechaInicio IS NULL SELECT @FechaInicio = @Ahora
INSERT INTO MovTiempo (Modulo,  Sucursal,  ID,  Usuario,  FechaInicio,  FechaComenzo, Estatus,       Situacion)
VALUES (@Modulo, @Sucursal, @ID, @Usuario, @FechaInicio, @Ahora,       @EstatusNuevo, @SituacionNueva)
END
END
EXEC spMovAlActualizar @Modulo, @ID, @Mov, @EstatusNuevo, @EstatusAnterior, @SituacionNueva, @SituacionAnterior
IF @EstatusNuevo = 'CANCELADO' AND @EstatusAnterior IN ('PENDIENTE', 'CONCLUIDO') AND EXISTS(SELECT * FROM Version WITH(NOLOCK) WHERE Sucursal = 0 AND SincroContabilidadMatriz = 1)
UPDATE Agent WITH(ROWLOCK) SET GenerarPoliza = 1 WHERE ID = @ID AND GenerarPoliza = 0 AND ContID IS NOT NULL
END


GO
ALTER TABLE [dbo].[Agent] ENABLE TRIGGER [tgAgentC]
GO
