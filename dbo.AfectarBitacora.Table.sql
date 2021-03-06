SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AfectarBitacora](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Modulo] [varchar](5) NULL,
	[ModuloID] [int] NULL,
	[Accion] [varchar](20) NULL,
	[Base] [varchar](20) NULL,
	[GenerarMov] [varchar](20) NULL,
	[Usuario] [varchar](10) NULL,
	[FechaRegistro] [datetime] NULL,
	[Ok] [int] NULL,
	[OkRef] [varchar](255) NULL,
 CONSTRAINT [priAfectarBitacora] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
