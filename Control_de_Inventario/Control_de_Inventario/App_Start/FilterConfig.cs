using System.Web;
using System.Web.Mvc;

namespace Control_de_Inventario
{
    public class FilterConfig
    {
        //PILA DE FILTROS
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            //DAR DE ALTA UN NUEVO FILTRO (fILTRO CREADO VERIFYSESSION)
            filters.Add(new Filters.VerifySession());

        }
    }
}
