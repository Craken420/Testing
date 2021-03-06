SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivoFCat](
	[Categoria] [varchar](50) NOT NULL,
	[DepreciacionAnual] [float] NULL,
	[VidaUtil] [int] NULL,
	[CategoriaMaestra] [varchar](50) NULL,
	[MantenimientoPeriodicidad] [varchar](20) NULL,
	[Cuenta] [varchar](20) NULL,
	[CuentaFiscal] [varchar](20) NULL,
	[Icono] [int] NULL,
	[InicioDepreciacion] [varchar](20) NULL,
	[MetodoDepreciacion] [varchar](50) NULL,
	[Formula] [varchar](255) NULL,
	[Propietario] [varchar](20) NULL,
	[ValorDesecho] [money] NULL,
	[DepreciacionAnualAjustada] [bit] NULL,
	[CveProdSAT] [varchar](10) NULL,
 CONSTRAINT [priActivoFCat] PRIMARY KEY CLUSTERED 
(
	[Categoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivoFCat] ADD  DEFAULT ('Siguiente Mes') FOR [InicioDepreciacion]
GO
ALTER TABLE [dbo].[ActivoFCat] ADD  DEFAULT ('Linea Recta') FOR [MetodoDepreciacion]
GO
ALTER TABLE [dbo].[ActivoFCat] ADD  DEFAULT ('Empresa') FOR [Propietario]
GO
ALTER TABLE [dbo].[ActivoFCat] ADD  DEFAULT ((0)) FOR [DepreciacionAnualAjustada]
GO
