SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alm](
	[Almacen] [varchar](10) NOT NULL,
	[Rama] [varchar](20) NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Direccion] [varchar](100) NULL,
	[EntreCalles] [varchar](100) NULL,
	[Plano] [varchar](15) NULL,
	[Observaciones] [varchar](100) NULL,
	[Colonia] [varchar](100) NULL,
	[Delegacion] [varchar](100) NULL,
	[Poblacion] [varchar](100) NULL,
	[Estado] [varchar](30) NULL,
	[Pais] [varchar](30) NULL,
	[CodigoPostal] [varchar](15) NULL,
	[Encargado] [varchar](50) NULL,
	[Telefonos] [varchar](100) NULL,
	[Grupo] [varchar](50) NULL,
	[Categoria] [varchar](50) NULL,
	[Zona] [varchar](30) NULL,
	[Ruta] [varchar](50) NULL,
	[Tipo] [varchar](15) NULL,
	[Sucursal] [int] NOT NULL,
	[Exclusivo] [varchar](20) NULL,
	[Orden] [int] NULL,
	[Estatus] [varchar](15) NOT NULL,
	[UltimoCambio] [datetime] NULL,
	[Alta] [datetime] NULL,
	[Logico1] [bit] NOT NULL,
	[Logico2] [bit] NOT NULL,
	[FacturasPendientes] [bit] NOT NULL,
	[wMostrar] [bit] NULL,
	[wUnicamenteDisponibles] [bit] NULL,
	[TieneMovimientos] [bit] NULL,
	[NivelAcceso] [varchar](50) NULL,
	[Idioma] [varchar](50) NULL,
	[ExcluirPlaneacion] [bit] NULL,
	[CBDir] [varchar](255) NULL,
	[Cuenta] [varchar](20) NULL,
	[Segundas] [bit] NULL,
	[Compartido] [bit] NULL,
	[SucursalRef] [int] NULL,
	[WMS] [bit] NULL,
	[SucursalAsignada] [int] NULL,
	[RecibeAjd] [bit] NULL,
 CONSTRAINT [priAlm] PRIMARY KEY CLUSTERED 
(
	[Almacen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ('Normal') FOR [Tipo]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [Sucursal]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [Logico1]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [Logico2]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [FacturasPendientes]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((1)) FOR [wMostrar]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [wUnicamenteDisponibles]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [TieneMovimientos]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [ExcluirPlaneacion]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [Segundas]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [Compartido]
GO
ALTER TABLE [dbo].[Alm] ADD  DEFAULT ((0)) FOR [WMS]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[tgAlmABC] ON [dbo].[Alm]

FOR INSERT, UPDATE, DELETE
AS BEGIN
DECLARE
@ClaveNueva  	varchar(10),
@ClaveAnterior	varchar(10),
@Mensaje 		varchar(255)
SELECT @ClaveNueva    = Almacen FROM Inserted
SELECT @ClaveAnterior = Almacen FROM Deleted
IF @ClaveNueva=@ClaveAnterior RETURN
IF @ClaveNueva IS NULL
BEGIN
DELETE Prop     WHERE Cuenta  = @ClaveAnterior AND Rama='ALM'
DELETE AnexoCta WHERE Cuenta  = @ClaveAnterior AND Rama='ALM'
DELETE AlmABC   WHERE Almacen = @ClaveAnterior
DELETE AlmPos   WHERE Almacen = @ClaveAnterior
END ELSE
IF @ClaveNueva <> @ClaveAnterior AND @ClaveAnterior IS NOT NULL
BEGIN
UPDATE Prop     WITH(ROWLOCK) SET Cuenta  = @ClaveNueva  WHERE Cuenta  = @ClaveAnterior AND Rama='ALM'
UPDATE AnexoCta WITH(ROWLOCK) SET Cuenta  = @ClaveNueva  WHERE Cuenta  = @ClaveAnterior AND Rama='ALM'
UPDATE AlmABC   WITH(ROWLOCK) SET Almacen = @ClaveNueva  WHERE Almacen = @ClaveAnterior
UPDATE AlmPos   WITH(ROWLOCK) SET Almacen = @ClaveNueva  WHERE Almacen = @ClaveAnterior
END
END


GO
ALTER TABLE [dbo].[Alm] ENABLE TRIGGER [tgAlmABC]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ======================================================================================================================================== 
-- NOMBRE   : TR_DM0246InsertDeletAlm
-- AUTOR   : Carlos Gonzalez Ramos
-- FECHA CREACION : 20/jul/2015 
-- DESARROLLO  : DM0246 Cuadros Basicos
-- MODULO   :  
-- DESCRIPCION  : 
-- 
-- ======================================================================================================================================== 
-- ========================================================================================================================================

CREATE TRIGGER [dbo].[TR_MAVIDM0246InsertDeletAlm] ON [dbo].[Alm]
AFTER INSERT,DELETE 
AS
BEGIN 
	INSERT INTO DM0246TipoAlm(Almacen) 
		SELECT 
			Almacen 
		FROM 
			inserted
		WHERE  
			inserted.Almacen LIKE 'V%' 
			AND inserted.Grupo='INS'  
			AND inserted.Estatus='alta'
			AND inserted.Almacen<> 'V00039'
			
			
	DELETE FROM DM0246TipoAlm
		WHERE 
			Almacen IN (SELECT Almacen FROM deleted WHERE deleted.Almacen LIKE 'V%' 
			AND deleted.Grupo='INS'  
			AND deleted.Estatus='alta'
			AND deleted.Almacen<> 'V00039')
			
END
GO
ALTER TABLE [dbo].[Alm] ENABLE TRIGGER [TR_MAVIDM0246InsertDeletAlm]
GO
