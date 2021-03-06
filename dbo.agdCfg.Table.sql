SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agdCfg](
	[PatenteAlmacenFiscal] [varchar](10) NOT NULL,
	[PatenteAlmacenadora] [varchar](10) NULL,
 CONSTRAINT [pk_agdCfg] PRIMARY KEY CLUSTERED 
(
	[PatenteAlmacenFiscal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agdCfg] ADD  DEFAULT ((1401)) FOR [PatenteAlmacenFiscal]
GO
