SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnexoCta](
	[Rama] [varchar](5) NOT NULL,
	[Cuenta] [varchar](20) NOT NULL,
	[IDR] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Nombre] [varchar](255) NULL,
	[Direccion] [varchar](255) NULL,
	[Icono] [int] NULL,
	[Tipo] [varchar](10) NULL,
	[Orden] [int] NULL,
	[Comentario] [text] NULL,
	[Origen] [varchar](255) NULL,
	[Destino] [varchar](255) NULL,
	[Fecha] [varchar](255) NULL,
	[FechaEmision] [datetime] NULL,
	[Vencimiento] [datetime] NULL,
	[TipoDocumento] [varchar](50) NULL,
	[Inicio] [datetime] NULL,
	[Alta] [datetime] NULL,
	[UltimoCambio] [datetime] NULL,
	[Usuario] [varchar](10) NULL,
	[NivelAcceso] [varchar](50) NULL,
	[Categoria] [varchar](50) NULL,
	[Grupo] [varchar](50) NULL,
	[Familia] [varchar](50) NULL,
 CONSTRAINT [priAnexoCta] PRIMARY KEY CLUSTERED 
(
	[Rama] ASC,
	[Cuenta] ASC,
	[IDR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================  
-- NOMBRE		  : TG_DM0172MAVIRegistrosSoloHuellas  
-- AUTOR		  : Jesus Del Toro Andrade
-- FECHA CREACION : 25-06-2012
-- DESARROLLO     : DESARROLLO DE HUELLA DIGITAL DE CLIENTES  
-- MODULO		  : CTE  
-- DESCRIPCION    : Registra las visitas hechas con solo la huella del cliente
-- ========================================================================================================================================  
CREATE TRIGGER [dbo].[TG_DM0172MAVIRegistrosSoloHuellas] ON [dbo].[AnexoCta]
 INSTEAD OF INSERT
AS BEGIN
  DECLARE
  @Comentario VARCHAR(100),
  @Suc INT,
  @Cte VARCHAR(20)
  
  SELECT @Comentario = CONVERT(VARCHAR(100),Comentario), @Cte = Cuenta FROM INSERTED
  SELECT TOP 1 @Suc = Sucursal FROM dbo.RegistroCte WHERE Codigo=@Cte ORDER BY Fecha DESC
  
	--IF ISNULL(@Comentario,'NULO') IN ('HUELLA','NULO')
	--BEGIN
	--	INSERT INTO dbo.RegistroCte(Codigo,Nombre,Registro,Fecha,Sucursal,Huella,Valido,UsuarioValido,FechaValido,Motivo,
	--								Pregunta1,Respuesta1,Pregunta2,Respuesta2,Pregunta3,Respuesta3,Pregunta4,Respuesta4,
	--								Pregunta5,Respuesta5)
	--	SELECT i.Cuenta,C.Nombre,@Comentario,i.Alta,0,'Si',@Suc,i.Usuario,i.Alta,'Registro Huella',
	--			'NA_','NA','NA','NA','NA','NA','NA','NA','NA','NA'
	--	FROM INSERTED i
	--	INNER JOIN Cte C WITH(NOLOCK) ON C.Cliente=i.Cuenta	
	--END
  	INSERT INTO dbo.AnexoCta(Rama,Cuenta,Nombre,Direccion,Icono,Tipo,Orden,Comentario,Origen,Destino,Fecha,FechaEmision,
							 Vencimiento,TipoDocumento,Inicio,Alta,UltimoCambio,Usuario,NivelAcceso,Categoria,Grupo,Familia)
	SELECT Rama,Cuenta,Nombre,Direccion,Icono,Tipo,Orden,Comentario,Origen,Destino,Fecha,FechaEmision,
							 Vencimiento,TipoDocumento,Inicio,Alta,UltimoCambio,Usuario,NivelAcceso,Categoria,Grupo,Familia
	FROM INSERTED

END
GO
ALTER TABLE [dbo].[AnexoCta] ENABLE TRIGGER [TG_DM0172MAVIRegistrosSoloHuellas]
GO
