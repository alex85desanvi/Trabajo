using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models;

namespace Control_de_Inventario.Controllers
{
    public class VenController : Controller
    {
        // GET: Ven
        public ActionResult Index()
        {
            return View();
        }


        public ActionResult GetData()
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                List<vwmostrararticulo> empList = db.vwmostrararticulo.ToList<vwmostrararticulo>();
                return Json(new { data = empList }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}