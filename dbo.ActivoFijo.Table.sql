SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivoFijo](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Empresa] [char](5) NOT NULL,
	[Mov] [char](20) NOT NULL,
	[MovID] [varchar](20) NULL,
	[FechaEmision] [datetime] NULL,
	[UltimoCambio] [datetime] NULL,
	[Proyecto] [varchar](50) NULL,
	[UEN] [int] NULL,
	[Usuario] [char](10) NULL,
	[Autorizacion] [char](10) NULL,
	[Concepto] [varchar](50) NULL,
	[Referencia] [varchar](50) NULL,
	[DocFuente] [int] NULL,
	[Observaciones] [varchar](100) NULL,
	[Estatus] [char](15) NULL,
	[Situacion] [varchar](50) NULL,
	[SituacionFecha] [datetime] NULL,
	[SituacionUsuario] [varchar](10) NULL,
	[SituacionNota] [varchar](100) NULL,
	[Moneda] [char](10) NULL,
	[TipoCambio] [float] NULL,
	[Condicion] [varchar](50) NULL,
	[Vencimiento] [datetime] NULL,
	[Proveedor] [char](10) NULL,
	[Importe] [money] NULL,
	[Impuestos] [money] NULL,
	[FormaPago] [varchar](50) NULL,
	[CtaDinero] [char](10) NULL,
	[Todo] [bit] NOT NULL,
	[Revaluar] [bit] NOT NULL,
	[ValorMercado] [bit] NOT NULL,
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
	[Personal] [varchar](10) NULL,
	[Espacio] [varchar](10) NULL,
	[ContUso] [varchar](20) NULL,
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
 CONSTRAINT [priActivoFijo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Todo]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Revaluar]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [ValorMercado]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [GenerarPoliza]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico1]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico2]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico3]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico4]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico5]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico6]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico7]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico8]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [Logico9]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((1)) FOR [SincroC]
GO
ALTER TABLE [dbo].[ActivoFijo] ADD  DEFAULT ((0)) FOR [SucursalOrigen]
GO
