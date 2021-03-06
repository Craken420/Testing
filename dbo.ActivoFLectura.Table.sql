SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivoFLectura](
	[Empresa] [varchar](5) NOT NULL,
	[Articulo] [varchar](20) NOT NULL,
	[Serie] [varchar](20) NOT NULL,
	[Concepto] [varchar](50) NOT NULL,
	[Lectura] [int] NULL,
	[Fecha] [datetime] NULL,
 CONSTRAINT [priActivoFLectura] PRIMARY KEY CLUSTERED 
(
	[Empresa] ASC,
	[Articulo] ASC,
	[Serie] ASC,
	[Concepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
