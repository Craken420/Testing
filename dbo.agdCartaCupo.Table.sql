SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agdCartaCupo](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Estatus] [varchar](15) NULL,
	[Situacion] [varchar](50) NULL,
	[Usuario] [varchar](10) NULL,
	[UltimoCambio] [datetime] NULL,
	[Folio] [varchar](10) NULL,
	[FechaEmision] [datetime] NULL,
	[FechaExpedicion] [datetime] NULL,
	[TipoMovimiento] [char](1) NULL,
	[Pedimento] [varchar](20) NULL,
	[AduanaDespacho] [varchar](10) NULL,
	[AduanaCircunscripcion] [varchar](10) NULL,
	[TipoDocumento] [varchar](10) NULL,
	[Cliente] [varchar](10) NULL,
	[ClienteRFC] [varchar](20) NULL,
	[AgenteAduanal] [varchar](10) NULL,
	[AgenteAduanalRFC] [varchar](20) NULL,
	[AgenteAduanalCURP] [varchar](20) NULL,
	[DestinoMercancia] [varchar](10) NULL,
	[SF] [varchar](5) NULL,
	[AG] [varchar](5) NULL,
	[CC] [varchar](5) NULL,
	[Observaciones] [varchar](255) NULL,
	[AlmacenadoraOrigen] [varchar](10) NULL,
	[AlmacenOrigen] [varchar](10) NULL,
	[FolioOrigen] [varchar](20) NULL,
	[EntradaReferencia] [varchar](50) NULL,
	[EntradaFecha] [datetime] NULL,
	[SalidaReferencia] [varchar](50) NULL,
	[SalidaFecha] [datetime] NULL,
 CONSTRAINT [pk_agdCartaCupo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
