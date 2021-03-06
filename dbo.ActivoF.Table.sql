SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivoF](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Empresa] [varchar](5) NOT NULL,
	[Articulo] [varchar](20) NOT NULL,
	[Serie] [varchar](50) NULL,
	[Moneda] [varchar](10) NULL,
	[Almacen] [varchar](10) NULL,
	[Categoria] [varchar](50) NULL,
	[Localizacion] [varchar](50) NULL,
	[UltimoCambio] [datetime] NULL,
	[AdquisicionValor] [money] NULL,
	[AdquisicionFecha] [datetime] NULL,
	[GarantiaVence] [datetime] NULL,
	[DepreciacionAnual] [float] NULL,
	[VidaUtil] [int] NULL,
	[Utilizacion] [float] NULL,
	[DepreciacionInicio] [datetime] NULL,
	[DepreciacionMeses] [int] NULL,
	[DepreciacionAcum] [money] NULL,
	[DepreciacionUltima] [datetime] NULL,
	[ValorRevaluado] [money] NULL,
	[RevaluacionUltima] [datetime] NULL,
	[Mantenimientos] [int] NULL,
	[MantenimientoUltimo] [datetime] NULL,
	[MantenimientoSiguiente] [datetime] NULL,
	[MantenimientoCantidad] [float] NULL,
	[MantenimientoUnidad] [varchar](50) NULL,
	[MantenimientoVence] [datetime] NULL,
	[MantenimientoAcum] [money] NULL,
	[MantenimientoHoras] [float] NULL,
	[MantenimientoPeriodicidad] [varchar](20) NULL,
	[Reparaciones] [int] NULL,
	[ReparacionAcum] [money] NULL,
	[ReparacionHoras] [float] NULL,
	[ReparacionUltima] [datetime] NULL,
	[SeguroVence] [datetime] NULL,
	[SeguroAcum] [money] NULL,
	[Observaciones] [varchar](100) NULL,
	[Estatus] [varchar](15) NOT NULL,
	[Sucursal] [int] NOT NULL,
	[TieneMovimientos] [bit] NULL,
	[Cliente] [varchar](10) NULL,
	[CentroCostos] [varchar](20) NULL,
	[Responsable] [varchar](10) NULL,
	[Espacio] [varchar](10) NULL,
	[Logico1] [bit] NOT NULL,
	[Logico2] [bit] NOT NULL,
	[Logico3] [bit] NOT NULL,
	[Logico4] [bit] NOT NULL,
	[Logico5] [bit] NOT NULL,
	[Referencia] [varchar](50) NULL,
	[Departamento] [varchar](50) NULL,
	[Licencia] [varchar](50) NULL,
	[Garantia] [varchar](50) NULL,
	[Aseguradora] [varchar](10) NULL,
	[SeguroInicio] [datetime] NULL,
	[SeguroTipoPoliza] [varchar](50) NULL,
	[SeguroMonto] [money] NULL,
	[Arrendadora] [varchar](10) NULL,
	[UEN] [int] NULL,
	[Proyecto] [varchar](50) NULL,
	[Actividad] [varchar](100) NULL,
	[ValorDesecho] [money] NULL,
	[UltimoKmServicio] [float] NULL,
	[UltimoTipoServicio] [varchar](10) NULL,
	[SeveroCada] [float] NULL,
	[LigeroCada] [float] NULL,
	[RecibeManntoMAVI] [varchar](20) NULL,
 CONSTRAINT [priActivoF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Sucursa__25132BA3]  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__TieneMo__26074FDC]  DEFAULT ((1)) FOR [TieneMovimientos]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Logico1__26FB7415]  DEFAULT ((0)) FOR [Logico1]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Logico2__27EF984E]  DEFAULT ((0)) FOR [Logico2]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Logico3__28E3BC87]  DEFAULT ((0)) FOR [Logico3]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Logico4__29D7E0C0]  DEFAULT ((0)) FOR [Logico4]
GO
ALTER TABLE [dbo].[ActivoF] ADD  CONSTRAINT [DF__ActivoF__Logico5__2ACC04F9]  DEFAULT ((0)) FOR [Logico5]
GO
