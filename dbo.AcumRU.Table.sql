SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AcumRU](
	[Sucursal] [int] NOT NULL,
	[Empresa] [char](5) NOT NULL,
	[Rama] [char](5) NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[Periodo] [int] NOT NULL,
	[Moneda] [char](10) NOT NULL,
	[Grupo] [char](10) NOT NULL,
	[Cuenta] [char](20) NOT NULL,
	[SubCuenta] [varchar](20) NOT NULL,
	[Cargos] [money] NULL,
	[Abonos] [money] NULL,
	[CargosU] [float] NULL,
	[AbonosU] [float] NULL,
	[UltimoCambio] [datetime] NULL,
 CONSTRAINT [priAcumRU] PRIMARY KEY CLUSTERED 
(
	[Cuenta] ASC,
	[SubCuenta] ASC,
	[Grupo] ASC,
	[Rama] ASC,
	[Ejercicio] ASC,
	[Periodo] ASC,
	[Moneda] ASC,
	[Sucursal] ASC,
	[Empresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AcumRU] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
