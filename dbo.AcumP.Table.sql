SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AcumP](
	[Sucursal] [int] NOT NULL,
	[Empresa] [varchar](5) NOT NULL,
	[Rama] [varchar](5) NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[Periodo] [int] NOT NULL,
	[Moneda] [varchar](10) NOT NULL,
	[Grupo] [varchar](10) NOT NULL,
	[Cuenta] [varchar](20) NOT NULL,
	[SubCuenta] [varchar](50) NOT NULL,
	[Cargos] [money] NULL,
	[Abonos] [money] NULL,
	[UltimoCambio] [datetime] NULL,
	[SubCuenta2] [varchar](50) NOT NULL,
	[SubCuenta3] [varchar](50) NOT NULL,
	[Proyecto] [varchar](50) NOT NULL,
	[UEN] [int] NOT NULL,
 CONSTRAINT [priAcumP] PRIMARY KEY CLUSTERED 
(
	[Cuenta] ASC,
	[SubCuenta] ASC,
	[SubCuenta2] ASC,
	[SubCuenta3] ASC,
	[Grupo] ASC,
	[Proyecto] ASC,
	[UEN] ASC,
	[Rama] ASC,
	[Ejercicio] ASC,
	[Periodo] ASC,
	[Moneda] ASC,
	[Sucursal] ASC,
	[Empresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AcumP] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[AcumP] ADD  DEFAULT ('') FOR [SubCuenta2]
GO
ALTER TABLE [dbo].[AcumP] ADD  DEFAULT ('') FOR [SubCuenta3]
GO
ALTER TABLE [dbo].[AcumP] ADD  DEFAULT ('') FOR [Proyecto]
GO
ALTER TABLE [dbo].[AcumP] ADD  DEFAULT ((0)) FOR [UEN]
GO
