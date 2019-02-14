SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aroRiesgo](
	[Riesgo] [varchar](10) NOT NULL,
	[FechaRegistro] [datetime] NULL,
	[Nombre] [varchar](100) NULL,
	[Descripcion] [varchar](255) NULL,
	[Comentarios] [text] NULL,
	[Procedimiento] [varchar](20) NULL,
	[Proceso] [varchar](20) NULL,
	[CentroCostos] [varchar](20) NULL,
	[UnidadOrganizacional] [varchar](20) NULL,
	[LineaNegocios] [varchar](20) NULL,
	[Supervisor] [varchar](10) NULL,
	[Usuario] [varchar](10) NULL,
	[Estatus] [varchar](15) NULL,
	[UltimoCambio] [datetime] NULL,
	[Alta] [datetime] NULL,
	[Baja] [datetime] NULL,
	[NivelAcceso] [varchar](50) NULL,
	[Situacion] [varchar](50) NULL,
	[SituacionFecha] [datetime] NULL,
	[SituacionUsuario] [varchar](10) NULL,
	[SituacionNota] [varchar](100) NULL,
	[DetectadoPor] [varchar](100) NULL,
	[DetectadoPorPuesto] [varchar](100) NULL,
	[TieneMovimientos] [bit] NULL,
	[FechaAutorizacion] [datetime] NULL,
	[UsuarioAutorizacion] [varchar](15) NULL,
	[FechaCancelacion] [datetime] NULL,
	[UsuarioCancelacion] [varchar](15) NULL,
 CONSTRAINT [pk_aroRiesgo] PRIMARY KEY CLUSTERED 
(
	[Riesgo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[aroRiesgo] ADD  DEFAULT ((0)) FOR [TieneMovimientos]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[tg_aroRiesgoBC] ON [dbo].[aroRiesgo]

FOR UPDATE, DELETE
AS BEGIN
DECLARE
@RiesgoN  	varchar(20),
@RiesgoA	varchar(20)
SELECT @RiesgoN = Riesgo FROM Inserted
SELECT @RiesgoA = Riesgo FROM Deleted
IF @RiesgoN = @RiesgoA RETURN
IF @RiesgoN IS NULL
BEGIN
DELETE aroRiesgoArt 		WHERE Riesgo = @RiesgoA
DELETE aroRiesgoFactor 		WHERE Riesgo = @RiesgoA
DELETE aroRiesgoControlInterno 	WHERE Riesgo = @RiesgoA
DELETE aroRiesgoEvaluacion 		WHERE Riesgo = @RiesgoA
END ELSE
IF @RiesgoA IS NOT NULL
BEGIN
UPDATE aroRiesgoArt WITH(ROWLOCK)  		SET Riesgo = @RiesgoN WHERE Riesgo = @RiesgoA
UPDATE aroRiesgoFactor WITH(ROWLOCK)  		SET Riesgo = @RiesgoN WHERE Riesgo = @RiesgoA
UPDATE aroRiesgoControlInterno WITH(ROWLOCK)  	SET Riesgo = @RiesgoN WHERE Riesgo = @RiesgoA
UPDATE aroRiesgoEvaluacion WITH(ROWLOCK) 		SET Riesgo = @RiesgoN WHERE Riesgo = @RiesgoA
END
END


GO
ALTER TABLE [dbo].[aroRiesgo] ENABLE TRIGGER [tg_aroRiesgoBC]
GO
