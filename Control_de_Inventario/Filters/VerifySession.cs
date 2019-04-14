using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Control_de_Inventario.Models;
using Control_de_Inventario.Controllers;

namespace Control_de_Inventario.Filters
{
    public class VerifySession : ActionFilterAttribute 
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var oUser = (Usuario)HttpContext.Current.Session["Usuario"];

            if(oUser == null)
            {
                //SI NO TENES SESION SOLO PODES INGRESAR A ACCESS PARA INGRESAR TU SESION
                if(filterContext.Controller is AccessController == false ){
                    filterContext.HttpContext.Response.Redirect("~/Access/Index");
                }
            }
            else
            {   
                //SI TENEGO SESION NO PODES VOLVER A ENTRAR ACCESS
                if(filterContext.Controller is AccessController == true)
                {
                    filterContext.HttpContext.Response.Redirect("~/Home/Index");
                }
            }

         

            base.OnActionExecuting(filterContext);
        }
    }

}