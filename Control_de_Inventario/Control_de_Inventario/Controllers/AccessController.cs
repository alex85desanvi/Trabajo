using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models;
using Control_de_Inventario.Models.ViewModels;

namespace Control_de_Inventario.Controllers
{
    public class AccessController : Controller
    {
        // GET: Access
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Enter(string user, string password)
        {   //CREAMOS UN TRY-CATCH PARA AUTENTIFICAR EL USUARIO INGRESADO
            try
            {
                using (Control_de_InventarioEntities db= new Control_de_InventarioEntities())
                {
                    var lst = from d in db.Usuario
                              where d.usu_nombre == user && d.usu_password == password && d.usu_activo == true
                              select d;
                    /*CON UN IF CONSULTAMOS LA CANTIDAD DE REGISTROS ENCONTRADOS
                    EN LA LISTA "LST"*/
                    if(lst.Count()>0)
                    {
                        Usuario oUser = lst.First();
                        Session["Usuario"] = oUser;
                        return Content("1");
                    }
                    else
                    {
                        return Content("Usuario invalido");
                    }
                }

            }
            catch (Exception ex)
            {
                return Content("Ocurrio un error :( " + ex.Message);
            }
        }

        
        public ActionResult Close()
        {
            Session.Clear();

            return RedirectToAction("Acces", "Index");
        }

    }
}