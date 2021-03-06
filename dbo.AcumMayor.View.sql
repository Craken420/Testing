SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[AcumMayor]

AS
SELECT
a.Empresa,
r.Mayor,
a.Cuenta,
a.SubCuenta,
a.Grupo,
a.Ejercicio,
a.Periodo,
a.Moneda,
"Cargos" = CONVERT(money, SUM(a.Cargos*r.Factor)),
"Abonos" = CONVERT(money, SUM(a.Abonos*r.Factor))
FROM
Acum a WITH(NOLOCK), Rama r WITH(NOLOCK)
WHERE
a.Rama = r.Rama
GROUP BY a.Empresa, r.Mayor, a.Cuenta, a.SubCuenta, a.Grupo, a.Ejercicio, a.Periodo, a.Moneda



GO
