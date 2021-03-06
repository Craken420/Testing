SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aduana](
	[Aduana] [varchar](50) NOT NULL,
	[Seccion] [varchar](20) NULL,
	[Denominacion] [varchar](255) NULL,
	[GLN] [varchar](50) NULL,
	[Ciudad] [varchar](50) NULL,
 CONSTRAINT [priAduana] PRIMARY KEY CLUSTERED 
(
	[Aduana] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
