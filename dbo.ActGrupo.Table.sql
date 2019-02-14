SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActGrupo](
	[Grupo] [varchar](50) NOT NULL,
	[Icono] [int] NULL,
 CONSTRAINT [priActGrupo] PRIMARY KEY CLUSTERED 
(
	[Grupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
