USE [master]
GO
/****** Object:  Database [Control_de_Inventario]    Script Date: 10/04/2019 10:41:38 ******/
CREATE DATABASE [Control_de_Inventario]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Control_de_Inventario', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Control_de_Inventario.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Control_de_Inventario_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Control_de_Inventario_log.ldf' , SIZE = 1088KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Control_de_Inventario] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Control_de_Inventario].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ARITHABORT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Control_de_Inventario] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Control_de_Inventario] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Control_de_Inventario] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Control_de_Inventario] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET RECOVERY FULL 
GO
ALTER DATABASE [Control_de_Inventario] SET  MULTI_USER 
GO
ALTER DATABASE [Control_de_Inventario] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Control_de_Inventario] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Control_de_Inventario] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Control_de_Inventario] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Control_de_Inventario', N'ON'
GO
USE [Control_de_Inventario]
GO
/****** Object:  StoredProcedure [dbo].[spAgregarArticulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarArticulo]	(@art_nombre varchar(50),
									@art_descripcion varchar(100),
									@art_precio_uni money,
									@art_precio_mayor_1 money,
									@art_precio_mayor_2 money)
AS
BEGIN
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
END
GO
/****** Object:  StoredProcedure [dbo].[spAgregarDetalleVenta]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarDetalleVenta]	(@deta_id_detalle_venta int,
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


GO
/****** Object:  StoredProcedure [dbo].[spAgregarEntrada]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarEntrada]	(@ent_usuario int,
									@ent_cantidad int,
									@ent_articulo int)
AS
BEGIN
	DECLARE @CantidadTotal int
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
END
GO
/****** Object:  StoredProcedure [dbo].[spAgregarUsuario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarUsuario]	(@usu_nombre varchar(30),
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


GO
/****** Object:  StoredProcedure [dbo].[spAgregarVenta]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAgregarVenta]	(@ven_id_usuario int,
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


GO
/****** Object:  StoredProcedure [dbo].[spBuscarArticulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBuscarArticulo](@palabra varchar(50))
AS
DECLARE @primerpalabra varchar(25),
		@segundapalabra varchar(25),
		@separador varchar(1),
		@inicio int,
		@fin int


BEGIN
	set @inicio = 1
	set	@separador = ' '
	set @fin = CHARINDEX (@separador,@palabra)
	
	IF(@palabra != '')
	BEGIN
	IF ((CHARINDEX(@separador,@palabra)=0))
		BEGIN
			select * from Articulo WHERE art_nombre LIKE '%' + @palabra + '%'
		END

		ELSE
		BEGIN
			set @primerpalabra = SUBSTRING (@palabra,1,@fin-1)
			set @segundapalabra = SUBSTRING(@palabra,@fin+1,LEN(@palabra))
			select Articulo.art_nombre from Articulo WHERE art_nombre LIKE '%' + @primerpalabra + '%' INTERSECT select Articulo.art_nombre from Articulo WHERE art_nombre LIKE '%' + @segundapalabra + '%'
		END
	END			
END
GO
/****** Object:  StoredProcedure [dbo].[spEditarArticulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEditarArticulo]	(@id_articulo int,
									@art_nombre varchar(100),
									@art_descripcion varchar(100),
									@art_precio_uni money,
									@art_precio_mayor_1 money,
									@art_precio_mayor_2 money)
AS
BEGIN

	UPDATE Articulo SET art_nombre = @art_nombre,
						art_descripcion = @art_descripcion,
						art_precio_uni = @art_precio_uni,
						art_precio_mayor_1 = @art_precio_mayor_1,
						art_precio_mayor_2 = @art_precio_mayor_2
	WHERE				id_articulo = @id_articulo
				
END

GO
/****** Object:  StoredProcedure [dbo].[spEditarUsuario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEditarUsuario] (@id_usuario int,
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

GO
/****** Object:  StoredProcedure [dbo].[spEliminarArticulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEliminarArticulo]	(@id_articulo int)
AS
BEGIN

	UPDATE Articulo SET art_activo = '0'
	WHERE				id_articulo = @id_articulo
				
END
GO
/****** Object:  StoredProcedure [dbo].[spEliminarUsuario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEliminarUsuario] (@id_usuario int)
AS
BEGIN
	UPDATE Usuario SET usu_activo = 0
	WHERE id_usuario = @id_usuario 
END


GO
/****** Object:  StoredProcedure [dbo].[spInventarioSalida]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInventarioSalida] (@inv_articulo int, 
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
		print 'El cantidad del Articulo que intenta vender excede el stock'
	end
END



GO
/****** Object:  Table [dbo].[Articulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Articulo](
	[id_articulo] [int] IDENTITY(1,1) NOT NULL,
	[art_nombre] [varchar](100) NULL,
	[art_descripcion] [varchar](100) NULL,
	[art_precio_uni] [money] NULL,
	[art_precio_mayor_1] [money] NULL,
	[art_precio_mayor_2] [money] NULL,
	[art_activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Detalle_Venta]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Detalle_Venta](
	[deta_id_detalle_venta] [int] NOT NULL,
	[deta_id_articulo] [int] NOT NULL,
	[deta_precio] [decimal](10, 2) NULL,
	[deta_cantidad] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[deta_id_detalle_venta] ASC,
	[deta_id_articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Entreda]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Entreda](
	[id_entrada] [int] IDENTITY(1,1) NOT NULL,
	[ent_fecha] [date] NULL,
	[ent_usuario] [int] NULL,
	[ent_cantidad] [int] NULL,
	[ent_articulo] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_entrada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Inventario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Inventario](
	[id_inventario] [int] IDENTITY(1,1) NOT NULL,
	[inv_articulo] [int] NULL,
	[inv_cantidad] [int] NULL,
	[inv_cantidad_min] [int] NULL,
	[inv_descripcion] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_inventario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Perfil]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Perfil](
	[id_perfil] [int] IDENTITY(1,1) NOT NULL,
	[per_perfil] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_perfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Usuario](
	[id_usuario] [int] IDENTITY(1,1) NOT NULL,
	[usu_nombre] [varchar](30) NULL,
	[usu_password] [varchar](30) NULL,
	[usu_perfil] [int] NULL,
	[usu_activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Venta]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Venta](
	[id_venta] [int] IDENTITY(1,1) NOT NULL,
	[ven_id_usuario] [int] NULL,
	[ven_fecha] [date] NULL,
	[ven_total] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwmostrararticulo]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmostrararticulo]
as
select A.id_articulo,A.art_nombre,A.art_precio_uni,A.art_precio_mayor_1,A.art_precio_mayor_2 from Articulo AS A
where A.art_activo = 1

GO
/****** Object:  View [dbo].[vwmostrarentrada]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmostrarentrada]
as
select A.id_articulo,A.art_nombre,I.inv_cantidad FROM Articulo AS A left outer join Inventario AS I ON A.id_articulo = I.inv_articulo 
where A.art_activo = 1
GO
/****** Object:  View [dbo].[vwmostrarinventario]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmostrarinventario]
as
select A.id_articulo,A.art_nombre,I.inv_cantidad from Articulo as A inner join Inventario as I 
on A.id_articulo = I.inv_articulo
where A.art_activo = 1

GO
/****** Object:  View [dbo].[vwmostrarusuarios]    Script Date: 10/04/2019 10:41:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwmostrarusuarios]
as
select U.id_usuario as ID,U.usu_nombre AS USUARIO,P.per_perfil AS PERFIL from Usuario as U inner join Perfil as P
on U.usu_perfil = P.id_perfil where P.id_perfil <> 1 and U.usu_activo = 1


GO
SET IDENTITY_INSERT [dbo].[Articulo] ON 

INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (1, N'GONZALITO AZUFRE EN BARRA PAQ X 5 ( CAJA X 20 PAQ)', NULL, 12.4300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (2, N'GORRION AZUFRE  ( CAJA X100 UND  SUELTAS ) ', NULL, 155.4100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (3, N'MAXI-BAG BOLSA CONSORCIO 60X90 REFORZADA PAQ X 10 UND (BULTO X 50 PAQ)', NULL, 23.0700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (4, N'MAXI-BAG BOLSA CONSORCIO 90X120 PAQ X10 UND ( BULTO X 20 PAQ)', NULL, 60.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (5, N'MAXI-BAG BOLSA RESIDUOS 45X60 PAQ X10 UND (BULTO X 200 PAQ)', NULL, 9.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (6, N'MAXI-BAG BOLSA RESIDUOS 50X70 PAQUETE X 10 UND (BULTO X 150)', NULL, 12.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (7, N'ROLAN BOLSA CAMISETA  45X60 PRACTIBAGS CALIDAD 8300 (X 20)', NULL, 22.2000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (8, N'ROLAN BOLSA CAMISETA 40X50 COLOR VERDE  (X 20)', NULL, 22.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (9, N'ROXI PLAST BOLSA COMPACTADORA 80X110 PAQ X 10 UND(BULTOX 40 PAQ)', NULL, 35.2300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (10, N'ROXI PLAST BOLSA COMPACTADORA 90X120 PAQ X 10 UND (BULTOX 20 PAQ)', NULL, 49.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (11, N'ROXI PLAST BOLSA CONSORCIO 60X90 AZUL PAQ X 10 UND (BULTOX 50 PAQ)', NULL, 16.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (12, N'ROXI PLAST BOLSA RESIDUOS 45X60  PAQ X 10 UND( BULTO X 150 PAQ)', NULL, 9.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (13, N'ROXI PLAST BOLSA RESIDUOS 50X70  PAQ X10 UND( BULTO X 150)', NULL, 10.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (14, N'SAMPEDRINA BOLSA CONSORCIO 60X90 PAQ X 10 UND(BULTO X 50 PAQ)', NULL, 15.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (15, N'SAMPEDRINA BOLSA CONSORCIO 80X110 PAQ X 10 UND (BULTO X40 PAQ)', NULL, 27.6600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (16, N'ROMYL BROCHES DE PLASTICO REFORZADO', NULL, 19.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (17, N'XPER BROCHE DE MADERA X12', NULL, 14.7800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (18, N'CABO DE MADERA 1RA X 1,20 MT', NULL, 12.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (19, N'CABO DE MADERA 2 MTS', NULL, 27.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (20, N'CABO DE MADERA INDUSTRIAL', NULL, 30.3600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (21, N'CABO DE MADERA PLASTIFICADO', NULL, 9.6600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (22, N'CABO DE MADERA X 1,50 MT', NULL, 18.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (23, N'ROMYL CABO EXTENSIBLE 3 MT ', NULL, 163.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (24, N'ISABELLA CEPILLO LAVA COCHE (CAJA DE 32 UND)', NULL, 27.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (25, N'ISABELLA ESCOBILLA ECO (CAJA 24 UND)', NULL, 14.2900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (26, N'ISABELLA ESCOBILLA WC S/ BASE (CAJA DE 12 UND)', NULL, 24.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (27, N'LA GAUCHITA  CEPILLO PLANCHITA  (CAJA X 12 UNIDADES )', NULL, 21.3600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (28, N'ESCOBA ECONOMICA', NULL, 80.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (29, N'ESCOBA GALPONERA', NULL, 109.2900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (30, N'ESCOBA ITALIANA', NULL, 92.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (31, N'ESCOBA NENES', NULL, 55.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (32, N'ISABELLA ESCOBETA MODENA (CAJA X12 UND)', NULL, 22.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (33, N'ISABELLA ESCOBILLON 4 HILERAS GUIDO (CAJA DE 18 UND)', NULL, 20.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (34, N'ISABELLA ESCOBILLON ANA (CAJA X12  UND)', NULL, 35.5000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (35, N'ISABELLA ESCOBILLON CURVO PALERMO (CAJA DE 12 UND)', NULL, 24.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (36, N'ISABELLA ESCOBILLON CURVO SUPER PALERMO. (CAJA X12 UND)', NULL, 27.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (37, N'ISABELLA ESCOBILLON JOSE (CAJA DE 12 UND)', NULL, 27.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (38, N'ISABELLA ESCOBILLON NERON (CAJA DE 12 UND)', NULL, 29.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (39, N'ISABELLA ESCOBILLON SAMIASI (CAJA 12 UNID)', NULL, 24.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (40, N'ISABELLA ESCOBON TITAN (CAJA X 12 UND)', NULL, 29.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (41, N'BOOB ESPONJA DE BAÑO LINEA CLASICA RECTANGULAR GRANDE (X 120)', NULL, 10.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (42, N'BOOB ESPONJA DE BAÑO OVALADA CON VEGETAL ART. 74 (X 120)', NULL, 29.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (43, N'GO! ESPONJA ACERO INOXIDABLE 30 GRS 5 x 12', NULL, 14.7500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (44, N'GO! ESPONJA ANATOMICA LIMPIEZA PROFUNDA 5 x 12', NULL, 11.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (45, N'GO! ESPONJA BRONCE X1 5 x 12', NULL, 11.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (46, N'GO! ESPONJA CUADROS CLASICA 5 x 12 ', NULL, 6.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (47, N'GO! ESPONJA LISA LIMPIEZA FACIL 5 x 12', NULL, 5.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (48, N'GO! ESPONJA MAX MULTIUSO 5 x 12', NULL, 7.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (49, N'GO! ESPONJA NO RAYA 5 x 12', NULL, 7.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (50, N'GO! ESPONJA POWER PROTEGE UÑAS 5 x 12', NULL, 6.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (51, N'GO! ESPONJA x1 ACERO INOXIDABLE 5 x 12', NULL, 7.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (52, N'GO! ESPONJA X2 ACERO INOXIDABLE 5 x 12', NULL, 14.3300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (53, N'GO! ESPONJA x2 BRONCE 5 X 12', NULL, 21.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (54, N'LA GAUCHITA ESPONJA LAVA AUTOS C/ PROT. UÑAS 5 x 12', NULL, 43.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (55, N'ROMYL LANA DE ACERO X10 RULITOS (X 25)', NULL, 13.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (56, N'LA GAUCHITA GUANTE MULTIUSO ', NULL, 30.7800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (57, N'MAT MANGUERA 1/2 (X 15 MTS)', NULL, 115.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (58, N'MAT MANGUERA 1/2 REFORZADA (X 15 MTS)', NULL, 144.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (59, N'MAT MANGUERA 3/4 (X15 MTS)', NULL, 229.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (60, N'MAT MANGUERA 3/4 REFORZADA   
(X 15 MTS)', NULL, 287.6800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (61, N' SECADOR DE GOMA NEGRO Nº 40 (CAJA X 12 UND)', NULL, 14.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (62, N' SECADOR DE GOMA NEGRO Nº 50 (CAJA X12 UND)', NULL, 15.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (63, N' SECADOR DE GOMA ROJO Nº 50 (CAJA X 12 UND)', NULL, 20.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (64, N'ISABELLA SECADOR DUO DOBLE GOMA BLANCO (CAJA X 12 UND)', NULL, 29.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (65, N'SANTIGOMA SECADOR DE GOMA BLANCO Nº 30', NULL, 19.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (66, N'SANTIGOMA SECADOR DE GOMA BLANCO Nº 40', NULL, 23.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (67, N'SECADOR DE GOMA NEGRO Nº 30 (CAJA X 12 UND)', NULL, 12.2800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (68, N'SECADOR DE GOMA ROJO Nº 30 (CAJA X 12 UND)', NULL, 15.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (69, N'SECADOR DE GOMA ROJO Nº 40 (CAJA X 12 UND)', NULL, 19.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (70, N'SANTIGOMA SOPAPA DE GOMA NEGRA (CAJA X 24 UND)', NULL, 8.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (71, N'SANTIGOMA SOPAPA DE GOMA ROJA (CAJA X 24 UND)', NULL, 8.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (72, N'BROCHES PVC', NULL, 10.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (73, N'CARRITO DE COMPRAS REFORZADO', NULL, 234.4500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (74, N'LA GAUCHITA BOLS SANITARIO (CAJA X 24 UNIDADES )', NULL, 38.7700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (75, N'LA GAUCHITA LIMPIATECHOS SIN CABO  (CAJA 6 UNIDADES )', NULL, 38.5400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (76, N'TENDEDERO DE ALUMINIO (8 VARILLAS)', NULL, 365.5000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (77, N'TENDEDERO DE ALUMINIO (BALCÓN CON 2 ALAS)', NULL, 388.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (78, N'VILLA IRIS VELAS 14 X 175 MM. PAQUETE X 4 UND. (CAJA X 25 UND)', NULL, 9.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (79, N'CLEANTEX TRAPO DE PISO NIDO DE ABEJAS ', NULL, 13.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (80, N'GAVAPLAST COMBO PVC BALDE + PALA + PALANGANA', NULL, 61.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (81, N'HEADLY POLVO DECO.70', NULL, 24.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (82, N'KEEPTRIN INSECTICIDA X 60 CC', NULL, 44.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (83, N'K-OTHRINA FOG AEROSOL X 426 CC', NULL, 72.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (84, N'LA GAUCHITA ESCOBILLA SANITARIA ECONOMICA (CAJA X 12 UNIDADES) ', NULL, 17.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (85, N'LA GAUCHITA SECADOR DOBLE GOMA REFORZADO (CAJA X 12 UNIDADES )', NULL, 55.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (86, N'LIMPIA VIDRIOS GRANDE PIRAGUA', NULL, 15.8500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (87, N'MAKE EMBUDO PLASTICO N10', NULL, 9.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (88, N'MAKE EMBUDO PLASTICO N17', NULL, 17.7600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (89, N'MAKE ROLLO DE LANA ACERO 10 U (X 240)', NULL, 3.8900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (90, N'MARY BOSQUES SACHET KERATINA CREMA EXPRESS', NULL, 7.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (91, N'NEW PEL 2X12X100 MTS (COD22 x12)', NULL, 326.4800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (92, N'NEW PEL ROLLO COCINA 6X450 PAÑOS COD69', NULL, 283.2900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (93, N'PIRAGUA BROCHE PLASTICO ', NULL, 12.2300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (94, N'ROXI PLAST BOLSA CONSORCIO 60X90 ROJA  PAQ X 10 UND(BULTO X 50 PAQ)', NULL, 6.5300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (95, N'SOCORRO SACHET CAPILAR', NULL, 10.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (96, N'ZORRO JABON EN POLVO  800 GRS', NULL, 20.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (97, N'ECOAHORRO BOLSA FRISELINA 45 X 60', NULL, 12.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (98, N'ECOAHORRO CREMA DE ENJUAGUE SUELTA', NULL, 25.2700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (99, N'ECOAHORRO GAVAPLAST PALANGANA DEL COMBO COLOR 6 LTS. ', NULL, 20.8200, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (100, N'ECOAHORRO GAVAPLAST PALITA DEL COMBO', NULL, 7.4400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (101, N'ECOAHORRO GELTEK CEBO EN GEL MATA CUCARACHAS. JERINGA X 6 GRS.', NULL, 40.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (102, N'ECOAHORRO GELTEK COMPRIMIDO FUMIGENO / FUMIXAN', NULL, 52.9600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (103, N'ECOAHORRO K-OTHRINA SUSPENSION CONCENTRADA X 60 CM3.', NULL, 35.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (104, N'ECOAHORRO LA GAUCHITA CEPILLO PLASTICO CALZADO', NULL, 26.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (105, N'ECOAHORRO LA GAUCHITA ESCOBILLON BARRENDERO (CAJA X 6 UNIDADES )', NULL, 137.6100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (106, N'ECOAHORRO LA GAUCHITA ESCURRIDOR DE PLATOS PETIT', NULL, 91.4500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (107, N'ECOAHORRO LA GAUCHITA ESPONJA ACERO 1 X 14 GRS', NULL, 15.7200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (108, N'ECOAHORRO LA GAUCHITA HERMETICO RECTANGULAR 2000 ML OCLOCK', NULL, 30.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (109, N'ECOAHORRO MAT MANGUERA 3/4 SUPER REFORZADA (X 15 MTS)', NULL, 269.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (110, N'ECOAHORRO ROLAN BOLSA DE ARRANQUE 35X45', NULL, 78.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (111, N'ECOAHORRO ROMYL BROCHES DE MADERA REFORZADO ', NULL, 12.7200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (112, N'ECOAHORRO ROMYL ESPONJA BAÑO VEGETAL ', NULL, 16.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (113, N'ECOAHORRO SHAMPOO SUELTO', NULL, 25.2700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (114, N'ECOAHORRO ULTRA BOM TRAMPA CEBO MATA CUCARACHAS X6', NULL, 141.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (115, N'TEOPLAST BIDON 10 LT VIRGEN (BULTO X 13 UND)', NULL, 35.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (116, N'TEOPLAST BIDON 5 LT VIRGEN (BULTO X 24 )', NULL, 18.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (117, N'ENVASE OMEGA JABONERA 250CC (BULTO X 200 UND )', NULL, 12.8500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (118, N'ENVASE PVC 100CC C/ SPRAY ( BULTO X 350 UND)', NULL, 10.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (119, N'ENVASE PVC 250CC C/ SPRAY (BULTO X 228 UND )', NULL, 9.6100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (120, N'ENVASE PVC 500 C/ GATILLO (BULTO X 80 UND', NULL, 11.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (121, N'GATILLO PARA ENVASE X 1 LT (TS-28/400)', NULL, 10.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (122, N'TEOPLAST BOTELLA 1 LT (BULTO X 90 UND)', NULL, 7.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (123, N'TEOPLAST BOTELLA 1/2 LT (BULTO X 180 UND)', NULL, 4.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (124, N'TEOPLAST BOTELLA 1/4 LT ( BULTO X 270 UND)', NULL, 4.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (125, N'TEOPLAST TAPA ROJA BOTELLA', NULL, 0.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (126, N'FUYI ESPIRAL COUNTRY LAVANDA X12 (CAJA X 24)', NULL, 23.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (127, N'FUYI ESPIRAL VERDE ORIGINAL X12', NULL, 23.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (128, N'FUYI ESPIRALES SOBRE X 4 UND (CAJA X 12 SOBRES)', NULL, 9.1600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (129, N'GORRION ESPIRAL COLECTIVA LAVAN. SOBRE X 4 UND ( CAJA X 50 SOBRES )', NULL, 5.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (130, N'RAID ESPIRALES X12 NOCHES COUNTRY (CAJA X 12 )', NULL, 23.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (131, N'RAID ESPIRALES X12 VERDE (CAJA X 24)', NULL, 23.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (132, N'RAID ESPIRALES X4', NULL, 12.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (133, N'ECTHOL GARRAPATICIDA X70 ML', NULL, 73.2700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (134, N'FLIT LIQUIDO X400ml', NULL, 45.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (135, N'GELTEK CEBO RODENTICIDA 12 X 10 GRS', NULL, 59.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (136, N'GELTEK CUCA CEBADO CABLE CANAL X 6', NULL, 32.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (137, N'HOR-TAL F POLVO X 250 GRS. (X 12)', NULL, 56.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (138, N'HOR-TAL HORMIG LIQUIDO X60 CC', NULL, 49.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (139, N'HOR-TAL SUSPENSION CONCENTRADA  X 120 CM3.', NULL, 70.9200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (140, N'KEEPTRIN INSECTICIDA X 1LT PARA DILUIR', NULL, 253.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (141, N'ULTRAPLUS DISPENSER X 50 GRS', NULL, 13.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (142, N'FLUITRON FLUIDO ACAROINA LIQUIDO X400ML (CAJA X 12 UND)', NULL, 45.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (143, N'FUYI CREMA REPELENTE DE INSECTOS 60 GRS.', NULL, 25.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (144, N'FUYI MATA MOSCAS Y MOSQUITOS. AEROSOL X 360 CM3. ( PAQ X 12 UND)', NULL, 46.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (145, N'OFF AEROSOL ( PAQ X 12 UND)', NULL, 73.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (146, N'OFF FAMILY CREMA REPELENTE DE INSECTOS X 60 GRS. (CAJA X 12)', NULL, 31.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (147, N'RAID AEROSOL MATA CUCARACHA', NULL, 91.5300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (148, N'RAID MATA MOSCAS Y MOSQUITOS. AEROSOL X 360 CM3. (PAQ X 12 UND)', NULL, 59.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (149, N'RAID PAPEL ', NULL, 22.3300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (150, N'FUYI TABLETAS x16 NOCHES ( CAJA X 20 )', NULL, 29.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (151, N'FUYI TABLETAS X28 ( CAJA X 20 )', NULL, 80.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (152, N'RAID X12 NOCHES TABLETAS CONTRA MOSQUITOS Y ZANCUDOS  (CAJA X 20)', NULL, 31.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (153, N'RAID X24 NOCHES TABLETAS CONTRA MOSQUITOS Y ZANCUDOS  (CAJA X 20)', NULL, 62.2200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (154, N'BARRE FONDO CHICO 1/2 LUNA', NULL, 240.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (155, N'BARRE FONDO GRANDE 8 RUEDAS', NULL, 432.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (156, N'BOYA HONGO ', NULL, 22.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (157, N'BOYA SATÉLITE CHICA', NULL, 29.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (158, N'BOYA SATELITE GRANDE', NULL, 62.4100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (159, N'CABO P/ SACA HOJAS ', NULL, 78.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (160, N'GRANULADO POTE LISO X KG DISOLUSION RAPIDA', NULL, 237.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (161, N'INTEX ANIMALES Y NOVEDADES COCODRILO REALISTA 170X86 CM (23251/1)', NULL, 719.6700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (162, N'INTEX BRAZALETE INFLABLE DELUXE 23X15 CM (58642) (22705/0)', NULL, 131.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (163, N'INTEX CHALECO INFLABLE FUN FISH (59661) (19791/7)', NULL, 247.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (164, N'INTEX COLCHONETA P/ AGUA INTEX ECONOMATS 183X69 CM (59703) (17786/1)', NULL, 274.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (165, N'INTEX COLCHONETA P/ AGUA INTEX ESTAMPADAS 183X69 CM (59711) (23827/8)', NULL, 339.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (166, N'INTEX FLOTADOR INFLABLE KIDDIE (59586) (19604/2)', NULL, 348.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (167, N'INTEX FLOTADOR INFLABLE RANITA C/ TECHO 119X79 CM (56854) (22753/7)', NULL, 604.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (168, N'INTEX JUEGOS DE PISCINA ARO FLOTADOR ANIMAL (22759/1)', NULL, 163.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (169, N'INTEX JUEGOS DE PISCINA PELOTA ANIMALES MARINOS 61CM (59050) (23849/0)', NULL, 137.4300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (170, N'INTEX JUEGOS DE PISCINA PELOTA PARADISE 61CM (59032)(19601/5)', NULL, 115.4500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (171, N'INTEX PILETA DE LONA 3.66 X 0.91MT  MOD:10319 EASY SET (56930)(19249/9)', NULL, 4696.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (172, N'INTEX PILETA INFLABLE CARACOL PEREZOSO 145X102X74 CM (57124) (23842/7)', NULL, 1282.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (173, N'INTEX PILETA INFLABLE HONGO NEW 102X89 CM (57114) (22754/6)', NULL, 1246.4300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (174, N'INTEX PILETA INFLABLE SOFT SIDE 188X46 CM (58431) (19193/1)', NULL, 1128.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (175, N'INTEX PILETA INFLABLE STARS SET 122X25 CM (59460) (21578/1)', NULL, 916.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (176, N'INTEX PILETA INFLABLE TIBURON 201X198X109 CM (57120) (22716/6)', NULL, 2308.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (177, N'INTEX TUBO INFLABLE CIRCULAR C/ AGARRADERA 76 CM (59258) (21557/8)', NULL, 194.9200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (178, N'KIT PH', NULL, 108.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (179, N'SACA HOJAS ', NULL, 57.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (180, N'SACA HOJAS CON BOLSA', NULL, 108.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (181, N'TECNOCLOR GRANULADO POTE X KG', NULL, 180.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (182, N'TECNOCLOR H2O BIO X1 LT', NULL, 301.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (183, N'ALGUICIDA GRANEL', NULL, 35.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (184, N'CLARIFICANTE GRANEL', NULL, 35.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (185, N'GRANULADO A GRANEL X KG', NULL, 183.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (186, N'TECNOCLOR ACIDO (TECNOACID) x2,5 KG', NULL, 215.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (187, N'TECNOCLOR ALGUICIDA X 1LT', NULL, 102.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (188, N'TECNOCLOR CLARIFICANTE x1LT(TECNOFLOC-S)', NULL, 102.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (189, N'TECNOCLOR PAST. MULTIFUNCION POTE X KG', NULL, 193.2000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (190, N'TECNOCLOR PASTILLAS 50 GRS A GRANEL X KG', NULL, 254.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (191, N'TRIPLE ACCION GRANEL X KILO', NULL, 203.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (192, N'GLADE DESODORANTE PARA PISO 900 ML.', NULL, 20.3500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (193, N'POETT DESODORANTE PARA PISOS 900ML ', NULL, 22.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (194, N'PROCENEX DESODORANTE PARA PISO 900 ML ', NULL, 20.9100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (195, N'ALA DETERGENTE 750 ML ', NULL, 27.5000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (196, N'ALA JABON EN POLVO LAVADO A MANO Y LAVARROPAS SEMI-AUTOMATICO X 400 GRS. (PACK X24 UNIDADES', NULL, 29.5300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (197, N'ALA JABON EN POLVO MATIC X 400 GRS. (PACK X24 UNIDADES)', NULL, 29.5300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (198, N'PRIX ULTRA JABON EN POLVO X 400 MULTIFUNCION ', NULL, 13.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (199, N'AYUDIN LAVANDINA  ORIGINAL 1LT(CAJA X 15 UNIDADES)', NULL, 26.3400, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (200, N'AYUDIN LAVANDINA CON FRAGANCIA 1LT', NULL, 26.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (201, N'AYUDIN LAVANDINA CON FRAGANCIA 2LT ', NULL, 51.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (202, N'AYUDIN LAVANDINA DOBLE RENDIMIENTO 1LT (CAJA X 15 UNIDADES)', NULL, 34.2200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (203, N'AYUDIN LAVANDINA DOBLE RENDIMIENTO 2LT(CAJA X 8 UNIDADES)', NULL, 63.2500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (204, N'AYUDIN LAVANDINA MAXIMA PUREZA X 2 LT', NULL, 46.5500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (205, N'AYUDIN LAVANDINA MAXIMA PUREZA X1LT(CAJA X 15UNIDADES)', NULL, 24.7000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (206, N'AYUDIN LAVANDINA ORIGINAL 2LT(CAJA X 8 UNIDADES)', NULL, 51.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (207, N'HOGAR LAVANDINA X 1LT (CAJA X 15 UNIDADES)', NULL, 14.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (208, N'HOGAR LAVANDINA X 2LT (CAJA X 8 UNIDADES)', NULL, 25.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (209, N'BLEM LUSTRA MUEBLES. AEROSOL X 360 CM3. ', NULL, 63.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (210, N'CIF CREMA ORIGINAL 375 ml  (CAJA X 12 UNIDADES)', NULL, 27.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (211, N'GRAN FRAGATA FOSFOROS X 220', NULL, 8.9700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (212, N'POETT PASTILLA AROMATIZANTE PARA INODOROS CON RED PROTECTORA X 25 GRS. ', NULL, 18.2500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (213, N'VIVERE SUAVIZANTE CLASICO 900 CC', NULL, 29.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (214, N'MATERIA PRIMA ACEITE LIMON 1', NULL, 1045.9900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (215, N'BAIRESPEL PAPEL HIGIENICO 8 X 300', NULL, 148.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (216, N'CAMPANITA PAPEL HIGIENICO SOFT 12x4x30', NULL, 232.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (217, N'CAMPANITA PAPEL HIGIENICO SOFT 12x6x30', NULL, 344.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (218, N'ELEGANTE PAPEL HIGIENICO 12X6X30 CON ALOE VERA', NULL, 483.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (219, N'ELEGANTE PAPEL HIGIENICO 4X30X12 -COD900', NULL, 309.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (220, N'ELEGANTE PAPEL HIGIENICO 4X80X12 -COD906', NULL, 698.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (221, N'ELEGANTE PAPEL HIGIENICO 6X30X8 -COD901', NULL, 309.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (222, N'ELEGANTE PAPEL HIGIENICO DOBLE HOJA 4X30X12 BL -COD910', NULL, 472.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (223, N'M&G PAPEL HIGIENICO BLANCO 24 X 50 MTS', NULL, 157.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (224, N'NEW PEL AZUL PRECORT. 48x1x70', NULL, 312.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (225, N'NEW PEL DESNUDO 48X1X90  COD 15', NULL, 496.3300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (226, N'NEW PEL ROJO PRECORT. 30x1x90 COD 10', NULL, 246.9600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (227, N'NEW PEL ROLLO 8x300 DECORADO', NULL, 247.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (228, N'NEW PEL ROLLO TOALLA 2X200 MTS COD. 1026', NULL, 195.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (229, N'NEW PEL VERDE PRECORT. 48x1x50 COD1', NULL, 222.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (230, N'NEW PEL VERDE PREMIUM 30X1X120 COD22', NULL, 395.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (231, N'ULTRAPEL 360-12X60MT', NULL, 265.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (232, N'BAIRESPEL TOALLAS INTERCALADAS BEIGE 20 X 24 CM (CAJA X 10)', NULL, 162.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (233, N'ELEGANTE PAÑUELOS EXPENDEDORES 30X12 UNID-985', NULL, 81.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (234, N'ELEGANTE PAÑUELOS POCKET 30X6X12 -984', NULL, 18.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (235, N'ELEGANTE SERVILLETA CAJA X1000 -COD290', NULL, 113.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (236, N'BAIRESPEL TOALLAS INTERCALADAS BLANCAS  20 X 24 CM (CAJA X 10)', NULL, 186.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (237, N'CAMPANITA ROLLO COCINA 3x40X12 MULTIUSO', NULL, 209.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (238, N'CELESTIAL ROLLO COCINA 12x3x40', NULL, 200.3700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (239, N'DICHA ROLLO COCINA DICHA X8 -COD427', NULL, 194.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (240, N'ELEGANTE ROLLO COCINA 3X100X8 -COD926', NULL, 426.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (241, N'ELEGANTE ROLLO COCINA 3X50X8 SULLEG -COD127', NULL, 231.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (242, N'ELEGANTE ROLLO COCINA PREMIUM MAXIMA ABSORCION 3X60X8 -COD928', NULL, 266.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (243, N'NEW PEL ROLLO COCINA DESNUDO  8X300 -COD74', NULL, 199.9100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (244, N'NEW PEL ROLLO COCINA SUPER MEGA 8X300 -COD77', NULL, 247.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (245, N'NEW PEL ROLLO DE COCINA 8X3X150 PAÑOS (COD50)', NULL, 176.6100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (246, N'SOL MAYOR ROLLO COCINA 12x3x40', NULL, 200.3700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (247, N'GLADE AROMATIZANTE DE AMBIENTE. AEROSOL X 360 CM3.', NULL, 32.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (248, N'LYSOFORM DESINFECTANTE DE AMBIENTES Y SUPERFICIES. AEROSOL 360 CM3.', NULL, 56.2500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (249, N'MAKE FRESH AROMATIZANTE DE AMBIENTES. AEROSOL X 270 CM3. ', NULL, 66.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (250, N'POETT AEROSOL AROMATIZANTE AMBIENTE ', NULL, 33.7500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (251, N'SWEET HOME DISPENSADOR AUTOMATICO ', NULL, 264.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (252, N'317 KIT COLOR', NULL, 48.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (253, N'HEAD & SHOULDERS ACONDICIONADOR / SHAMPOO X 200 ML.', NULL, 41.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (254, N'HEADLY POLVO DECO. 20', NULL, 12.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (255, N'PANTENE PRO-V SHAMPOO / ACONDICIONADOR X 200 ML. ', NULL, 67.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (256, N'PANTENE SACHET ACONDICIONAD 10ML', NULL, 3.5400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (257, N'PANTENE SACHET SHAMPOO 10ML', NULL, 3.5400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (258, N'PLUSBELLE ACONDICIONADOR / SHAMPOO X 1LT ', NULL, 51.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (259, N'PLUSBELLE X 1 LT SHAMPOO DETOX', NULL, 51.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (260, N'PLUSBELLE X 1LT ACONDICIONADOR DETOX', NULL, 51.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (261, N'SEDAL DOY PACK 300ML SHAMPOO / ACONDICIONADOR', NULL, 60.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (262, N'SEDAL SACHET 10ML ACONDICIONADOR CREMA BALANCE ', NULL, 2.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (263, N'SEDAL SACHET 10ML SHAMPOO  / ACONDICIONADOR', NULL, 2.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (264, N'SEDAL x190 ml ACCONDICIONADOR / SHAMPOO', NULL, 42.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (265, N'COLGATE DENTIFRICO HERBAL X 90 GRS. (X 48)', NULL, 31.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (266, N'COLGATE DENTIFRICO ORIGINAL 90 GR (X 72)', NULL, 35.2000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (267, N'COLGATE DENTIFRICO X 70GRS', NULL, 29.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (268, N'KOLYNOS CREMA DENTAL FRESCURA INTENSA  70 G', NULL, 23.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (269, N'KOLYNOS DENTRIFICO 90 GRS.', NULL, 25.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (270, N'ODOL 2 CREMA DENTAL DIENTES BLANCOS 90 GR (X 72)
', NULL, 31.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (271, N'ODOL 2 CREMA DENTAL DOBLE ACCION 70 GR (X 72)', NULL, 18.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (272, N'ODOL 2 CREMA DENTAL DOBLE ACCION 90 GR

', NULL, 20.5800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (273, N'AXE DESODORANTE EN AEROSOL X 150 ML.', NULL, 43.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (274, N'DOVE DESODORANTE AEROSOL 100 GRS ORIGINAL', NULL, 80.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (275, N'DOVE DESODORANTE AEROSOL 54 GRS. ORIGINAL COMPRIMIDO (X 12)', NULL, 80.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (276, N'IMPULSE DESODORANTE AEROSOL 107 GRS ', NULL, 54.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (277, N'IMPULSE PERFUME PARA EL CUERPO EN AEROSOL X 58 GRS.', NULL, 32.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (278, N'PATRICHS DESODORANTE EN  AEROSOL X 164 ML. ', NULL, 56.4500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (279, N'REXONA DESODORANTE AEROSOL  MUJER ', NULL, 40.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (280, N'REXONA DESODORANTE AEROSOL HOMBRE ', NULL, 48.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (281, N'REXONA ODORONO DESODORANTE CREMA 60 GRS (X 12)', NULL, 35.2000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (282, N'ALGODON ESTRELLA 75 GRS', NULL, 15.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (283, N'COLGATE CEPILLO DE DIENTES  TIRA X6', NULL, 73.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (284, N'COLGATE CEPILLO PREMIER CLEAN CON LIMPIADOR DE LENGUA', NULL, 10.4100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (285, N'DONCELLA ALGODON HIDROFILO CLASICO X 140 GRS. (X 20)', NULL, 31.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (286, N'DONCELLA ALGODON HIDROFILO CLASICO X 300 GRS. (X 100)', NULL, 68.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (287, N'DONCELLA ALGODON HIDROFILO CLASICO X 70 GRS. (X 40)', NULL, 15.5900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (288, N'DONCELLA HISOPOS EXTRA SUAVE  x100 (CAJA 24 UND)', NULL, 27.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (289, N'GILLETE  MAQUINA DE AFEITAR ULTRAGRIP 3 HOJAS', NULL, 40.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (290, N'GILLETE PRESTOBARBA 3 SENSE CARE', NULL, 37.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (291, N'GILLETE PRESTOBARBA EXCEL FEMENINA ', NULL, 33.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (292, N'GILLETE PRESTOBARBA ULTRAGRIP', NULL, 24.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (293, N'GOODMAX CEPILLO DE DIENTES ', NULL, 11.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (294, N'GOODMAX MAQUINA DE AFEITAR 3 FILOS', NULL, 15.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (295, N'MINORA  PRESTOBARBA DOBLE  HOJA ', NULL, 16.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (296, N'REXONA EFFICIENT TALCO DESODORANTE PARA PIES X 100 GRS. (X 12)', NULL, 29.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (297, N'SANICOL ALCOHOL 500 CC (x20)', NULL, 28.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (298, N'VENUS MAQUINA D/AFEITAR SIMPLY 3', NULL, 37.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (299, N'VILLA IRIS ALCOHOL ETILICO X 500 CM3. (X 20)', NULL, 29.0400, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (300, N'CALIPSO PROTECTOR MULTIESTILO DUAL X 20 (BUL X 20 ', NULL, 26.1400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (301, N'CALIPSO PROTECTORES DIARIOS  CON FRAGANCIA X 20 (BUL X 40', NULL, 21.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (302, N'CALIPSO PROTECTORES DIARIOS COLA LESS X 20 (BUL X 20)', NULL, 26.1400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (303, N'CALIPSO TOALLITAS CON ALAS VERDE X 8(BUL X 50)', NULL, 16.7700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (304, N'CALIPSO TOALLITAS NOCTURNAS X 8 (BUL X 50 )', NULL, 30.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (305, N'CALIPSO TOALLITAS POCKET NORMAL X 8 (BUL X 50)', NULL, 16.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (306, N'CALIPSO TOALLITAS TANGA (CAJA X40)', NULL, 21.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (307, N'DONCELLA PROTECTOR DIARIO ANATMICO CON DESODORANTE X 20 UND (X 30)', NULL, 14.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (308, N'DONCELLA PROTECTOR DIARIO ANATOMICO SIN DESODORANTE X 20 UND. (X 30)', NULL, 14.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (309, N'DONCELLA PROTECTOR DIARIO CLASICO C/DESOD. X 20 UND. (X 30)', NULL, 15.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (310, N'DONCELLA PROTECTOR DIARIO CLASICO S/DESOD. X 20 UND. (X 30)', NULL, 15.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (311, N'DONCELLA TOALLITAS  NOCTURNAS  ULTRA ABSORBENTE x8 (X 50 EL BULTO)', NULL, 19.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (312, N'DONCELLA TOALLITAS CON ALAS  TANGA x8', NULL, 14.0700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (313, N'DONCELLA TOALLITAS CON ALAS CON PERFUME x8', NULL, 11.9500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (314, N'DONCELLA TOALLITAS CON ALAS SIN DESODORANTE 8 UND, (X 50) ', NULL, 11.9500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (315, N'DONCELLA TOALLITAS CON ALAS ULTRAFINAS  X 8 UND. (X 50)', NULL, 16.5800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (316, N'DONCELLA TOALLITAS SIN ALAS NORMAL SIN DESODORANTE (X 50)', NULL, 10.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (317, N'LINA TOALLITAS NORMAL CON  ALAS (X 8) ART. 30223597 (X 64)', NULL, 14.2900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (318, N'SHE PROTECTORES DIARIOS ULTRAFINA POCKET X 20', NULL, 10.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (319, N'SHE TOALLITAS FEMENINAS CON ALAS POCKET X8', NULL, 10.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (320, N'ALA MULTIACCION JABON DE LAVAR EN PAN X 200 GRS. (X 84)', NULL, 12.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (321, N'DAIAN JABON DE TOCADOR VARIEDAD 3X90', NULL, 17.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (322, N'DOVE JABON DE TOCADOR DELICIUS CARE KARITE 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (323, N'DOVE JABON DE TOCADOR DELICIUS CARE LECHE DE COCO 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (324, N'DOVE JABON DE TOCADOR EXFOLIACION SUAVE 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (325, N'DOVE JABON DE TOCADOR GO FRESH REVIGORIZANTE 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (326, N'DOVE JABON DE TOCADOR MEN CARE CLEAN COMFORT 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (327, N'DOVE JABON DE TOCADOR MEN CARE EXTRA FRESH 90 GRS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (328, N'DOVE JABON DE TOCADOR ORIGINAL 90 GRS', NULL, 33.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (329, N'LUX JABON DE TOCADOR 3X125 GRS. ', NULL, 56.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (330, N'LUX JABON DE TOCADOR X 125 GRS.  ', NULL, 18.7000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (331, N'MUSMI JABON EN PAN CON GLICERINA X 200 GRS.', NULL, 8.8500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (332, N'PLUSBELLE JABON DE TOCADOR 3 X 125 GRS. ', NULL, 40.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (333, N'PLUSBELLE JABON DE TOCADOR X 125 GRS. ', NULL, 14.8500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (334, N'REXONA JABON DE TOCADOR X 125 GRS. ', NULL, 14.2900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (335, N'SEISEME JABON DE LAVAR DE PRIMERA EN PAN X 300 GRS. (X 50)', NULL, 22.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (336, N'SIGNO JABON DE TOCADOR CON GLICERINA X 90 GRS', NULL, 4.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (337, N'SIGNO JABON DE TOCADOR x3', NULL, 15.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (338, N'SIGNO JABON EN PAN  BLANCO x 150 GRS', NULL, 5.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (339, N'SIGNO JABON EN POLVO MATIC X400(CAJA X 24UNIDADES)', NULL, 19.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (340, N'SIGNO JABON EN POLVO REGULAR(CAJA X 24 UNIDADES)', NULL, 19.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (341, N'SIGNO JABON PAN OCRE', NULL, 5.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (342, N'SIRKIS JABON / DETERGENTE EN BARRA X 200 GRS', NULL, 8.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (343, N'HUGGIES PAÑALES  AMARILLO', NULL, 55.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (344, N'PAMPERS PAÑALES SUPERSEC ', NULL, 53.8900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (345, N'FLORIDA BALDE  COLOR 12 LTS.', NULL, 53.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (346, N'FLORIDA BALDE C/ ESCURRIDOR 16,5 LTS', NULL, 114.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (347, N'FLORIDA RECIPIENTE DE RESIDUO DE 70LT. NEGRO', NULL, 438.9100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (348, N'GAVAPLAST BALDE DEL COMBO 10 LT', NULL, 37.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (349, N'GAVAPLAST BALDE DEL COMBO 10 LT NEGRO', NULL, 35.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (350, N'BARRE HOJAS PROFESIONAL', NULL, 51.1200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (351, N'BATEN BARRE HOJAS, (CAJA X24 UND)', NULL, 11.8900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (352, N'FLORIDA CESTO RECTANGULAR CALADO  P/ROPA  C/TAPA', NULL, 273.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (353, N'FLORIDA CESTO REDONDO CALADO  P/ ROPA  C/TAPA', NULL, 192.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (354, N'LA GAUCHITA CESTO PAPELERO  9LT (CAJA X 12 UNIDADES)', NULL, 55.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (355, N'LA GAUCHITA CESTO VAIVEN 3LTS (CAJA X 12 UNIDADES)', NULL, 82.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (356, N'LA GAUCHITA CESTO VAIVEN 6 LTS (CAJA X 12 UNIDADES )', NULL, 116.5500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (357, N'FLORIDA FUENTON REDONDO COLOR 12 LTS.', NULL, 50.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (358, N'FLORIDA FUENTON REDONDO COLOR 14 LTS.', NULL, 55.5500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (359, N'FLORIDA FUENTON REDONDO COLOR 16 LTS.', NULL, 63.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (360, N'FLORIDA FUENTON REDONDO COLOR 28 LTS.', NULL, 100.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (361, N'FLORIDA FUENTON REDONDO COLOR 35 LTS.', NULL, 129.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (362, N'FLORIDA FUENTON REDONDO COLOR 52 LTS.', NULL, 195.7200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (363, N'FLORIDA PALANGANA COLOR 4 LTS.', NULL, 20.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (364, N'FLORIDA PALANGANA COLOR 6 LTS.', NULL, 30.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (365, N'FLORIDA PALANGANA COLOR 9 LTS.', NULL, 44.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (366, N'D PLAS PALA CON CABO FIJO, (CAJA X12 UND)', NULL, 26.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (367, N'LA GAUCHITA PALA SHARK', NULL, 27.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (368, N'FLORIDA RECIPIENTE REDONDO P/ RESIDUOS COLOR 7 LTS.', NULL, 58.4700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (369, N'FLORIDA TACHO BASURA 12 LT ', NULL, 83.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (370, N'FLORIDA TACHO BASURA 13LT C/PEDAL ', NULL, 202.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (371, N'GAVAPLAST CESTO PAPELERO A PEDAL 15 LT. NEGRO', NULL, 164.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (372, N'FLORIDA BAÑERA BEBE 35 LT CELESTE / ROSA', NULL, 161.9700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (373, N'FLORIDA BANQUETA', NULL, 104.0200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (374, N'FLORIDA PELELA CELESTE', NULL, 22.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (375, N'FLORIDA PELELA ROSA', NULL, 22.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (376, N'FLORIDA SILLA P/JARDIN ', NULL, 272.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (377, N'FLORIDA SILLON INFANTIL ', NULL, 123.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (378, N'FLORIDA SILLON P/JARDIN ', NULL, 296.1600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (379, N'AUTOPOLISH CERA ', NULL, 53.7200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (380, N'BRILLO SILICONADO PARA AUTOS', NULL, 40.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (381, N'CERA PARA AUTOS', NULL, 70.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (382, N'LIMPIA MOTOR PURO', NULL, 46.8700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (383, N'REVIVIDOR ', NULL, 121.1400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (384, N'REVIVIDOR DE CUBIERTAS', NULL, 51.9900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (385, N'REVIVIDOR PREMIUM', NULL, 259.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (386, N'SHAMPOO PARA AUTO', NULL, 53.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (387, N'SILICONA PARA INTERIORES', NULL, 42.2700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (388, N'x5 SILICONA PARA INTERIORES CON CAJA Y ETIQUETA', NULL, 249.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (389, N'DETERGENTE AMONIACAL 30%', NULL, 44.2200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (390, N'DETERGENTE AZUL', NULL, 13.5400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (391, N'DETERGENTE MANZANA', NULL, 20.9700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (392, N'DETERGENTE ROJO', NULL, 14.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (393, N'DETERGENTE SODICO 24%', NULL, 40.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (394, N'DETERGENTE SODICO 30%', NULL, 27.2500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (395, N'DETERGENTE ULTRA CONCENTRADO', NULL, 27.4400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (396, N'DETERGENTE VERDE', NULL, 11.5300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (397, N'X5 DETERGENTE AZUL ', NULL, 103.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (398, N'X5 DETERGENTE AZUL CON CAJA Y ETIQUETA', NULL, 111.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (399, N'X5 DETERGENTE DE MANZANA CON CAJA Y ETIQUETA', NULL, 153.2200, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (400, N'X5 DETERGENTE MANZANA', NULL, 144.9500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (401, N'X5 DETERGENTE ROJO', NULL, 108.9200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (402, N'X5 DETERGENTE ROJO CON CAJA Y ETIQUETA', NULL, 117.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (403, N'X5 DETERGENTE ULTRA CONCENTRADO', NULL, 180.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (404, N'X5 DETERGENTE ULTRA CONCENTRADO CON CAJA Y ETIQUETA', NULL, 189.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (405, N'X5 DETERGENTE VERDE', NULL, 92.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (406, N'X5 DETERGENTE VERDE CON CAJA Y ETIQUETA', NULL, 100.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (407, N'1/4 ESENCIA ARPEAGE', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (408, N'1/4 ESENCIA BABY JOHNSON PISO', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (409, N'1/4 ESENCIA CITRONELA', NULL, 76.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (410, N'1/4 ESENCIA CITRONELA NATURAL', NULL, 121.6100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (411, N'1/4 ESENCIA CONIGLIO', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (412, N'1/4 ESENCIA FANTASIA PREMIX ', NULL, 66.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (413, N'1/4 ESENCIA FLORAL', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (414, N'1/4 ESENCIA LAVANDA', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (415, N'1/4 ESENCIA LIMON ', NULL, 66.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (416, N'1/4 ESENCIA LYSOFORM', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (417, N'1/4 ESENCIA MARINA', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (418, N'1/4 ESENCIA PINOLUZ', NULL, 66.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (419, N'1/4 ESENCIA POETT PRIMAVERA', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (420, N'1/4 ESENCIA PROCENEX', NULL, 78.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (421, N'ESENCIA ARPEAGE', NULL, 231.7600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (422, N'ESENCIA BABY JOHNSON', NULL, 240.8400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (423, N'ESENCIA BOSQUE BAMBOO', NULL, 201.3700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (424, N'ESENCIA CITRICO', NULL, 184.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (425, N'ESENCIA CITRONELA', NULL, 254.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (426, N'ESENCIA CITRONELA NATURAL', NULL, 350.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (427, N'ESENCIA CONIGLIO', NULL, 212.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (428, N'ESENCIA FANTASIA', NULL, 134.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (429, N'ESENCIA FLORAL', NULL, 204.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (430, N'ESENCIA LAVANDA', NULL, 237.0700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (431, N'ESENCIA LIMON', NULL, 152.7000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (432, N'ESENCIA LYSOFORM', NULL, 209.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (433, N'ESENCIA MARINA', NULL, 235.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (434, N'ESENCIA PINOLUZ', NULL, 184.6600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (435, N'ESENCIA POETT PRIMAVERA', NULL, 190.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (436, N'ESENCIA PROCENEX', NULL, 254.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (437, N'JABON LIQUIDO BAJA ESPUMA AZUL', NULL, 13.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (438, N'JABON LIQUIDO BAJA ESPUMA CLASICO', NULL, 13.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (439, N'JABON LIQUIDO BAJA ESPUMA OXI', NULL, 23.2300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (440, N'JABON LIQUIDO BAJA ESPUMA PREMIUM', NULL, 18.1600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (441, N'JABON LIQUIDO BAJA ESPUMA VIOLETA', NULL, 18.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (442, N'SHAMPOO SUELTO T. DOVE', NULL, 38.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (443, N'X5 JABON LIQUIDO BAJA ESPUMA AZUL ', NULL, 105.7400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (444, N'X5 JABON LIQUIDO BAJA ESPUMA AZUL CON CAJA Y ETIQUETA', NULL, 119.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (445, N'X5 JABON LIQUIDO BAJA ESPUMA CLASICO', NULL, 106.4700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (446, N'X5 JABON LIQUIDO BAJA ESPUMA CLASICO CON CAJA Y ETIQUETA', NULL, 120.3700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (447, N'X5 JABON LIQUIDO BAJA ESPUMA OXI', NULL, 161.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (448, N'X5 JABON LIQUIDO BAJA ESPUMA OXI CON CAJA Y ETIQUETA', NULL, 175.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (449, N'X5 JABON LIQUIDO BAJA ESPUMA PREMIUM', NULL, 122.8900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (450, N'X5 JABON LIQUIDO BAJA ESPUMA PREMIUM CON CAJA Y ETIQUETA', NULL, 136.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (451, N'X5 JABON LIQUIDO BAJA ESPUMA VIOLETA', NULL, 120.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (452, N'X5 JABON LIQUIDO BAJA ESPUMA VIOLETA CON CAJA Y ETIQUETA', NULL, 134.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (453, N'X5 LT JABON LIQUIDO PARA MANOS FRUTOS ROJOS', NULL, 210.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (454, N'PERFUMINA BABY JOHNSON', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (455, N'PERFUMINA CAMPOS DE ALGODON', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (456, N'PERFUMINA COCO', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (457, N'PERFUMINA COMFORT', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (458, N'PERFUMINA CONIGLIO', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (459, N'PERFUMINA DOVE', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (460, N'PERFUMINA FRUTILLA', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (461, N'PERFUMINA JAZMIN', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (462, N'PERFUMINA LAVANDA', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (463, N'PERFUMINA MELON', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (464, N'PERFUMINA SIMIL IMPORTADOS ACQUA DI GIO MASC', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (465, N'PERFUMINA SIMIL IMPORTADOS AMARIGE', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (466, N'PERFUMINA SIMIL IMPORTADOS CAROLINA HERRERA', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (467, N'PERFUMINA SIMIL IMPORTADOS KENZO FLOWERS', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (468, N'PERFUMINA SIMIL IMPORTADOS KENZO MASC', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (469, N'PERFUMINA SIMIL IMPORTADOS NEW BLACK', NULL, 105.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (470, N'PERFUMINA VAINICOCO', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (471, N'PERFUMINA VAINILLA ', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (472, N'PERFUMINA VIVERE', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (473, N'PERFUMINA VIVEX', NULL, 96.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (474, N'X5 LT PERFUMINA BABY JOHNSON CON CAJA Y ETIQUETA', NULL, 520.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (475, N'X5 LT PERFUMINA VAINILLA ', NULL, 511.7600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (476, N'X5 PERFUMINA CONIGLIO CON CAJA Y ETIQUETA', NULL, 519.8700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (477, N'CREMA ENJUAGUE T. DOVE', NULL, 29.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (478, N'JABON ANTISEPTICO', NULL, 27.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (479, N'JABON LIQUIDO PARA MANOS ACQUA', NULL, 22.6500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (480, N'JABON LIQUIDO PARA MANOS CITRICO', NULL, 22.6900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (481, N'JABON LIQUIDO PARA MANOS COCO', NULL, 33.6200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (482, N'JABON LIQUIDO PARA MANOS DOVE', NULL, 35.4900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (483, N'JABON LIQUIDO PARA MANOS FRAMBUESA', NULL, 21.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (484, N'JABON LIQUIDO PARA MANOS FRESIAS', NULL, 28.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (485, N'JABON LIQUIDO PARA MANOS FRUTOS ROJOS', NULL, 35.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (486, N'JABON LIQUIDO PARA MANOS MARINA', NULL, 22.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (487, N'JABON LIQUIDO PARA MANOS ROSA', NULL, 28.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (488, N'JABON LIQUIDO PARA MANOS SHOWER', NULL, 28.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (489, N'SHAMPOO PARA PERRO', NULL, 25.1700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (490, N'X5 JABON LIQUIDO PARA MANOS FRUTOS ROJOS CON CAJA Y ETIQUETA', NULL, 211.5600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (491, N'SUAVIZANTE CLASICO AMARILLO', NULL, 12.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (492, N'SUAVIZANTE CLASICO BLANCO', NULL, 11.9800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (493, N'SUAVIZANTE CLASICO CELESTE', NULL, 8.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (494, N'SUAVIZANTE CLASICO ROSA', NULL, 12.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (495, N'SUAVIZANTE CLASICO VIVEX', NULL, 12.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (496, N'SUAVIZANTE DOBLE AMARILLO', NULL, 18.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (497, N'SUAVIZANTE DOBLE BLANCO', NULL, 18.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (498, N'SUAVIZANTE DOBLE CELESTE ', NULL, 17.9400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (499, N'SUAVIZANTE DOBLE ROSA', NULL, 18.1500, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (500, N'SUAVIZANTE DOBLE VIVEX', NULL, 18.3500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (501, N'X1000 lt SUAVIZANTE CLASICO ROSA', NULL, 12.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (502, N'X1000 lt SUAVIZANTE DOBLE VIVEX', NULL, 18.3500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (503, N'X1000 SIN PERFUME SUAVIZANTE AMARILLO', NULL, 6400.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (504, N'X1000 SIN PERFUME SUAVIZANTE BLANCO', NULL, 6400.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (505, N'X1000 SIN PERFUME SUAVIZANTE CELESTE', NULL, 6400.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (506, N'X1000 SIN PERFUME SUAVIZANTE ROSA', NULL, 6400.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (507, N'x5 SUAVIZANTE CLASICO AMARILLO', NULL, 92.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (508, N'x5 SUAVIZANTE CLASICO AMARILLO CON CAJA Y ETIQUETA', NULL, 100.5900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (509, N'x5 SUAVIZANTE CLASICO BLANCO', NULL, 82.8700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (510, N'x5 SUAVIZANTE CLASICO BLANCO CON CAJA Y ETIQUETA', NULL, 91.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (511, N'X5 SUAVIZANTE CLASICO CELESTE', NULL, 78.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (512, N'X5 SUAVIZANTE CLASICO CELESTE CON CAJA Y ETIQUETA', NULL, 92.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (513, N'x5 SUAVIZANTE CLASICO ROSA', NULL, 92.3100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (514, N'x5 SUAVIZANTE CLASICO ROSA CON CAJA Y ETIQUETA', NULL, 100.5900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (515, N'x5 SUAVIZANTE CLASICO VIVEX', NULL, 79.5500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (516, N'x5 SUAVIZANTE CLASICO VIVEX CON CAJA Y ETIQUETA', NULL, 113.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (517, N'X5 SUAVIZANTE DOBLE AMARILLO', NULL, 118.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (518, N'X5 SUAVIZANTE DOBLE AMARILLO CON CAJA Y ETIQUETA', NULL, 127.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (519, N'X5 SUAVIZANTE DOBLE BLANCO', NULL, 99.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (520, N'X5 SUAVIZANTE DOBLE BLANCO CON CAJA Y ETIQUETA', NULL, 108.2100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (521, N'X5 SUAVIZANTE DOBLE CELESTE', NULL, 116.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (522, N'X5 SUAVIZANTE DOBLE CELESTE CAJA Y ETIQUETA', NULL, 124.3600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (523, N'X5 SUAVIZANTE DOBLE ROSA', NULL, 118.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (524, N'X5 SUAVIZANTE DOBLE ROSA CON CAJA Y ETIQUETA', NULL, 132.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (525, N'X5 SUAVIZANTE DOBLE VIVEX', NULL, 105.1100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (526, N'X5 SUAVIZANTE DOBLE VIVEX CON CAJA Y ETIQUETA', NULL, 113.3800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (527, N'AHUYENTA GATOS', NULL, 37.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (528, N'ALCOHOL EN GEL', NULL, 18.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (529, N'AMONIACO LIMPIADOR', NULL, 92.7800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (530, N'APRESTO SILICONADO', NULL, 30.1600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (531, N'BIDON X10 LT REGULADOR DE PH', NULL, 174.9300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (532, N'BLANQUEADOR', NULL, 72.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (533, N'BRILLO ACRILICO', NULL, 55.8700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (534, N'CERA NATURAL', NULL, 33.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (535, N'CERA NATURAL SILICONADA', NULL, 15.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (536, N'CERA NEGRA', NULL, 42.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (537, N'CERA ROJA', NULL, 42.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (538, N'CIF CREMOSO SUELTO', NULL, 28.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (539, N'CITRONELLA PARA ANTORCHAS', NULL, 86.3600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (540, N'CLORO', NULL, 13.7500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (541, N'DESENGRASANTE AMONIACAL', NULL, 14.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (542, N'DESENGRASANTE MULTIPROPOSITO', NULL, 17.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (543, N'DESENGRASANTE/QUITAMANCHAS', NULL, 25.7900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (544, N'DESODORANTE DE PISO X LT', NULL, 6.3500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (545, N'DESTAPA CAÑERIA', NULL, 6.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (546, N'DILUYENTE', NULL, 38.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (547, N'ECHO LISTO', NULL, 11.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (548, N'FLIT LIQUIDO', NULL, 73.6700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (549, N'FLUIDO-ACAROINA', NULL, 73.6700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (550, N'GEL CON LAVANDINA', NULL, 16.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (551, N'GEL QUITA SARRO', NULL, 16.9500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (552, N'LAVANDINA', NULL, 5.8900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (553, N'LAVANDINA CON DESENGRASANTE', NULL, 5.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (554, N'LAVANDINA ROPA BLANCA', NULL, 3.1000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (555, N'LAVANDINA ROPA COLOR', NULL, 18.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (556, N'LIMPIA BAÑOS', NULL, 23.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (557, N'LIMPIA VIDRIOS MULTISUPERFICIES', NULL, 12.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (558, N'LUSTRA MUEBLES', NULL, 54.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (559, N'OXIPOWER LIQUIDO', NULL, 52.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (560, N'OXIPOWER POLVO', NULL, 58.7200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (561, N'REMOVEDOR DE CERA', NULL, 36.9100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (562, N'X5 ALCOHOL EN GEL', NULL, 132.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (563, N'X5 CERA NEGRA', NULL, 277.9900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (564, N'X5 CLORO', NULL, 109.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (565, N'X5 CLORO CON CAJA Y ETIQUETA', NULL, 117.9200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (566, N'X5 DESENGRASANTE AMONIACAL ', NULL, 112.1900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (567, N'X5 DESENGRASANTE AMONIACAL CON CAJA Y ETIQUETA', NULL, 119.8300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (568, N'X5 DESODORANTE DE PISO CON CAJA Y ETIQUETA', NULL, 71.6000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (569, N'X5 JABON LIQUIDO PARA MANOS FRAMBUESA', NULL, 141.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (570, N'x5 LAVANDINA CON CAJA Y ETIQUETA', NULL, 71.4600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (571, N'X5 LAVANDINA ROPA BLANCA', NULL, 36.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (572, N'X5 LAVANDINA ROPA BLANCA CON CAJA Y ETIQUETA', NULL, 44.3200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (573, N'X5 LAVANDINA ROPA COLOR', NULL, 123.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (574, N'X5 LAVANDINA ROPA COLOR CON CAJA Y ETIQUETA', NULL, 131.9900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (575, N'X5 LIMPIA VIDRIOS MULTISUPERFICIES', NULL, 78.5700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (576, N'X5 LIMPIA VIDRIOS MULTISUPERFICIES CON CAJA Y ETIQUETA', NULL, 97.2300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (577, N'x5 LT CERA NATURAL', NULL, 223.5400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (578, N'x5 LT CERA NATURAL CON CAJA Y ETIQUETA', NULL, 231.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (579, N'X5 LT CERA NEGRA CON CAJA Y ETIQUETA', NULL, 286.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (580, N'X5 LT CERA ROJA', NULL, 277.9900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (581, N'X5 LT CIF CREMOSO SUELTO CON CAJA Y ETIQUETA', NULL, 202.1400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (582, N'X5 LT ECHO LISTO', NULL, 93.5800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (583, N'X5 LT GEL CON LAVANDINA', NULL, 127.6100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (584, N'X5 LT GEL QUITA SARRO', NULL, 116.0900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (585, N'X5 LT LIMPIA BAÑOS CON CAJA Y ETIQUETA', NULL, 123.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (586, N'X5 REVIVIDOR', NULL, 743.8100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (587, N'X5LT DESODORANTE PISOS', NULL, 65.9000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (588, N'X5LT LAVANDINA', NULL, 63.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (589, N'x1000 lt CERA NATURAL', NULL, 33.8200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (590, N'x1000 lt CERA NEGRA', NULL, 43.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (591, N'x1000 lt CERA ROJA', NULL, 43.2600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (592, N'x1000 lt CLORO', NULL, 14.0800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (593, N'x1000 lt DESENGRASANTE AMONIACAL', NULL, 14.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (594, N'x1000 lt DESENGRASANTE MULTIPROPOSITO', NULL, 18.9700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (595, N'x1000 lt DESENGRASANTE/QUITAMANCHAS', NULL, 26.3900, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (596, N'x1000 lt DETERGENTE AMONIACAL 30%', NULL, 52.4100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (597, N'x1000 lt DETERGENTE AZUL', NULL, 16.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (598, N'x1000 lt DETERGENTE MANZANA', NULL, 24.8600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (599, N'x1000 lt DETERGENTE ROJO', NULL, 17.1700, NULL, NULL, 1)
GO
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (600, N'x1000 lt DETERGENTE SODICO 24%', NULL, 30.0700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (601, N'x1000 lt DETERGENTE ULTRA CONCENTRADO', NULL, 32.5200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (602, N'x1000 lt DETERGENTE VERDE', NULL, 13.6700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (603, N'x1000 lt JABON LIQUIDO BAJA ESPUMA AZUL', NULL, 13.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (604, N'x1000 lt JABON LIQUIDO BAJA ESPUMA CLASICO', NULL, 13.0300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (605, N'x1000 lt JABON LIQUIDO BAJA ESPUMA OXI', NULL, 23.2300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (606, N'x1000 lt JABON LIQUIDO BAJA ESPUMA PREMIUM', NULL, 18.1600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (607, N'x1000 lt JABON LIQUIDO BAJA ESPUMA VIOLETA', NULL, 18.2400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (608, N'x1000 lt LIMPIA VIDRIOS MULTISUPERFICIES', NULL, 11.6300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (609, N'x1000 lt SUAVIZANTE CELESTE DOBLE', NULL, 13.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (610, N'X1000 lt SUAVIZANTE CLASICO AMARILLO', NULL, 12.5100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (611, N'X1000 lt SUAVIZANTE CLASICO BLANCO', NULL, 10.6600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (612, N'x1000 lt SUAVIZANTE CLASICO CELESTE', NULL, 8.3400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (613, N'X1000 lt SUAVIZANTE CLASICO VIVEX', NULL, 12.1800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (614, N'x1000 lt SUAVIZANTE DOBLE AMARILLO', NULL, 18.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (615, N'x1000 lt SUAVIZANTE DOBLE BLANCO', NULL, 18.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (616, N'x1000 lt SUAVIZANTE DOBLE ROSA', NULL, 18.1500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (617, N'CLEANTEX FRANELA ', NULL, 10.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (618, N'NENU FRANELA ESPECIAL ', NULL, 12.4300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (619, N'LAFFITTE GUANTE MICROFIBRA AUTO Y HOGAR - AJ28', NULL, 84.2700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (620, N'LAFFITTE PAÑO MICROFIBRA 2 EN 1 30X30 - AJ25', NULL, 50.6700, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (621, N'LAFFITTE PAÑO MICROFIBRA 40X60 CM - AJ27', NULL, 76.3000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (622, N'LAFFITTE PAÑO MICROFIBRA 40X60 CM 550 GRS -AJ47', NULL, 143.6800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (623, N'LAFFITTE PAÑO MICROFIBRA CORTE LASER 30X40 CM CELESTE -AJ46', NULL, 74.0500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (624, N'LAFFITTE PAÑO MICROFIBRA LIMP/SECADO 40X80 CM - AJ41', NULL, 104.2500, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (625, N'LAFFITTE PAÑO MICROFIBRA LIMPIA VIDRIO 30X35 CM -AJ45', NULL, 41.9600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (626, N'LAFFITTE PAÑO MICROFIBRA MULTIUSO 30X30 - AJ10', NULL, 22.5800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (627, N'LAFFITTE PAÑO SECADO ULTRA RAPIDO TIPO WAFLE 40X60 - AJ44', NULL, 89.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (628, N'LAFFITTE PAÑO TIPO ESPONJA SUPER ABSORBENTE 30X40 - AJ48', NULL, 61.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (629, N'BALERINA PAÑO MULTIUSO 38 X 40 (X 250)', NULL, 8.2200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (630, N'DELEBRITEX TRAPO DE PISO RAYADO', NULL, 25.9200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (631, N'ENTRESOL REJILLA  PABILO SUPER 40x42 (X 240)', NULL, 5.0100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (632, N'ENTRESOL REJILLA PABILO DOBLE (X 240)', NULL, 7.0000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (633, N'ENTRESOL REJILLA PABILO LIVIANA COMUN (X 240) ', NULL, 3.5000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (634, N'MIRTA REJILLA ', NULL, 11.0400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (635, N'REJILLA N° 20 (AMERICANA DOBLE )', NULL, 14.4000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (636, N'REJILLA N° 22  DOBLE PARA AUTO (BULTO X 60)', NULL, 20.7100, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (637, N'REJILLA N° 24 TRIPLE PARA AUTOS 
(BULTO X 60)', NULL, 38.6400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (638, N'TOP GOURMET REPASADOR TOALLA', NULL, 38.8800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (639, N'CHUPATODO TRAPO DE PISO ', NULL, 28.2800, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (640, N'DELEBRITEX TRAPO DE PISO NIDO DE ABEJAS', NULL, 27.3600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (641, N'DURAMAS MOPA AMARILLA', NULL, 40.1300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (642, N'DURAMAS MOPA BLANCA MAXI', NULL, 31.7300, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (643, N'DURAMAS MOPA GRIS MAXI', NULL, 27.5000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (644, N'DURAMAS TRAPO DE PISO GRIS COSTURADO ( BULTOX 120)', NULL, 10.6600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (645, N'DURAMAS TRAPO DE PISO GRIS COSTURADO CONSORCIO (X 60)', NULL, 14.8000, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (646, N'DURAMAS TRAPO DE PISO NIDO DE ABEJA BLANCO (X 60)', NULL, 19.4400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (647, N'DURAMAS TRAPO DE PISO NIDO DE ABEJA GRIS (X 60)', NULL, 19.4400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (648, N'DURAMAS TRAPO DE PISO NIDO DE ABEJA RAYADO (X 60)', NULL, 19.4400, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (649, N'DURAMAS TRAPO DE PISO PLANO RAYADO (X 60)', NULL, 19.0600, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (650, N'JULIETA TRAPO DE PISO GRIS 50 X 60', NULL, 8.4200, NULL, NULL, 1)
INSERT [dbo].[Articulo] ([id_articulo], [art_nombre], [art_descripcion], [art_precio_uni], [art_precio_mayor_1], [art_precio_mayor_2], [art_activo]) VALUES (651, N'NIVEA CEREZA CREMA CORPORAL 90', NULL, NULL, NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[Articulo] OFF
SET IDENTITY_INSERT [dbo].[Entreda] ON 

INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (1, CAST(0x453F0B00 AS Date), 2, 20, 1)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (2, CAST(0x513F0B00 AS Date), 2, 45, 75)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (3, CAST(0x5C3F0B00 AS Date), 2, 45, 2)
INSERT [dbo].[Entreda] ([id_entrada], [ent_fecha], [ent_usuario], [ent_cantidad], [ent_articulo]) VALUES (4, CAST(0x7C3F0B00 AS Date), 2, 40, 3)
SET IDENTITY_INSERT [dbo].[Entreda] OFF
SET IDENTITY_INSERT [dbo].[Inventario] ON 

INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (1, 1, 20, 10, N'')
INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (2, 75, 45, 10, N'')
INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (3, 2, 45, 10, N'')
INSERT [dbo].[Inventario] ([id_inventario], [inv_articulo], [inv_cantidad], [inv_cantidad_min], [inv_descripcion]) VALUES (4, 3, 40, 10, N'')
SET IDENTITY_INSERT [dbo].[Inventario] OFF
SET IDENTITY_INSERT [dbo].[Perfil] ON 

INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (1, N'ADMINISTRADOR')
INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (2, N'MASTER')
INSERT [dbo].[Perfil] ([id_perfil], [per_perfil]) VALUES (3, N'CAJERO')
SET IDENTITY_INSERT [dbo].[Perfil] OFF
SET IDENTITY_INSERT [dbo].[Usuario] ON 

INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (1, N'Alexander', N'9484', 1, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (2, N'Tato', N'9484', 2, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (3, N'Luis', N'2030', 2, 1)
INSERT [dbo].[Usuario] ([id_usuario], [usu_nombre], [usu_password], [usu_perfil], [usu_activo]) VALUES (7, N'Leo', N'123', 3, 1)
SET IDENTITY_INSERT [dbo].[Usuario] OFF
ALTER TABLE [dbo].[Articulo] ADD  CONSTRAINT [chk_art_activo]  DEFAULT ((1)) FOR [art_activo]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [chk_usu_activo]  DEFAULT ((1)) FOR [usu_activo]
GO
ALTER TABLE [dbo].[Detalle_Venta]  WITH CHECK ADD FOREIGN KEY([deta_id_detalle_venta])
REFERENCES [dbo].[Venta] ([id_venta])
GO
ALTER TABLE [dbo].[Detalle_Venta]  WITH CHECK ADD FOREIGN KEY([deta_id_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Entreda]  WITH CHECK ADD FOREIGN KEY([ent_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Entreda]  WITH CHECK ADD FOREIGN KEY([ent_usuario])
REFERENCES [dbo].[Usuario] ([id_usuario])
GO
ALTER TABLE [dbo].[Inventario]  WITH CHECK ADD FOREIGN KEY([inv_articulo])
REFERENCES [dbo].[Articulo] ([id_articulo])
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD FOREIGN KEY([usu_perfil])
REFERENCES [dbo].[Perfil] ([id_perfil])
GO
ALTER TABLE [dbo].[Venta]  WITH CHECK ADD FOREIGN KEY([ven_id_usuario])
REFERENCES [dbo].[Usuario] ([id_usuario])
GO
ALTER TABLE [dbo].[Inventario]  WITH CHECK ADD  CONSTRAINT [chk_inv_cantidad] CHECK  (([inv_cantidad]>=(0)))
GO
ALTER TABLE [dbo].[Inventario] CHECK CONSTRAINT [chk_inv_cantidad]
GO
USE [master]
GO
ALTER DATABASE [Control_de_Inventario] SET  READ_WRITE 
GO
