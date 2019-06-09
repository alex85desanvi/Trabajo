using Control_de_Inventario.Controllers;
using Control_de_Inventario.Filters;
using Control_de_Inventario.Models;
using Control_de_Inventario.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Control_de_Inventario.Controllers
{
    public class EntController : Controller
    {
        // GET: Ent
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult GetData()
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                List<vwmostrarentrada> invList = db.vwmostrarentrada.ToList<vwmostrarentrada>();
                return Json(new { data = invList }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public ActionResult AddStock(int id = 0)
        {
            if (id == 0)
                return View(new vwmostrarentrada());
            else
            {
                using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
                {
                    return View(db.vwmostrarentrada.Where(x => x.id_articulo == id).FirstOrDefault<vwmostrarentrada>());
                }
            }
        }

        [HttpPost]
        public ActionResult AddStock(vwmostrarentrada art)
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {

                var usuario = (Session["Usuario"] as Usuario)?.id_usuario;

                db.spAgregarEntrada(usuario, art.inv_cantidad, art.id_articulo);

                return Json(new { success = true, message = "Saved Successfully" }, JsonRequestBehavior.AllowGet);
            }


        }


    }

}