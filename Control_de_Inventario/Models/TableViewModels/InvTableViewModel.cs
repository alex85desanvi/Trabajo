using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Control_de_Inventario.Models.TableViewModels
{
    public class InvTableViewModel
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public int? Cantidad { get; set; }
    }
}