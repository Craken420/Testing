SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE  [dbo].[Actualiza_CampoCobranza](@prefijo_p nvarchar(50),@empieza_p int, @termina_p int)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	declare @contador int;
	declare @de_Id int;
	declare @hasta_Id int;
	declare @prefijo nvarchar(50);
	declare @cobranza nvarchar(50);

	set @contador = 1;
	set @prefijo = @prefijo_p;
	set @hasta_Id = @termina_p;
	set @de_Id = @empieza_p;


		while (@de_Id < @hasta_Id)
		begin 

		set @cobranza=
		(@prefijo + replicate('0',4 - len(cast(@contador as nvarchar))) +
		cast(@contador as nvarchar)
		);

			update CodigoPostal WITH(ROWLOCK) set CodigoPostal.Cobranza=@cobranza
			where CodigoPostal.ID=@de_Id;

		set @contador = @contador + 1;

		set @de_Id = @de_Id + 1;

		end;

END
GO
