﻿using Control_de_Inventario.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
<<<<<<< HEAD
=======
using Control_de_Inventario.Models;
>>>>>>> 494e6a934b76ad42e4b6ca7377c931b312f203b4

namespace Control_de_Inventario.Controllers
{
    public class VentasController : Controller
    {
        [HttpPost]
        public JsonResult GuardarVenta(List<ItemVentaViewModel> items)
        {
            //TODO: implementar guardado de la venta
<<<<<<< HEAD
=======
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                decimal Total = 0;
                int idProducto = 0;
                int cantidad = 0;
                decimal SubTotal = 0;
                decimal precioUni = 0;

                for(int i = 0; i < items.Count(); i++)
                {
                    idProducto = Convert.ToInt32(items[i].IdProducto);
                    var produto = db.Articulo.Find(idProducto);
                    cantidad = items[i].Cantidad;

                    precioUni = produto.art_precio_uni.Value;

                    SubTotal = precioUni * cantidad;

                    Total = SubTotal + Total;
                }
                
                db.spAgregarVenta(1, Total);

                var idVenta = db.Venta.Max(x => (int?)x.id_venta) ?? 0;

                
                for (int i = 0; i < items.Count(); i++)
                {
                    idProducto = Convert.ToInt32(items[i].IdProducto);
                    var produto = db.Articulo.Find(idProducto);
                    cantidad = items[i].Cantidad;
                    precioUni = produto.art_precio_uni.Value;
                    db.spAgregarDetalleVenta(idVenta, idProducto, precioUni, cantidad);
                }



            }
>>>>>>> 494e6a934b76ad42e4b6ca7377c931b312f203b4
            return Json(new { });
        }
    }
}