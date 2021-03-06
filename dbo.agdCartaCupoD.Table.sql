SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agdCartaCupoD](
	[ID] [int] NOT NULL,
	[RID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Fraccion] [varchar](20) NULL,
	[Secuencia] [int] NULL,
	[ValorEnDolares] [money] NULL,
	[Cantidad] [float] NULL,
	[UnidadMedidaTarifa] [varchar](10) NULL,
 CONSTRAINT [pk_agdCartaCupoD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[RID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
