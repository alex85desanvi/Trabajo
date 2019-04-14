using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models;
using Control_de_Inventario.Models.TableViewModels;
//Recivira el model ViewModels
using Control_de_Inventario.Models.ViewModels;

namespace Control_de_Inventario.Controllers
{
    public class ArtController : Controller
    {
        // GET: Art
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

        

         [HttpGet]
        public ActionResult AddOrEdit(int id = 0)
        {
            if (id == 0)
                return View(new Articulo());
            else
            {
                using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
                {
                    return View(db.Articulo.Where(x => x.id_articulo==id).FirstOrDefault<Articulo>());
                }
            }
        }

        [HttpPost]
        public ActionResult AddOrEdit(Articulo emp)
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                if (emp.id_articulo == 0)
                {
                    db.spAgregarArticulo(emp.art_nombre,emp.art_descripcion,emp.art_precio_uni,emp.art_precio_mayor_1,emp.art_precio_mayor_2);
                    db.SaveChanges();
                    return Json(new { success = true, message = "Saved Successfully" }, JsonRequestBehavior.AllowGet);
                }
                else {
                    //db.Entry(emp).State = System.Data.Entity.EntityState.Modified;
                    db.spEditarArticulo(emp.id_articulo, emp.art_nombre, emp.art_descripcion, emp.art_precio_uni, emp.art_precio_mayor_1, emp.art_precio_mayor_2);
                    db.SaveChanges();
                    return Json(new { success = true, message = "Updated Successfully" }, JsonRequestBehavior.AllowGet);
                }
            }


        }

        [HttpPost]
        public ActionResult Delete(int id)
        {
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                Articulo emp = db.Articulo.Where(x => x.id_articulo == id).FirstOrDefault<Articulo>();
                db.spEliminarArticulo(emp.id_articulo);
                db.SaveChanges();
                return Json(new { success = true, message = "Deleted Successfully" }, JsonRequestBehavior.AllowGet);
            }
    
        }

    }
}