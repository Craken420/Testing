SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[ActivoFDisponible]

AS
SELECT
Empresa Empresa,
Cuenta Articulo,
Grupo Almacen,
sum(SaldoU) Disponible
FROM
SaldoU WITH(NOLOCK)
WHERE
Rama='AF'
GROUP BY
Empresa, Cuenta, Grupo



GO
