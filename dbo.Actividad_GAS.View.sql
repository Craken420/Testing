SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[Actividad_GAS]

AS
SELECT Orden, Actividad
FROM Actividad WITH(NOLOCK) WHERE ModuloEsp IN (NULL, '', 'GAS')



GO
