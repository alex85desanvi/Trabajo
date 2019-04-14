using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models;
using Control_de_Inventario.Models.TableViewModels;

namespace Control_de_Inventario.Controllers
{
    public class InvController : Controller
    {
        // GET: Inv
        public ActionResult Index()
        {

            return View();
        }

        public ActionResult GetData()
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                List<vwmostrarinventario> invList = db.vwmostrarinventario.ToList<vwmostrarinventario>();
                return Json(new { data = invList }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}