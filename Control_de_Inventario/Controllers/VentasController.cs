using Control_de_Inventario.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Control_de_Inventario.Controllers
{
    public class VentasController : Controller
    {
        [HttpPost]
        public JsonResult GuardarVenta(List<ItemVentaViewModel> items)
        {
            //TODO: implementar guardado de la venta
            return Json(new { });
        }
    }
}
