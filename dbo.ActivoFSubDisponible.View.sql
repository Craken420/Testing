SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[ActivoFSubDisponible]

AS
SELECT
Empresa Empresa,
Cuenta Articulo,
SubCuenta SubCuenta,
Grupo Almacen,
Sum(SaldoU) Disponible
FROM
SaldoU WITH(NOLOCK)
WHERE
SubCuenta is NOT NULL AND Rama = 'AF'
GROUP BY
Empresa, Cuenta, Grupo, SubCuenta



GO
