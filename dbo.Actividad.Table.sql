SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actividad](
	[Actividad] [varchar](100) NOT NULL,
	[Grupo] [varchar](50) NULL,
	[Costo] [money] NULL,
	[ModuloEsp] [char](5) NULL,
	[Orden] [int] NULL,
 CONSTRAINT [priActividad] PRIMARY KEY CLUSTERED 
(
	[Actividad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
