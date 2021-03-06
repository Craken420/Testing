SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AgentC](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Empresa] [char](5) NULL,
	[Mov] [char](20) NULL,
	[Serie] [varchar](20) NULL,
	[Periodo] [int] NULL,
	[Ejercicio] [int] NULL,
	[Consecutivo] [int] NOT NULL,
	[Sucursal] [int] NOT NULL,
 CONSTRAINT [priAgentC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AgentC] ADD  DEFAULT ((0)) FOR [Consecutivo]
GO
ALTER TABLE [dbo].[AgentC] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
