Create DataBase Control_de_Inventario

use Control_de_Inventario



create table Articulo(
id_articulo int identity (1,1),
art_nombre varchar (50),
art_descripcion varchar (100),
art_precio_uni decimal (10,2),
art_precio_mayor_1 decimal (10,2),
art_precio_mayor_2 decimal (10,2),
art_activo bit,
primary key (id_articulo)
)

alter table Articulo
alter column art_activo bit

--RESTRICCION (ART_ACTIVO POR DEFAULT 1)
alter table Articulo 
add constraint chk_art_activo default 1 for art_activo
--BORRAR UNA RESTRICCION
alter table Articulo
drop constraint chk_art_activo


create table Perfil(
id_perfil int identity (1,1),
per_perfil varchar (30),
primary key (id_perfil)
)

create table Usuario(
id_usuario int identity (1,1),
usu_nombre varchar (30),
usu_password varchar (30),
usu_perfil int,
usu_activo bit,
primary key (id_usuario),
foreign key (usu_perfil) references Perfil(id_perfil)
)
--RESTRICCION (USU_ACTIVO POR DEFAULT 1)
alter table Usuario
add constraint chk_usu_activo default 1 for usu_activo

create table Inventario(
id_inventario int identity (1,1),
inv_articulo int,
inv_cantidad int,
inv_cantidad_min int,
inv_descripcion varchar (100),
primary key (id_inventario),
foreign key (inv_articulo) references Articulo(id_articulo)
)

/*RESTRICCION DE INVENTARIO.INV_CANTIDAD SEA MAYOR/IGUAL A 0*/
alter table Inventario
add constraint chk_inv_cantidad check (inv_cantidad >= 0)

create table Entreda(
id_entrada int identity (1,1),
ent_fecha date,
ent_usuario int,
ent_cantidad int,
ent_articulo int,
primary key (id_entrada),
foreign key (ent_usuario) references Usuario(id_usuario),
foreign key (ent_articulo) references Articulo(id_articulo)
)


Create table Venta(
id_venta int identity (1,1),
ven_id_usuario int,
ven_fecha date,
ven_total decimal (10,2),
primary key (id_venta),
foreign key (ven_id_usuario) references Usuario(id_usuario)
)


Create table Detalle_Venta(
deta_id_detalle_venta int,
deta_id_articulo int,
deta_precio decimal (10,2),
deta_cantidad int,
primary key (deta_id_detalle_venta,deta_id_articulo),
foreign key (deta_id_detalle_venta) references Venta(id_venta),
foreign key (deta_id_articulo) references Articulo(id_articulo)
)

/*----------------------------------------*/
/*----------------------------------------*/
select * from Articulo
select * from Perfil



/*----------------------------------------*/
--INSERT ARTICULO
/*----------------------------------------*/
insert into Articulo	(art_nombre,
						art_categoria,
						art_descripcion,
						art_precio_uni,
						art_precio_mayor_1,
						art_precio_mayor_2) 
values					('NIVEA CEREZA CREMA CORPORAL 400ML',
						'PERFUME',
						'CEREZA & ACEITE DE JOJOBA PIEL NORMAL A SECA',
						105.00,
						100.00,
						0)

insert into Articulo	(art_nombre,
						art_categoria,
						art_descripcion,
						art_precio_uni,
						art_precio_mayor_1,
						art_precio_mayor_2) 
values					('HELBAL ESSENCES ALBOROTALOS ACONDICIONADOR 300ML',
						'PERFUME',
						'ALBOROTALOS CON ESECIAS DE MANGOSTAN',
						85.00,
						80.00,
						0)

select * from Articulo 


/*----------------------------------------*/
--INSERT PERFIL
/*----------------------------------------*/

insert into Perfil(per_perfil)
values				('ADMINISTRADOR'),
					('MASTER'),
					('CAJERO')


/*----------------------------------------*/
--INSERT USUARIO
/*----------------------------------------*/

insert into Usuario(usu_nombre,usu_password,usu_perfil)
values				('Alexander',
					'9484',
					1)

/*----------------------------------------*/
--INSERT INVENTARIO
/*----------------------------------------*/

insert into Inventario(inv_articulo,
						inv_cantidad,
						inv_cantidad_min,
						inv_descripcion)
values					(1,
						80,
						10,
						''),
						(2,
						100,
						10,
						'')

select * from Articulo
/*----------------------------------------*/
--INSERT ENTRADA
/*----------------------------------------*/

insert into Entreda(ent_fecha,
					ent_usuario,
					ent_cantidad,
					ent_articulo)
values				(GETDATE(),
					1,
					80,
					1),
					(GETDATE(),
					1,
					100,
					2)

/*----------------------------------------*/
--INSERT VENTA
/*----------------------------------------*/

insert into Venta	(ven_id_usuario,
					ven_fecha,
					ven_total)
values				(1,
					GETDATE(),
					380.00)

/*----------------------------------------*/
--INSERT DETALLE_VENTA
/*----------------------------------------*/

insert into Detalle_Venta	(deta_id_detalle_venta,
							deta_id_articulo,
							deta_precio,
							deta_cantidad)
values						(1,
							1,
							105.00,
							2),
							(1,
							2,
							85.00,
							2)
select * from Venta
select * from Detalle_Venta

/*----------------------------------------*/
--PROCEDURE INSERT ARTICULO
/*----------------------------------------*/

ALTER PROCEDURE spAgregarArticulo	(@art_nombre varchar(50),
									@art_descripcion varchar(100),
									@art_precio_uni decimal(10,2),
									@art_precio_mayor_1 decimal(10,2),
									@art_precio_mayor_2 decimal (10,2))
AS
BEGIN
	if(@art_nombre<>'' AND @art_precio_uni<>0)
		begin
			insert into Articulo	(art_nombre,
									art_descripcion,
									art_precio_uni,
									art_precio_mayor_1,
									art_precio_mayor_2)
			values					(@art_nombre,
									@art_descripcion,
									@art_precio_uni,
									@art_precio_mayor_1,
									@art_precio_mayor_2)
		end
	else
		begin
			select 'Ingrese los campos obligatorios'
		end
END

exec spAgregarArticulo 'PHILIP MORRIS 20','PHILIP MORRIS 20',88.00,87.00,0
select * from Articulo

/*----------------------------------------*/
--PROCEDURE INSERT USUARIO
/*----------------------------------------*/

ALTER PROCEDURE spAgregarUsuario	(@usu_nombre varchar(30),
									@usu_password varchar(30),
									@usu_perfil int)
AS
BEGIN
		IF(select COUNT(*) from Usuario where usu_nombre = @usu_nombre) = 0
			begin
				IF(select COUNT(*) from Perfil where id_perfil = @usu_perfil)>0
					begin
						insert into Usuario(usu_nombre,
											usu_password,
											usu_perfil,
											usu_activo)
						values				(@usu_nombre,
											@usu_password,
											@usu_perfil,
											1)
						select 'El Usuario se guardo correctamente'
					end
				ELSE
					begin
						select 'El Perfil de Usuario no existe'
					end
			end
		ELSE
			begin
				select 'El Nombre de Usuario que intenta ingresar ya existe'
			end
END

select * from Usuario

EXEC spAgregarUsuario 'Tato','9484',2
/*----------------------------------------*/
--PROCEDURE UPDATE USUARIO
/*----------------------------------------*/

ALTER PROCEDURE spEditarUsuario (@id_usuario int,
								@usu_nombre varchar(30),
								@usu_password varchar(30),
								@usu_perfil int)
AS
BEGIN
			begin
				if(@usu_password <> '')
				begin
					UPDATE Usuario SET usu_password = @usu_password
					WHERE id_usuario = @id_usuario
				end
				else
				begin
					UPDATE Usuario SET	usu_nombre = @usu_nombre,usu_perfil = @usu_perfil
					WHERE id_usuario = @id_usuario
				end
			end
END

exec spEditarUsuario 7,'Leonardo','12345',3

select * from Usuario

/*----------------------------------------*/
--PROCEDURE DELETE USUARIO
/*----------------------------------------*/

CREATE PROCEDURE spEliminarUsuario (@id_usuario int)
AS
BEGIN
	UPDATE Usuario SET usu_activo = 0
	WHERE id_usuario = @id_usuario
	
	SELECT 'El usuario fue eliminado' 
END

/*----------------------------------------*/
--PROCEDURE INSERT ENTRADA
/*----------------------------------------*/

ALTER PROCEDURE spAgregarEntrada	(@ent_usuario int,
									@ent_cantidad int,
									@ent_articulo int)
AS
BEGIN
	DECLARE @CantidadTotal int
	IF(select COUNT(*) from Articulo where id_articulo = @ent_articulo)>0
		begin
			IF @ent_cantidad>0
				begin
					insert into Entreda(ent_fecha,
										ent_usuario,
										ent_cantidad,
										ent_articulo)
					values				(GETDATE(),
										@ent_usuario,
										@ent_cantidad,
										@ent_articulo)
					IF(select COUNT(*) from Inventario where inv_articulo = @ent_articulo)>0
						begin
							set @CantidadTotal = @ent_cantidad + (SELECT Inventario.inv_cantidad FROM Inventario WHERE inv_articulo = @ent_articulo)
							update Inventario set inv_cantidad = @CantidadTotal 
							where inv_articulo = @ent_articulo
						end
					ELSE
						begin
							insert into Inventario(inv_articulo,
										inv_cantidad,
										inv_cantidad_min,
										inv_descripcion)
							values		(@ent_articulo,
										@ent_cantidad,
										10,
										'')
						end
				end
			ELSE
				begin
					select 'Ingrese un numero mayor a 0'
				end
		end
	ELSE	
		begin	
			select 'Ingrese un articulo existente'
		end
END

select * from Entreda

exec spAgregarEntrada 2,20,3

exec spAgregarEntrada 2,20,2


/*----------------------------------------*/
--PROCEDURE INSERT INVENTARIO SALIDA
/*----------------------------------------*/

ALTER PROCEDURE spInventarioSalida (@inv_articulo int, 
									@inv_descontar_cantidad int)
AS 
BEGIN
	IF (select Inv.inv_cantidad from Inventario as Inv where Inv.inv_articulo = @inv_articulo)>@inv_descontar_cantidad
	begin
		update Inventario set inv_cantidad = inv_cantidad - @inv_descontar_cantidad
		where Inventario.inv_articulo = @inv_articulo
	end
	else
	begin
		print 'La cantidad del Articulo que intenta vender excede el stock'
	end
END

exec spInventarioSalida 3,5

select * from Inventario

/*----------------------------------------*/
--PROCEDURE INSERT VENTA
/*----------------------------------------*/

CREATE PROCEDURE spAgregarVenta	(@ven_id_usuario int,
							@ven_total decimal (10,2))
AS
BEGIN
	INSERT INTO Venta	(ven_id_usuario,
						ven_fecha,
						ven_total)
	VALUES				(@ven_id_usuario,
						GETDATE(),
						@ven_total)
END

select * from Venta

/*----------------------------------------*/
--PROCEDURE INSERT DETALLE VENTA
/*----------------------------------------*/
 

CREATE PROCEDURE spAgregarDetalleVenta	(@deta_id_detalle_venta int,
							@deta_id_articulo int,
							@deta_precio_uni decimal (10,2),
							@deta_cantidad int)
AS
BEGIN
	INSERT INTO Detalle_Venta	(deta_id_detalle_venta,
								deta_id_articulo,
								deta_precio,
								deta_cantidad)
	VALUES						(@deta_id_detalle_venta,
								@deta_id_articulo,
								@deta_precio_uni,
								@deta_cantidad)
	
	exec spInventarioSalida @deta_id_articulo,@deta_cantidad
END

select * from Venta
select * from Detalle_Venta
select * from Articulo

exec spAgregarDetalleVenta 1,3,40,2

update Venta set ven_total = 670 where id_venta = 1

select * from Detalle_Venta

select * from Venta

select * from Perfil


/*----------------------------------------*/
--VISTA DE USUARIOS
/*----------------------------------------*/
ALTER VIEW vwmostrarusuarios
as
select U.id_usuario as ID,U.usu_nombre AS USUARIO,P.per_perfil AS PERFIL from Usuario as U inner join Perfil as P
on U.usu_perfil = P.id_perfil where P.id_perfil <> 1 and U.usu_activo = 1

select * from Usuario

update Usuario set usu_activo = 1
where usu_nombre = 'Leonardo'

delete Usuario where usu_nombre = 'Leo'



