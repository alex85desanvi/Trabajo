using Control_de_Inventario.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Control_de_Inventario.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(DateTime? fecha = null)
        {
            var filtro = fecha.HasValue ? fecha.Value : DateTime.Now.Date;

            using(var context = new Control_de_InventarioEntities())
            {
                var sumatoria = context.Venta.Where(x => x.ven_fecha >= filtro && x.ven_fecha <= filtro).Sum(x => x.ven_total) ?? 0m;
                ViewBag.ventaTotal = sumatoria;
            }

            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}