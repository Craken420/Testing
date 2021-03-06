SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivoFijoD](
	[ID] [int] NOT NULL,
	[Renglon] [float] NOT NULL,
	[RenglonSub] [int] NOT NULL,
	[Articulo] [char](20) NULL,
	[Serie] [varchar](20) NULL,
	[Importe] [money] NULL,
	[Impuestos] [money] NULL,
	[Horas] [float] NULL,
	[MesesDepreciados] [int] NULL,
	[Depreciacion] [money] NULL,
	[DepreciacionPorcentaje] [float] NULL,
	[NuevoValor] [money] NULL,
	[Inflacion] [float] NULL,
	[ActualizacionCapital] [money] NULL,
	[ActualizacionGastos] [money] NULL,
	[ActualizacionDepreciacion] [money] NULL,
	[Observaciones] [varchar](100) NULL,
	[ValorAnterior] [money] NULL,
	[DepreciacionAnterior] [datetime] NULL,
	[RevaluacionAnterior] [datetime] NULL,
	[ReparacionAnterior] [datetime] NULL,
	[MantenimientoAnterior] [datetime] NULL,
	[MantenimientoSiguienteAnterior] [datetime] NULL,
	[PolizaMantenimientoAnterior] [datetime] NULL,
	[PolizaSeguroAnterior] [datetime] NULL,
	[Sucursal] [int] NOT NULL,
	[SucursalOrigen] [int] NOT NULL,
	[UltimoKmServicio] [float] NULL,
	[UltimoTipoServicio] [varchar](10) NULL,
	[AumentoKmServicio] [float] NULL,
	[UnidadKm] [float] NULL,
	[AnteriorTipoServicio] [varchar](10) NULL,
 CONSTRAINT [priActivoFijoD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[Renglon] ASC,
	[RenglonSub] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivoFijoD] ADD  DEFAULT ((0)) FOR [RenglonSub]
GO
ALTER TABLE [dbo].[ActivoFijoD] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[ActivoFijoD] ADD  DEFAULT ((0)) FOR [SucursalOrigen]
GO
