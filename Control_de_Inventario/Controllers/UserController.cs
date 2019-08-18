using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models.ViewModels;
using Control_de_Inventario.Models.TableViewModels;
using Control_de_Inventario.Models;

namespace Control_de_Inventario.Controllers
{
    public class UserController : Controller
    {
        // GET: User
        public ActionResult Index()
        {
            var oUser = (Usuario)Session["Usuario"];
            if (oUser?.usu_perfil == 3)//3 = usuario cajero
            {
                return View("~/Views/Mensajes/SinPermisos.cshtml");
            }
            List<UserTableViewModel> lst = null;
            using (Control_de_InventarioEntities db = new Control_de_InventarioEntities())
            {
                lst = (from d in db.vwmostrarusuarios
                       select new UserTableViewModel
                       {
                           id = d.ID,
                           usuario = d.USUARIO,
                           perfil = d.PERFIL
                       }).ToList();
            }

            return View(lst);
        }


        [HttpGet]
        public ActionResult Add()
        {
            return View();
        }


        [HttpPost]
        public ActionResult Add(UserViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            using (var db = new Control_de_InventarioEntities())
            {
                db.spAgregarUsuario(model.Usuario, model.Password, model.Perfil);
                //db.SaveChanges();
            }

            return Redirect(Url.Content("~/User/"));
        }

        public ActionResult Edit(int Id)
        {
            EditUserViewModel model = new EditUserViewModel();

            using (var db = new Control_de_InventarioEntities())
            {
                //Me trae un objeto que tiene ese ID
                var oUser = db.Usuario.Find(Id);
                model.Id = oUser.id_usuario;
                model.Usuario = oUser.usu_nombre;
                model.Perfil = (int)oUser.usu_perfil;
            }

            return View(model);
        }

        [HttpPost]
        public ActionResult Edit(EditUserViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            using (var db = new Control_de_InventarioEntities())
            {
                db.spEditarUsuario(model.Id, model.Usuario, model.Password, model.Perfil);
                //No hace falta porque uso un Procedimiento Almacenado para Editar la tabla Usuario
                //db.SaveChanges();
            }

            return Redirect(Url.Content("~/User/"));
        }

        public ActionResult Delete(int Id)
        {
            DeleteUserModel model = new DeleteUserModel();

            using (var db = new Control_de_InventarioEntities())
            {
                //Me trae un objeto que tiene ese ID
                var oUser = db.Usuario.Find(Id);
                model.Id = oUser.id_usuario;
                db.spEliminarUsuario(model.Id);
            }

            return Redirect(Url.Content("~/User/"));
        }
    }
}